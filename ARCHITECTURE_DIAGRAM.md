# CI/CD Architecture Diagram

Visual representation of your complete CI/CD pipeline.

---

## 🏗️ Complete System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DEVELOPER WORKFLOW                           │
│                                                                      │
│  Developer → Code Changes → Git Commit → Git Push                   │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      GIT REPOSITORY (GitHub/GitLab)                  │
│                                                                      │
│  • Stores source code                                               │
│  • Tracks version history                                           │
│  • Triggers Jenkins via webhook/polling                             │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           JENKINS SERVER                             │
│                         (Port 8080)                                  │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                    JENKINS PIPELINE                            │ │
│  │                                                                │ │
│  │  Stage 1: Checkout SCM                                        │ │
│  │  ├─ Pull latest code from Git                                 │ │
│  │  └─ Verify branch (main/feature)                              │ │
│  │                                                                │ │
│  │  Stage 2: Lint & Test Backend                                 │ │
│  │  ├─ Run in Docker container (node:20-alpine)                  │ │
│  │  ├─ npm ci (install dependencies)                             │ │
│  │  └─ npm test (run tests)                                      │ │
│  │                                                                │ │
│  │  Stage 3: Lint & Test Frontend                                │ │
│  │  ├─ Run in Docker container (node:20-alpine)                  │ │
│  │  ├─ npm ci (install dependencies)                             │ │
│  │  └─ npm test (run tests with coverage)                        │ │
│  │                                                                │ │
│  │  Stage 4: Build Docker Images                                 │ │
│  │  ├─ Build backend image                                       │ │
│  │  │  └─ Tag: voting-app-backend:latest & :BUILD_NUMBER         │ │
│  │  └─ Build frontend image                                      │ │
│  │     └─ Tag: voting-app-frontend:latest & :BUILD_NUMBER        │ │
│  │                                                                │ │
│  │  Stage 5: Security Scan (Optional)                            │ │
│  │  ├─ Scan with Trivy                                           │ │
│  │  └─ Check for HIGH/CRITICAL vulnerabilities                   │ │
│  │                                                                │ │
│  │  Stage 6: Push to Docker Hub (main branch only)               │ │
│  │  ├─ Login to Docker Hub                                       │ │
│  │  ├─ Push backend:latest & :BUILD_NUMBER                       │ │
│  │  ├─ Push frontend:latest & :BUILD_NUMBER                      │ │
│  │  └─ Logout                                                    │ │
│  │                                                                │ │
│  │  Stage 7: Deploy Application (main branch only)               │ │
│  │  ├─ docker compose down (stop old containers)                 │ │
│  │  ├─ docker compose pull (get latest images)                   │ │
│  │  ├─ docker compose up -d (start new containers)               │ │
│  │  ├─ Wait for services to be healthy                           │ │
│  │  └─ Health checks (frontend & backend)                        │ │
│  │                                                                │ │
│  │  Post Actions:                                                │ │
│  │  ├─ Clean up Docker resources                                 │ │
│  │  └─ Send notifications (success/failure)                      │ │
│  └───────────────────────────────────────────────────────────────┘ │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         DOCKER HUB REGISTRY                          │
│                      (hub.docker.com)                                │
│                                                                      │
│  Repository: your-username/voting-app-backend                       │
│  ├─ latest                                                          │
│  ├─ build-1                                                         │
│  ├─ build-2                                                         │
│  └─ build-N                                                         │
│                                                                      │
│  Repository: your-username/voting-app-frontend                      │
│  ├─ latest                                                          │
│  ├─ build-1                                                         │
│  ├─ build-2                                                         │
│  └─ build-N                                                         │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      PRODUCTION ENVIRONMENT                          │
│                     (Docker Compose Stack)                           │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    FRONTEND CONTAINER                        │  │
│  │                  (voting-app-frontend)                       │  │
│  │                                                              │  │
│  │  Image: your-username/voting-app-frontend:latest            │  │
│  │  Base: nginx:alpine                                          │  │
│  │  Port: 80 → 80                                               │  │
│  │  Content: React app (built static files)                    │  │
│  │  Features:                                                   │  │
│  │  ├─ Gzip compression                                         │  │
│  │  ├─ Browser caching                                          │  │
│  │  ├─ Security headers                                         │  │
│  │  └─ SPA routing support                                      │  │
│  │                                                              │  │
│  │  Health Check: HTTP GET http://localhost/                   │  │
│  └──────────────────────────┬───────────────────────────────────┘  │
│                             │                                       │
│                             │ HTTP Requests                         │
│                             │                                       │
│  ┌──────────────────────────▼───────────────────────────────────┐  │
│  │                    BACKEND CONTAINER                         │  │
│  │                  (voting-app-backend)                        │  │
│  │                                                              │  │
│  │  Image: your-username/voting-app-backend:latest             │  │
│  │  Base: node:20-alpine                                        │  │
│  │  Port: 5000 → 3000                                           │  │
│  │  Runtime: Node.js + Express.js                              │  │
│  │  Features:                                                   │  │
│  │  ├─ RESTful API                                              │  │
│  │  ├─ JWT Authentication                                       │  │
│  │  ├─ Role-based access control                               │  │
│  │  └─ Non-root user (security)                                │  │
│  │                                                              │  │
│  │  API Endpoints:                                              │  │
│  │  ├─ POST /api/user/register                                 │  │
│  │  ├─ POST /api/user/login                                    │  │
│  │  ├─ GET  /api/candidate/candidates                          │  │
│  │  ├─ POST /api/candidate/vote                                │  │
│  │  ├─ POST /api/candidate/add (admin)                         │  │
│  │  ├─ DELETE /api/candidate/delete/:id (admin)                │  │
│  │  └─ GET  /api/health                                        │  │
│  │                                                              │  │
│  │  Health Check: HTTP GET http://localhost:3000/api/health    │  │
│  └──────────────────────────┬───────────────────────────────────┘  │
│                             │                                       │
│                             │ MongoDB Protocol                      │
│                             │                                       │
│  ┌──────────────────────────▼───────────────────────────────────┐  │
│  │                   DATABASE CONTAINER                         │  │
│  │                  (voting-app-mongodb)                        │  │
│  │                                                              │  │
│  │  Image: mongo:7                                              │  │
│  │  Port: 27017 → 27017                                         │  │
│  │  Storage: Persistent volume (mongodb_data)                  │  │
│  │  Authentication:                                             │  │
│  │  ├─ Username: admin                                          │  │
│  │  └─ Password: secretpassword                                │  │
│  │                                                              │  │
│  │  Database: votingdb                                          │  │
│  │  Collections:                                                │  │
│  │  ├─ voters (user accounts)                                   │  │
│  │  └─ candidates (candidate data + votes)                     │  │
│  │                                                              │  │
│  │  Health Check: mongosh ping command                         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  Network: voting-app-network (bridge)                               │
│  All containers communicate via this internal network               │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 CI/CD Flow Diagram

