# init-runner.ps1 - init/reset runner
param([switch]$ResetOnly)
. "$PSScriptRoot\common.ps1"

Ensure-Dirs

if ($ResetOnly) {
    $fresh = @{
        mode = "idle"
        current_project = $null
        current_project_path = $null
        start_time = $null
        end_time = $null
        last_run = $null
    }
    Write-State $fresh
    Write-Output "RESET_OK"
    return
}

$state = @{
    mode = "idle"
    current_project = $null
    current_project_path = $null
    start_time = $null
    last_run = $null
}
Write-State $state
Write-Output "INIT_OK"
