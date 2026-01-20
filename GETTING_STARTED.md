# 🚀 Complete Step-by-Step Guide - First Time Deployment

A beginner-friendly guide to go from your GitHub repo to a live deployed application on AWS.

## 📋 Overview of What You'll Do

```
Phase 1: Local Testing        (Your Windows machine)
Phase 2: AWS Setup            (Create AWS account & EC2)
Phase 3: Server Configuration (Install Docker, setup)
Phase 4: Deploy Application   (Push code to server)
Phase 5: Verify & Monitor     (Check it's working)
Phase 6: Maintenance          (Keep it running)
```

---

## Phase 1: Local Testing (Your Machine)

### Step 1.1: Clone Your Repository

Open PowerShell and run:

```powershell
# Navigate to where you want to work
cd "$env:USERPROFILE\Documents"

# Clone your repository
git clone https://github.com/Anuradha-Herath/aws-cloud-devops-deployment.git
cd aws-cloud-devops-deployment

# Verify you're in the right folder
ls
```

**What you should see:**
```
pages/
nginx/
scripts/
Dockerfile
docker-compose.yml
README.md
package.json
... etc
```

### Step 1.2: Install Node.js (if not already installed)

Check if Node.js is installed:
```powershell
node --version
npm --version
```

If not installed:
1. Go to https://nodejs.org
2. Download LTS version (18.x or higher)
3. Install and restart PowerShell
4. Verify: `node --version`

### Step 1.3: Install Dependencies

```powershell
# Install npm packages
npm install

# This creates node_modules/ folder
# Wait for it to complete (2-3 minutes)
```

### Step 1.4: Test Locally (Development Mode)

```powershell
# Start development server
npm run dev

# You should see:
# ➜ Local: http://localhost:3000
```

**Open in browser:**
- http://localhost:3000 → Should see your app with purple gradient
- http://localhost:3000/api/health → Should return JSON
- http://localhost:3000/api/info → Should return system info

**Stop server:** Press `Ctrl + C`

### Step 1.5: Test with Docker Locally (Optional but Recommended)

```powershell
# Check if Docker Desktop is installed
docker --version
docker compose --version

# If not installed, download from https://www.docker.com/products/docker-desktop

# Build and run with Docker
docker compose up -d --build

# Check containers are running
docker compose ps

# Test the app
curl http://localhost      # Should work
curl http://localhost/api/health

# View logs
docker compose logs -f

# Stop containers
docker compose down
```

**If Docker gives errors:**
- Make sure Docker Desktop is running (check taskbar)
- Restart Docker Desktop
- Try again

---

## Phase 2: AWS Setup (30-45 minutes)

### Step 2.1: Create AWS Account

