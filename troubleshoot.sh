#!/bin/bash

# Troubleshooting Script for Jenkins CI/CD Pipeline
# This script checks common issues and provides solutions

echo "=========================================="
echo "Jenkins CI/CD Troubleshooting Script"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Docker Installation
echo "1. Checking Docker installation..."
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker is installed${NC}"
    docker --version
else
    echo -e "${RED}✗ Docker is NOT installed${NC}"
    echo "  Solution: Install Docker using the guide in JENKINS_SETUP_GUIDE.md"
fi
echo ""

# Check 2: Docker Compose
echo "2. Checking Docker Compose..."
if docker compose version &> /dev/null; then
    echo -e "${GREEN}✓ Docker Compose is installed${NC}"
    docker compose version
else
    echo -e "${RED}✗ Docker Compose is NOT installed${NC}"
    echo "  Solution: Install docker-compose-plugin"
fi
echo ""

# Check 3: Docker Service
echo "3. Checking Docker service status..."
if systemctl is-active --quiet docker 2>/dev/null || docker ps &> /dev/null; then
    echo -e "${GREEN}✓ Docker service is running${NC}"
else
    echo -e "${RED}✗ Docker service is NOT running${NC}"
    echo "  Solution: sudo systemctl start docker"
fi
echo ""

# Check 4: Jenkins Installation
echo "4. Checking Jenkins installation..."
if systemctl is-active --quiet jenkins 2>/dev/null; then
    echo -e "${GREEN}✓ Jenkins service is running${NC}"
elif docker ps | grep -q jenkins; then
    echo -e "${GREEN}✓ Jenkins is running in Docker${NC}"
elif command -v jenkins &> /dev/null; then
    echo -e "${YELLOW}⚠ Jenkins is installed but not running${NC}"
    echo "  Solution: sudo systemctl start jenkins"
else
    echo -e "${RED}✗ Jenkins is NOT installed${NC}"
    echo "  Solution: Install Jenkins using the guide in JENKINS_SETUP_GUIDE.md"
fi
echo ""

# Check 5: Port Availability
echo "5. Checking port availability..."
ports=(80 5000 8080 27017)
for port in "${ports[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${YELLOW}⚠ Port $port is in use${NC}"
        if command -v lsof &> /dev/null; then
            echo "  Process: $(lsof -ti:$port -sTCP:LISTEN 2>/dev/null | xargs ps -p 2>/dev/null | tail -n +2)"
        fi
    else
        echo -e "${GREEN}✓ Port $port is available${NC}"
    fi
done
echo ""

# Check 6: Docker Permissions
echo "6. Checking Docker permissions..."
if groups | grep -q docker || id -nG | grep -q docker; then
    echo -e "${GREEN}✓ Current user is in docker group${NC}"
else
    echo -e "${YELLOW}⚠ Current user is NOT in docker group${NC}"
    echo "  Solution: sudo usermod -aG docker \$USER && newgrp docker"
fi

if [ -S /var/run/docker.sock ]; then
    if [ -r /var/run/docker.sock ] && [ -w /var/run/docker.sock ]; then
        echo -e "${GREEN}✓ Docker socket is accessible${NC}"
    else
        echo -e "${YELLOW}⚠ Docker socket has permission issues${NC}"
        echo "  Solution: sudo chmod 666 /var/run/docker.sock"
    fi
else
    echo -e "${RED}✗ Docker socket not found${NC}"
fi
echo ""

# Check 7: Running Containers
echo "7. Checking running containers..."
if docker ps &> /dev/null; then
    container_count=$(docker ps -q | wc -l)
    if [ $container_count -gt 0 ]; then
        echo -e "${GREEN}✓ Found $container_count running container(s)${NC}"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        echo -e "${YELLOW}⚠ No containers are running${NC}"
        echo "  This is normal if you haven't deployed yet"
    fi
else
    echo -e "${RED}✗ Cannot access Docker${NC}"
fi
echo ""

# Check 8: Docker Images
echo "8. Checking Docker images..."
if docker images &> /dev/null; then
    voting_images=$(docker images | grep -c "voting-app" || echo "0")
    if [ $voting_images -gt 0 ]; then
        echo -e "${GREEN}✓ Found $voting_images voting-app image(s)${NC}"
        docker images | grep "voting-app"
    else
        echo -e "${YELLOW}⚠ No voting-app images found${NC}"
        echo "  Images will be built during first pipeline run"
    fi
else
    echo -e "${RED}✗ Cannot access Docker${NC}"
fi
echo ""

# Check 9: Disk Space
echo "9. Checking disk space..."
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $disk_usage -lt 80 ]; then
    echo -e "${GREEN}✓ Sufficient disk space (${disk_usage}% used)${NC}"
elif [ $disk_usage -lt 90 ]; then
    echo -e "${YELLOW}⚠ Disk space is getting low (${disk_usage}% used)${NC}"
    echo "  Consider running: docker system prune -a -f"
else
    echo -e "${RED}✗ Disk space is critically low (${disk_usage}% used)${NC}"
    echo "  Solution: docker system prune -a -f --volumes"
fi
echo ""

# Check 10: Network Connectivity
echo "10. Checking network connectivity..."
if ping -c 1 hub.docker.com &> /dev/null; then
    echo -e "${GREEN}✓ Can reach Docker Hub${NC}"
else
    echo -e "${RED}✗ Cannot reach Docker Hub${NC}"
    echo "  Check your internet connection"
fi

if ping -c 1 github.com &> /dev/null; then
    echo -e "${GREEN}✓ Can reach GitHub${NC}"
else
    echo -e "${RED}✗ Cannot reach GitHub${NC}"
    echo "  Check your internet connection"
fi
echo ""

# Check 11: Application Health
echo "11. Checking application health..."
if curl -s http://localhost:5000/api/health &> /dev/null; then
    echo -e "${GREEN}✓ Backend is healthy${NC}"
    curl -s http://localhost:5000/api/health
else
    echo -e "${YELLOW}⚠ Backend is not responding${NC}"
    echo "  This is normal if application is not deployed yet"
fi

if curl -s http://localhost &> /dev/null; then
    echo -e "${GREEN}✓ Frontend is accessible${NC}"
else
    echo -e "${YELLOW}⚠ Frontend is not accessible${NC}"
    echo "  This is normal if application is not deployed yet"
fi
echo ""

# Summary
echo "=========================================="
echo "Troubleshooting Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Fix any issues marked with ✗ or ⚠"
echo "2. Review JENKINS_SETUP_GUIDE.md for detailed solutions"
echo "3. Run 'docker compose up -d' to start the application"
echo "4. Access Jenkins at http://localhost:8080"
echo ""
