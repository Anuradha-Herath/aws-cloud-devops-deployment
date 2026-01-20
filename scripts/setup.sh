#!/bin/bash

#############################################################
# AWS EC2 Server Setup Script for DevOps Web App
# This script sets up a fresh Ubuntu server with all
# required dependencies for running the containerized app
#############################################################

set -e  # Exit on any error

echo "================================================"
echo "  AWS EC2 Server Setup for DevOps Web App"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should NOT be run as root${NC}"
   echo "Please run as a regular user with sudo privileges"
   exit 1
fi

echo -e "${YELLOW}Step 1: Updating system packages...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

echo ""
echo -e "${YELLOW}Step 2: Installing essential packages...${NC}"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    vim \
    wget \
    software-properties-common \
    ufw

echo ""
echo -e "${YELLOW}Step 3: Installing Docker...${NC}"
# Remove old Docker versions if any
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

echo ""
echo -e "${YELLOW}Step 4: Installing Docker Compose (standalone)...${NC}"
DOCKER_COMPOSE_VERSION="v2.24.5"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo ""
echo -e "${YELLOW}Step 5: Configuring UFW Firewall...${NC}"
# Reset UFW to default
sudo ufw --force reset

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (IMPORTANT - don't lock yourself out!)
sudo ufw allow 22/tcp comment 'SSH'

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Allow Netdata monitoring (optional - can be restricted)
sudo ufw allow 19999/tcp comment 'Netdata Monitoring'

# Enable UFW
echo "y" | sudo ufw enable

echo ""
echo -e "${YELLOW}Step 6: Installing Netdata (optional)...${NC}"
read -p "Do you want to install Netdata monitoring? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Install Netdata using kickstart script
    bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait --stable-channel
    
    echo ""
    echo -e "${GREEN}Netdata installed successfully!${NC}"
    echo "Access it at: http://YOUR_SERVER_IP:19999"
fi

echo ""
echo -e "${YELLOW}Step 7: Creating application directory...${NC}"
APP_DIR="$HOME/app"
mkdir -p $APP_DIR
cd $APP_DIR

echo ""
echo -e "${YELLOW}Step 8: Setting up Git for deployment...${NC}"
read -p "Enter your Git repository URL (or press Enter to skip): " GIT_REPO

if [ ! -z "$GIT_REPO" ]; then
    git clone $GIT_REPO $APP_DIR/source
    echo -e "${GREEN}Repository cloned successfully!${NC}"
else
    echo "Skipping Git setup. You can manually clone your repo later."
fi

echo ""
echo -e "${YELLOW}Step 9: Enabling Docker service...${NC}"
sudo systemctl enable docker
sudo systemctl start docker

echo ""
echo "================================================"
echo -e "${GREEN}  Server Setup Complete! ✓${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Log out and log back in for Docker group changes to take effect"
echo "2. Upload your application code to: $APP_DIR"
echo "3. Run the deploy.sh script to start the application"
echo ""
echo "Firewall status:"
sudo ufw status numbered
echo ""
echo "Docker version:"
docker --version
docker compose version
echo ""
echo -e "${GREEN}Your server is ready for deployment!${NC}"
