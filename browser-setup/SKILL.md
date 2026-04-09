---
name: browser-setup
description: OpenClaw 浏览器工具配置与使用指南。当需要配置或使用OpenClaw管理的浏览器进行网页自动化、数据抓取、测试等任务时激活此技能。
---

# 浏览器工具配置与使用指南

## 概述
专门用于配置和使用OpenClaw管理的浏览器工具。提供从基础配置到高级使用的完整指南，包括故障排除和最佳实践。

## 核心原则

### 1. 安全第一
- 浏览器在隔离环境中运行
- 配置适当的SSRF策略
- 避免暴露敏感信息

### 2. 实用导向
- 提供具体的配置命令
- 包含实际使用示例
- 解决常见问题

### 3. 可复用性
- 模块化配置步骤
- 可复用的代码片段
- 跨平台兼容性说明

## 快速开始

### 基础配置
```bash
# 1. 启用浏览器插件
openclaw config set plugins.entries.browser.enabled true

# 2. 启用浏览器功能
openclaw config set browser.enabled true

# 3. 设置默认配置文件
openclaw config set browser.defaultProfile "openclaw"

# 4. 配置显示模式（false为显示界面，true为无头模式）
openclaw config set browser.headless false

# 5. 配置颜色主题
openclaw config set browser.color "#FF4500"

# 6. 配置SSRF策略（允许私有网络访问）
openclaw config set browser.ssrfPolicy.dangerouslyAllowPrivateNetwork true

# 7. 配置openclaw配置文件
openclaw config set browser.profiles.openclaw.cdpPort 18800
openclaw config set browser.profiles.openclaw.color "#FF4500"

# 8. 重启网关应用配置
openclaw gateway restart
```

### 快速验证
```bash
# 检查浏览器状态
openclaw browser status

# 启动浏览器
openclaw browser start

# 打开测试网页
openclaw browser open https://www.example.com

# 查看标签页
openclaw browser tabs

# 测试截图
openclaw browser screenshot

# 测试页面快照
openclaw browser snapshot
```

## 详细配置指南

### 完整配置文件示例
```json
{
  "plugins": {
    "entries": {
      "browser": {
        "enabled": true
      }
    }
  },
  "browser": {
    "enabled": true,
    "defaultProfile": "openclaw",
    "headless": false,
    "color": "#FF4500",
    "ssrfPolicy": {
      "dangerouslyAllowPrivateNetwork": true
    },
    "profiles": {
      "openclaw": {
        "cdpPort": 18800,
        "color": "#FF4500"
      }
    }
  }
}
```

### 配置文件说明
- **plugins.entries.browser.enabled**: 启用浏览器插件
- **browser.enabled**: 启用浏览器功能
- **browser.defaultProfile**: 默认使用的浏览器配置文件
- **browser.headless**: 是否使用无头模式（true=无界面，false=显示界面）
- **browser.color**: 浏览器界面主题颜色
- **browser.ssrfPolicy.dangerouslyAllowPrivateNetwork**: SSRF安全策略，true允许访问私有网络
- **browser.profiles.openclaw**: openclaw配置文件设置

## 使用场景

### 场景1：网页自动化测试
```bash
# 打开目标网站
openclaw browser open https://target-site.com

# 等待页面加载
Start-Sleep -Seconds 3

# 获取页面快照
openclaw browser snapshot --interactive

# 执行点击操作（使用快照中的ref）
openclaw browser click e12

# 输入文本
openclaw browser type e23 "搜索关键词"

# 提交表单
openclaw browser press Enter
```

### 场景2：数据抓取
```bash
# 打开数据页面
openclaw browser open https://data-source.com/report

# 获取完整页面内容
openclaw browser snapshot --format ai

# 保存页面为PDF
openclaw browser pdf

# 截取全屏截图
openclaw browser screenshot --full-page
```

### 场景3：监控任务
```bash
# 定期检查网站状态
openclaw cron add \
  --name "website-monitor" \
  --schedule "every 1h" \
  --payload '{"kind":"agentTurn","message":"检查目标网站状态，打开https://target-site.com，截图并保存"}' \
  --sessionTarget isolated \
  --delivery '{"mode":"announce"}'
```

## CLI命令参考

### 基础操作
```bash
# 状态管理
openclaw browser status
openclaw browser start
openclaw browser stop

# 标签页管理
openclaw browser tabs
openclaw browser open <url>
openclaw browser focus <tab-id>
openclaw browser close <tab-id>

# 页面操作
openclaw browser navigate <url>
openclaw browser refresh
openclaw browser back
openclaw browser forward
```

### 内容获取
```bash
# 截图
openclaw browser screenshot
openclaw browser screenshot --full-page
openclaw browser screenshot --ref <element-ref>

# 页面快照
openclaw browser snapshot
openclaw browser snapshot --interactive
openclaw browser snapshot --format aria
openclaw browser snapshot --efficient

# PDF导出
openclaw browser pdf
```

### 自动化操作
```bash
# 元素操作
openclaw browser click <ref>
openclaw browser type <ref> "文本内容"
openclaw browser hover <ref>
openclaw browser scrollintoview <ref>

# 键盘操作
openclaw browser press Enter
openclaw browser press Tab
openclaw browser press "Control+A"

# 等待操作
openclaw browser wait --text "加载完成"
openclaw browser wait --url "**/dashboard"
openclaw browser wait --load networkidle
```

### 调试工具
```bash
# 控制台日志
openclaw browser console --level error
openclaw browser console --level warning

# 网络请求
openclaw browser requests --filter api
openclaw browser requests --clear

# 性能追踪
openclaw browser trace start
openclaw browser trace stop
```

