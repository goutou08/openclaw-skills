# add-task.ps1 - convenience helper to create a bare task markdown file
param(
    [Parameter(Mandatory=$true)][string]$Title,
    [string[]]$Steps = @()
)
. "$PSScriptRoot\common.ps1"
Ensure-Dirs

$safeTitle = $Title -replace '[\\/:*?"<>|]', '-' -replace '\s+', '-'
$filename = "$safeTitle.md"
$filepath = Join-Path $script:ProjectsDir $filename
if (Test-Path $filepath) {
    Write-Output 'TASK_ALREADY_EXISTS'
    return
}

$body = "# $Title`n`n"
if ($Steps.Count -gt 0) {
    $body += "## 步骤`n"
    foreach ($s in $Steps) { $body += "- [ ] $s`n" }
    $body += "`n"
}
$body += "## 备注`n`n"
Write-ProjectFile $filepath $body
Write-Output $filename
