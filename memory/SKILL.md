---
name: memory
description: 记忆管理与 session 提炼。当需要总结对话、记录重要信息、更新长期记忆时激活此技能。
---

# Memory - 记忆管理与提炼

## 核心理念

记忆是 AI 的灵魂。Session 结束后提炼精华，长期记忆分层管理，不让有价值的信息丢失。

## 记忆分层

| 层级 | 文件 | 内容 | 更新频率 |
|------|------|------|---------|
| 长期 | `MEMORY.md` | 高价值、可操作、通用模式 | 发现时更新 |
| 短期 | `memory/YYYY-MM-DD.md` | 当日精华、关键决策、教训 | 每次 session 结束 |
| 实时 | AGENTS.md 已含 | SOUL.md + USER.md + memory | 每次 session 开始 |

## 提炼原则（HEAT 法则）

```
H - Highlight（高亮）
   → 只选有价值的：关键决策、教训、模式、约定

E - Extract（提取）
   → 从对话中提取结论，不抄过程

A - Abstract（抽象）
   → 通用模式写入 MEMORY，具体事件写入当日 memory

T - Trim（精简）
   → MEMORY.md < 1KB/次，memory/日 < 800 bytes
```

## 提炼时机

| 时机 | 动作 |
|------|------|
| Session 结束前 | 评估是否值得提炼 |
| 新 session 开始 | 读 memory/今日+昨日 |
| 发现通用模式 | 更新 MEMORY.md |

## 每次提炼检查

1. **有关键决策吗？** → 记录结论
2. **有教训吗？** → 记入当日 memory
3. **有通用模式吗？** → 提炼到 MEMORY.md
4. **天均的偏好/风格有更新吗？** → 更新 USER.md/SOUL.md

## 精简标准

✅ 要记：
- 决策结论（"用 9222 不用 18800"）
- 教训（"调试模式 Chrome 需登录一次才能复用"）
- 模式（"排查顺序：端口→进程→配置→文档"）
- 偏好（"天均喜欢直接说重点"）

❌ 不记：
- 过程描述
- 命令输出
- 文档抄录
- 占位/待办（除非有明确 deadline）

## 编码规范

- 写入 memory 用 `write` 工具**覆盖全文**，不用 append
- 全程 UTF-8 编码
- 中文优先，不用表情符号（节省空间）

## 文件路径

```
F:\OpenClaw_Soul\workspace\
├── MEMORY.md              # 长期记忆
└── memory\
    └── YYYY-MM-DD.md     # 当日 memory
```

## Session 结束模板

```markdown
# YYYY-MM-DD

## 完成
- [任务1]：[结果/状态]
- [任务2]：[结果/状态]

## 关键决策
1. [决策点] → [结论]
2. ...

## 教训
- [教训1]
- [教训2]
```

## 相关技能

- 此技能是所有 skill 的基础，不依赖其他技能
