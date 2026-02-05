# 🚀 Axiom Complete Deployment Guide

## Overview

Your Axiom no-code platform is ready for production deployment with:
- ✅ Docker containerization (Frontend + Backend)
- ✅ Docker Compose for local/production setup
- ✅ Kubernetes orchestration with auto-scaling
- ✅ GitHub Actions CI/CD pipeline
- ✅ Nginx reverse proxy with SSL/TLS
- ✅ MongoDB + Redis infrastructure
- ✅ Automated backups and monitoring

---

## 📋 Deployment Options

### **Option 1: Local Development (Fastest)**
```bash
# Navigate to project root
cd /path/to/axiom

# Start everything with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f backend

# Access services:
# - Backend API: http://localhost:5000
# - MongoDB: mongodb://localhost:27017
# - Redis: localhost:6379
```

### **Option 2: Production Server**
```bash
# Use production-grade docker-compose
docker-compose -f docker-compose.prod.yml up -d

# This includes:
# - Nginx reverse proxy (port 80/443)
# - MongoDB with authentication
# - Redis with persistence
# - Backend service with 2 replicas
# - SSL/TLS certificate support
```

### **Option 3: Kubernetes Cloud Deployment**
```bash
# Deploy to Kubernetes cluster
kubectl apply -f k8s-deployment.yaml

# Monitor deployment
kubectl get pods
kubectl logs -f deployment/axiom-backend

# Access via Ingress
# Frontend: https://your-domain.com
# API: https://api.your-domain.com
```

### **Option 4: Automated CI/CD (GitHub)**
```bash
# 1. Push code to GitHub repository
git push origin main

# 2. GitHub Actions automatically:
#    - Runs tests and linting
#    - Builds Docker images
#    - Pushes to container registry
#    - Deploys to production
#    - Sends Slack notifications
```

---

## 🔧 Environment Setup

### **1. Create .env file**
```bash
# Copy the example file
cp .env.example .env

# Edit with your values
nano .env
```

### **2. Required Environment Variables**
```env
# Backend
NODE_ENV=production
PORT=5000
JWT_SECRET=your-secret-key-here
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/axiom
REDIS_URL=redis://redis:6379

# Frontend
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_SOCKET_URL=http://localhost:5000

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# AWS (if using S3)
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_REGION=us-east-1
AWS_S3_BUCKET=axiom-uploads
```

---

## 🐳 Docker Quick Reference

### **Build Images**
```bash
# Build backend
docker build -t axiom-backend:latest axiomBackend/

# Build frontend
docker build -t axiom-frontend:latest axiom/

# Build both
./build.sh
```

### **Run Containers**
```bash
# Backend only
docker run -p 5000:5000 --env-file .env axiom-backend:latest

# Frontend only
docker run -p 3000:3000 axiom-frontend:latest

# With Docker Compose (easiest)
docker-compose up -d
```

### **Common Commands**
```bash
# View logs
docker logs -f axiom-backend

# Access shell
docker exec -it axiom-backend sh

# Check health
curl http://localhost:5000/health

# Stop all containers
docker-compose down

# Remove volumes (careful!)
docker-compose down -v

# Rebuild without cache
docker-compose up -d --build --no-cache
```

---

## 📦 Service Configuration

### **Backend Service**
- **Port**: 5000
- **Health Check**: `GET /health`
- **WebSocket**: Enabled for real-time collaboration
- **Database**: MongoDB (dynamic collections)
- **Cache**: Redis (session storage, API response caching)

### **Frontend Service**
- **Port**: 3000 (dev), 80/443 (prod)
- **Build**: React/Flutter compatible
- **State Management**: Provider pattern
- **API Client**: HTTP + WebSocket

### **Database Services**
- **MongoDB**: Persistent data storage
  - Default port: 27017
  - Auth: Configurable
  - Backups: Automated daily

- **Redis**: Session + Cache layer
  - Default port: 6379
  - TTL: Configurable
  - Persistence: Enabled in production

