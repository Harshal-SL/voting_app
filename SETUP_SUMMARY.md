# CI/CD Setup Summary - Quick Reference

## 🎯 What You Need to Do

Your friend started the CI/CD setup but faced issues. Here's your complete roadmap to get it working.

---

## 📚 Documentation Files Created

| File | Purpose |
|------|---------|
| **JENKINS_SETUP_GUIDE.md** | Complete step-by-step Jenkins setup (START HERE!) |
| **quick-start.sh** | Automated script to start the application |
| **troubleshoot.sh** | Diagnostic script to find and fix issues |
| **CI_CD_GUIDE.md** | Original guide (already existed) |
| **Jenkinsfile** | Pipeline definition (already existed) |

---

## 🚀 Quick Start (3 Steps)

### Step 1: Update Your Docker Hub Username

Open `Jenkinsfile` and change line 6:
```groovy
DOCKER_HUB_REPO = 'your-dockerhub-username'  // Change this!
```

### Step 2: Run Quick Start Script

```bash
# On Linux/Mac or Windows with Git Bash
bash quick-start.sh
```

This will:
- Check prerequisites
- Build Docker images
- Start all services (MongoDB, Backend, Frontend)
- Verify everything is working

### Step 3: Set Up Jenkins

Follow **JENKINS_SETUP_GUIDE.md** for detailed instructions:
1. Install Jenkins
2. Install required plugins
3. Configure Docker Hub credentials
4. Create pipeline job
5. Run your first build

---

## 🔍 Common Issues Your Friend Likely Faced

### Issue 1: Docker Permission Denied
**Symptom:** Jenkins can't access Docker
**Solution:**
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Issue 2: Missing Docker Hub Credentials
**Symptom:** Pipeline fails at "Push to Docker Hub" stage
**Solution:**
- Go to Jenkins → Manage Jenkins → Credentials
- Add credential with ID: `dockerhub-creds`
- Use Docker Hub access token (not password!)

### Issue 3: Port Conflicts
**Symptom:** "Port already in use" error
**Solution:**
```bash
# Find what's using the port
sudo lsof -i :80
sudo lsof -i :5000

# Stop the conflicting service or change ports in docker-compose.yml
```

### Issue 4: MongoDB Connection Failed
**Symptom:** Backend can't connect to database
**Solution:**
```bash
# Restart with fresh volumes
docker compose down -v
docker compose up -d
```

### Issue 5: Tests Failing
**Symptom:** Pipeline fails at test stage
**Solution:** The Jenkinsfile already has `|| true` to ignore test failures, but you can:
```bash
# Run tests locally to debug
cd backend
npm install
npm test
```

---

## 🛠️ Troubleshooting

### Run Diagnostic Script
```bash
bash troubleshoot.sh
```

This checks:
- Docker installation
- Jenkins status
- Port availability
- Running containers
- Disk space
- Network connectivity
- Application health

### Manual Checks

```bash
# Check Docker
docker --version
docker compose version
docker ps

# Check Jenkins (if installed)
sudo systemctl status jenkins

# Check application
curl http://localhost:5000/api/health
curl http://localhost

# View logs
docker compose logs -f
docker compose logs backend
docker compose logs frontend
docker compose logs mongodb
```

---

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Docker** installed (version 20.10+)
- [ ] **Docker Compose** installed (v2.0+)
- [ ] **Git** installed
- [ ] **Docker Hub account** created
- [ ] **Ports available**: 80, 5000, 8080, 27017
- [ ] **Disk space**: At least 20GB free
- [ ] **RAM**: Minimum 4GB (8GB recommended)

---

## 🎓 Understanding the Pipeline

### Pipeline Stages

```
1. Checkout SCM
   └─ Pulls code from Git

2. Lint & Test Backend
   └─ Runs npm test for backend

3. Lint & Test Frontend
   └─ Runs npm test for frontend

4. Build Docker Images
   └─ Builds backend and frontend images

5. Security Scan
   └─ Scans images with Trivy (optional)

6. Push to Docker Hub
   └─ Pushes images (only on main branch)

7. Deploy Application
   └─ Starts containers with docker compose (only on main branch)
```

