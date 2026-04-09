---
name: skill-publisher
description: 创建并管理 OpenClaw 共享 skills 仓库。将本地 skills 发布到 GitHub 仓库，支持多 AI 助手（清风、明月等）共享。用于：创建新的 skills 仓库、发布 skill 到共享仓库、通知其他 AI 助手更新。
---

# Skill Publisher

管理本地 skills 与 GitHub 共享仓库之间的同步。

## 核心概念

| 路径 | 说明 |
|------|------|
| **gitPath** | Git 工作目录（clone 地址），推拉操作在这里执行 |
| **skillsPath** | OpenClaw 实际读取的技能目录 |

**同步规则（重要）：** 如果 `gitPath == skillsPath`（即 skills 直接在 git 仓库根目录），则无需同步步骤，push/pull 直接操作。如果不同，则脚本负责双向同步。

---

## 运行时配置（敏感信息）

**配置文件路径：** `%USERPROFILE%\.openclaw\agents\main\agent\skill-sync-config.json`

读取方式（PowerShell）：
```powershell
$authFile = "$env:USERPROFILE\.openclaw\agents\main\agent\skill-sync-config.json"
$config = Get-Content $authFile | ConvertFrom-Json
$gitPath    = $config.gitPath      # Git 工作目录
$skillsPath = $config.skillsPath   # OpenClaw 技能目录
$token      = $config.token        # GitHub PAT
$proxy      = $config.proxy        # 代理地址
```

**auth 文件由 setup 流程生成，Token 绝不写入 SKILL.md 或任何共享文件。**

---

## 前置检查

### 1. 检查 Git 是否可用

```bash
git --version
```

**如果报错：** Git 未安装
- 用 winget 安装：`winget install Git.Git`
- 安装后**重新打开终端**
- 或使用完整路径：`C:\Program Files\Git\cmd\git.exe`

### 2. 检查共享仓库是否已配置

```powershell
$authFile = "$env:USERPROFILE\.openclaw\agents\main\agent\skill-sync-config.json"
if (-not (Test-Path $authFile)) {
    # 触发首次配置流程
}
```

---

## 首次配置流程（setup mode）

### 步骤 1：询问用户（必须）

向用户请求以下信息：
- **GitHub 仓库地址**（例如 `https://github.com/username/openclaw-skills.git`）
- **GitHub Personal Access Token**（Classic PAT，需要 repo scope）
- **Git 工作目录 + skills 目录**（是否相同？相同则无需同步步骤）
- **代理端口**（可选，见"代理配置"章节）

### 步骤 2：保存配置到 auth 文件

```json
// 写入 %USERPROFILE%\.openclaw\agents\main\agent\skill-sync-config.json
{
  "repoUrl": "<用户提供的仓库URL>",
  "token": "<用户提供的PAT>",
  "gitPath": "<git工作目录>",
  "skillsPath": "<OpenClaw技能目录>",
  "proxy": "<用户提供的代理或留空>"
}
```

### 步骤 3：克隆仓库（仅当 gitPath 和 skillsPath 不同时需要）

```bash
git clone https://<TOKEN>@github.com/<owner>/<repo>.git <gitPath>
```

### 步骤 4：配置 Git 用户

```bash
git config --global user.email "openclaw@users.noreply.github.com"
git config --global user.name "<YourName>"
```

### 步骤 5：配置代理（如需要）

如果 Git clone/push 报 `Connection reset`，执行"代理配置"章节的步骤。

---

## 代理配置（Windows）

### 自动发现系统代理

```powershell
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
```

关注 `ProxyServer`（格式 `127.0.0.1:端口`）和 `ProxyEnable`（1=启用）。

### 扫描本机常见代理端口

```powershell
$ports = @(7890, 7891, 1080, 10808, 8080, 3128, 8118, 51926)
foreach ($p in $ports) {
    try {
        $c = New-Object System.Net.Sockets.TcpClient
        $c.Connect("127.0.0.1", $p)
        if ($c.Connected) { Write-Host "OPEN: $p" }
        $c.Close()
    } catch {}
}
```

### 配置 Git 使用代理

```bash
git config --global http.proxy http://127.0.0.1:<PORT>
git config --global https.proxy http://127.0.0.1:<PORT>
```

---

## 日常同步流程

### 读取配置（所有操作的第 1 步）

```powershell
$authFile = "$env:USERPROFILE\.openclaw\agents\main\agent\skill-sync-config.json"
$config = Get-Content $authFile | ConvertFrom-Json
$gitPath    = $config.gitPath
$skillsPath = $config.skillsPath
$token      = $config.token
$proxy      = $config.proxy
```

