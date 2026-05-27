# CUSIN Backend Infrastructure Documentation

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  Mobile App (Flutter)  │  Web Dashboard (React)                 │
│  - Incident Reporting    │  - Admin Moderation                  │
│  - Map Visualization    │  - Analytics Dashboard               │
│  - Safe Routes          │  - Trust Management                  │
│  - Circles/Contacts     │  - System Health                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│  REST API  │  WebSocket Gateway  │  Rate Limiting  │  Auth      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    APPLICATION SERVICES                         │
├─────────────────────────────────────────────────────────────────┤
│  Incident Service  │  Trust Service  │  Geo Service  │  Notify   │
│  Moderation Svc    │  Circle Service │  Route Svc    │  Analytics│
│  Audit Service     │  Deduplication  │  Anomaly Det  │  Risk     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                 │
├─────────────────────────────────────────────────────────────────┤
│  PostgreSQL + PostGIS  │  Redis Cache  │  Object Storage (S3)    │
│  - Incidents           │  - Sessions   │  - Evidence Files      │
│  - Users/Trust         │  - Heatmaps   │  - Moderation Assets   │
│  - Circles             │  - Rate Limits│                        │
│  - Geospatial Data     │               │                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE                                │
├─────────────────────────────────────────────────────────────────┤
│  Cloud Provider  │  CDN  │  Monitoring  │  Logging  │  Backup    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Interaction Flow

### Incident Reporting Flow

```
User Report → Mobile App → API Gateway → Incident Service
                                            ↓
                                    Trust Service (score)
                                            ↓
                                    Geo Service (cluster)
                                            ↓
                                    Deduplication Service (check)
                                            ↓
                                    Anomaly Detection (scan)
                                            ↓
                                    Moderation Service (queue)
                                            ↓
                                    Database (store)
                                            ↓
                                    WebSocket (notify circles)
                                            ↓
                                    Heatmap Aggregator (update)
```

### Safe Route Calculation Flow

```
Route Request → Mobile App → API Gateway → Route Service
                                            ↓
                                    Geo Service (get incidents)
                                            ↓
                                    Risk Scoring (calculate risk)
                                            ↓
                                    Route Engine (generate alternatives)
                                            ↓
                                    Time Adjustment (multiplier)
                                            ↓
                                    Return to Client
```

### Moderation Flow

```
Incident Created → Moderation Queue → AI Triage (classify)
                                            ↓
                                    ┌──────────────┬──────────────┬──────────────┐
                                    │ Auto-Approve │ Flag Review  │ Auto-Reject │
                                    └──────────────┴──────────────┴──────────────┘
                                            ↓
                                    Human Review Queue
                                            ↓
                                    Moderator Action
                                            ↓
                                    ┌──────────────┬──────────────┬──────────────┐
                                    │   Approve    │ Request Info │   Reject     │
                                    └──────────────┴──────────────┴──────────────┘
                                            ↓
                                    Status Update → User Notification → Trust Update
```

---

## Service Architecture

### Backend Services

#### 1. Incident Service
- **Responsibilities:**
  - Ingest incident reports
  - Validate report structure
  - Trigger trust scoring
  - Queue for moderation
  - Publish to realtime channels

- **Dependencies:**
  - PostgreSQL (storage)
  - Trust Service (scoring)
  - Geo Service (location processing)
  - Moderation Service (queueing)
  - Deduplication Service (duplicate check)
  - Anomaly Detection (spam check)

- **API Endpoints:**
  - POST /api/v1/incidents - Create incident
  - GET /api/v1/incidents - Get nearby incidents
  - GET /api/v1/incidents/:id - Get incident by ID
  - POST /api/v1/incidents/:id/corroborate - Corroborate incident
  - GET /api/v1/incidents/heatmap - Get heatmap data

#### 2. Trust Service
- **Responsibilities:**
  - Calculate user trust scores
  - Track report consistency
  - Detect behavioral anomalies
  - Apply trust decay over time
  - Handle abuse flagging

- **Dependencies:**
  - PostgreSQL (user data, trust events)

- **Trust Score Formula:**
  ```
  Trust_Score = (
    Report_Consistency * 0.35 +
    Corroboration_Accuracy * 0.30 +
    Volume_Score * 0.20 +
    Recency_Score * 0.15
  )
  ```

#### 3. Geo Service
- **Responsibilities:**
  - Geospatial clustering of incidents
  - Heatmap generation (grid-based)
  - Location fuzzing for privacy
  - Spatial queries for circles
  - H3 grid operations

