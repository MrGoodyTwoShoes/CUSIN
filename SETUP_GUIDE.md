# CUSIN Setup Guide

This guide will help you set up the CUSIN platform for development and deployment.

## System Requirements

### Minimum Requirements
- **OS**: Windows 10+, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **RAM**: 8GB minimum (16GB recommended)
- **Storage**: 20GB free space
- **Network**: Stable internet connection

### Software Requirements
- Node.js 18+ and npm
- PostgreSQL 15+ with PostGIS extension
- Redis 7+
- Flutter 3.0+ (for mobile development only)
- Docker & Docker Compose (optional but recommended)
- Git

## Installation Steps

### Option 1: Docker Setup (Recommended)

#### 1. Install Docker
- Download Docker Desktop from https://www.docker.com/products/docker-desktop
- Install and start Docker Desktop
- Verify installation: `docker --version` and `docker-compose --version`

#### 2. Clone the Repository
```bash
git clone <repository-url>
cd CUSIN
```

#### 3. Configure Environment Variables
```bash
# Backend
cp backend/.env.example backend/.env
# Edit backend/.env with your settings

# Admin
cp admin-web/.env.local.example admin-web/.env.local
# Edit admin-web/.env.local with your settings
```

#### 4. Start Services
```bash
cd docker
docker-compose up -d
```

#### 5. Run Database Migrations
```bash
cd ../database
node migrate.js
```

#### 6. Verify Setup
- Backend health: http://localhost:3000/health
- Admin dashboard: http://localhost:3001

### Option 2: Manual Setup

#### Backend Setup

1. **Install PostgreSQL with PostGIS**
   - Windows: Download from https://www.postgresql.org/download/windows/
   - macOS: `brew install postgresql postgis`
   - Linux: `sudo apt-get install postgresql postgis`

2. **Create Database**
```bash
# Start PostgreSQL service
# Windows: Start PostgreSQL service from Services
# macOS/Linux: brew services start postgresql or sudo systemctl start postgresql

# Create database
createdb cusin
```

3. **Install Node.js Dependencies**
```bash
cd backend
npm install
```

4. **Configure Environment**
```bash
cp .env.example .env
# Edit .env with your database credentials
```

5. **Run Migrations**
```bash
cd ../database
node migrate.js
```

6. **Start Backend**
```bash
cd ../backend
npm run dev
```

#### Admin Dashboard Setup

1. **Install Dependencies**
```bash
cd admin-web
npm install
```

2. **Configure Environment**
```bash
cp .env.local.example .env.local
# Edit .env.local with your API URL
```

3. **Start Admin Dashboard**
```bash
npm run dev
```

#### Mobile App Setup

1. **Install Flutter**
   - Download from https://flutter.dev/docs/get-started/install
   - Follow platform-specific instructions
   - Verify: `flutter doctor`

2. **Install Dependencies**
```bash
cd mobile
flutter pub get
```

3. **Configure Mapbox**
   - Sign up at https://www.mapbox.com/
   - Get access token
   - Edit `lib/screens/heatmap_screen.dart` and replace `YOUR_MAPBOX_ACCESS_TOKEN`

4. **Run App**
```bash
# Connect Android device or start emulator
flutter devices

# Run app
flutter run
```

## Configuration

### Backend Configuration (.env)

```env
# Server
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cusin
DB_USER=postgres
DB_PASSWORD=your_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your_secret_key
JWT_EXPIRES_IN=7d

# Twilio (for SMS verification)
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=your_phone_number

# AWS S3 (for evidence storage)
AWS_REGION=af-south-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_S3_BUCKET=cusin-evidence

# Mapbox
MAPBOX_ACCESS_TOKEN=your_mapbox_token

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Geospatial
H3_RESOLUTION=9
LOCATION_FUZZ_RADIUS=75
```

### Admin Configuration (.env.local)

```env
NEXT_PUBLIC_API_URL=http://localhost:3000/api/v1
```

## Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL is running
- Check database credentials in .env
- Verify PostGIS extension is installed: `CREATE EXTENSION IF NOT EXISTS postgis;`

### Redis Connection Issues
- Ensure Redis is running: `redis-cli ping`
- Check Redis host and port in .env

### Flutter Build Issues
- Run `flutter doctor` to check dependencies
- Ensure Android SDK is installed
- Check Android emulator is running

### Port Conflicts
- Change ports in .env files if default ports are in use
- Backend: 3000
- Admin: 3000 (Next.js default)
- PostgreSQL: 5432
- Redis: 6379

## Development Workflow

### Backend Development
```bash
cd backend
npm run dev  # Start with hot reload
npm test     # Run tests
npm run migrate  # Run migrations
```

### Admin Development
```bash
cd admin-web
npm run dev  # Start with hot reload
npm run build  # Build for production
npm start  # Start production server
```

### Mobile Development
```bash
cd mobile
flutter pub get  # Install dependencies
flutter run  # Run on connected device/emulator
flutter test  # Run tests
flutter build apk  # Build Android APK
```

## Production Deployment

### Backend Deployment

1. **Use Environment Variables**
   - Set all required environment variables
   - Use strong JWT secret
   - Configure production database

2. **Use Process Manager**
```bash
npm install -g pm2
pm2 start src/server.js --name cusin-backend
pm2 save
pm2 startup
```

3. **Set Up Reverse Proxy**
   - Use Nginx or Apache
   - Enable HTTPS with Let's Encrypt
   - Configure CORS for production domains

4. **Database Backup**
   - Set up automated backups
   - Use pg_dump for PostgreSQL backups

### Admin Deployment

1. **Build Application**
```bash
cd admin-web
npm run build
```

2. **Deploy to Platform**
   - Vercel: `vercel deploy`
   - Netlify: `netlify deploy --prod`
   - AWS: Deploy to EC2 or ECS

3. **Configure Environment**
   - Set NEXT_PUBLIC_API_URL to production backend URL

### Mobile Deployment

1. **Build Release APK**
```bash
cd mobile
flutter build apk --release
```

2. **Sign APK**
   - Generate signing key
   - Sign the APK
   - Align the APK

3. **Upload to Play Store**
   - Create developer account
   - Upload signed APK
   - Complete store listing

## Security Best Practices

1. **Never commit .env files**
2. **Use strong passwords and secrets**
3. **Enable HTTPS in production**
4. **Keep dependencies updated**
5. **Regular security audits**
6. **Implement rate limiting**
7. **Use prepared statements for SQL**
8. **Validate all inputs**
9. **Enable CORS only for trusted domains**
10. **Monitor logs for suspicious activity**

## Support

For setup issues:
- Check logs in `backend/logs/`
- Review Docker logs: `docker-compose logs`
- Check Flutter doctor output
- Review database connection settings

## Next Steps

After setup:
1. Review the architecture document: `ARCHITECTURE.md`
2. Explore the API endpoints
3. Test the mobile app
4. Review the admin dashboard
5. Customize configuration for your needs