1. Go to https://aws.amazon.com
2. Click "Create AWS Account"
3. Fill in your details
4. Add payment method (you won't be charged for free tier)
5. Verify email

**Free Tier includes:**
- 1 year free
- t2.micro EC2 instance (1 free)
- 30GB storage free

### Step 2.2: Create EC2 Instance

1. Log into AWS Console: https://console.aws.amazon.com
2. Search for "EC2" → Click EC2
3. Click "Launch Instance"

**Configuration:**
```
Name: devops-webapp-server

AMI: Ubuntu Server 22.04 LTS (Free tier)

Instance type: t2.micro (Free tier)

Key pair:
  - Click "Create new key pair"
  - Name: devops-webapp-key
  - Type: RSA
  - Format: .pem
  - Click "Create key pair"
  - SAVE THIS FILE! (devops-webapp-key.pem)

Storage:
  - Size: 20 GB
  - Type: gp3

Security group - Click "Create security group":
  - Name: devops-webapp-sg
  - Description: Security group for DevOps app
  
  - Inbound rules:
    ✓ SSH (22) - Source: My IP
    ✓ HTTP (80) - Source: Anywhere (0.0.0.0/0)
    ✓ HTTPS (443) - Source: Anywhere
    ✓ Custom TCP (19999) - Source: My IP (for Netdata)

Click "Launch instance"
```

**Wait 2-3 minutes for instance to start**

### Step 2.3: Connect to Your Server (From PowerShell)

Find your EC2 public IP:
1. Go to EC2 Dashboard
2. Click "Instances"
3. Click your instance name
4. Copy the "Public IPv4 address" (e.g., 54.123.45.67)

Connect via SSH:

```powershell
# Navigate to where you saved devops-webapp-key.pem
cd "$env:USERPROFILE\Downloads"

# First time only - Set proper permissions
icacls "devops-webapp-key.pem" /inheritance:r /grant:r "$env:USERNAME`:(F)"

# Connect to server
ssh -i "devops-webapp-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP

# Example:
# ssh -i "devops-webapp-key.pem" ubuntu@54.123.45.67

# Type "yes" when asked about fingerprint
```

**You should see:** `ubuntu@ip-xxx:~$` (prompt from server)

---

## Phase 3: Server Configuration (15-20 minutes)

**Important:** All these commands run ON THE SERVER (in SSH terminal)

### Step 3.1: Create App Directory

```bash
# Create directory for your app
mkdir -p ~/app
cd ~/app
```

### Step 3.2: Clone Your Repository on Server

```bash
# Clone your GitHub repo
git clone https://github.com/Anuradha-Herath/aws-cloud-devops-deployment.git .

# Verify files are here
ls

# You should see: pages/, nginx/, scripts/, Dockerfile, etc.
```

### Step 3.3: Run Server Setup Script

```bash
# Make setup script executable
chmod +x scripts/setup.sh

# Run setup (this takes 5-10 minutes)
./scripts/setup.sh

# The script will:
# - Update system packages
# - Install Docker
# - Install Docker Compose
# - Configure UFW firewall
# - Ask if you want Netdata (say "y" for yes)
```

**When asked about Netdata:**
- Type: `y` and press Enter
- This installs real-time monitoring

**After script finishes:**
```bash
# Log out and back in for Docker group changes
exit
```

Reconnect from PowerShell:
```powershell
ssh -i "devops-webapp-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
```

### Step 3.4: Verify Setup

```bash
# Check Docker is installed
docker --version
docker compose --version

# Check firewall
sudo ufw status

# You should see:
# Status: active
# 22/tcp (SSH)
# 80/tcp (HTTP)
# 443/tcp (HTTPS)
# 19999/tcp (Netdata)
```

---

## Phase 4: Deploy Application (5 minutes)

**Still on the server (in SSH terminal)**

### Step 4.1: Run Deployment Script

```bash
cd ~/app

# Make deployment script executable
chmod +x scripts/deploy.sh

# Run deployment
./scripts/deploy.sh

# The script will:
# - Check Docker is running
# - Build Docker images
# - Start containers
# - Run health checks
# - Show you access URLs
```

**Wait for it to complete** (5-10 minutes first time, 2-3 minutes after)

You'll see something like:
```
================================================
  Deployment Complete! ✓
================================================

Application Status:
CONTAINER ID   NAMES              STATUS
abc123def456   nextjs-app         Up 2 minutes
xyz789abc456   nginx-proxy        Up 2 minutes
def456xyz789   netdata-monitor    Up 2 minutes

Access your application:
➜ Web App: http://YOUR_EC2_PUBLIC_IP
➜ Health Check: http://YOUR_EC2_PUBLIC_IP/api/health
➜ System Info: http://YOUR_EC2_PUBLIC_IP/api/info
➜ Netdata: http://YOUR_EC2_PUBLIC_IP:19999
```

---

## Phase 5: Verify Everything Works

### Step 5.1: Test from Browser

Replace `54.123.45.67` with YOUR actual EC2 IP

```
http://54.123.45.67
http://54.123.45.67/api/health
http://54.123.45.67/api/info
http://54.123.45.67:19999
```

**What you should see:**

| URL | Expected |
|-----|----------|
| `http://IP/` | Purple gradient page with cards |
| `http://IP/api/health` | `{"status":"healthy",...}` |
| `http://IP/api/info` | JSON with server info |
| `http://IP:19999` | Netdata dashboard (colorful graphs) |

### Step 5.2: Check Server Health (from SSH)

```bash
cd ~/app

chmod +x scripts/health-check.sh
./scripts/health-check.sh

# Shows:
# - Container status
# - Health check results
# - Logs
# - Memory/Disk usage
```

---

## Phase 6: Keep Everything Running

### Step 6.1: View Logs

```bash
cd ~/app

# View all logs (last 20 lines)
docker compose logs --tail=20

# View specific service
docker compose logs app     # Next.js app
docker compose logs nginx   # Nginx proxy
docker compose logs netdata # Monitoring

# Follow logs in real-time
docker compose logs -f
# Press Ctrl+C to stop
```

### Step 6.2: Check Status

```bash
# Show running containers
docker compose ps

# Show system resources used
docker stats
```

### Step 6.3: Update Your Code

When you make changes locally:

```bash
# Local machine (PowerShell)
git add .
git commit -m "Fix: description of changes"
git push origin main

# Then on server (SSH)
cd ~/app
git pull origin main
./scripts/deploy.sh
```

### Step 6.4: Stop/Restart Services

```bash
# Stop all services
docker compose down

# Start services
docker compose up -d

# Restart specific service
docker compose restart app

# View status
docker compose ps
```

---

## 🎯 Common Tasks

### Restart Everything

```bash
cd ~/app
./scripts/deploy.sh
```

### View Recent Logs

```bash
cd ~/app
docker compose logs --tail=50 app
```

### Fix Common Issues

**Can't access the app:**
```bash
# Check if containers are running
docker compose ps

# Check if port 80 is listening
sudo netstat -tlnp | grep 80

# Check firewall
sudo ufw status
```

**Out of disk space:**
```bash
# Check disk
df -h

# Clean up Docker
docker system prune -a
```

**Need to rebuild:**
```bash
cd ~/app
docker compose down -v
./scripts/deploy.sh
```

---

## 📊 Monitoring Your App

### Real-Time Dashboard
```
http://YOUR_EC2_IP:19999
```

Shows:
- CPU usage
- Memory usage
- Disk space
- Network traffic
- Container metrics

### Health Check
```bash
# From anywhere
curl http://YOUR_EC2_IP/api/health

# On server
curl localhost/api/health
```

### Set Up Email Alerts (Optional)

If app goes down, send alert email:
1. Install UptimeRobot: https://uptimerobot.com
2. Create account
3. Add monitor:
   - Type: HTTP(S)
   - URL: `http://YOUR_EC2_IP/api/health`
   - Interval: 5 minutes
4. Add email for alerts

---

## ✅ Quick Reference Cheat Sheet

### Local Machine Commands
```powershell
# Clone repo
git clone https://github.com/Anuradha-Herath/aws-cloud-devops-deployment.git
cd aws-cloud-devops-deployment

# Install dependencies
npm install

# Test locally
npm run dev

# Push changes to GitHub
git add .
git commit -m "Your message"
git push origin main

# Connect to server
ssh -i "devops-webapp-key.pem" ubuntu@YOUR_EC2_IP
```

### Server Commands
```bash
# Navigate to app
cd ~/app

# Initial setup (one time)
chmod +x scripts/setup.sh
./scripts/setup.sh

# Deploy app
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Check status
docker compose ps

# View logs
docker compose logs -f

# Health check
./scripts/health-check.sh

# Update code
git pull origin main
./scripts/deploy.sh
```

---

## 🚨 If Something Goes Wrong

### Problem: Can't SSH to server
```
1. Check EC2 instance is running (not stopped)
2. Check Security Group allows port 22 from your IP
3. Check .pem file has correct permissions
4. Try different terminal (Git Bash, WSL)
```

### Problem: App shows error page
```bash
# Check logs
docker compose logs app

# Restart
docker compose restart app

# Rebuild
docker compose down
docker compose up -d --build
```

### Problem: Port already in use
```bash
# Check what's using port 80
sudo lsof -i :80

# Stop conflicting service
sudo systemctl stop <service-name>

# Or change port in docker-compose.yml
# Change "80:80" to "8080:80"
```

### Problem: Docker won't start
```bash
# Check Docker service
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check logs
journalctl -u docker -n 50
```

---

## 📝 Summary Checklist

- [ ] Cloned GitHub repo locally
- [ ] Tested with `npm run dev`
- [ ] Tested with `docker compose up -d`
- [ ] Created AWS account
- [ ] Created EC2 instance (t2.micro)
- [ ] Created security group
- [ ] Downloaded .pem key file
- [ ] Connected via SSH
- [ ] Ran `setup.sh` script
- [ ] Deployed with `deploy.sh`
- [ ] Tested: http://YOUR_IP
- [ ] Tested: http://YOUR_IP/api/health
- [ ] Accessed Netdata: http://YOUR_IP:19999
- [ ] Committed and pushed code to GitHub
- [ ] Set up UptimeRobot (optional)

---

## 🎓 What You've Accomplished

After completing this guide, you will have:

✅ A working Next.js application  
✅ Docker containerization  
✅ Running on AWS EC2  
✅ Nginx reverse proxy  
✅ Real-time monitoring with Netdata  
✅ Firewall security configured  
✅ Automated deployment scripts  
✅ A portfolio-ready project  

## 💡 Next Steps (Optional Enhancements)

1. **Add HTTPS/SSL** - Use Let's Encrypt (free)
2. **Set up CI/CD** - GitHub Actions auto-deploy
3. **Add database** - PostgreSQL or MongoDB
4. **Domain name** - Use Route 53 or external provider
5. **Load balancing** - Handle more traffic
6. **Auto-scaling** - Scale based on demand

---

## 📞 Need Help?

**Common resources:**
- AWS Docs: https://docs.aws.amazon.com
- Docker Docs: https://docs.docker.com
- Next.js Docs: https://nextjs.org/docs
- Ubuntu Help: https://help.ubuntu.com

**Community:**
- Stack Overflow
- AWS Forums
- Reddit: r/aws, r/devops
- GitHub Discussions

---

**Good luck! 🚀 You've got this!**
