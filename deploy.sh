#!/bin/bash

# Configuration
SSH_HOST="46.250.231.233"
SSH_USER="fionetix"
SSH_PASS="7ukW4i87dJ"
REMOTE_DIR="/home/fionetix/ctf_25"
PORT=1339

echo "========================================="
echo "CTF Project Deployment Script"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo -e "${YELLOW}sshpass not found. Installing...${NC}"
    sudo apt-get update && sudo apt-get install -y sshpass
fi

# Function to execute SSH commands
ssh_exec() {
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$SSH_HOST" "$1"
}

# Function to copy files
scp_copy() {
    sshpass -p "$SSH_PASS" scp -o StrictHostKeyChecking=no -r "$1" "$SSH_USER@$SSH_HOST:$2"
}

echo -e "${GREEN}Step 1: Testing SSH connection...${NC}"
if ssh_exec "echo 'Connection successful'"; then
    echo -e "${GREEN}✓ SSH connection established${NC}"
else
    echo -e "${RED}✗ SSH connection failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Step 2: Installing Docker on remote server...${NC}"
ssh_exec "
    if ! command -v docker &> /dev/null; then
        echo 'Installing Docker...'
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\"
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo 'Installing Docker Compose...'
        sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    # Add user to docker group
    sudo usermod -aG docker $SSH_USER || true
"
echo -e "${GREEN}✓ Docker installation complete${NC}"

echo ""
echo -e "${GREEN}Step 3: Creating remote directory...${NC}"
ssh_exec "mkdir -p $REMOTE_DIR"
echo -e "${GREEN}✓ Remote directory created${NC}"

echo ""
echo -e "${GREEN}Step 4: Copying project files to server...${NC}"
# Use rsync for better file transfer
if ! command -v rsync &> /dev/null; then
    echo -e "${YELLOW}Installing rsync...${NC}"
    sudo apt-get install -y rsync
fi
sshpass -p "$SSH_PASS" rsync -avz --exclude 'node_modules' --exclude '.next' --exclude '.git' -e "ssh -o StrictHostKeyChecking=no" ./ "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"
echo -e "${GREEN}✓ Files copied${NC}"

echo ""
echo -e "${GREEN}Step 5: Stopping existing containers...${NC}"
ssh_exec "cd $REMOTE_DIR && docker compose down || true"
echo -e "${GREEN}✓ Existing containers stopped${NC}"

echo ""
echo -e "${GREEN}Step 6: Building and starting containers...${NC}"
ssh_exec "cd $REMOTE_DIR && docker compose up -d --build"
echo -e "${GREEN}✓ Containers started${NC}"

echo ""
echo -e "${GREEN}Step 7: Checking container status...${NC}"
ssh_exec "cd $REMOTE_DIR && docker compose ps"

echo ""
echo -e "${GREEN}Step 8: Checking logs...${NC}"
ssh_exec "cd $REMOTE_DIR && docker compose logs --tail=50"

echo ""
echo "========================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "========================================="
echo ""
echo -e "Your application is now running at:"
echo -e "${YELLOW}http://$SSH_HOST:$PORT${NC}"
echo ""
echo "To view logs, run:"
echo -e "${YELLOW}sshpass -p '$SSH_PASS' ssh $SSH_USER@$SSH_HOST 'cd $REMOTE_DIR && docker compose logs -f'${NC}"
echo ""
echo "To stop the application, run:"
echo -e "${YELLOW}sshpass -p '$SSH_PASS' ssh $SSH_USER@$SSH_HOST 'cd $REMOTE_DIR && docker compose down'${NC}"
echo ""
