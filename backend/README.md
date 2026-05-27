# CUSIN Backend API

Civilian Urban Safety Intelligence Network - Backend Service

## Overview

The CUSIN backend provides a scalable, secure API for incident reporting, geospatial analysis, trust scoring, and community safety intelligence for Kenyan urban environments.

## Tech Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** PostgreSQL 15+ with PostGIS extension
- **Cache:** Redis 7+
- **Realtime:** WebSocket (ws)
- **Authentication:** JWT (jsonwebtoken)
- **Geospatial:** h3-js
- **Logging:** Winston + Morgan

## Features

### Core Services
- **Incident Service:** Report ingestion, validation, moderation queue
- **Trust Service:** Behavioral trust scoring, reputation engine
- **Geo Service:** Geospatial clustering, heatmap generation, location fuzzing
- **Moderation Service:** AI-assisted triage, human review queue
- **Circle Service:** Community circles, member management, circle-scoped alerts
- **Contact Service:** Trusted contacts, emergency escalation
- **Route Service:** Safe route calculation, risk-based routing
- **Notification Service:** Push notifications, circle alerts, SMS integration
- **Audit Service:** Comprehensive audit logging, compliance reporting
- **Deduplication Service:** Incident duplicate detection, similarity analysis
- **Anomaly Detection:** Spam detection, coordinated manipulation detection
- **Risk Scoring:** Incident risk assessment, area risk analysis, dynamic risk

### Security Features
- JWT authentication with phone verification
- Rate limiting (per endpoint)
- Input validation and sanitization
- Location fuzzing for privacy
- SQL injection prevention
- XSS protection
- CSRF protection
- Audit logging
- Anomaly detection

## Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env with your configuration
# Required variables:
# - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
# - JWT_SECRET
# - REDIS_HOST, REDIS_PORT
# Optional:
# - PUSH_NOTIFICATIONS_ENABLED
# - SMS_NOTIFICATIONS_ENABLED
# - TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER
```

## Database Setup

```bash
# Run database migrations
npm run migrate

# Seed database (optional)
npm run seed
```

## Running the Server

```bash
# Development mode with hot reload
npm run dev

# Production mode
npm start
```

The server will start on port 3000 (or PORT environment variable).

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register with phone number
- `POST /api/v1/auth/verify-phone` - Verify phone with SMS code
- `POST /api/v1/auth/login` - Login
- `GET /api/v1/auth/me` - Get current user

### Incidents
- `POST /api/v1/incidents` - Create incident
- `GET /api/v1/incidents` - Get nearby incidents
- `GET /api/v1/incidents/heatmap` - Get heatmap data
- `GET /api/v1/incidents/:id` - Get incident by ID
- `POST /api/v1/incidents/:id/corroborate` - Corroborate incident

### Users
- `GET /api/v1/users/me` - Get current user
- `GET /api/v1/users/me/trust-score` - Get trust score
- `GET /api/v1/users/me/incidents` - Get user's incidents
- `PUT /api/v1/users/me` - Update profile
- `DELETE /api/v1/users/me` - Delete account

### Circles
- `POST /api/v1/circles` - Create circle
- `GET /api/v1/circles` - Get circles
- `GET /api/v1/circles/:id` - Get circle by ID
- `POST /api/v1/circles/:id/members` - Add member
- `DELETE /api/v1/circles/:id/members/:userId` - Remove member
- `GET /api/v1/circles/:id/members` - Get circle members
- `PUT /api/v1/circles/:id/members/:userId/role` - Update member role
- `GET /api/v1/circles/:id/incidents` - Get circle incidents
- `GET /api/v1/circles/my-circles` - Get user's circles

### Trusted Contacts
- `POST /api/v1/trusted-contacts` - Add contact
- `GET /api/v1/trusted-contacts` - Get contacts
- `GET /api/v1/trusted-contacts/:id` - Get contact by ID
- `PUT /api/v1/trusted-contacts/:id` - Update contact
- `DELETE /api/v1/trusted-contacts/:id` - Delete contact
- `GET /api/v1/trusted-contacts/emergency` - Get emergency contacts
- `POST /api/v1/trusted-contacts/share-location` - Share location
- `POST /api/v1/trusted-contacts/escalate` - Escalate emergency

### Routes
- `POST /api/v1/routes/safe` - Calculate safe route
- `GET /api/v1/routes/area-risk` - Get area risk summary
- `GET /api/v1/routes/safe-corridors` - Get safe corridors

### Admin
- `GET /api/v1/admin/moderation/queue` - Get moderation queue
- `PUT /api/v1/admin/moderation/queue/:id/approve` - Approve incident
- `PUT /api/v1/admin/moderation/queue/:id/reject` - Reject incident

## WebSocket

Connect to `ws://localhost:3000/ws`

