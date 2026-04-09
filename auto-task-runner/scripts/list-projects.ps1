# list-projects.ps1 - list all projects
. "$PSScriptRoot\common.ps1"
Ensure-Dirs

$files = Get-ChildItem $script:ProjectsDir -Filter "*.md" | Sort-Object Name
if ($files.Count -eq 0) {
    Write-Output "No projects found."
    return
}

$state = Read-State
$current = $state.current_project
foreach ($f in $files) {
    $status = Get-ProjectStatus $f.FullName
    $marker = if ($f.Name -eq $current) { '>> ' } else { '   ' }
    Write-Output "$marker[$status] $($f.Name)"
}
