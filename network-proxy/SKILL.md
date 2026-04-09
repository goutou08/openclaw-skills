---
name: network-proxy
description: 让 PowerShell/系统 CLI 通过本地代理翻墙。当需要访问被墙的外部服务（如 OpenAI Codex OAuth、GitHub、OpenAI API）时激活此技能。
---

# Network Proxy - PowerShell 代理配置

## 概念

通过设置环境变量 `HTTP_PROXY` / `HTTPS_PROXY`，让 PowerShell 里的所有 HTTP/HTTPS 请求走本地代理（Clash Verge），实现翻墙。

**核心价值：** 解决 OpenClaw CLI（运行在 PowerShell 中）无法访问被墙服务的问题。

## 架构说明

```
PowerShell（openclaw 命令）
     ↓
$env:HTTP_PROXY / HTTPS_PROXY
     ↓
Clash Verge（本地代理客户端）
     ↓
机场订阅（远程 VPN 服务器）
     ↓
目标网站（auth.openai.com、GitHub 等）
```

**三层概念：**
- **机场订阅链接**：远程 VPN 服务器地址（付费，用户自行获取）
- **Clash Verge**：本地代理软件，后台运行，持有机场订阅连接
- **本地代理端口**：Clash Verge 对外提供的入口

## 首次初始化

首次使用前，需要配置代理端口：

```powershell
# 进入 skill 目录
cd F:\OpenClaw_Soul\workspace\skills\network-proxy

# 运行初始化（会提示输入端口）
.\init.ps1
```

初始化会要求输入：
- **代理端口**：Clash Verge 的本地 HTTP 代理端口（默认一般是 7890/7897/7891 等）
- **机场订阅链接**（可选）：仅作记录，不参与代理工作

配置保存在 `~\.openclaw\skills-config\network-proxy.json`，不进入 git。

## 快速启用

### 方式一：运行脚本

```powershell
cd F:\OpenClaw_Soul\workspace\skills\network-proxy
.\proxy-on.ps1
```

### 方式二：手动设置

```powershell
# 获取本地配置的端口
$config = Get-Content "$env:USERPROFILE\.openclaw\skills-config\network-proxy.json" | ConvertFrom-Json
$port = $config.port

# 设置代理
$env:HTTP_PROXY = "http://127.0.0.1:$port"
$env:HTTPS_PROXY = "http://127.0.0.1:$port"
```

## 代理端口

### 查看当前端口

```powershell
# 方式1：查看配置文件
Get-Content "$env:USERPROFILE\.openclaw\skills-config\network-proxy.json"

# 方式2：在 Clash Verge 中查看
# 打开 Clash Verge → 设置 → "本地 HTTP 代理端口"
```

### 修改端口

```powershell
# 重新运行初始化
.\init.ps1

# 或手动修改配置文件
notepad "$env:USERPROFILE\.openclaw\skills-config\network-proxy.json"
```

## 验证清单

| 验证项 | 命令 | 预期结果 |
|--------|------|---------|
| 代理开启 | `echo $env:HTTP_PROXY` | `http://127.0.0.1:端口号` |
| Google 访问 | `Invoke-WebRequest https://www.google.com` | StatusCode 200 |
| OpenAI 访问 | `Invoke-WebRequest https://auth.openai.com` | 能连接（Cloudflare 挑战页正常） |
| Codex OAuth | `openclaw models auth login --provider openai-codex` | 浏览器弹出 OAuth 页面 |

## 使用场景

| 场景 | 需要代理？ | 说明 |
|------|-----------|------|
| Codex OAuth 登录 | ✅ | `openclaw models auth login --provider openai-codex` |
| GitHub 操作 | ✅ | git push/pull |
| OpenAI API 调用 | ✅ | OpenClaw 模型请求 |
| 知乎/B站 访问 | ❌ | 国内站不需要 |
| npm/pip 包安装 | 看情况 | 部分国外包需要 |

## 故障排除

### 问题：代理生效后依然无法访问

**检查1：Clash Verge 是否开启系统代理**

Clash Verge 界面中确认：
- "系统代理"或"全局模式"已开启
- 或者至少"规则分流"模式

**检查2：端口是否正确**

```powershell
# 查看当前配置的端口
Get-Content "$env:USERPROFILE\.openclaw\skills-config\network-proxy.json"

# 验证端口是否在监听
netstat -ano | findstr "LISTENING" | findstr "端口号"
```

**检查3：重新初始化**

```powershell
.\init.ps1
```

### 问题：某些 CLI 工具不认代理

部分工具需要单独配置：
```powershell
# Git 代理
git config --global http.proxy "http://127.0.0.1:端口号"
git config --global https.proxy "http://127.0.0.1:端口号"

# npm 代理
npm config set proxy "http://127.0.0.1:端口号"
npm config set https-proxy "http://127.0.0.1:端口号"
```

### 问题：代理导致国内网站变慢

可以临时关闭代理：
```powershell
.\proxy-off.ps1
```

## 本地配置文件

配置保存在用户目录，不进入 git：

```
~\.openclaw\skills-config\network-proxy.json
```

文件格式：
```json
{
  "port": 7897,
  "airportUrl": "https://your-subscription-url",
  "updatedAt": "2026-04-05"
}
```

## 与 Browser Share 的关系

- **Browser Share**：解决"网站需要登录"的问题（ChatGPT 等）
- **Network Proxy**：解决"CLI 工具需要翻墙"的问题（Codex OAuth、GitHub 等）
- **两者互补**，可同时使用

## 扩展规划

- [ ] 支持多种代理软件（Clash Verge、Surge、Shadowrocket 等）
- [ ] 代理模式切换（全局/规则/直连）
- [ ] 按任务自动开关代理
- [ ] 自动检测代理端口（扫描 Clash Verge 进程）

## 相关技能

- `browser-share`：浏览器共享，复用网站登录态
- `opencli`：部分网站可通过 OpenCLI 免代理访问
