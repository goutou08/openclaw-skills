## 测试脚本

### 示例1：运行完整测试
```powershell
# 运行基础测试
.\scripts\test-browser.ps1

# 运行全面测试
.\scripts\test-browser.ps1 -Comprehensive

# 在特定URL上测试
.\scripts\test-browser.ps1 -TestUrl "https://news.ycombinator.com" -Comprehensive

# 在无头模式下测试
.\scripts\test-browser.ps1 -Headless -OutputDir ".\test-results"
```

### 示例2：自定义测试套件
```powershell
# 自定义测试脚本
function Run-CustomTests {
    param(
        [string]$TestSuite = "basic"
    )
    
    Write-Host "运行自定义测试套件: $TestSuite"
    
    $tests = @()
    
    switch ($TestSuite) {
        "basic" {
            $tests = @(
                "Test-BrowserStatus",
                "Test-BrowserStartStop",
                "Test-OpenWebpage -Url 'https://www.example.com'",
                "Test-Screenshot",
                "Test-PageSnapshot"
            )
        }
        "advanced" {
            $tests = @(
                "Test-BrowserStatus",
                "Test-Performance -Url 'https://www.example.com'",
                "Test-FormSubmission",
                "Test-Navigation",
                "Test-DataExtraction"
            )
        }
        "monitoring" {
            $tests = @(
                "Test-WebsiteMonitoring -Url 'https://www.example.com'",
                "Test-AlertSystem",
                "Test-ReportGeneration"
            )
        }
    }
    
    $results = @()
    foreach ($test in $tests) {
        Write-Host "运行测试: $test"
        try {
            Invoke-Expression $test
            $results += @{Test = $test; Status = "通过"}
        } catch {
            $results += @{Test = $test; Status = "失败"; Error = $_}
        }
    }
    
    # 生成测试报告
    $report = @{
        TestSuite = $TestSuite
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Results = $results
        Summary = @{
            Total = $results.Count
            Passed = ($results | Where-Object {$_.Status -eq "通过"}).Count
            Failed = ($results | Where-Object {$_.Status -eq "失败"}).Count
        }
    }
    
    $report | ConvertTo-Json -Depth 3 | Set-Content "custom_test_report.json"
    
    Write-Host "测试完成!"
    Write-Host "通过: $($report.Summary.Passed)/$($report.Summary.Total)"
    
    return $report
}

# 使用示例
$basicReport = Run-CustomTests -TestSuite "basic"
$advancedReport = Run-CustomTests -TestSuite "advanced"
```

## 故障排除

### 常见问题1：浏览器无法启动
```powershell
# 诊断脚本
function Diagnose-BrowserStartupIssue {
    Write-Host "=== 浏览器启动问题诊断 ==="
    
    # 1. 检查Chrome安装
    Write-Host "1. 检查Chrome安装..."
    $chromePaths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )
    
    $chromeFound = $false
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            Write-Host "   ✅ 找到Chrome: $path"
            $chromeFound = $true
            break
        }
    }
    
    if (-not $chromeFound) {
        Write-Host "   ❌ 未找到Chrome"
        Write-Host "      解决方案: 安装Google Chrome浏览器"
        return $false
    }
    
    # 2. 检查端口占用
    Write-Host "2. 检查端口占用..."
    $port = 18800
    $portInUse = netstat -ano | findstr ":$port"
    
    if ($portInUse) {
        Write-Host "   ⚠️  端口 $port 被占用"
        $pid = ($portInUse -split "\s+")[-1]
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "       占用进程: $($process.ProcessName) (PID: $pid)"
        }
        Write-Host "      解决方案: 修改browser.profiles.openclaw.cdpPort配置"
    } else {
        Write-Host "   ✅ 端口 $port 可用"
    }
    
    # 3. 检查配置文件
    Write-Host "3. 检查配置文件..."
    $config = openclaw config get browser 2>$null
    if ($config) {
        Write-Host "   ✅ 浏览器配置存在"
    } else {
        Write-Host "   ❌ 浏览器配置不存在"
        Write-Host "      解决方案: 运行配置脚本 .\scripts\setup-browser.ps1"
        return $false
    }
    
    # 4. 检查插件状态
    Write-Host "4. 检查插件状态..."
    $plugin = openclaw config get plugins.entries.browser 2>$null
    if ($plugin -and $plugin.enabled -eq $true) {
        Write-Host "   ✅ 浏览器插件已启用"
    } else {
        Write-Host "   ❌ 浏览器插件未启用"
        Write-Host "      解决方案: openclaw config set plugins.entries.browser.enabled true"
        return $false
    }
    
    # 5. 尝试启动并捕获错误
    Write-Host "5. 尝试启动浏览器..."
    try {
        $result = openclaw browser start 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ 浏览器启动成功"
            Start-Sleep -Seconds 3
            
            $status = openclaw browser status
            if ($status -match "running: true") {
                Write-Host "   ✅ 浏览器运行正常"
                return $true
            } else {
                Write-Host "   ⚠️  浏览器启动但状态异常"
                return $false
            }
        } else {
            Write-Host "   ❌ 浏览器启动失败"
            Write-Host "      错误信息: $result"
            return $false
        }
    } catch {
        Write-Host "   ❌ 启动过程中出现异常"
        Write-Host "      异常信息: $_"
        return $false
    }
}

# 运行诊断
Diagnose-BrowserStartupIssue
```

