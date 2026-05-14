# Jenkins CI/CD Setup Checklist

Use this checklist to track your progress through the setup process.

---

## 📋 Phase 1: Prerequisites (Before Starting)

- [ ] **Docker Desktop installed**
  - Download from: https://www.docker.com/products/docker-desktop
  - Version 20.10 or higher
  - Running and accessible

- [ ] **Docker Compose available**
  - Test: `docker compose version`
  - Should show v2.0 or higher

- [ ] **Git installed**
  - Test: `git --version`
  - Git Bash available on Windows

- [ ] **Docker Hub account created**
  - Sign up at: https://hub.docker.com
  - Username noted: ________________

- [ ] **Docker Hub access token created**
  - Go to: Account Settings → Security → Access Tokens
  - Token saved securely: ________________

- [ ] **Ports available**
  - [ ] Port 80 (Frontend)
  - [ ] Port 5000 (Backend)
  - [ ] Port 8080 (Jenkins)
  - [ ] Port 27017 (MongoDB)

- [ ] **System resources**
  - [ ] At least 4GB RAM available
  - [ ] At least 20GB disk space free

---

## 📋 Phase 2: Project Configuration

- [ ] **Project cloned/downloaded**
  - Location: ________________

- [ ] **Jenkinsfile updated**
  - [ ] Open `Jenkinsfile`
  - [ ] Change line 6: `DOCKER_HUB_REPO = 'your-username'`
  - [ ] Save file

- [ ] **Review docker-compose.yml**
  - [ ] MongoDB credentials noted
  - [ ] Ports configured correctly
  - [ ] No conflicts with existing services

---

## 📋 Phase 3: Local Testing (Before Jenkins)

- [ ] **Docker access verified**
  - Test: `docker ps`
  - Should run without errors

- [ ] **Build and start services**
  - Run: `docker compose up -d --build`
  - Wait 2-3 minutes for services to start

- [ ] **Verify containers running**
  - Run: `docker ps`
  - Should see 3 containers:
    - [ ] voting-app-mongodb
    - [ ] voting-app-backend
    - [ ] voting-app-frontend

- [ ] **Test backend health**
  - Run: `curl http://localhost:5000/api/health`
  - Should return: `{"status":"ok"}`

- [ ] **Test frontend**
  - Open browser: http://localhost
  - Should load the voting app

- [ ] **Check logs for errors**
  - Run: `docker compose logs`
  - No critical errors shown

---

## 📋 Phase 4: Jenkins Installation

Choose one option:

### Option A: Jenkins in Docker (Recommended)

- [ ] **Create Jenkins home directory**
  - Run: `mkdir -p ~/jenkins_home`

- [ ] **Start Jenkins container**
  ```bash
  docker run -d \
    --name jenkins \
    -p 8080:8080 -p 50000:50000 \
    -v ~/jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins/jenkins:lts
  ```

- [ ] **Install Docker CLI in Jenkins**
  - Run the command from JENKINS_SETUP_GUIDE.md
  - Verify: `docker exec jenkins docker --version`

### Option B: Native Jenkins Installation

- [ ] **Java installed**
  - Test: `java -version`
  - Should show Java 11 or 17

- [ ] **Jenkins installed**
  - Follow OS-specific instructions
  - Service started and running

- [ ] **Jenkins user added to docker group**
  - Run: `sudo usermod -aG docker jenkins`
  - Run: `sudo systemctl restart jenkins`

---

## 📋 Phase 5: Jenkins Initial Setup

- [ ] **Access Jenkins web UI**
  - Open: http://localhost:8080
  - Page loads successfully

