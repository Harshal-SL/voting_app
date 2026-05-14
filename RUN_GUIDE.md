# How to Run This CI/CD Pipeline

## Option 1: Run Locally with Docker Compose (Quickest)

### Step 1: Check Prerequisites
```bash
docker --version
docker-compose --version
```

### Step 2: Start the Application
```bash
cd c:/Users/Kishan.m.c/Desktop/project/Voting_app

# Build and start all services in background
docker-compose up --build -d

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb
```

### Step 3: Access the Application
| Service | URL |
|---------|-----|
| Frontend (React App) | http://localhost |
| Backend API | http://localhost:5000 |
| MongoDB | localhost:27017 |

### Step 4: Stop the Application
```bash
docker-compose down

# To remove volumes too:
docker-compose down -v
```

---

## Option 2: Run with Jenkins CI/CD Pipeline

### Step 1: Install Jenkins

**Windows (using Docker):**
```bash
docker run -d ^
  -p 8080:8080 ^
  -p 50000:50000 ^
  -v jenkins_home:/var/jenkins_home ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  --name jenkins ^
  jenkinsci/blueocean
```

**Access Jenkins:** http://localhost:8080

- Get initial password: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`
- Install suggested plugins
- Create admin user

### Step 2: Configure Jenkins Credentials

1. Go to **Manage Jenkins → Credentials → System → Global credentials**
2. Click **Add Credentials**
3. Select **Username with password**
   - Username: Your Docker Hub username
   - Password: Your Docker Hub access token (Create one at https://hub.docker.com/settings/security)
   - ID: `dockerhub-creds`
4. Click OK

### Step 3: Update Jenkinsfile

Open `Jenkinsfile` and update this line:
```groovy
DOCKER_HUB_REPO = 'your-dockerhub-username'  // <-- Change to your Docker Hub username
```

Commit and push:
```bash
git add .
git commit -m "Update Docker Hub username"
git push origin main
```

### Step 4: Create Jenkins Pipeline Job

1. Go to Jenkins Dashboard → **New Item**
2. Enter name: `voting-app-pipeline`
3. Select **Pipeline** → Click OK
4. Configure:
   - **Pipeline** section:
     - Definition: `Pipeline script from SCM`
     - SCM: `Git`
     - Repository URL: `https://github.com/Harshal-SL/voting_app.git`
     - Credentials: (Add if private repo)
     - Branch Specifier: `*/main`
     - Script Path: `Jenkinsfile`
5. Click **Save**

### Step 5: Run the Pipeline

1. Click **Build Now**
2. Watch the stages execute in the **Stage View**
3. Blue = Success, Red = Failure, Yellow = Unstable

### Step 6: Monitor Pipeline

- Click on the build number (e.g., `#1`)
- Click **Console Output** for detailed logs
- Click **Pipeline Steps** to see each stage's progress

---

## Option 3: Run Without Docker (Development Mode)

### Start MongoDB
Make sure MongoDB is running locally or use MongoDB Atlas.

### Start Backend
```bash
cd backend
npm install
cp .env.example .env  # Or create .env with your MongoDB URL
npm run dev
```
Backend runs on: http://localhost:3000

### Start Frontend
```bash
cd frontend
npm install
npm start
```
Frontend runs on: http://localhost:3000

---

## Troubleshooting

### Port Already in Use
```bash
# Find and kill process using port 80 or 5000
# Windows:
netstat -ano | findstr :80
taskkill /PID <PID> /F

# Or change ports in docker-compose.yml
```

### Docker Permission Issues (Linux)
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Jenkins Can't Access Docker
```bash
# If running Jenkins in Docker, ensure it has access:
docker exec -it jenkins bash
apk add docker
exit
```

### Push to Docker Hub Fails
- Verify `dockerhub-creds` credential exists in Jenkins
- Ensure Docker Hub access token is correct (not password)
- Check `DOCKER_HUB_REPO` is updated in `Jenkinsfile`

---

## Verify Deployment

After successful pipeline run:
```bash
# Check running containers
docker ps

# Check container health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Test frontend
curl http://localhost

# Test backend API
curl http://localhost:5000/api/user

# Check
