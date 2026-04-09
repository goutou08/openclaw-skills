---
name: chatgpt-multi-turn
description: Run structured multi-turn conversations in the ChatGPT web app via OpenClaw browser tools, one round at a time. Use when the user wants ChatGPT Web queried across 2+ rounds, wants each round archived as Markdown, wants later questions designed from earlier answers, or wants a saved conversation record. Prefer browser-share/browser-setup for browser access, copy each completed reply via ChatGPT Web's `复制回复` button, then save the question and reply together before designing the next round.
---

# ChatGPT Multi-Turn

Use this skill to run repeatable, archived, multi-round conversations in ChatGPT Web.

Keep the workflow deterministic: ask one question, wait for completion, capture the latest reply, write that round's Markdown file, then design the next question.

## Core workflow

1. Open ChatGPT in the managed/shared browser.
2. Identify the current input box from a fresh page snapshot.
3. Ask exactly one question.
4. Wait until the answer finishes streaming.
5. Capture the latest answer with `复制回复` as the primary method.
6. Immediately write one per-round Markdown file containing both:
   - the exact question sent in that round
   - the copied ChatGPT reply
7. Only after that file is saved, design the next question.
8. Repeat until the requested number of rounds is complete.
9. Write or update the compact index file.
10. After all rounds are complete, write one final concise research/conclusion file that distills the conversation into a short reusable output.

Do not design or send the next round before the current round file is safely written.

## Required operating rule

Treat each round as an atomic unit:

```text
ask -> wait -> copy reply -> validate clipboard -> write round md -> design next question
```

This is the default behavior, not an optional optimization.

## Browser dependency rule

Treat browser availability as a required preflight step, not as an implicit assumption.

Preferred order:

1. Detect whether a usable ChatGPT Web browser environment already exists in the current runtime.
2. If not, try `browser-share` first when the user's normal Chrome session may already be logged in.
3. If shared-browser reuse is unavailable or unsuitable, try `browser-setup` to create a managed automation browser.
4. Only stop, block, or ask the user when neither path can establish a usable browser environment.

Prefer these browser skills and environments:

- `browser-share` first when ChatGPT is already logged in in the user's Chrome
- `browser-setup` when a managed automation browser is needed

This skill does not own login setup, but it does own the responsibility to check whether browser access is already available and to route into the appropriate browser skill when the environment is missing.

Do not immediately fail just because the current task context does not already expose a ready browser session. First try to establish one through the browser skills above. Only if those skills or capabilities are unavailable in the current runtime should the run be paused or marked blocked.

If ChatGPT is not logged in after browser setup/share is attempted, pause and ask for the appropriate browser/login intervention instead of improvising.

## Response style rule for prompts

Default to concise outputs.

When designing each question, explicitly ask ChatGPT to answer briefly, clearly, and with low fluff. Prefer prompts that request:

- short paragraphs or bullet points
- only the essential reasoning
- concrete recommendations over long exposition

Example suffixes to add when useful:

- `请尽量简洁，直接给结论和关键依据。`
- `避免长篇大论，控制在 5-8 个要点内。`
- `先给结论，再给最必要的解释。`

Do not over-compress if the user explicitly wants depth, full analysis, or long-form writing. In that case, follow the user's request.

## Recommended round count

- Default: 3 rounds
- Use the user's requested round count when provided
- If the topic naturally ends early, stop and summarize instead of forcing another weak question

## Archive path rule

Always save output under:

```text
workspace\archive\chatgpt-multi-turn\YYYY-MM-DD\<topic>\
```

Minimum output set:

```text
00-对话目录.md
01-第1轮-完整回复.md
02-第2轮-完整回复.md
03-第3轮-完整回复.md
...
0N-第N轮-完整回复.md
04-最终研究结论.md   (default 3-round example)
```

Treat the numbered round files as an extensible pattern rather than a fixed 3-round ceiling.

Example:

```text
F:\OpenClaw_Soul\workspace\archive\chatgpt-multi-turn\2026-04-06\OpenClaw游戏策划应用\00-对话目录.md
```

