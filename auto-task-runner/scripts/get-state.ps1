# get-state.ps1 - query runner state
. "$PSScriptRoot\common.ps1"

$state = Read-State
$files = Get-ChildItem $script:ProjectsDir -Filter "*.md" -ErrorAction SilentlyContinue | Sort-Object Name
$newCount = 0; $pending = 0; $running = 0; $done = 0; $blocked = 0; $managed = 0
foreach ($f in $files) {
    switch (Get-ProjectStatus $f.FullName) {
        'new' { $newCount++ }
        'pending' { $pending++ }
        'running' { $running++ }
        'done' { $done++ }
        'blocked' { $blocked++ }
        default { $managed++ }
    }
}

$currentProjectStatus = $null
$outputFileCount = 0
$minutesSinceLastRun = $null
$likelyStale = $false

if ($state.last_run) {
    try {
        $lastRunDt = Get-Date $state.last_run
        $minutesSinceLastRun = [math]::Round(((Get-Date) - $lastRunDt).TotalMinutes, 2)
    } catch {
        $minutesSinceLastRun = $null
    }
}

if ($state.current_project_path -and (Test-Path $state.current_project_path)) {
    $currentProjectStatus = Get-ProjectStatus $state.current_project_path
}

if ($state.current_output_dir -and (Test-Path $state.current_output_dir)) {
    $outputFileCount = @(Get-ChildItem $state.current_output_dir -File -Recurse -ErrorAction SilentlyContinue).Count
}

if ($state.mode -eq 'running' -and $state.current_project -and $minutesSinceLastRun -ne $null) {
    if ($minutesSinceLastRun -ge 15 -and $outputFileCount -eq 0) {
        $likelyStale = $true
    }
}

@{
    mode = $state.mode
    current_project = $state.current_project
    current_project_path = $state.current_project_path
    current_output_dir = $state.current_output_dir
    current_project_status = $currentProjectStatus
    output_file_count = $outputFileCount
    start_time = $state.start_time
    last_run = $state.last_run
    minutes_since_last_run = $minutesSinceLastRun
    likely_stale = $likelyStale
    counts = @{
        total = $files.Count
        new = $newCount
        pending = $pending
        running = $running
        done = $done
        blocked = $blocked
        managed = $managed
    }
} | ConvertTo-Json -Depth 5
