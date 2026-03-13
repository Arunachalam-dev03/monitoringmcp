#!/bin/bash
# ------------------------------------------------------------------------
# Multimodal RAG Incident Analyzer - Linux Deployment Script
# ------------------------------------------------------------------------
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}  Starting Linux Deployment for Incident Analyzer     ${NC}"
echo -e "${BLUE}======================================================${NC}\n"

# 1. Update system packages
echo -e "${YELLOW}[1/5] Updating system packages...${NC}"
sudo apt-get update
sudo apt-get install -y python3.11 python3.11-venv python3-pip git build-essential curl

# 2. Check/Install Docker and Docker Compose
echo -e "${YELLOW}[2/5] Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${NC}Docker not found. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker installed. (You may need to log out and back in for group changes to take effect)${NC}"
else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

# 3. Setup Python Virtual Environment
echo -e "${YELLOW}[3/5] Setting up Python virtual environment...${NC}"
rm -rf venv/
python3.11 -m venv venv
source venv/bin/activate

echo -e "${YELLOW}Installing Python dependencies (this might take a few minutes)...${NC}"
pip install --upgrade pip
pip install -r requirements.txt
echo -e "${GREEN}Python dependencies installed successfully.${NC}"

# 4. Setup Environment Variables
echo -e "${YELLOW}[4/5] Setting up environment configuration...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}Created .env file. Please edit it to add your OPENAI_API_KEY before starting.${NC}"
else
    echo -e "${GREEN}.env file already exists.${NC}"
fi

# 5. Start Services
echo -e "${YELLOW}[5/5] Starting services...${NC}"
echo -e "${NC}Starting Qdrant Vector Database...${NC}"
sudo docker compose up -d qdrant

echo -e "\n${BLUE}======================================================${NC}"
echo -e "${GREEN}Deployment setup complete!${NC}"
echo -e "${BLUE}======================================================${NC}"
echo -e "\nTo start the API server, run:\n"
echo -e "  source venv/bin/activate"
echo -e "  uvicorn app.main:app --host 0.0.0.0 --port 8000"
echo -e "\nNote: You can also run both the API and Qdrant in Docker:"
echo -e "  sudo docker compose up -d"
echo -e "\nThe Web UI will be available at: http://<server_ip>:8000\n"