Do not write conversation Markdown files into the workspace root.
For path naming and archive details, read:

- `references/archive-conventions.md`
- `references/output-layout.md`

## Per-round file rule

Each round file must be written before the next round starts.

Each `0N-第N轮-完整回复.md` file must include:

- round number
- topic
- timestamp
- exact question sent that round
- full captured ChatGPT reply
- capture method
- a note when text is partial, uncertain, stale, or manually repaired

If capture fails after reasonable retries, still write the round file with:

- the exact question
- failure notes
- what was attempted
- whether the reply may need manual recovery

Never silently skip a failed round.

## Index file rule

Maintain one compact index file:

```text
00-对话目录.md
```

Use it to record:

- topic
- time
- platform
- round count
- file list
- 1 short summary per round
- final conclusions
- suggested next actions

Update the index after each completed round or at minimum after the final round.

## Final conclusion file rule

After the last round, write one final concise synthesis file:

```text
04-最终研究结论.md
```

Use it to produce a short, high-signal takeaway document based on the saved round files.

Always derive this file from the already-written per-round Markdown files, not from temporary page state alone.

Requirements:

- be shorter and cleaner than the full round files
- focus on conclusions, patterns, and recommended direction
- avoid transcript-like repetition
- default to concise, decision-friendly writing
- prefer 1-screen to 2-screen length unless the user asks for more depth

Treat this file as the main reusable artifact when the conversation is research-oriented.

## Primary capture method: copy-first

On ChatGPT Web, use this as the default archival path:

1. Wait until the current reply is no longer streaming.
2. Take a fresh snapshot.
3. If a `滚动到底部` button is visible and the answer is long, click it.
4. Click the latest `复制回复` button associated with the newest assistant reply.
5. Read the clipboard.
6. Validate that the clipboard contains the current round's answer.
7. Write the round Markdown file immediately.

Use DOM text reads, screenshots, or OCR only as fallback methods.

## Clipboard validation rule

Do not trust clipboard text blindly.

Treat capture as valid only when all checks pass:

- clipboard text is non-empty
- clipboard text is not obviously from an older round
- clipboard text is relevant to the current question
- clipboard text length is plausible for the observed reply
- the round file writes successfully

Treat capture as suspect when any of these happen:

- text is empty
- text clearly matches an earlier round
- text is abnormally short for the visible answer
- text is unrelated to the current question
- text appears truncated mid-sentence without explanation

If capture is suspect:

1. take a fresh snapshot
2. re-target the newest `复制回复`
3. retry clipboard capture
4. only then fall back to DOM extraction / screenshot / OCR

## Fresh-ref rule

Refs on ChatGPT Web are unstable.

Always prefer fresh page state over remembered refs:

- refresh snapshot before interacting with the current round
- do not rely on old input-box refs or old copy-button refs
- if ref clicking is flaky, target the last visible page button whose label or aria-label contains `复制回复`

## Waiting heuristics

Use approximate waits, then verify page state:

- short answer: ~15s
- medium answer: ~20-25s
- long answer: ~30s, then re-check

If the reply is still streaming, wait again. Do not rush the next round.

For long answers or broken capture, read `references/long-replies.md`.

## Next-question design rule

Design the next question only after the current round file exists.

Prefer one of these follow-up patterns:

- **Deepen**: expand the most promising idea from the prior answer
- **Constrain**: force tradeoffs, assumptions, scope, or limits
- **Compare**: compare two routes, structures, or recommendations
- **Operationalize**: turn abstract advice into steps, checklist, draft, framework, or plan

Avoid vague follow-ups like `展开讲讲` unless the topic truly needs open-ended expansion.

When useful, explicitly tell ChatGPT to stay concise in the next round.

## Completion criteria

Treat the task as complete only when all of the following are true:

