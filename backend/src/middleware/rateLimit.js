const rateLimit = require('express-rate-limit');

const incidentRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many incident reports. Maximum 5 per hour.',
      retryAfter: 3600,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many authentication attempts. Please try again later.',
      retryAfter: 900,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

const heatmapRateLimit = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many heatmap requests. Maximum 30 per minute.',
      retryAfter: 60,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// NEW: Location query rate limiting (anti-stalking)
const locationQueryRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many location queries. Maximum 10 per hour.',
      retryAfter: 3600,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// NEW: Circle query rate limiting (anti-enumeration)
const circleQueryRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many circle queries. Maximum 20 per hour.',
      retryAfter: 3600,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// NEW: Route query rate limiting (anti-criminal planning)
const routeQueryRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 15,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many route queries. Maximum 15 per hour.',
      retryAfter: 3600,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// NEW: General API rate limiting (anti-DDoS)
const generalRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many requests. Maximum 100 per 15 minutes.',
      retryAfter: 900,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// NEW: WebSocket connection rate limiting
const wsConnectionRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 50,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many WebSocket connections. Maximum 50 per hour.',
      retryAfter: 3600,
    },
  },
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => req.headers['upgrade'] === 'websocket', // Skip for actual WebSocket upgrade
});

module.exports = {
  incidentRateLimit,
  authRateLimit,
  heatmapRateLimit,
  locationQueryRateLimit,
  circleQueryRateLimit,
  routeQueryRateLimit,
  generalRateLimit,
  wsConnectionRateLimit,
};
