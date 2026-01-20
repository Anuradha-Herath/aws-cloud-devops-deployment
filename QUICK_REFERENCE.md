# ⚡ Quick Command Reference Card

Print this out or bookmark it! All commands you'll need.

---

## 🖥️ LOCAL MACHINE (PowerShell on Windows)

### Initial Setup
```powershell
# Clone repository
git clone https://github.com/Anuradha-Herath/aws-cloud-devops-deployment.git
cd aws-cloud-devops-deployment

# Install Node.js dependencies
npm install

# Check installation
npm --version
node --version
docker --version
```

### Development (Local Testing)
```powershell
# Start development server
npm run dev

# Visit http://localhost:3000

# Stop: Press Ctrl+C
```

### Docker Local Testing
```powershell
# Build and start containers
docker compose up -d --build

# View containers
docker compose ps

# View logs
docker compose logs -f

# Stop containers
docker compose down

# Test endpoints
curl http://localhost
curl http://localhost/api/health
```

### Git Management
```powershell
# View changes
git status

# Stage changes
git add .

# Commit
git commit -m "Your message here"

# Push to GitHub
git push origin main

# Pull latest
git pull origin main

# View history
git log --oneline
```

### AWS Connection
```powershell
# Navigate to key file
cd $env:USERPROFILE\Downloads

# Set permissions (first time)
icacls "devops-webapp-key.pem" /inheritance:r /grant:r "$env:USERNAME`:(F)"

# Connect to server
ssh -i "devops-webapp-key.pem" ubuntu@YOUR_EC2_IP

# Example:
ssh -i "devops-webapp-key.pem" ubuntu@54.123.45.67

# Copy file to server
scp -i "devops-webapp-key.pem" local-file.txt ubuntu@54.123.45.67:~/

# Copy from server
scp -i "devops-webapp-key.pem" ubuntu@54.123.45.67:~/remote-file.txt .
```

---

## 🌐 SERVER COMMANDS (Run in SSH terminal)

### Navigation & Basic
```bash
# Show current directory
pwd

# List files
ls
ls -la          # With details

# Change directory
cd ~/app
cd scripts

# Show current location in full
pwd

# Create directory
mkdir my-folder

# Remove file
rm filename.txt

# Remove directory
rm -rf directory-name
```

### First Time Setup
```bash
# Create app directory
mkdir -p ~/app
cd ~/app

# Clone repository
git clone https://github.com/Anuradha-Herath/aws-cloud-devops-deployment.git .

# Make setup script executable
chmod +x scripts/setup.sh

# Run setup (takes 5-10 minutes)
./scripts/setup.sh

# Say "y" when asked about Netdata

# Log out and back in after
exit
# Then SSH back in
```

### Deployment
```bash
# Navigate to app
cd ~/app

# Make deploy script executable (first time)
chmod +x scripts/deploy.sh

# Deploy application
./scripts/deploy.sh

# This takes 5-10 minutes first time
# 2-3 minutes for updates
```

### Check Status
```bash
# View running containers
docker compose ps

# View specific container status
docker compose ps app
docker compose ps nginx

# Show resource usage
docker stats

# Check processes
ps aux | grep docker
```

### View Logs
```bash
# All logs (last 20 lines)
docker compose logs --tail=20

# All logs following (live)
docker compose logs -f

# Specific service
docker compose logs app
docker compose logs nginx
docker compose logs netdata

# Last 50 lines of app logs
docker compose logs --tail=50 app

# Stop following: Ctrl+C
```

### Container Management
```bash
# Stop all containers
docker compose down

# Start all containers
docker compose up -d

# Restart all containers
docker compose restart

# Restart specific container
docker compose restart app

# Rebuild and restart
docker compose down
docker compose up -d --build

# Remove everything (CAUTION: loses data)
docker compose down -v
```

### Health Check
```bash
# Run health check script
./scripts/health-check.sh

# Manual health check
curl http://localhost/api/health
curl http://localhost/api/info

# From outside server
curl http://YOUR_EC2_IP/api/health
```

### Update Code from GitHub
```bash
# Pull latest changes
git pull origin main

# See what changed
git log --oneline -5

# Deploy after update
./scripts/deploy.sh
```

### System Information
```bash
# Disk space
df -h

# Memory usage
free -h

# CPU info
nproc              # Number of processors
top                # Press q to exit

# System uptime
uptime

# Hostname/IP
hostname
hostname -I
```

### Firewall
```bash
# Check firewall status
sudo ufw status

# Show rules with numbers
sudo ufw status numbered

# Allow port
sudo ufw allow 22/tcp

# Deny port
sudo ufw deny 22/tcp

# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable
```

### Troubleshooting
```bash
# Check what's using port 80
sudo lsof -i :80

# Check what's using port 3000
sudo lsof -i :3000

# Kill process (use PID from above)
sudo kill -9 1234

# Check disk issues
df -h
du -sh *           # Size of each directory

# Clean Docker
docker system prune -a

# Check system logs
journalctl -n 50   # Last 50 lines

# Watch for errors
tail -f /var/log/syslog
```

---

## 🌍 Browser URLs

| URL | What | Expected |
|-----|------|----------|
| `http://54.123.45.67` | Main app | Purple gradient page |
| `http://54.123.45.67/api/health` | Health check | `{"status":"healthy",...}` |
| `http://54.123.45.67/api/info` | System info | System data JSON |
| `http://54.123.45.67:19999` | Monitoring | Colorful dashboard |

Replace `54.123.45.67` with YOUR actual EC2 public IP.

---

## 📁 Important File Paths

### On Your Machine
```
AWS Key:           C:\Users\Anuradha\Downloads\devops-webapp-key.pem
Repository:        C:\Users\Anuradha\Documents\aws-cloud-devops-deployment\
Dockerfile:        .../Dockerfile
Setup Script:      .../scripts/setup.sh
Deploy Script:     .../scripts/deploy.sh
README:            .../README.md
```

### On Server
```
App Directory:     ~/app  (same as /home/ubuntu/app)
Docker Config:     ~/app/docker-compose.yml
Nginx Config:      ~/app/nginx/default.conf
Scripts:           ~/app/scripts/
Backups:           ~/app/backups/
Logs:              docker compose logs
```

---

## 🔐 Security Checklist

```bash
# On server, secure your key
chmod 600 ~/.ssh/devops-webapp-key.pem

# Check SSH only allows key authentication
sudo nano /etc/ssh/sshd_config
# Look for: PasswordAuthentication no

# Verify firewall
sudo ufw status

# Should show:
# 22/tcp (SSH)
# 80/tcp (HTTP)
# 443/tcp (HTTPS)
# 19999/tcp (Netdata)

# Check for unauthorized access
sudo lastlog -t -10        # Last 10 logins
```

---

## 🚨 Emergency Commands

### Something's Wrong, Start Fresh
```bash
cd ~/app

# Stop everything
docker compose down

# Remove containers, images, volumes
docker compose down -v
docker system prune -a

# Start fresh
git pull origin main
./scripts/deploy.sh
```

### Out of Disk Space
```bash
# Check space
df -h

# Clean Docker
docker system prune -a

# Remove old containers/images
docker image prune -a
docker container prune
```

### Application Crashes
```bash
# Check what's wrong
docker compose logs app

# Restart
docker compose restart app

# Full rebuild
docker compose down
docker compose up -d --build
```

### Can't Connect to Server
```bash
# From local machine
# 1. Check EC2 instance is "Running" in AWS Console
# 2. Check security group allows port 22 from your IP
# 3. Check .pem file permissions
# 4. Try again:

ssh -i "devops-webapp-key.pem" ubuntu@YOUR_EC2_IP
```

---

## 📊 Monitoring Commands

```bash
# Real-time container stats
docker stats

# Memory usage
docker compose stats

# Check specific container
docker compose logs app | tail -100

# See all running processes
ps aux

# Network connections
netstat -tulpn

# Disk usage by directory
du -sh /* | sort -h

# Memory detailed
free -m
cat /proc/meminfo
```

---

## 🎯 Daily Routine

### Check Everything is Working
```bash
# SSH in
ssh -i "key.pem" ubuntu@IP

# Navigate
cd ~/app

# Check status
docker compose ps

# Run health check
./scripts/health-check.sh

# View recent logs
docker compose logs --tail=20 app

# Exit
exit
```

### Make Code Changes
```powershell
# 1. On your machine, edit files
# 2. Test locally: npm run dev
# 3. Commit changes
git add .
git commit -m "Fixed bug"
git push origin main

# 4. Deploy to server
# SSH in and run:
cd ~/app
git pull origin main
./scripts/deploy.sh
```

---

## 📚 File Structure Reminder

```
aws-cloud-devops-deployment/
├── pages/              # Your app code here
│   ├── index.tsx
│   └── api/
├── nginx/              # Web server config
├── scripts/            # Automation scripts
│   ├── setup.sh
│   ├── deploy.sh
│   └── health-check.sh
├── Dockerfile          # Container recipe
├── docker-compose.yml  # Services setup
├── package.json        # Dependencies
└── README.md           # Documentation
```

---

**Pro Tip:** Bookmark this page or print it! Refer back often. 🚀
