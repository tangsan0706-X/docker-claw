# OpenClaw 项目记忆

## 项目概述

- **项目路径**: `D:\openclaw`
- **项目类型**: OpenClaw AI Agent Framework 容器化部署
- **GitHub**: https://github.com/openclaw/openclaw (247K+ stars)
- **用途**: 个人 AI 助手，支持 20+ 消息平台集成

## 用户偏好

### AI 模型配置
- **提供商**: 阿里云 Coding Plan (DashScope)
- **默认模型**: glm-5 (智谱 GLM-5)
- **API Key 格式**: sk-sp-xxxxxx
- **Base URL**: https://coding.dashscope.aliyuncs.com/v1

### 环境配置
- **操作系统**: Windows 11 Home China
- **容器化工具**: Docker Desktop
- **包管理**: pnpm (项目使用)

## 项目结构

```
D:\openclaw\
├── config/
│   └── openclaw.json          # 主配置文件（包含阿里云模型配置）
├── workspace/                 # 工作空间持久化目录
├── memory/                    # 项目记忆文件
│   └── MEMORY.md              # 本文件
├── .env                       # 环境变量配置
├── Dockerfile                 # 官方 Docker 镜像定义
├── docker-compose.yml         # Docker Compose 服务配置
├── 阿里云配置指南.md          # 阿里云 Coding Plan 详细文档
├── 配置阿里云.ps1             # 自动化配置脚本
├── quick-start.ps1            # PowerShell 快速启动脚本
├── quick-start.sh             # Bash 快速启动脚本
└── 部署说明.md                # 中文快速部署指南
```

## 关键配置文件

### 1. config/openclaw.json
- 包含所有阿里云模型 provider 配置
- 模型列表：qwen3.5-plus, qwen3-coder-plus, glm-5, glm-4-plus, kimi-k2.5, minimax-m2.5
- 默认模型设置在 `agents.defaults.model.primary`

### 2. .env
- `OPENCLAW_GATEWAY_TOKEN`: Gateway 认证令牌（已自动生成）
- `OPENCLAW_CONFIG_DIR`: D:/openclaw/config
- `OPENCLAW_WORKSPACE_DIR`: D:/openclaw/workspace
- `OPENCLAW_GATEWAY_BIND`: lan (允许外部访问)

## 阿里云 Coding Plan 配置

### 已配置的模型提供商
```json
{
  "aliyun-coding-qwen": {...},   // Qwen 系列模型
  "aliyun-coding-glm": {...},    // GLM 系列模型
  "aliyun-coding-kimi": {...},   // Kimi K2.5
  "aliyun-coding-minimax": {...} // MiniMax M2.5
}
```

### API Key
- 格式：sk-sp-b886687fca86472c9f005a386f56d321
- 所有 provider 使用同一个 API Key
- 已配置在 config/openclaw.json

## 部署流程

### 标准部署步骤
1. 克隆 OpenClaw 仓库 ✅
2. 配置阿里云 API Key ✅
3. 生成 Gateway Token ✅
4. 构建 Docker 镜像 (待完成)
5. 启动服务 (待完成)
6. 验证部署 (待完成)

### 快速配置命令
```powershell
# 自动配置
.\配置阿里云.ps1

# 快速启动
.\quick-start.ps1
```

## 常见问题与解决方案

### 1. Docker Desktop 未启动
**症状**: `error during connect: open //./pipe/dockerDesktopLinuxEngine`

**解决方案**:
```powershell
# 启动 Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# 等待 1-3 分钟，然后验证
docker version
```

**注意**: Docker Desktop 启动需要 2-5 分钟，需要等待托盘图标变为静止状态

### 2. API Key 配置问题
**症状**: 配置文件中仍有 `YOUR_API_KEY` 占位符

**解决方案**:
- 使用 `配置阿里云.ps1` 脚本自动配置
- 或手动编辑 `config/openclaw.json`，替换所有 `YOUR_API_KEY`

### 3. Gateway Token 未设置
**症状**: `.env` 中 token 为默认值

**解决方案**:
```powershell
# 生成随机 token
openssl rand -hex 32

# 更新 .env 文件中的 OPENCLAW_GATEWAY_TOKEN
```

## Docker 镜像构建

### 基础镜像（推荐）
```bash
docker build -t openclaw:local .
```

### 包含浏览器自动化
```bash
docker build --build-arg OPENCLAW_INSTALL_BROWSER=1 -t openclaw:local .
```

### 完整版（浏览器 + Docker CLI）
```bash
docker build --build-arg OPENCLAW_INSTALL_DOCKER_CLI=1 -t openclaw:local .
```

## 服务启动

### 使用 Docker Compose
```bash
# 启动所有服务
docker compose up -d

# 查看日志
docker compose logs -f

# 停止服务
docker compose down
```

### 使用 CLI
```bash
# TUI 终端界面
docker compose run --rm openclaw-cli tui

# Web UI 控制台
docker compose run --rm openclaw-cli dashboard
```

## 验证部署

### 健康检查
```bash
curl http://localhost:18789/healthz
# 应返回: {"ok": true}
```

### 服务端口
- Gateway: 18789 (WebSocket + HTTP)
- Bridge: 18790

## 支持的模型对比

| 模型 | 上下文 | 推荐场景 |
|------|--------|----------|
| qwen3.5-plus | 128K | 通用编程（速度快） |
| qwen3-coder-plus | 128K | 专业代码生成 |
| glm-5 ⭐ | 128K | 复杂推理（用户偏好） |
| kimi-k2.5 | 128K | 长文本理解 |
| minimax-m2.5 | 245K | 超长上下文 |

## 切换模型

### 临时切换（TUI 中）
```
/model qwen3.5-plus
/model glm-5
```

### 永久修改默认模型
编辑 `config/openclaw.json`:
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "glm-5"  // 修改这里
      }
    }
  }
}
```

## 重要文档链接

- [阿里云 Coding Plan 控制台](https://bailian.console.aliyun.com/coding-plan)
- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [阿里云 OpenClaw 集成文档](https://help.aliyun.com/zh/model-studio/openclaw-coding-plan)
- [获取 API Key](https://help.aliyun.com/zh/model-studio/get-api-key)

## 待完成任务

- [ ] 等待 Docker Desktop 完全启动
- [ ] 构建 Docker 镜像
- [ ] 启动 OpenClaw 服务
- [ ] 验证 glm-5 模型可用性
- [ ] 测试基本对话功能
- [ ] 可选：配置消息通道（Telegram/Discord）

## 项目特点

### 优势
- ✅ 国内访问友好（使用阿里云）
- ✅ 无需科学上网
- ✅ 低延迟
- ✅ 按请求计费（非按 Token）
- ✅ 支持多种模型切换

### 成本
- Lite 套餐：¥40/月
- Pro 套餐：¥200/月
- 用户选择：待确认

## 下次启动

如果 Docker 已就绪，运行：
```powershell
cd D:\openclaw
.\quick-start.ps1
```

或手动启动：
```bash
docker build -t openclaw:local .
docker compose up -d
docker compose run --rm openclaw-cli tui
```

---

**最后更新**: 2026-03-04
**状态**: 配置完成，等待 Docker Desktop 启动后进行镜像构建和服务启动测试