### **Nginx Proxy** (Production)
- **HTTP Port**: 80
- **HTTPS Port**: 443
- **Rate Limiting**: 100 req/s (API), 50 req/s (general)
- **Compression**: gzip enabled
- **WebSocket**: Proxied correctly

---

## 🔐 Security Checklist

- [ ] Change all default passwords in `.env`
- [ ] Generate strong JWT_SECRET (use `openssl rand -base64 32`)
- [ ] Enable HTTPS/SSL certificates
- [ ] Configure CORS origins properly
- [ ] Set up firewall rules
- [ ] Enable database authentication
- [ ] Use secrets management (AWS Secrets Manager, etc.)
- [ ] Scan images for vulnerabilities: `trivy image axiom-backend:latest`
- [ ] Regular security updates: `npm audit fix`

---

## 🚀 Deployment Commands

### **Local Development**
```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# View all services
docker-compose ps

# Restart a service
docker-compose restart backend
```

### **Production Deployment**
```bash
# Build production images
docker build -t axiom-backend:latest -t axiom-backend:$(date +%Y%m%d) axiomBackend/
docker build -t axiom-frontend:latest -t axiom-frontend:$(date +%Y%m%d) axiom/

# Push to registry (if needed)
docker tag axiom-backend:latest myregistry/axiom-backend:latest
docker push myregistry/axiom-backend:latest

# Deploy with Docker Compose
docker-compose -f docker-compose.prod.yml up -d --pull always

# Or with Kubernetes
kubectl apply -f k8s-deployment.yaml
kubectl rollout status deployment/axiom-backend
```

### **Kubernetes Deployment**
```bash
# Create namespace
kubectl create namespace axiom

# Deploy
kubectl apply -f k8s-deployment.yaml -n axiom

# Check status
kubectl get all -n axiom
kubectl logs -f deployment/axiom-backend -n axiom

# Scale replicas
kubectl scale deployment axiom-backend --replicas=5 -n axiom

# Update image
kubectl set image deployment/axiom-backend \
  axiom-backend=myregistry/axiom-backend:latest -n axiom
```

---

## 📊 Monitoring & Logs

### **Docker Logs**
```bash
# Backend logs
docker logs -f axiom-backend --tail 100

# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
```

### **Health Checks**
```bash
# Backend health
curl http://localhost:5000/health

# Database connection
curl http://localhost:5000/health | jq '.database'

# Redis connection
redis-cli ping
```

### **Resource Usage**
```bash
# View container stats
docker stats

# CPU/Memory limits
docker inspect axiom-backend | grep -A 10 Memory
```

---

## 🔄 CI/CD Pipeline

### **GitHub Actions Setup**

1. **Push to repository**
   ```bash
   git push origin main
   ```

2. **Pipeline runs automatically:**
   - ✅ Lint & Format check
   - ✅ Unit tests
   - ✅ Security scanning (Trivy, npm audit)
   - ✅ Docker image build
   - ✅ Push to registry
   - ✅ Deploy to staging
   - ✅ Deploy to production
   - ✅ Health checks
   - ✅ Slack notifications

3. **Configure GitHub Secrets**
   ```
   DOCKER_USERNAME: your-dockerhub-username
   DOCKER_PASSWORD: your-dockerhub-token
   REGISTRY_PASSWORD: your-container-registry-token
   SLACK_WEBHOOK_URL: your-slack-webhook
   PRODUCTION_SERVER_IP: your-server-ip
   PRODUCTION_SSH_KEY: your-ssh-private-key
   ```

---

## 💾 Backup & Restore

### **Automated Backups**
```bash
# Backups run daily at 2 AM
# Location: /backups/mongodb/
# Retention: 7 days

# Manual backup
docker exec axiom-mongodb mongodump --out /backup/$(date +%Y%m%d_%H%M%S)

# List backups
ls -la /backups/mongodb/
```

