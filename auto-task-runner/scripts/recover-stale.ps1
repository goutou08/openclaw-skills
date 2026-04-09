# recover-stale.ps1 - recover a likely-stale running project
param(
    [ValidateSet('resume','block','idle')]
    [string]$Action = 'resume',
    [string]$Reason = 'stale running task recovered manually'
)
. "$PSScriptRoot\common.ps1"
Ensure-Dirs

$state = Read-State
if ($state.mode -ne 'running' -or $null -eq $state.current_project_path) {
    Write-Output 'NO_RUNNING_PROJECT'
    return
}

if (-not (Test-Path $state.current_project_path)) {
    $state.mode = 'idle'
    $state.current_project = $null
    $state.current_project_path = $null
    $state.current_output_dir = $null
    $state.last_run = (Get-Date).ToString('o')
    Write-State $state
    Write-Output 'PROJECT_FILE_MISSING_RESET_TO_IDLE'
    return
}

switch ($Action) {
    'resume' {
        & "$PSScriptRoot\resume-current.ps1"
        return
    }
    'block' {
        & "$PSScriptRoot\mark-fail.ps1" -Reason $Reason
        return
    }
    'idle' {
        Update-Frontmatter $state.current_project_path @{ status = 'pending' }
        $state.mode = 'idle'
        $state.current_project = $null
        $state.current_project_path = $null
        $state.current_output_dir = $null
        $state.last_run = (Get-Date).ToString('o')
        Write-State $state
        Write-Output 'RESET_TO_PENDING_AND_IDLE'
        return
    }
}
