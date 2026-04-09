---
name: browser-share
description: 控制用户已有的 Chrome 浏览器，复用已登录状态（Browser Sharing）。当需要操作已登录的网站（ChatGPT、知乎、B站等）时激活此技能。
---

# Browser Share - 复用已有 Chrome 的浏览器控制

## 概念

Browser Share 让 OpenClaw 通过 Chrome 的调试端口（DevTools Protocol）控制 Chrome 浏览器实例，复用其中的登录态。

**核心价值：** 登录一次网站后，后续 AI 即可直接操作，无需重复登录。

## 工作原理

```
Chrome（调试模式）←──CDP 协议──→ OpenClaw（任意端口）
     ↑
     │
  只需要登录一次
```

**关键前提：** Chrome 必须以调试模式打开（开启 CDP 接口）。无论用哪个端口，原理都一样。

## 两种使用方式（等价）

| 方式 | 端口 | Chrome 谁启动 | 如何获得登录态 |
|------|------|-------------|---------------|
| **方式A** OpenClaw 隔离浏览器 | 18800（默认） | OpenClaw 启动全新 Chrome | 用户在浏览器中手动登录一次 |
| **方式B** Browser Share | 9222（Chrome 调试标准端口） | 用户手动打开 | 用户在浏览器中手动登录一次 |

两种方式**完全等价**，区别仅在于：
- **18800**：OpenClaw 自己的隔离浏览器，适合敏感操作
- **9222**：用户已有的 Chrome，适合复用已登录的账号

**核心逻辑：** 登录态存在浏览器里，不是端口决定的。无论哪个端口，只要在调试模式 Chrome 里登录一次，之后就能用。

## 两个 Chrome 完全独立

```
┌─────────────────────────────┐
│  你自己用的 Chrome           │  ← 正常模式，不开调试端口
│  正常浏览，互不影响          │
└─────────────────────────────┘

┌─────────────────────────────┐
│  OpenClaw 控制的 Chrome      │  ← 调试模式（18800 或 9222）
│  登录态只在这里用            │
└─────────────────────────────┘
```

两者是独立进程，各干各的事，不冲突。

## 前提条件

1. Chrome 浏览器（Google Chrome）
2. OpenClaw 已安装并运行
3. Chrome 需要以调试模式打开

## 配置步骤

### 方式A：使用 18800（OpenClaw 隔离浏览器，默认）

```bash
# 1. 启动 OpenClaw 的隔离 Chrome
openclaw browser start

# 2. 验证连接
openclaw browser tabs

# 3. 打开目标网站
openclaw browser open https://chatgpt.com

# 4. 在打开的浏览器中手动登录（只需一次）
# 5. 之后 AI 即可控制该浏览器
```

### 方式B：使用 9222（复用用户已有的 Chrome）

**Step 1: 打开调试模式的 Chrome**

彻底关闭所有 Chrome，然后命令行：

```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

**Step 2: 配置 OpenClaw 连接 9222**

```bash
openclaw config set browser.profiles.openclaw.cdpPort 9222
openclaw gateway restart
```

**Step 3: 验证连接**

```bash
openclaw browser status
openclaw browser tabs
```

**Step 4: 在 Chrome 中登录目标网站（只需一次）**

**Step 5: 之后 AI 即可控制**

### 方式B 进阶：永久化调试端口

不想每次手动输命令？改快捷方式：

1. 右键 Chrome 快捷方式 → **属性**
2. 在"目标"字段最后加上：`--remote-debugging-port=9222`
3. 确定

以后正常打开 Chrome 即是调试模式。

## OpenClaw 配置参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `browser.profiles.openclaw.cdpPort` | 9222 或 18800 | 调试端口，9222=Chrome 标准，18800=OpenClaw 默认 |
| `browser.defaultProfile` | openclaw | 配置文件名 |
| `browser.headless` | false | false=显示界面 |

## 常用命令

```bash
# 检查状态
openclaw browser status

# 查看标签页
openclaw browser tabs

# 打开网页
openclaw browser open https://chatgpt.com

# 获取页面快照（交互模式）
openclaw browser snapshot --interactive

# 点击元素
openclaw browser click <ref>

# 输入文本
openclaw browser type <ref> "文本内容"

# 按键
openclaw browser press Enter

# 截图
openclaw browser screenshot

# 关闭浏览器
openclaw browser stop
```

## 支持的网站

| 网站 | 状态 | 备注 |
|------|------|------|
| ChatGPT (chatgpt.com) | ✅ 已验证 | Plus 账号正常 |
| 知乎 (zhihu.com) | ✅ | |
| B站 (bilibili.com) | ✅ | |
| 微博 (weibo.com) | 待测试 | |
| YouTube | 待测试 | |

## 限制与注意事项

1. **两种方式完全等价**
   - 都能手动登录获得登录态
   - 都能被 AI 控制
   - 选择哪个取决于是否需要复用用户已有的 Chrome

2. **调试模式是独立实例**
   - 调试模式 Chrome 和普通模式 Chrome 是分开的
   - 需要在调试模式 Chrome 中登录网站

3. **端口占用**
   - 如果端口被占用，连接会失败
   - 解决方案：关闭所有 chrome.exe 进程后重试

4. **安全性**
   - 调试端口仅监听本地 127.0.0.1，外部无法访问
   - 不要在公共网络中暴露端口

## 故障排除

### 问题：连接失败

```bash
# 检查端口是否有监听
netstat -ano | findstr ":9222"

# 检查 Chrome 进程
tasklist | findstr "chrome"
```

### 问题：打开了浏览器但显示未登录

- 确认是在**调试模式**的 Chrome 中登录的
- 普通模式 Chrome 的登录态不会共享到调试模式

## 扩展规划

- [ ] 支持 Edge/Brave 等 Chromium 系浏览器
- [ ] cookies/profiles 一键导入导出
- [ ] 多账号快速切换
- [ ] 自动化脚本录制与回放

## 相关技能

- `browser-setup`：OpenClaw 浏览器工具的基础配置与排障
- `opencli`：OpenCLI 通用命令行工具，支持部分网站的免登录访问
