# 🏗️ Axiom Complete Infrastructure Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER BROWSER                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    HTTP/HTTPS/WebSocket
                             │
┌────────────────────────────┴────────────────────────────────────┐
│                    NGINX REVERSE PROXY                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • SSL/TLS Termination                                    │   │
│  │ • Rate Limiting (100 req/s API, 50 req/s general)       │   │
│  │ • Gzip Compression                                       │   │
│  │ • Security Headers (HSTS, CSP, X-Frame-Options)         │   │
│  │ • WebSocket Upgrade                                      │   │
│  │ • Load Balancing                                         │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────┬─────────────────────────────────┬───────────────────┘
             │                                 │
      ┌──────▼──────┐              ┌─────────▼──────┐
      │  Frontend    │              │   Backend API   │
      │  (Port 80)   │              │   (Port 5000)   │
      │              │              │                 │
      │ • React/Web  │              │ • Node.js       │
      │ • Flutter    │              │ • Express       │
      │ • Static     │              │ • Socket.io     │
      │   Assets     │              │ • JWT Auth      │
      └──────────────┘              └────────┬────────┘
                                             │
                    ┌────────────────────────┼─────────────────┐
                    │                        │                 │
              ┌─────▼──────┐          ┌─────▼──────┐    ┌─────▼──────┐
              │  MongoDB    │          │   Redis    │    │  Log Store │
              │ (Port 27017)│          │ (Port 6379)│    │ (ELK Stack)│
              │             │          │            │    │            │
              │ • Projects  │          │ • Sessions │    │ • Logs     │
              │ • Users     │          │ • Cache    │    │ • Metrics  │
              │ • APIs      │          │ • Queues   │    │ • Alerts   │
              │ • Screens   │          │            │    │            │
              │ • Widgets   │          │            │    │            │
              │ • Form Data │          │            │    │            │
              └─────────────┘          └────────────┘    └────────────┘
```

---

## 📦 Component Breakdown

### **1. Frontend (Port 3000/80)**

**Technology Stack:**
- React.js (Web)
- Flutter (Mobile)
- State Management: Provider
- HTTP Client: http package
- WebSocket: socket_io_client

**Features:**
- Real-time collaboration
- Drag-and-drop UI builder
- Live code export
- Form data submission
- Project management

**Docker Image:**
```dockerfile
# Multi-stage build
# Development: Full source with hot-reload
# Production: Static assets served by Nginx
Size: ~50MB (optimized)
```

**Deployment:**
```yaml
Development:
  - Port 3000
  - Hot module replacement
  - Source maps enabled

Production:
  - Port 80/443
  - Static asset caching
  - Gzip compression
  - CDN-ready
```

---

### **2. Backend API (Port 5000)**

**Technology Stack:**
- Node.js 18 (Alpine)
- Express.js
- MongoDB driver
- Socket.io (WebSocket)
- JWT authentication
- Redis client

**Core Services:**
```
┌─ Authentication & Authorization
│  ├─ User registration/login
│  ├─ JWT token generation
│  ├─ Refresh token rotation
│  └─ Role-based access control
│
├─ Project Management
│  ├─ Create/read/update/delete projects
│  ├─ Collaborative editing
│  ├─ Version control
│  └─ Export functionality
│
├─ API Code Generation
│  ├─ AI-powered API suggestions
│  ├─ Auto-generated CRUD endpoints
│  ├─ MongoDB collection management
│  └─ Dynamic route creation
│
├─ Real-time Collaboration
│  ├─ WebSocket connections
│  ├─ Cursor tracking
│  ├─ Widget synchronization
│  └─ Multi-user presence
│
└─ Data Services
   ├─ Form data collection
   ├─ Analytics & insights
   ├─ Backup management
   └─ File upload/download
```

**API Endpoints:**
```
Authentication:
  POST   /api/auth/register
  POST   /api/auth/login
  GET    /api/auth/me
  POST   /api/auth/refresh

Projects:
  GET    /api/projects
  POST   /api/projects
  GET    /api/projects/:id
  PUT    /api/projects/:id
  DELETE /api/projects/:id

APIs:
  GET    /api/projects/:id/apis
  POST   /api/projects/:id/apis
  PUT    /api/projects/:id/apis/:apiId
  DELETE /api/projects/:id/apis/:apiId

AI Features:
  POST   /api/ai/generate-api
  POST   /api/ai/suggest-improvements
  POST   /api/widget-suggestions
  POST   /api/ui-design/...

