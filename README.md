<p align="center">
  <br/>
  <img src="https://img.shields.io/badge/Powered_by-Rust_|_Next.js_|_Flutter-blueviolet?style=for-the-badge" />
  <img src="https://img.shields.io/github/license/sexyfeifan/stellux?style=for-the-badge" />
  <img src="https://img.shields.io/docker/image-size/sexyfeifan/stellux-backend/latest?style=for-the-badge&label=Backend" />
  <img src="https://img.shields.io/docker/image-size/sexyfeifan/stellux-frontend/latest?style=for-the-badge&label=Frontend" />
</p>

<h1 align="center">✦ Stellux ✦</h1>
<p align="center"><strong>高性能全栈博客系统</strong></p>
<p align="center">
  Rust (Axum) 后端 · Next.js 前端 · Flutter 多端 · Docker 一键部署 · MCP Server
</p>

<p align="center">
  <a href="#-一键部署">快速开始</a> ·
  <a href="#-架构说明">架构</a> ·
  <a href="#-技术栈">技术栈</a> ·
  <a href="#-api-接口">API</a> ·
  <a href="#-开发指南">开发</a>
</p>

---

## ✨ 特性

| 特性 | 说明 |
|------|------|
| 🚀 **极致性能** | Rust Axum 后端，内存安全，高并发，低资源占用 |
| 🎨 **现代前端** | Next.js 15 + React 19 + TailwindCSS 4 + Shadcn UI |
| 📱 **多端支持** | Flutter 移动端/Web 端独立前端 |
| 📝 **Markdown 编辑器** | 代码高亮、实时预览、一键发布 |
| 🗂️ **对象存储** | RustFS (S3 兼容) 文件管理 |
| 🔐 **安全认证** | JWT + Argon2 密码哈希 |
| 🤖 **MCP Server** | 内置 Model Context Protocol，支持 AI 工具调用 |
| 🐳 **容器化部署** | Docker Compose 一键启动，数据库自动迁移 |
| 🌐 **多架构** | 预构建 `amd64` + `arm64` 镜像 |
| 🔄 **CI/CD** | GitHub Actions 自动构建发布 |

## 🏗️ 架构说明

```
                        ┌──────────────────┐
                        │   客户端浏览器     │
                        └────────┬─────────┘
                                 │
                  ┌──────────────┴──────────────┐
                  │                              │
                  ▼                              ▼
        ┌─────────────────┐            ┌─────────────────┐
        │  Stellux 前端    │            │  Stellux 后端    │
        │  (Next.js)      │─── SSR ──▶ │  (Rust/Axum)    │
        │  :3000          │            │  :8088          │
        └─────────────────┘            └────────┬────────┘
                                                │
                           ┌────────────────────┼────────────────────┐
                           │                    │                    │
                           ▼                    ▼                    ▼
                  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
                  │  PostgreSQL   │    │    Redis      │    │   RustFS     │
                  │  (数据库)     │    │   (缓存)      │    │  (文件存储)  │
                  │  :5432       │    │   :6379       │    │  :9000/9001  │
                  └──────────────┘    └──────────────┘    └──────────────┘
```

## 📦 技术栈

| 层 | 技术 |
|---|------|
| **后端** | Rust, Axum 0.8, SQLx, Redis, Argon2, JWT, AWS S3 SDK |
| **前端** | Next.js 15, React 19, TypeScript 5, TailwindCSS 4, Shadcn UI, Zustand |
| **移动端** | Flutter, Dart, Riverpod, GoRouter |
| **数据库** | PostgreSQL 15, Redis 7, RustFS (S3 兼容) |
| **部署** | Docker, Docker Compose, GitHub Actions, GHCR |

---

## 🚀 一键部署

### 方式一：一键脚本安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/sexyfeifan/stellux/main/deploy.sh | bash
```

脚本会自动：
- ✅ 检测 Docker 环境
- ✅ 生成 `.env` 配置文件（交互式填写关键参数）
- ✅ 拉取预构建镜像
- ✅ 启动所有服务
- ✅ 输出访问地址

### 方式二：Docker Compose 安装

```bash
# 1. 克隆项目
git clone https://github.com/sexyfeifan/stellux.git
cd stellux

# 2. 配置环境变量
cp .env.example .env

# 编辑 .env，必须修改以下项：
#   POSTGRES_PASSWORD=你的数据库密码
#   JWT_SECRET=你的JWT密钥(至少32字符)
#   RUSTFS_SECRET_KEY=你的存储密钥
#   NEXT_PUBLIC_API_URL=http://你的服务器IP:8088/api/v1

# 3. 启动服务
docker compose -f docker-compose.prod.yml up -d

# 4. 查看状态
docker compose -f docker-compose.prod.yml ps
```

### 方式三：手动逐个启动

```bash
# 启动数据库
docker run -d --name stellux-postgres \
  -e POSTGRES_DB=stellux \
  -e POSTGRES_USER=stellux \
  -e POSTGRES_PASSWORD=your-password \
  -v stellux_pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15-alpine

