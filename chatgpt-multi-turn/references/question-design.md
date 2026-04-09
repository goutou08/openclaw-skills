# Question Design

Use this reference when the next round is not obvious.

Design the next question only after the current round file has been written.

## Goal

Make the next question more useful than a generic follow-up.

Prefer questions that compress ambiguity, force useful structure, or move the conversation toward an output the user can reuse.

## Default style instruction

Unless the user asked for long-form depth, append a brief style constraint such as:

- `请尽量简洁，先给结论，再给关键依据。`
- `避免长篇大论，控制在 5-8 个要点。`
- `请只保留最重要的信息，不要铺垫。`

Do not repeat the exact same suffix every round if it makes the prompt clumsy. Keep it natural.

## Follow-up patterns

Choose the next question from one of these patterns.

### 1. Deepen

Use when the previous answer surfaced one promising idea but stayed high level.

Examples:

- `你刚才提到 A 路线更稳。请简洁说明它成立的 3 个关键前提。`
- `你认为这个方案可行。请把最关键的风险点展开成 5 条。`

### 2. Constrain

Use when the previous answer is broad, fluffy, or too many options were given.

Examples:

- `如果只能保留两个动作，请选最重要的两个，并说明取舍理由。`
- `假设预算很低、时间只有两周，请把建议压缩成最小可执行版本。`

### 3. Compare

Use when two or more routes need tradeoff analysis.

Examples:

- `请简洁对比 A 和 B，在成本、速度、稳定性上分别给出判断。`
- `如果目标是快速上线而不是最优设计，你会选哪条路线？为什么？`

### 4. Operationalize

Use when the answer is conceptually good but not yet actionable.

Examples:

- `请把你的建议改写成一个 7 步以内的执行清单。`
- `请直接给一个可复制的模板，不要解释太多。`
- `请把这个思路整理成：目标 / 输入 / 步骤 / 输出。`

## Selection heuristics

Use this quick rule:

- promising but vague -> Deepen
- too broad -> Constrain
- multiple options -> Compare
- useful but abstract -> Operationalize

## Avoid weak follow-ups

Avoid these unless there is a clear reason:

- `展开讲讲`
- `还有吗`
- `请更详细`
- `继续`

These often produce bloated answers and weak progression.

## Good next-question checklist

Before sending the next round, check that the question:

- clearly depends on the prior answer
- narrows or advances the conversation
- is answerable in one response
- encourages concise output when appropriate
- moves toward a reusable artifact, decision, or framework

## Escalation rule

If the previous answer was already specific and complete, do not force another question just to hit a round count target. It is better to stop early and summarize than to ask a weak filler question.