### 常见问题2：CDP连接失败
```powershell
# CDP连接诊断
function Diagnose-CdpConnectionIssue {
    param(
        [int]$Port = 18800
    )
    
    Write-Host "=== CDP连接问题诊断 ==="
    
    # 1. 测试本地连接
    Write-Host "1. 测试本地CDP连接..."
    $connection = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -InformationLevel Quiet
    if ($connection) {
        Write-Host "   ✅ 本地CDP连接正常"
    } else {
        Write-Host "   ❌ 本地CDP连接失败"
        
        # 检查浏览器是否运行
        $status = openclaw browser status 2>$null
        if ($status -match "running: false") {
            Write-Host "       浏览器未运行，请先启动浏览器"
        }
        return $false
    }
    
    # 2. 检查CDP端点
    Write-Host "2. 检查CDP端点..."
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/json/version" -TimeoutSec 3
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ CDP端点响应正常"
            $cdpInfo = $response.Content | ConvertFrom-Json
            Write-Host "       浏览器: $($cdpInfo.Browser)"
            Write-Host "       协议版本: $($cdpInfo.'Protocol-Version')"
        }
    } catch {
        Write-Host "   ❌ CDP端点无响应"
        Write-Host "       错误: $_"
        return $false
    }
    
    # 3. 检查防火墙
    Write-Host "3. 检查防火墙设置..."
    $firewallRule = Get-NetFirewallRule -DisplayName "*OpenClaw*" -ErrorAction SilentlyContinue
    if ($firewallRule) {
        Write-Host "   ⚠️  找到OpenClaw防火墙规则"
        foreach ($rule in $firewallRule) {
            Write-Host "       规则: $($rule.DisplayName), 状态: $($rule.Enabled)"
        }
    } else {
        Write-Host "   ✅ 无相关防火墙规则限制"
    }
    
    return $true
}

# 运行诊断
Diagnose-CdpConnectionIssue -Port 18800
```

### 常见问题3：页面操作失败
```powershell
# 页面操作诊断
function Diagnose-PageActionIssue {
    param(
        [string]$Url = "https://www.example.com"
    )
    
    Write-Host "=== 页面操作问题诊断 ==="
    
    # 1. 打开测试页面
    Write-Host "1. 打开测试页面..."
    openclaw browser open $Url
    Start-Sleep -Seconds 2
    
    # 2. 获取快照
    Write-Host "2. 获取页面快照..."
    $snapshot = openclaw browser snapshot --interactive
    Write-Host "   获取到 $($snapshot.Count) 行快照"
    
    # 3. 检查交互元素
    Write-Host "3. 检查交互元素..."
    $interactiveElements = $snapshot | Where-Object {
        $_ -match "button|link|textbox|checkbox|radio"
    }
    Write-Host "   找到 $($interactiveElements.Count) 个交互元素"
    
    if ($interactiveElements.Count -eq 0) {
        Write-Host "   ⚠️  未找到交互元素，尝试获取完整快照..."
        $fullSnapshot = openclaw browser snapshot
        Write-Host "   完整快照行数: $($fullSnapshot.Count)"
    }
    
    # 4. 测试截图
    Write-Host "4. 测试截图功能..."
    $screenshot = openclaw browser screenshot
    if ($screenshot -match "MEDIA:(.+)") {
        Write-Host "   ✅ 截图成功: $($matches[1])"
    } else {
        Write-Host "   ❌ 截图失败"
    }
    
    # 5. 测试元素高亮
    Write-Host "5. 测试元素高亮..."
    if ($interactiveElements.Count -gt 0) {
        $firstRef = $interactiveElements[0] -match "\[ref=(\w+)\]"
        if ($matches) {
            $ref = $matches[1]
            Write-Host "   高亮元素: $ref"
            openclaw browser highlight $ref
            Write-Host "   ✅ 元素高亮测试完成"
        }
    }
    
    Write-Host "诊断完成!"
    return @{
        SnapshotLines = $snapshot.Count
        InteractiveElements = $interactiveElements.Count
        ScreenshotSuccess = ($screenshot -match "MEDIA:")
    }
}

# 运行诊断
Diagnose-PageActionIssue
```