- [ ] **Get initial admin password**
  - Docker: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`
  - Native: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
  - Password: ________________

- [ ] **Unlock Jenkins**
  - Enter initial admin password
  - Click Continue

- [ ] **Install suggested plugins**
  - Click "Install suggested plugins"
  - Wait for installation to complete

- [ ] **Create first admin user**
  - Username: ________________
  - Password: ________________
  - Full name: ________________
  - Email: ________________

- [ ] **Jenkins URL configured**
  - Keep default: http://localhost:8080
  - Click Save and Finish

---

## 📋 Phase 6: Jenkins Plugin Installation

- [ ] **Navigate to plugin manager**
  - Manage Jenkins → Plugins → Available plugins

- [ ] **Install required plugins**
  - [ ] Docker Pipeline
  - [ ] Docker
  - [ ] Pipeline
  - [ ] Git
  - [ ] Credentials Binding
  - [ ] Blue Ocean (optional)

- [ ] **Restart Jenkins**
  - Check "Restart Jenkins when installation is complete"
  - Wait for restart

---

## 📋 Phase 7: Jenkins Credentials Configuration

- [ ] **Navigate to credentials**
  - Manage Jenkins → Credentials → System → Global credentials

- [ ] **Add Docker Hub credentials**
  - Click "Add Credentials"
  - Kind: Username with password
  - Scope: Global
  - Username: [Your Docker Hub username]
  - Password: [Your Docker Hub access token]
  - ID: `dockerhub-creds` (MUST be exactly this)
  - Description: Docker Hub Credentials
  - Click Create

- [ ] **Verify credential created**
  - Should see "dockerhub-creds" in credentials list

---

## 📋 Phase 8: Pipeline Job Creation

- [ ] **Create new pipeline**
  - Jenkins Dashboard → New Item
  - Name: `voting-app-pipeline`
  - Type: Pipeline
  - Click OK

- [ ] **Configure pipeline**
  - [ ] General section:
    - Description: CI/CD pipeline for voting application
  
  - [ ] Build Triggers (optional):
    - [ ] Poll SCM: `H/5 * * * *`
  
  - [ ] Pipeline section:
    - Definition: Pipeline script from SCM
    - SCM: Git
    - Repository URL: ________________
    - Credentials: (add if private repo)
    - Branch Specifier: `*/main`
    - Script Path: `Jenkinsfile`

- [ ] **Save pipeline configuration**

---

## 📋 Phase 9: First Pipeline Run

- [ ] **Trigger first build**
  - Click "Build Now"
  - Build #1 should appear

- [ ] **Monitor build progress**
  - Click on build #1
  - Click "Console Output"
  - Watch logs in real-time

- [ ] **Verify all stages complete**
  - [ ] ✅ Checkout SCM
  - [ ] ✅ Lint & Test Backend
  - [ ] ✅ Lint & Test Frontend
  - [ ] ✅ Build Docker Images
  - [ ] ✅ Security Scan
  - [ ] ✅ Push to Docker Hub (if on main branch)
  - [ ] ✅ Deploy Application (if on main branch)

- [ ] **Check for errors**
  - No red X marks in pipeline view
  - Build status: SUCCESS

---

## 📋 Phase 10: Verify Deployment

- [ ] **Check Docker Hub**
  - Login to https://hub.docker.com
  - Navigate to your repositories
  - Should see:
    - [ ] voting-app-backend
    - [ ] voting-app-frontend
  - Both with "latest" tag

- [ ] **Check running containers**
  - Run: `docker ps`
  - Should see 3 containers running

- [ ] **Test application**
  - [ ] Frontend: http://localhost
  - [ ] Backend: http://localhost:5000/api/health
  - [ ] Both responding correctly

- [ ] **Check application functionality**
  - [ ] Can register a user
  - [ ] Can login
  - [ ] Can view candidates
  - [ ] Can vote

---

## 📋 Phase 11: Testing CI/CD Workflow

- [ ] **Create feature branch**
  ```bash
  git checkout -b test-feature
  ```

- [ ] **Make a small change**
  - Edit README.md or add a comment
  - Commit and push

- [ ] **Verify pipeline runs**
  - Jenkins should detect change
  - Pipeline runs automatically (if polling enabled)
  - Or click "Build Now"

- [ ] **Verify partial pipeline**
  - Stages run up to "Build Docker Images"
  - Push and Deploy stages skipped (not on main)

- [ ] **Merge to main**
  ```bash
  git checkout main
  git merge test-feature
  git push origin main
  ```

- [ ] **Verify full pipeline**
  - Pipeline runs on main branch
  - All stages execute including Push and Deploy
  - Application updates successfully

---

## 📋 Phase 12: Monitoring and Maintenance

- [ ] **Set up build retention**
  - Pipeline → Configure
  - Discard old builds: Keep last 10 builds

- [ ] **Monitor disk space**
  - Run: `df -h`
  - Should have adequate free space

- [ ] **Set up notifications (optional)**
  - Email notifications
  - Slack integration
  - Other notification methods

- [ ] **Document custom changes**
  - Note any modifications made
  - Update team documentation

---

## 📋 Troubleshooting Checklist

If something goes wrong:

- [ ] **Run diagnostic script**
  - Run: `bash troubleshoot.sh`
  - Review output for issues

- [ ] **Check Jenkins logs**
  - Console output for specific build
  - Jenkins system logs

- [ ] **Check Docker logs**
  - `docker compose logs -f`
  - Individual container logs

- [ ] **Verify credentials**
  - Docker Hub credentials correct
  - Access token not expired

- [ ] **Check network connectivity**
  - Can reach Docker Hub
  - Can reach Git repository

- [ ] **Review common issues**
  - See JENKINS_SETUP_GUIDE.md
  - See WINDOWS_SETUP.md (if on Windows)

---

## 📋 Success Criteria

Your setup is complete when:

- [ ] ✅ Jenkins is running and accessible
- [ ] ✅ Pipeline job is configured
- [ ] ✅ First build completes successfully
- [ ] ✅ Docker images are pushed to Docker Hub
- [ ] ✅ Application is deployed and running
- [ ] ✅ Frontend is accessible at http://localhost
- [ ] ✅ Backend API is responding
- [ ] ✅ MongoDB is connected
- [ ] ✅ CI/CD workflow tested (feature branch → main)
- [ ] ✅ Team members can access and use the system

---

## 📊 Progress Tracking

| Phase | Status | Date Completed | Notes |
|-------|--------|----------------|-------|
| 1. Prerequisites | ⬜ | | |
| 2. Project Config | ⬜ | | |
| 3. Local Testing | ⬜ | | |
| 4. Jenkins Install | ⬜ | | |
| 5. Jenkins Setup | ⬜ | | |
| 6. Plugin Install | ⬜ | | |
| 7. Credentials | ⬜ | | |
| 8. Pipeline Job | ⬜ | | |
| 9. First Build | ⬜ | | |
| 10. Verify Deploy | ⬜ | | |
| 11. Test Workflow | ⬜ | | |
| 12. Monitoring | ⬜ | | |

---

## 🎯 Quick Reference

### Important URLs
- Jenkins: http://localhost:8080
- Frontend: http://localhost
- Backend: http://localhost:5000
- Health Check: http://localhost:5000/api/health
- Docker Hub: https://hub.docker.com

### Important Commands
```bash
# Start application
docker compose up -d

# Stop application
docker compose down

# View logs
docker compose logs -f

# Check containers
docker ps

# Restart Jenkins (Docker)
docker restart jenkins

# Restart Jenkins (Native)
sudo systemctl restart jenkins

# Run diagnostics
bash troubleshoot.sh
```

### Important Files
- `Jenkinsfile` - Pipeline definition
- `docker-compose.yml` - Service orchestration
- `JENKINS_SETUP_GUIDE.md` - Detailed setup instructions
- `WINDOWS_SETUP.md` - Windows-specific instructions
- `troubleshoot.sh` - Diagnostic script

---

**Print this checklist and mark items as you complete them!**

Good luck! 🚀
