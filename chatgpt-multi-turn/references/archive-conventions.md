# Archive Conventions

Use this reference when saving ChatGPT multi-turn outputs.

## Required root

Always archive under:

```text
workspace\archive\chatgpt-multi-turn\YYYY-MM-DD\<topic>\
```

## Required file set

Prefer this structure inside the task folder:

```text
00-对话目录.md
01-第1轮-完整回复.md
02-第2轮-完整回复.md
03-第3轮-完整回复.md
```

Examples of topic folders:

- `OpenClaw游戏策划应用`
- `SLG策划Prompt研究`
- `技术方案讨论`

## Topic naming guidance

Use short, human-readable Chinese titles.

Prefer:

- task topic
- domain + purpose
- project name + discussion type

Avoid:

- `new-file.md`
- `chatgpt-output.md`
- vague timestamps as the only title

## Markdown frontmatter substitute

At the top of each archive file, include:

```markdown
# <对话主题>

> 对话时间：YYYY-MM-DD HH:mm
> 对话平台：ChatGPT (OpenClaw Browser Tool)
> 对话轮数：N轮
```

## Minimum sections

The task folder should contain:

1. One compact index file (`00-对话目录.md`)
2. One full-content Markdown file per round
3. Final summary in the index file
4. Optional next actions in the index file

## Do not

- Do not save these files in workspace root
- Do not mix multiple unrelated conversations into one task folder
- Do not replace the per-round full files with summaries only
- Do not dump noisy OCR into the index file if a cleaner summary is possible
