# OpenClaw Skills Repository

这是当前主工作目录下的本地 skills 仓库：

- **路径**：`F:\OpenClaw_Soul\workspace\skills`
- **用途**：存放清风当前实际使用、维护、发布的 OpenClaw skills
- **同步方式**：由 `skill-publisher` 负责与 GitHub 仓库 `goutou08/openclaw-skills` 同步

> 说明：当前仓库已经直接以 `workspace/skills` 作为 git 工作目录，不再使用旧的 `openclaw-skills/skills/` 子目录结构。

---

## 当前包含的 skills

- `auto-task-runner` — Markdown 任务队列 / 协作式任务 runner
- `browser-setup` — OpenClaw 浏览器配置与排障
- `browser-share` — 复用用户已有 Chrome 登录态
- `chatgpt-multi-turn` — ChatGPT Web 多轮对话归档研究
- `memory` — 记忆管理与 session 提炼
- `network-proxy` — PowerShell / CLI 代理配置
- `openai-codex-gateway` — 大陆网络环境下的 Codex + Gateway 连通性修复
- `skill-publisher` — skills 仓库同步与发布

详细索引见：`SKILLS.md`

---

## 仓库结构

```text
workspace/skills/
├── README.md
├── SKILLS.md
├── auto-task-runner/
├── browser-setup/
├── browser-share/
├── chatgpt-multi-turn/
├── memory/
├── network-proxy/
├── openai-codex-gateway/
└── skill-publisher/
```

---

## 使用方式

### 作为本地工作目录使用

当前目录本身就是 OpenClaw 的本地 skills 工作目录，可直接在这里：

- 新建 skill
- 编辑 skill
- 测试 skill
- git 提交 / push

### 同步到 GitHub

使用 `skill-publisher` 所描述的同步流程：

- `gitPath = F:\OpenClaw_Soul\workspace\skills`
- `skillsPath = F:\OpenClaw_Soul\workspace\skills`

也就是：

> 这里既是本地技能目录，也是 git 仓库目录。

---

## 维护约定

### 添加新 skill

1. 在仓库根目录下创建一个新文件夹
2. 每个 skill 至少包含 `SKILL.md`
3. 如有需要，可加入：
   - `scripts/`
   - `references/`
   - `assets/`
4. 更新 `SKILLS.md`
5. 提交并 push

### Skill 规范

- 目录名使用小写字母和连字符
- 每个 skill 必须有 `SKILL.md`
- 优先保持目录简洁，避免无用文档堆积
- 敏感配置不要写进共享文件

---

## 已移出当前工作目录的内容

以下内容不再保留在当前仓库主目录中：

- `opencli`
- `dist`
- `gateway-monitor`
- `sonoscli`

如果需要，可从历史提交或备份目录恢复。

---

## 维护者

- 清风
- 明月（协作方 / 共享方）
