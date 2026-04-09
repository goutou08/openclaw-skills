# get-next.ps1 - pick the next project
. "$PSScriptRoot\common.ps1"
Ensure-Dirs

$files = Get-ChildItem $script:ProjectsDir -Filter "*.md" -ErrorAction SilentlyContinue | Sort-Object Name
$nextFile = $null
foreach ($f in $files) {
    $status = Get-ProjectStatus $f.FullName
    if ($status -eq 'new' -or $status -eq 'pending') {
        $nextFile = $f
        break
    }
}

if ($null -eq $nextFile) {
    $state = Read-State
    $state.mode = 'finished'
    $state.current_project = $null
    $state.current_project_path = $null
    $state.current_output_dir = $null
    $state.last_run = (Get-Date).ToString('o')
    Write-State $state
    Write-Output 'QUEUE_EMPTY'
    return
}

$outputDir = Ensure-ProjectOutputDir $nextFile.FullName
$now = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
Update-Frontmatter $nextFile.FullName @{
    status = 'running'
    started = $now
    output_dir = $outputDir
}

$state = Read-State
if ($null -eq $state.start_time) {
    $state.start_time = (Get-Date).ToString('o')
}
$state.mode = 'running'
$state.current_project = $nextFile.Name
$state.current_project_path = $nextFile.FullName
$state.current_output_dir = $outputDir
$state.last_run = (Get-Date).ToString('o')
Write-State $state

Write-Output $nextFile.Name