### Message Types
- `authenticate` - Authenticate with JWT token
- `subscribe` - Subscribe to channels
- `unsubscribe` - Unsubscribe from channels
- `ping` - Keep-alive

### Channels
- `user:{userId}` - User-specific notifications
- `circle:{circleId}` - Circle updates
- `area:{h3Cell}` - Area-specific incidents

## Project Structure

```
backend/
├── src/
│   ├── config/          # Configuration files
│   │   ├── database.js   # PostgreSQL connection
│   │   ├── logger.js     # Winston logger
│   │   └── redis.js      # Redis client
│   ├── controllers/      # Route controllers
│   │   ├── authController.js
│   │   └── incidentController.js
│   ├── database/         # Database utilities
│   │   └── connection.js
│   ├── middleware/       # Express middleware
│   │   ├── auth.js       # JWT authentication
│   │   ├── rateLimit.js  # Rate limiting
│   │   └── validation.js # Input validation
│   ├── routes/           # API routes
│   │   ├── auth.js
│   │   ├── incidents.js
│   │   ├── users.js
│   │   ├── circles.js
│   │   ├── contacts.js
│   │   ├── routes.js
│   │   └── admin.js
│   ├── services/         # Business logic
│   │   ├── trustService.js
│   │   ├── geoService.js
│   │   ├── moderationService.js
│   │   ├── circleService.js
│   │   ├── contactService.js
│   │   ├── routeService.js
│   │   ├── notificationService.js
│   │   ├── auditService.js
│   │   ├── deduplicationService.js
│   │   ├── anomalyDetectionService.js
│   │   └── riskScoringService.js
│   ├── utils/            # Utility functions
│   │   ├── validators.js
│   │   └── helpers.js
│   ├── websocket/        # WebSocket server
│   │   └── websocketServer.js
│   └── server.js         # Main server file
├── database/             # Database files
│   ├── schema.sql        # Database schema
│   ├── migrate.js        # Migration script
│   └── seed.js           # Seed script
├── docker/               # Docker files
│   ├── Dockerfile.backend
│   ├── Dockerfile.admin
│   └── docker-compose.yml
├── .env.example          # Environment variables template
├── package.json          # Dependencies
├── SECURITY.md           # Security documentation
├── INFRASTRUCTURE.md     # Infrastructure documentation
└── README.md            # This file
```

## Environment Variables

See `.env.example` for all available environment variables.

### Required
- `DB_HOST` - PostgreSQL host
- `DB_PORT` - PostgreSQL port (default: 5432)
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `JWT_SECRET` - JWT signing secret
- `REDIS_HOST` - Redis host
- `REDIS_PORT` - Redis port (default: 6379)

### Optional
- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port (default: 3000)
- `CORS_ORIGIN` - CORS origin
- `H3_RESOLUTION` - H3 grid resolution (default: 9)
- `LOCATION_FUZZ_RADIUS` - Location fuzzing radius in meters (default: 75)
- `RATE_LIMIT_WINDOW_MS` - Rate limit window (default: 900000)
- `RATE_LIMIT_MAX_REQUESTS` - Max requests per window (default: 100)
- `JWT_EXPIRES_IN` - JWT expiration (default: 7d)
- `PUSH_NOTIFICATIONS_ENABLED` - Enable push notifications (default: false)
- `SMS_NOTIFICATIONS_ENABLED` - Enable SMS notifications (default: false)
- `TWILIO_ACCOUNT_SID` - Twilio account SID
- `TWILIO_AUTH_TOKEN` - Twilio auth token
- `TWILIO_PHONE_NUMBER` - Twilio phone number

## Security

See `SECURITY.md` for comprehensive security documentation including:
- Threat model
- Security controls
- Abuse mitigation strategies
- Incident response plan
- Compliance requirements

## Infrastructure

See `INFRASTRUCTURE.md` for infrastructure documentation including:
- System architecture
- Service interactions
- Database architecture
- Deployment strategy
- Monitoring and observability

## Testing

```bash
# Run tests
npm test

# Run with coverage
npm test -- --coverage
```

## Docker

```bash
# Build and run with Docker Compose
cd docker
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

## Contributing

1. Follow the existing code style
2. Write tests for new features
3. Update documentation
4. Ensure security best practices
5. Get code review before merging

## License

MIT

## Support

For security issues: security@cusin.ke
For general support: support@cusin.ke
