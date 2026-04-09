# Skills 索引

当前主工作目录：`F:\OpenClaw_Soul\workspace\skills`

> 说明：这里是**本地实际使用中的 skills 工作目录**，不再以旧的 `openclaw-skills` 目录为主。

---

## 当前保留的 skills

### auto-task-runner
Markdown 任务队列 / 协作式任务 runner。

**功能：**
- 把 `workspace/projects/*.md` 当作任务队列
- 自动认领 `new/pending` 任务并写入 frontmatter
- 维护 `running / done / blocked` 状态
- 管理每个任务的输出目录
- 提供 `resume-current`、`recover-stale` 等恢复能力

**适用场景：**
- 想用 Markdown 文件管理一批连续任务
- 想让 heartbeat 或当前 agent 接力推进任务
- 想给每个任务保留独立输出目录

**位置：** `skills/auto-task-runner/`

---

### browser-setup
OpenClaw 浏览器工具配置与排障指南。

**功能：**
- 配置 OpenClaw 管理的浏览器
- 启用 browser plugin / profile / CDP 端口
- 处理浏览器启动失败、连接失败、截图/快照失败等问题

**适用场景：**
- 初次启用 OpenClaw 浏览器能力
- 浏览器自动化前的环境配置
- 浏览器故障排查

**位置：** `skills/browser-setup/`

---

### browser-share
复用用户已有 Chrome 登录态的浏览器共享 skill。

**功能：**
- 通过 CDP（如 9222）接管 Chrome
- 复用已登录网站的账号状态
- 让 AI 直接操作 ChatGPT、知乎、B站等站点

**适用场景：**
- 已登录 ChatGPT / 知乎 / B站 等网站
- 不想在自动化浏览器里重新登录
- 希望让 AI 直接复用现有 Chrome 会话

**位置：** `skills/browser-share/`

---

### chatgpt-multi-turn
ChatGPT 网页版多轮对话归档研究 skill。

**功能：**
- 在 ChatGPT Web 中逐轮提问
- 每轮等待完成后复制回复并写入 Markdown
- 保存完整对话记录、轮次文件和最终研究结论
- 适合研究、策划、方案比较等多轮任务

**适用场景：**
- 2 轮及以上的 ChatGPT Web 研究任务
- 需要完整归档每一轮问题与回答
- 想把 ChatGPT 讨论沉淀为结构化文档

**位置：** `skills/chatgpt-multi-turn/`

---

### memory
记忆管理与 session 提炼 skill。

**功能：**
- 规范更新 `MEMORY.md` 与 `memory/YYYY-MM-DD.md`
- 使用 HEAT 法则提炼长期/短期记忆
- 帮助 session 结束时做高价值总结

**适用场景：**
- 需要记录关键决策、经验教训、用户偏好
- session 结束前整理记忆
- 维护长期连续性

**位置：** `skills/memory/`

---

### network-proxy
让 PowerShell / CLI 走本地代理翻墙的 skill。

**功能：**
- 配置 `HTTP_PROXY` / `HTTPS_PROXY`
- 让 GitHub、OpenAI、Codex OAuth 等 CLI 请求走本地代理
- 提供本地代理端口初始化与验证方法

**适用场景：**
- 中国大陆环境下访问国外服务
- PowerShell 中执行 Git / OpenAI / OAuth 相关命令
- CLI 明明报网络错误，但浏览器可访问外网

**位置：** `skills/network-proxy/`

---

### openai-codex-gateway
面向中国大陆环境的 OpenClaw Gateway + OpenAI Codex 连通性修复 skill。

**功能：**
- 专门处理 `openclaw gateway` 如何继承代理环境
- 解决 `openai-codex/*` 模型的 `fetch failed` / `network connection error`
- 区分“网络问题”与“401/403/429 账号权限问题”

**适用场景：**
- Gateway 能启动，但 Codex 模型请求失败
- 浏览器能上 ChatGPT，但 OpenClaw 中 Codex 不通
- 需要在大陆网络环境下稳定使用 `openai-codex/*`

**位置：** `skills/openai-codex-gateway/`

---

### skill-publisher
本地 skills 与 GitHub 仓库同步管理 skill。

**功能：**
- 管理 `gitPath` / `skillsPath`
- 配置 PAT、代理和同步路径
- pull / push skills 仓库
- 处理同步冲突与定时同步策略

**适用场景：**
- 发布或同步 skills 仓库
- 切换本地工作目录与 git 仓库路径
- 让不同 AI / 不同机器共享技能

**位置：** `skills/skill-publisher/`

---

## 已清理 / 不再保留在当前工作目录

以下内容已从当前 `workspace/skills` 清理，不属于当前活跃 skills：

- `opencli` — 已移出当前工作目录
- `dist` — 打包产物目录，已移出当前工作目录
- `gateway-monitor` — 不在当前工作目录中
- `sonoscli` — 不在当前工作目录中

---

## 建议理解方式

### 核心工作流技能
- `auto-task-runner`
- `browser-share`
- `chatgpt-multi-turn`
- `memory`

### 基础设施 / 连接性技能
- `browser-setup`
- `network-proxy`
- `openai-codex-gateway`

### 仓库维护技能
- `skill-publisher`

---

## 更新记录

### v2.0.0 (2026-04-09)
- 将索引切换为 `workspace/skills` 当前实际内容
- 移除对 `opencli` / `sonoscli` / `gateway-monitor` / `dist` 的过期主索引描述
- 新增 `auto-task-runner`、`browser-share`、`chatgpt-multi-turn`、`memory`、`network-proxy`、`openai-codex-gateway` 的说明
- 明确当前目录是本地实际工作目录

### v1.1.0 (2026-04-04)
- 新增 `skill-publisher`

### v1.0.0 (2026-04-04)
- 初始版本
