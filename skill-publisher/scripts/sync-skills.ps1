# sync-skills.ps1 - Skill Publisher 同步脚本
# 用法: .\sync-skills.ps1 -Mode <pull|push>
param(
    [ValidateSet("pull", "push")]
    [string]$Mode = "push"
)

$ErrorActionPreference = "Stop"
$Git = "C:\Program Files\Git\cmd\git.exe"
$AuthFile = "$env:USERPROFILE\.openclaw\agents\main\agent\skill-sync-config.json"
$LogFile = "$env:USERPROFILE\.openclaw\logs\skills-sync.log"
$ConflictFile = "$env:USERPROFILE\.openclaw\agents\main\agent\skills-conflict.json"

if (-not (Test-Path (Split-Path $LogFile))) {
    New-Item -ItemType Directory -Force -Path (Split-Path $LogFile) | Out-Null
}

function Write-Log {
    param([string]$Msg, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts [$Level] $Msg" | Tee-Object -FilePath $LogFile -Append
}

# 读取认证配置
if (-not (Test-Path $AuthFile)) {
    Write-Log "Auth file not found: $AuthFile" "ERROR"
    exit 1
}
$config = Get-Content $AuthFile | ConvertFrom-Json
$token      = $config.token
$gitPath    = $config.gitPath      # Git 工作目录
$skillsPath = $config.skillsPath   # OpenClaw 技能目录
$proxy      = $config.proxy
$repoUrl    = $config.repoUrl

# 解析 owner/repo 用于 remote URL
if ($repoUrl -match "github\.com/(.+/([^/]+?))(?:\.git)?$") {
    $repoOwner = $Matches[2]
    $repoName  = $Matches[2]
} else {
    $repoOwner = "goutou08"
    $repoName  = "openclaw-skills"
}

# 确保代理配置
if ($proxy) {
    & $Git config --global http.proxy $proxy 2>$null
    & $Git config --global https.proxy $proxy 2>$null
}

# 设置 remote URL（含 token，仅本次操作使用）
$remoteUrlWithToken = "https://${token}@github.com/$repoOwner/$repoName.git"
$remoteUrlClean     = "https://github.com/$repoOwner/$repoName.git"

function Set-RemoteUrl {
    param([bool]$WithToken)
    $url = if ($WithToken) { $remoteUrlWithToken } else { $remoteUrlClean }
    & $Git -C $gitPath remote set-url origin $url 2>$null
}

function Sync-Skills-ToLocal {
    # gitPath 和 skillsPath 相同时，无需同步
    if ($gitPath -eq $skillsPath) {
        Write-Log "gitPath == skillsPath, skipping sync"
        return
    }
    if (-not (Test-Path $gitPath)) {
        Write-Log "gitPath not found: $gitPath" "WARN"
        return
    }
    Get-ChildItem $gitPath -Directory | ForEach-Object {
        $dest = "$skillsPath\$($_.Name)"
        if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
        Copy-Item -Recurse -Force $_.FullName $dest
    }
    Write-Log "Synced gitPath/ to skillsPath/"
}

function Sync-Local-ToGit {
    # gitPath 和 skillsPath 相同时，无需同步
    if ($gitPath -eq $skillsPath) {
        Write-Log "gitPath == skillsPath, skipping sync"
        return
    }
    Get-ChildItem $skillsPath -Directory | ForEach-Object {
        $target = "$gitPath\$($_.Name)"
        if (Test-Path $target) { Remove-Item -Recurse -Force $target }
        Copy-Item -Recurse -Force $_.FullName $target
    }
    # 移除 gitPath 中 skillsPath 已删除的 skill
    Get-ChildItem $gitPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        if (-not (Test-Path "$skillsPath\$($_.Name)")) {
            Remove-Item -Recurse -Force $_.FullName
            Write-Log "Removed deleted skill: $($_.Name)"
        }
    }
    Write-Log "Synced skillsPath/ to gitPath/"
}

function Test-HasConflict {
    Set-RemoteUrl -WithToken $false
    $output = & $Git -C $gitPath pull --no-commit origin main 2>&1
    if ($output -match "CONFLICT") {
        & $Git -C $gitPath merge --abort 2>$null
        return $true
    }
    & $Git -C $gitPath commit --no-edit 2>$null
    return $false
}

# ========== 主流程 ==========

Write-Log "=== Skill sync started: $Mode ==="

try {
    if ($Mode -eq "pull") {
        Write-Log "Pulling latest from GitHub..."
        Set-RemoteUrl -WithToken $false
        $output = & $Git -C $gitPath pull origin main 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Pull failed: $output" "ERROR"
            exit 1
        }
        Write-Log "Pull successful."
        Sync-Skills-ToLocal
        Write-Log "=== Pull completed ==="
        exit 0
    }

    if ($Mode -eq "push") {
        # Step 1: pull 检测冲突
        Write-Log "Step 1: Pull and conflict check..."
        $conflict = Test-HasConflict
        if ($conflict) {
            Write-Log "Conflict detected! Writing conflict report." "WARN"
            $conflictReport = @{
                detectedAt = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss+08:00")
                conflictWith = "qingfeng-or-other"
                status = "pending_decision"
                message = "有冲突，需要决定用本地还是仓库版本"
            } | ConvertTo-Json -Depth 5
            Set-Content -Path $ConflictFile -Value $conflictReport -Encoding UTF8
            Write-Log "Conflict report written. Stopping." "WARN"
            exit 2
        }
        Write-Log "No conflict from pull."

        # Step 2: 同步
        Write-Log "Step 2: Syncing skills..."
        Sync-Local-ToGit

        # Step 3: 检查今日改动
        Write-Log "Step 3: Checking for changes..."
        Set-RemoteUrl -WithToken $false
        & $Git -C $gitPath add .
        $status = & $Git -C $gitPath status --porcelain 2>$null
        if (-not $status) {
            Write-Log "No changes to commit. Exiting."
            exit 0
        }

        # 列出改动的 skill
        $changedSkills = $status | ForEach-Object {
            $line = $_.Trim()
            if ($line -match "^..\s+(.+)") {
                $path = $Matches[1]
                if ($path -match "^([^/]+)") { $Matches[1] }
            }
        } | Sort-Object -Unique
        $changedList = $changedSkills -join ", "
        if (-not $changedList) { $changedList = "(various)" }
        Write-Log "Changed: $changedList"

        # Step 4: 提交
        $commitMsg = "Sync: $changedList ($(Get-Date -Format 'yyyy-MM-dd'))"
        Set-RemoteUrl -WithToken $true
        & $Git -C $gitPath commit -m $commitMsg

        # Step 5: 推送
        Write-Log "Step 4: Pushing to GitHub..."
        $pushOut = & $Git -C $gitPath push origin main 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Push failed: $pushOut" "ERROR"
            & $Git -C $gitPath reset --soft HEAD~1 2>$null
            exit 1
        }
        Set-RemoteUrl -WithToken $false

        # Step 6: 同步到本地（确保两边一致）
        Sync-Skills-ToLocal

        Write-Log "=== Push completed: $changedList ==="
        exit 0
    }

} catch {
    Write-Log "Exception: $_" "ERROR"
    Set-RemoteUrl -WithToken $false
    exit 1
}
