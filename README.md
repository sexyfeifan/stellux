<p align="center">
  <br/>
  <img src="https://img.shields.io/badge/Powered_by-Rust_|_Next.js-blueviolet?style=for-the-badge" />
  <img src="https://img.shields.io/github/license/sexyfeifan/stellux?style=for-the-badge" />
  <img src="https://img.shields.io/docker/image-size/sexyfeifan/stellux-backend/latest?style=for-the-badge&label=Backend" />
  <img src="https://img.shields.io/docker/image-size/sexyfeifan/stellux-frontend/latest?style=for-the-badge&label=Frontend" />
</p>

<h1 align="center">✦ Stellux ✦</h1>
<p align="center"><strong>高性能全栈博客系统</strong></p>
<p align="center">
  Rust (Axum) 后端 · Next.js 16 前端 · Docker 一键部署 · MCP Server
</p>

<p align="center">
  <a href="#-快速开始">快速开始</a> ·
  <a href="#-页面路由">页面路由</a> ·
  <a href="#-api-接口">API</a> ·
  <a href="#-架构说明">架构</a> ·
  <a href="#-技术栈">技术栈</a> ·
  <a href="#-环境变量">配置</a>
</p>

---

## 🚀 快速开始

### 一键部署（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/sexyfeifan/stellux/main/deploy.sh | bash
```

脚本自动完成：检测 Docker → 生成配置 → 拉取镜像 → 启动服务 → 创建管理员

### Docker Compose 部署

```bash
git clone https://github.com/sexyfeifan/stellux.git
cd stellux
cp .env.example .env
docker compose -f docker-compose.prod.yml up -d

# 创建管理员（首次）
curl -X POST http://localhost:8080/api/v1/auth/setup \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"your-password"}'
```

### 默认管理员

| 项目 | 值 |
|------|-----|
| 用户名 | `admin` |
| 密码 | `admin123` |
| 登录地址 | `http://服务器IP:3000/admin/login` |

> ⚠️ 首次登录后请立即在 **设置 → 安全** 中修改默认密码

---

## 📄 页面路由

### 前台博客页面（无需登录）

| 路由 | 页面 | 说明 |
|------|------|------|
| `/` | 首页 | 博客文章列表、分类导航 |
| `/blog/{slug}` | 文章详情 | Markdown 渲染、代码高亮 |
| `/categories` | 分类列表 | 所有文章分类 |
| `/category/{id}` | 分类文章 | 按分类筛选文章 |
| `/tags` | 标签列表 | 所有标签 |
| `/tag/{id}` | 标签文章 | 按标签筛选文章 |
| `/archive` | 文章归档 | 按时间线展示 |
| `/search` | 搜索 | 全文搜索 |
| `/docs` | 文档目录 | 树形文档结构 |
| `/docs/{id}` | 文档详情 | Markdown 文档 |
| `/projects` | 项目展示 | 开源/个人项目 |
| `/friends` | 友情链接 | 博客友链 |
| `/texts/{id}` | 加密文本 | 需密码查看的临时文本 |

### 后台管理页面（需要登录）

| 路由 | 页面 | 说明 |
|------|------|------|
| `/admin/login` | 登录页 | 管理员登录 |
| `/admin` | 仪表盘 | 数据统计概览 |
| `/admin/blogs` | 文章管理 | 文章列表、编辑、删除 |
| `/admin/blogs/new` | 新建文章 | Markdown 编辑器 |
| `/admin/blogs/{id}` | 编辑文章 | 修改已有文章 |
| `/admin/categories` | 分类管理 | 增删改分类 |
| `/admin/tags` | 标签管理 | 增删改标签 |
| `/admin/directories` | 目录管理 | 文档目录树 |
| `/admin/documents/new` | 新建文档 | 创建文档 |
| `/admin/documents/{id}` | 编辑文档 | 修改文档 |
| `/admin/files` | 文件管理 | S3 文件上传/管理 |
| `/admin/friend-links` | 友链管理 | 友情链接增删改 |
| `/admin/projects` | 项目管理 | 项目增删改 |
| `/admin/texts` | 加密文本 | 管理加密临时文本 |
| `/admin/data` | 数据管理 | 数据导入/导出 |
| `/admin/settings` | 站点设置 | 8 个配置 Tab（见下表） |

