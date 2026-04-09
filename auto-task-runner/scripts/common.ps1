# common.ps1 - shared helpers
$script:Root = "F:\OpenClaw_Soul\workspace"
$script:ProjectsDir = "$script:Root\projects"
$script:MemoryDir = "$script:Root\memory"
$script:StatePath = "$script:MemoryDir\project-runner-state.json"

function Ensure-Dirs {
    if (-not (Test-Path $script:ProjectsDir)) {
        New-Item -ItemType Directory -Path $script:ProjectsDir -Force | Out-Null
    }
    if (-not (Test-Path $script:MemoryDir)) {
        New-Item -ItemType Directory -Path $script:MemoryDir -Force | Out-Null
    }
}

function Read-State {
    $default = @{
        mode = "idle"
        current_project = $null
        current_project_path = $null
        current_output_dir = $null
        start_time = $null
        end_time = $null
        last_run = $null
    }
    if (-not (Test-Path $script:StatePath)) {
        return $default
    }
    $bytes = [System.IO.File]::ReadAllBytes($script:StatePath)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    } else {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    $parsed = $text | ConvertFrom-Json
    foreach ($key in $default.Keys) {
        if (-not $parsed.PSObject.Properties[$key]) {
            $parsed | Add-Member -NotePropertyName $key -NotePropertyValue $default[$key]
        }
    }
    return $parsed
}

function Write-State($state) {
    $json = $state | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllBytes($script:StatePath, [System.Text.Encoding]::UTF8.GetBytes($json))
}

function Read-ProjectFile($path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    }
    return [System.Text.Encoding]::UTF8.GetString($bytes)
}

function Write-ProjectFile($path, $content) {
    [System.IO.File]::WriteAllBytes($path, [System.Text.Encoding]::UTF8.GetBytes($content))
}

function Get-ExistingOutputDirFromProject($projectPath) {
    if (-not (Test-Path $projectPath)) {
        return $null
    }
    $text = Read-ProjectFile $projectPath
    $fm = Get-FrontmatterBlock $text
    if ($null -eq $fm) {
        return $null
    }
    if ($fm -match '(?m)^output_dir:\s*(.+?)\s*$') {
        return $Matches[1].Trim()
    }
    return $null
}

function Get-SafeProjectOutputName($projectPath) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)
    $ascii = ($base.ToLowerInvariant() -replace '[^a-z0-9._-]+', '-')
    $ascii = ($ascii -replace '-{2,}', '-').Trim('-','.')
    if ([string]::IsNullOrWhiteSpace($ascii)) {
        $ascii = 'project'
    }

    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($base)
        $hashBytes = $md5.ComputeHash($bytes)
        $hash = ([System.BitConverter]::ToString($hashBytes)).Replace('-', '').ToLowerInvariant().Substring(0, 8)
    } finally {
        $md5.Dispose()
    }

    return "$ascii-$hash"
}

function Get-ProjectOutputDir($projectPath) {
    $existing = Get-ExistingOutputDirFromProject $projectPath
    if ($existing) {
        return $existing
    }
    $safeName = Get-SafeProjectOutputName $projectPath
    return Join-Path $script:ProjectsDir $safeName
}

function Ensure-ProjectOutputDir($projectPath) {
    $dir = Get-ProjectOutputDir $projectPath
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    return $dir
}

function Get-FrontmatterBlock($text) {
    if ($text -match '(?s)^---\r?\n(.*?)\r?\n---\r?\n?') {
        return $Matches[1]
    }
    return $null
}

function Get-ProjectStatus($path) {
    $text = Read-ProjectFile $path
    $fm = Get-FrontmatterBlock $text
    if ($null -eq $fm) {
        return 'new'
    }
    if ($fm -match '(?m)^status:\s*(\w+)\s*$') {
        return $Matches[1]
    }
    return 'managed'
}

function Add-FrontmatterIfMissing($path, $status = 'pending') {
    $text = Read-ProjectFile $path
    $fm = Get-FrontmatterBlock $text
    if ($null -ne $fm) {
        return
    }
    $now = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
    $newText = @"
---
status: $status
created: $now
started: null
completed: null
blocked_reason: null
output_dir: $(Get-ProjectOutputDir $path)
---

$text
"@
    Write-ProjectFile $path $newText
}

function Update-Frontmatter($path, $updates) {
    $text = Read-ProjectFile $path
    Add-FrontmatterIfMissing $path
    $text = Read-ProjectFile $path

    $lines = $text -split "`r?`n"
    $result = @()
    $inFrontmatter = $false
    $frontmatterEnded = $false
    $frontmatterMap = @{}
    $bodyLines = @()

    foreach ($line in $lines) {
        if (-not $frontmatterEnded -and $line -match '^---\s*$') {
            if (-not $inFrontmatter) {
                $inFrontmatter = $true
            } else {
                $inFrontmatter = $false
                $frontmatterEnded = $true
            }
            continue
        }
        if ($inFrontmatter) {
            if ($line -match '^(\w+):\s*(.*)$') {
                $frontmatterMap[$Matches[1]] = $Matches[2]
            }
        } else {
            $bodyLines += $line
        }
    }

    foreach ($key in $updates.Keys) {
        $frontmatterMap[$key] = $updates[$key]
    }

    $orderedKeys = @('status','created','started','completed','blocked_reason','output_dir')
    $result += '---'
    foreach ($key in $orderedKeys) {
        if ($frontmatterMap.ContainsKey($key)) {
            $result += "${key}: $($frontmatterMap[$key])"
        }
    }
    foreach ($key in $frontmatterMap.Keys | Sort-Object) {
        if ($orderedKeys -notcontains $key) {
            $result += "${key}: $($frontmatterMap[$key])"
        }
    }
    $result += '---'
    if ($bodyLines.Count -gt 0) {
        $result += ''
        $result += $bodyLines
    }

    Write-ProjectFile $path ($result -join "`n")
}