Dynamic Routes:
  ANY    /api/dynamic/:collection
  ANY    /api/users
  ANY    /api/orders
  ANY    /api/products
  ...
```

**WebSocket Events:**
```javascript
// Real-time collaboration
socket.emit('join-project', projectId);
socket.emit('widget-update', { projectId, widget });
socket.emit('cursor-move', { projectId, x, y, userId });

// Receive updates
socket.on('widget-updated', handleUpdate);
socket.on('cursor-moved', handleCursorMove);
```

**Health & Monitoring:**
```
GET /health
GET /health/detailed
GET /metrics (Prometheus-compatible)
```

---

### **3. MongoDB Database (Port 27017)**

**Collections:**
```javascript
// User Management
db.users
  ├─ _id (ObjectId)
  ├─ name (String)
  ├─ email (String, unique)
  ├─ password (Hashed)
  ├─ avatar (String)
  ├─ projects (Array of ObjectIds)
  ├─ createdAt (Date)
  └─ updatedAt (Date)

// Project Management
db.projects
  ├─ _id (ObjectId)
  ├─ name (String)
  ├─ description (String)
  ├─ owner (ObjectId -> users)
  ├─ screens (Array)
  │  ├─ id (String)
  │  ├─ name (String)
  │  ├─ route (String)
  │  ├─ widgets (Array)
  │  └─ lastModified (Date)
  ├─ apis (Array)
  │  ├─ id (String)
  │  ├─ name (String)
  │  ├─ method (String)
  │  ├─ path (String)
  │  ├─ collectionName (String)
  │  ├─ fields (Array)
  │  └─ auth (Boolean)
  ├─ theme (Object)
  ├─ dataModels (Array)
  ├─ collections (Array of Strings)
  ├─ createdAt (Date)
  └─ updatedAt (Date)

// Dynamic API Collections (User-created)
db.[collection_name]
  ├─ _id (ObjectId)
  ├─ ...fields (Dynamic)
  ├─ createdAt (Date)
  └─ updatedAt (Date)

// Form Submissions
db.form_data
  ├─ _id (ObjectId)
  ├─ projectId (ObjectId)
  ├─ screenId (String)
  ├─ formData (Object)
  ├─ submittedAt (Date)
  └─ userAgent (String)

// Sessions
db.sessions
  ├─ _id (ObjectId)
  ├─ userId (ObjectId)
  ├─ token (String)
  ├─ expiresAt (Date)
  └─ createdAt (Date)
```

**Indexes:**
```javascript
// Performance optimization
db.users.createIndex({ email: 1 }, { unique: true });
db.projects.createIndex({ owner: 1 });
db.projects.createIndex({ createdAt: -1 });
db.form_data.createIndex({ projectId: 1 });
db.sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 3600 });
```

**Backup Strategy:**
```bash
# Automated daily backups at 2 AM
/backups/mongodb/
├─ 2026-02-04_020000/
├─ 2026-02-03_020000/
├─ 2026-02-02_020000/
└─ ...

# Retention: 7 days
# Size: ~500MB per backup (approximate)
# Restore: mongorestore command
```

---

### **4. Redis Cache (Port 6379)**

**Storage Pattern:**
```
session:${sessionId} -> {userId, token, expiresAt}
  TTL: 1 hour

api_response:${endpoint}:${hash} -> {data, timestamp}
  TTL: 5 minutes

user:${userId}:cache -> {profile, preferences}
  TTL: 30 minutes

project:${projectId}:collaborators -> {users, cursors}
  TTL: Session-based

rate_limit:${ip}:${endpoint} -> counter
  TTL: 1 minute
```

**Performance:**
- Session lookups: <1ms
- Cache hits: 80% (estimated)
- Memory usage: 100-200MB typical
- Max connections: 1000

---

## 🐳 Docker Configuration

### **Docker Compose (Development)**

```yaml
version: '3.9'

services:
  # Backend API Service
  backend:
    build: ./axiomBackend
    ports:
      - "5000:5000"
    environment:
      NODE_ENV: development
      MONGODB_URI: mongodb://mongodb:27017/axiom
      REDIS_URL: redis://redis:6379
    depends_on:
      - mongodb
      - redis
    volumes:
      - ./axiomBackend/src:/app/src
    networks:
      - axiom-network

  # MongoDB Database
  mongodb:
    image: mongo:6.0
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - ./mongo-init.js:/docker-entrypoint-initdb.d/init.js
    networks:
      - axiom-network

  # Redis Cache
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - axiom-network

