#!/bin/bash

# Quick Start Script for Jenkins CI/CD Setup
# This script helps you get started quickly

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "Jenkins CI/CD Quick Start"
echo -e "==========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user
prompt_continue() {
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 1
    fi
}

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"
echo ""

if command_exists docker; then
    echo -e "${GREEN}✓ Docker is installed${NC}"
else
    echo -e "${RED}✗ Docker is not installed${NC}"
    echo "Please install Docker first. See JENKINS_SETUP_GUIDE.md"
    exit 1
fi

if docker compose version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker Compose is installed${NC}"
else
    echo -e "${RED}✗ Docker Compose is not installed${NC}"
    echo "Please install Docker Compose plugin. See JENKINS_SETUP_GUIDE.md"
    exit 1
fi

echo ""
echo -e "${GREEN}All prerequisites are met!${NC}"
echo ""

# Step 2: Update Docker Hub username
echo -e "${YELLOW}Step 2: Configure Docker Hub username${NC}"
echo ""
echo "Current Jenkinsfile uses Docker Hub repository: harshalsl0209"
echo ""
read -p "Enter your Docker Hub username (or press Enter to keep current): " dockerhub_username

if [ ! -z "$dockerhub_username" ]; then
    echo "Updating Jenkinsfile with username: $dockerhub_username"
    sed -i.bak "s/DOCKER_HUB_REPO = 'harshalsl0209'/DOCKER_HUB_REPO = '$dockerhub_username'/" Jenkinsfile
    echo -e "${GREEN}✓ Jenkinsfile updated${NC}"
else
    echo "Keeping current username"
fi
echo ""

# Step 3: Test Docker setup
echo -e "${YELLOW}Step 3: Testing Docker setup...${NC}"
echo ""

if docker ps >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker is running and accessible${NC}"
else
    echo -e "${RED}✗ Cannot access Docker${NC}"
    echo "Try: sudo usermod -aG docker \$USER && newgrp docker"
    exit 1
fi
echo ""

# Step 4: Build and start services
echo -e "${YELLOW}Step 4: Build and start services${NC}"
echo ""
echo "This will:"
echo "  - Build Docker images for backend and frontend"
echo "  - Start MongoDB, Backend, and Frontend containers"
echo "  - This may take 5-10 minutes on first run"
echo ""
prompt_continue

echo "Building and starting services..."
docker compose down -v 2>/dev/null || true
docker compose up -d --build

echo ""
echo -e "${GREEN}✓ Services started${NC}"
echo ""

# Step 5: Wait for services to be healthy
echo -e "${YELLOW}Step 5: Waiting for services to be healthy...${NC}"
echo ""

max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker compose ps | grep -q "healthy"; then
        echo -e "${GREEN}✓ Services are healthy${NC}"
        break
    fi
    attempt=$((attempt + 1))
    echo "Waiting for services... ($attempt/$max_attempts)"
    sleep 5
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "${YELLOW}⚠ Services took longer than expected to start${NC}"
    echo "Check logs with: docker compose logs"
fi
echo ""

# Step 6: Verify services
echo -e "${YELLOW}Step 6: Verifying services...${NC}"
echo ""

echo "Checking backend health..."
if curl -s http://localhost:5000/api/health >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Backend is responding${NC}"
    curl -s http://localhost:5000/api/health | jq . 2>/dev/null || curl -s http://localhost:5000/api/health
else
    echo -e "${RED}✗ Backend is not responding${NC}"
    echo "Check logs: docker compose logs backend"
fi
echo ""

echo "Checking frontend..."
if curl -s http://localhost >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend is accessible${NC}"
else
    echo -e "${RED}✗ Frontend is not accessible${NC}"
    echo "Check logs: docker compose logs frontend"
fi
echo ""

echo "Checking MongoDB..."
if docker compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ MongoDB is running${NC}"
else
    echo -e "${YELLOW}⚠ MongoDB check failed (this might be normal)${NC}"
fi
echo ""

# Step 7: Display running containers
echo -e "${YELLOW}Step 7: Running containers${NC}"
echo ""
docker compose ps
echo ""

# Step 8: Next steps
echo -e "${BLUE}=========================================="
echo "Setup Complete!"
echo -e "==========================================${NC}"
echo ""
echo -e "${GREEN}Your application is now running!${NC}"
echo ""
echo "Access your application:"
echo "  Frontend:  http://localhost"
echo "  Backend:   http://localhost:5000"
echo "  Health:    http://localhost:5000/api/health"
echo ""
echo -e "${YELLOW}Next Steps for Jenkins:${NC}"
echo ""
echo "1. Install Jenkins (if not already installed):"
echo "   See JENKINS_SETUP_GUIDE.md for detailed instructions"
echo ""
echo "2. Configure Jenkins:"
echo "   - Install required plugins (Docker Pipeline, Git, etc.)"
echo "   - Add Docker Hub credentials (ID: dockerhub-creds)"
echo "   - Create pipeline job pointing to this repository"
echo ""
echo "3. Run the pipeline:"
echo "   - Click 'Build Now' in Jenkins"
echo "   - Monitor the build in Console Output"
echo ""
echo "4. Useful commands:"
echo "   docker compose logs -f          # View logs"
echo "   docker compose down             # Stop services"
echo "   docker compose up -d            # Start services"
echo "   docker compose restart          # Restart services"
echo "   bash troubleshoot.sh            # Run diagnostics"
echo ""
echo -e "${GREEN}Good luck with your CI/CD setup! 🚀${NC}"
echo ""