### Feature Branch Workflow

```
Developer
   │
   ├─ Create feature branch
   │  git checkout -b feature/new-feature
   │
   ├─ Make changes
   │  Edit code, add features
   │
   ├─ Commit & Push
   │  git commit -m "Add feature"
   │  git push origin feature/new-feature
   │
   ▼
Jenkins (Partial Pipeline)
   │
   ├─ ✅ Checkout SCM
   ├─ ✅ Lint & Test Backend
   ├─ ✅ Lint & Test Frontend
   ├─ ✅ Build Docker Images
   ├─ ✅ Security Scan
   ├─ ⏭️  Push to Docker Hub (SKIPPED - not main branch)
   └─ ⏭️  Deploy (SKIPPED - not main branch)
   │
   ▼
Result: Build verified, ready for merge
```

### Main Branch Workflow (Full Deployment)

```
Developer
   │
   ├─ Merge to main
   │  git checkout main
   │  git merge feature/new-feature
   │  git push origin main
   │
   ▼
Jenkins (Full Pipeline)
   │
   ├─ ✅ Checkout SCM
   ├─ ✅ Lint & Test Backend
   ├─ ✅ Lint & Test Frontend
   ├─ ✅ Build Docker Images
   ├─ ✅ Security Scan
   ├─ ✅ Push to Docker Hub
   │     │
   │     ▼
   │  Docker Hub
   │     ├─ backend:latest
   │     ├─ backend:build-N
   │     ├─ frontend:latest
   │     └─ frontend:build-N
   │
   └─ ✅ Deploy Application
         │
         ├─ Stop old containers
         ├─ Pull latest images
         ├─ Start new containers
         └─ Health checks
         │
         ▼
   Production Environment
         ├─ Frontend (Port 80)
         ├─ Backend (Port 5000)
         └─ MongoDB (Port 27017)
         │
         ▼
Result: Application updated and running!
```

