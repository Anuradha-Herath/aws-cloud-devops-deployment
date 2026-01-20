# 🚀 AWS EC2 Deployment - Step by Step Guide

## ✅ Step 1: Get Your Instance Information

### 1.1 Find Your Public IP Address

1. Go to **EC2 Dashboard** → **Instances**
2. Click on your instance (i-058099fed1af63b67)
3. In the **Details** tab, find **Public IPv4 address**
4. **Copy this IP address** - you'll need it!

Example: `54.123.45.67`

### 1.2 Wait for Instance to be Running

- Status should change from "Pending" → "Running" (takes 1-2 minutes)
- Wait until **Instance State** shows "Running" ✅

---

## ✅ Step 2: Connect to Your Server (SSH)

### Option A: Using Windows PowerShell (Recommended)

1. **Open PowerShell** (as Administrator if possible)

2. **Navigate to where your .pem key file is located**
   ```powershell
   cd C:\Users\Anuradha\Downloads
   # Or wherever you saved your key file
   ```

3. **Set correct permissions** (Windows may need this):
   ```powershell
   icacls your-key-name.pem /inheritance:r
   icacls your-key-name.pem /grant:r "%username%:R"
   ```

4. **Connect via SSH:**
   ```powershell
   ssh -i your-key-name.pem ubuntu@YOUR_PUBLIC_IP
   ```
   
   Replace:
   - `your-key-name.pem` with your actual key file name
   - `YOUR_PUBLIC_IP` with the IP address from Step 1.1

5. **First time connection:** Type `yes` when asked about authenticity

### Option B: Using Windows Subsystem for Linux (WSL)

If you have WSL installed:

```bash
# Navigate to key file location
cd /mnt/c/Users/Anuradha/Downloads

# Set permissions
chmod 400 your-key-name.pem

# Connect
ssh -i your-key-name.pem ubuntu@YOUR_PUBLIC_IP
```

### Option C: Using PuTTY (Alternative)

1. Download **PuTTY** and **PuTTYgen** if not installed
2. Convert .pem to .ppk using PuTTYgen
3. Use PuTTY to connect:
   - Host: `ubuntu@YOUR_PUBLIC_IP`
   - Port: 22
   - Connection → SSH → Auth → Credentials → Browse → Select .ppk file

---

## ✅ Step 3: Initial Server Setup

Once connected, you'll see a prompt like:
```
ubuntu@ip-172-31-xx-xx:~$
```

### 3.1 Update System Packages

```bash
# Update package lists
sudo apt-get update

# Upgrade packages (this may take a few minutes)
sudo apt-get upgrade -y
```

### 3.2 Install Docker & Docker Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add ubuntu user to docker group (so you don't need sudo)
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker compose version
```

### 3.3 Configure Firewall (UFW)

```bash
# Allow SSH (important - don't lock yourself out!)
sudo ufw allow 22/tcp

# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS (optional)
sudo ufw allow 443/tcp

# Allow Netdata (restrict to your IP later)
sudo ufw allow 19999/tcp

# Enable firewall
sudo ufw --force enable

# Check status
sudo ufw status
```

**Important:** Make sure SSH (port 22) is allowed before enabling UFW!

---

## ✅ Step 4: Upload Your Project to Server

### Option A: Using SCP (From Windows PowerShell)

1. **Open a NEW PowerShell window** (keep SSH session open)

2. **Navigate to your project directory:**
   ```powershell
   cd "C:\Users\Anuradha\Downloads\Moratuwa Academic\Projects\devops project 1"
   ```

3. **Upload entire project:**
   ```powershell
   scp -i your-key-name.pem -r * ubuntu@YOUR_PUBLIC_IP:~/app/
   ```

   Or upload specific files:
   ```powershell
   scp -i your-key-name.pem -r docker-compose.yml Dockerfile nginx pages scripts package.json next.config.js tsconfig.json ubuntu@YOUR_PUBLIC_IP:~/app/
   ```

### Option B: Using Git (If your project is on GitHub)

Back in your SSH session:

```bash
# Install Git
sudo apt-get install git -y

