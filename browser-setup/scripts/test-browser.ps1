#!/usr/bin/env pwsh
<#
.SYNOPSIS
OpenClaw浏览器工具测试脚本

.DESCRIPTION
测试OpenClaw浏览器工具的各项功能，包括基础操作、页面交互和性能测试。

.PARAMETER TestUrl
测试使用的URL，默认为"https://www.example.com"

.PARAMETER ProfileName
浏览器配置文件名，默认为"openclaw"

.PARAMETER Headless
是否使用无头模式测试

.PARAMETER Comprehensive
运行全面测试（包括性能测试）

.PARAMETER OutputDir
测试输出目录

.EXAMPLE
.\test-browser.ps1
运行基础功能测试

.EXAMPLE
.\test-browser.ps1 -TestUrl "https://news.ycombinator.com" -Comprehensive
在指定URL上运行全面测试

.EXAMPLE
.\test-browser.ps1 -Headless -OutputDir ".\test-results"
在无头模式下运行测试并保存结果
#>

param(
    [string]$TestUrl = "https://www.example.com",
    [string]$ProfileName = "openclaw",
    [switch]$Headless,
    [switch]$Comprehensive,
    [string]$OutputDir = ".\browser-test-results"
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

# 测试结果记录
$TestResults = @{
    StartTime = Get-Date
    Tests = @()
    Summary = @{
        Total = 0
        Passed = 0
        Failed = 0
        Skipped = 0
    }
}

# 记录测试结果
function Record-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message,
        [hashtable]$Details = @{},
        [switch]$Skipped
    )
    
    $result = @{
        TestName = $TestName
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        Passed = $Passed
        Message = $Message
        Details = $Details
        Skipped = $Skipped
    }
    
    $TestResults.Tests += $result
    
    if ($Skipped) {
        $TestResults.Summary.Skipped++
        Write-Color "[跳过] $TestName: $Message" -Color "Gray"
    } elseif ($Passed) {
        $TestResults.Summary.Passed++
        $TestResults.Summary.Total++
        Write-Success "$TestName: $Message"
    } else {
        $TestResults.Summary.Failed++
        $TestResults.Summary.Total++
        Write-Error "$TestName: $Message"
    }
}

# 保存测试报告
function Save-TestReport {
    # 创建输出目录
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    # 保存JSON报告
    $reportFile = Join-Path $OutputDir "test-report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $TestResults | ConvertTo-Json -Depth 5 | Set-Content $reportFile
    
    # 生成HTML报告
    $htmlReport = Generate-HtmlReport
    $htmlFile = Join-Path $OutputDir "test-report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    $htmlReport | Set-Content $htmlFile
    
    Write-Info "测试报告已保存:"
    Write-Info "  JSON: $reportFile"
    Write-Info "  HTML: $htmlFile"
}

