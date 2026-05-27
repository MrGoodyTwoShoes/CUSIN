# CUSIN - Civilian Urban Safety Intelligence Network

A civilian-first urban safety intelligence platform for Kenya, designed to increase situational awareness, reduce victim isolation, and aggregate community safety signals while prioritizing privacy, resilience, and trust.

## Architecture Overview

CUSIN consists of three main components:

- **Backend API** (Node.js/Express) - REST API with PostgreSQL + PostGIS
- **Mobile App** (Flutter) - Android-first mobile application
- **Admin Dashboard** (Next.js/React) - Web-based moderation and analytics

## Features

### MVP Features (Phase 1)
- Anonymous/pseudonymous incident reporting
- Phone-based authentication
- Location fuzzing for privacy
- Risk heatmaps with H3 geospatial grid
- Behavioral trust scoring system
- AI-assisted moderation queue
- Basic circle management
- Safe route recommendations (future)

### Privacy-First Design
- No biometric storage
- No facial recognition
- Location fuzzing (50-100m)
- Hashed phone numbers
- Data minimization
- User control over data

## Prerequisites

- Node.js 18+
- PostgreSQL 15+ with PostGIS extension
- Redis 7+
- Flutter 3.0+ (for mobile development)
- Docker & Docker Compose (optional, for containerized setup)

## Quick Start with Docker

### 1. Clone the repository
```bash
git clone <repository-url>
cd CUSIN
```

### 2. Configure environment variables
```bash
cp backend/.env.example backend/.env
cp admin-web/.env.local.example admin-web/.env.local
```

Edit the environment files with your configuration:
- Backend: `backend/.env`
- Admin: `admin-web/.env.local`

### 3. Start all services with Docker Compose
```bash
cd docker
docker-compose up -d
```

This will start:
- PostgreSQL with PostGIS (port 5432)
- Redis (port 6379)
- Backend API (port 3000)
- Admin Dashboard (port 3001)

### 4. Run database migrations
```bash
cd ../database
node migrate.js
```

### 5. Access the applications
- Admin Dashboard: http://localhost:3001
- Backend API: http://localhost:3000
- API Health: http://localhost:3000/health

## Manual Setup (Without Docker)

### Backend Setup

1. **Install dependencies**
```bash
cd backend
npm install
```

2. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Set up PostgreSQL**
```bash
# Create database
createdb cusin

# Run migrations
cd ../database
node migrate.js
```

4. **Start the backend**
```bash
cd ../backend
npm run dev
```

The backend will be available at http://localhost:3000

### Admin Dashboard Setup

1. **Install dependencies**
```bash
cd admin-web
npm install
```

2. **Configure environment**
```bash
cp .env.local.example .env.local
# Edit .env.local with your configuration
```

3. **Start the admin dashboard**
```bash
npm run dev
```

The admin dashboard will be available at http://localhost:3000 (Next.js default)

### Mobile App Setup

1. **Install Flutter**
   - Follow the official Flutter installation guide for your OS
   - Ensure Flutter is in your PATH

2. **Install dependencies**
```bash
cd mobile
flutter pub get
```

3. **Configure Mapbox**
   - Get a Mapbox access token from https://www.mapbox.com/
   - Replace `YOUR_MAPBOX_ACCESS_TOKEN` in `lib/screens/heatmap_screen.dart`

4. **Run the app**
```bash
# For Android
flutter run

# For iOS (macOS only)
flutter run -d ios
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register with phone number
- `POST /api/v1/auth/login` - Login with phone number
- `POST /api/v1/auth/verify-phone` - Verify phone with SMS code
- `GET /api/v1/auth/me` - Get current user

### Incidents
- `POST /api/v1/incidents` - Create incident report
- `GET /api/v1/incidents` - Get nearby incidents
- `GET /api/v1/incidents/heatmap` - Get risk heatmap
- `GET /api/v1/incidents/:id` - Get incident by ID
- `POST /api/v1/incidents/:id/corroborate` - Corroborate incident

### Admin (requires admin role)
- `GET /api/v1/admin/moderation/queue` - Get moderation queue
- `PUT /api/v1/admin/moderation/queue/:id/approve` - Approve incident
- `PUT /api/v1/admin/moderation/queue/:id/reject` - Reject incident

## Database Schema

The database uses PostgreSQL with PostGIS extension for geospatial queries. Key tables:

- `users` - User accounts with trust scores
- `incidents` - Incident reports with geospatial data
- `circles` - Community circles/groups
- `circle_members` - Circle memberships
- `trusted_contacts` - Emergency contacts
- `trust_events` - Trust score history
- `moderation_queue` - Incident moderation queue
- `anomaly_flags` - Abuse detection flags

See `database/schema.sql` for complete schema.

## Trust System

The trust system uses behavioral scoring based on:
- Report consistency (35%)
- Corroboration accuracy (30%)
- Historical reliability (20%)
- Account age (10%)
- Circle engagement (5%)

Trust scores range from 0-100 and decay over inactivity.

## Geospatial System

- Uses H3 hexagonal grid for spatial aggregation
- Resolution 9 (~0.18 km²) for neighborhood views
- Location fuzzing (50-100m) for privacy
- PostGIS for spatial queries
- Risk scoring based on incident density and confidence

## Security

- JWT authentication
- Rate limiting
- Input validation
- SQL injection prevention
- CORS configuration
- Helmet security headers
- Encrypted database (in production)

## Development

### Running tests
```bash
# Backend
cd backend
npm test

# Mobile
cd mobile
flutter test
```

### Code style
- Backend: ESLint + Prettier
- Mobile: Flutter analyzer
- Admin: ESLint + Prettier

## Deployment

### Backend Deployment
1. Set environment variables in production
2. Use PostgreSQL with PostGIS
3. Configure Redis for caching
4. Use process manager (PM2)
5. Set up reverse proxy (Nginx)
6. Enable HTTPS

### Mobile Deployment
1. Build APK for Android
2. Sign and upload to Play Store
3. Configure Firebase for push notifications

### Admin Deployment
1. Build with `npm run build`
2. Deploy to Vercel, Netlify, or similar
3. Configure environment variables

## Kenya-Specific Considerations

- Data residency: Store data in Africa region (AWS Cape Town or Azure South Africa)
- Intermittent internet: Offline-first design for mobile app
- SMS verification: Use local SMS provider (e.g., Africa's Talking)
- Payment: M-Pesa integration for future premium features
- Language: Support Swahili, English, and Sheng

## Legal & Compliance

- Complies with Kenya Data Protection Act (2019)
- Privacy by design principles
- User consent for data collection
- Right to data deletion
- Regular security audits

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- GitHub Issues: [repository-url]/issues
- Email: support@cusin.example.com

## Roadmap

### Phase 1 (Current) - MVP
- Basic incident reporting
- Manual moderation
- Simple heatmaps
- Phone authentication

### Phase 2 - Community Expansion
- Multiple circles
- AI-assisted moderation
- Safe route recommendations
- Enhanced trust scoring

### Phase 3 - City-Wide Launch
- Full feature set
- Advanced anomaly detection
- Circle discovery
- Emergency escalation

### Phase 4 - National Expansion
- Multi-city support
- Institutional partnerships
- Premium features
- API ecosystem

## Acknowledgments

- Built for the safety and resilience of Kenyan communities
- Privacy-first design inspired by global best practices
- Geospatial processing powered by PostGIS and H3
