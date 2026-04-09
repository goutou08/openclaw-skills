# Skills 索引

## 工具类

### opencli
通用 CLI 工具，通过浏览器桥接控制已登录的 Chrome 会话。

**功能：**
- 支持 70+ 网站的 CLI 操作（知乎、B站、微博、小红书等）
- 浏览器自动化（点击、输入、截图）
- 内容下载（文章、视频、图片）
- 外部 CLI 工具调用（gh, docker, lark-cli）

**安装前提：**
- Chrome 浏览器
- 安装 Browser Bridge 扩展
- Node.js >= 20

**安装：**
```bash
npm install -g @jackwener/opencli
```

**使用：**
```bash
opencli doctor  # 检查连接
opencli zhihu hot --limit 10  # 知乎热榜
opencli bilibili hot --limit 5  # B站热榜
opencli list  # 查看所有命令
```

**位置：** `skills/opencli/`

---

### browser-setup
OpenClaw 浏览器工具配置与使用指南。

**功能：**
- 配置 OpenClaw 管理的浏览器
- 网页自动化、数据抓取、测试

**使用场景：**
- 需要浏览器交互的任务
- 网页截图、内容提取
- 自动化测试

**位置：** `skills/browser-setup/`

---

## 系统监控类

### gateway-monitor
OpenClaw 网关健康监控与故障恢复。

**功能：**
- 网关服务状态检测
- WebUI 访问诊断
- 渠道连接中断修复
- 定期健康检查

**使用场景：**
- 网关服务停止
- WebUI 无法访问
- 渠道连接中断

**位置：** `skills/gateway-monitor/`

---

## 智能家居类

### sonoscli
Sonos 音响控制 CLI 工具。

**功能：**
- 音响发现
- 播放状态控制
- 音量调节
- 分组管理

**使用：**
```bash
opencli sonos discover  # 发现音响
opencli sonos status     # 播放状态
opencli sonos volume 50 # 音量调节
```

**位置：** `skills/sonoscli/`

---

## 仓库管理类

### skill-publisher
将 OpenClaw skills 发布到共享 GitHub 仓库的完整流程指南。

**功能：**
- 创建新的 skills 仓库
- 发布 skill 到共享仓库
- Git/GitHub 常用操作
- Token 管理最佳实践

**使用场景：**
- 首次创建 skills 共享仓库
- 发布新开发的 skill
- 多 AI 助手协作时同步 skills

**位置：** `skills/skill-publisher/`

---

## 更新日志

### v1.1.0 (2026-04-04)
- 新增 skill-publisher：skills 仓库发布指南

### v1.0.0 (2026-04-04)
- 初始版本
- 包含 opencli、browser-setup、gateway-monitor、sonoscli 四个 skills
