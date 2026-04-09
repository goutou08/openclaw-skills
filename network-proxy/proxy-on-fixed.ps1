# proxy-on-fixed.ps1 - Hardcoded port version
$port = 7897
$env:HTTP_PROXY = "http://127.0.0.1:$port"
$env:HTTPS_PROXY = "http://127.0.0.1:$port"
$env:http_proxy = "http://127.0.0.1:$port"
$env:https_proxy = "http://127.0.0.1:$port"
Write-Host "Proxy enabled: http://127.0.0.1:$port"
try {
    $r = Invoke-WebRequest https://www.google.com -TimeoutSec 5 -UseBasicParsing
    Write-Host "Google: $($r.StatusCode)"
} catch {
    Write-Host "Google: FAIL"
}
try {
    $r = Invoke-WebRequest https://github.com -TimeoutSec 5 -UseBasicParsing
    Write-Host "GitHub: $($r.StatusCode)"
} catch {
    Write-Host "GitHub: FAIL"
}