- **Dependencies:**
  - PostgreSQL + PostGIS
  - h3-js library

- **Key Functions:**
  - `fuzzLocation(lat, lng)` - Randomize within 50-100m
  - `latLngToCell(lat, lng)` - Convert to H3 cell
  - `clusterIncidents(timeWindow)` - Spatial clustering
  - `generateHeatmap(layer)` - Risk heatmap
  - `getNearbyIncidents(lat, lng, radius)` - Spatial query

#### 4. Moderation Service
- **Responsibilities:**
  - AI-assisted triage (content classification)
  - Human review queue management
  - Community corroboration processing
  - Incident status transitions
  - Evidence handling

- **Dependencies:**
  - PostgreSQL (moderation queue)
  - Trust Service (reward/penalty)
  - Notification Service (user alerts)

- **Queue Priorities:**
  - Critical: Violence, kidnapping
  - High: Robbery, harassment
  - Normal: Other incidents
  - Low: Spam/abuse

#### 5. Circle Service
- **Responsibilities:**
  - Circle creation/management
  - Member invitation/verification
  - Circle-scoped notifications
  - Trusted contact management
  - Emergency escalation logic

- **Dependencies:**
  - PostgreSQL (circles, members)
  - Notification Service (alerts)
  - Geo Service (spatial queries)

#### 6. Contact Service
- **Responsibilities:**
  - Trusted contacts management
  - Emergency contact storage
  - Location sharing with contacts
  - Emergency escalation

- **Dependencies:**
  - PostgreSQL (contacts)
  - Notification Service (SMS/push)
  - Twilio (SMS - future)

#### 7. Route Service
- **Responsibilities:**
  - Safe route calculation
  - Risk scoring for routes
  - Time-based risk adjustment
  - Alternative route generation
  - Area risk assessment

- **Dependencies:**
  - PostgreSQL (incident data)
  - Geo Service (spatial queries)
  - Risk Scoring Service

- **Risk Formula:**
  ```
  Edge_Cost = (
    Distance * 0.30 +
    Travel_Time * 0.30 +
    Risk_Score * 0.30 +
    Road_Quality * 0.10
  )
  ```

#### 8. Notification Service
- **Responsibilities:**
  - Push notification delivery
  - Circle alert broadcasting
  - Emergency contact escalation
  - Rate-limited alert delivery
  - Delivery tracking

- **Dependencies:**
  - PostgreSQL (notifications)
  - Firebase Cloud Messaging (push - future)
  - Twilio (SMS - future)
  - WebSocket Server (realtime)

#### 9. Audit Service
- **Responsibilities:**
  - Log all user actions
  - Track resource changes
  - Generate audit reports
  - Compliance reporting
  - Security monitoring

- **Dependencies:**
  - PostgreSQL (audit logs)

#### 10. Deduplication Service
- **Responsibilities:**
  - Detect duplicate incidents
  - Hash-based similarity detection
  - Spatial-temporal clustering
  - Content similarity analysis
  - Similar incident discovery

- **Dependencies:**
  - PostgreSQL (incident data)

#### 11. Anomaly Detection Service
- **Responsibilities:**
  - Spam pattern detection
  - Coordinated manipulation detection
  - Rapid reporting detection
  - Device fingerprint correlation
  - Anomaly flagging

- **Dependencies:**
  - PostgreSQL (user data, incidents)
  - Audit Service (flagging)

#### 12. Risk Scoring Service
- **Responsibilities:**
  - Calculate incident risk scores
  - Area risk assessment
  - Dynamic risk calculation (time-adjusted)
  - Historical risk patterns
  - Batch risk processing

- **Dependencies:**
  - PostgreSQL (incident data)
  - Geo Service (spatial queries)

---

## Database Architecture

### PostgreSQL + PostGIS

#### Tables

1. **users**
   - User accounts and trust scores
   - Phone hash (SHA-256)
   - Device fingerprint
   - Privacy settings

2. **incidents**
   - Incident reports
   - Location (PostGIS POINT)
   - Fuzzed location (privacy)
   - H3 cell for clustering
   - Confidence score
   - Anomaly flags
   - Incident hash (deduplication)

3. **circles**
   - Community circles
   - Boundary (PostGIS POLYGON)
   - Member count
   - Privacy settings

4. **circle_members**
   - Circle membership
   - Role (admin, moderator, member)
   - Trust in circle

5. **trusted_contacts**
   - Emergency contacts
   - Contact type
   - Priority

