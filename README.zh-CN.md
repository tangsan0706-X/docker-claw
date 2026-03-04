# OpenClaw Docker 部署 - 阿里云 Coding Plan 版本

[![OpenClaw](https://img.shields.io/badge/OpenClaw-247K%20stars-blue)](https://github.com/openclaw/openclaw)
[![阿里云](https://img.shields.io/badge/阿里云-Coding%20Plan-orange)](https://bailian.console.aliyun.com/coding-plan)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue)](https://www.docker.com/)

基于官方 [OpenClaw](https://github.com/openclaw/openclaw) 仓库，添加了完整的**阿里云 Coding Plan** 集成配置和中文部署文档。

## 🎯 项目特点

- ✅ **国内优化**：使用阿里云 Coding Plan，无需科学上网
- ✅ **低延迟**：国内访问速度快
- ✅ **多模型支持**：Qwen3.5、GLM-5、Kimi-K2.5、MiniMax-M2.5
- ✅ **完整文档**：中文部署指南和配置文档
- ✅ **自动化脚本**：一键配置和部署
- ✅ **Docker 容器化**：开箱即用

## 📚 快速开始

### 前置要求

- Windows/Linux/macOS
- Docker Desktop
- 阿里云 Coding Plan 订阅（¥40/月起）

### 3 步部署

#### 1️⃣ 克隆仓库

```bash
git clone https://github.com/tangsan0706-X/docker-claw.git
cd docker-claw
```

#### 2️⃣ 配置阿里云 API Key

**方式 A：自动配置（推荐）**
```powershell
.\配置阿里云.ps1
```

**方式 B：手动配置**
1. 获取 API Key：https://bailian.console.aliyun.com/coding-plan
2. 编辑 `config/openclaw.json`，替换 `YOUR_API_KEY`
3. 生成 Gateway Token 并更新 `.env`

#### 3️⃣ 启动服务

```powershell
.\quick-start.ps1
```

或手动启动：
```bash
docker build -t openclaw:local .
docker compose up -d
```

## 📖 文档导航

| 文档 | 说明 |
|------|------|
| [部署说明.md](./部署说明.md) | 快速部署指南（3 步启动）|
| [README-DEPLOY.md](./README-DEPLOY.md) | 详细部署文档（英文）|
| [阿里云配置指南.md](./阿里云配置指南.md) | 阿里云 Coding Plan 完整配置 |
| [PROJECT-MEMORY.md](./PROJECT-MEMORY.md) | 项目记忆和常见问题 |

## 🤖 支持的模型

| 模型 | 上下文 | 特点 |
|------|--------|------|
| **qwen3.5-plus** | 128K | 通用编程，速度快 |
| **glm-5** ⭐ | 128K | 逻辑推理强（默认）|
| **kimi-k2.5** | 128K | 长文本理解 |
| **minimax-m2.5** | 245K | 超长上下文 |
| **qwen3-coder-plus** | 128K | 专业代码生成 |

## 🚀 使用方式

### TUI 终端界面
```bash
docker compose run --rm openclaw-cli tui
```

### Web UI 控制台
```bash
docker compose run --rm openclaw-cli dashboard
```

### 切换模型
在 TUI 中输入：
```
/model qwen3.5-plus
/model glm-5
/model kimi-k2.5
```

## 💰 成本

### 阿里云 Coding Plan 套餐

- **Lite**：¥40/月（个人学习）
- **Pro**：¥200/月（专业开发）
- 按请求次数计费（非按 Token）

## 🔧 常用命令

```bash
# 启动服务
docker compose up -d

# 查看日志
docker compose logs -f

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 健康检查
curl http://localhost:18789/healthz
```

## 📡 消息平台集成

OpenClaw 支持 20+ 消息平台：

- Telegram
- Discord
- Slack
- WhatsApp
- 微信（通过插件）
- 更多...

配置方法请查看 [部署说明.md](./部署说明.md)

## 🔐 安全说明

**请勿提交以下文件到公开仓库**：
- `.env` - 包含 Gateway Token
- `config/openclaw.json` - 包含 API Key
- `workspace/` - 用户数据

这些文件已在 `.gitignore` 中排除。

## 🆘 故障排查

### Docker Desktop 未启动
```powershell
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

### API Key 配置问题
检查 `config/openclaw.json` 中所有 `apiKey` 字段是否已替换。

### 更多问题
查看 [PROJECT-MEMORY.md](./PROJECT-MEMORY.md) 的常见问题部分。

## 📚 相关链接

- [OpenClaw 官方仓库](https://github.com/openclaw/openclaw)
- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [阿里云 Coding Plan](https://bailian.console.aliyun.com/coding-plan)
- [阿里云文档](https://help.aliyun.com/zh/model-studio/openclaw-coding-plan)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目基于 [OpenClaw](https://github.com/openclaw/openclaw) 官方仓库，遵循 MIT 许可证。

---

**维护者**: [@tangsan0706-X](https://github.com/tangsan0706-X)

**最后更新**: 2026-03-04

🦞 享受 OpenClaw 带来的 AI 编程体验！
