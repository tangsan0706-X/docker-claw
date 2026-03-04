# 阿里云 Coding Plan 快速配置脚本

Write-Host "🦞 OpenClaw - 阿里云 Coding Plan 配置向导" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 检查配置文件是否存在
if (-not (Test-Path "config\openclaw.json")) {
    Write-Host "❌ 错误：配置文件不存在" -ForegroundColor Red
    Write-Host "请确保在项目根目录运行此脚本" -ForegroundColor Yellow
    exit 1
}

Write-Host "📚 阿里云 Coding Plan 说明" -ForegroundColor Green
Write-Host "-------------------------------------------"
Write-Host "• 国内访问友好，低延迟，无需科学上网"
Write-Host "• 支持 Qwen3.5、GLM-5、Kimi、MiniMax 等模型"
Write-Host "• 价格：Lite ¥40/月，Pro ¥200/月"
Write-Host "• 按请求次数计费（非按 Token）"
Write-Host ""
Write-Host "📖 详细文档：阿里云配置指南.md" -ForegroundColor Yellow
Write-Host ""

# 获取 API Key
Write-Host "🔑 第一步：获取 API Key" -ForegroundColor Cyan
Write-Host "-------------------------------------------"
Write-Host "1. 访问：https://bailian.console.aliyun.com/coding-plan"
Write-Host "2. 开通 Coding Plan 套餐（如未开通）"
Write-Host "3. 复制您的 API Key（格式：sk-sp-xxxxx）"
Write-Host ""

$apiKey = Read-Host "请粘贴您的阿里云 Coding Plan API Key"

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host "❌ 错误：API Key 不能为空" -ForegroundColor Red
    exit 1
}

if (-not $apiKey.StartsWith("sk-sp-")) {
    Write-Host "⚠️  警告：API Key 格式可能不正确" -ForegroundColor Yellow
    Write-Host "Coding Plan 的 API Key 应该以 'sk-sp-' 开头" -ForegroundColor Yellow
    Write-Host "如果您确定这是正确的 Key，可以继续" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "是否继续？(y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

Write-Host ""
Write-Host "✅ API Key 已接收" -ForegroundColor Green
Write-Host ""

# 选择默认模型
Write-Host "🎨 第二步：选择默认模型" -ForegroundColor Cyan
Write-Host "-------------------------------------------"
Write-Host "1) qwen3.5-plus       - 通用编程（推荐）"
Write-Host "2) qwen3-coder-plus   - 专业代码生成"
Write-Host "3) qwen3-coder-turbo  - 快速代码补全"
Write-Host "4) glm-5              - 智谱 GLM-5"
Write-Host "5) kimi-k2.5          - Kimi K2.5"
Write-Host "6) minimax-m2.5       - MiniMax M2.5（超长上下文）"
Write-Host ""

$modelChoice = Read-Host "请选择默认模型 (1-6, 默认: 1)"
if ([string]::IsNullOrEmpty($modelChoice)) {
    $modelChoice = "1"
}

$modelMap = @{
    "1" = "qwen3.5-plus"
    "2" = "qwen3-coder-plus"
    "3" = "qwen3-coder-turbo"
    "4" = "glm-5"
    "5" = "kimi-k2.5"
    "6" = "minimax-m2.5"
}

$selectedModel = $modelMap[$modelChoice]
if ([string]::IsNullOrEmpty($selectedModel)) {
    Write-Host "⚠️  无效的选择，使用默认模型：qwen3.5-plus" -ForegroundColor Yellow
    $selectedModel = "qwen3.5-plus"
}

Write-Host "✅ 已选择模型：$selectedModel" -ForegroundColor Green
Write-Host ""

# 更新配置文件
Write-Host "⚙️  第三步：更新配置文件" -ForegroundColor Cyan
Write-Host "-------------------------------------------"

try {
    $configPath = "config\openclaw.json"
    $config = Get-Content $configPath -Raw | ConvertFrom-Json

    # 更新所有 provider 的 API Key
    $config.models.providers.'aliyun-coding-qwen'.apiKey = $apiKey
    $config.models.providers.'aliyun-coding-glm'.apiKey = $apiKey
    $config.models.providers.'aliyun-coding-kimi'.apiKey = $apiKey
    $config.models.providers.'aliyun-coding-minimax'.apiKey = $apiKey

    # 更新默认模型
    $config.agents.defaults.model.primary = $selectedModel

    # 保存配置
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8

    Write-Host "✅ 配置文件已更新：$configPath" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误：配置文件更新失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""

# 更新 Gateway Token（如果还是默认值）
$envPath = ".env"
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    if ($envContent -match "change-me-to-a-long-random-token") {
        Write-Host "🔐 第四步：生成 Gateway Token" -ForegroundColor Cyan
        Write-Host "-------------------------------------------"

        # 生成随机 token
        $token = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | % {[char]$_})

        # 更新 .env 文件
        $envContent = $envContent -replace "change-me-to-a-long-random-token-please-generate-one", $token
        $envContent | Set-Content $envPath -Encoding UTF8 -NoNewline

        Write-Host "✅ Gateway Token 已自动生成并保存到 .env" -ForegroundColor Green
        Write-Host ""
    }
}

# 显示下一步操作
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "🎉 配置完成！" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 配置摘要：" -ForegroundColor Cyan
Write-Host "  API Key: $($apiKey.Substring(0, 10))..." -ForegroundColor White
Write-Host "  默认模型: $selectedModel" -ForegroundColor White
Write-Host "  配置文件: config\openclaw.json" -ForegroundColor White
Write-Host ""
Write-Host "🚀 下一步操作：" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 启动 OpenClaw 服务：" -ForegroundColor Yellow
Write-Host "   .\quick-start.ps1" -ForegroundColor White
Write-Host ""
Write-Host "2. 或者手动构建和启动：" -ForegroundColor Yellow
Write-Host "   docker build -t openclaw:local ." -ForegroundColor White
Write-Host "   docker compose up -d" -ForegroundColor White
Write-Host ""
Write-Host "3. 启动后测试：" -ForegroundColor Yellow
Write-Host "   docker compose run --rm openclaw-cli tui" -ForegroundColor White
Write-Host ""
Write-Host "📚 需要帮助？查看：阿里云配置指南.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "🦞 祝您使用愉快！" -ForegroundColor Magenta
