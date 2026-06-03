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
                                 │ :3000
                                 ▼
                        ┌──────────────────┐
                        │  Stellux 前端     │
                        │  (Next.js)       │─── SSR ──┐
                        │  代理 /api/v1/*  │          │
                        └────────┬─────────┘          │
                                 │ rewrites           │
                                 ▼                    ▼
                        ┌─────────────────────────────────┐
                        │        Stellux 后端              │
                        │        (Rust/Axum) :8080        │
                        └────────┬────────────────────────┘
                                 │
                ┌────────────────┼────────────────┐
                │                │                │
                ▼                ▼                ▼
       ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
       │  PostgreSQL   │ │    Redis      │ │   RustFS     │
       │  (数据库)     │ │   (缓存)      │ │  (文件存储)  │
       │  :5432       │ │   :6379       │ │  :9000/9001  │
       └──────────────┘ └──────────────┘ └──────────────┘
```

## 📦 技术栈

| 层 | 技术 |
|---|------|
| **后端** | Rust, Axum 0.8, SQLx, Redis, Argon2, JWT, AWS S3 SDK |
| **前端** | Next.js 15, React 19, TypeScript 5, TailwindCSS 4, Shadcn UI, Zustand |
| **移动端** | Flutter, Dart, Riverpod, GoRouter |
| **数据库** | PostgreSQL 15, Redis 7, RustFS (S3 兼容) |
| **部署** | Docker, Docker Compose, GitHub Actions, Docker Hub |

---

## 🚀 一键部署

### 方式一：一键脚本安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/sexyfeifan/stellux/main/deploy.sh | bash
```

脚本会自动：
- ✅ 检测并安装 Docker 环境
- ✅ 生成 `.env` 配置文件（随机密码）
- ✅ 拉取预构建镜像
- ✅ 启动全部 5 个服务（前端、后端、PostgreSQL、Redis、RustFS）
- ✅ 自动创建管理员账号
- ✅ 输出访问地址和登录信息

### 方式二：Docker Compose 安装

```bash
# 1. 克隆项目
git clone https://github.com/sexyfeifan/stellux.git
cd stellux

# 2. 配置环境变量
cp .env.example .env
# 编辑 .env 修改密码等配置

# 3. 启动服务
docker compose -f docker-compose.prod.yml up -d

# 4. 创建管理员（首次部署）
curl -X POST http://localhost:8080/api/v1/auth/setup \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"your-password"}'
```

---

## 🔑 默认管理员账号

| 项目 | 值 |
|------|-----|
| **用户名** | `admin` |
| **密码** | `admin123` |
| **登录地址** | `http://你的服务器IP:3000/admin/login` |

> ⚠️ **安全提示**：首次登录后请立即修改默认密码！

---

## 🐳 Docker 镜像

预构建多架构镜像（`linux/amd64` + `linux/arm64`）：

```bash
# 后端
docker pull sexyfeifan/stellux-backend:latest

# 前端
docker pull sexyfeifan/stellux-frontend:latest
```

| 镜像 | Docker Hub |
|------|------------|
| 后端 | [sexyfeifan/stellux-backend](https://hub.docker.com/r/sexyfeifan/stellux-backend) |
| 前端 | [sexyfeifan/stellux-frontend](https://hub.docker.com/r/sexyfeifan/stellux-frontend) |

---

## ⚙️ 环境变量

| 变量 | 必填 | 说明 | 默认值 |
|------|:----:|------|--------|
| `POSTGRES_PASSWORD` | ✅ | 数据库密码 | - |
| `JWT_SECRET` | ✅ | JWT 密钥（≥32 字符） | - |
| `RUSTFS_SECRET_KEY` | ✅ | 文件存储密钥 | - |
| `NEXT_PUBLIC_API_URL` | | 前端 API 地址（通过 Next.js 代理） | `/api/v1` |
| `BACKEND_PORT` | | 后端外部端口 | `8080` |
| `FRONTEND_PORT` | | 前端外部端口 | `3000` |
| `POSTGRES_PORT` | | 数据库外部端口 | `5432` |
| `ADMIN_USERNAME` | | 管理员用户名 | `admin` |
| `ADMIN_PASSWORD` | | 管理员密码 | `admin123` |
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
│   ├── next.config.ts      # Next.js 配置（含 API 代理）
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
