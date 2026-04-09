# resume-current.ps1 - normalize and resume the currently claimed project
. "$PSScriptRoot\common.ps1"
Ensure-Dirs

$state = Read-State

if ($state.mode -eq 'stopped' -or $state.mode -eq 'finished') {
    Write-Output 'RUNNER_INACTIVE'
    return
}

if ($null -eq $state.current_project_path) {
    Write-Output 'NO_CURRENT_PROJECT'
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

$status = Get-ProjectStatus $state.current_project_path
switch ($status) {
    'done' {
        $state.mode = 'idle'
        $state.current_project = $null
        $state.current_project_path = $null
        $state.current_output_dir = $null
        $state.last_run = (Get-Date).ToString('o')
        Write-State $state
        Write-Output 'CURRENT_PROJECT_ALREADY_DONE_RESET_TO_IDLE'
        return
    }
    'blocked' {
        $state.mode = 'idle'
        $state.current_project = $null
        $state.current_project_path = $null
        $state.current_output_dir = $null
        $state.last_run = (Get-Date).ToString('o')
        Write-State $state
        Write-Output 'CURRENT_PROJECT_BLOCKED_RESET_TO_IDLE'
        return
    }
    default {
        $outputDir = Ensure-ProjectOutputDir $state.current_project_path
        $state.mode = 'running'
        $state.current_project = [System.IO.Path]::GetFileName($state.current_project_path)
        $state.current_output_dir = $outputDir
        $state.last_run = (Get-Date).ToString('o')
        Write-State $state

        @{
            project = $state.current_project
            project_path = $state.current_project_path
            output_dir = $outputDir
            project_status = $status
            body_preview = (Read-ProjectFile $state.current_project_path).Substring(0, [Math]::Min((Read-ProjectFile $state.current_project_path).Length, 400))
        } | ConvertTo-Json -Depth 5
        return
    }
}
