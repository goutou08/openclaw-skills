# Capture Validation

Use this reference when validating copied ChatGPT replies.

The main failure mode is simple: the page copy action succeeds, but the clipboard content is stale, partial, or from the wrong turn.

## Validation goal

Confirm that the captured text is the newest relevant answer for the current round before saving it as the source of truth.

## Required checks

Treat copied text as valid only when all of these are true:

1. **Non-empty**
   - The clipboard contains actual text, not whitespace.

2. **Plausibly current**
   - The text does not obviously match an older round.
   - The text is not clearly unrelated to the current question.

3. **Plausibly complete**
   - The text length is broadly consistent with what is visible on the page.
   - The text does not end in an obviously broken way unless the UI itself shows truncation or interruption.

4. **Persisted successfully**
   - The round Markdown file is written successfully after validation.

## Quick validation heuristics

Use lightweight checks first.

### A. Relevance check

Compare the copied answer against the current question.

Ask:

- Does the answer mention the same topic, entities, or decision space?
- Does it look like a response to this round rather than the previous one?

If clearly no, treat it as stale or wrong-turn capture.

### B. Length check

Compare observed page length vs clipboard length.

- If the page visibly contains a long reply but the clipboard is only a few short lines, treat as suspect.
- If the current answer should be brief because the prompt asked for concision, short output can still be valid.

Judge relative to the actual page state, not a fixed threshold.

### C. Ending check

Inspect the final lines.

Suspect capture when the text ends with:

- half a sentence
- broken list structure
- abrupt fragment with no closing thought
- obvious clipped markdown/code block

### D. Duplication check

Compare against the last saved round if available.

If the new clipboard content is nearly identical to the previous round, re-check before accepting it.

## Retry sequence

If capture is suspect, retry in this order:

1. take a fresh page snapshot
2. identify the newest assistant turn again
3. click the latest `复制回复`
4. read clipboard again
5. re-run validation

Only after a failed retry should you use a fallback capture path.

## Fallback capture paths

Use these only when copy-first remains unreliable:

1. DOM text extraction
2. screenshot-based reading
3. OCR/manual repair

When fallback is used, record it in the round file under capture method and notes.

## File note rule

If the capture is accepted but not fully clean, note that explicitly.

Examples:

- `备注：本轮通过复制回复获取，末尾疑似有轻微截断。`
- `备注：复制回复失败，改用 DOM 提取并人工整理格式。`

## Failure threshold

Do not loop forever.

If repeated copy attempts still produce stale or broken text, switch to fallback capture and document the issue.

The priority is: reliable archive with clear notes, not a fake sense of perfection.