6. **trust_events**
   - Trust score changes
   - Event type
   - Score delta
   - Reason

7. **moderation_queue**
   - Pending incidents
   - AI classification
   - Priority
   - Assignment

8. **anomaly_flags**
   - Detected anomalies
   - Flag type
   - Severity
   - Resolution status

9. **heatmap_cache**
   - Pre-computed risk data
   - H3 cell aggregation
   - Time buckets
   - Layer types

10. **sessions**
    - User sessions
    - Device fingerprint
    - IP address
    - Expiration

11. **notifications**
    - User notifications
    - Type, title, message
    - Priority
    - Read status

12. **audit_logs**
    - All system actions
    - User, action, resource
    - Old/new values
    - IP, user agent

#### Materialized Views

1. **daily_risk_aggregation**
   - Daily risk by H3 cell
   - Incident counts
   - Confidence averages
   - Severity distribution

2. **user_trust_summary**
   - User trust metrics
   - Report statistics
   - Approval rates

#### Indexes

- GiST indexes on geometry columns (location, boundary)
- B-tree indexes on foreign keys and frequently queried columns
- Partial indexes on status columns
- Composite indexes on common query patterns

---

## Caching Strategy

### Redis Cache Usage

1. **Session Storage**
   - User session data
   - JWT token blacklist
   - TTL: 24 hours

2. **Rate Limiting**
   - Request counters per IP/user
   - Sliding window implementation
   - TTL: 15 minutes

3. **Heatmap Caching**
   - Pre-computed risk data
   - H3 cell aggregations
   - TTL: 5-15 minutes (dynamic)

4. **Trust Score Cache**
   - User trust scores
   - Recent trust events
   - TTL: 1 hour

5. **Geospatial Cache**
   - Nearby incidents
   - Area risk summaries
   - TTL: 10 minutes

---

## WebSocket Architecture

### Connection Flow

```
Client Connect → WebSocket Server
                    ↓
            Generate Client ID
                    ↓
            Send Connected Message
                    ↓
            Client Authenticates (JWT)
                    ↓
            Subscribe to Channels
                    ↓
            Receive Real-time Updates
```

### Channel Types

1. **User Channel:** `user:{userId}`
   - Personal notifications
   - Incident approval/rejection
   - Trust score changes

2. **Circle Channel:** `circle:{circleId}`
   - Circle incidents
   - Member updates
   - Circle alerts

3. **Area Channel:** `area:{h3Cell}`
   - Nearby incidents
   - Risk updates
   - Area alerts

4. **System Channel:** `system:announcements`
   - System-wide notifications
   - Maintenance alerts
   - Feature updates

### Message Types

- `connected` - Connection established
- `authenticated` - Authentication successful
- `subscribed` - Channel subscription confirmed
- `unsubscribed` - Channel unsubscription confirmed
- `ping` - Keep-alive
- `pong` - Keep-alive response
- `error` - Error message
- `circle_incident` - New incident in circle
- `nearby_incident` - Incident near user
- `notification` - User notification

---

## Security Architecture

### Defense Layers

1. **Layer 1 - Authentication**
   - Phone verification
   - JWT tokens
   - Session management
   - Device fingerprinting

2. **Layer 2 - Rate Limiting**
   - IP-based limits
   - User-based limits
   - Endpoint-specific limits
   - DDoS protection

3. **Layer 3 - Input Validation**
   - Schema validation
   - SQL injection prevention
   - XSS prevention
   - File upload validation

4. **Layer 4 - Application Logic**
   - Trust scoring
   - Anomaly detection
   - Deduplication
   - Moderation queue

5. **Layer 5 - Data Protection**
   - Encryption at rest
   - Encryption in transit
   - Location fuzzing
   - Data minimization

6. **Layer 6 - Infrastructure**
   - Network segmentation
   - Firewall rules
   - Access controls
   - Audit logging

---

## Deployment Architecture

### Development Environment

```
Local Machine
├── PostgreSQL (Docker)
├── Redis (Docker)
├── Backend API (Node.js)
└── WebSocket Server
```

### Staging Environment

```
Cloud Provider (AWS/Azure)
├── Load Balancer
├── Application Servers (2x)
│   ├── Backend API
│   └── WebSocket Server
├── PostgreSQL (Managed)
├── Redis (Managed)
└── Object Storage (S3/Blob)
```

### Production Environment

