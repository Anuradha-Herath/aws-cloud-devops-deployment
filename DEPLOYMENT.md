# 📋 Deployment Guide - Cloud DevOps Web Application

Complete step-by-step guide for deploying the containerized Next.js application on AWS EC2 with Docker, Nginx, and Netdata monitoring.

## 📚 Table of Contents

1. [AWS EC2 Setup](#1-aws-ec2-setup)
2. [Server Configuration](#2-server-configuration)
3. [Application Deployment](#3-application-deployment)
4. [Post-Deployment Verification](#4-post-deployment-verification)
5. [Maintenance & Updates](#5-maintenance--updates)
6. [Monitoring Setup](#6-monitoring-setup)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. AWS EC2 Setup

### 1.1 Launch EC2 Instance

1. **Log into AWS Console**
   - Navigate to EC2 Dashboard
   - Click "Launch Instance"

2. **Configure Instance**
   ```
   Name: devops-webapp-server
   AMI: Ubuntu Server 22.04 LTS (64-bit x86)
   Instance Type: t2.micro (Free tier) or t2.small (recommended)
   Key Pair: Create new or select existing
   ```

3. **Configure Storage**
   ```
   Size: 20 GB (minimum)
   Type: gp3 (General Purpose SSD)
   ```

### 1.2 Configure Security Group

Create a new security group with these inbound rules:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | Your IP | SSH access |
| HTTP | TCP | 80 | 0.0.0.0/0 | Web application |
| HTTPS | TCP | 443 | 0.0.0.0/0 | SSL (future) |
| Custom TCP | TCP | 19999 | Your IP | Netdata monitoring |

**Security Note**: Restrict SSH (port 22) and Netdata (port 19999) to your IP address only.

### 1.3 Launch and Connect

```bash
# Wait for instance to start (2-3 minutes)
# Note the Public IPv4 address

# Connect via SSH
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# On Windows, use PuTTY or WSL
```

---

## 2. Server Configuration

### 2.1 Update System

```bash
# Update package lists
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade -y

# Reboot if kernel was updated
sudo reboot
```

### 2.2 Run Automated Setup

```bash
# Create app directory
mkdir -p ~/app
cd ~/app

# Upload setup.sh (using SCP or git clone)
# Option 1: Using SCP from your local machine
scp -i your-key.pem scripts/setup.sh ubuntu@YOUR_EC2_IP:~/app/scripts/

# Option 2: Clone from GitHub
git clone <your-repo-url> .

# Make script executable
chmod +x scripts/setup.sh

# Run setup script
./scripts/setup.sh
```

**The setup script will:**
- Install Docker & Docker Compose
- Configure UFW firewall
- Install Netdata (optional)
- Set up application directory
- Configure system services

### 2.3 Post-Setup Steps

```bash
# IMPORTANT: Log out and back in for Docker group changes
exit

# SSH back in
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Verify Docker installation
docker --version
docker compose version

# Check firewall status
sudo ufw status
```

---

## 3. Application Deployment

### 3.1 Prepare Application Code

**Option A: Clone from GitHub (Recommended)**
```bash
cd ~/app
git clone <your-repository-url> .
```

**Option B: Upload Files via SCP**
```bash
# From your local machine
scp -i your-key.pem -r * ubuntu@YOUR_EC2_IP:~/app/
```

### 3.2 Configure Environment (Optional)

```bash
# Create .env file if needed
nano .env

# Add environment variables
NODE_ENV=production
# Add other variables as needed
```

### 3.3 Run Deployment Script

```bash
cd ~/app

# Make deploy script executable
chmod +x scripts/deploy.sh

# Run deployment
./scripts/deploy.sh
```

**The deployment script will:**
1. ✅ Check Docker status
2. ✅ Pull latest code (if Git repo)
3. ✅ Create backup of current configuration
4. ✅ Stop existing containers
5. ✅ Build new Docker images
6. ✅ Start all containers
7. ✅ Run health checks
8. ✅ Display access information

### 3.4 Manual Deployment (Alternative)

```bash
# Build and start containers
docker compose up -d --build

# View logs
docker compose logs -f

# Check status
docker compose ps
```

---

## 4. Post-Deployment Verification

### 4.1 Check Container Status

```bash
# View running containers
docker compose ps

# Expected output:
# nextjs-app    running
# nginx-proxy   running
# netdata       running (optional)
```

### 4.2 Test Application Endpoints

```bash
# Test main application
curl http://localhost

# Test health endpoint
curl http://localhost/api/health

# Expected response:
# {"status":"healthy","timestamp":"...","uptime":123,"service":"cloud-devops-webapp"}

# Test system info endpoint
curl http://localhost/api/info
```

### 4.3 External Access Test

From your local machine:
```bash
# Test web application
curl http://YOUR_EC2_PUBLIC_IP

# Test health endpoint
curl http://YOUR_EC2_PUBLIC_IP/api/health

# Access in browser
# http://YOUR_EC2_PUBLIC_IP
# http://YOUR_EC2_PUBLIC_IP:19999 (Netdata)
```

### 4.4 Run Health Check Script

```bash
chmod +x scripts/health-check.sh
./scripts/health-check.sh
```

---

## 5. Maintenance & Updates

### 5.1 Update Application

```bash
cd ~/app

# Pull latest changes
git pull origin main

# Redeploy
./scripts/deploy.sh
```

### 5.2 View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f nginx

# Last 50 lines
docker compose logs --tail=50 app
```

### 5.3 Restart Services

```bash
# Restart all containers
docker compose restart

# Restart specific service
docker compose restart app
docker compose restart nginx
```

### 5.4 Stop/Start Application

```bash
# Stop all services
docker compose down

# Start all services
docker compose up -d

# Stop and remove volumes (CAUTION: deletes data)
docker compose down -v
```

---

## 6. Monitoring Setup

### 6.1 Access Netdata Dashboard

```
URL: http://YOUR_EC2_PUBLIC_IP:19999
```

**Available Metrics:**
- System resources (CPU, RAM, Disk)
- Network traffic
- Docker container stats
- Application performance

### 6.2 Configure Netdata Alerts (Optional)

```bash
# Edit Netdata config
sudo nano /etc/netdata/health_alarm_notify.conf

# Add email/Slack notifications
# Restart Netdata
sudo systemctl restart netdata
```

### 6.3 Set Up External Monitoring (Optional)

**UptimeRobot Configuration:**
1. Sign up at https://uptimerobot.com
2. Add new monitor:
   - Type: HTTP(S)
   - URL: `http://YOUR_EC2_IP/api/health`
   - Interval: 5 minutes
3. Configure alerts (email/SMS)

---

## 7. Troubleshooting

### 7.1 Application Won't Start

```bash
# Check Docker service
sudo systemctl status docker

# Check container logs
docker compose logs app

# Rebuild without cache
docker compose build --no-cache
docker compose up -d
```

### 7.2 Cannot Access from Browser

```bash
# Check if containers are running
docker compose ps

# Check if ports are listening
sudo netstat -tlnp | grep -E '(80|3000)'

# Check UFW firewall
sudo ufw status

# Test locally first
curl http://localhost
```

### 7.3 Out of Memory

```bash
# Check memory usage
free -h

# Check Docker stats
docker stats

# Increase swap (if needed)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 7.4 Port Already in Use

```bash
# Find process using port 80
sudo lsof -i :80

# Kill the process (if safe)
sudo kill -9 <PID>

# Or change Docker compose port mapping
# Edit docker-compose.yml: "8080:80" instead of "80:80"
```

### 7.5 Docker Build Fails

```bash
# Clean Docker cache
docker system prune -a

# Check disk space
df -h

# Remove unused images
docker image prune -a

# Rebuild with verbose output
docker compose build --progress=plain
```

### 7.6 Connection Timeout

```bash
# Verify security group allows port 80
# Check AWS EC2 Console → Security Groups

# Verify UFW is not blocking
sudo ufw status numbered

# Test from server itself
curl http://localhost
```

---

## 📞 Support & Resources

### Useful Commands

```bash
# View all running containers
docker ps

# Execute commands in container
docker compose exec app sh

# Check Nginx config
docker compose exec nginx nginx -t

# View container resource usage
docker stats

# Clean up everything (CAUTION)
docker compose down -v
docker system prune -a
```

### Log Locations

```
Application Logs: docker compose logs app
Nginx Logs: docker compose logs nginx
Netdata Logs: /var/log/netdata/
System Logs: /var/log/syslog
```

### Performance Optimization

1. **Enable Nginx caching**
2. **Configure Docker resource limits**
3. **Set up CDN (CloudFlare)**
4. **Enable gzip compression** (already configured)
5. **Optimize Next.js build**

---

## ✅ Deployment Checklist

- [ ] AWS EC2 instance created
- [ ] Security groups configured
- [ ] SSH access verified
- [ ] setup.sh executed successfully
- [ ] Docker and Docker Compose installed
- [ ] UFW firewall configured
- [ ] Application code deployed
- [ ] Containers built and running
- [ ] Health checks passing
- [ ] External access verified
- [ ] Netdata accessible
- [ ] Monitoring configured
- [ ] Backup strategy planned
- [ ] Documentation updated

---

## 🎉 Congratulations!

Your application is now deployed and running on AWS EC2 with:
- ✅ Docker containerization
- ✅ Nginx reverse proxy
- ✅ Netdata monitoring
- ✅ Security hardening
- ✅ Automated deployment

**Next Steps:**
1. Set up SSL/TLS with Let's Encrypt (Optional)
2. Configure CI/CD pipeline (Optional)
3. Set up automated backups
4. Monitor application performance
5. Plan for scaling (load balancer, auto-scaling)

---

**Need help?** Open an issue on GitHub or contact the maintainer.