# Create app directory
mkdir -p ~/app
cd ~/app

# Clone your repository (replace with your repo URL)
git clone https://github.com/yourusername/your-repo-name.git .

# Or if you need to set up Git first:
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Option C: Manual File Transfer

1. Use **WinSCP** or **FileZilla** (SFTP client)
2. Connect using:
   - Host: `YOUR_PUBLIC_IP`
   - Username: `ubuntu`
   - Key file: Your .pem file
3. Upload project files to `/home/ubuntu/app/`

---

## ✅ Step 5: Deploy Your Application

### 5.1 Navigate to App Directory

In your SSH session:

```bash
cd ~/app

# Verify files are there
ls -la
```

### 5.2 Build and Start Containers

```bash
# Build and start all services
docker compose up -d --build

# This will:
# - Build your Next.js app
# - Start Nginx reverse proxy
# - Start Netdata monitoring
# - Set up networking
```

### 5.3 Check Status

```bash
# Check if containers are running
docker compose ps

# View logs
docker compose logs -f

# Check specific service
docker compose logs app
docker compose logs nginx
```

---

## ✅ Step 6: Test Your Deployment

### 6.1 Test from Server

```bash
# Test health endpoint
curl http://localhost/api/health

# Test main app
curl http://localhost
```

### 6.2 Test from Your Browser

Open in your browser:
- **Main App**: `http://YOUR_PUBLIC_IP`
- **Health Check**: `http://YOUR_PUBLIC_IP/api/health`
- **System Info**: `http://YOUR_PUBLIC_IP/api/info`
- **Netdata**: `http://YOUR_PUBLIC_IP:19999`

---

## ✅ Step 7: Verify Everything Works

### Check Container Status

```bash
docker compose ps
```

Expected output:
```
NAME              STATUS
nextjs-app        Up (healthy)
nginx-proxy       Up
netdata-monitor   Up
```

### Check Logs for Errors

```bash
# All logs
docker compose logs

# App logs
docker compose logs app

# Nginx logs
docker compose logs nginx
```

### Test Endpoints

```bash
# Health check
curl http://localhost/api/health

# Should return JSON with status: "healthy"
```

---

## 🎉 Success Checklist

- [ ] Instance is running
- [ ] Connected via SSH
- [ ] Docker installed
- [ ] Project files uploaded
- [ ] Containers running (`docker compose ps`)
- [ ] App accessible at `http://YOUR_PUBLIC_IP`
- [ ] Health check working
- [ ] Netdata accessible at `http://YOUR_PUBLIC_IP:19999`

---

## 🐛 Troubleshooting

### Can't Connect via SSH

**Error: "Permission denied"**
- Check key file permissions
- Make sure you're using the correct key file
- Verify security group allows SSH from your IP

**Error: "Connection timeout"**
- Check security group allows port 22
- Verify instance is running
- Check your IP address hasn't changed

### Containers Won't Start

```bash
# Check logs
docker compose logs

# Rebuild without cache
docker compose build --no-cache
docker compose up -d

# Check disk space
df -h
```

### Can't Access from Browser

- Verify security group allows port 80
- Check UFW firewall: `sudo ufw status`
- Test from server first: `curl http://localhost`

### Port Already in Use

```bash
# Check what's using port 80
sudo lsof -i :80

# Stop conflicting service
sudo systemctl stop apache2  # if Apache is running
```

---

## 📝 Useful Commands Reference

```bash
# View running containers
docker compose ps

# View logs
docker compose logs -f

# Restart services
docker compose restart

# Stop services
docker compose down

# Start services
docker compose up -d

# Rebuild and restart
docker compose up -d --build

# Check system resources
docker stats

# Check disk space
df -h

# Check memory
free -h
```

---

## 🎯 Next Steps After Deployment

1. **Set up domain name** (optional)
2. **Configure SSL/HTTPS** with Let's Encrypt
3. **Set up automated backups**
4. **Configure monitoring alerts**
5. **Set up CI/CD pipeline** (optional)

---

**Need help?** Check `DEPLOYMENT.md` for detailed instructions!