### When Each Stage Runs

| Stage | Feature Branch | Main Branch |
|-------|---------------|-------------|
| Checkout | ✅ | ✅ |
| Test | ✅ | ✅ |
| Build | ✅ | ✅ |
| Security Scan | ✅ | ✅ |
| Push to Docker Hub | ❌ | ✅ |
| Deploy | ❌ | ✅ |

---

## 🔐 Security Best Practices

### Docker Hub Credentials
- **Never** commit Docker Hub password to Git
- Use **access tokens** instead of passwords
- Create token at: https://hub.docker.com → Account Settings → Security → Access Tokens
- Store in Jenkins with ID: `dockerhub-creds`

### Environment Variables
- MongoDB credentials are in `docker-compose.yml`
- Change default passwords in production:
  ```yaml
  MONGO_INITDB_ROOT_USERNAME: admin
  MONGO_INITDB_ROOT_PASSWORD: secretpassword  # Change this!
  ```

---

## 📊 Architecture Overview

```
Developer → Git → Jenkins → Docker Hub → Production

Production Stack:
┌─────────────────────────────────────────┐
│  Frontend (React + Nginx)               │
│  Port: 80                               │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│  Backend (Node.js + Express)            │
│  Port: 5000                             │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│  MongoDB                                │
│  Port: 27017                            │
└─────────────────────────────────────────┘
```

---

## 🎯 Success Criteria

Your CI/CD is working when:

✅ Jenkins builds complete without errors  
✅ Docker images are pushed to Docker Hub  
✅ All 3 containers are running: `docker ps`  
✅ Frontend loads at http://localhost  
✅ Backend health check passes: http://localhost:5000/api/health  
✅ MongoDB is connected and healthy  

---

## 📞 Getting Help

### Check Logs
```bash
# Jenkins logs (if installed natively)
sudo journalctl -u jenkins -f

# Jenkins logs (if in Docker)
docker logs jenkins -f

# Application logs
docker compose logs -f
```

### Common Commands
```bash
# Start application
docker compose up -d

# Stop application
docker compose down

# Restart application
docker compose restart

# Rebuild and start
docker compose up -d --build

# View running containers
docker ps

# Clean up Docker resources
docker system prune -a -f

# Check disk space
df -h
```

---

## 🎉 Next Steps After Setup

1. **Test the pipeline:**
   - Make a small change to code
   - Commit and push to a feature branch
   - Watch Jenkins build

2. **Merge to main:**
   - Create pull request
   - Merge to main branch
   - Watch full pipeline including deployment

3. **Monitor:**
   - Check Jenkins build history
   - Monitor Docker Hub for new images
   - Verify application is running

4. **Optimize:**
   - Add more tests
   - Configure webhooks for automatic builds
   - Set up notifications (email, Slack)
   - Add more security scans

---

## 📖 Learning Resources

- **Jenkins:** https://www.jenkins.io/doc/
- **Docker:** https://docs.docker.com/
- **Docker Compose:** https://docs.docker.com/compose/
- **Jenkinsfile Syntax:** https://www.jenkins.io/doc/book/pipeline/syntax/

---

## 💡 Pro Tips

1. **Start Simple:** Get basic pipeline working first, then add features
2. **Check Logs:** Most issues are clearly shown in logs
3. **Use Branches:** Test on feature branches before merging to main
4. **Clean Regularly:** Run `docker system prune` to free up space
5. **Document Changes:** Keep notes of what you change for troubleshooting

---

## ⚠️ Important Notes

- The Jenkinsfile uses `|| true` for tests to prevent build failures during setup
- Security scan (Trivy) is optional and will be skipped if not installed
- Push and Deploy stages only run on the `main` branch
- First build will take longer as it downloads base images

---

**Ready to start? Open JENKINS_SETUP_GUIDE.md and follow the steps!**

Good luck! 🚀