```
Cloud Provider (AWS/Azure - South Africa Region)
├── CDN (Cloudflare)
├── Load Balancer (Multi-AZ)
├── Application Servers (Auto-scaling, 4-8 instances)
│   ├── Backend API
│   └── WebSocket Server
├── PostgreSQL (Managed, Multi-AZ, Read Replicas)
├── Redis (Managed, Cluster Mode)
├── Object Storage (S3/Blob with CDN)
├── Monitoring (Prometheus + Grafana)
├── Logging (ELK Stack or CloudWatch)
└── Backup (Automated, Cross-region)
```

---

## Monitoring & Observability

### Metrics Collection

1. **Application Metrics**
   - Request rate and latency
   - Error rate by endpoint
   - Active WebSocket connections
   - Database query performance
   - Cache hit rates

2. **Business Metrics**
   - Incident submission rate
   - Moderation queue depth
   - Trust score distribution
   - User engagement metrics
   - Anomaly detection rate

3. **Infrastructure Metrics**
   - CPU, memory, disk usage
   - Network I/O
   - Database connections
   - Redis memory usage

### Logging Strategy

1. **Application Logs**
   - Structured JSON logging
   - Log levels: ERROR, WARN, INFO, DEBUG
   - Contextual information (user_id, request_id)
   - Sensitive data masking

2. **Access Logs**
   - All HTTP requests
   - WebSocket connections
   - IP addresses
   - User agents

3. **Audit Logs**
   - All user actions
   - Resource changes
   - Administrative actions
   - Security events

### Alerting

1. **Critical Alerts**
   - Service down
   - Database connection failure
   - High error rate (> 5%)
   - Security breach detected

2. **Warning Alerts**
   - High latency (> 1s)
   - High memory usage (> 80%)
   - Queue backlog
   - Unusual traffic patterns

3. **Info Alerts**
   - Deployment completed
   - Scheduled maintenance
   - Metric thresholds

---

## Backup & Disaster Recovery

### Backup Strategy

1. **Database Backups**
   - Daily full backups
   - Hourly incremental backups
   - Point-in-time recovery (7 days)
   - Cross-region replication

2. **Object Storage Backups**
   - Versioning enabled
   - Cross-region replication
   - Lifecycle policies (auto-delete old data)

3. **Configuration Backups**
   - Environment variables
   - Security credentials
   - SSL certificates
   - Stored in secure vault

### Disaster Recovery

1. **RTO (Recovery Time Objective):** 4 hours
2. **RPO (Recovery Point Objective):** 1 hour
3. **Failover:** Automated for critical services
4. **Data Recovery:** From backups or replicas
5. **Testing:** Quarterly disaster recovery drills

---

## Scalability Strategy

### Horizontal Scaling

1. **Stateless Application Servers**
   - Auto-scaling based on CPU/memory
   - Load balancer distribution
   - Session storage in Redis

2. **Database Scaling**
   - Read replicas for read-heavy workloads
   - Connection pooling
   - Query optimization
   - Future: Sharding by region

3. **Cache Scaling**
   - Redis Cluster for high availability
   - Cache partitioning
   - Automatic failover

### Vertical Scaling

1. **Database**
   - Increase instance size
   - Optimize queries
   - Add indexes
   - Archive old data

2. **Application**
   - Increase instance size
   - Optimize code
   - Reduce memory usage
   - Profile and optimize

---

## Cost Optimization

1. **Reserved Instances**
   - Production workloads
   - 1-3 year commitments

2. **Spot Instances**
   - Non-critical workloads
   - Batch processing
   - Development/testing

3. **Auto-scaling**
   - Scale down during off-peak
   - Scale up during peak hours
   - Schedule-based scaling

4. **Storage Optimization**
   - Lifecycle policies
   - Data compression
   - Archive old data
   - Delete expired data

5. **Network Optimization**
   - CDN for static assets
   - Data transfer minimization
   - Compression enabled
   - Regional data centers

---

## Future Enhancements

1. **Microservices Migration**
   - Split into individual services
   - Service mesh (Istio/Linkerd)
   - Event-driven architecture

2. **Advanced Caching**
   - Edge caching
   - CDN for API responses
   - Intelligent cache invalidation

3. **Machine Learning**
   - Improved anomaly detection
   - Predictive risk scoring
   - Automated moderation
   - Pattern recognition

4. **Real-time Analytics**
   - Stream processing (Kafka)
   - Real-time dashboards
   - Live incident tracking

5. **Multi-region Deployment**
   - Global availability
   - Data locality
   - Reduced latency
