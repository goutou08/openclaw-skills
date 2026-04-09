# init.ps1 - 网络代理初始化配置
# 用法: .\init.ps1
# 首次使用前运行，配置代理端口等参数

$ErrorActionPreference = "Stop"

# 配置目录
$configDir = "$env:USERPROFILE\.openclaw\skills-config"
$configFile = "$configDir\network-proxy.json"

# 确保目录存在
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

Write-Host "=== Network Proxy 初始化 ===" -ForegroundColor Cyan
Write-Host ""

# 读取当前配置（如果存在）
$currentConfig = $null
if (Test-Path $configFile) {
    try {
        $currentConfig = Get-Content $configFile | ConvertFrom-Json
        Write-Host "当前配置:" -ForegroundColor Yellow
        Write-Host "  代理端口: $($currentConfig.port)"
        Write-Host "  机场订阅: $($currentConfig.airportUrl)"
        Write-Host ""
    } catch {
        Write-Host "读取现有配置失败，将创建新配置" -ForegroundColor Yellow
    }
}

# 询问代理端口
Write-Host "请输入 Clash Verge 的本地代理端口:" -ForegroundColor Green
Write-Host "  （通常在 Clash Verge 设置中查看，常见值: 7890, 7891, 7897）" -ForegroundColor Gray
$portInput = Read-Host "端口"
if ([string]::IsNullOrWhiteSpace($portInput)) {
    $port = if ($currentConfig) { $currentConfig.port } else { 7897 }
    Write-Host "  使用默认值: $port" -ForegroundColor Gray
} else {
    $port = $portInput.Trim()
}

# 验证端口是否为数字
if ($port -notmatch "^\d+$") {
    Write-Host "[错误] 端口必须是数字" -ForegroundColor Red
    exit 1
}

# 询问机场订阅链接（可选）
Write-Host ""
Write-Host "机场订阅链接（可选，直接回车跳过）:" -ForegroundColor Green
Write-Host "  （仅作记录，不参与代理工作）" -ForegroundColor Gray
$airportInput = Read-Host "订阅链接"
if ([string]::IsNullOrWhiteSpace($airportInput)) {
    $airportUrl = if ($currentConfig) { $currentConfig.airportUrl } else { "" }
    if ($airportUrl) {
        Write-Host "  保留现有订阅链接: $airportUrl" -ForegroundColor Gray
    } else {
        Write-Host "  未设置订阅链接" -ForegroundColor Gray
    }
} else {
    $airportUrl = $airportInput.Trim()
}

# 创建配置对象
$config = @{
    port = [int]$port
    airportUrl = $airportUrl
    updatedAt = (Get-Date -Format "yyyy-MM-dd")
}

# 保存配置
$config | ConvertTo-Json | Set-Content $configFile -Encoding UTF8

Write-Host ""
Write-Host "=== 配置已保存 ===" -ForegroundColor Green
Write-Host "  配置文件: $configFile"
Write-Host "  代理端口: $($config.port)"
Write-Host ""

# 验证端口是否可用
Write-Host "正在验证代理连接..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 5 `
        -Proxy "http://127.0.0.1:$port" -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "验证成功! 代理可正常工作" -ForegroundColor Green
    }
} catch {
    Write-Host "警告: 无法验证代理连接" -ForegroundColor Yellow
    Write-Host "请确认:" -ForegroundColor Yellow
    Write-Host "  1. Clash Verge 正在运行" -ForegroundColor Yellow
    Write-Host "  2. 系统代理或规则分流模式已开启" -ForegroundColor Yellow
    Write-Host "  3. 端口号正确 ($port)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "初始化完成! 运行 .\proxy-on.ps1 启用代理" -ForegroundColor Cyan