# 启动缓存
docker run -d --name stellux-redis \
  -v stellux_redis:/data \
  redis:7-alpine redis-server --appendonly yes

# 启动文件存储
docker run -d --name stellux-rustfs \
  -e RUSTFS_ACCESS_KEY=stellux \
  -e RUSTFS_SECRET_KEY=your-secret \
  -v stellux_rustfs:/data \
  -p 9100:9000 -p 9101:9001 \
  rustfs/rustfs:latest

# 启动后端
docker run -d --name stellux-backend \
  -e DATABASE_URL=postgres://stellux:your-password@host.docker.internal:5432/stellux \
  -e REDIS_URL=redis://host.docker.internal:6379 \
  -e JWT_SECRET=your-jwt-secret \
  -e SERVER_PORT=8088 \
  --add-host=host.docker.internal:host-gateway \
  -p 8088:8088 \
  ghcr.io/sexyfeifan/stellux-backend:latest

# 启动前端
docker run -d --name stellux-frontend \
  -e INTERNAL_API_URL=http://host.docker.internal:8088/api/v1 \
  -e NEXT_PUBLIC_API_URL=http://你的IP:8088/api/v1 \
  -p 3000:3000 \
  ghcr.io/sexyfeifan/stellux-frontend:latest
```

### 首次使用

1. 访问 `http://你的IP:3000/admin/login`
2. 首次访问自动进入初始化页面，创建管理员账号
3. 登录后即可开始写文章 🎉

## 🐳 Docker 镜像

预构建多架构镜像（`linux/amd64` + `linux/arm64`）：

```bash
# 后端
docker pull ghcr.io/sexyfeifan/stellux-backend:latest

# 前端
docker pull ghcr.io/sexyfeifan/stellux-frontend:latest
```

## ⚙️ 环境变量

| 变量 | 必填 | 说明 | 默认值 |
|------|:----:|------|--------|
| `POSTGRES_PASSWORD` | ✅ | 数据库密码 | - |
| `JWT_SECRET` | ✅ | JWT 密钥（≥32 字符） | - |
| `RUSTFS_SECRET_KEY` | ✅ | 文件存储密钥 | - |
| `NEXT_PUBLIC_API_URL` | ✅ | 浏览器访问后端 API 地址 | `http://localhost:8088/api/v1` |
| `BACKEND_PORT` | | 后端外部端口 | `8088` |
| `FRONTEND_PORT` | | 前端外部端口 | `3000` |
| `POSTGRES_PORT` | | 数据库外部端口 | `5432` |
| `RUST_LOG` | | 日志级别 | `warn` |
| `SERVER_MAX_BODY_SIZE_MB` | | 上传文件大小限制(MB) | `50` |

## 📁 项目结构

```
stellux/
├── backend/                 # Rust 后端
│   ├── src/
│   │   ├── main.rs         # 入口
│   │   ├── handlers/       # 请求处理器
│   │   ├── routes/         # 路由定义
│   │   ├── models/         # 数据模型
│   │   ├── repositories/   # 数据访问层
│   │   ├── services/       # 业务逻辑
│   │   ├── middleware/     # 中间件（JWT 认证）
│   │   └── mcp/            # MCP Server
│   ├── migrations/         # 数据库迁移（启动时自动执行）
│   └── Dockerfile
├── frontend/                # Next.js 前端
│   ├── src/
│   │   ├── app/            # 页面路由 (App Router)
│   │   ├── components/     # UI 组件
│   │   └── lib/            # 工具库
│   └── Dockerfile
├── flutter/                 # Flutter 多端
├── docker-compose.prod.yml  # 生产环境部署
├── .env.example             # 环境变量模板
├── deploy.sh                # 一键部署脚本
└── README.md
```

## 🔧 API 接口

| 接口 | 方法 | 说明 | 认证 |
|------|------|------|:----:|
| `/api/v1/health` | GET | 健康检查 | ❌ |
| `/api/v1/auth/setup` | POST | 初始化管理员 | ❌ |
| `/api/v1/auth/login` | POST | 登录 | ❌ |
| `/api/v1/blogs` | GET | 文章列表 | ❌ |
| `/api/v1/blogs/{slug}` | GET | 文章详情 | ❌ |
| `/api/v1/categories` | GET | 分类列表 | ❌ |
| `/api/v1/tags` | GET | 标签列表 | ❌ |
| `/api/v1/search` | GET | 搜索 | ❌ |
| `/api/v1/admin/*` | * | 管理接口 | ✅ |

## 💡 常用命令

```bash
# 查看服务状态
docker compose -f docker-compose.prod.yml ps

# 查看日志
docker logs -f stellux-backend
docker logs -f stellux-frontend

# 重启服务
docker compose -f docker-compose.prod.yml restart

# 停止所有服务
docker compose -f docker-compose.prod.yml down

# 更新版本
git pull
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 License

MIT License

---

<p align="center">
  <sub>Built with ❤️ using Rust + Next.js + Flutter</sub>
</p>