## 故障排除

### 常见问题1：浏览器无法启动
```bash
# 检查Chrome是否安装
where chrome
where google-chrome

# 检查配置文件
openclaw config get browser
openclaw config get plugins.entries.browser

# 查看日志
openclaw logs --tail 20 | findstr browser
```

### 常见问题2：CDP连接失败
```bash
# 检查端口占用
netstat -ano | findstr :18800

# 测试CDP连接
Test-NetConnection -ComputerName 127.0.0.1 -Port 18800

# 重启浏览器服务
openclaw browser stop
Start-Sleep -Seconds 3
openclaw browser start
```

### 常见问题3：页面操作失败
```bash
# 重新获取快照
openclaw browser snapshot --interactive

# 高亮显示元素
openclaw browser highlight <ref>

# 检查元素可见性
openclaw browser evaluate --fn '(el) => el.offsetParent !== null' --ref <ref>
```

## 最佳实践

### 1. 配置管理
```bash
# 备份配置
Copy-Item ~\.openclaw\openclaw.json ~\.openclaw\openclaw.json.backup_$(Get-Date -Format 'yyyyMMdd')

# 恢复配置
Copy-Item ~\.openclaw\openclaw.json.backup_$(Get-Date -Format 'yyyyMMdd') ~\.openclaw\openclaw.json
```

### 2. 资源管理
```bash
# 定期清理
openclaw browser stop
Remove-Item ~\AppData\Local\Temp\openclaw\browser\* -Recurse -Force -ErrorAction SilentlyContinue

# 内存监控
Get-Process -Name chrome | Where-Object {$_.CommandLine -like "*openclaw*"} | Select-Object PM,WS,CPU
```

### 3. 安全建议
```bash
# 限制网络访问（生产环境）
openclaw config set browser.ssrfPolicy.dangerouslyAllowPrivateNetwork false
openclaw config set browser.ssrfPolicy.hostnameAllowlist '["*.example.com", "example.com"]'

# 禁用危险功能
openclaw config set browser.evaluateEnabled false
```

## 记忆记录

### 配置记录模板
```markdown
## 浏览器配置记录 [YYYY-MM-DD]

### 🔧 配置详情
- **配置时间**: [时间]
- **配置目的**: [描述]
- **浏览器类型**: Chrome/Brave/Edge
- **运行模式**: 有头/无头
- **CDP端口**: 18800

### 📋 配置命令
```bash
[使用的配置命令]
```

### ✅ 验证结果
- 状态检查: [结果]
- 网页打开: [结果]
- 截图功能: [结果]
- 快照功能: [结果]

### 💡 经验总结
- [成功经验]
- [注意事项]
- [改进建议]
```

### 使用记录模板
```markdown
## 浏览器使用记录 [YYYY-MM-DD HH:mm]

### 🎯 使用场景
- **任务类型**: 自动化测试/数据抓取/监控
- **目标网站**: [网站URL]
- **执行操作**: [操作描述]

### 🔍 执行过程
#### 准备阶段
1. [准备步骤]
2. [配置检查]

#### 执行阶段
1. [操作步骤]
2. [中间结果]

#### 验证阶段
1. [结果验证]
2. [问题处理]

### 📊 执行结果
- **成功/失败**: [结果]
- **耗时**: [时间]
- **产出物**: [截图/数据/报告]

### 🧠 学习收获
- [技术收获]
- [问题解决]
- [优化建议]
```

## 扩展功能

### 多配置文件支持
```bash
# 创建工作配置文件
openclaw config set browser.profiles.work.cdpPort 18801
openclaw config set browser.profiles.work.color "#0066CC"

# 创建测试配置文件
openclaw config set browser.profiles.test.cdpPort 18802
openclaw config set browser.profiles.test.color "#00AA00"

# 使用特定配置文件
openclaw browser --browser-profile work status
openclaw browser --browser-profile work open https://work-site.com
```

### 远程浏览器配置
```bash
# 配置远程CDP连接
openclaw config set browser.profiles.remote.cdpUrl "http://192.168.1.100:9222"
openclaw config set browser.profiles.remote.color "#FF9900"

# 配置Browserless（云浏览器）
openclaw config set browser.profiles.browserless.cdpUrl "wss://production-sfo.browserless.io?token=<API_KEY>"
openclaw config set browser.profiles.browserless.color "#00AA00"
```

### 浏览器设置定制
```bash
# 设置视口大小
openclaw browser resize 1280 720

# 设置用户代理
openclaw browser set headers --headers-json '{"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}'

# 设置地理位置
openclaw browser set geo 39.9042 116.4074 --origin "https://example.com"

# 设置时区
openclaw browser set timezone Asia/Shanghai
```

## 技能维护

### 版本历史
- **v1.0** (2026-04-03): 初始版本，基于实际配置经验创建
- **创建原因**: 标准化OpenClaw浏览器工具的配置和使用流程
- **适用环境**: Windows + OpenClaw 2026.4.2 + Chrome浏览器

### 测试验证
```bash
# 运行技能测试
./scripts/test-browser-setup.ps1

# 验证配置完整性
openclaw doctor --check browser

# 性能基准测试
./scripts/benchmark-browser.ps1
```

### 更新记录
- 定期检查OpenClaw文档更新
- 收集用户反馈优化指南
- 添加新的使用场景和示例

---

**最后更新**: 2026-04-03  
**创建者**: 清风  
**关联技能**: gateway-monitor, healthcheck  
**目标**: 提供完整、可复用的浏览器工具配置和使用指南