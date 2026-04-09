# Failure Recovery

Use this reference when the normal ask -> copy -> save loop breaks.

Recover deliberately. Do not hide failures, and do not keep pushing into later rounds with a broken archive.

## Recovery principles

- stabilize the current round before starting the next one
- prefer fresh page state over stale refs
- write explicit failure notes instead of pretending capture succeeded
- ask the user only when browser/login/manual intervention is actually required

## Common failure cases

### 0. No browser environment exists yet

Symptoms:

- current runtime has no usable browser session
- ChatGPT Web cannot be opened from the available tools
- the task expects browser automation, but no browser environment is established yet

Action:

1. check whether an existing shared/managed browser session is already available
2. if not, try the browser-establishment path first:
   - prefer `browser-share` when the user's Chrome session may already be logged in
   - otherwise try `browser-setup`
3. continue the task only after browser access is actually usable
4. only ask the user or mark the task blocked when those environment-creation paths are unavailable or fail

### 1. ChatGPT is not logged in

Symptoms:

- login page appears
- input box for normal chatting is unavailable
- page asks for authentication

Action:

- stop the workflow
- do not improvise around login
- switch to the appropriate browser setup path
- ask for user help only if login/session restoration is required

### 2. Input box cannot be found reliably

Symptoms:

- no usable input control in snapshot
- refs appear stale or point to inactive controls

Action:

1. refresh snapshot
2. re-identify the active input area
3. if still unstable, pause and re-check browser state
4. only ask the user if the page itself is broken or blocked

### 3. Reply keeps streaming unusually long

Symptoms:

- answer never seems to finish
- page remains in a generating state beyond normal wait windows

Action:

1. wait again once
2. refresh page state
3. determine whether the model is still actually generating or stuck
4. if stuck, capture what is available with explicit notes
5. do not ask the next round until the current round file exists

### 4. `复制回复` button is missing or unreliable

Symptoms:

- no visible copy button on the newest assistant turn
- clicking the ref does nothing
- wrong copy button is triggered repeatedly

Action:

1. refresh snapshot
2. scroll to bottom if needed
3. target the newest visible assistant turn again
4. retry using the freshest ref
5. if still unreliable, switch to fallback capture

### 5. Clipboard content is stale or wrong-turn

Symptoms:

- copied text matches an earlier answer
- copied text is unrelated to the current question
- copied text is suspiciously short

Action:

1. validate using `capture-validation.md`
2. retry with a fresh snapshot and the newest copy target
3. if repeated retries fail, use fallback capture and record that choice

### 6. Round Markdown file cannot be written

Symptoms:

- path creation fails
- write operation errors
- filename collision blocks save

Action:

1. verify topic folder path
2. create missing directories if needed
3. resolve filename conflicts predictably
4. write a temporary local substitute only if necessary
5. do not move to the next round before the round record exists somewhere durable

### 7. Topic folder already exists

Symptoms:

- target archive folder contains prior run artifacts for the same topic/date

Action:

Use a deterministic disambiguation rule, for example:

- append a short suffix
- append a run time marker
- or create a clearly named sibling folder

Do not overwrite a previous archive accidentally.

## Minimum salvage rule

If the round is partially broken, still preserve at least:

- exact question asked
- timestamp
- what failed
- what capture methods were attempted
- best available recovered answer text, if any

A partial but honest archive is better than a clean-looking lie.

## Stop rule

Stop the multi-turn run early when:

- browser/login state blocks further progress
- capture quality cannot be trusted after retries and fallback
- the user changes scope mid-run and a clean restart is better
- the objective has already been met and another round would be filler

When stopping early, write the current round state and summarize why the run stopped.
