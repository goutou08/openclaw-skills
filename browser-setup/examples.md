# 浏览器工具使用示例

## 目录
1. [基础使用](#基础使用)
2. [网页自动化](#网页自动化)
3. [数据抓取](#数据抓取)
4. [监控任务](#监控任务)
5. [测试脚本](#测试脚本)
6. [故障排除](#故障排除)

## 基础使用

### 示例1：快速配置
```powershell
# 运行配置脚本
.\scripts\setup-browser.ps1

# 或者使用自定义参数
.\scripts\setup-browser.ps1 -ProfileName "work" -Headless $true -Port 18801 -Color "#0066CC"
```

### 示例2：基础操作
```powershell
# 1. 检查状态
openclaw browser status

# 2. 启动浏览器
openclaw browser start

# 3. 打开网页
openclaw browser open https://www.example.com

# 4. 查看标签页
openclaw browser tabs

# 5. 截图
openclaw browser screenshot

# 6. 获取页面快照
openclaw browser snapshot

# 7. 停止浏览器
openclaw browser stop
```

### 示例3：使用特定配置文件
```powershell
# 使用工作配置文件
openclaw browser --browser-profile work status
openclaw browser --browser-profile work start
openclaw browser --browser-profile work open https://work.example.com

# 使用测试配置文件
openclaw browser --browser-profile test status
openclaw browser --browser-profile test open https://test.example.com
```

## 网页自动化

### 示例1：登录自动化
```powershell
# 自动化登录脚本
function Auto-Login {
    param(
        [string]$LoginUrl,
        [string]$Username,
        [string]$Password
    )
    
    Write-Host "开始自动化登录: $LoginUrl"
    
    # 1. 打开登录页面
    openclaw browser open $LoginUrl
    Start-Sleep -Seconds 2
    
    # 2. 获取交互式快照
    $snapshot = openclaw browser snapshot --interactive
    
    # 3. 查找用户名输入框
    $usernameRef = $snapshot | Where-Object {
        $_ -match "用户名|username|email|账号" -and $_ -match "textbox"
    } | ForEach-Object {
        ($_ -match "\[ref=(\w+)\]") | Out-Null
        $matches[1]
    } | Select-Object -First 1
    
    if ($usernameRef) {
        Write-Host "找到用户名输入框: $usernameRef"
        openclaw browser type $usernameRef $Username
    }
    
    # 4. 查找密码输入框
    $passwordRef = $snapshot | Where-Object {
        $_ -match "密码|password" -and $_ -match "textbox"
    } | ForEach-Object {
        ($_ -match "\[ref=(\w+)\]") | Out-Null
        $matches[1]
    } | Select-Object -First 1
    
    if ($passwordRef) {
        Write-Host "找到密码输入框: $passwordRef"
        openclaw browser type $passwordRef $Password
    }
    
    # 5. 查找登录按钮
    $loginRef = $snapshot | Where-Object {
        $_ -match "登录|login|sign in" -and $_ -match "button"
    } | ForEach-Object {
        ($_ -match "\[ref=(\w+)\]") | Out-Null
        $matches[1]
    } | Select-Object -First 1
    
    if ($loginRef) {
        Write-Host "找到登录按钮: $loginRef"
        openclaw browser click $loginRef
        
        # 等待登录完成
        openclaw browser wait --text "欢迎|dashboard|主页"
        Write-Host "登录成功!"
        
        # 截图记录
        openclaw browser screenshot
    }
}

# 使用示例
Auto-Login -LoginUrl "https://example.com/login" -Username "testuser" -Password "testpass"
```

### 示例2：表单提交
```powershell
# 自动化表单提交
function Submit-ContactForm {
    param(
        [string]$FormUrl,
        [hashtable]$FormData
    )
    
    Write-Host "提交联系表单: $FormUrl"
    
    # 打开表单页面
    openclaw browser open $FormUrl
    Start-Sleep -Seconds 2
    
    # 获取快照
    $snapshot = openclaw browser snapshot --interactive
    
    # 填写表单
    foreach ($field in $FormData.Keys) {
        # 查找对应的输入框
        $fieldRef = $snapshot | Where-Object {
            $_ -match $field -and $_ -match "(textbox|textarea)"
        } | ForEach-Object {
            ($_ -match "\[ref=(\w+)\]") | Out-Null
            $matches[1]
        } | Select-Object -First 1
        
        if ($fieldRef) {
            Write-Host "填写 $field : $($FormData[$field])"
            openclaw browser type $fieldRef $FormData[$field]
            Start-Sleep -Milliseconds 300
        }
    }
    
    # 查找提交按钮
    $submitRef = $snapshot | Where-Object {
        $_ -match "提交|submit|send" -and $_ -match "button"
    } | ForEach-Object {
        ($_ -match "\[ref=(\w+)\]") | Out-Null
        $matches[1]
    } | Select-Object -First 1
    
    if ($submitRef) {
        Write-Host "点击提交按钮"
        openclaw browser click $submitRef
        
        # 等待提交结果
        openclaw browser wait --text "成功|thank you|received"
        Write-Host "表单提交成功!"
        
        # 截图确认
        openclaw browser screenshot
    }
}

# 使用示例
$contactData = @{
    "姓名" = "张三"
    "邮箱" = "zhangsan@example.com"
    "电话" = "13800138000"
    "公司" = "示例公司"
    "留言" = "这是一个测试留言，用于演示OpenClaw浏览器自动化功能。"
}

Submit-ContactForm -FormUrl "https://example.com/contact" -FormData $contactData
```

### 示例3：网页导航和操作
```powershell
# 复杂的网页操作流程
function Complex-WebOperation {
    param(
        [string]$StartUrl
    )
    
    Write-Host "开始复杂网页操作: $StartUrl"
    
    # 1. 打开起始页面
    openclaw browser open $StartUrl
    Start-Sleep -Seconds 2
    
    # 2. 搜索功能
    $snapshot = openclaw browser snapshot --interactive
    
    # 查找搜索框
    $searchRef = $snapshot | Where-Object {
        $_ -match "搜索|search" -and $_ -match "textbox"
    } | ForEach-Object {
        ($_ -match "\[ref=(\w+)\]") | Out-Null
        $matches[1]
    } | Select-Object -First 1
    
    if ($searchRef) {
        Write-Host "执行搜索..."
        openclaw browser type $searchRef "OpenClaw 浏览器自动化"
        openclaw browser press Enter
        
        # 等待搜索结果
        openclaw browser wait --text "搜索结果|search results"
        Start-Sleep -Seconds 2
    }
    
    # 3. 点击第一个结果
    $resultsSnapshot = openclaw browser snapshot --interactive
    $firstResult = $resultsSnapshot | Where-Object {
        $_ -match "link" -and $_ -match "http"
    } | Select-Object -First 1
    
    if ($firstResult -match "\[ref=(\w+)\]") {
        $resultRef = $matches[1]
        Write-Host "点击第一个结果"
        openclaw browser click $resultRef
        
        # 等待新页面加载
        openclaw browser wait --load networkidle
        Start-Sleep -Seconds 2
    }
    
    # 4. 在新页面中操作
    Write-Host "在新页面中操作..."
    
    # 滚动页面
    openclaw browser press "PageDown"
    Start-Sleep -Seconds 1
    openclaw browser press "PageDown"
    
    # 5. 截图记录
    $screenshot = openclaw browser screenshot --full-page
    Write-Host "全屏截图完成"
    
    # 6. 获取页面内容
    $content = openclaw browser snapshot
    $content | Out-File "page_content.txt"
    Write-Host "页面内容已保存"
    
    Write-Host "复杂操作完成!"
}

# 使用示例
Complex-WebOperation -StartUrl "https://www.google.com"
```

## 数据抓取

### 示例1：新闻抓取
```powershell
# 新闻网站数据抓取
function Scrape-News {
    param(
        [string]$NewsUrl,
        [string]$OutputFile = "news_data.json"
    )
    
    Write-Host "开始抓取新闻: $NewsUrl"
    
    # 打开新闻页面
    openclaw browser open $NewsUrl
    Start-Sleep -Seconds 3
    
    # 获取AI快照（结构化数据）
    $snapshot = openclaw browser snapshot --format ai
    
    # 解析新闻数据
    $newsItems = @()
    $currentItem = @{}
    
    $snapshot | ForEach-Object {
        $line = $_.Trim()
        
        # 新闻标题
        if ($line -match "heading \"(.+)\" \[level=[23]\]") {
            if ($currentItem.Count -gt 0) {
                $newsItems += $currentItem.Clone()
                $currentItem.Clear()
            }
            $currentItem["title"] = $matches[1]
            $currentItem["timestamp"] = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        # 新闻链接
        elseif ($line -match "link \"(.+)\".*href=\"(.+)\"") {
            $currentItem["link_text"] = $matches[1]
            $currentItem["link_url"] = $matches[2]
        }
        
        # 新闻摘要
        elseif ($line -match "paragraph.*: (.+)") {
            if (-not $currentItem.ContainsKey("summary")) {
                $currentItem["summary"] = $matches[1]
            } elseif (-not $currentItem.ContainsKey("content")) {
                $currentItem["content"] = $matches[1]
            }
        }
        
        # 发布时间
        elseif ($line -match "time.*: (.+)") {
            $currentItem["publish_time"] = $matches[1]
        }
        
        # 作者信息
        elseif ($line -match "作者|author.*: (.+)") {
            $currentItem["author"] = $matches[1]
        }
    }
    
    # 添加最后一个项目
    if ($currentItem.Count -gt 0) {
        $newsItems += $currentItem
    }
    
    # 保存数据
    $newsItems | ConvertTo-Json -Depth 3 | Set-Content $OutputFile
    
    # 截图记录
    $screenshot = openclaw browser screenshot --full-page
    if ($screenshot -match "MEDIA:(.+)") {
        $newsItems | ForEach-Object {
            $_["screenshot"] = $matches[1]
        }
    }
    
    Write-Host "抓取完成! 共获取 $($newsItems.Count) 条新闻"
    Write-Host "数据已保存到: $OutputFile"
    
    return $newsItems
}

# 使用示例
$newsData = Scrape-News -NewsUrl "https://news.example.com/latest" -OutputFile "latest_news.json"
$newsData | Format-Table -Property title, publish_time, author -AutoSize
```

### 示例2：产品信息抓取
```powershell
# 电商产品信息抓取
function Scrape-Products {
    param(
        [string]$ProductUrl,
        [string]$OutputFile = "products.json"
    )
    
    Write-Host "开始抓取产品信息: $ProductUrl"
    
    # 打开产品页面
    openclaw browser open $ProductUrl
    Start-Sleep -Seconds 3
    
    # 可能需要处理分页
    $allProducts = @()
    $page = 1
    
    do {
        Write-Host "处理第 $page 页..."
        
        # 获取当前页面快照
        $snapshot = openclaw browser snapshot --interactive
        
        # 解析产品信息
        $products = Parse-ProductsFromSnapshot $snapshot
        $allProducts += $products
        
        Write-Host "本页找到 $($products.Count) 个产品"
        
        # 检查是否有下一页
        $nextPageRef = $snapshot | Where-Object {
            $_ -match "下一页|next" -and $_ -match "button|link"
        } | ForEach-Object {
            ($_ -match "\[ref=(\w+)\]") | Out-Null
            $matches[1]
        } | Select-Object -First 1
        
        if ($nextPageRef) {
            Write-Host "点击下一页..."
            openclaw browser click $nextPageRef
            Start-Sleep -Seconds 3
            $page++
        } else {
            Write-Host "没有更多页面"
            break
        }
        
        # 限制最多抓取5页
        if ($page -gt 5) {
            Write-Host "达到最大页数限制"
            break
        }
        
    } while ($true)
    
    # 保存数据
    $allProducts | ConvertTo-Json -Depth 3 | Set-Content $OutputFile
    
    Write-Host "抓取完成! 共获取 $($allProducts.Count) 个产品"
    Write-Host "数据已保存到: $OutputFile"
    
    return $allProducts
}

function Parse-ProductsFromSnapshot {
    param([array]$Snapshot)
    
    $products = @()
    $currentProduct = @{}
    
    $Snapshot | ForEach-Object {
        $line = $_
        
        # 产品名称
        if ($line -match "heading \"(.+)\" \[level=3\]") {
            if ($currentProduct.Count -gt 0) {
                $products += $currentProduct.Clone()
                $currentProduct.Clear()
            }
            $currentProduct["name"] = $matches[1]
        }
        
        # 产品价格
        elseif ($line -match "\\\$(\d+(\.\d+)?)") {
            $currentProduct["price"] = $matches[1]
        } elseif ($line -match "¥(\d+(\.\d+)?)") {
            $currentProduct["price"] = $matches[1]
            $currentProduct["currency"] = "CNY"
        }
        
        # 产品评分
        elseif ($line -match "评分|rating.*: ([\d\.]+)") {
            $currentProduct["rating"] = $matches[1]
        }
        
        # 产品描述
        elseif ($line -match "paragraph.*: (.+)") {
            if (-not $currentProduct.ContainsKey("description")) {
                $currentProduct["description"] = $matches[1]
            }
        }
        
        # 产品图片
        elseif ($line -match "img.*src=\"(.+)\"") {
            $currentProduct["image_url"] = $matches[1]
        }
        
        # 购买链接
        elseif ($line -match "link \"购买|buy\".*href=\"(.+)\"") {
            $currentProduct["buy_url"] = $matches[1]
        }
    }
    
    # 添加最后一个产品
    if ($currentProduct.Count -gt 0) {
        $products += $currentProduct
    }
    
    return $products
}

# 使用示例
$products = Scrape-Products -ProductUrl "https://example.com/products" -OutputFile "products_data.json"
$products | Select-Object -First 5 | Format-Table -Property name, price, rating -AutoSize
```

## 监控任务

### 示例1：网站可用性监控
```powershell
# 网站监控脚本
function Monitor-Website {
    param(
        [string]$Url,
        [string]$CheckName = "网站监控"
    )
    
    $result = @{
        CheckName = $CheckName
        Url = $Url
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Status = "未知"
        ResponseTime = 0
        Screenshot = $null
        Error = $null
    }
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        Write-Host "检查网站: $Url"
        
        # 打开网站
        openclaw browser open $Url
        Start-Sleep -Seconds 5
        
        # 检查页面标题
        $snapshot = openclaw browser snapshot
        $hasContent = $snapshot -match "\w+"  # 检查是否有文本内容
        
        if ($hasContent) {
            $result.Status = "正常"
            
            # 截图记录
            $screenshot = openclaw browser screenshot
            if ($screenshot -match "MEDIA:(.+)") {
                $result.Screenshot = $matches[1]
            }
        } else {
            $result.Status = "异常"
            $result.Error = "页面无内容"
        }
        
    } catch {
        $result.Status = "异常"
        $result.Error = $_.Exception.Message
    } finally {
        $stopwatch.Stop()
        $result.ResponseTime = $stopwatch.ElapsedMilliseconds
        
        # 清理：关闭标签页
        openclaw browser tabs | ForEach-Object {
            if ($_ -match "id: (\w+)" -and $_ -match [regex]::Escape($Url)) {
                $tabId = $matches[1]
                openclaw browser close $tabId
            }
        }
    }
    
    # 输出结果
    Write-Host "检查结果: $($result.Status)"
    Write-Host "响应时间: $($result.ResponseTime)ms"
    if ($result.Error) {
        Write-Host "错误信息: $($result.Error)"
    }
    
    return $result
}

# 批量监控多个网站
function Monitor-Websites {
    param(
        [array]$Urls,
        [string]$OutputFile = "monitoring_report.json"
    )
    
    $results = @()
    
    foreach ($url in $Urls) {
        $checkName = "监控: $url"
        $result = Monitor-Website -Url $url -CheckName $checkName
        $results += $result
        
        # 间隔一下，避免过快
        Start-Sleep -Seconds 2
    }
    
    # 保存监控报告
    $results | ConvertTo-Json -Depth 3 | Set-Content $OutputFile
    
    # 生成摘要
    $total = $results.Count
    $normal = ($results | Where-Object {$_.Status -eq "正常"}).Count
    $abnormal = ($results | Where-Object {$_.Status -eq "异常"}).Count
    $avgTime = [math]::Round(($results | Measure-Object -Property ResponseTime -Average).Average, 2)
    
    Write-Host "=== 监控摘要 ==="
    Write-Host "总计检查: $total"
    Write-Host "正常: $normal"
    Write-Host "异常: $abnormal"
    Write-Host "平均响应时间: ${avgTime}ms"
    
    # 如果有异常，发出警告
    if ($abnormal -gt 0) {
        $abnormalUrls = $results | Where-Object {$_.Status -eq "异常"} | ForEach-Object {$_.Url}
        Write-Host "警告! 以下网站异常: $($abnormalUrls -join ', ')"
    }
    
    return $results
}

# 使用示例
$websites = @(
    "https://www.example.com",
    "https://www.google.com",
    "https://github.com",
    "https://news.ycombinator.com"
)

$monitoringResults = Monitor-Websites -Urls $websites -OutputFile "website_monitoring.json"
$monitoringResults | Format-Table -Property CheckName, Status, ResponseTime -AutoSize