const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const logger = require('../config/logger');

class WebSocketServer {
  constructor(server) {
    this.wss = new WebSocket.Server({ 
      server,
      path: '/ws',
      clientTracking: true
    });
    
    this.clients = new Map(); // userId -> Set of WebSocket connections
    this.subscriptions = new Map(); // userId -> Set of channels
    this.setupWebSocketServer();
  }

  setupWebSocketServer() {
    this.wss.on('connection', (ws, req) => {
      const clientId = this.generateClientId();
      
      logger.info(`WebSocket client connected: ${clientId}`);

      ws.on('message', async (message) => {
        try {
          const data = JSON.parse(message);
          await this.handleMessage(ws, clientId, data);
        } catch (error) {
          logger.error('Error handling WebSocket message:', error);
          this.sendError(ws, 'INVALID_MESSAGE', 'Failed to parse message');
        }
      });

      ws.on('close', () => {
        this.handleDisconnect(clientId);
        logger.info(`WebSocket client disconnected: ${clientId}`);
      });

      ws.on('error', (error) => {
        logger.error(`WebSocket error for client ${clientId}:`, error);
      });

      // Send initial connection confirmation
      this.send(ws, {
        type: 'connected',
        clientId,
        timestamp: new Date().toISOString()
      });
    });

    logger.info('WebSocket server initialized');
  }

  generateClientId() {
    return `client_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  async handleMessage(ws, clientId, data) {
    const { type, payload } = data;

    switch (type) {
      case 'authenticate':
        await this.handleAuthenticate(ws, clientId, payload);
        break;
      
      case 'subscribe':
        await this.handleSubscribe(ws, clientId, payload);
        break;
      
      case 'unsubscribe':
        await this.handleUnsubscribe(ws, clientId, payload);
        break;
      
      case 'ping':
        this.send(ws, { type: 'pong', timestamp: new Date().toISOString() });
        break;
      
      default:
        this.sendError(ws, 'UNKNOWN_MESSAGE_TYPE', `Unknown message type: ${type}`);
    }
  }

  async handleAuthenticate(ws, clientId, payload) {
    try {
      const { token } = payload;

      if (!token) {
        this.sendError(ws, 'MISSING_TOKEN', 'Authentication token is required');
        return;
      }

      // Verify JWT token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const userId = decoded.id;

      // Store client connection
      if (!this.clients.has(userId)) {
        this.clients.set(userId, new Set());
      }
      this.clients.get(userId).add({ ws, clientId });

      // Store userId in WebSocket object for later reference
      ws.userId = userId;
      ws.clientId = clientId;

      this.send(ws, {
        type: 'authenticated',
        userId,
        timestamp: new Date().toISOString()
      });

      logger.info(`WebSocket client authenticated: ${clientId} -> userId: ${userId}`);
    } catch (error) {
      logger.error('WebSocket authentication failed:', error);
      this.sendError(ws, 'AUTH_FAILED', 'Invalid authentication token');
    }
  }

  async handleSubscribe(ws, clientId, payload) {
    try {
      if (!ws.userId) {
        this.sendError(ws, 'NOT_AUTHENTICATED', 'Client must authenticate first');
        return;
      }

      const { channels } = payload;

      if (!Array.isArray(channels)) {
        this.sendError(ws, 'INVALID_CHANNELS', 'Channels must be an array');
        return;
      }

      // Store subscriptions
      if (!this.subscriptions.has(ws.userId)) {
        this.subscriptions.set(ws.userId, new Set());
      }

      const userSubscriptions = this.subscriptions.get(ws.userId);
      channels.forEach(channel => {
        userSubscriptions.add(channel);
      });

      this.send(ws, {
        type: 'subscribed',
        channels,
        timestamp: new Date().toISOString()
      });

      logger.info(`Client ${clientId} subscribed to channels: ${channels.join(', ')}`);
    } catch (error) {
      logger.error('Error handling subscribe:', error);
      this.sendError(ws, 'SUBSCRIBE_FAILED', 'Failed to subscribe to channels');
    }
  }

  async handleUnsubscribe(ws, clientId, payload) {
    try {
      if (!ws.userId) {
        this.sendError(ws, 'NOT_AUTHENTICATED', 'Client must authenticate first');
        return;
      }

      const { channels } = payload;

      if (!Array.isArray(channels)) {
        this.sendError(ws, 'INVALID_CHANNELS', 'Channels must be an array');
        return;
      }

      const userSubscriptions = this.subscriptions.get(ws.userId);
      if (userSubscriptions) {
        channels.forEach(channel => {
          userSubscriptions.delete(channel);
        });
      }

      this.send(ws, {
        type: 'unsubscribed',
        channels,
        timestamp: new Date().toISOString()
      });

      logger.info(`Client ${clientId} unsubscribed from channels: ${channels.join(', ')}`);
    } catch (error) {
      logger.error('Error handling unsubscribe:', error);
      this.sendError(ws, 'UNSUBSCRIBE_FAILED', 'Failed to unsubscribe from channels');
    }
  }

  handleDisconnect(clientId) {
    // Remove client from all user connections
    for (const [userId, connections] of this.clients.entries()) {
      for (const connection of connections) {
        if (connection.clientId === clientId) {
          connections.delete(connection);
          
          // Clean up empty sets
          if (connections.size === 0) {
            this.clients.delete(userId);
            this.subscriptions.delete(userId);
          }
          break;
        }
      }
    }
  }

  send(ws, data) {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(data));
    }
  }

  sendError(ws, code, message) {
    this.send(ws, {
      type: 'error',
      error: { code, message },
      timestamp: new Date().toISOString()
    });
  }

  // Broadcast to specific user
  sendToUser(userId, data) {
    const connections = this.clients.get(userId);
    if (connections) {
      for (const connection of connections) {
        this.send(connection.ws, data);
      }
      return true;
    }
    return false;
  }

  // Broadcast to channel (users subscribed to channel)
  sendToChannel(channel, data) {
    let sentCount = 0;
    for (const [userId, subscriptions] of this.subscriptions.entries()) {
      if (subscriptions.has(channel)) {
        if (this.sendToUser(userId, data)) {
          sentCount++;
        }
      }
    }
    return sentCount;
  }

  // Broadcast to circle members
  sendToCircle(circleId, data) {
    const channel = `circle:${circleId}`;
    return this.sendToChannel(channel, data);
  }

  // Broadcast incident update to nearby users
  sendToNearbyUsers(h3Cell, data) {
    const channel = `area:${h3Cell}`;
    return this.sendToChannel(channel, data);
  }

  // Broadcast to all connected users
  broadcast(data) {
    let sentCount = 0;
    for (const [userId, connections] of this.clients.entries()) {
      for (const connection of connections) {
        this.send(connection.ws, data);
        sentCount++;
      }
    }
    return sentCount;
  }

  // Get connection stats
  getStats() {
    let totalConnections = 0;
    let authenticatedConnections = 0;
    
    for (const [userId, connections] of this.clients.entries()) {
      totalConnections += connections.size;
      authenticatedConnections += connections.size;
    }

    return {
      totalConnections,
      authenticatedConnections,
      uniqueUsers: this.clients.size,
      totalSubscriptions: Array.from(this.subscriptions.values())
        .reduce((sum, subs) => sum + subs.size, 0)
    };
  }
}

module.exports = WebSocketServer;
