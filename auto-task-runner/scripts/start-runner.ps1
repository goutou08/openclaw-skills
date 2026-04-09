# start-runner.ps1 - arm the cooperative runner using the shared project state
. "$PSScriptRoot\common.ps1"
Ensure-Dirs

if (-not (Test-Path $script:StatePath)) {
    & "$PSScriptRoot\init-runner.ps1" | Out-Null
}

$state = Read-State
if ($state.mode -eq "running") {
    Write-Output "ALREADY_RUNNING"
    exit 0
}

$state.mode = "running"
if ($null -eq $state.start_time) {
    $state.start_time = (Get-Date).ToString("o")
}
$state.last_run = (Get-Date).ToString("o")
Write-State $state

Write-Output "STARTED"