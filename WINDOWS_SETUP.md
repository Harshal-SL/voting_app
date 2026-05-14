# Windows-Specific Setup Guide for Jenkins CI/CD

Since you're running on Windows, here are specific instructions for your environment.

---

## 🪟 Windows Prerequisites

### Option 1: Using WSL2 (Recommended)

WSL2 (Windows Subsystem for Linux) provides the best experience for Docker and Jenkins.

#### Install WSL2

1. Open PowerShell as Administrator and run:
```powershell
wsl --install
```

2. Restart your computer

3. Set WSL2 as default:
```powershell
wsl --set-default-version 2
```

4. Install Ubuntu:
```powershell
wsl --install -d Ubuntu
```

5. Launch Ubuntu and create a user account

#### Install Docker Desktop for Windows

1. Download from: https://www.docker.com/products/docker-desktop
2. Install and enable WSL2 integration
3. Open Docker Desktop → Settings → Resources → WSL Integration
4. Enable integration with your Ubuntu distribution

#### Continue Setup in WSL2

```bash
# Open Ubuntu terminal
wsl

# Navigate to your project
cd /mnt/e/voting_app

# Follow the Linux instructions from JENKINS_SETUP_GUIDE.md
bash quick-start.sh
```

---

### Option 2: Using Git Bash (Alternative)

If you prefer not to use WSL2, you can use Git Bash with Docker Desktop.

#### Install Required Software

1. **Docker Desktop for Windows**
   - Download: https://www.docker.com/products/docker-desktop
   - Install and start Docker Desktop
   - Ensure it's running (check system tray)

2. **Git for Windows** (includes Git Bash)
   - Download: https://git-scm.com/download/win
   - Install with default options

3. **Jenkins** (Optional - can run in Docker)
   - See Jenkins installation options below

#### Run Scripts in Git Bash

```bash
# Open Git Bash in your project directory
cd /e/voting_app

# Run quick start
bash quick-start.sh

# Run troubleshooting
bash troubleshoot.sh
```

---

## 🔧 Jenkins Installation on Windows

### Option A: Jenkins in Docker (Easiest)

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

**Important:** You need to install Docker CLI inside Jenkins container:

```bash
docker exec -u root jenkins bash -c "
  apt-get update && \
  apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt-get install -y docker-ce-cli docker-compose-plugin
"
```

### Option B: Jenkins Native Windows Installation

1. **Install Java**
   - Download JDK 17: https://adoptium.net/
   - Install and set JAVA_HOME environment variable

2. **Download Jenkins**
   - Download: https://www.jenkins.io/download/
   - Choose "Windows" installer
   - Run the installer

3. **Start Jenkins**
   - Jenkins will start automatically as a Windows service
   - Access at: http://localhost:8080

4. **Configure Docker Access**
   - Jenkins needs to access Docker Desktop
   - This is automatically configured if Docker Desktop is running

---

## 🐳 Docker Commands on Windows

### Using PowerShell

```powershell
# Check Docker
docker --version
docker compose version

# Start application
docker compose up -d

# Stop application
docker compose down

# View logs
docker compose logs -f

# List containers
docker ps

# Clean up
docker system prune -a -f
```

### Using Git Bash

```bash
# Same commands work in Git Bash
docker --version
docker compose up -d
docker compose logs -f
```

---

## 🔍 Windows-Specific Troubleshooting

### Issue 1: Docker Desktop Not Starting

**Solution:**
1. Enable Hyper-V and WSL2 in Windows Features
2. Restart computer
3. Start Docker Desktop manually
4. Check Docker Desktop settings

### Issue 2: Volume Mounting Issues

**Error:** "Error response from daemon: invalid mount config"

**Solution:**
In Docker Desktop:
1. Go to Settings → Resources → File Sharing
2. Add your project directory (E:\voting_app)
3. Apply & Restart

### Issue 3: Line Ending Issues

**Error:** "bash: '\r': command not found"

**Solution:**
```bash
# Convert line endings to Unix format
dos2unix quick-start.sh troubleshoot.sh

# Or using Git Bash
sed -i 's/\r$//' quick-start.sh
sed -i 's/\r$//' troubleshoot.sh
```

### Issue 4: Permission Issues

**Error:** "Permission denied"

**Solution:**
- Run Git Bash or PowerShell as Administrator
- Or adjust Docker Desktop settings to allow access

### Issue 5: Port Already in Use

**Error:** "Port 80 is already allocated"

**Solution:**
```powershell
# Find what's using the port
netstat -ano | findstr :80

# Stop IIS if it's running
iisreset /stop

# Or change port in docker-compose.yml
ports:
  - "8081:80"  # Use 8081 instead of 80
```

