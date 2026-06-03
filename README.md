# 📝 Blog New — 全栈博客系统

一个现代化的全栈博客系统，使用 **Rust (Axum)** 后端 + **Next.js** 前端 + **Flutter** 多端支持。

支持 Docker 一键部署，预构建多架构镜像（amd64 / arm64）。

## ✨ 特性

- 🚀 **Rust 后端** — Axum + SQLx + Redis，高性能内存安全
- 🎨 **Next.js 前端** — React 19 + TailwindCSS 4 + Shadcn UI
- 📱 **Flutter 多端** — 移动端/Web 端独立前端
- 📝 **Markdown 编辑器** — 支持代码高亮、实时预览
- 🗂️ **文件管理** — RustFS (S3 兼容) 对象存储
- 🔐 **JWT 认证** — 安全的用户认证体系
- 🐳 **Docker 一键部署** — 5 个容器，一键启动
- 🌐 **多架构支持** — amd64 / arm64 预构建镜像
- 🤖 **MCP Server** — 内置 Model Context Protocol 支持

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────┐
│                   客户端浏览器                     │
│                                                   │
│  ┌──────────────┐          ┌──────────────┐       │
│  │  Flutter App  │          │   Next.js    │       │
│  │  (Web/Mobile) │          │   :3000      │       │
│  └──────┬───────┘          └──────┬───────┘       │
│         │                         │ SSR            │
│         └─────────┬───────────────┘                │
│                   ▼                                │
│         ┌─────────────────┐                        │
│         │   Rust Backend   │                        │
│         │   (Axum) :8088   │                        │
│         └────────┬────────┘                        │
│                  │                                 │
│    ┌─────────────┼─────────────┐                   │
│    ▼             ▼             ▼                   │
│ ┌──────┐   ┌──────┐    ┌──────────┐               │
│ │ PgSQL │   │Redis │    │ RustFS   │               │
│ │ :5432 │   │:6379 │    │ :9000/1  │               │
│ └──────┘   └──────┘    └──────────┘               │
└─────────────────────────────────────────────────┘
```

## 📦 技术栈

| 层 | 技术 |
|---|------|
| **后端** | Rust, Axum 0.8, SQLx 0.8, Redis, Argon2, JWT |
| **前端** | Next.js 15, React 19, TypeScript 5, TailwindCSS 4, Shadcn UI |
| **移动端** | Flutter, Dart, Riverpod, GoRouter |
| **存储** | PostgreSQL 15, Redis 7, RustFS (S3 兼容) |
| **部署** | Docker, Docker Compose, GitHub Actions CI/CD |

## 🚀 快速部署

### 方式一：使用预构建镜像（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/sexyfeifan/blog-new.git
cd blog-new

# 2. 配置环境变量
cp .env.example .env
vim .env   # 必须修改: POSTGRES_PASSWORD, JWT_SECRET, RUSTFS_SECRET_KEY, NEXT_PUBLIC_API_URL

# 3. 一键启动
docker compose -f docker-compose.prod.yml up -d

# 4. 访问
# 博客首页: http://your-ip:3000
# 后端 API: http://your-ip:8088/api/v1
# RustFS:   http://your-ip:9101
```

### 方式二：本地构建

```bash
# 步骤同上，但不使用预构建镜像，改为本地构建
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
```

### 首次使用

1. 访问 `http://your-ip:3000/admin/login`
2. 首次访问会进入初始化页面，创建管理员账号
3. 登录后即可开始写文章

## ⚙️ 环境变量说明

| 变量 | 必填 | 说明 | 默认值 |
|------|------|------|--------|
| `POSTGRES_PASSWORD` | ✅ | 数据库密码 | - |
| `JWT_SECRET` | ✅ | JWT 密钥（≥32字符） | - |
| `RUSTFS_SECRET_KEY` | ✅ | 文件存储密钥 | - |
| `NEXT_PUBLIC_API_URL` | ✅ | 浏览器访问后端 API 地址 | `http://localhost:8088/api/v1` |
| `BACKEND_PORT` | | 后端外部端口 | `8088` |
| `FRONTEND_PORT` | | 前端外部端口 | `3000` |
| `POSTGRES_PORT` | | 数据库外部端口 | `5432` |
| `RUST_LOG` | | 日志级别 | `warn` |
| `SERVER_MAX_BODY_SIZE_MB` | | 上传文件大小限制(MB) | `50` |

## 🐳 Docker 镜像

预构建多架构镜像（支持 `linux/amd64` 和 `linux/arm64`）：

```bash
# 后端
docker pull sexyfeifan/blog-backend:latest

# 前端
docker pull sexyfeifan/blog-frontend:latest
```

## 📁 项目结构

```
blog-new/
├── backend/                 # Rust 后端
│   ├── src/
│   │   ├── main.rs         # 入口
│   │   ├── handlers/       # 请求处理器
│   │   ├── routes/         # 路由定义
│   │   ├── models/         # 数据模型
│   │   ├── repositories/   # 数据访问层
│   │   ├── services/       # 业务逻辑
│   │   ├── middleware/     # 中间件（认证等）
│   │   └── utils/          # 工具函数
│   ├── migrations/         # 数据库迁移（自动执行）
│   ├── Cargo.toml
│   └── Dockerfile
├── frontend/                # Next.js 前端
│   ├── src/
│   │   ├── app/            # 页面路由
│   │   ├── components/     # 组件
│   │   ├── lib/            # 工具库
│   │   └── types/          # TypeScript 类型
│   ├── package.json
│   └── Dockerfile
├── flutter/                 # Flutter 多端
├── .github/workflows/       # CI/CD
├── docker-compose.prod.yml  # 生产环境部署
├── .env.example             # 环境变量模板
└── README.md
```

## 🔧 API 接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/v1/health` | GET | 健康检查 |
| `/api/v1/auth/login` | POST | 登录 |
| `/api/v1/auth/setup` | POST | 初始化管理员 |
| `/api/v1/blogs` | GET | 文章列表 |
| `/api/v1/blogs/{slug}` | GET | 文章详情 |
| `/api/v1/categories` | GET | 分类列表 |
| `/api/v1/tags` | GET | 标签列表 |
| `/api/v1/search` | GET | 搜索 |
| `/api/v1/admin/*` | - | 管理接口（需认证） |

## 💡 常用命令

```bash
# 查看服务状态
docker compose -f docker-compose.prod.yml ps

# 查看日志
docker logs -f blog-backend
docker logs -f blog-frontend

# 重启服务
docker compose -f docker-compose.prod.yml restart

# 停止所有服务
docker compose -f docker-compose.prod.yml down

# 更新版本
git pull
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

## 📄 License

MIT License