volumes:
  mongodb_data:
  redis_data:

networks:
  axiom-network:
    driver: bridge
```

### **Docker Compose (Production)**

```yaml
version: '3.9'

services:
  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - backend
    networks:
      - axiom-network

  # Backend (2 replicas)
  backend:
    build:
      context: ./axiomBackend
      target: production
    expose:
      - "5000"
    environment:
      NODE_ENV: production
      MONGODB_URI: mongodb://mongodb:27017/axiom
      REDIS_URL: redis://redis:6379
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - mongodb
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    networks:
      - axiom-network

  # MongoDB with Authentication
  mongodb:
    image: mongo:6.0
    volumes:
      - mongodb_data:/data/db
      - ./mongo-init.js:/docker-entrypoint-initdb.d/init.js
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
    restart: unless-stopped
    networks:
      - axiom-network

  # Redis with Authentication
  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - redis_data:/data
    restart: unless-stopped
    networks:
      - axiom-network

volumes:
  mongodb_data:
  redis_data:

networks:
  axiom-network:
    driver: bridge
```

---

## ⚙️ Kubernetes Configuration

**Deployment Strategy:**
```yaml
# 3 backend replicas initially
# Auto-scale 3-10 replicas based on:
#   - CPU: 70% threshold
#   - Memory: 80% threshold
#
# Rolling update strategy:
#   - maxSurge: 1 (1 extra pod during update)
#   - maxUnavailable: 0 (no downtime)
#
# Resource limits:
#   - CPU: 500m request, 1000m limit
#   - Memory: 512Mi request, 1Gi limit
```

**StatefulSets:**
- MongoDB (3 replicas in production)
- Redis (master-slave replication)

**Services:**
- ClusterIP (internal communication)
- LoadBalancer (external traffic)
- Ingress (HTTP/HTTPS routing)

**ConfigMaps & Secrets:**
- Environment configurations
- Database credentials
- API keys
- SSL certificates

---

## 🔐 Security Implementation

### **Authentication & Authorization**
```javascript
// JWT Token Structure
{
  userId: ObjectId,
  email: String,
  role: Enum['user', 'admin'],
  iat: Number,
  exp: Number
}

// Refresh Token Rotation
- Issue new refresh token every login
- Old tokens invalidated
- TTL: 7 days
- Stored in Redis for quick validation
```

### **Data Protection**
```
• Passwords: Bcrypt (10 salt rounds)
• Encryption: AES-256 for sensitive data
• SSL/TLS: 1.2+ with modern ciphers
• HSTS: Enabled (max-age: 31536000)
• CSP: Enabled (no-unsafe-inline)
```

### **Rate Limiting**
```
API Endpoints: 100 requests/second
General Endpoints: 50 requests/second
Login Endpoint: 5 requests/minute per IP
Database Connections: 100 max concurrent
WebSocket Connections: 1000 max concurrent
```

### **Input Validation**
```javascript
// Sanitization & Validation
- XSS Prevention: Sanitize HTML
- SQL Injection: Use parameterized queries
- CORS: Configured origins only
- CSRF: Token-based protection
- File Upload: Type & size validation
- API Schema: JSON Schema validation
```

---

## 📈 Performance Metrics

### **Target Performance**
```
Frontend:
  - Initial Load: < 3s
  - Paint: < 1s
  - Interactive: < 5s

Backend:
  - API Response: < 200ms (p95)
  - Database Query: < 100ms (p95)
  - WebSocket Latency: < 50ms

Database:
  - Query: < 100ms
  - Write: < 50ms
  - Connection Pool: 100 concurrent
```

### **Caching Strategy**
```
L1: Browser Cache (static assets - 30 days)
L2: Redis Cache (API responses - 5 minutes)
L3: MongoDB Cache (query results - implicit)

Cache Invalidation:
  - On-demand: API endpoint updates
  - TTL-based: Automatic expiration
  - Event-based: WebSocket notifications
