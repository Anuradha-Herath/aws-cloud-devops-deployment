#!/bin/bash

###############################################################
# Health Check Script for DevOps Web App
# Checks the status of all services and sends alerts if needed
###############################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "================================================"
echo "  Health Check - DevOps Web App"
echo "================================================"
echo ""

# Check if containers are running
echo -e "${YELLOW}Checking container status...${NC}"
docker compose ps
echo ""

# Check web app health
echo -e "${YELLOW}Checking application health endpoint...${NC}"
if curl -f http://localhost/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Application is healthy${NC}"
    curl -s http://localhost/api/health | jq . 2>/dev/null || curl -s http://localhost/api/health
else
    echo -e "${RED}✗ Application health check failed${NC}"
fi
echo ""

# Check Nginx
echo -e "${YELLOW}Checking Nginx status...${NC}"
if docker compose ps nginx | grep -q "Up"; then
    echo -e "${GREEN}✓ Nginx is running${NC}"
else
    echo -e "${RED}✗ Nginx is not running${NC}"
fi
echo ""

# Check Netdata
echo -e "${YELLOW}Checking Netdata status...${NC}"
if docker compose ps netdata | grep -q "Up"; then
    echo -e "${GREEN}✓ Netdata is running${NC}"
    echo "Access at: http://localhost:19999"
else
    echo -e "${YELLOW}⚠ Netdata is not running${NC}"
fi
echo ""

# Check disk space
echo -e "${YELLOW}Checking disk space...${NC}"
df -h | grep -E "Filesystem|/dev/"
echo ""

# Check memory usage
echo -e "${YELLOW}Checking memory usage...${NC}"
free -h
echo ""

# Recent logs
echo -e "${YELLOW}Recent application logs:${NC}"
docker compose logs --tail=10 app
echo ""

echo "================================================"
echo "  Health Check Complete"
echo "================================================"
