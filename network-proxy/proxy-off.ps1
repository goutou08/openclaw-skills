# proxy-off.ps1 - 关闭网络代理
# 用法: .\proxy-off.ps1

# 清除代理环境变量
$env:HTTP_PROXY = $null
$env:HTTPS_PROXY = $null
$env:http_proxy = $null
$env:https_proxy = $null

Write-Host "[proxy-off] 代理环境变量已清除" -ForegroundColor Yellow
Write-Host "[proxy-off] 注意: Clash Verge 本身仍在后台运行" -ForegroundColor Gray
Write-Host "[proxy-off] 如需重新启用，运行 .\proxy-on.ps1" -ForegroundColor Gray
