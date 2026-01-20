# 🚀 Cloud-Based Web Application with Docker & Monitoring

A production-ready Next.js web application deployed on AWS EC2 with Docker containerization, Nginx reverse proxy, and Netdata monitoring. This project demonstrates full-stack DevOps capabilities including cloud deployment, containerization, networking, and observability.

![Project Banner](https://img.shields.io/badge/DevOps-Project-blue?style=for-the-badge)
![Next.js](https://img.shields.io/badge/Next.js-14.1-black?style=flat-square&logo=next.js)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?style=flat-square&logo=docker)
![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?style=flat-square&logo=amazon-aws)
![Nginx](https://img.shields.io/badge/Nginx-Proxy-009639?style=flat-square&logo=nginx)

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

This project showcases enterprise-grade DevOps practices by deploying a containerized web application on AWS cloud infrastructure. It includes automated deployment scripts, reverse proxy configuration, real-time monitoring, and security hardening.

### What This Project Demonstrates

✅ **Cloud Computing** - AWS EC2 deployment with Ubuntu Linux  
✅ **Containerization** - Multi-stage Docker builds for optimized images  
✅ **Networking** - Nginx reverse proxy with load balancing capabilities  
✅ **Monitoring** - Real-time metrics with Netdata  
✅ **Security** - UFW firewall configuration and security headers  
✅ **Automation** - Bash scripts for deployment and server setup  
✅ **Infrastructure as Code** - Docker Compose for service orchestration  

## 🛠 Tech Stack

### Application Layer
- **Framework**: Next.js 14.1 (React 18.2)
- **Language**: TypeScript
- **Runtime**: Node.js 18

### Infrastructure
- **Cloud Provider**: AWS EC2
- **Operating System**: Ubuntu 22.04 LTS
- **Container Runtime**: Docker & Docker Compose
- **Reverse Proxy**: Nginx (Alpine)
- **Monitoring**: Netdata

### DevOps Tools
- **Version Control**: Git & GitHub
- **CI/CD**: Bash automation scripts (in scripts/)
- **Firewall**: UFW (Uncomplicated Firewall)

## ✨ Features

### Application Features
- 🎨 Modern, responsive UI with gradient design
- 📊 Real-time system information dashboard
- 🏥 Health check endpoint for monitoring
- ⚡ Server-side rendering with Next.js
- 📱 Mobile-friendly responsive design

### DevOps Features
- 🐳 Multi-stage Docker builds (optimized production images)
- 🔄 Automated deployment with rollback capability
- 📈 Real-time performance monitoring
- 🔒 Security hardening (UFW, security headers)
- 💾 Automatic backup before deployment
- 🚦 Health checks and graceful shutdowns
- 📝 Comprehensive logging

## 🏗 Architecture

```
┌─────────────────────────────────────────────────┐
│              AWS EC2 (Ubuntu)                   │
│  ┌───────────────────────────────────────────┐  │
│  │         Docker Network (Bridge)           │  │
│  │  ┌─────────┐  ┌──────────┐  ┌─────────┐  │  │
│  │  │  Nginx  │──│ Next.js  │  │ Netdata │  │  │
│  │  │  :80    │  │   :3000  │  │ :19999  │  │  │
│  │  └────┬────┘  └──────────┘  └─────────┘  │  │
│  └───────┼────────────────────────────────────┘  │
│          │                                        │
│  ┌───────▼────────┐                              │
│  │  UFW Firewall  │                              │
│  │  • Port 80     │                              │
│  │  • Port 443    │                              │
│  │  • Port 19999  │                              │
│  └────────────────┘                              │
└─────────────────────────────────────────────────┘
           │
           ▼
    Internet Users
```

### Request Flow
1. User requests → AWS EC2 (Port 80)
2. UFW Firewall → Allows HTTP traffic
3. Nginx Container → Receives request
4. Reverse Proxy → Forwards to Next.js app (Port 3000)
5. Next.js → Processes and returns response
6. Netdata → Monitors all components

## 📦 Prerequisites

### For Local Development
- Node.js 18+ and npm
- Docker Desktop
- Git

### For AWS Deployment
- AWS Account with EC2 access
- SSH key pair for EC2 instance
- Ubuntu 22.04 EC2 instance (t2.micro or larger)
- Security group configured for ports: 22, 80, 443, 19999

## 💻 Local Development

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd "devops project 1"
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Run Development Server
```bash
npm run dev
```

Visit `http://localhost:3000` to see the application.

### 4. Build for Production (Local)
```bash
npm run build
npm start
```

### 5. Test with Docker Locally
```bash
# Build and start all services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

Access points:
- **Application**: http://localhost
- **Health Check**: http://localhost/api/health
- **System Info**: http://localhost/api/info
- **Netdata**: http://localhost:19999

## 🚀 Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

### Quick Deployment Steps

1. **Provision AWS EC2 Instance**
   - Ubuntu 22.04 LTS
   - t2.micro or larger
   - Configure security groups

2. **SSH into Server**
   ```bash
   ssh -i your-key.pem ubuntu@YOUR_EC2_IP
   ```

3. **Run Setup Script**
   ```bash
   # Upload setup.sh to server
   chmod +x setup.sh
   ./setup.sh
   ```

4. **Deploy Application**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

5. **Access Your App**
   - Application: `http://YOUR_EC2_IP`
   - Netdata: `http://YOUR_EC2_IP:19999`

## 📊 Monitoring

### Netdata Dashboard
Access real-time metrics at `http://YOUR_EC2_IP:19999`

**Metrics Available:**
- CPU usage and load
- Memory usage and swap
- Network traffic
- Disk I/O and space
- Docker container metrics
- Application performance

### Health Check Endpoint
```bash
curl http://YOUR_EC2_IP/api/health
```

Response:
```json
{
  "status": "healthy",
  "timestamp": "2026-01-20T10:30:00.000Z",
  "uptime": 3600,
  "service": "cloud-devops-webapp"
}
```

### Manual Health Check
```bash
chmod +x health-check.sh
./health-check.sh
```

## 🔒 Security

### Implemented Security Measures

1. **Firewall (UFW)**
   - Default deny incoming
   - Allow only necessary ports (22, 80, 443, 19999)
   - Rate limiting on SSH

2. **Nginx Security Headers**
   - X-Frame-Options
   - X-Content-Type-Options
   - X-XSS-Protection
   - Referrer-Policy

3. **Docker Security**
   - Non-root user in containers
   - Minimal base images (Alpine)
   - No unnecessary capabilities

4. **Application Security**
   - Environment variable isolation
   - Health check endpoints (no sensitive data)
   - CORS configuration

### Optional Enhancements
- [ ] SSL/TLS with Let's Encrypt
- [ ] Rate limiting with Nginx
- [ ] Container image scanning
- [ ] Secret management with AWS Secrets Manager

## 🐛 Troubleshooting

### Application Won't Start
```bash
# Check container status
docker compose ps

# View logs
docker compose logs app

# Restart services
docker compose restart
```

### Nginx 502 Bad Gateway
```bash
# Check if app container is running
docker compose ps app

# Check app logs
docker compose logs app

# Verify network connectivity
docker network inspect devops-project-1_app-network
```

### Port Already in Use
```bash
# Find process using port 80
sudo lsof -i :80

# Stop conflicting service
sudo systemctl stop <service-name>
```

### Out of Disk Space
```bash
# Clean Docker resources
docker system prune -a

# Check disk usage
df -h

# Remove old logs
docker compose logs --tail=0 -f > /dev/null
```

## 📚 Scripts Reference

| Script | Purpose |
|--------|---------|
| `scripts/setup.sh` | Initial server setup (Docker, UFW, Netdata) |
| `scripts/deploy.sh` | Deploy/update application |
| `scripts/health-check.sh` | Check service health status |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- Next.js team for the amazing framework
- Docker for containerization platform
- Netdata for monitoring solution
- Nginx for reverse proxy capabilities

---

**⭐ If you find this project helpful, please give it a star!**
