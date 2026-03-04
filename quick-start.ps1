# OpenClaw Docker 快速部署脚本 (PowerShell)

Write-Host "🦞 OpenClaw Docker 快速部署脚本" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Docker
try {
    $null = docker --version
    Write-Host "✅ Docker 检查通过" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误：未检测到 Docker，请先安装 Docker Desktop" -ForegroundColor Red
    exit 1
}

# 检查 Docker 是否运行
try {
    $null = docker info 2>&1
} catch {
    Write-Host "❌ 错误：Docker 未运行，请启动 Docker Desktop" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 检查 .env 文件
if (-not (Test-Path .env)) {
    Write-Host "❌ 错误：未找到 .env 文件" -ForegroundColor Red
    Write-Host "请先复制 .env.example 并配置必要的环境变量" -ForegroundColor Yellow
    exit 1
}

# 检查是否配置了 Gateway Token
$envContent = Get-Content .env -Raw
if ($envContent -match "change-me-to-a-long-random-token") {
    Write-Host "⚠️  警告：检测到默认的 OPENCLAW_GATEWAY_TOKEN" -ForegroundColor Yellow
    Write-Host "建议生成一个安全的随机令牌：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host '  -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})' -ForegroundColor Cyan
    Write-Host ""
    $continue = Read-Host "是否继续？(y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# 检查是否配置了 API Key
$hasApiKey = $false
foreach ($line in (Get-Content .env)) {
    if ($line -match "^(OPENAI_API_KEY|ANTHROPIC_API_KEY|GEMINI_API_KEY)=" -and $line -notmatch "^#") {
        $hasApiKey = $true
        break
    }
}

if (-not $hasApiKey) {
    Write-Host "⚠️  警告：未检测到 AI 模型 API 密钥配置" -ForegroundColor Yellow
    Write-Host "OpenClaw 需要至少一个 AI 模型提供商的 API 密钥才能正常工作" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "支持的提供商：" -ForegroundColor Yellow
    Write-Host "  - OpenAI (OPENAI_API_KEY)"
    Write-Host "  - Anthropic/Claude (ANTHROPIC_API_KEY)"
    Write-Host "  - Google Gemini (GEMINI_API_KEY)"
    Write-Host ""
    $continue = Read-Host "是否继续？(y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

Write-Host "✅ 配置检查通过" -ForegroundColor Green
Write-Host ""

# 创建必要的目录
Write-Host "📁 创建数据目录..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path config | Out-Null
New-Item -ItemType Directory -Force -Path workspace | Out-Null
Write-Host "✅ 目录创建完成" -ForegroundColor Green
Write-Host ""

# 询问构建选项
Write-Host "🔨 Docker 镜像构建选项：" -ForegroundColor Cyan
Write-Host "1) 基础版（推荐，约 1.5GB）"
Write-Host "2) 包含浏览器自动化（约 1.8GB）"
Write-Host "3) 完整版（浏览器 + Docker CLI，约 2GB）"
Write-Host ""
$buildOption = Read-Host "请选择 (1-3, 默认: 1)"
if ([string]::IsNullOrEmpty($buildOption)) {
    $buildOption = "1"
}

$buildArgs = ""
switch ($buildOption) {
    "2" {
        $buildArgs = "--build-arg OPENCLAW_INSTALL_BROWSER=1"
        Write-Host "📦 构建包含浏览器自动化的镜像..." -ForegroundColor Cyan
    }
    "3" {
        $buildArgs = "--build-arg OPENCLAW_INSTALL_BROWSER=1 --build-arg OPENCLAW_INSTALL_DOCKER_CLI=1"
        Write-Host "📦 构建完整版镜像..." -ForegroundColor Cyan
    }
    default {
        Write-Host "📦 构建基础版镜像..." -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "⏳ 构建 Docker 镜像（首次构建可能需要 10-20 分钟）..." -ForegroundColor Yellow

$buildCmd = "docker build $buildArgs -t openclaw:local ."
Invoke-Expression $buildCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 镜像构建成功" -ForegroundColor Green
} else {
    Write-Host "❌ 镜像构建失败" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🚀 启动 OpenClaw 服务..." -ForegroundColor Cyan

docker compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 服务启动成功" -ForegroundColor Green
} else {
    Write-Host "❌ 服务启动失败" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⏳ 等待服务就绪..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 检查服务状态
$psOutput = docker compose ps
if ($psOutput -match "Up") {
    Write-Host "✅ 服务运行正常" -ForegroundColor Green
} else {
    Write-Host "⚠️  警告：部分服务可能未正常启动" -ForegroundColor Yellow
    Write-Host "请运行 'docker compose logs' 查看详细日志" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "🎉 OpenClaw 部署完成！" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 服务信息：" -ForegroundColor Cyan
Write-Host "  Gateway 地址: http://localhost:18789"
Write-Host "  健康检查: http://localhost:18789/healthz"
Write-Host ""
Write-Host "🔧 常用命令：" -ForegroundColor Cyan
Write-Host "  查看日志: docker compose logs -f"
Write-Host "  停止服务: docker compose down"
Write-Host "  重启服务: docker compose restart"
Write-Host "  使用 CLI: docker compose run --rm openclaw-cli"
Write-Host ""
Write-Host "📚 详细文档请查看: README-DEPLOY.md" -ForegroundColor Yellow
Write-Host ""
Write-Host "🦞 享受 OpenClaw 带来的 AI 体验！" -ForegroundColor Magenta
