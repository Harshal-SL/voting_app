# Voting App - Complete Initialization Guide

This guide will walk you through **complete setup** from scratch to deploy your voting app using Docker and Jenkins.

---

## 📋 Prerequisites Check

### Verify You Have These Installed:

```powershell
# Check Docker
docker --version
# Expected: Docker version 20.x or higher

# Check Docker Compose
docker-compose --version
# Expected: Docker Compose version 2.x or higher

# Check Git
git --version
# Expected: git version 2.x or higher
```

**Don't have these?** Install them:
- [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- [Git for Windows](https://git-scm.com/download/win)

---

## 🟢 Phase 1: Local Docker Testing (30 minutes)

### Step 1.1: Navigate to Project

```powershell
cd e:\voting_app
```

### Step 1.2: Build & Start Services

```powershell
# Build and start all services
docker-compose up --build -d

# Check if services are running
docker ps

# View logs
docker-compose logs -f
```

**Wait 30-40 seconds** for MongoDB to initialize.

### Step 1.3: Test Application

Open in browser:
- **Frontend:** http://localhost
- **Backend API:** http://localhost:5000
- **Health Check:** http://localhost:5000/api/user

### Step 1.4: View Service Logs

```powershell
# All logs
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb
```

### Step 1.5: Stop Services (For Now)

```powershell
docker-compose down
```

✅ **If all services started without errors, Phase 1 is complete!**

---

## 🔵 Phase 2: Docker Hub Account Setup (5 minutes)

### Step 2.1: Create Docker Hub Account
1. Go to https://hub.docker.com/
2. Sign up (if you don't have account)
3. Note your **username** (you'll need this)

### Step 2.2: Create Access Token
1. Log in to Docker Hub
2. Go to Account Settings → Security → **New Access Token**
3. Name it: `jenkins-deployment`
4. Copy the token (you won't see it again)
5. **Save it somewhere safe** (you'll need it in Phase 3)

✅ **Docker Hub Setup Complete!**

---

## 🔴 Phase 3: Jenkins Installation & Setup (45 minutes)

### Step 3.1: Launch Jenkins in Docker

**Option A: Using PowerShell**

```powershell
docker run -d `
  -p 8080:8080 `
  -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  -v /var/run/docker.sock:/var/run/docker.sock `
  --name jenkins-voting-app `
  jenkinsci/blueocean
```

**Option B: Or create a docker-compose file** (recommended):

Create `jenkins-docker-compose.yml`:
```yaml
version: '3.8'
services:
  jenkins:
    image: jenkinsci/blueocean:latest
    container_name: jenkins-voting-app
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock

volumes:
  jenkins_home:
```

```powershell
docker-compose -f jenkins-docker-compose.yml up -d
```

### Step 3.2: Get Jenkins Initial Admin Password

```powershell
docker exec jenkins-voting-app cat /var/jenkins_home/secrets/initialAdminPassword
```

**Save this password!** You'll need it next.

### Step 3.3: Access Jenkins UI

1. Open browser: http://localhost:8080
2. Paste the admin password
3. Click **Continue**

### Step 3.4: Install Recommended Plugins

1. Click **Install suggested plugins**
2. Wait for installation (takes 3-5 minutes)
3. When complete, it will ask to create admin user

### Step 3.5: Create Jenkins Admin User

Fill in:
- Full name: `Admin`
- Username: `admin`
- Password: `admin123` (or your choice)
- Confirm password: (same)
- Email: `admin@voting-app.local`

Click **Save and Continue** → **Save and Finish** → **Start Using Jenkins**

✅ **Jenkins Installation Complete!**

---

## 🟣 Phase 4: Configure Jenkins for Your Project (15 minutes)

### Step 4.1: Add Docker Hub Credentials

1. Go to **Manage Jenkins** (left sidebar)
2. Click **Credentials**
3. Click **System** (under the heading)
4. Click **Global credentials (unrestricted)**
5. Click **Add Credentials** (left sidebar)
6. Fill in:
   - Kind: `Username with password`
   - Username: `your-dockerhub-username` (from Phase 2)
   - Password: `your-docker-hub-access-token` (from Phase 2)
   - ID: `dockerhub-creds`
   - Description: `Docker Hub Credentials`
7. Click **Create**

### Step 4.2: Update Jenkinsfile with Your Docker Hub Username

Open `e:\voting_app\Jenkinsfile` and update line 7:

**BEFORE:**
```groovy
DOCKER_HUB_REPO = 'kishanmc'
```

**AFTER:**
```groovy
DOCKER_HUB_REPO = 'your-dockerhub-username'  // Use YOUR Docker Hub username
```

Save the file.

### Step 4.3: Initialize Git Repository (If Not Already)

```powershell
cd e:\voting_app

# Check if git repo exists
git status

# If not initialized, initialize it
git init
git config user.name "Admin"
git config user.email "admin@voting-app.local"

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: voting app with Docker and Jenkins"
```

**Note:** If using GitHub, push to your repository:
```powershell
git remote add origin https://github.com/your-username/voting_app.git
git branch -M main
git push -u origin main
```

### Step 4.4: Create Jenkins Pipeline Job

1. Go to Jenkins Dashboard (http://localhost:8080)
2. Click **New Item** (top left)
3. Enter name: `voting-app-pipeline`
4. Select **Pipeline** → Click **OK**

### Step 4.5: Configure Pipeline Job

In the Pipeline configuration page:

#### General Section:
- Check: **Discard old builds**
  - Max builds to keep: `10`

#### Pipeline Section:
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: 
  - Local: `file:///e/voting_app`
  - Or GitHub: `https://github.com/your-username/voting_app.git`
- Branch Specifier: `*/main`
- Script Path: `Jenkinsfile`

Click **Save**

✅ **Jenkins Configuration Complete!**

---

## 🟡 Phase 5: First Pipeline Execution (20 minutes)

### Step 5.1: Trigger the Pipeline

1. Go to your `voting-app-pipeline` job
2. Click **Build Now** (left sidebar)
3. You should see build #1 starting

### Step 5.2: Monitor Pipeline Execution

1. Click on **#1** (the build number)
2. You can see:
   - **Console Output** - Full logs of execution
   - **Stage View** - Visual pipeline stages

**Pipeline stages will run:**
```
Checkout → Lint & Test Backend → Lint & Test Frontend 
  → Build Docker Images → Security Scan → Push to Docker Hub → Deploy
```

**First build takes 3-5 minutes** (Docker image builds are slow first time)

### Step 5.3: Check Build Status

✅ **Green** = Success
🔴 **Red** = Failed
🟡 **Yellow** = Unstable

Check console output for any errors.

---

## 🟠 Phase 6: Verify Deployment (10 minutes)

### Step 6.1: Check Running Containers

```powershell
# List running containers
docker ps

# Should show 3 containers:
# - jenkins-voting-app
# - voting-app-backend
# - voting-app-frontend
# - voting-app-mongodb
```

### Step 6.2: Test Application Access

Open in browser:
- **Frontend:** http://localhost (should load voting app)
- **Backend:** http://localhost:5000 (should return JSON)
- **MongoDB:** localhost:27017 (database)

### Step 6.3: Check Container Health

```powershell
# Detailed container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# View specific logs
docker logs voting-app-backend
docker logs voting-app-frontend
```

✅ **Deployment Verification Complete!**

---

## 🟣 Phase 7: Continuous Deployment Setup (Optional)

### Step 7.1: Set Up Git Webhook (For Auto-Triggered Builds)

If using GitHub:
1. Go to your GitHub repository settings
2. Click **Webhooks** → **Add webhook**
3. Payload URL: `http://your-jenkins-ip:8080/github-webhook/`
4. Content type: `application/json`
5. Trigger: `Push events`
6. Click **Add webhook**

Now every Git push to `main` will automatically trigger the Jenkins pipeline!

### Step 7.2: Test Auto-Trigger

```powershell
cd e:\voting_app

# Make a small change
echo "# Updated $(date)" >> README.md

# Commit and push
git add README.md
git commit -m "Test auto-trigger"
git push origin main
```

Jenkins should automatically start a new build!

---

## 🟢 Troubleshooting

### Issue: Docker Port Already in Use

```powershell
# Find process using port
netstat -ano | findstr :8080

# Kill process
taskkill /PID <PID> /F

# Or use different port in docker-compose
# Change: -p 8081:8080 (uses 8081 instead)
```

### Issue: Jenkins Can't Connect to Docker

```powershell
# Check if Docker socket is accessible
docker ps

# If Jenkins in Docker can't reach host Docker:
# Restart Jenkins with proper Docker socket mapping
docker stop jenkins-voting-app
docker rm jenkins-voting-app
# Re-run Step 3.1
```

### Issue: Docker Hub Push Fails

- Verify credentials in Jenkins: **Manage Jenkins → Credentials**
- Check `DOCKER_HUB_REPO` in Jenkinsfile matches your username
- Ensure Docker Hub access token (not password) is used

### Issue: Backend Can't Connect to MongoDB

Check environment variables in `docker-compose.yml`:
```yaml
MONGODB_URL_LOCAL: mongodb://admin:secretpassword@voting-app-mongodb:27017/votingdb?authSource=admin
```

### Issue: Frontend Shows Blank Page

Check browser console (F12) for:
- CORS errors
- Backend API URL wrong (should be http://localhost:5000)

---

## 📊 Architecture After Setup

```
┌──────────────────────────────────────────┐
│          Your Computer (Windows)          │
├──────────────────────────────────────────┤
│                                          │
│  ┌─────────────────────────────────┐   │
│  │      Docker Containers          │   │
│  │ ┌──────────────────────────────┐│   │
│  │ │  Jenkins (Port 8080)         ││   │
│  │ │  - Monitors Git              ││   │
│  │ │  - Runs Pipeline             ││   │
│  │ └──────────────────────────────┘│   │
│  │ ┌──────────────────────────────┐│   │
│  │ │  Frontend (Port 80)          ││   │
│  │ │  React + Nginx               ││   │
│  │ └──────────────────────────────┘│   │
│  │ ┌──────────────────────────────┐│   │
│  │ │  Backend (Port 5000)         ││   │
│  │ │  Node.js API                 ││   │
│  │ └──────────────────────────────┘│   │
│  │ ┌──────────────────────────────┐│   │
│  │ │  MongoDB (Port 27017)        ││   │
│  │ │  Database                    ││   │
│  │ └──────────────────────────────┘│   │
│  └─────────────────────────────────┘   │
│                                          │
└──────────────────────────────────────────┘
         ↓
    Docker Hub Registry
    (Docker images stored)
```

---

## ✅ Initialization Checklist

- [ ] Phase 1: Docker & Docker Compose installed
- [ ] Phase 1: Local docker-compose up --build -d works
- [ ] Phase 2: Docker Hub account created
- [ ] Phase 2: Access token generated
- [ ] Phase 3: Jenkins Docker container running
- [ ] Phase 3: Jenkins admin user created
- [ ] Phase 4: Docker Hub credentials added to Jenkins
- [ ] Phase 4: Jenkinsfile updated with Docker Hub username
- [ ] Phase 4: Git repo initialized with Jenkinsfile
- [ ] Phase 4: Jenkins pipeline job created
- [ ] Phase 5: First pipeline build successful
- [ ] Phase 6: All containers running and healthy
- [ ] Phase 6: Frontend accessible at http://localhost
- [ ] Phase 6: Backend accessible at http://localhost:5000
- [ ] Phase 7 (Optional): Git webhook configured

---

## 🚀 Next Steps

Once initialization is complete:

1. **Make code changes** locally
2. **Commit and push** to Git (main branch)
3. **Jenkins automatically** builds and deploys
4. **Check** http://localhost for updates

---

## 📞 Quick Command Reference

```powershell
# Docker Compose
docker-compose up --build -d       # Start all services
docker-compose down                # Stop all services
docker-compose logs -f             # View logs
docker-compose ps                  # List services

# Docker
docker ps                           # List running containers
docker logs <container-name>       # View container logs
docker exec -it <container> bash   # Enter container shell

# Jenkins
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
# Get Jenkins admin password
```

---

**You're all set! Your voting app is now ready for Docker + Jenkins CI/CD deployment.** 🎉
