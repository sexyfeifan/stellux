#!/bin/bash
# ============================================
# Blog System - One-Click Deploy Script
# ============================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Blog System - Docker Deploy Script    ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed.${NC}"
    echo "Install: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not available.${NC}"
    exit 1
fi

# Check .env
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo -e "${YELLOW}.env not found, copying from .env.example...${NC}"
        cp .env.example .env
        echo -e "${RED}Please edit .env and set required values:${NC}"
        echo "  - POSTGRES_PASSWORD"
        echo "  - JWT_SECRET (min 32 chars)"
        echo "  - RUSTFS_SECRET_KEY"
        echo "  - NEXT_PUBLIC_API_URL (your server IP)"
        echo ""
        echo "Then run this script again."
        exit 1
    else
        echo -e "${RED}Error: .env.example not found.${NC}"
        exit 1
    fi
fi

# Validate required vars
source .env
ERRORS=0

if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "your-secure-password-here" ]; then
    echo -e "${RED}Error: POSTGRES_PASSWORD not set in .env${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ -z "$JWT_SECRET" ] || [ "$JWT_SECRET" = "your-super-secret-jwt-key-at-least-32-characters" ]; then
    echo -e "${RED}Error: JWT_SECRET not set in .env${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ -z "$RUSTFS_SECRET_KEY" ] || [ "$RUSTFS_SECRET_KEY" = "your-secure-rustfs-secret-key" ]; then
    echo -e "${RED}Error: RUSTFS_SECRET_KEY not set in .env${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -gt 0 ]; then
    echo ""
    echo -e "${RED}Please fix the above errors in .env and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}Configuration validated.${NC}"
echo ""

# Deploy
echo -e "${YELLOW}Starting services...${NC}"
docker compose -f docker-compose.prod.yml up -d

echo ""
echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
sleep 10

# Check status
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Service Status                        ${NC}"
echo -e "${GREEN}========================================${NC}"
docker compose -f docker-compose.prod.yml ps

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deploy Complete!                      ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  Blog:      http://$(hostname -I | awk '{print $1}'):${FRONTEND_PORT:-3000}"
echo "  API:       http://$(hostname -I | awk '{print $1}'):${BACKEND_PORT:-8088}/api/v1"
echo "  RustFS:    http://$(hostname -I | awk '{print $1}'):9101"
echo ""
echo "  Admin:     http://$(hostname -I | awk '{print $1}'):${FRONTEND_PORT:-3000}/admin/login"
echo ""
