---
name: openai-codex-gateway
description: 在中国大陆环境下，通过本地代理 + OpenClaw Gateway 稳定使用 openai-codex/* 模型（Codex 订阅 / ChatGPT 账号）。
version: 0.1.0
changelog:
  - date: 2026-04-05
    version: 0.1.0
    changes:
      - 初始版本：提炼本地代理 + OpenClaw Gateway + openai-codex 连通性排查流程，面向中国大陆环境。
      - 拆分职责：通用 CLI 代理逻辑留在 network-proxy，本 skill 专注 Codex + Gateway。
      - 加入环境探测：先判断是否需要本 skill（大陆 vs 非大陆，直连 OpenAI/Google 与否）。
      - 记录节点选择经验：香港节点等可能导致能上网但仍无法稳定访问 OpenAI。
---

# OpenAI Codex Gateway Skill

## 背景 & 原理（先搞清楚在解决什么）

很多人会有这样的疑惑：

- “浏览器里（或系统里）我已经能上 Google / ChatGPT 了，为什么 OpenClaw 里 Codex 还是 `fetch failed`？”

关键在于：

- 浏览器流量走的是 **系统 / 浏览器自己的代理配置**；
- 但 OpenClaw 的这些东西：
  - `openclaw` CLI（在 PowerShell / 终端里跑的命令）
  - `openclaw gateway`（常驻的 Node 进程）
  默认 **不会自动继承你的 Clash / 系统代理设置**，而是尝试“直连外网”。

在中国大陆环境下，这就会导致：

- 浏览器：可以正常打开 Google / chatgpt.com
- CLI / Gateway：直连 `api.openai.com` / `chatgpt.com` 失败 → 出现 `network connection error` / `fetch failed`

因此：

- `network-proxy` skill：解决的是 **PowerShell / CLI 这条命令行链路怎么通过本地代理出口翻墙**；
- 本 `openai-codex-gateway` skill：在此基础上，专门保证 **OpenClaw Gateway 这条进程链也确实走代理**，
  让 `openai-codex/*` 不再因为“直连 chatgpt.com/backend-api 失败”而报 `fetch failed`。

在国外主机 / 能直连 OpenAI 的网络环境里，这两个 skill 通常都 **不是必须的**。

---

## 适用场景（何时触发这个 skill）

当同时满足下面 **至少 2 条** 时，启用本 skill：

- 你在 `openclaw.json` 里配置了 `openai-codex/*` 模型
- 切换到 Codex 模型后，TUI / WebChat 里出现：
  - `LLM request failed: network connection error. rawError=fetch failed`
  - 或一切换 Codex 就明显“断线”、自动回落到其他模型
- 你在中国大陆，通过 Clash / 代理软件才能访问 OpenAI / ChatGPT

> 本 skill 只解决：**OpenClaw → Gateway → Codex（chatgpt.com/backend-api）这条链路的连通性问题**。
> 它假设你已经有一个可用的本地 HTTP 代理端口（例如 7897）。

---

## 环境探测（大陆 vs 非大陆）

在真正执行后面的“代理 + gateway”步骤前，先判断当前环境是否**真的需要**这套增强逻辑。

在一个**未设置 HTTP_PROXY/HTTPS_PROXY 的 PowerShell 会话**中，尝试直连：

```powershell
# 确保当前会话没有显式设置 HTTP_PROXY / HTTPS_PROXY
Remove-Item Env:HTTP_PROXY  -ErrorAction SilentlyContinue
Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue

Invoke-WebRequest -Uri "https://www.google.com"    -Method Head -TimeoutSec 8
Invoke-WebRequest -Uri "https://api.openai.com"    -Method Head -TimeoutSec 8
```

根据结果分流：

- **如果两个请求都能正常返回（200 / 3xx）：**
  - 当前环境可以直连外网，本 skill 一般**不需要使用**；
  - 建议直接按 OpenClaw 官方的 OpenAI / Codex 文档配置即可。
- **如果任意一个请求超时 / DNS 失败 / 无法建立连接：**
  - 当前更接近“中国大陆网络环境”，适合继续使用本 skill；

> 提醒：有些环境可能“偶尔能连上 OpenAI”，但质量不稳定。
> 如果你已经遇到过 Codex 偶发性 `fetch failed`，也可以直接按本 skill 继续往下做。

---

## 前提假设（已有基础）

1. **本地代理软件已正常运行**
   - 例如：Clash Verge / Clash for Windows 等
   - 已在浏览器中验证：可以访问 Google、GitHub、OpenAI 等
   - 如果你在中国大陆：
     - 建议优先选择日本、新加坡、美国等“对 OpenAI 友好的节点”；
     - 某些香港节点（或被 OpenAI/Cloudflare 标记的节点）可能导致：
       - 直连其他网站没问题，但访问 `api.openai.com` / `chatgpt.com` 依然失败或经常超时；
       - 出现偶发 `fetch failed` / 连接重置等问题。
     - 遇到这种情况时，先在 Clash 中**换一个已知可以稳定使用 OpenAI 的节点**，再继续本 skill。

2. **本地 HTTP 代理端口已知**
   - 例如：`http://127.0.0.1:7897`
   - 可以通过 `network-proxy` skill 初始化/记录端口，也可以你自己记在别处

3. **OpenClaw 已完成 Codex OAuth 登录**
   - `openclaw onboard --auth-choice openai-codex`
   - 或 `openclaw models auth login --provider openai-codex`
   - 在 `openclaw.json` 中能看到类似：

     ```json5
     {
       "auth": {
         "profiles": {
           "openai-codex:your-email@example.com": {
             "provider": "openai-codex",
             "mode": "oauth"
           }
         }
       }
     }
     ```

4. **你已经为 Codex 配置了至少一个模型**

   最小必要配置示例（精简版）：

   ```json5
   {
     "agents": {
       "defaults": {
         "model": {
           "primary": "openai-codex/gpt-5.1"
         }
       }
     }
   }
   ```

   > 本 skill 不关心 fallbacks 顺序、其他 provider 的偏好，只关注：
   > **当 primary 使用 `openai-codex/*` 时，不要再因为网络/代理问题直接失败。**

---

## 核心目标

> 在中国大陆环境下，让 `openclaw gateway` **始终带着正确的 HTTP 代理环境** 启动，
> 使得 `openai-codex/*` 模型不会因为“直连 chatgpt.com/backend-api 失败”而报 `fetch failed`。

换一句话说：

- 不再出现：`provider: openai-codex` + `network connection error` + `rawErrorPreview: "fetch failed"`
- 如果有错误，也应该是 Codex 账户/额度/权限层面的 HTTP 状态码（401/403/429 等），而不是连不上。

---

## 步骤一：确认代理端口可用（一次性或偶尔重查）

> 如果你已经用 `network-proxy` 验证过代理通畅，可以跳过本节。

在任意 PowerShell 会话中，简单验证代理端口是否工作（以 7897 为例）：

```powershell
$proxy = "http://127.0.0.1:7897"

# 测试 Google
Invoke-WebRequest -Proxy $proxy -ProxyUseDefaultCredentials `
  -Uri "https://www.google.com" -Method Head -TimeoutSec 10

# 测试 GitHub
Invoke-WebRequest -Proxy $proxy -ProxyUseDefaultCredentials `
  -Uri "https://github.com" -Method Head -TimeoutSec 10
```

预期：返回 `StatusCode` 200 或 3xx 重定向；如果是 DNS/超时等网络异常，先回到代理软件排查。

---

## 步骤二：正确启动 Gateway（**关键！**）

**强约定：为 gateway 单独保留一个 PowerShell 标签页 / 窗口。**

在这个专用标签页里，按顺序执行：

```powershell
$env:HTTP_PROXY  = "http://127.0.0.1:7897"
$env:HTTPS_PROXY = "http://127.0.0.1:7897"

openclaw gateway
```

说明：

- 只在 **gateway 所在的 PowerShell 进程** 里设置环境变量，
  这样通过该进程启动的 `node openclaw.mjs gateway` 及其子进程都会继承代理设置。
- `openclaw gateway` 启动后，终端会“卡住”在前台滚日志——这表示 gateway 正在运行，这是预期行为。
- 不要依赖 Windows 计划任务中可能指向的旧 `gateway.cmd`，那容易和手动启动的 gateway 冲突或配置不一致。

---

## 步骤三：在其他终端中使用 Codex 模型

保持 gateway 标签页前台运行，新开一个 PowerShell / TUI 窗口进行日常使用：

1. 启动 OpenClaw TUI 或连接到 WebChat / 其它渠道
2. 在当前会话中选择 Codex 模型，例如：
   - `openai-codex/gpt-5.1`
   - 或你配置的任意 `openai-codex/*` 模型
3. 正常对话，观察是否还会出现之前的 `network connection error / fetch failed`。

---

## 故障排查（只覆盖本 skill 关心的两类）

### 情况 A：切到 Codex 就 `network connection error / fetch failed`

典型日志示例：

```text
provider: openai-codex
error: LLM request failed: network connection error.
rawErrorPreview: "fetch failed"
```

排查顺序：

1. **确认 gateway 仍在运行**

   在任意 PowerShell 中执行：

   ```powershell
   openclaw gateway status
   ```

   - 如果 `RPC probe: ok` 且有 `Listening: 0.0.0.0:18789` → gateway 正在运行
   - 如果 gateway 没跑，回到“步骤二”重新按模板启动

2. **重启 gateway 并确保在其标签页设置代理 env**

   在 gateway 专用标签页：

   ```powershell
   # 停掉当前 gateway（如果在前台）
   Ctrl+C

   # 重新设置代理环境变量
   $env:HTTP_PROXY  = "http://127.0.0.1:7897"
   $env:HTTPS_PROXY = "http://127.0.0.1:7897"

   # 再次前台启动 gateway
   openclaw gateway
   ```

   > 关键点：不要指望“在别的标签页里设 env”能影响这个已运行的 gateway 进程，
   > 环境变量只在 **当前进程及其子进程** 中有效。

3. **仍然 `fetch failed`？考虑代理本身是否异常**

   - 回到“步骤一”，用 `Invoke-WebRequest -Proxy ...` 再测一次 Google / GitHub
   - 如果连这些都不通，先修复代理或网络，再看 Codex

---

### 情况 B：Codex 返回 HTTP 错误（401 / 403 / 429 等）

如果错误形态变成标准 HTTP 状态码，例如：

- `401`：未授权 / OAuth 过期
- `403`：权限不足 / 地区限制 / 风控
- `429`：请求过多 / 额度用尽

那么：

- 说明：**OpenClaw → Gateway → Codex 的网络链路已经打通**（不再是 `fetch failed`）
- 这时本 skill 的职责范围已经结束，应该转向：
  - 检查 Codex 订阅 / ChatGPT 账号状态
  - 检查该模型是否对当前账户开放
  - 或参考 OpenClaw 文档中对 openai-codex provider 的额度和限制说明

---

## 日常自检 Checklist（给未来的你用）

当你怀疑“Codex 又不通了”时，可以快速跑一轮：

1. **gateway 状态**

   ```powershell
   openclaw gateway status
   ```

   - 预期：`RPC probe: ok`，且有 `Listening: 0.0.0.0:18789`

2. **确认 gateway 是在带 proxy 的标签页重启的**

   在 gateway 标签页回忆这三步是否都做了：

   ```powershell
   $env:HTTP_PROXY  = "http://127.0.0.1:7897"
   $env:HTTPS_PROXY = "http://127.0.0.1:7897"
   openclaw gateway
   ```

3. **看错误形态**

   - 如果是 `network connection error / fetch failed` → 回到本 skill 的“情况 A”排查
   - 如果是 `401/403/429` → 交给 Codex 账号/额度层面的处理

---

## 与 `network-proxy` 的关系（简要说明）

- `network-proxy`：
  - 负责 **通用的 CLI 代理配置**（设置 & 验证 HTTP(S) 代理端口）
  - 适用于 GitHub、OpenAI API、Google 等各种 CLI 场景

- 本 `openai-codex-gateway` skill：
  - 站在“代理已可用”的前提上，专门确保：
    - `openclaw gateway` 正确继承代理环境
    - `openai-codex/*` 模型不再因为网络/代理配置问题而 `fetch failed`

你可以理解为：

> `network-proxy` 打通的是 **“这台机器 → 代理出口”**；
>
> `openai-codex-gateway` 补的是 **“OpenClaw Gateway 这条进程链也确实走这条出口”**。