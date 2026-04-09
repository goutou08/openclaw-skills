# Runner state schema

State file path:

`F:\OpenClaw_Soul\workspace\memory\project-runner-state.json`

Example:

```json
{
  "mode": "idle",
  "current_project": null,
  "current_project_path": null,
  "current_output_dir": null,
  "start_time": null,
  "end_time": null,
  "last_run": null
}
```

## Fields

- `mode`: `idle | running | stopped | finished`
- `current_project`: current project filename or `null`
- `current_project_path`: absolute path or `null`
- `current_output_dir`: absolute output directory path or `null`
- `start_time`: first runner start time
- `end_time`: optional end time / reserved field
- `last_run`: last runner action time

## Health fields from `get-state.ps1`

These are derived fields returned by `get-state.ps1` for diagnostics and heartbeat recovery:

- `current_project_status`: project frontmatter status of the claimed file
- `output_file_count`: recursive file count under the current output directory
- `minutes_since_last_run`: time since the last runner action
- `likely_stale`: `true` when the runner is `running`, has a current project, has had no recent action for a while, and the output directory is still empty
