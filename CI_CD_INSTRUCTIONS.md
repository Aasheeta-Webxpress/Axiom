# 🚀 CI/CD SETUP INSTRUCTIONS

## Your Repository: https://github.com/Aasheeta-Webxpress/Axiom

## Step 1: Add GitHub Secrets
Go to: https://github.com/Aasheeta-Webxpress/Axiom/settings/secrets/actions

Add these secrets:
```
DOCKER_USERNAME = aasheeta8913
DOCKER_PASSWORD = dckr_pat_rJH5IxlRg4PNUK3byl_kJZ0l5iQ
```

## Step 2: Enable GitHub Pages
Go to: https://github.com/Aasheeta-Webxpress/Axiom/settings/pages
- Source: Deploy from a branch
- Branch: gh-pages (will appear after first push)
- Folder: /root
- Click Save

## Step 3: Push Your Code
Since you're having permission issues, use one of these methods:

### Method A: GitHub Web Interface (Easiest)
1. Go to: https://github.com/Aasheeta-Webxpress/Axiom
2. Click "Add file" → "Upload files"
3. Upload all files from your project folder
4. Commit message: "Setup CI/CD"
5. Click "Commit changes"

### Method B: Fix Git Credentials
1. Open Windows Credential Manager
2. Find GitHub credentials
3. Delete them
4. Try push again and use correct credentials

## What Happens After Push:
✅ GitHub Actions automatically starts
✅ Backend builds and pushes to Docker Hub
✅ Frontend deploys to GitHub Pages
✅ Your platform goes LIVE!

## Your Live URLs:
- **Frontend**: https://Aasheeta-Webxpress.github.io/Axiom/
- **Backend**: Available as Docker image: `aasheeta8913/axiom-backend:latest`

## Monitor Deployment:
Go to: https://github.com/Aasheeta-Webxpress/Axiom/actions

## Total Cost: $0/month! 🎉