### **Restore from Backup**
```bash
# Stop services
docker-compose down

# Restore database
docker exec axiom-mongodb mongorestore /backup/backup-folder

# Start services
docker-compose up -d
```

---

## 🆘 Troubleshooting

### **Common Issues**

**Port Already in Use**
```bash
# Kill process using port
lsof -i :5000
kill -9 <PID>

# Or change port in docker-compose.yml
```

**Database Connection Refused**
```bash
# Check if MongoDB is running
docker-compose ps mongodb

# Restart MongoDB
docker-compose restart mongodb

# Check connection string in .env
```

**Out of Memory**
```bash
# Increase Docker memory limit
docker update --memory 4g axiom-backend

# Or use memory limits in docker-compose.yml
```

**SSL/TLS Certificate Issues**
```bash
# Check certificate
openssl x509 -in /etc/letsencrypt/live/domain/fullchain.pem -text -noout

# Renew certificate
certbot renew --force-renewal
```

**WebSocket Connection Failed**
```bash
# Check Nginx proxy configuration
# Ensure upgrade headers are set:
# proxy_http_version 1.1;
# proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";
```

---

## 📈 Scaling & Performance

### **Horizontal Scaling (Kubernetes)**
```bash
# Auto-scale based on CPU
kubectl autoscale deployment axiom-backend --min=3 --max=10 --cpu-percent=70

# View HPA status
kubectl get hpa
```

### **Vertical Scaling (Docker Compose)**
```bash
# Increase service resources in docker-compose.yml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

### **Caching Strategy**
```bash
# Redis is pre-configured for:
# - Session storage (1 hour TTL)
# - API response caching (5 minutes TTL)
# - WebSocket connection pooling

# Monitor Redis
redis-cli
> INFO stats
> KEYS *
```

---

## 📝 File Structure

```
axiom/
├── axiomBackend/
│   ├── Dockerfile
│   ├── src/
│   ├── package.json
│   └── .env.example
├── axiom/
│   ├── pubspec.yaml
│   ├── lib/
│   └── Dockerfile (for web)
├── docker-compose.yml           # Development setup
├── docker-compose.prod.yml      # Production setup
├── k8s-deployment.yaml          # Kubernetes manifests
├── nginx.conf                   # Proxy configuration
├── mongo-init.js                # Database initialization
├── .github/workflows/ci-cd.yml  # CI/CD pipeline
├── .env.example                 # Environment template
├── DEPLOYMENT.md                # Detailed guide
└── start.sh                     # Quick start script
```

---

## ✅ Verification Checklist

After deployment, verify:

```bash
# 1. Services are running
docker-compose ps

# 2. Health checks pass
curl http://localhost:5000/health

# 3. Database is accessible
mongo mongodb://localhost:27017

# 4. Redis is running
redis-cli ping

# 5. Frontend loads
curl http://localhost:3000

# 6. API works
curl http://localhost:5000/api/projects

# 7. WebSocket connects (check browser console)

# 8. Logs show no errors
docker-compose logs | grep -i error
```

---

## 🎯 Next Steps

1. **Local Testing**
   ```bash
   docker-compose up -d
   # Test locally at http://localhost:3000
   ```

2. **Production Preparation**
   - Set up domain name
   - Configure SSL certificates
   - Set up GitHub secrets for CI/CD
   - Configure monitoring and alerts

3. **Deploy to Production**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   # Or push to GitHub for automated deployment
   ```

4. **Monitor & Maintain**
   - Set up log aggregation
   - Configure health check alerts
   - Schedule regular backups
   - Plan security updates

---

## 📞 Support Resources

- **Docker Docs**: https://docs.docker.com
- **Kubernetes Docs**: https://kubernetes.io/docs
- **GitHub Actions**: https://docs.github.com/en/actions
- **MongoDB**: https://docs.mongodb.com
- **Nginx**: https://nginx.org/en/docs
- **Troubleshooting**: See `DEPLOYMENT.md` for detailed guide

---

**🎉 You're ready to deploy! Choose your deployment option above and get started.**
