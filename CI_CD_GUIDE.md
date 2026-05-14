# CI/CD Pipeline Guide

This project includes a complete CI/CD pipeline using **Jenkins**, **Git**, and **Docker**.

---

## 📁 Pipeline Files

| File | Description |
|------|-------------|
| `Jenkinsfile` | Jenkins pipeline definition with multi-stage build |
| `docker-compose.yml` | Orchestrates all services (MongoDB, Backend, Frontend) |
| `backend/Dockerfile` | Multi-stage Docker build for Node.js backend |
| `frontend/Dockerfile` | Multi-stage Docker build for React frontend |
| `frontend/nginx.conf` | Nginx configuration for serving React app |
| `backend/.dockerignore` | Excludes files from Docker build context |
| `frontend/.dockerignore` | Excludes files from Docker build context |

---

## 🚀 Quick Start (Local)

### Prerequisites
- Docker & Docker Compose installed
- Git installed

### Run Locally with Docker Compose

```bash
# Clone the repository
git clone <your-repo-url>
cd Voting_app

# Build and start all services
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Access the Application
| Service | URL |
|---------|-----|
| Frontend | http://localhost |
| Backend API | http://localhost:5000 |
| MongoDB | localhost:27017 |

---

## 🔧 Jenkins Setup

### Prerequisites
1. Jenkins installed with plugins:
   - Docker Pipeline
   - Pipeline
   - Git
   - Credentials Binding

2. Docker installed on Jenkins agent

3. Jenkins Credentials:
   - Go to **Manage Jenkins → Credentials → System → Global**
   - Add **Username with Password** credential:
     - ID: `dockerhub-creds`
     - Username: Your Docker Hub username
     - Password: Your Docker Hub access token

### Create Jenkins Pipeline
1. Go to **New Item → Pipeline**
2. Name: `voting-app-pipeline`
3. Under **Pipeline**, select:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/Harshal-SL/voting_app.git`
   - Branch Specifier: `*/main`
   - Script Path: `Jenkinsfile`
4. Save and click **Build Now**

---

## 📊 Pipeline Stages

```
Checkout → Lint & Test Backend → Lint & Test Frontend 
  → Build Docker Images → Security Scan → Push to Registry → Deploy
```

| Stage | Description |
|-------|-------------|
| **Checkout** | Pulls latest code from Git |
| **Lint & Test Backend** | Installs dependencies and runs Node.js tests |
| **Lint & Test Frontend** | Installs dependencies and runs React tests |
| **Build Docker Images** | Builds optimized multi-stage Docker images |
| **Security Scan** | Scans images for vulnerabilities (Trivy) |
| **Push to Registry** | Pushes images to Docker Hub (main branch only) |
| **Deploy** | Deploys using Docker Compose (main branch only) |

---

## 🔐 Environment Variables

### Backend
| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Server port |
| `MONGODB_URL_LOCAL` | — | MongoDB connection string |

### Frontend
| Variable | Default | Description |
|----------|---------|-------------|
| `REACT_APP_API_URL` | `http://localhost:5000` | Backend API base URL |

---

## 🐳 Docker Images

### Backend Image
- **Base**: `node:20-alpine`
- **User**: Non-root (`nodejs` user)
- **Port**: `3000`
- **Health Check**: HTTP check on `/api/health`

### Frontend Image
- **Base**: `nginx:alpine`
- **Build**: React app compiled with Node.js
- **Port**: `80`
- **Features**: Gzip compression, caching, security headers

---

## 📝 Updating Docker Hub Username

Before running the pipeline, update `Jenkinsfile`:

```groovy
environment {
    DOCKER_HUB_REPO = 'your-dockerhub-username'  // <-- Change this
}
```

---

## 🧪 Testing the Pipeline

1. Push changes to a feature branch → Pipeline runs stages up to "Build Docker Images"
2. Merge to `main` → Full pipeline runs including Push and Deploy

---

## 📞 Troubleshooting

| Issue | Solution |
|-------|----------|
| Jenkins can't find Docker | Ensure Jenkins user is in `docker` group |
| MongoDB connection fails | Check `MONGODB_URL_LOCAL` in docker-compose.yml |
| Frontend can't reach backend | Verify `REACT_APP_API_URL` is set correctly |
| Push stage fails | Verify `dockerhub-creds` credential exists in Jenkins |

---

## 🏗️ Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   GitHub    │────▶│   Jenkins   │────▶│ Docker Hub  │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   Server    │
                    │  (Deploy)   │
                    └─────────────┘
                           │
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │ Frontend │   │  Backend │   │  MongoDB │
    │  (Nginx) │   │ (Node.js)│   │  (Mongo) │
    └──────────┘   └──────────┘   └──────────┘
```