---

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      SECURITY LAYERS                         │
│                                                              │
│  Layer 1: Authentication                                     │
│  ├─ JWT tokens for API access                               │
│  ├─ Password hashing (bcrypt)                               │
│  └─ Role-based access control (voter/admin)                 │
│                                                              │
│  Layer 2: Container Security                                │
│  ├─ Non-root users in containers                            │
│  ├─ Minimal base images (alpine)                            │
│  ├─ Security scanning (Trivy)                               │
│  └─ Read-only file systems where possible                   │
│                                                              │
│  Layer 3: Network Security                                  │
│  ├─ Internal Docker network                                 │
│  ├─ Only necessary ports exposed                            │
│  ├─ CORS configuration                                      │
│  └─ MongoDB authentication required                         │
│                                                              │
│  Layer 4: CI/CD Security                                    │
│  ├─ Jenkins credentials management                          │
│  ├─ Docker Hub access tokens (not passwords)                │
│  ├─ Environment variable isolation                          │
│  └─ Build artifact scanning                                 │
│                                                              │
│  Layer 5: Data Security                                     │
│  ├─ MongoDB authentication                                  │
│  ├─ Persistent volume encryption (optional)                 │
│  ├─ One vote per user enforcement                           │
│  └─ Input validation and sanitization                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow Diagram

### User Registration & Login

```
User Browser
   │
   ├─ POST /api/user/register
   │  { name, email, password, role }
   │
   ▼
Frontend (React)
   │
   ├─ Validate input
   ├─ Send to backend
   │
   ▼
Backend (Express)
   │
   ├─ Validate data
   ├─ Hash password
   ├─ Check if user exists
   │
   ▼
MongoDB
   │
   ├─ Insert user document
   ├─ Return user ID
   │
   ▼
Backend
   │
   ├─ Generate JWT token
   ├─ Return token + user data
   │
   ▼
Frontend
   │
   ├─ Store token (localStorage)
   ├─ Redirect to dashboard
   │
   ▼
User sees dashboard
```

### Voting Process

```
Voter Browser
   │
   ├─ View candidates
   │  GET /api/candidate/candidates
   │
   ▼
Backend
   │
   ├─ Verify JWT token
   ├─ Fetch candidates from MongoDB
   ├─ Return candidate list
   │
   ▼
Frontend
   │
   ├─ Display candidates
   ├─ User selects candidate
   ├─ POST /api/candidate/vote
   │  { candidateId }
   │
   ▼
Backend
   │
   ├─ Verify JWT token
   ├─ Check if user already voted
   ├─ Validate candidate exists
   │
   ▼
MongoDB
   │
   ├─ Update candidate vote count
   ├─ Mark user as voted
   │
   ▼
Backend
   │
   ├─ Return success message
   │
   ▼
Frontend
   │
   ├─ Show confirmation
   ├─ Disable voting button
   │
   ▼
Vote recorded successfully!
```

---

## 🔧 Component Interaction Matrix

| Component | Communicates With | Protocol | Port | Purpose |
|-----------|------------------|----------|------|---------|
| **Frontend** | Backend | HTTP/REST | 5000 | API calls |
| **Frontend** | User Browser | HTTP | 80 | Serve UI |
| **Backend** | Frontend | HTTP/REST | 3000 | API responses |
| **Backend** | MongoDB | MongoDB Protocol | 27017 | Data operations |
| **Backend** | Jenkins | - | - | Deployed by |
| **MongoDB** | Backend | MongoDB Protocol | 27017 | Data storage |
| **Jenkins** | Git | Git Protocol | - | Source code |
| **Jenkins** | Docker Hub | HTTPS | 443 | Push images |
| **Jenkins** | Docker Engine | Unix Socket | - | Build/deploy |

---

## 📈 Scaling Architecture (Future)

```
┌─────────────────────────────────────────────────────────────┐
│                      LOAD BALANCER                           │
│                      (Nginx/HAProxy)                         │
└────────────┬────────────────────────────┬───────────────────┘
             │                            │
             ▼                            ▼
┌─────────────────────┐      ┌─────────────────────┐
│  Frontend Instance 1 │      │  Frontend Instance 2 │
└──────────┬───────────┘      └──────────┬───────────┘
           │                             │
           └──────────┬──────────────────┘
                      │
                      ▼
           ┌─────────────────────┐
           │   Backend Cluster    │
           │  (Multiple instances)│
           └──────────┬───────────┘
                      │
                      ▼
           ┌─────────────────────┐
           │  MongoDB Replica Set │
           │  (Primary + Replicas)│
           └─────────────────────┘
```

---

## 🎯 Monitoring & Logging (Future Enhancement)

```
┌─────────────────────────────────────────────────────────────┐
│                    MONITORING STACK                          │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Prometheus  │  │   Grafana    │  │  ELK Stack   │     │
│  │  (Metrics)   │  │ (Dashboards) │  │   (Logs)     │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  Your Application│
                    │  (All containers)│
                    └─────────────────┘
```

---

This architecture provides:
- ✅ Automated CI/CD pipeline
- ✅ Containerized deployment
- ✅ Scalable infrastructure
- ✅ Security best practices
- ✅ Easy rollback capability
- ✅ Health monitoring
- ✅ Persistent data storage

**Ready to build this? Start with START_HERE.md!** 🚀
