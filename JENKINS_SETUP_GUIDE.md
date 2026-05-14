# Complete Jenkins CI/CD Setup Guide

This guide will help you set up CI/CD for the Voting Application using Jenkins and Docker from scratch.

---

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Jenkins Installation](#jenkins-installation)
3. [Docker Setup](#docker-setup)
4. [Jenkins Configuration](#jenkins-configuration)
5. [Pipeline Setup](#pipeline-setup)
6. [Common Issues & Solutions](#common-issues--solutions)
7. [Testing the Pipeline](#testing-the-pipeline)

---

## 🔧 Prerequisites

### Required Software
- **Operating System**: Linux (Ubuntu 20.04+ recommended) or Windows with WSL2
- **RAM**: Minimum 4GB (8GB recommended)
- **Disk Space**: At least 20GB free
- **Docker Hub Account**: Create one at https://hub.docker.com

### Required Ports
Ensure these ports are available:
- `8080` - Jenkins Web UI
- `50000` - Jenkins Agent
- `80` - Frontend Application
- `5000` - Backend API
- `27017` - MongoDB

---

## 🚀 Step 1: Jenkins Installation

### Option A: Install Jenkins on Ubuntu/Linux

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Java (Jenkins requires Java 11 or 17)
sudo apt install openjdk-17-jdk -y

# Verify Java installation
java -version

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install jenkins -y

# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check Jenkins status
sudo systemctl status jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Option B: Install Jenkins using Docker

```bash
# Create Jenkins home directory
mkdir -p ~/jenkins_home

# Run Jenkins in Docker
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v ~/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Access Jenkins
1. Open browser: `http://localhost:8080`
2. Enter the initial admin password
3. Click **Install suggested plugins**
4. Create your first admin user
5. Keep default Jenkins URL and click **Save and Finish**

---

## 🐳 Step 2: Docker Setup

### Install Docker (if not already installed)

```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Verify installation
docker --version
docker compose version
```

### Configure Docker for Jenkins

```bash
# Add Jenkins user to docker group (for native Jenkins installation)
sudo usermod -aG docker jenkins

# Restart Jenkins to apply changes
sudo systemctl restart jenkins

# Verify Jenkins can access Docker
sudo -u jenkins docker ps
```

**For Jenkins in Docker:**
```bash
# The Docker socket is already mounted, but you need to install Docker CLI inside Jenkins container
docker exec -u root jenkins bash -c "
  apt-get update && \
  apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt-get install -y docker-ce-cli docker-compose-plugin
"
```

---

## ⚙️ Step 3: Jenkins Configuration

### Install Required Plugins

1. Go to **Manage Jenkins** → **Plugins** → **Available plugins**
2. Search and install these plugins:
   - **Docker Pipeline**
   - **Docker**
   - **Pipeline**
   - **Git**
   - **Credentials Binding**
   - **Blue Ocean** (optional, for better UI)

3. Click **Install** and restart Jenkins when installation is complete

### Configure Docker Hub Credentials

1. Go to **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
2. Click **Add Credentials**
3. Fill in the form:
   - **Kind**: Username with password
   - **Scope**: Global
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub access token (not password!)
   - **ID**: `dockerhub-creds` (must match Jenkinsfile)
   - **Description**: Docker Hub Credentials
4. Click **Create**

### Get Docker Hub Access Token

1. Log in to https://hub.docker.com
2. Click your username → **Account Settings**
3. Go to **Security** → **Access Tokens**
4. Click **New Access Token**
5. Name it "Jenkins CI/CD" and copy the token
6. Use this token as the password in Jenkins credentials

---

## 🔨 Step 4: Pipeline Setup

### Update Jenkinsfile with Your Docker Hub Username

1. Open `Jenkinsfile` in your project
2. Update line 6:
   ```groovy
   DOCKER_HUB_REPO = 'your-dockerhub-username'  // Change this!
   ```

### Create Jenkins Pipeline Job

1. From Jenkins dashboard, click **New Item**
2. Enter name: `voting-app-pipeline`
3. Select **Pipeline** and click **OK**
4. Configure the pipeline:

   **General Section:**
   - ✅ Check **GitHub project** (optional)
   - Project url: Your GitHub repository URL

   **Build Triggers:**
   - ✅ Check **Poll SCM** (optional, for automatic builds)
   - Schedule: `H/5 * * * *` (checks every 5 minutes)

   **Pipeline Section:**
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: Your Git repository URL
     - Example: `https://github.com/yourusername/voting-app.git`
   - **Credentials**: Add if private repository
   - **Branch Specifier**: `*/main` (or `*/master`)
   - **Script Path**: `Jenkinsfile`

5. Click **Save**

---

## 🧪 Step 5: Testing the Pipeline

### First Build

1. Click **Build Now** on your pipeline
2. Click on the build number (e.g., #1)
3. Click **Console Output** to see logs
4. Watch the pipeline progress through stages

### Expected Pipeline Flow

```
✅ Checkout SCM
✅ Lint & Test Backend
✅ Lint & Test Frontend
✅ Build Docker Images
✅ Security Scan (optional)
✅ Push to Docker Hub (only on main branch)
✅ Deploy Application (only on main branch)
```

### Verify Deployment

After successful build:

```bash
# Check running containers
docker ps

# Test frontend
curl http://localhost

# Test backend health
curl http://localhost:5000/api/health

# View logs
docker compose logs -f
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Permission denied" when accessing Docker

**Error:**
```
Got permission denied while trying to connect to the Docker daemon socket
```

**Solution:**
```bash
# Add Jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins

# Or restart Jenkins container
docker restart jenkins
```

---

### Issue 2: "dockerhub-creds" credential not found

**Error:**
```
groovy.lang.MissingPropertyException: No such property: DOCKER_HUB_CREDENTIALS
```

**Solution:**
1. Verify credential ID is exactly `dockerhub-creds` in Jenkins
2. Make sure it's in **Global** scope
3. Restart the pipeline

---

### Issue 3: Docker Compose command not found

**Error:**
```
docker-compose: command not found
```

**Solution:**
```bash
# Install Docker Compose plugin
sudo apt install docker-compose-plugin -y

# Or use 'docker compose' (with space) instead of 'docker-compose'
# The Jenkinsfile already uses 'docker compose'
```

---

### Issue 4: Port already in use

**Error:**
```
Bind for 0.0.0.0:80 failed: port is already allocated
```

**Solution:**
```bash
# Find what's using the port
sudo lsof -i :80

# Stop the service or change port in docker-compose.yml
# For example, change frontend port to 8081:
ports:
  - "8081:80"
```

---

### Issue 5: MongoDB connection failed

**Error:**
```
MongoServerError: Authentication failed
```

**Solution:**
1. Check MongoDB is running:
   ```bash
   docker ps | grep mongodb
   ```

2. Verify environment variables in `docker-compose.yml`:
   ```yaml
   MONGODB_URL_LOCAL=mongodb://admin:secretpassword@voting-app-mongodb:27017/votingdb?authSource=admin
   ```

3. Restart services:
   ```bash
   docker compose down -v
   docker compose up -d
   ```

---

### Issue 6: Frontend can't connect to backend

**Error:**
```
Network Error or CORS error in browser console
```

**Solution:**
1. Check backend is running:
   ```bash
   curl http://localhost:5000/api/health
   ```

2. Verify `REACT_APP_API_URL` in Jenkinsfile:
   ```groovy
   --build-arg REACT_APP_API_URL=http://localhost:5000
   ```

3. If accessing from different machine, use server IP instead of localhost

---

### Issue 7: Build fails during npm test

**Error:**
```
npm test failed with exit code 1
```

**Solution:**
The Jenkinsfile already has `|| true` to ignore test failures. If you want to fix tests:

1. Run tests locally:
   ```bash
   cd backend
   npm install
   npm test
   ```

2. Fix failing tests or remove test stage temporarily

---

### Issue 8: Trivy security scan fails

**Error:**
```
trivy: command not found
```

**Solution:**
Install Trivy (optional):
```bash
# Install Trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
```

Or the pipeline will skip it automatically if not installed.

---

### Issue 9: Jenkins runs out of disk space

**Error:**
```
No space left on device
```

**Solution:**
```bash
# Clean up Docker resources
docker system prune -a -f --volumes

# Remove old Jenkins builds
# Go to Jenkins → Manage Jenkins → System
# Set "Discard old builds" to keep only last 10 builds
```

---

### Issue 10: Pipeline stuck on "Waiting for services"

**Error:**
Pipeline hangs at Deploy stage

**Solution:**
```bash
# Check container health
docker ps

# Check logs
docker compose logs backend
docker compose logs frontend

# Increase wait time in Jenkinsfile (line 127):
sh 'sleep 30'  # Instead of 15
```

---

## 📊 Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Developer                            │
│                    (Push code to Git)                        │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      GitHub/GitLab                           │
│                   (Source Code Repository)                   │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                         Jenkins                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ 1. Checkout Code                                      │  │
│  │ 2. Run Tests (Backend + Frontend)                    │  │
│  │ 3. Build Docker Images                                │  │
│  │ 4. Security Scan (Trivy)                             │  │
│  │ 5. Push to Docker Hub                                │  │
│  │ 6. Deploy with Docker Compose                        │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                       Docker Hub                             │
│              (Container Image Registry)                      │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Production Server                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Frontend   │  │   Backend    │  │   MongoDB    │     │
│  │   (Nginx)    │  │  (Node.js)   │  │   (Mongo)    │     │
│  │   Port 80    │  │  Port 5000   │  │  Port 27017  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Quick Checklist

Before running the pipeline, ensure:

- [ ] Jenkins is installed and running on port 8080
- [ ] Docker is installed and Jenkins can access it
- [ ] Docker Hub credentials are configured in Jenkins (ID: `dockerhub-creds`)
- [ ] Jenkinsfile has your Docker Hub username
- [ ] Ports 80, 5000, 27017 are available
- [ ] Git repository is accessible from Jenkins
- [ ] Pipeline job is created with correct SCM settings

---

## 🔄 Workflow for Development

### For Feature Branches
```bash
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
```
Pipeline will run: Checkout → Test → Build (but won't push or deploy)

### For Main Branch
```bash
git checkout main
git merge feature/new-feature
git push origin main
```
Pipeline will run: Full pipeline including Push to Docker Hub and Deploy

---

## 📞 Getting Help

If you encounter issues not covered here:

1. **Check Jenkins Console Output**: Most errors are clearly shown in build logs
2. **Check Docker Logs**: `docker compose logs -f`
3. **Verify Credentials**: Ensure Docker Hub credentials are correct
4. **Check Network**: Ensure containers can communicate
5. **Review Jenkinsfile**: Ensure syntax is correct

---

## 🎉 Success Indicators

Your CI/CD is working correctly when:

✅ Jenkins builds complete successfully  
✅ Docker images are pushed to Docker Hub  
✅ Containers are running: `docker ps` shows 3 containers  
✅ Frontend accessible at http://localhost  
✅ Backend health check passes: http://localhost:5000/api/health  
✅ MongoDB is connected and healthy  

---

## 📚 Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Jenkinsfile Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)

---

**Good luck with your CI/CD setup! 🚀**
