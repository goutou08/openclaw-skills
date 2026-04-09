# mark-fail.ps1 - mark current project blocked
param([Parameter(Mandatory=$true)][string]$Reason)
. "$PSScriptRoot\common.ps1"

$state = Read-State
if ($null -eq $state.current_project_path) {
    Write-Output 'NO_CURRENT_PROJECT'
    return
}
if (-not (Test-Path $state.current_project_path)) {
    Write-Output 'PROJECT_FILE_MISSING'
    return
}

$outputDir = Ensure-ProjectOutputDir $state.current_project_path
Update-Frontmatter $state.current_project_path @{
    status = 'blocked'
    blocked_reason = $Reason
    output_dir = $outputDir
}

$state.mode = 'idle'
$state.current_project = $null
$state.current_project_path = $null
$state.current_output_dir = $null
$state.last_run = (Get-Date).ToString('o')
Write-State $state

Write-Output "BLOCKED: $Reason"
