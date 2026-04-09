# Output Layout

Use this reference when writing files for a ChatGPT multi-turn session.

## Required folder layout

Always create one dedicated folder per task:

```text
workspace\archive\chatgpt-multi-turn\YYYY-MM-DD\<topic>\
```

Example:

```text
F:\OpenClaw_Soul\workspace\archive\chatgpt-multi-turn\2026-04-06\OpenClaw游戏策划应用\
```

## Required files

At minimum, write:

```text
00-对话目录.md
01-第1轮-完整回复.md
02-第2轮-完整回复.md
03-第3轮-完整回复.md
```

If there are more rounds, continue numbering.

## File roles

### `00-对话目录.md`

This is the compact guide file.

Include:
- topic
- date/time
- round count
- per-round question
- per-round short summary
- final conclusions / next actions
- links or filenames for each full-reply file

### `0N-第N轮-完整回复.md`

This is the full-content file for that round.

Keep as much original structure as possible:
- headings
- bullet lists
- numbered steps
- quoted prompts
- code blocks
- concluding remarks

Do not intentionally summarize this file.

If a section is partially missing, mark it clearly:

```markdown
> 注：以下第 3 小节可能有截断，已按当前可提取内容保留。
```

## Naming guidance

Use short, stable topic folder names in Chinese when possible.

Prefer:
- `OpenClaw游戏策划应用`
- `技术方案讨论`
- `SLG策划Prompt研究`

Avoid:
- `new-folder`
- `chatgpt`
- bare timestamps only

## Optional files

Only add these when needed:

```text
assets\
notes.md
```

Use `assets\` for screenshots if the raw capture itself is worth preserving.

## Rule

One task → one folder.
Do not mix unrelated conversations in the same folder.
