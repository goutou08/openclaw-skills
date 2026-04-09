#!/usr/bin/env pwsh
<#
.SYNOPSIS
OpenClaw浏览器工具配置脚本

.DESCRIPTION
自动化配置OpenClaw浏览器工具，包括插件启用、配置设置和验证测试。

.PARAMETER ProfileName
浏览器配置文件名，默认为"openclaw"

.PARAMETER Headless
是否使用无头模式，默认为$false（显示界面）

.PARAMETER Port
CDP调试端口，默认为18800

.PARAMETER Color
浏览器主题颜色，默认为"#FF4500"

.PARAMETER SkipRestart
跳过网关重启步骤

.EXAMPLE
.\setup-browser.ps1
基本配置，使用默认参数

.EXAMPLE
.\setup-browser.ps1 -ProfileName "work" -Headless $true -Port 18801
配置工作用的无头浏览器

.EXAMPLE
.\setup-browser.ps1 -SkipRestart
配置但不重启网关（需要手动重启）
#>

param(
    [string]$ProfileName = "openclaw",
    [bool]$Headless = $false,
    [int]$Port = 18800,
    [string]$Color = "#FF4500",
    [switch]$SkipRestart
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-Color {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Color -Message "✅ $Message" -Color "Green"
}

function Write-Info {
    param([string]$Message)
    Write-Color -Message "ℹ️  $Message" -Color "Cyan"
}

function Write-Warning {
    param([string]$Message)
    Write-Color -Message "⚠️  $Message" -Color "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-Color -Message "❌ $Message" -Color "Red"
}

# 主配置函数
function Main {
    Write-Color "=== OpenClaw浏览器工具配置 ===" -Color "Magenta"
    Write-Info "配置文件: $ProfileName"
    Write-Info "无头模式: $Headless"
    Write-Info "CDP端口: $Port"
    Write-Info "主题颜色: $Color"
    Write-Host ""

    # 步骤1：检查前置条件
    Step1-CheckPrerequisites
    
    # 步骤2：配置浏览器插件
    Step2-ConfigurePlugin
    
    # 步骤3：配置浏览器设置
    Step3-ConfigureBrowser
    
    # 步骤4：配置浏览器配置文件
    Step4-ConfigureProfile
    
    # 步骤5：应用配置
    if (-not $SkipRestart) {
        Step5-ApplyConfiguration
    } else {
        Write-Warning "跳过网关重启，请手动重启网关以应用配置"
    }
    
    # 步骤6：验证配置
    Step6-VerifyConfiguration
    
    Write-Color "=== 配置完成 ===" -Color "Magenta"
}

# 步骤1：检查前置条件
function Step1-CheckPrerequisites {
    Write-Color "步骤1：检查前置条件" -Color "Blue"
    
    # 检查OpenClaw安装
    Write-Info "检查OpenClaw安装..."
    try {
        $version = openclaw --version 2>$null
        if ($version) {
            Write-Success "OpenClaw版本: $version"
        } else {
            throw "无法获取OpenClaw版本"
        }
    } catch {
        Write-Error "OpenClaw未安装或未在PATH中"
        Write-Info "请安装OpenClaw: npm install -g openclaw"
        exit 1
    }
    
    # 检查Chrome安装
    Write-Info "检查Chrome浏览器..."
    $chromePaths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )
    
    $chromeFound = $false
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            Write-Success "找到Chrome: $path"
            $chromeFound = $true
            break
        }
    }
    
    if (-not $chromeFound) {
        Write-Warning "未找到Chrome，将尝试自动检测"
    }
    
    # 检查端口占用
    Write-Info "检查端口占用..."
    $portInUse = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -InformationLevel Quiet
    if ($portInUse) {
        Write-Warning "端口 $Port 可能被占用，建议使用其他端口"
    } else {
        Write-Success "端口 $Port 可用"
    }
    
    Write-Host ""
}

# 步骤2：配置浏览器插件
function Step2-ConfigurePlugin {
    Write-Color "步骤2：配置浏览器插件" -Color "Blue"
    
    Write-Info "启用浏览器插件..."
    try {
        openclaw config set plugins.entries.browser.enabled true
        Write-Success "浏览器插件已启用"
    } catch {
        Write-Error "启用浏览器插件失败: $_"
        exit 1
    }
    
    Write-Host ""
}