### 设置页面 Tab 详情

| Tab | 功能 |
|-----|------|
| 站点 | 站点标题、副标题、SEO 描述、博客总结 |
| 站长 | 站长昵称、头像、介绍、技能列表 |
| 社交 | GitHub、Twitter、邮箱等社交链接 |
| 备案 | ICP 备案号、公安备案、版权信息 |
| 存储 | S3/RustFS 文件存储配置 |
| AI 配置 | AI 润色、摘要功能开关和 API Key |
| MCP 配置 | MCP Server 启用/禁用、Token 管理 |
| **安全** | **修改管理员密码** |

---

## 🔌 API 接口

### 公开接口（无需认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/health` | 健康检查 |
| GET | `/api/v1/auth/check-admin` | 检查管理员是否存在 |
| POST | `/api/v1/auth/setup` | 初始化管理员（首次） |
| POST | `/api/v1/auth/login` | 登录，返回 JWT |
| POST | `/api/v1/auth/refresh` | 刷新 Token |
| GET | `/api/v1/blogs` | 文章列表（分页） |
| GET | `/api/v1/blogs/slug/{slug}` | 文章详情 |
| GET | `/api/v1/categories` | 分类列表 |
| GET | `/api/v1/tags` | 标签列表 |
| GET | `/api/v1/tags/{id}/blogs` | 标签下的文章 |
| GET | `/api/v1/archives` | 文章归档 |
| GET | `/api/v1/search?q={query}` | 全文搜索 |
| GET | `/api/v1/directories` | 文档目录树 |
| GET | `/api/v1/documents/{id}` | 文档详情 |
| GET | `/api/v1/friend-links` | 友情链接 |
| GET | `/api/v1/projects` | 项目列表 |
| GET | `/api/v1/texts/{id}` | 加密文本（需密码） |
| POST | `/api/v1/texts/{id}/verify` | 验证文本密码 |

### 管理接口（需要 Bearer Token）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/admin/stats` | 仪表盘统计 |
| POST | `/api/v1/admin/blogs` | 创建文章 |
| PUT | `/api/v1/admin/blogs/{id}` | 更新文章 |
| DELETE | `/api/v1/admin/blogs/{id}` | 删除文章 |
| POST | `/api/v1/admin/categories` | 创建分类 |
| PUT | `/api/v1/admin/categories/{id}` | 更新分类 |
| DELETE | `/api/v1/admin/categories/{id}` | 删除分类 |
| POST | `/api/v1/admin/tags` | 创建标签 |
| PUT | `/api/v1/admin/tags/{id}` | 更新标签 |
| DELETE | `/api/v1/admin/tags/{id}` | 删除标签 |
| POST | `/api/v1/admin/directories` | 创建目录 |
| PUT | `/api/v1/admin/directories/{id}` | 更新目录 |
| DELETE | `/api/v1/admin/directories/{id}` | 删除目录 |
| POST | `/api/v1/admin/documents` | 创建文档 |
| PUT | `/api/v1/admin/documents/{id}` | 更新文档 |
| DELETE | `/api/v1/admin/documents/{id}` | 删除文档 |
| POST | `/api/v1/admin/files/upload` | 上传文件 |
| DELETE | `/api/v1/admin/files/{id}` | 删除文件 |
| POST | `/api/v1/admin/friend-links` | 创建友链 |
| PUT | `/api/v1/admin/friend-links/{id}` | 更新友链 |
| DELETE | `/api/v1/admin/friend-links/{id}` | 删除友链 |
| POST | `/api/v1/admin/projects` | 创建项目 |
| PUT | `/api/v1/admin/projects/{id}` | 更新项目 |
| DELETE | `/api/v1/admin/projects/{id}` | 删除项目 |
| POST | `/api/v1/admin/texts` | 创建加密文本 |
| PUT | `/api/v1/admin/texts/{id}` | 更新文本 |
| DELETE | `/api/v1/admin/texts/{id}` | 删除文本 |
| GET | `/api/v1/admin/config` | 获取站点配置 |
| PUT | `/api/v1/admin/config` | 批量更新配置 |
| POST | `/api/v1/admin/auth/change-password` | **修改密码** |
| POST | `/api/v1/admin/data/export` | 导出数据 |
| POST | `/api/v1/admin/data/import` | 导入数据 |
| POST | `/api/v1/admin/data/import-sql` | 导入 SQL |
| GET | `/api/v1/admin/mcp/settings` | MCP 配置 |
| PUT | `/api/v1/admin/mcp/settings` | 更新 MCP 配置 |
| POST | `/api/v1/admin/mcp/token/rotate` | 轮换 MCP Token |
| POST | `/api/v1/admin/ai/summarize` | AI 生成摘要 |
| POST | `/api/v1/admin/ai/polish` | AI 润色文本 |
| POST | `/api/v1/admin/ai/batch-preview` | AI 批量预览 |
| POST | `/api/v1/admin/ai/batch-confirm` | AI 批量确认 |
| POST | `/api/v1/admin/ai/batch-summarize-all` | AI 批量摘要 |
| GET | `/api/v1/admin/ai/status` | AI 功能状态 |

