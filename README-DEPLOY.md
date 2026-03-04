# OpenClaw Docker 容器化部署指南

本指南将帮助您在 Windows 环境下使用 Docker 部署 OpenClaw AI Agent Framework。

## 📋 前置要求

- ✅ Docker Desktop for Windows（已安装并运行）
- ✅ Git（已安装）
- ✅ 至少一个 AI 模型提供商的 API 密钥（OpenAI、Anthropic、Gemini 等）

## 🚀 快速开始

### 1️⃣ 配置环境变量

编辑项目根目录下的 `.env` 文件，配置以下必需项：

```bash
# 生成一个安全的随机令牌
# 可以使用 PowerShell: -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})
OPENCLAW_GATEWAY_TOKEN=your-long-random-token-here

# 至少配置一个 AI 模型 API 密钥
OPENAI_API_KEY=sk-...
# 或
ANTHROPIC_API_KEY=sk-ant-...
# 或
GEMINI_API_KEY=...
```

### 2️⃣ 创建数据持久化目录

```bash
# 在项目目录下创建
mkdir config
mkdir workspace
```

### 3️⃣ 构建 Docker 镜像

```bash
# 基础镜像（不包含浏览器和 Docker CLI）
docker build -t openclaw:local .

# 或者，包含浏览器自动化支持（增加 ~300MB）
docker build --build-arg OPENCLAW_INSTALL_BROWSER=1 -t openclaw:local .

# 或者，包含浏览器 + Docker CLI（用于沙箱隔离）
docker build --build-arg OPENCLAW_INSTALL_BROWSER=1 --build-arg OPENCLAW_INSTALL_DOCKER_CLI=1 -t openclaw:local .
```

> 💡 **提示**：首次构建可能需要 10-20 分钟，请耐心等待。

### 4️⃣ 启动服务

```bash
# 启动所有服务（gateway + cli）
docker compose up -d

# 查看日志
docker compose logs -f

# 仅启动 gateway
docker compose up -d openclaw-gateway
```

### 5️⃣ 验证部署

```bash
# 检查服务状态
docker compose ps

# 检查健康状态
curl http://localhost:18789/healthz

# 应该返回：{"ok": true}
```

## 🔧 常用命令

### 使用 OpenClaw CLI

```bash
# 交互式 CLI
docker compose run --rm openclaw-cli

# 执行特定命令
docker compose run --rm openclaw-cli --help

# 创建新的 AI 代理
docker compose run --rm openclaw-cli agent create my-first-agent
```

### 管理服务

```bash
# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f openclaw-gateway

# 进入容器
docker compose exec openclaw-gateway bash
```

### 数据管理

```bash
# 备份配置
tar -czf openclaw-backup-$(date +%Y%m%d).tar.gz config/ workspace/

# 恢复配置
tar -xzf openclaw-backup-YYYYMMDD.tar.gz

# 清理数据（谨慎操作！）
docker compose down -v
rm -rf config/* workspace/*
```

## 📡 配置消息通道

OpenClaw 支持 20+ 消息平台。以 Telegram 为例：

### Telegram Bot 配置

1. 与 [@BotFather](https://t.me/botfather) 对话创建机器人
2. 获取 Bot Token
3. 在 `.env` 中添加：

```bash
TELEGRAM_BOT_TOKEN=123456:ABCDEF...
```

4. 重启服务：

```bash
docker compose restart
```

5. 在 Telegram 中向你的 Bot 发送消息测试

### Discord Bot 配置

1. 访问 [Discord Developer Portal](https://discord.com/developers/applications)
2. 创建应用并获取 Bot Token
3. 在 `.env` 中添加：

```bash
DISCORD_BOT_TOKEN=your-discord-token
```

4. 重启服务

## 🔐 安全建议

### 生产环境部署清单

- ✅ 使用强随机 `OPENCLAW_GATEWAY_TOKEN`
- ✅ 定期备份 `config/` 和 `workspace/` 目录
- ✅ 不要将 `.env` 文件提交到版本控制
- ✅ 使用 HTTPS 反向代理（Nginx/Traefik）
- ✅ 限制 Gateway 端口的访问（防火墙规则）
- ✅ 定期更新 Docker 镜像：`docker compose pull && docker compose up -d`

### 生成安全令牌

**PowerShell (Windows):**
```powershell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | % {[char]$_})
```

**Git Bash / WSL:**
```bash
openssl rand -hex 32
```

## 🌐 远程访问配置

如果需要从外部网络访问 OpenClaw：

### 方案 1：Nginx 反向代理 + SSL

```nginx
server {
    listen 443 ssl http2;
    server_name openclaw.yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 方案 2：Tailscale Funnel（推荐）

```bash
# 安装 Tailscale
# 在容器内运行
tailscale funnel 18789
```

## 🐛 故障排查

### 问题 1：容器无法启动

```bash
# 检查日志
docker compose logs openclaw-gateway

# 常见原因：
# - 端口被占用：修改 .env 中的 OPENCLAW_GATEWAY_PORT
# - 缺少 API 密钥：检查 .env 配置
# - 目录权限问题：确保 config/ 和 workspace/ 可写
```

### 问题 2：Gateway 无法连接

```bash
# 测试网络连接
docker compose exec openclaw-gateway curl http://127.0.0.1:18789/healthz

# 检查绑定地址
# 确保 .env 中 OPENCLAW_GATEWAY_BIND=lan
```

### 问题 3：AI 模型响应失败

```bash
# 检查 API 密钥
docker compose exec openclaw-gateway env | grep API_KEY

# 测试 API 连接
docker compose exec openclaw-gateway curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"
```

### 问题 4：数据丢失

```bash
# 检查卷挂载
docker compose config | grep volumes

# 确保使用绝对路径
# Windows: D:/openclaw/config
# 不要使用: ./config
```

## 📚 高级配置

### 启用浏览器自动化

编辑 `docker-compose.yml`，添加环境变量：

```yaml
environment:
  OPENCLAW_BROWSER_ENABLED: "1"
```

### 启用沙箱隔离

1. 重新构建镜像（包含 Docker CLI）：

```bash
docker build --build-arg OPENCLAW_INSTALL_DOCKER_CLI=1 -t openclaw:local .
```

2. 编辑 `docker-compose.yml`，取消注释：

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
group_add:
  - "${DOCKER_GID:-999}"
```

3. 设置正确的 Docker GID（Git Bash / WSL）：

```bash
# 获取 Docker socket 的 GID
stat -c '%g' /var/run/docker.sock

# 在 .env 中设置
DOCKER_GID=999  # 替换为实际值
```

### 自定义 Agent 配置

在 `config/openclaw.json` 中配置：

```json
{
  "agents": {
    "defaults": {
      "model": "claude-sonnet-4-5",
      "workspace": "/home/node/.openclaw/workspace",
      "sandbox": true
    }
  },
  "gateway": {
    "auth": {
      "token": "your-token-from-env"
    }
  }
}
```

## 📖 更多资源

- 🌐 官方网站：https://openclaw.ai
- 📚 官方文档：https://docs.openclaw.ai
- 💬 GitHub：https://github.com/openclaw/openclaw
- 🐛 问题反馈：https://github.com/openclaw/openclaw/issues

## 🎉 下一步

现在您已经成功部署了 OpenClaw！可以尝试：

1. 🤖 创建您的第一个 AI 代理
2. 📱 连接您喜欢的消息平台（Telegram、Discord 等）
3. 🔧 探索高级功能（浏览器自动化、沙箱隔离等）
4. 🌟 参与社区贡献

祝您使用愉快！🦞
