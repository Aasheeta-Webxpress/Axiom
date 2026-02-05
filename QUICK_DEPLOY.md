# 🚀 QUICK DEPLOY GUIDE (Docker Only)

## What You Get:
- ✅ **Backend**: Docker Hub automated builds
- ✅ **Frontend**: GitHub Pages (FREE hosting)
- ✅ **Database**: MongoDB in Docker
- ✅ **Cache**: Redis in Docker
- ✅ **CI/CD**: GitHub Actions (FREE)

## Step 1: Add GitHub Secrets (2 Minutes)
Go to: https://github.com/Aasheeta-Webxpress/Axiom/settings/secrets/actions

Click "New repository secret" and add:
- **DOCKER_USERNAME**: `aasheeta8913`
- **DOCKER_PASSWORD**: `dckr_pat_rJH5IxlRg4PNUK3byl_kJZ0l5iQ`

## Step 2: Enable GitHub Pages (1 Minute)
Go to: https://github.com/Aasheeta-Webxpress/Axiom/settings/pages
2. Source: Deploy from a branch
3. Branch: gh-pages
4. Folder: /root
5. Click Save

## Step 3: Push to Activate CI/CD
```bash
git add .
git commit -m "Setup Docker CI/CD"
git push origin main
```

## Step 4: Wait for Deployment
- GitHub Actions will run automatically
- Backend builds and pushes to Docker Hub
- Frontend deploys to GitHub Pages

## Your Live URLs:
- **Frontend**: https://Aasheeta-Webxpress.github.io/Axiom/
- **Backend**: Pull from Docker Hub: `docker pull aasheeta8913/axiom-backend:latest`

## Local Deployment (After CI/CD):
```bash
# Download the generated files
git pull origin main

# Deploy locally
./deploy.sh
```

## Access Your Platform:
- Frontend: http://localhost:3000
- Backend: http://localhost:5000
- Health Check: http://localhost:5000/health

## Total Cost: $0/month! 🎉
