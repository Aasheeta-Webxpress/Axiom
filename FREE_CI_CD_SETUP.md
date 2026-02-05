# 🆓 FREE CI/CD Setup Guide

## Option 1: GitHub Actions + Docker Hub (Recommended)

### Step 1: Create Docker Hub Account (FREE)
1. Go to https://hub.docker.com
2. Sign up for free account
3. Create repository: `axiom-backend` and `axiom-frontend`

### Step 2: Get Docker Hub Credentials
- **DOCKER_USERNAME**: Your Docker Hub username
- **DOCKER_PASSWORD**: Create Access Token:
  1. Go to Docker Hub → Account Settings → Security
  2. Click "New Access Token"
  3. Name: `github-actions`
  4. Copy the token (this is your password)

### Step 3: Setup GitHub Secrets
1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret" and add:

```
docker login -u aasheeta8913
DOCKER_USERNAME = aasheeta8913
DOCKER_PASSWORD = dckr_pat_rJH5IxlRg4PNUK3byl_kJZ0l5iQ
```

### Step 4: Use FREE Cloud Services

#### Option A: Railway (FREE $5/month credit)
1. Go to https://railway.app
2. Connect GitHub account
3. Import your repository
4. Railway will auto-deploy on push

#### Option B: Render (FREE tier)
1. Go to https://render.com
2. Connect GitHub
3. Create Web Service → Connect Repo
4. Auto-deploys on push

#### Option C: Vercel (FREE for frontend)
1. Go to https://vercel.com
2. Import GitHub repository
3. Auto-deploys frontend

## Option 2: GitHub Actions + Self-Hosted (FREE)

### Step 1: Use GitHub's FREE Runners
Update your CI/CD to use GitHub's free hosted runners:

```yaml
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest  # FREE from GitHub
    steps:
      - uses: actions/checkout@v4
      
      - name: Build and push to Docker Hub
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: your-username/axiom-backend:latest
```

### Step 2: FREE Deployment Options

#### A. Docker Hub + Railway (Easiest)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Railway

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Railway
        uses: railway-app/railway-action@v1
        with:
          api-token: ${{ secrets.RAILWAY_TOKEN }}
          service: ${{ secrets.RAILWAY_SERVICE_ID }}
```

#### B. Docker Hub + DigitalOcean ($5/month)
```yaml
# DigitalOcean App Platform (FREE $200 credit for 60 days)
name: Deploy to DigitalOcean

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to DigitalOcean
        uses: digitalocean/app_platform@v1
        with:
          app_name: axiom
          token: ${{ secrets.DIGITALOCEAN_TOKEN }}
```

## Option 3: Complete FREE Setup

### Step 1: Frontend on Vercel (FREE)
1. Push code to GitHub
2. Go to https://vercel.com
3. Import repository
4. Auto-deploys on every push

### Step 2: Backend on Railway (FREE tier)
1. Go to https://railway.app
2. Connect GitHub
3. Import repository
4. Set environment variables
5. Auto-deploys on push

### Step 3: Database on MongoDB Atlas (FREE)
1. Go to https://mongodb.com/atlas
2. Create free cluster (512MB)
3. Get connection string
4. Update environment variables

### Step 4: Redis on Redis Cloud (FREE)
1. Go to https://redis.com/try-free
2. Create free account
3. Get Redis connection string
4. Update environment variables

## Quick Start Commands

### 1. Setup GitHub Secrets
```bash
# In GitHub repo → Settings → Secrets
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-access-token
RAILWAY_TOKEN=your-railway-token
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/axiom
REDIS_URL=redis://user:pass@host:port
```

### 2. Push to Activate CI/CD
```bash
git add .
git commit -m "Add FREE CI/CD setup"
git push origin main
```

### 3. Monitor Deployment
- GitHub Actions: https://github.com/your-username/axiom/actions
- Railway: https://railway.app/project/your-project
- Vercel: https://vercel.com/your-username/axiom

## Environment Variables for FREE Services

### MongoDB Atlas (FREE)
```
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/axiom?retryWrites=true&w=majority
```

### Redis Cloud (FREE)
```
REDIS_URL=redis://default:password@host:port
```

### Railway
```
NODE_ENV=production
PORT=5000
JWT_SECRET=your-secret-key
```

## Benefits of FREE Setup

✅ **No server costs** - Use free tiers
✅ **Automated deployment** - Push to deploy
✅ **SSL certificates** - Auto-provided
✅ **Custom domains** - Free on most platforms
✅ **Monitoring** - Built-in dashboards
✅ **Scaling** - Pay-as-you-grow

## Final URLs After Setup

- **Frontend**: `https://axiom.vercel.app` (FREE)
- **Backend**: `https://axiom-backend.railway.app` (FREE tier)
- **Database**: MongoDB Atlas (FREE 512MB)
- **Cache**: Redis Cloud (FREE tier)

## Total Cost: $0/month! 🎉