### Issue 6: Firewall Blocking Connections

**Solution:**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Add Docker Desktop and Jenkins
4. Allow both Private and Public networks

---

## 📝 Windows Path Considerations

### Project Path
Your project is at: `E:\voting_app`

In different shells:
- **PowerShell:** `E:\voting_app`
- **Git Bash:** `/e/voting_app`
- **WSL2:** `/mnt/e/voting_app`

### Accessing Application

After deployment:
- Frontend: http://localhost or http://localhost:80
- Backend: http://localhost:5000
- Jenkins: http://localhost:8080

If using a different machine on the network:
- Replace `localhost` with your Windows machine's IP address
- Find IP: `ipconfig` in PowerShell

---

## 🚀 Quick Start on Windows

### Using Git Bash (Recommended for Windows)

```bash
# 1. Open Git Bash in project directory
cd /e/voting_app

# 2. Ensure Docker Desktop is running
docker ps

# 3. Update Jenkinsfile with your Docker Hub username
# Edit Jenkinsfile line 6 with your favorite editor

# 4. Start the application
docker compose up -d --build

# 5. Wait for services to start (2-3 minutes)
docker compose ps

# 6. Test the application
curl http://localhost:5000/api/health
curl http://localhost

# 7. View logs if needed
docker compose logs -f
```

### Using PowerShell

```powershell
# 1. Navigate to project
cd E:\voting_app

# 2. Check Docker
docker ps

# 3. Start application
docker compose up -d --build

# 4. Check status
docker compose ps

# 5. Test endpoints
Invoke-WebRequest -Uri http://localhost:5000/api/health
Invoke-WebRequest -Uri http://localhost
```

---

## 🎯 Recommended Workflow for Windows

1. **Use Docker Desktop** for container management
2. **Use Git Bash** for running scripts and commands
3. **Use VS Code** or your preferred editor for code changes
4. **Use Jenkins in Docker** for CI/CD (easier than native installation)

---

## 📊 Checking Everything Works

### 1. Docker Desktop
- Open Docker Desktop
- Should show green "running" status
- Check containers tab - should see 3 containers after deployment

### 2. Application
```bash
# In Git Bash or PowerShell
curl http://localhost:5000/api/health
# Should return: {"status":"ok"}

curl http://localhost
# Should return HTML content
```

### 3. Jenkins
```bash
# If running Jenkins in Docker
docker ps | grep jenkins
# Should show jenkins container running

# Access Jenkins
# Open browser: http://localhost:8080
```

---

## 💡 Windows Pro Tips

1. **Use WSL2 for best experience** - Most Docker/Linux tools work better in WSL2

2. **Keep Docker Desktop running** - It must be running for any Docker commands to work

3. **Use Git Bash for scripts** - Better compatibility with Linux shell scripts

4. **Watch for line endings** - Windows uses CRLF, Linux uses LF
   - Configure Git: `git config --global core.autocrlf true`

5. **Antivirus exceptions** - Add Docker Desktop and project folder to antivirus exceptions

6. **Resource allocation** - In Docker Desktop settings, allocate enough RAM (4GB minimum)

---

## 🔗 Useful Windows Commands

```powershell
# Check if ports are in use
netstat -ano | findstr :80
netstat -ano | findstr :5000
netstat -ano | findstr :8080

# Check Docker Desktop status
docker info

# Restart Docker Desktop (if needed)
# Right-click Docker Desktop icon → Restart

# Check Windows version (for WSL2 compatibility)
winver

# Check available disk space
Get-PSDrive C
```

---

## 📞 Getting Help on Windows

### Check Docker Desktop Logs
1. Click Docker Desktop icon in system tray
2. Click "Troubleshoot"
3. View logs

### Check Jenkins Logs
```bash
# If Jenkins in Docker
docker logs jenkins -f

# If Jenkins native installation
# Check: C:\Program Files\Jenkins\jenkins.log
```

### Check Application Logs
```bash
docker compose logs backend
docker compose logs frontend
docker compose logs mongodb
```

---

## ✅ Windows Setup Checklist

- [ ] Docker Desktop installed and running
- [ ] Git Bash or WSL2 installed
- [ ] Java installed (if using native Jenkins)
- [ ] Project cloned to local directory
- [ ] Ports 80, 5000, 8080, 27017 available
- [ ] Docker Hub account created
- [ ] Jenkinsfile updated with Docker Hub username
- [ ] Firewall configured to allow Docker and Jenkins

---

**You're ready to go! Start with the quick-start.sh script in Git Bash.**

```bash
cd /e/voting_app
bash quick-start.sh
```

Good luck! 🚀
