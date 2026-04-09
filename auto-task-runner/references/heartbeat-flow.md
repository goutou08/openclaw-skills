# Heartbeat flow

Use this flow when heartbeat drives the runner.

## Steps

1. Run `scripts\get-state.ps1`
2. If `mode` is `stopped` or `finished`, return `HEARTBEAT_OK`
3. If `current_project` is not null, run `scripts\resume-current.ps1`, then read that project file and continue the real work **in the same turn**
4. If `current_project` is null, run `scripts\get-next.ps1`
5. If `get-next.ps1` returns `QUEUE_EMPTY`, stop runner and return `HEARTBEAT_OK`
6. Otherwise run `scripts\resume-current.ps1`, then read the returned project file and begin the real work **in the same turn**
7. After successful completion, call `scripts\mark-done.ps1`
8. On a real blocker, call `scripts\mark-fail.ps1 -Reason "..."`
9. If `get-state.ps1` reports `likely_stale=true`, explicitly recover instead of silently leaving the task in `running` (for example: `recover-stale.ps1 -Action resume|block|idle`)

## Principle

Heartbeat should not invent tasks. It should only continue or pick from `projects/`.

Claiming a task is not enough. A heartbeat that only updates state but does not actually execute the claimed task can leave the queue stuck in `running`.
