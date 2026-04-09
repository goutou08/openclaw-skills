# Long Reply Capture

Use this reference when ChatGPT replies are long, still streaming, or likely to be truncated in one screenshot.

## Goal

Capture enough of the answer to produce:

1. a per-round full-content Markdown file
2. a reliable summary for the index file

without asking the next question too early.

## Recommended flow

1. Wait for the first draft of the reply.
2. Run `snapshot --interactive`.
3. If the page still shows a streaming state (for example a stop button or active generation state), wait again.
4. If a `滚动到底部` button exists, click it first.
5. On ChatGPT Web, click the latest `复制回复` button and read the system clipboard.
6. Prefer a fresh snapshot ref first; if ref-based clicking is flaky, click the last page button whose `aria-label` contains `复制回复`.
7. On Windows / PowerShell, use `Get-Clipboard -Raw` to pull the copied reply text.
8. If clipboard capture succeeds, use that text as the primary archival source.
9. Only if `复制回复` is unavailable or clipboard capture fails, take a screenshot and use image extraction to pull the visible content.
10. Repeat wait + scroll + copy (or fallback screenshot) until the answer stabilizes.
11. Merge the captured fragments into one clean summary.

## Heuristics

### Signs the reply is not done yet

- A visible “停止流式传输” / stop-streaming button
- New copy buttons appearing later than before
- The answer ends mid-list, mid-sentence, or mid-code-block
- The page still exposes a fresh scroll-to-bottom button after waiting

### Signs the reply is probably complete

- No streaming indicator remains
- The final paragraph contains a wrap-up or call-to-action
- A second copy attempt or screenshot taken after waiting shows no meaningful new content

## Extraction strategy

Use two outputs, not one.

### A. Full-content round file

For `0N-第N轮-完整回复.md`:

1. Prefer text copied via the page `复制回复` button
2. If needed, supplement with screenshot / OCR fragments
3. Preserve the original structure as much as possible
4. Keep headings, lists, numbered steps, prompts, and code blocks
5. Mark any uncertain gap instead of silently summarizing it away

### B. Summary index file

For `00-对话目录.md`:

1. Compress the round into bullet points
2. Keep only the key takeaways
3. Avoid noisy OCR and duplication

## When content is partially missing

If the answer is clearly useful but one section is cut off:

- Keep the captured part
- Mark it as partial in your notes
- Ask a narrower follow-up only if the missing section matters to the user goal

Example:

```markdown
### Prompt 模板（部分截取）
- 主策划人格 Prompt
- 核心循环优先
- 结构化 Markdown 输出
```

## Multi-screenshot merge pattern

Use a simple merge style in your working notes:

```markdown
### Round 2 raw capture
- Shot A: opening explanation + main template
- Shot B: usage tips + final summary
- Missing: one middle subsection title
```

Then convert that into a clean final summary.

## Copy-first checklist

For ChatGPT Web, use this short checklist:

1. Wait for reply completion
2. Snapshot
3. Scroll to bottom if needed
4. Click latest `复制回复`
5. If needed, click the last page button whose `aria-label` contains `复制回复`
6. Run `Get-Clipboard -Raw`
7. Save the round Markdown file
8. Only then continue to the next round

## Rule

Do not send the next round question until you are confident the current answer is complete enough to save as that round's full-content file.