### 常见问题4：内存泄漏或性能问题
```powershell
# 性能问题诊断
function Diagnose-PerformanceIssue {
    Write-Host "=== 性能问题诊断 ==="
    
    # 1. 检查浏览器进程
    Write-Host "1. 检查浏览器进程..."
    $chromeProcesses = Get-Process -Name chrome -ErrorAction SilentlyContinue | 
        Where-Object {$_.CommandLine -like "*openclaw*"}
    
    if ($chromeProcesses) {
        Write-Host "   找到 $($chromeProcesses.Count) 个OpenClaw相关的Chrome进程"
        
        foreach ($process in $chromeProcesses) {
            $memoryMB = [math]::Round($process.WorkingSet64 / 1MB, 2)
            $cpu = $process.CPU
            Write-Host "       PID: $($process.Id), 内存: ${memoryMB}MB, CPU: ${cpu}%"
        }
        
        $totalMemory = [math]::Round(($chromeProcesses | Measure-Object -Property WorkingSet64 -Sum).Sum / 1MB, 2)
        Write-Host "   总内存使用: ${totalMemory}MB"
        
        if ($totalMemory -gt 1000) {
            Write-Host "   ⚠️  内存使用过高，建议重启浏览器"
        }
    } else {
        Write-Host "   ✅ 没有找到相关的Chrome进程"
    }
    
    # 2. 检查系统资源
    Write-Host "2. 检查系统资源..."
    $availableMemory = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB
    $totalMemory = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1MB
    $memoryUsage = [math]::Round(($totalMemory - $availableMemory) / $totalMemory * 100, 2)
    
    Write-Host "   总内存: ${totalMemory}MB"
    Write-Host "   可用内存: ${availableMemory}MB"
    Write-Host "   内存使用率: ${memoryUsage}%"
    
    if ($availableMemory -lt 500) {
        Write-Host "   ⚠️  可用内存不足，建议关闭不必要的程序"
    }
    
    # 3. 检查磁盘空间
    Write-Host "3. 检查磁盘空间..."
    $disk = Get-PSDrive C
    $freeGB = [math]::Round($disk.Free / 1GB, 2)
    $usedGB = [math]::Round($disk.Used / 1GB, 2)
    $freePercent = [math]::Round($disk.Free / $disk.Used * 100, 2)
    
    Write-Host "   已用空间: ${usedGB}GB"
    Write-Host "   可用空间: ${freeGB}GB"
    Write-Host "   可用百分比: ${freePercent}%"
    
    if ($freeGB -lt 5) {
        Write-Host "   ⚠️  磁盘空间不足，建议清理临时文件"
    }
    
    # 4. 建议的优化措施
    Write-Host "4. 优化建议..."
    Write-Host "   • 定期重启浏览器: openclaw browser stop && openclaw browser start"
    Write-Host "   • 清理临时文件: Remove-Item ~\AppData\Local\Temp\openclaw\* -Recurse -Force"
    Write-Host "   • 使用无头模式: 设置 browser.headless = true"
    Write-Host "   • 限制标签页数量: 避免同时打开过多标签页"
    
    return @{
        ChromeProcesses = $chromeProcesses.Count
        TotalMemoryUsageMB = $totalMemory
        AvailableMemoryMB = $availableMemory
        MemoryUsagePercent = $memoryUsage
        DiskFreeGB = $freeGB
        DiskFreePercent = $freePercent
    }
}

# 运行诊断
$performanceInfo = Diagnose-PerformanceIssue
$performanceInfo | Format-List
```

## 最佳实践总结

### 1. 配置管理
```powershell
# 备份配置
function Backup-BrowserConfig {
    $backupDir = ".\config-backups"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    $backupFile = Join-Path $backupDir "openclaw-browser_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    openclaw config get browser | Set-Content $backupFile
    
    Write-Host "配置已备份到: $backupFile"
}

# 恢复配置
function Restore-BrowserConfig {
    param([string]$BackupFile)
    
    if (Test-Path $BackupFile) {
        $config = Get-Content $BackupFile | ConvertFrom-Json
        foreach ($key in $config.PSObject.Properties.Name) {
            $value = $config.$key
            openclaw config set "browser.$key" $value
        }
        
        Write-Host "配置已从 $BackupFile 恢复"
        openclaw gateway restart
    } else {
        Write-Error "备份文件不存在: $BackupFile"
    }
}
```

### 2. 监控和维护
```powershell
# 定期维护脚本
function Perform-BrowserMaintenance {
    Write-Host "=== 浏览器维护 ==="
    
    # 1. 停止浏览器
    Write-Host "1. 停止浏览器..."
    openclaw browser stop
    Start-Sleep -Seconds 3
    
    # 2. 清理临时文件
    Write-Host "2. 清理临时文件..."
    $tempDirs = @(
        "$env:TEMP\openclaw",
        "$env:LOCALAPPDATA\Temp\openclaw",
        ".\browser-test-results",
        ".\browser-logs"
    )
    
    foreach ($dir in $tempDirs) {
        if (Test-Path $dir) {
            Remove-Item "$dir\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   清理: $dir"
        }
    }
    
    # 3. 重启浏览器
    Write-Host "3. 重启浏览器..."
    openclaw browser start
    Start-Sleep -Seconds 5
    
    # 4. 验证