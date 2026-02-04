# 🚀 Axiom Complete Setup & Testing Guide

## ✅ Issues Fixed

### 1. **Dashboard Not Showing Projects**
- ✅ Fixed project loading with better error handling
- ✅ Added debug logging to track issues
- ✅ Updated ProjectProvider with proper error states

### 2. **API 500 Errors on Registration**
- ✅ Created dynamic API execution routes (`/api/dynamic/:collection`)
- ✅ Fixed MongoDB connection string
- ✅ Added proper data validation and error handling

### 3. **Previous Projects Not Showing**
- ✅ Fixed project persistence in MongoDB
- ✅ Updated Project model to support enhanced API structure
- ✅ Added proper user authentication flow

### 4. **Real-time Collaboration**
- ✅ WebSocket connections working
- ✅ Project data sync across users

## 🔧 Quick Start

### Backend Setup
```bash
# Navigate to backend folder
cd axiomBackend

# Install dependencies
npm install

# Start the server
npm run dev
# OR use the startup script
./start.bat  (Windows)
./start.sh   (Mac/Linux)
```

### Frontend Testing
1. **Start Flutter app**
2. **Login with existing account**
3. **Dashboard should show all projects**
4. **Click any project to open editor**
5. **Test registration form creation**

## 🧪 Complete Testing Workflow

### Step 1: Create Registration Form
1. Click "Test Form" button in top toolbar
2. Form appears with title, text fields, and button
3. Click widgets to see properties panel

### Step 2: Create API Endpoint
1. Click "APIs" button → Create new endpoint
2. Fill details:
   - Name: "Register User"
   - Method: POST
   - Path: `/users/register`
   - Purpose: `register`
   - Collection: `users`
   - Auth: No
3. Add fields: name, email, password

### Step 3: Bind API to Button
1. Select Register button
2. In properties panel, bind to "Register User" API
3. Save project

### Step 4: Test Registration
1. Click "Preview" → Test the form
2. Fill form fields and click Register
3. Should see success message (no 500 error!)

### Step 5: Verify Data Persistence
1. Check MongoDB `users` collection
2. New user data should be saved
3. Dashboard should show all projects
4. Old user data should be visible

## 🐛 Debug Commands

### Check Console Logs
```bash
# Backend logs
npm run dev

# Flutter logs (in terminal)
flutter run --verbose
```

### Test API Directly
```bash
# Test registration API
curl -X POST http://localhost:5000/api/dynamic/users \
  -H "Content-Type: application/json" \
  -d '{
    "method": "POST",
    "purpose": "register", 
    "data": {
      "name": "Test User",
      "email": "test@example.com",
      "password": "123456"
    }
  }'
```

## 📱 Generated Code Features

### Flutter Export
- ✅ Complete working app
- ✅ API integration with proper endpoints
- ✅ Form validation and error handling
- ✅ Success/error messages

### Backend Export  
- ✅ Node.js/Express routes
- ✅ MongoDB schemas
- ✅ Dynamic collection support
- ✅ Authentication middleware

## 🎯 Key Fixes Applied

1. **Dynamic API Routes**: `/api/dynamic/:collection` handles all CRUD operations
2. **Enhanced Project Model**: Supports new API structure with fields, validation
3. **Fixed Frontend**: Proper error handling and loading states
4. **MongoDB Connection**: Updated URI with proper database name
5. **Real-time Sync**: WebSocket collaboration working

## 🚀 Deployment Ready

The application is now fully functional and ready for deployment:

1. **Backend**: Deploy to Render/Heroku/AWS
2. **Frontend**: Build Flutter APK/IPA
3. **Database**: MongoDB Atlas configured
4. **APIs**: Dynamic endpoints working

## 📞 Support

If issues persist:
1. Check console logs for errors
2. Verify MongoDB connection
3. Ensure backend server is running
4. Test API endpoints directly

All major issues have been resolved! 🎉
