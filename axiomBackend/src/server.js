import 'dotenv/config';
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import http from 'http';
import { Server } from 'socket.io';
import {projectRoutes} from './routes/projectRoutes.js';
import {apiRoutes} from './routes/apiRoutes.js';
import {authRoutes} from './routes/authRoutes.js';
import dynamicApiRoutes from './routes/dynamicApiRoutes.js';
import aiApiRoutes from './routes/aiApiRoutes.js';
import validationRoutes from './routes/validationRoutes.js';
import widgetSuggestionRoutes from './routes/widgetSuggestionRoutes.js';
import uiDesignRoutes from './routes/uiDesignRoutes.js';
import dataInsightsRoutes from './routes/dataInsightsRoutes.js';

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: [
      'http://localhost:8080',
      'http://localhost:3000',
      'http://localhost:60688',
      'http://localhost:65497',
      'http://127.0.0.1:8080',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:60688',
      'http://127.0.0.1:65497',
      '*' // Allow all origins for testing
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    credentials: true,
    optionsSuccessStatus: 200
  }
});

// Middleware
app.use(cors({
  origin: [
    'http://localhost:8080',
    'http://localhost:3000',
    'http://localhost:60688',
    'http://localhost:65497',
    'http://127.0.0.1:8080',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:60688',
    'http://127.0.0.1:65497',
    '*' // Allow all origins for testing
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  credentials: true,
  optionsSuccessStatus: 200
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Database connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

app.use('/api/projects', projectRoutes);
app.use('/api/apis', apiRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/ai', aiApiRoutes); // AI-powered features
app.use('/api/validation', validationRoutes); // Smart validation
app.use('/api/widget-suggestions', widgetSuggestionRoutes); // AI widget suggestions
app.use('/api/ui-design', uiDesignRoutes); // Smart UI design assistant
app.use('/api/data-insights', dataInsightsRoutes); // AI-powered data insights
app.use('/api', dynamicApiRoutes); // Dynamic API execution

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Axiom Backend Running' });
});

// WebSocket for real-time collaboration
io.on('connection', (socket) => {
  console.log('👤 User connected:', socket.id);

  socket.on('join-project', (projectId) => {
    socket.join(projectId);
    console.log(`User ${socket.id} joined project ${projectId}`);
  });

  socket.on('widget-update', (data) => {
    socket.to(data.projectId).emit('widget-updated', data);
  });

  socket.on('cursor-move', (data) => {
    socket.to(data.projectId).emit('cursor-moved', data);
  });

  socket.on('disconnect', () => {
    console.log('👤 User disconnected:', socket.id);
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Something went wrong!', 
    message: err.message 
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});