- browser preflight succeeded, or a clear environment/setup failure was explicitly recorded
- all requested rounds were asked, or there is a clear reason to stop early
- each completed round has its own Markdown file
- each round file contains both question and answer
- the compact index file exists
- the final concise conclusion file exists when the task is research, comparison, or synthesis oriented
- files are stored under the required archive path

## Failure handling

Pause and recover deliberately when any of these occur:

- no usable browser environment exists yet
- ChatGPT is not logged in
- no stable input box can be found
- reply keeps streaming unusually long
- newest `复制回复` button cannot be identified
- clipboard content stays stale across retries
- archive path cannot be created or written
- topic folder name conflicts badly with an existing run

Use these recovery patterns:

- first check whether browser access already exists in the current runtime
- if not, try `browser-share`, then `browser-setup`
- refresh snapshot and re-identify current controls
- retry copy from the newest visible assistant turn
- switch to fallback capture if copy remains unreliable
- write explicit failure notes into the round file instead of hiding the issue
- ask the user only when browser/login/manual intervention is genuinely required or when browser-establishment paths are unavailable

## Output templates

### Compact index file

Use this structure for `00-对话目录.md`:

```markdown
# <对话主题>

> 对话时间：YYYY-MM-DD HH:mm
> 对话平台：ChatGPT (OpenClaw Browser Tool)
> 对话轮数：N轮

## 文件清单
- `01-第1轮-完整回复.md`
- `02-第2轮-完整回复.md`
- `03-第3轮-完整回复.md`

## 第 1 轮：<摘要>
**问题：** ...

**回复要点：**
- ...
- ...

## 第 2 轮：<摘要>
**问题：** ...

**回复要点：**
- ...
- ...

## 总结
### 核心结论
- ...

### 下一步行动
- ...
```

### Per-round full-content file

Use this structure for `0N-第N轮-完整回复.md`:

```markdown
# 第 N 轮完整回复

> 对话主题：<对话主题>
> 时间：YYYY-MM-DD HH:mm
> 问题：<该轮完整问题>
> 捕获方式：复制回复 / DOM / OCR / 混合

## ChatGPT 完整回复

<优先使用页面 `复制回复` 按钮得到的原始文本；如失败，再退回其他方法>

## 备注

- 如有截断、补录、失败重试、人工修复或不确定片段，在这里明确标注。
```

### Final concise conclusion file

Use this structure for `04-最终研究结论.md`:

```markdown
# <对话主题>研究结论

> 生成时间：YYYY-MM-DD HH:mm
> 来源：基于 N 轮 ChatGPT Web 对话整理
> 风格：精炼版

## 一句话结论

...

## 核心发现

- ...
- ...
- ...

## 推荐方向 / 判断

- ...

## 最终压缩版结论

...
```

## Practical notes from live runs

Keep these lessons explicit:

- `wait --text` may be less reliable than direct fresh snapshots on ChatGPT Web; verify page state instead of trusting one wait primitive blindly
- copy-button refs can change after scrolling or page updates; re-snapshot before copy when in doubt
- if the page still shows a streaming-state control such as `停止流式传输`, do not copy yet
- terminal display encoding can look wrong even when clipboard text writes correctly to UTF-8 files; verify the saved file if output looks suspicious

## Minimal command pattern

Use a minimal sequence like this:

```text
snapshot -> optional scroll-to-bottom -> click latest copy-reply -> read clipboard -> validate -> write round md
```

Then:

```text
analyze current answer -> design concise next question -> send next round
```

After the final round:

```text
read saved round files -> write compact index -> write concise final conclusion md
```

## Reference files

Read these only when needed:

- `references/archive-conventions.md` — archive path and naming rules
- `references/output-layout.md` — folder and file layout rules
- `references/long-replies.md` — long reply capture, scrolling, merging, and retry strategy
- `references/question-design.md` — follow-up question selection and concise prompt shaping
- `references/capture-validation.md` — validate that copied text belongs to the current round and is usable
- `references/failure-recovery.md` — recovery patterns for login, ref, clipboard, write, and partial-run failures
- `references/game-planning.md` — example prompt ladder for game-design style conversations
