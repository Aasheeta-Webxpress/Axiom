---
description: Complete API Management workflow for creating and managing API endpoints
---

# API Management Workflow

## Overview
This workflow guides users through creating complete API endpoints with database integration, field validation, and testing capabilities.

## Steps

### 1. Access API Management
- Click "APIs" button in the top toolbar
- OR use `Navigator.pushNamed(context, '/api-management')` in code
- This opens the API Management Screen

### 2. Create New API Endpoint
- Click the "+" button in the app bar or "Create First API" button
- Fill in the API details:

#### Basic Configuration
- **Name**: Human-readable name (e.g., "Register User")
- **Method**: HTTP method (GET, POST, PUT, DELETE)
- **Path**: API endpoint path (e.g., `/users/register`)
- **Description**: Optional description of what the API does

#### Database Configuration  
- **Purpose**: Select from predefined purposes:
  - `login` - User authentication
  - `register` - New user registration  
  - `create` - Create new record
  - `read` - Get single record
  - `update` - Update existing record
  - `delete` - Delete record
  - `list` - Get multiple records
- **Collection**: MongoDB collection name (e.g., `users`)
- **Create Collection**: Whether to auto-create the collection

#### Field Configuration
- Add fields that define the data structure:
  - **Name**: Field name (e.g., `email`)
  - **Type**: Data type (String, Number, Boolean, Date, ObjectId, Array)
  - **Required**: Whether field is mandatory
  - **Unique**: Field must be unique
  - **Default Value**: Default value for the field
  - **Validation**: Validation rules (email, phone, url, etc.)

#### Authentication
- **Requires Auth**: Whether the endpoint needs JWT token

### 3. API Testing
- Click the menu button (⋮) on any API card
- Select "Test" to open test dialog
- View API configuration details
- Send test requests with sample data

### 4. API Management
- **Edit**: Modify existing API endpoints
- **Delete**: Remove API endpoints with confirmation
- **Duplicate**: Copy existing endpoints for similar functionality

### 5. Integration with Widgets
- In the editor, select Button or TextField widgets
- In Properties Panel, bind widgets to API endpoints
- Configure field mapping between form fields and API data

## Quick Templates

### User Registration API
```
Name: Register User
Method: POST
Path: /users/register
Purpose: register
Collection: users
Auth Required: No
Fields:
- name (String, Required)
- email (String, Required, Unique, Email validation)
- password (String, Required)
- createdAt (Date, Default: current date)
```

### User Login API
```
Name: User Login  
Method: POST
Path: /auth/login
Purpose: login
Collection: users
Auth Required: No
Fields:
- email (String, Required)
- password (String, Required)
```

### Create Record API
```
Name: Create [Model]
Method: POST
Path: /[model]
Purpose: create
Collection: [model_name]
Auth Required: Yes
Fields: [based on your data model]
```

## Code Generation Integration

The APIs created here automatically integrate with:
- **Flutter Code Export**: Generates HTTP calls with proper headers
- **Backend Code Export**: Creates Node.js/Express routes with Mongoose schemas
- **Widget Binding**: Connects UI widgets to API endpoints
- **Event Handling**: Triggers API calls on button clicks or form submissions

## Best Practices

1. **Use Clear Naming**: Make API names descriptive
2. **Proper Validation**: Add field validation rules
3. **Authentication**: Secure endpoints that modify data
4. **Consistent Paths**: Use RESTful URL patterns
5. **Field Mapping**: Ensure widget fields match API fields
6. **Test Thoroughly**: Use the test feature before using in production