# 生成HTML报告
function Generate-HtmlReport {
    $passRate = if ($TestResults.Summary.Total -gt 0) {
        [math]::Round($TestResults.Summary.Passed / $TestResults.Summary.Total * 100, 2)
    } else { 0 }
    
    $duration = (Get-Date) - $TestResults.StartTime
    
    @"
<!DOCTYPE html>
<html>
<head>
    <title>OpenClaw浏览器测试报告</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .summary { background: #f5f5f5; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .test { border: 1px solid #ddd; margin: 10px 0; padding: 15px; border-radius: 5px; }
        .passed { background: #d4edda; border-color: #c3e6cb; }
        .failed { background: #f8d7da; border-color: #f5c6cb; }
        .skipped { background: #e2e3e5; border-color: #d6d8db; }
        .details { margin-top: 10px; padding: 10px; background: white; border-radius: 3px; }
        .stats { display: flex; gap: 20px; margin: 10px 0; }
        .stat { padding: 10px; border-radius: 5px; }
        .stat-total { background: #6c757d; color: white; }
        .stat-passed { background: #28a745; color: white; }
        .stat-failed { background: #dc3545; color: white; }
        .stat-skipped { background: #ffc107; color: black; }
    </style>
</head>
<body>
    <h1>OpenClaw浏览器测试报告</h1>
    
    <div class="summary">
        <h2>测试摘要</h2>
        <p><strong>测试时间:</strong> $($TestResults.StartTime.ToString("yyyy-MM-dd HH:mm:ss"))</p>
        <p><strong>测试URL:</strong> $TestUrl</p>
        <p><strong>配置文件:</strong> $ProfileName</p>
        <p><strong>测试时长:</strong> $($duration.ToString("hh\:mm\:ss"))</p>
        
        <div class="stats">
            <div class="stat stat-total">
                <h3>总计</h3>
                <p>$($TestResults.Summary.Total)</p>
            </div>
            <div class="stat stat-passed">
                <h3>通过</h3>
                <p>$($TestResults.Summary.Passed)</p>
            </div>
            <div class="stat stat-failed">
                <h3>失败</h3>
                <p>$($TestResults.Summary.Failed)</p>
            </div>
            <div class="stat stat-skipped">
                <h3>跳过</h3>
                <p>$($TestResults.Summary.Skipped)</p>
            </div>
        </div>
        
        <p><strong>通过率:</strong> $passRate%</p>
    </div>
    
    <h2>详细测试结果</h2>
    
"@
    
    foreach ($test in $TestResults.Tests) {
        $statusClass = if ($test.Skipped) { "skipped" } elseif ($test.Passed) { "passed" } else { "failed" }
        
        @"
    <div class="test $statusClass">
        <h3>$($test.TestName)</h3>
        <p><strong>状态:</strong> $(if ($test.Skipped) { "跳过" } elseif ($test.Passed) { "通过" } else { "失败" })</p>
        <p><strong>时间:</strong> $($test.Timestamp)</p>
        <p><strong>消息:</strong> $($test.Message)</p>
        
"@
        
        if ($test.Details.Count -gt 0) {
            @"
        <div class="details">
            <h4>详细信息:</h4>
            <pre>$($test.Details | ConvertTo-Json -Depth 3)</pre>
        </div>
"@
        }
        
        @"
    </div>
"@
    }
    
    @"
</body>
</html>
"@
}

# 测试1：检查浏览器状态
function Test-BrowserStatus {
    Write-Color "=== 测试1：检查浏览器状态 ===" -Color "Blue"
    
    try {
        $status = openclaw browser --browser-profile $ProfileName status 2>$null
        if ($status) {
            $details = @{
                Status = $status
                Profile = $ProfileName
            }
            
            Record-TestResult -TestName "浏览器状态检查" -Passed $true -Message "浏览器状态获取成功" -Details $details
            return $true
        } else {
            Record-TestResult -TestName "浏览器状态检查" -Passed $false -Message "无法获取浏览器状态"
            return $false
        }
    } catch {
        Record-TestResult -TestName "浏览器状态检查" -Passed $false -Message "检查浏览器状态时出错: $_"
        return $false
    }
}

# 测试2：启动和停止浏览器
function Test-BrowserStartStop {
    Write-Color "=== 测试2：启动和停止浏览器 ===" -Color "Blue"
    
    try {
        # 启动浏览器
        Write-Info "启动浏览器..."
        $startResult = openclaw browser --browser-profile $ProfileName start 2>&1
        Start-Sleep -Seconds 5
        
        # 检查运行状态
        $status = openclaw browser --browser-profile $ProfileName status 2>$null
        $isRunning = $status -match "running: true"
        
        if ($isRunning) {
            Write-Success "浏览器启动成功"
            
            # 停止浏览器
            Write-Info "停止浏览器..."
            $stopResult = openclaw browser --browser-profile $ProfileName stop 2>&1
            Start-Sleep -Seconds 3
            
            # 再次检查状态
            $statusAfterStop = openclaw browser --browser-profile $ProfileName status 2>$null
            $isStopped = $statusAfterStop -match "running: false"
            
            if ($isStopped) {
                $details = @{
                    StartResult = $startResult
                    StopResult = $stopResult
                    InitialStatus = $status
                    FinalStatus = $statusAfterStop
                }
                
                Record-TestResult -TestName "浏览器启动停止" -Passed $true -Message "浏览器启动和停止测试成功" -Details $details
                return $true
            } else {
                Record-TestResult -TestName "浏览器启动停止" -Passed $false -Message "浏览器停止失败"
                return $false
            }
        } else {
            Record-TestResult -TestName "浏览器启动停止" -Passed $false -Message "浏览器启动失败"
            return $false
        }
    } catch {
        Record-TestResult -TestName "浏览器启动停止" -Passed $false -Message "启动停止测试时出错: $_"
        return $false
    }
}

# 测试3：打开网页
function Test-OpenWebpage {
    param([string]$Url)
    
    Write-Color "=== 测试3：打开网页 ===" -Color "Blue"
    
    try {
        # 确保浏览器运行
        openclaw browser --browser-profile $ProfileName start 2>$null
        Start-Sleep -Seconds 3
        
        # 打开网页
        Write-Info "打开网页: $Url"
        $openResult = openclaw browser --browser-profile $ProfileName open $Url 2>&1
        
        # 等待页面加载
        Start-Sleep -Seconds 3
        
        # 检查标签页
        $tabs = openclaw browser --browser-profile $ProfileName tabs 2>$null
        $urlFound = $tabs -match [regex]::Escape($Url)
        
        if ($urlFound) {
            # 提取标签页ID
            $tabId = $null
            if ($openResult -match "id: (\w+)") {
                $tabId = $matches[1]
            }
            
            $details = @{
                Url = $Url
                OpenResult = $openResult
                TabId = $tabId
                Tabs = $tabs
            }
            
            Record-TestResult -TestName "打开网页" -Passed $true -Message "成功打开网页: $Url" -Details $details
            return $true
        } else {
            Record-TestResult -TestName "打开网页" -Passed $false -Message "打开网页失败: $Url"
            return $false
        }
    } catch {
        Record-TestResult -TestName "打开网页" -Passed $false -Message "打开网页测试时出错: $_"
        return $false
    }
}

# 测试4：截图功能
function Test-Screenshot {
    Write-Color "=== 测试4：截图功能 ===" -Color "Blue"
    
    try {
        Write-Info "进行截图..."
        $screenshotResult = openclaw browser --browser-profile $ProfileName screenshot 2>&1
        
        if ($screenshotResult -match "MEDIA:(.+)") {
            $screenshotPath = $matches[1]
            
            # 检查文件是否存在
            if (Test-Path $screenshotPath) {
                $fileInfo = Get-Item $screenshotPath
                
                $details = @{
                    Path = $screenshotPath
                    Size = "$([math]::Round($fileInfo.Length / 1KB, 2)) KB"
                    Created = $fileInfo.CreationTime
                    ScreenshotResult = $screenshotResult
                }
                
                Record-TestResult -TestName "截图功能" -Passed $true -Message "截图成功" -Details $details
                return $true
            } else {
                Record-TestResult -TestName "截图功能" -Passed $false -Message "截图文件不存在"
                return $false
            }
        } else {
            Record-TestResult -TestName "截图功能" -Passed $false -Message "截图失败"
            return $false
        }
    } catch {
        Record-TestResult -TestName "截图功能" -Passed $false -Message "截图测试时出错: $_"
        return $false
    }
}

# 测试5：页面快照
function Test-PageSnapshot {
    Write-Color "=== 测试5：页面快照 ===" -Color "Blue"
    
    try {
        Write-Info "获取页面快照..."
        $snapshot = openclaw browser --browser-profile $ProfileName snapshot 2>&1
        
        if ($snapshot -and $snapshot.Count -gt 0) {
            $lineCount = ($snapshot -split "`n").Count
            $charCount = $snapshot.Length
            
            # 分析快照内容
            $hasElements = $snapshot -match "\[ref="
            $hasText = $snapshot -match "\w+"
            
            $details = @{
                LineCount = $lineCount
                CharCount = $charCount
                HasElements = $hasElements
                HasText = $hasText
                Sample = ($snapshot -split "`n")[0..4] -join "`n"
            }
            
            Record-TestResult -TestName "页面快照" -Passed $true -Message "获取页面快照成功" -Details $details
            return $true
        } else {
            Record-TestResult -TestName "页面快照" -Passed $false -Message "获取页面快照失败"
            return $false
        }
    } catch {
        Record-TestResult -TestName "页面快照" -Passed $false -Message "页面快照测试时出错: $_"
        return $false
    }
}

# 测试6：性能测试（全面测试时运行）
function Test-Performance {
    param([string]$Url)
    
    Write-Color "=== 测试6：性能测试 ===" -Color "Blue"
    
    $performanceResults = @()
    
    # 测试1：页面加载时间
    try {
        Write-Info "测试页面加载时间..."
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        openclaw browser --browser-profile $ProfileName open $Url 2>$null
        Start-Sleep -Seconds 3  # 等待页面加载
        
        $stopwatch.Stop()
        $loadTime = $stopwatch.ElapsedMilliseconds
        
        $performanceResults += @{
            Test = "页面加载"
            TimeMs = $loadTime
            Status = "完成"
        }
        
        Write-Info "页面加载时间: ${loadTime}ms"
    } catch {
        $performanceResults += @{
            Test = "页面加载"
            TimeMs = 0
            Status = "失败"
            Error = $_.Exception.Message
        }
    }
    
    # 测试2：截图时间
    try {
        Write-Info "测试截图时间..."
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        openclaw browser --browser-profile $ProfileName screenshot 2>$null
        
        $stopwatch.Stop()
        $screenshotTime = $stopwatch.ElapsedMilliseconds
        
        $performanceResults += @{
            Test = "截图"
            TimeMs = $screenshotTime
            Status = "完成"
        }
        
        Write-Info "截图时间: ${screenshotTime}ms"
    } catch {
        $performanceResults += @{
            Test = "截图"
            TimeMs = 0
            Status = "失败"
            Error = $_.Exception.Message
        }
    }
    
    # 测试3：快照时间
    try {
        Write-Info "测试快照时间..."
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        openclaw browser --browser-profile $ProfileName snapshot 2>$null
        
        $stopwatch.Stop()
        $snapshotTime = $stopwatch.ElapsedMilliseconds
        
        $performanceResults += @{
            Test = "快照"
            TimeMs = $snapshotTime
            Status = "完成"
        }
        
        Write-Info "快照时间: ${snapshotTime}ms"
    } catch {
        $performanceResults += @{
            Test = "快照"
            TimeMs = 0
            Status = "失败"
            Error = $_.Exception.Message
        }
    }
    
    # 评估性能结果
    $allPassed = $performanceResults.Where({$_.Status -eq "完成"}).Count -eq $performanceResults.Count
    $avgTime = if ($performanceResults.Where({$_.TimeMs -gt 0}).Count -gt 0) {
        [math]::Round(($performanceResults | Where-Object {$_.TimeMs -gt 0} | Measure-Object -Property TimeMs -Average).Average, 2)
    } else { 0 }
    
    $details = @{
        Results = $performanceResults
        AverageTimeMs = $avgTime
        AllTestsPassed = $allPassed
    }
    
    Record-TestResult -TestName "性能测试" -Passed $allPassed -Message "性能测试完成，平均时间: ${avgTime}ms" -Details $details
    return $allPassed
}

# 主测试函数
function Main {
    Write-Color "=== OpenClaw浏览器工具测试 ===" -Color "Magenta"
    Write-Info "测试URL: $TestUrl"
    Write-Info "配置文件: $ProfileName"
    Write-Info "无头模式: $Headless"
    Write-Info "全面测试: $Comprehensive"
    Write-Info "输出目录: $OutputDir"
    Write-Host ""
    
    # 运行基础测试
    $statusTest = Test-BrowserStatus
    
    if ($statusTest) {
        $startStopTest = Test-BrowserStartStop
        
        if ($startStopTest) {
            # 重新启动浏览器进行后续测试
            openclaw browser --browser-profile $ProfileName start 2>$null
            Start-Sleep -Seconds 3
            
            $openTest = Test-OpenWebpage -Url $TestUrl
            
            if ($openTest) {
                $screenshotTest = Test-Screenshot
                $snapshotTest = Test-PageSnapshot
                
                # 运行性能测试（如果启用全面测试）
                if ($Comprehensive) {
                    $performanceTest = Test-Performance -Url $TestUrl
                } else {
                    Record-TestResult -TestName "性能测试" -Skipped -Message "跳过性能测试（使用-Comprehensive参数启用）"
                }
            }
            
            # 清理：停止浏览器
            openclaw browser --browser-profile $ProfileName stop 2>$null
        }
    }
    
    # 生成测试报告
    Write-Host ""
    Write-Color "=== 测试完成 ===" -Color "Magenta"
    
    $summary = $TestResults.Summary
    $passRate = if ($summary.Total -gt 0) {
        [math]::Round($summary.Passed / $summary.Total * 100, 2)
    } else { 0 }
    
    Write-Info "测试统计:"
    Write-Info "  总计: $($summary.Total)"
    Write-Info "  通过: $($summary.Passed)"
    Write-Info "  失败: $($summary.Failed)"
    Write-Info "  跳过: $($summary.Skipped)"
    Write-Info "  通过率: ${passRate}%"
    
    # 保存测试报告
    Save-TestReport
    
    # 返回退出码
    if ($summary.Failed -gt 0) {
        Write-Error "测试失败，请查看详细报告"
        exit 1
    } else {
        Write-Success "所有测试通过!"
        exit 0
    }
}

# 运行主函数
try {
    Main
} catch {
    Write-Error "测试过程中出现错误: $_"
    Write-Error "错误详情: $($_.ScriptStackTrace)"
    exit 1
}