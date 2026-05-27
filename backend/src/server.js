const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const http = require('http');
require('dotenv').config();

const logger = require('./config/logger');
const authRoutes = require('./routes/auth');
const incidentRoutes = require('./routes/incidents');
const userRoutes = require('./routes/users');
const circleRoutes = require('./routes/circles');
const contactRoutes = require('./routes/contacts');
const adminRoutes = require('./routes/admin');
const routeRoutes = require('./routes/routes');
const WebSocketServer = require('./websocket/websocketServer');

const app = express();
const server = http.createServer(app);

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false,
}));

app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
app.use(morgan('combined', { stream: { write: (message) => logger.info(message.trim()) } }));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/incidents', incidentRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/circles', circleRoutes);
app.use('/api/v1/trusted-contacts', contactRoutes);
app.use('/api/v1/routes', routeRoutes);
app.use('/api/v1/admin', adminRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: 'The requested resource was not found',
    },
  });
});

// Error handler
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: process.env.NODE_ENV === 'production' 
        ? 'An internal error occurred' 
        : err.message,
    },
  });
});

const PORT = process.env.PORT || 3000;

// Initialize WebSocket server
const wss = new WebSocketServer(server);

// Make WebSocket server globally accessible for other services
global.websocketServer = wss;

server.listen(PORT, () => {
  logger.info(`CUSIN Backend Server running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.info(`WebSocket server initialized on ws://localhost:${PORT}/ws`);
}).on('error', (error) => {
  logger.error('Server failed to start:', error);
  process.exit(1);
});

module.exports = { app, server, wss };
