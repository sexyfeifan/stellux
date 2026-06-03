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

# ---- Default admin credentials ----
ADMIN_USER="admin"
ADMIN_PASS="admin123"

# ---- Generate .env ----
if [ -f .env ]; then
    echo -e "${YELLOW}⚠ .env already exists, using existing config.${NC}"
    source .env
else
    echo -e "${CYAN}Generating configuration...${NC}"
    echo ""

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

# === API URL (通过 Next.js 代理，使用相对路径) ===
NEXT_PUBLIC_API_URL=/api/v1

# === Ports ===
BACKEND_PORT=8080
FRONTEND_PORT=3000
POSTGRES_PORT=5432

# === Admin Account ===
ADMIN_USERNAME=${ADMIN_USER}
ADMIN_PASSWORD=${ADMIN_PASS}

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
for i in $(seq 1 30); do
    HEALTHY=$(docker ps --filter health=healthy --format '{{.Names}}' | grep -c stellux-backend || true)
    if [ "$HEALTHY" -ge 1 ]; then
        break
    fi
    sleep 2
done

# ---- Create admin account ----
echo ""
echo -e "${CYAN}Creating admin account...${NC}"
RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://localhost:${BACKEND_PORT:-8080}/api/v1/auth/setup" \
    -H 'Content-Type: application/json' \
    -d "{\"username\":\"${ADMIN_USER}\",\"password\":\"${ADMIN_PASS}\"}" 2>/dev/null || echo "000")

if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ Admin account created${NC}"
elif [ "$RESPONSE" = "409" ]; then
    echo -e "${YELLOW}⚠ Admin account already exists${NC}"
else
    echo -e "${YELLOW}⚠ Admin setup returned HTTP $RESPONSE (may already exist)${NC}"
fi

# ---- Get server IP ----
SERVER_IP=$(hostname -I | awk '{print $1}')

# ---- Status ----
echo ""
echo -e "${GREEN}${BOLD}  ╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}  ║        ✦  Deploy Complete!  ✦       ║${NC}"
echo -e "${GREEN}${BOLD}  ╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Blog:${NC}     http://${SERVER_IP}:${FRONTEND_PORT:-3000}"
echo -e "  ${BOLD}Admin:${NC}    http://${SERVER_IP}:${FRONTEND_PORT:-3000}/admin/login"
echo -e "  ${BOLD}RustFS:${NC}   http://${SERVER_IP}:9101"
echo ""
echo -e "  ${BOLD}Admin Login:${NC}"
echo -e "    Username:  ${CYAN}${ADMIN_USER}${NC}"
echo -e "    Password:  ${CYAN}${ADMIN_PASS}${NC}"
echo ""
echo -e "${CYAN}  docker compose -f docker-compose.prod.yml ps    ${NC}# 查看状态"
echo -e "${CYAN}  docker logs -f stellux-backend                  ${NC}# 查看日志"
echo ""
