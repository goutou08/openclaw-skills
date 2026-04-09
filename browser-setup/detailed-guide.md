# 浏览器工具详细配置指南

## 目录
1. [环境准备](#环境准备)
2. [逐步配置](#逐步配置)
3. [配置文件详解](#配置文件详解)
4. [使用示例](#使用示例)
5. [故障排除](#故障排除)
6. [高级功能](#高级功能)
7. [安全考虑](#安全考虑)
8. [性能优化](#性能优化)

## 环境准备

### 系统要求
- **操作系统**: Windows 10/11, macOS 10.15+, Linux (Ubuntu 20.04+)
- **OpenClaw版本**: 2026.4.2+
- **浏览器**: Chrome 120+, Brave, Edge, Chromium
- **内存**: 至少4GB可用内存
- **磁盘空间**: 至少2GB可用空间

### 前置检查
```bash
# 检查OpenClaw版本
openclaw --version

# 检查Chrome是否安装
where chrome
where google-chrome

# 检查系统资源
systeminfo | findstr /C:"可用物理内存"

# 检查网络连接
Test-NetConnection -ComputerName www.google.com -Port 443
```

## 逐步配置

### 第1步：基础配置检查
```bash
# 查看当前配置
openclaw config get browser
openclaw config get plugins.entries.browser

# 如果配置不存在，进行初始化
if (-not (openclaw config get browser 2>$null)) {
    Write-Host "浏览器配置不存在，开始初始化..."
}
```

### 第2步：启用浏览器插件
```bash
# 方法1：使用CLI命令
openclaw config set plugins.entries.browser.enabled true

# 方法2：手动编辑配置文件
$configPath = "~\.openclaw\openclaw.json"
$config = Get-Content $configPath | ConvertFrom-Json
if (-not $config.plugins.entries.browser) {
    $config.plugins.entries | Add-Member -NotePropertyName "browser" -NotePropertyValue @{enabled=$true}
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
}
```

### 第3步：配置浏览器参数
```powershell
# 批量配置命令
$browserConfig = @{
    "browser.enabled" = $true
    "browser.defaultProfile" = "openclaw"
    "browser.headless" = $false
    "browser.color" = "#FF4500"
    "browser.ssrfPolicy.dangerouslyAllowPrivateNetwork" = $true
}

foreach ($key in $browserConfig.Keys) {
    $value = $browserConfig[$key]
    openclaw config set $key $value
    Write-Host "已配置: $key = $value"
}
```

### 第4步：配置浏览器配置文件
```powershell
# 配置openclaw配置文件
$profileConfig = @{
    "browser.profiles.openclaw.cdpPort" = 18800
    "browser.profiles.openclaw.color" = "#FF4500"
}

foreach ($key in $profileConfig.Keys) {
    $value = $profileConfig[$key]
    openclaw config set $key $value
    Write-Host "已配置: $key = $value"
}

# 可选：添加其他配置文件
$additionalProfiles = @{
    "work" = @{cdpPort=18801; color="#0066CC"}
    "test" = @{cdpPort=18802; color="#00AA00"}
}

foreach ($profileName in $additionalProfiles.Keys) {
    $profile = $additionalProfiles[$profileName]
    openclaw config set "browser.profiles.$profileName.cdpPort" $profile.cdpPort
    openclaw config set "browser.profiles.$profileName.color" $profile.color
    Write-Host "已添加配置文件: $profileName"
}
```

### 第5步：应用配置
```bash
# 重启网关服务
openclaw gateway restart

# 等待服务启动
Start-Sleep -Seconds 10

# 验证网关状态
openclaw gateway status
```

### 第6步：验证配置
```powershell
# 验证配置脚本
function Test-BrowserConfig {
    Write-Host "=== 浏览器配置验证 ==="
    
    # 1. 检查配置
    Write-Host "1. 检查浏览器配置..."
    $browserConfig = openclaw config get browser 2>$null
    if ($browserConfig) {
        Write-Host "   ✅ 浏览器配置存在"
    } else {
        Write-Host "   ❌ 浏览器配置不存在"
        return $false
    }
    
    # 2. 检查插件
    Write-Host "2. 检查浏览器插件..."
    $pluginConfig = openclaw config get plugins.entries.browser 2>$null
    if ($pluginConfig -and $pluginConfig.enabled -eq $true) {
        Write-Host "   ✅ 浏览器插件已启用"
    } else {
        Write-Host "   ❌ 浏览器插件未启用"
        return $false
    }
    
    # 3. 检查浏览器状态
    Write-Host "3. 检查浏览器状态..."
    $status = openclaw browser status 2>$null
    if ($status -and $status -match "enabled: true") {
        Write-Host "   ✅ 浏览器功能已启用"
    } else {
        Write-Host "   ❌ 浏览器功能未启用"
        return $false
    }
    
    Write-Host "=== 所有检查通过 ==="
    return $true
}

# 运行验证
Test-BrowserConfig
```

## 配置文件详解

### 完整配置示例
```json
{
  "plugins": {
    "entries": {
      "browser": {
        "enabled": true,
        "config": {
          // 插件特定配置
        }
      }
    }
  },
  "browser": {
    // 基础设置
    "enabled": true,
    "defaultProfile": "openclaw",
    "headless": false,
    "color": "#FF4500",
    
    // SSRF安全策略
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": true,
      "hostnameAllowlist": [],
      "allowedHostnames": []
    },
    
    // 连接设置
    "remoteCdpTimeoutMs": 1500,
    "remoteCdpHandshakeTimeoutMs": 3000,
    
    // 浏览器路径（自动检测，可手动指定）
    "executablePath": "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
    
    // 高级设置
    "noSandbox": false,
    "attachOnly": false,
    "evaluateEnabled": true,
    
    // 快照默认设置
    "snapshotDefaults": {
      "mode": "efficient",
      "maxChars": 50000
    },
    
    // 配置文件
    "profiles": {
      "openclaw": {
        "cdpPort": 18800,
        "color": "#FF4500",
        "driver": "cdp"
      },
      "work": {
        "cdpPort": 18801,
        "color": "#0066CC",
        "driver": "cdp"
      },
      "user": {
        "driver": "existing-session",
        "attachOnly": true,
        "color": "#00AA00"
      },
      "remote": {
        "cdpUrl": "http://192.168.1.100:9222",
        "color": "#FF9900"
      }
    }
  }
}
```

### 配置项说明

#### 1. 插件配置 (`plugins.entries.browser`)
- **enabled**: 是否启用浏览器插件
- **config**: 插件特定配置（通常为空）

#### 2. 基础设置
- **enabled**: 启用/禁用浏览器功能
- **defaultProfile**: 默认使用的配置文件
- **headless**: 无头模式（true=无界面，false=显示界面）
- **color**: 浏览器界面主题颜色

#### 3. 安全策略 (`ssrfPolicy`)
- **dangerouslyAllowPrivateNetwork**: 是否允许访问私有网络
- **hostnameAllowlist**: 主机名白名单（支持通配符）
- **allowedHostnames**: 允许的主机名列表

#### 4. 连接设置
- **remoteCdpTimeoutMs**: 远程CDP连接超时（毫秒）
- **remoteCdpHandshakeTimeoutMs**: 远程CDP握手超时（毫秒）

#### 5. 配置文件 (`profiles`)
每个配置文件包含：
- **cdpPort**: CDP调试端口（本地配置文件）
- **cdpUrl**: CDP连接URL（远程配置文件）
- **color**: 配置文件颜色
- **driver**: 驱动类型（cdp/existing-session）
- **attachOnly**: 仅附加模式（不启动新浏览器）

## 使用示例

### 示例1：基础网页操作
```powershell
# 自动化测试脚本
function Test-Webpage {
    param(
        [string]$Url = "https://www.example.com"
    )
    
    Write-Host "开始测试网页: $Url"
    
    # 1. 打开网页
    Write-Host "1. 打开网页..."
    $result = openclaw browser open $Url
    $tabId = ($result -split "`n" | Where-Object {$_ -match "id:"} | ForEach-Object {($_ -split ":")[1].Trim()})[0]
    Write-Host "   标签页ID: $tabId"
    
    # 2. 等待页面加载
    Write-Host "2. 等待页面加载..."
    Start-Sleep -Seconds 3
    
    # 3. 获取页面快照
    Write-Host "3. 获取页面快照..."
    $snapshot = openclaw browser snapshot --interactive
    Write-Host "   快照行数: $($snapshot.Count)"
    
    # 4. 查找特定元素
    Write-Host "4. 查找链接元素..."
    $links = $snapshot | Where-Object {$_ -match "link"}
    Write-Host "   找到链接数: $($links.Count)"
    
    # 5. 截图保存
    Write-Host "5. 截图保存..."
    $screenshot = openclaw browser screenshot
    if ($screenshot -match "MEDIA:(.+)") {
        $screenshotPath = $matches[1]
        Write-Host "   截图保存到: $screenshotPath"
    }
    
    Write-Host "测试完成!"
    return @{
        TabId = $tabId
        LinksFound = $links.Count
        ScreenshotPath = $screenshotPath
    }
}

# 运行测试
Test-Webpage -Url "https://www.example.com"
```

### 示例2：表单自动化
```powershell
# 表单填写示例
function Submit-Form {
    param(
        [string]$Url = "https://example.com/form",
        [hashtable]$FormData
    )
    
    Write-Host "开始表单提交: $Url"
    
    # 1. 打开表单页面
    openclaw browser open $Url
    Start-Sleep -Seconds 2
    
    # 2. 获取交互式快照
    $snapshot = openclaw browser snapshot --interactive
    
    # 3. 填写表单字段
    foreach ($field in $FormData.Keys) {
        # 查找输入框
        $inputRef = $snapshot | Where-Object {$_ -match $field -and $_ -match "textbox"} | 
                    ForEach-Object {($_ -match "\[ref=(\w+)\]") | Out-Null; $matches[1]}
        
        if ($inputRef) {
            Write-Host "   填写字段: $field"
            openclaw browser type $inputRef $FormData[$field]
            Start-Sleep -Milliseconds 500
        }
    }
    
    # 4. 查找提交按钮
    $submitRef = $snapshot | Where-Object {$_ -match "button" -and $_ -match "提交|Submit"} |
                 ForEach-Object {($_ -match "\[ref=(\w+)\]") | Out-Null; $matches[1]}
    
    if ($submitRef) {
        Write-Host "   点击提交按钮"
        openclaw browser click $submitRef
    }
    
    # 5. 等待提交完成
    Write-Host "   等待提交完成..."
    openclaw browser wait --text "提交成功|Success"
    
    Write-Host "表单提交完成!"
}

# 使用示例
$formData = @{
    "姓名" = "张三"
    "邮箱" = "zhangsan@example.com"
    "电话" = "13800138000"
    "留言" = "测试留言内容"
}

Submit-Form -Url "https://example.com/contact" -FormData $formData
```

### 示例3：数据抓取
```powershell
# 数据抓取脚本
function Scrape-Data {
    param(
        [string]$Url,
        [string]$OutputFile = "scraped_data.json"
    )
    
    Write-Host "开始数据抓取: $Url"
    
    # 1. 打开目标页面
    openclaw browser open $Url
    Start-Sleep -Seconds 3
    
    # 2. 获取AI快照（包含结构化数据）
    $snapshot = openclaw browser snapshot --format ai
    
    # 3. 解析数据
    $data = @()
    $currentItem = @{}
    
    $snapshot | ForEach-Object {
        $line = $_.Trim()
        
        # 解析标题
        if ($line -match "heading \"(.+)\"") {
            if ($currentItem.Count -gt 0) {
                $data += $currentItem.Clone()
                $currentItem.Clear()
            }
            $currentItem["title"] = $matches[1]
        }
        
        # 解析链接
        elseif ($line -match "link \"(.+)\".*href=\"(.+)\"") {
            $currentItem["link_text"] = $matches[1]
            $currentItem["link_url"] = $matches[2]
        }
        
        # 解析描述
        elseif ($line -match "paragraph.*: (.+)") {
            if (-not $currentItem.ContainsKey("description")) {
                $currentItem["description"] = $matches[1]
            }
        }
    }
    
    # 添加最后一个项目
    if ($currentItem.Count -gt 0) {
        $data += $currentItem
    }
    
    # 4. 保存数据
    $data | ConvertTo-Json -Depth 3 | Set-Content $OutputFile
    Write-Host "数据已保存到: $OutputFile"
    Write-Host "抓取到 $($data.Count) 条记录"
    
    # 5. 截图记录
    $screenshot = openclaw browser screenshot --full-page
    if ($screenshot -match "MEDIA:(.+)") {
        Write-Host "全屏截图: $($matches[1])"
    }
    
    return $data
}

# 使用示例
$scrapedData = Scrape-Data -Url "https://news.example.com" -OutputFile "news_data.json"
$scrapedData | Format-Table -AutoSize
```

## 故障排除

### 问题1：浏览器无法启动
```powershell
# 诊断脚本
function Diagnose-BrowserStartup {
    Write-Host "=== 浏览器启动问题诊断 ==="
    
    # 1. 检查Chrome安装
    Write-Host "1. 检查Chrome安装..."
    $chromePaths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )
    
    $found = $false
    foreach ($path in $chromePaths) {
        if (Test-Path $path) {
            Write-Host "   ✅ 找到Chrome: $path"
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        Write-Host "   ❌ 未找到Chrome，请安装Chrome浏览器"
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
        return $false
    }
    
    # 4. 检查插件状态
    Write-Host "4. 检查插件状态..."
    $plugin = openclaw config get plugins.entries.browser 2>$null
    if ($plugin -and $plugin.enabled -eq $true) {
        Write-Host "   ✅ 浏览器插件已启用"
    } else {
        Write-Host "   ❌ 浏览器插件未启用"
        return $false
    }
    
    # 5. 尝试启动
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
Diagnose-BrowserStartup