```

---

## 🔄 CI/CD Pipeline

### **GitHub Actions Workflow**

**Trigger Events:**
```yaml
- Push to main (deploy to production)
- Push to develop (deploy to staging)
- Pull requests (run tests & linting)
- Manual dispatch
```

**Jobs:**

1. **Lint & Format** (5 min)
   - ESLint configuration check
   - Prettier format validation
   - YAML validation

2. **Unit Tests** (10 min)
   - Jest test suite
   - Coverage reports
   - MongoDB test container

3. **Security Scan** (5 min)
   - npm audit
   - Trivy image scanning
   - OWASP dependency check

4. **Build Images** (15 min)
   - Build backend (multi-stage)
   - Build frontend (optimized)
   - Push to registry

5. **Deploy Staging** (5 min)
   - On develop branch
   - SSH to staging server
   - Run docker-compose
   - Health checks

6. **Deploy Production** (5 min)
   - On main branch
   - SSH to production
   - Blue-green deployment
   - Smoke tests

7. **Backup** (5 min)
   - Automated MongoDB dump
   - Archive to S3
   - Retention policy

8. **Notifications** (1 min)
   - Slack webhook
   - Email alerts
   - Status badges

---

## 📊 Monitoring & Logging

### **Metrics Collection**
```
Prometheus scrapes:
  - Node.js process metrics
  - Express request metrics
  - MongoDB connection pool
  - Redis memory usage
  - Docker container stats

Interval: 15 seconds
Retention: 15 days
Queries: Grafana dashboards
```

### **Log Aggregation**
```
ELK Stack (Elasticsearch, Logstash, Kibana):
  - Application logs (JSON format)
  - Access logs (Nginx)
  - Error logs
  - Audit logs

Retention: 30 days
Search: Kibana UI
Alerts: PagerDuty integration
```

### **Alerting Rules**
```
High Priority:
  - Service down (0 health checks)
  - Database unavailable
  - Memory > 80%
  - Error rate > 5%

Medium Priority:
  - Response time > 500ms
  - Memory > 60%
  - Disk > 80%
  - API latency spike

Low Priority:
  - Security scan warnings
  - Deprecated dependencies
  - Build time increase
```

---

## 🚀 Deployment Environments

### **Development**
```
Host: localhost
Database: Local MongoDB
Cache: Local Redis
SSL: Disabled
Replicas: 1
Auto-scale: Disabled
Logging: Console
Monitoring: Basic
```

### **Staging**
```
Host: staging.example.com
Database: Managed MongoDB Atlas
Cache: Managed Redis Cloud
SSL: Let's Encrypt
Replicas: 2
Auto-scale: Enabled
Logging: CloudWatch
Monitoring: Full metrics
```

### **Production**
```
Host: api.example.com
Database: MongoDB Atlas (3 replicas, backup)
Cache: Redis Cluster
SSL: Wildcard cert
Replicas: 3-10 (auto-scale)
Auto-scale: Enabled
Logging: ELK Stack
Monitoring: Full observability
Backup: Hourly + daily
SLA: 99.9% uptime
```

---

## 💾 Disaster Recovery

### **Backup Strategy**
```
Frequency: Daily at 2 AM
Location: AWS S3
Retention: 7 days
Type: Full MongoDB dump
Size: ~500MB
Restore Time: ~2 minutes

Off-site Backup:
  - Geo-redundant storage
  - Point-in-time recovery
  - Automated verification
```

### **Recovery Procedure**
```
1. Detect failure (monitoring alert)
2. Spin up new container
3. Download backup from S3
4. Restore MongoDB from dump
5. Verify data integrity
6. Run health checks
7. Notify team

RTO: 15 minutes
RPO: 1 day
```

---

## 📚 File Reference

| File | Purpose | Location |
|------|---------|----------|
| Dockerfile | Backend containerization | `axiomBackend/` |
| docker-compose.yml | Local development setup | Root |
| docker-compose.prod.yml | Production setup | Root |
| k8s-deployment.yaml | Kubernetes manifests | Root |
| nginx.conf | Reverse proxy config | Root |
| mongo-init.js | Database initialization | Root |
| .github/workflows/ci-cd.yml | CI/CD pipeline | `.github/workflows/` |
| .env.example | Environment template | Root |
| DEPLOYMENT.md | Detailed guide | Root |
| start.sh | Quick start script | Root |
| build.sh | Build automation | Root |

---

## 🎯 Success Criteria

✅ **Deployment is successful when:**
- All containers are running and healthy
- Database migrations completed
- API health check returns 200
- WebSocket connections established
- Frontend loads in < 3 seconds
- All tests pass
- No error logs
- Monitoring shows normal metrics
- Backups are scheduled

---

**Last Updated:** February 04, 2026
**Version:** 1.0.0
**Status:** Production Ready ✅
