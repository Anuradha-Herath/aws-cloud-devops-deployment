#!/bin/bash

#############################################################
# Deployment Script for DevOps Web App
# Pulls latest code, rebuilds containers, and restarts services
#############################################################

set -e  # Exit on any error

echo "================================================"
echo "  Deploying DevOps Web Application"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$APP_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${BLUE}Deployment started at: $(date)${NC}"
echo -e "${BLUE}Application directory: $APP_DIR${NC}"
echo ""

# Function to handle errors
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Function to create backup
create_backup() {
    echo -e "${YELLOW}Creating backup...${NC}"
    mkdir -p $BACKUP_DIR
    
    if [ -f "$APP_DIR/.env" ]; then
        cp "$APP_DIR/.env" "$BACKUP_DIR/.env.$TIMESTAMP"
        echo -e "${GREEN}Environment file backed up${NC}"
    fi
    
    # Backup docker-compose.yml if exists
    if [ -f "$APP_DIR/docker-compose.yml" ]; then
        cp "$APP_DIR/docker-compose.yml" "$BACKUP_DIR/docker-compose.yml.$TIMESTAMP"
        echo -e "${GREEN}Docker Compose file backed up${NC}"
    fi
}

# Step 1: Check if Docker is running
echo -e "${YELLOW}Step 1: Checking Docker status...${NC}"
if ! docker info > /dev/null 2>&1; then
    error_exit "Docker is not running. Please start Docker first."
fi
echo -e "${GREEN}✓ Docker is running${NC}"
echo ""

# Step 2: Pull latest code from Git (if in a git repo)
echo -e "${YELLOW}Step 2: Pulling latest code...${NC}"
if [ -d "$APP_DIR/.git" ]; then
    git fetch origin
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "Current branch: $CURRENT_BRANCH"
    
    read -p "Pull latest changes from $CURRENT_BRANCH? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git pull origin $CURRENT_BRANCH || error_exit "Failed to pull latest code"
        echo -e "${GREEN}✓ Code updated successfully${NC}"
    else
        echo "Skipping code update"
    fi
else
    echo "Not a Git repository. Skipping code pull."
fi
echo ""

# Step 3: Create backup
create_backup
echo ""

# Step 4: Stop existing containers
echo -e "${YELLOW}Step 3: Stopping existing containers...${NC}"
if [ -f "$APP_DIR/docker-compose.yml" ]; then
    docker compose down || echo "No containers to stop"
    echo -e "${GREEN}✓ Containers stopped${NC}"
else
    error_exit "docker-compose.yml not found in $APP_DIR"
fi
echo ""

# Step 5: Remove old images (optional)
read -p "Remove old Docker images to free up space? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Removing unused Docker images...${NC}"
    docker image prune -f
    echo -e "${GREEN}✓ Old images removed${NC}"
fi
echo ""

# Step 6: Build new images
echo -e "${YELLOW}Step 4: Building Docker images...${NC}"
docker compose build --no-cache || error_exit "Failed to build Docker images"
echo -e "${GREEN}✓ Images built successfully${NC}"
echo ""

# Step 7: Start containers
echo -e "${YELLOW}Step 5: Starting containers...${NC}"
docker compose up -d || error_exit "Failed to start containers"
echo -e "${GREEN}✓ Containers started successfully${NC}"
echo ""

# Step 8: Wait for services to be ready
echo -e "${YELLOW}Step 6: Waiting for services to be ready...${NC}"
sleep 10

# Check health status
echo "Checking container health..."
docker compose ps
echo ""

# Step 9: Test application health
echo -e "${YELLOW}Step 7: Testing application health...${NC}"
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Application is healthy!${NC}"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "Waiting for application... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep 2
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${RED}Warning: Application health check failed${NC}"
    echo "Checking logs..."
    docker compose logs --tail=50
else
    echo ""
fi

# Step 10: Show logs
echo ""
echo -e "${YELLOW}Recent logs:${NC}"
docker compose logs --tail=20
echo ""

# Step 11: Display access information
echo "================================================"
echo -e "${GREEN}  Deployment Complete! ✓${NC}"
echo "================================================"
echo ""
echo "Application Status:"
docker compose ps
echo ""
echo "Access your application:"
echo -e "${GREEN}➜ Web App: http://YOUR_SERVER_IP${NC}"
echo -e "${GREEN}➜ Health Check: http://YOUR_SERVER_IP/api/health${NC}"
echo -e "${GREEN}➜ System Info: http://YOUR_SERVER_IP/api/info${NC}"
echo -e "${GREEN}➜ Netdata: http://YOUR_SERVER_IP:19999${NC}"
echo ""
echo "Useful commands:"
echo "  View logs:       docker compose logs -f"
echo "  Stop services:   docker compose down"
echo "  Restart:         docker compose restart"
echo "  Status:          docker compose ps"
echo ""
echo -e "${BLUE}Deployment completed at: $(date)${NC}"