### 拉取更新（清风更新了 → 同步到本地）

> **如果 gitPath == skillsPath**：直接 `git pull`，无需额外同步。

```bash
git -C <gitPath> pull
# 如果 gitPath != skillsPath，额外同步 skills
Get-ChildItem <gitPath> | ForEach-Object {
    Copy-Item -Recurse -Force "<gitPath>\$($_.Name)" "<skillsPath>\"
}
```

### 推送更新（本地更新了 → 同步到清风/GitHub）

```bash
cd <gitPath>

# 提交
git add .
git commit -m "Update: $(Get-Date -Format 'yyyy-MM-dd') skills sync"

# 推送（Token 运行时注入 remote URL）
git remote set-url origin https://<TOKEN>@github.com/<owner>/<repo>.git
git push
git remote set-url origin https://github.com/<owner>/<repo>.git
```

---

## 常用 Git 命令

```bash
# 查看状态
git status

# 查看远程
git remote -v

# 查看提交历史
git log --oneline -5

# 强制推送（谨慎）
git push -f origin main
```

---

## 故障排查

| 问题 | 解决方案 |
|------|---------|
| `git 不是 cmdlet` | 用完整路径 `C:\Program Files\Git\cmd\git.exe` 或重新安装 Git |
| `Connection reset` | GitHub HTTPS 被墙，配置 http.proxy 见"代理配置"章节 |
| `Permission denied` | Token 无效或过期，检查 PAT 是否有 `repo` scope |
| `Authentication failed` | Token 未配置，检查 auth 文件是否存在 |
| 代理端口未知 | 扫描常见端口或查看注册表 `HKCU:\...\Internet Settings` |
| GitHub secret scanning 拦截 | Token 不能出现在任何 commit 里，必须在 push 前彻底抹掉 |

---

## 同步调度

### 调度策略

| 事件 | 时间 | 行为 |
|------|------|------|
| 自动 pull | 每天 08:00 | pull → 更新本地 → 完成 |
| 自动 push | 每天 23:00 | pull 检测冲突 → diff → 有冲突停手报备，无冲突 commit+push |
| 手动触发 | 随时 | 用户说"同步技能" → 立即执行完整 pull + diff + push 流程 |

### 23:00 Push 完整流程

```
1. pull（--no-commit，检测冲突）
   └─ 有冲突 → 写入冲突报告 → 通知我 → 停止

2. 同步（仅当 gitPath != skillsPath 时）
   └─ 删除：skillsPath 没有但 gitPath 有的 skill

3. diff 检测今日改动
   └─ 无改动 → 静默完成
   └─ 有改动 → 展示改动清单 → commit + push
```

### 冲突处理

冲突报告写入：`%USERPROFILE%\.openclaw\agents\main\agent\skills-conflict.json`

```json
{
  "detectedAt": "2026-04-04T23:00:00+08:00",
  "status": "pending_decision",
  "message": "有冲突，需要决定用本地还是仓库版本"
}
```

**冲突时不停手、不覆盖，由用户决定用哪边。**

### Cron Job 配置

```bash
# 08:00 pull（isolated，安静模式）
openclaw cron add \
  --name "skills-pull" \
  --cron "0 8 * * *" --tz "Asia/Shanghai" \
  --session isolated \
  --message 'powershell -File "<skillsPath>\skill-publisher\scripts\sync-skills.ps1" -Mode pull' \
  --announce

# 23:00 push（isolated）
openclaw cron add \
  --name "skills-push" \
  --cron "0 23 * * *" --tz "Asia/Shanghai" \
  --session isolated \
  --message 'powershell -File "<skillsPath>\skill-publisher\scripts\sync-skills.ps1" -Mode push' \
  --announce
```

### 日志

同步日志位于：`%USERPROFILE%\.openclaw\logs\skills-sync.log`

---

## 安全原则

1. **Token 永不写入 SKILL.md 或任何共享文件** — 只存到 `skill-sync-config.json`
2. **Token 永不写入 git commit** — 推送时临时注入 URL，push 完成后立即还原
3. **分支命名**：始终使用 `main`，不是 `master`
4. **先拉后推**：每次 push 前必须 pull + diff，有冲突不停手
5. **代理端口可能变化**：VPN 重连后端口可能不同，发现网络问题先重新扫描
6. **冲突不停手**：任何冲突写入报告，由用户决定，不自动覆盖
