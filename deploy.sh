#!/bin/bash
# ============================================
#  Stellux - One-Click Deploy Script
#  Usage: curl -fsSL https://raw.githubusercontent.com/sexyfeifan/stellux/main/deploy.sh | bash
# ============================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}  ╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}  ║        ✦  Stellux  Deploy  ✦        ║${NC}"
echo -e "${CYAN}${BOLD}  ║    High-Performance Blog System      ║${NC}"
echo -e "${CYAN}${BOLD}  ╚══════════════════════════════════════╝${NC}"
echo ""

# ---- Check Docker ----
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed.${NC}"
    echo -e "${YELLOW}  Installing Docker...${NC}"
    curl -fsSL https://get.docker.com | sh
    echo -e "${GREEN}✓ Docker installed.${NC}"
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}✗ Docker Compose is not available.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker $(docker --version | awk '{print $3}')${NC}"
echo -e "${GREEN}✓ $(docker compose version)${NC}"
echo ""

# ---- Generate .env ----
if [ -f .env ]; then
    echo -e "${YELLOW}⚠ .env already exists, using existing config.${NC}"
    source .env
else
    echo -e "${CYAN}Generating configuration...${NC}"
    echo ""

    # Get server IP
    SERVER_IP=$(hostname -I | awk '{print $1}')

    # Generate random passwords
    PG_PASS=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 20)
    JWT_SECRET=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 40)
    RUSTFS_PASS=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9' | head -c 20)

    cat > .env << EOF
# ============================================
# Stellux - Docker Environment Config
# ============================================

# === Required ===
POSTGRES_PASSWORD=${PG_PASS}
JWT_SECRET=${JWT_SECRET}
RUSTFS_SECRET_KEY=${RUSTFS_PASS}

# === API URL (浏览器访问后端的地址) ===
NEXT_PUBLIC_API_URL=http://${SERVER_IP}:8088/api/v1

# === Ports ===
BACKEND_PORT=8088
FRONTEND_PORT=3000
POSTGRES_PORT=5432

# === Optional ===
POSTGRES_DB=stellux
POSTGRES_USER=stellux
RUSTFS_ACCESS_KEY=stelluxadmin
JWT_ACCESS_TOKEN_EXPIRE_HOURS=720
JWT_REFRESH_TOKEN_EXPIRE_DAYS=30
RUST_LOG=warn
SERVER_MAX_BODY_SIZE_MB=50
DATABASE_MAX_CONNECTIONS=25
DATABASE_MIN_CONNECTIONS=3
EOF

    echo -e "${GREEN}✓ .env generated${NC}"
    echo ""
    echo -e "${BOLD}  Generated credentials (saved in .env):${NC}"
    echo -e "  DB Password:    ${CYAN}${PG_PASS}${NC}"
    echo -e "  JWT Secret:     ${CYAN}${JWT_SECRET}${NC}"
    echo -e "  RustFS Secret:  ${CYAN}${RUSTFS_PASS}${NC}"
    echo ""
    source .env
fi

# ---- Clone repo if needed ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -f "docker-compose.prod.yml" ]; then
    echo -e "${YELLOW}Downloading Stellux...${NC}"
    REPO_URL="https://github.com/sexyfeifan/stellux.git"
    git clone --depth 1 "$REPO_URL" /opt/stellux 2>/dev/null || true
    cd /opt/stellux
    echo -e "${GREEN}✓ Downloaded to /opt/stellux${NC}"
fi

# ---- Pull images ----
echo ""
echo -e "${CYAN}Pulling Docker images...${NC}"
docker compose -f docker-compose.prod.yml pull 2>/dev/null || {
    echo -e "${YELLOW}Pre-built images not available, building from source...${NC}"
    docker compose -f docker-compose.prod.yml build
}
echo -e "${GREEN}✓ Images ready${NC}"

# ---- Start services ----
echo ""
echo -e "${CYAN}Starting services...${NC}"
docker compose -f docker-compose.prod.yml up -d

echo ""
echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
sleep 15

# ---- Status ----
echo ""
echo -e "${GREEN}${BOLD}  ╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}  ║        ✦  Deploy Complete!  ✦       ║${NC}"
echo -e "${GREEN}${BOLD}  ╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Blog:${NC}     http://${SERVER_IP}:${FRONTEND_PORT:-3000}"
echo -e "  ${BOLD}Admin:${NC}    http://${SERVER_IP}:${FRONTEND_PORT:-3000}/admin/login"
echo -e "  ${BOLD}API:${NC}      http://${SERVER_IP}:${BACKEND_PORT:-8088}/api/v1"
echo -e "  ${BOLD}RustFS:${NC}   http://${SERVER_IP}:9101"
echo ""
echo -e "  ${BOLD}First visit → create admin account${NC}"
echo ""
echo -e "${CYAN}  docker compose -f docker-compose.prod.yml ps    ${NC}# 查看状态"
echo -e "${CYAN}  docker logs -f stellux-backend                  ${NC}# 查看日志"
echo ""
