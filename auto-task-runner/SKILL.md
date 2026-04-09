---
name: auto-task-runner
description: Run project tasks from `workspace/projects/` using a simple file-based queue. Use when the user wants to manage work by creating one Markdown file per task, let the runner detect new bare Markdown files as unstarted tasks, write progress/status into task files only after execution begins, and store each task's outputs in a same-named subfolder under `projects/`.
---

# Auto Task Runner

Use this skill as a **cooperative bare-Markdown project runner**.

## Important model

This skill is **not** a self-contained daemon that can finish arbitrary tasks on its own after a file is claimed.

It has two layers:

1. **Queue/state layer** — scripts discover tasks, claim them, maintain frontmatter, and track the current project.
2. **Execution layer** — the active agent turn / heartbeat turn must actually read the claimed project file, perform the work, write outputs, and then call `mark-done.ps1` or `mark-fail.ps1`.

If a task is marked `running` but no active turn actually continues the work, it can appear "stuck" even though the queue scripts are behaving as designed.

Treat this skill as a **cooperative queue + state manager**, not a guaranteed always-on worker.

## Core model

- `projects/*.md` is the task queue
- **One Markdown file = one task / small project**
- A file containing only user-written task content is treated as a **new task**
- The runner writes frontmatter only when it starts managing that task
- Each task gets an output folder under `projects/`
- For new tasks, the output folder should use a **safe ASCII directory name** derived from the task filename, with a short hash suffix for uniqueness
- If a task file already has an `output_dir` in frontmatter, keep using that existing directory for compatibility

Example:

- task file: `projects/设计战斗框架.md`
- output folder: `projects/project-a1b2c3d4/` (example form)
- frontmatter still records the exact `output_dir`, so the runner knows where outputs belong

## Task discovery rules

Treat a task file as:

- `new`: no runner frontmatter yet, only user content
- `pending`: managed by runner but not started
- `running`: currently in progress
- `done`: completed
- `blocked`: stopped because of a blocker

When picking the next task:

1. Read all `projects/*.md`
2. Sort by filename
3. Pick the first file whose status is `new` or `pending`
4. Create its output folder
5. Write frontmatter into the task file
6. Set status to `running`

## Progress storage

The runner may write frontmatter like:

```md
---
status: running
created: 2026-04-08T21:00:00+08:00
started: 2026-04-08T21:05:00+08:00
completed: null
blocked_reason: null
output_dir: F:\OpenClaw_Soul\workspace\projects\设计战斗框架
---
```

Below the frontmatter, preserve the user's original task content.

## Output storage

Put task outputs into the corresponding subfolder.

Why safe ASCII directories:

- Avoid mojibake/garbled Chinese names in PowerShell/exec output
- Make shell diagnostics more stable across Windows console encodings
- Keep compatibility by preserving any already-recorded `output_dir`


- documents
- drafts
- images
- prototypes
- notes
- exported files

Do not mix outputs from different tasks in one shared folder.

## Main scripts

- `scripts\init-runner.ps1` — initialize/reset runtime state
- `scripts\start-runner.ps1` — arm the cooperative runner using the shared state file
- `scripts\stop-runner.ps1` — stop runner
- `scripts\list-projects.ps1` — list task files and statuses
- `scripts\get-state.ps1` — show runner state + health signals (`current_project_status`, `output_file_count`, `likely_stale`)
- `scripts\get-next.ps1` — claim next `new`/`pending` task
- `scripts\resume-current.ps1` — normalize and resume the currently claimed project before doing real work
- `scripts\recover-stale.ps1 [-Action resume|block|idle] [-Reason "..."]` — recover a likely-stale running task
- `scripts\mark-done.ps1` — finish current task
- `scripts\mark-fail.ps1 -Reason "..."` — block current task
- `scripts\add-task.ps1 -Title "..." [-Steps "a","b"]` — optional helper; creates a bare task file only

## Heartbeat behavior

Heartbeat should:

1. Run `scripts\get-state.ps1`
2. If there is a current running task, run `scripts\resume-current.ps1`, then read that project file and continue the actual task work in the same turn
3. If there is no current task, run `scripts\get-next.ps1`
4. If `get-next.ps1` returns a project name, run `scripts\resume-current.ps1`, then read that project file immediately and start executing it in the same turn
5. If it returns `QUEUE_EMPTY`, reply `HEARTBEAT_OK`
6. After successful completion, run `scripts\mark-done.ps1`
7. On a real blocker, run `scripts\mark-fail.ps1 -Reason "..."`
8. If `get-state.ps1` shows `likely_stale=true`, treat it as a recovery-needed condition and explicitly decide whether to resume, fail, or reset pending (for example via `recover-stale.ps1`)

Do not stop at merely claiming a task. Claiming a task without executing it leaves the queue in a misleading `running` state.

## Constraints

- Do not require numbered filenames
- Do not require the user to prewrite runner frontmatter
- Do not maintain a separate JSON task queue as the source of truth
- Use `projects/` as the single source of truth for tasks
- Keep runtime-only data in `memory/project-runner-state.json`
- Use one shared runner state file; do not split start/stop/query logic across multiple state files
