# stop-runner.ps1 - stop the runner
. "$PSScriptRoot\common.ps1"

$state = Read-State
$state.mode = "stopped"
$state.last_run = (Get-Date).ToString("o")
Write-State $state

Write-Output "STOPPED"
