# Project format

Use one Markdown file per project under `F:\OpenClaw_Soul\workspace\projects\`.

## Recommended filename format

Use numeric prefixes to control order:

- `001.review-auto-task-runner.md`
- `002.fix-gateway-timeout.md`
- `003.design-mingyue-collab.md`

## Required frontmatter fields

```md
---
status: pending
created: 2026-04-08T19:30:00+08:00
started: null
completed: null
blocked_reason: null
---
```

### Allowed `status` values

- `pending`
- `running`
- `done`
- `blocked`

## Recommended body structure

```md
# 工程：项目名称

## 目标
说明这个项目想达成什么。

## 步骤
- [ ] 步骤一
- [ ] 步骤二
- [ ] 步骤三

## 备注
补充背景、链接、限制、想法。
```

## Notes

- Treat the whole file as one atomic project
- Use checkbox steps only as internal progress markers
- Keep freeform notes below the steps section when needed
- The runner should update frontmatter status, not rewrite the whole body unnecessarily
- The runner may store outputs in a safe ASCII directory even when the project filename contains Chinese or other non-ASCII characters
- The canonical mapping from task file to output folder is the `output_dir` value in frontmatter