# 步骤3：配置浏览器设置
function Step3-ConfigureBrowser {
    Write-Color "步骤3：配置浏览器设置" -Color "Blue"
    
    $browserSettings = @(
        @{Key = "browser.enabled"; Value = "true"},
        @{Key = "browser.defaultProfile"; Value = $ProfileName},
        @{Key = "browser.headless"; Value = $Headless.ToString().ToLower()},
        @{Key = "browser.color"; Value = $Color},
        @{Key = "browser.ssrfPolicy.dangerouslyAllowPrivateNetwork"; Value = "true"}
    )
    
    foreach ($setting in $browserSettings) {
        Write-Info "设置 $($setting.Key) = $($setting.Value)..."
        try {
            openclaw config set $setting.Key $setting.Value
            Write-Success "设置成功"
        } catch {
            Write-Error "设置失败: $_"
        }
    }
    
    Write-Host ""
}

# 步骤4：配置浏览器配置文件
function Step4-ConfigureProfile {
    Write-Color "步骤4：配置浏览器配置文件" -Color "Blue"
    
    Write-Info "配置 $ProfileName 配置文件..."
    
    # 配置CDP端口
    try {
        openclaw config set "browser.profiles.$ProfileName.cdpPort" $Port
        Write-Success "设置CDP端口: $Port"
    } catch {
        Write-Error "设置CDP端口失败: $_"
    }
    
    # 配置颜色
    try {
        openclaw config set "browser.profiles.$ProfileName.color" $Color
        Write-Success "设置颜色: $Color"
    } catch {
        Write-Error "设置颜色失败: $_"
    }
    
    Write-Host ""
}

# 步骤5：应用配置
function Step5-ApplyConfiguration {
    Write-Color "步骤5：应用配置" -Color "Blue"
    
    Write-Info "重启网关服务..."
    try {
        $result = openclaw gateway restart 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "网关重启成功"
            
            # 等待网关启动
            Write-Info "等待网关启动..."
            Start-Sleep -Seconds 10
            
            # 验证网关状态
            $gatewayStatus = openclaw gateway status 2>$null
            if ($gatewayStatus -and $gatewayStatus -match "Listening:") {
                Write-Success "网关运行正常"
            } else {
                Write-Warning "网关状态检查失败，请手动验证"
            }
        } else {
            Write-Error "网关重启失败: $result"
        }
    } catch {
        Write-Error "重启网关时出错: $_"
    }
    
    Write-Host ""
}

# 步骤6：验证配置
function Step6-VerifyConfiguration {
    Write-Color "步骤6：验证配置" -Color "Blue"
    
    # 检查浏览器状态
    Write-Info "检查浏览器状态..."
    try {
        $status = openclaw browser status 2>$null
        if ($status) {
            Write-Success "浏览器状态检查成功"
            
            # 解析状态信息
            $statusLines = $status -split "`n"
            foreach ($line in $statusLines) {
                if ($line.Trim()) {
                    Write-Host "   $line"
                }
            }
            
            # 检查关键状态
            if ($status -match "enabled: true") {
                Write-Success "浏览器功能已启用"
            } else {
                Write-Error "浏览器功能未启用"
            }
            
            if ($status -match "running:") {
                $running = $status -match "running: true"
                if ($running) {
                    Write-Success "浏览器正在运行"
                } else {
                    Write-Info "浏览器未运行，可以手动启动"
                }
            }
        } else {
            Write-Error "无法获取浏览器状态"
        }
    } catch {
        Write-Error "检查浏览器状态失败: $_"
    }
    
    Write-Host ""
    
    # 生成配置摘要
    Write-Color "配置摘要" -Color "Green"
    Write-Host "配置文件:     $ProfileName"
    Write-Host "CDP端口:      $Port"
    Write-Host "无头模式:     $Headless"
    Write-Host "主题颜色:     $Color"
    Write-Host "网关端口:     18789"
    Write-Host "控制面板:     http://localhost:18789/"
    Write-Host ""
    
    # 使用说明
    Write-Color "使用说明" -Color "Yellow"
    Write-Host "1. 启动浏览器: openclaw browser start"
    Write-Host "2. 打开网页:   openclaw browser open <URL>"
    Write-Host "3. 查看标签页: openclaw browser tabs"
    Write-Host "4. 截图:       openclaw browser screenshot"
    Write-Host "5. 停止浏览器: openclaw browser stop"
    Write-Host ""
    
    # 故障排除提示
    Write-Color "故障排除" -Color "Red"
    Write-Host "• 如果浏览器无法启动，检查Chrome是否安装"
    Write-Host "• 如果端口冲突，修改Port参数重新运行脚本"
    Write-Host "• 查看日志: openclaw logs --tail 20"
    Write-Host "• 详细文档: https://docs.openclaw.ai/tools/browser"
}

# 运行主函数
try {
    Main
} catch {
    Write-Error "配置过程中出现错误: $_"
    Write-Error "错误详情: $($_.ScriptStackTrace)"
    exit 1
}