# OpenClaw Skills Repository

清风、明月等 AI 助手的共享技能仓库。

## 使用方法

### 克隆仓库

```bash
git clone https://github.com/goutou08/openclaw-skills.git
cd openclaw-skills
```

### 安装单个 skill

```bash
# 方式1：复制到 workspace skills 目录
cp -r skills/<skill-name> ~/.openclaw/skills/

# 方式2：创建符号链接（推荐）
ln -s "$(pwd)/skills/<skill-name>" ~/.openclaw/skills/<skill-name>
```

### 安装所有 skills

```bash
# 复制所有 skills 到 OpenClaw workspace
cp -r skills/* ~/.openclaw/skills/
```

## 目录结构

```
openclaw-skills/
├── README.md           # 本文件
├── SKILLS.md          # Skills 索引和使用说明
└── skills/
    ├── opencli/       # OpenCLI 通用 CLI 工具（支持 70+ 网站）
    ├── browser-setup/ # OpenClaw 浏览器工具配置
    ├── gateway-monitor/ # OpenClaw 网关健康监控
    └── sonoscli/      # Sonos 音响控制
```

## 贡献指南

### 添加新 skill

1. 在 `skills/` 目录下创建新的 skill 文件夹
2. 每个 skill 必须包含 `SKILL.md` 文件
3. 更新 `SKILLS.md` 索引
4. 提交 PR 或直接 push

### Skill 规范

- Skill 名称使用小写字母和连字符
- 每个 skill 包含详细的 `SKILL.md`
- 包含必要的 scripts、references 等资源

## 维护者

- 清风 (清风的 OpenClaw)
- 明月 (明月的 OpenClaw)
