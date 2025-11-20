# Deployment Guide

## Server Details
- **IP**: 46.250.231.233
- **Username**: fionetix
- **Password**: 7ukW4i87dJ
- **Port**: 1339

## Quick Deployment

Simply run:
```bash
./deploy.sh
```

This script will automatically:
1. Connect to your SSH server
2. Install Docker and Docker Compose (if not already installed)
3. Copy all project files
4. Build and deploy your application with MongoDB
5. Start services on port 1339

## Manual Commands

### Deploy the application:
```bash
./deploy.sh
```

### View logs:
```bash
sshpass -p '7ukW4i87dJ' ssh fionetix@46.250.231.233 'cd /home/fionetix/ctf_25 && sudo docker-compose logs -f'
```

### Stop the application:
```bash
sshpass -p '7ukW4i87dJ' ssh fionetix@46.250.231.233 'cd /home/fionetix/ctf_25 && sudo docker-compose down'
```

### Restart the application:
```bash
sshpass -p '7ukW4i87dJ' ssh fionetix@46.250.231.233 'cd /home/fionetix/ctf_25 && sudo docker-compose restart'
```

### SSH into the server:
```bash
sshpass -p '7ukW4i87dJ' ssh fionetix@46.250.231.233
```

## Architecture

- **Next.js App**: Running in Docker container, exposed on port 1339
- **MongoDB**: Running in separate Docker container, internal port 27017
- **Network**: Both containers communicate through Docker network

## URLs

After deployment, your application will be available at:
- **http://46.250.231.233:1339**

## Notes

- The MongoDB database is persistent (data stored in Docker volume)
- The application automatically connects to MongoDB
- SSL/HTTPS not configured (you can add nginx reverse proxy if needed)
- The deploy script requires `sshpass` which will be auto-installed if missing