### MCP Server

| 方法 | 路径 | 说明 |
|------|------|------|
| GET/POST | `/mcp` | MCP Streamable HTTP 端点 |

---

## 🏗️ 架构说明

```
                        ┌──────────────────┐
                        │   客户端浏览器     │
                        └────────┬─────────┘
                                 │ :3000
                                 ▼
                        ┌──────────────────┐
                        │  Stellux 前端     │
                        │  (Next.js 16)    │─── SSR ──┐
                        │  代理 /api/v1/*  │          │
                        └────────┬─────────┘          │
                                 │ rewrites           │
                                 ▼                    ▼
                        ┌─────────────────────────────────┐
                        │        Stellux 后端              │
                        │      (Rust/Axum) :8088          │
                        │   + MCP Server (/mcp)           │
                        └────────┬────────────────────────┘
                                 │
                ┌────────────────┼────────────────┐
                │                │                │
                ▼                ▼                ▼
       ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
       │  PostgreSQL   │ │    Redis      │ │   RustFS     │
       │   15 Alpine   │ │   7 Alpine    │ │  (S3 兼容)   │
       │  :5432       │ │   :6379       │ │  :9000/9001  │
       └──────────────┘ └──────────────┘ └──────────────┘
```

### 请求流程

1. 浏览器访问 `http://server:3000`
2. Next.js 处理页面渲染（SSR/CSR）
3. API 请求 `/api/v1/*` 通过 Next.js rewrites 代理到后端 `:8088`
4. 后端验证 JWT Token（管理接口）
5. 查询 PostgreSQL / Redis
6. 文件操作通过 RustFS (S3 兼容)

---

## 📦 技术栈

| 层 | 技术 | 版本 |
|---|------|------|
| **后端** | Rust | 1.92 |
| | Axum | 0.8 |
| | SQLx | 0.8 (PostgreSQL) |
| | Redis | 7 |
| | Argon2 | 密码哈希 |
| | JWT | 认证 |
| | AWS S3 SDK | 文件存储 |
| | rmcp | MCP Server |
| **前端** | Next.js | 16.1.6 |
| | React | 19 |
| | TypeScript | 5 |
| | TailwindCSS | 4 |
| | Shadcn UI | Radix UI |
| | Zustand | 状态管理 |
| | react-md-editor | Markdown 编辑 |
| **数据库** | PostgreSQL | 15 Alpine |
| | Redis | 7 Alpine |
| | RustFS | S3 兼容存储 |
| **部署** | Docker | 29+ |
| | Docker Compose | V5 |
| | GitHub Actions | CI/CD |
| | Docker Hub | 镜像仓库 |

### 数据库表结构

