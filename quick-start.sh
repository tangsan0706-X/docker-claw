#!/bin/bash
# OpenClaw 快速启动脚本

set -e

echo "🦞 OpenClaw Docker 快速部署脚本"
echo "================================"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 错误：未检测到 Docker，请先安装 Docker Desktop"
    exit 1
fi

# 检查 Docker 是否运行
if ! docker info &> /dev/null; then
    echo "❌ 错误：Docker 未运行，请启动 Docker Desktop"
    exit 1
fi

echo "✅ Docker 检查通过"
echo ""

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "❌ 错误：未找到 .env 文件"
    echo "请先复制 .env.example 并配置必要的环境变量"
    exit 1
fi

# 检查是否配置了 Gateway Token
if grep -q "change-me-to-a-long-random-token" .env 2>/dev/null; then
    echo "⚠️  警告：检测到默认的 OPENCLAW_GATEWAY_TOKEN"
    echo "建议生成一个安全的随机令牌："
    echo ""
    echo "  openssl rand -hex 32"
    echo ""
    read -p "是否继续？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查是否配置了 API Key
if ! grep -E "^(OPENAI_API_KEY|ANTHROPIC_API_KEY|GEMINI_API_KEY)=" .env | grep -v "^#" &> /dev/null; then
    echo "⚠️  警告：未检测到 AI 模型 API 密钥配置"
    echo "OpenClaw 需要至少一个 AI 模型提供商的 API 密钥才能正常工作"
    echo ""
    echo "支持的提供商："
    echo "  - OpenAI (OPENAI_API_KEY)"
    echo "  - Anthropic/Claude (ANTHROPIC_API_KEY)"
    echo "  - Google Gemini (GEMINI_API_KEY)"
    echo ""
    read -p "是否继续？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ 配置检查通过"
echo ""

# 创建必要的目录
echo "📁 创建数据目录..."
mkdir -p config workspace
echo "✅ 目录创建完成"
echo ""

# 询问构建选项
echo "🔨 Docker 镜像构建选项："
echo "1) 基础版（推荐，约 1.5GB）"
echo "2) 包含浏览器自动化（约 1.8GB）"
echo "3) 完整版（浏览器 + Docker CLI，约 2GB）"
echo ""
read -p "请选择 (1-3, 默认: 1): " BUILD_OPTION
BUILD_OPTION=${BUILD_OPTION:-1}

BUILD_ARGS=""
case $BUILD_OPTION in
    2)
        BUILD_ARGS="--build-arg OPENCLAW_INSTALL_BROWSER=1"
        echo "📦 构建包含浏览器自动化的镜像..."
        ;;
    3)
        BUILD_ARGS="--build-arg OPENCLAW_INSTALL_BROWSER=1 --build-arg OPENCLAW_INSTALL_DOCKER_CLI=1"
        echo "📦 构建完整版镜像..."
        ;;
    *)
        echo "📦 构建基础版镜像..."
        ;;
esac

echo ""
echo "⏳ 构建 Docker 镜像（首次构建可能需要 10-20 分钟）..."
if docker build $BUILD_ARGS -t openclaw:local .; then
    echo "✅ 镜像构建成功"
else
    echo "❌ 镜像构建失败"
    exit 1
fi

echo ""
echo "🚀 启动 OpenClaw 服务..."
if docker compose up -d; then
    echo "✅ 服务启动成功"
else
    echo "❌ 服务启动失败"
    exit 1
fi

echo ""
echo "⏳ 等待服务就绪..."
sleep 5

# 检查服务状态
if docker compose ps | grep -q "Up"; then
    echo "✅ 服务运行正常"
else
    echo "⚠️  警告：部分服务可能未正常启动"
    echo "请运行 'docker compose logs' 查看详细日志"
fi

echo ""
echo "======================================"
echo "🎉 OpenClaw 部署完成！"
echo "======================================"
echo ""
echo "📊 服务信息："
echo "  Gateway 地址: http://localhost:18789"
echo "  健康检查: http://localhost:18789/healthz"
echo ""
echo "🔧 常用命令："
echo "  查看日志: docker compose logs -f"
echo "  停止服务: docker compose down"
echo "  重启服务: docker compose restart"
echo "  使用 CLI: docker compose run --rm openclaw-cli"
echo ""
echo "📚 详细文档请查看: README-DEPLOY.md"
echo ""
echo "🦞 享受 OpenClaw 带来的 AI 体验！"