| 表名 | 说明 |
|------|------|
| `users` | 管理员用户 |
| `blogs` | 博客文章 |
| `blog_tags` | 文章-标签关联 |
| `categories` | 文章分类 |
| `tags` | 标签 |
| `directories` | 文档目录（树形） |
| `documents` | 文档 |
| `files` | 文件记录 |
| `friend_links` | 友情链接 |
| `projects` | 项目 |
| `texts` | 加密临时文本 |
| `site_config` | 站点配置（KV） |

---

## ⚙️ 环境变量

| 变量 | 必填 | 说明 | 默认值 |
|------|:----:|------|--------|
| `POSTGRES_PASSWORD` | ✅ | 数据库密码 | - |
| `JWT_SECRET` | ✅ | JWT 密钥（≥32 字符） | - |
| `RUSTFS_SECRET_KEY` | ✅ | 文件存储密钥 | - |
| `NEXT_PUBLIC_API_URL` | | 前端 API 地址 | `/api/v1` |
| `BACKEND_PORT` | | 后端外部端口 | `8080` |
| `FRONTEND_PORT` | | 前端外部端口 | `3000` |
| `POSTGRES_PORT` | | 数据库端口 | `5432` |
| `ADMIN_USERNAME` | | 管理员用户名 | `admin` |
| `ADMIN_PASSWORD` | | 管理员密码 | `admin123` |
| `RUST_LOG` | | 日志级别 | `warn` |
| `SERVER_MAX_BODY_SIZE_MB` | | 上传大小限制 | `50` |
| `JWT_ACCESS_TOKEN_EXPIRE_HOURS` | | Token 有效期(小时) | `720` |
| `JWT_REFRESH_TOKEN_EXPIRE_DAYS` | | 刷新 Token 有效期(天) | `30` |

---

## 🐳 Docker 镜像

```bash
docker pull sexyfeifan/stellux-backend:latest
docker pull sexyfeifan/stellux-frontend:latest
```

| 镜像 | Docker Hub |
|------|------------|
| 后端 | [sexyfeifan/stellux-backend](https://hub.docker.com/r/sexyfeifan/stellux-backend) |
| 前端 | [sexyfeifan/stellux-frontend](https://hub.docker.com/r/sexyfeifan/stellux-frontend) |

---

## 💡 常用命令

```bash
# 查看状态
docker compose -f docker-compose.prod.yml ps

# 查看日志
docker logs -f stellux-backend
docker logs -f stellux-frontend

# 重启
docker compose -f docker-compose.prod.yml restart

# 停止
docker compose -f docker-compose.prod.yml down

# 停止并删除数据
docker compose -f docker-compose.prod.yml down -v

# 更新版本
git pull && docker compose -f docker-compose.prod.yml pull && docker compose -f docker-compose.prod.yml up -d
```

---

## 📁 项目结构

```
stellux/
├── backend/                    # Rust 后端
│   ├── src/
│   │   ├── main.rs            # 入口
│   │   ├── handlers/          # 请求处理器
│   │   ├── routes/            # 路由定义
│   │   ├── models/            # 数据模型
│   │   ├── repositories/      # 数据访问层
│   │   ├── services/          # 业务逻辑
│   │   ├── middleware/        # JWT 认证中间件
│   │   ├── mcp/               # MCP Server
│   │   └── utils/             # 工具函数
│   ├── migrations/            # 数据库迁移（自动执行）
│   └── Dockerfile
├── frontend/                   # Next.js 前端
│   ├── src/
│   │   ├── app/               # App Router 页面
│   │   │   ├── (blog)/        # 前台博客页面
│   │   │   └── admin/         # 后台管理页面
│   │   ├── components/        # UI 组件
│   │   ├── lib/               # API 客户端
│   │   └── types/             # TypeScript 类型
│   ├── next.config.ts         # Next.js 配置（含 API 代理）
│   └── Dockerfile
├── docker-compose.prod.yml    # 生产环境部署
├── .env.example               # 环境变量模板
├── deploy.sh                  # 一键部署脚本
└── README.md
```

---

## 📄 License

MIT License

---

<p align="center">
  <sub>Built with ❤️ using Rust + Next.js</sub>
</p>
