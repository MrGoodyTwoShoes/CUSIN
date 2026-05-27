# CUSIN Technical Architecture Document
## Civilian Urban Safety Intelligence Network - MVP Design

**Version:** 1.0  
**Date:** 2026-05-27  
**Context:** Kenya (Nairobi-first)  
**Philosophy:** Privacy-first, resilience-focused, abuse-resistant

---

# 1. Complete MVP Architecture

## 1.1 High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│  Android App (Flutter)  │  Web Dashboard (React)               │
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

## 1.2 Component Interaction Flow

```
User Report → Mobile App → API Gateway → Incident Service
                                            ↓
                                    Trust Service (score)
                                            ↓
                                    Geo Service (cluster)
                                            ↓
                                    Moderation Service (triage)
                                            ↓
                                    Database (store)
                                            ↓
                                    Realtime (notify circles)
                                            ↓
                                    Heatmap Aggregator (update)
```

---

# 2. Frontend/Backend Responsibilities

## 2.1 Frontend (Mobile - Flutter)

**Core Responsibilities:**
- **Map Rendering:** Display heatmaps, incidents, safe routes using Mapbox SDK
- **Incident Reporting:** Form-based reporting with location capture, photo upload
- **Offline Support:** Local caching of critical data, queue reports for sync
- **Push Notifications:** Receive circle alerts, incident confirmations
- **Circle Management:** Create/join circles, manage trusted contacts
- **Route Visualization:** Display safe route alternatives with risk scores
- **Privacy Controls:** Anonymous mode, location fuzzing, data deletion
- **Trust Indicators:** Display user trust scores, report confidence levels

**Frontend MUST NOT:**
- Store raw GPS coordinates longer than necessary
- Expose other users' exact locations
- Cache sensitive evidence indefinitely
- Implement trust scoring logic (backend only)

## 2.2 Frontend (Web - React)

**Core Responsibilities:**
- **Admin Dashboard:** Incident moderation queue, trust score adjustments
- **Analytics:** System health metrics, abuse detection alerts
- **Circle Management:** Bulk circle operations, trust reviews
- **System Configuration:** Risk thresholds, moderation rules
- **Audit Logs:** Review moderation actions, trust score changes

## 2.3 Backend Services

### Incident Service
- Ingest incident reports
- Validate report structure
- Trigger trust scoring
- Queue for moderation
- Publish to realtime channels

### Trust Service
- Calculate user trust scores
- Track report consistency
- Detect behavioral anomalies
- Apply trust decay over time
- Handle abuse flagging

### Geo Service
- Geospatial clustering of incidents
- Heatmap generation (grid-based)
- Safe route calculation
- Location fuzzing for privacy
- Spatial queries for circles

### Moderation Service
- AI-assisted triage (content classification)
- Human review queue management
- Community corroboration processing
- Incident status transitions
- Evidence handling

### Circle Service
- Circle creation/management
- Member invitation/verification
- Circle-scoped notifications
- Trusted contact management
- Emergency escalation logic

### Notification Service
- Push notification delivery
- Circle alert broadcasting
- Emergency contact escalation
- Rate-limited alert delivery
- Delivery tracking

### Route Service
- Safe route calculation
- Risk scoring for routes
- Time-based risk adjustment
- Alternative route generation
- Route caching

### Analytics Service
- System metrics aggregation
- Abuse detection alerts
- Trust score distribution
- Incident pattern analysis
- Performance monitoring

---

# 3. Scalable Tech Stack Recommendation

## 3.1 Recommended Stack (MVP-Optimized)

### Mobile Frontend
- **Framework:** Flutter (Dart)
  - Single codebase for Android/iOS future
  - Excellent offline support
  - Strong map SDK integration (Mapbox)
  - Good performance on lower-end devices
- **State Management:** Riverpod or Bloc
- **Local Storage:** Hive (NoSQL, fast, simple)
- **Map Provider:** Mapbox GL Flutter
- **Push Notifications:** Firebase Cloud Messaging

### Web Frontend
- **Framework:** Next.js (React)
  - Server-side rendering for admin
  - API routes for simple backend needs
  - Strong TypeScript support
- **UI Library:** shadcn/ui + TailwindCSS
- **Charts:** Recharts or Chart.js

### Backend
- **Framework:** Node.js with Express or Fastify
  - JavaScript ecosystem familiarity
  - Good async performance
  - Easy containerization
- **Alternative:** Go (Gin/Echo) if performance critical
  - Better resource efficiency
  - Strong concurrency
  - Faster cold starts

### Database
- **Primary:** PostgreSQL 15+ with PostGIS extension
  - ACID compliance
  - Excellent geospatial support
  - JSONB for flexible schemas
  - Strong ecosystem
- **Cache:** Redis 7+
  - Session storage
  - Rate limiting
  - Heatmap caching
  - Realtime pub/sub
- **Object Storage:** AWS S3 or MinIO (self-hosted)
  - Evidence files
  - Moderation assets
  - Static assets

### Realtime
- **WebSocket:** Native Node.js WebSocket or Socket.io
- **Alternative:** Supabase Realtime (PostgreSQL changes)
- **Push:** Firebase Cloud Messaging

### Infrastructure
- **Hosting:** AWS (Africa region - Cape Town) or Azure (South Africa)
  - Best latency for Kenya
  - Compliance considerations
- **CDN:** Cloudflare
  - Global edge caching
  - DDoS protection
  - Edge functions
- **Container Orchestration:** Docker Compose (MVP) → Kubernetes (scale)
- **Monitoring:** Prometheus + Grafana
- **Logging:** ELK Stack (Elasticsearch, Logstash, Kibana) or Loki
- **Error Tracking:** Sentry

### AI/ML
- **Content Moderation:** OpenAI API (GPT-4 for triage) or local models
- **Anomaly Detection:** Simple statistical models (Python scikit-learn)
- **Route Optimization:** OSRM (Open Source Routing Machine) or GraphHopper

## 3.2 Alternative: BaaS Approach (Faster MVP)

If speed-to-market is critical:
- **Backend:** Supabase (PostgreSQL + Auth + Realtime + Storage)
- **Mobile:** Flutter with Supabase SDK
- **Pros:** Faster development, built-in auth, realtime, storage
- **Cons:** Less control, vendor lock-in, potential scaling limits

## 3.3 Kenya-Specific Considerations

- **Data Residency:** Consider hosting in South Africa (AWS/Azure)
- **Intermittent Internet:** Design for offline-first, sync queues
- **Low-End Devices:** Optimize Flutter app size, lazy loading
- **Data Costs:** Minimize payload sizes, compress images, efficient sync
- **Payment:** M-Pesa integration for future premium features

---

# 4. Trust and Anti-Abuse Systems

## 4.1 Behavioral Trust Engine

### Trust Score Components

```python
Trust_Score = (
    Report_Consistency * 0.30 +
    Corroboration_Accuracy * 0.25 +
    Historical_Reliability * 0.20 +
    Account_Age_Factor * 0.10 +
    Circle_Engagement * 0.10 +
    Abuse_Penalty * 0.05
)
```

### Report Consistency
- Track if user's reports align with subsequent independent reports
- Penalize reports that are consistently contradicted
- Reward reports that gain corroboration
- Decay over time (recent reports weighted more)

### Corroboration Accuracy
- Track how often user's confirmations match final incident status
- Penalize false confirmations
- Reward accurate confirmations
- Require minimum threshold before confirmation affects trust

### Historical Reliability
- Long-term track record of report accuracy
- Account for report volume (avoid gaming with few reports)
- Exponential moving average for smooth changes

### Account Age Factor
- New accounts start with neutral trust
- Gradual trust increase with consistent positive behavior
- Prevent rapid trust gaming

### Circle Engagement
- Active participation in trusted circles
- Positive feedback from circle members
- Circle leadership (with oversight)

### Abuse Penalty
- Severe penalty for confirmed abuse
- Temporary or permanent trust reduction
- Manual review for severe cases

## 4.2 Multi-Signal Validation

### Incident Confidence Scoring

```python
Incident_Confidence = (
    Independent_Reports_Count * 0.35 +
    Geospatial_Consistency * 0.25 +
    Temporal_Consistency * 0.15 +
    Evidence_Quality * 0.15 +
    Trusted_User_Confirmations * 0.10
)
```

### Independent Reports
- Count unique users reporting similar incidents
- Weight by reporter trust scores
- Time window clustering (e.g., reports within 30 minutes)
- Spatial clustering (within 200m for urban, 500m for suburban)

### Geospatial Consistency
- Check if reports cluster around plausible location
- Detect impossible travel times between reports
- Validate against known geography (roads, landmarks)

### Temporal Consistency
- Check if reports follow logical timeline
- Detect back-dating or future-dating
- Account for reporting delays

### Evidence Quality
- Photo/video evidence increases confidence
- Metadata validation (timestamp, location)
- Basic image forensics (manipulation detection)
- Audio transcription quality

### Trusted User Confirmations
- Weight confirmations by user trust
- Require minimum trust threshold to count
- Limit confirmation power per user

## 4.3 Anomaly Detection

### Detection Triggers

**Spam Detection:**
- Rate limit: Max 5 reports/hour per user
- Pattern detection: Similar reports in short time
- Content similarity: Near-duplicate text

**Coordinated Manipulation:**
- Cluster analysis: Multiple accounts reporting same pattern
- Device fingerprinting: Same device, multiple accounts
- Network analysis: Accounts from same IP/subnet
- Temporal correlation: Synchronized reporting bursts

**Bot Behavior:**
- Unnatural reporting patterns (exact intervals)
- Lack of normal user behavior (no circle engagement)
- Suspicious metadata (missing device info)
- API abuse patterns

**Suspicious Clustering:**
- Geographic clustering of low-trust reports
- Targeted reporting against specific locations/individuals
- Rapid trust score manipulation attempts

### Response Actions

- **Low Confidence:** Auto-hide, require manual review
- **Medium Suspicion:** Rate limit, flag for review
- **High Suspicion:** Temporary account suspension
- **Confirmed Abuse:** Permanent ban, evidence preservation

## 4.4 Trust Decay and Recovery

### Decay Mechanism
- Trust scores decay slowly over inactivity (6-month half-life)
- Recent behavior weighted more heavily
- Prevent trust hoarding

### Recovery Mechanism
- Consistent positive behavior gradually restores trust
- Manual review for severe cases
- Transparency in trust changes (user notifications)

---

# 5. Moderation Workflows

## 5.1 Moderation Pipeline

```
Incident Submitted
       ↓
AI Triage (automated classification)
       ↓
┌──────────────┬──────────────┬──────────────┐
│   Auto-Approve│   Flag for   │   Auto-Reject│
│   (high conf)│   Review     │   (spam/abuse)│
└──────────────┴──────────────┴──────────────┘
       ↓
Human Review Queue (priority-sorted)
       ↓
Moderator Action
       ↓
┌──────────────┬──────────────┬──────────────┐
│   Approve    │   Request    │   Reject     │
│   (publish)  │   More Info  │   (hide)     │
└──────────────┴──────────────┴──────────────┘
       ↓
Status Update → User Notification → Trust Score Update
```

## 5.2 AI-Assisted Triage

### Classification Categories
- **High Priority:** Violence, kidnapping, imminent danger
- **Medium Priority:** Robbery, harassment, suspicious activity
- **Low Priority:** Minor incidents, community alerts
- **Spam/Abuse:** Obvious spam, harassment, manipulation attempts

### AI Responsibilities
- Content classification (category, severity)
- Sentiment analysis (detect hostility)
- Language detection (support Swahili, English, Sheng)
- Evidence quality assessment
- Duplicate detection

### AI Limitations
- NEVER autonomously approve/reject
- NEVER make trust score decisions
- ALWAYS flag for human review on uncertainty
- Provide confidence scores for human review

## 5.3 Human Review Process

### Review Queue Priority
1. High-confidence, high-severity incidents
2. Low-trust user reports
3. Flagged by anomaly detection
4. Community-reported disputes
5. Routine reviews

### Review Actions
- **Approve:** Publish to heatmap, notify circles
- **Reject:** Hide incident, notify reporter (with reason)
- **Request Info:** Ask reporter for clarification/evidence
- **Escalate:** Send to senior moderator for complex cases
- **Mark Abuse:** Trigger abuse investigation

### Review SLAs
- High-severity: < 15 minutes
- Medium-severity: < 1 hour
- Low-severity: < 4 hours
- Routine: < 24 hours

## 5.4 Community Corroboration

### Corroboration Flow
1. Incident published to circle (limited visibility)
2. Circle members can confirm/deny
3. Confirmations weighted by trust score
4. Threshold reached → wider visibility
5. False confirmations penalized

### Corroboration Rules
- Only circle members can corroborate
- Minimum trust score required
- Time window for corroboration (e.g., 2 hours)
- Limit corroboration power per incident
- Prevent self-corroboration (multiple accounts)

## 5.5 Abuse Investigation

### Triggers
- Multiple abuse reports against user
- Anomaly detection alerts
- Community complaints
- Pattern analysis flags

### Investigation Process
1. Account suspension (temporary)
2. Evidence collection
3. Pattern analysis
4. Cross-reference with other accounts
5. Decision: warning, suspension, permanent ban

### Appeals Process
- User can appeal within 7 days
- Senior moderator review
- Transparent decision communication
- Evidence preservation

---

# 6. Geospatial Architecture

## 6.1 Geospatial Data Model

### Location Privacy
- **Fuzzing:** Randomize location within 50-100m radius
- **Grid System:** Use H3 hexagonal grid for aggregation
- **Temporal Fuzzing:** Generalize timestamps to 5-minute bins
- **No Raw Storage:** Never store exact user coordinates long-term

### H3 Grid System
- Resolution 8 (~0.74 km²) for city-wide heatmaps
- Resolution 9 (~0.18 km²) for neighborhood views
- Resolution 10 (~0.05 km²) for detailed analysis (admin only)

### Spatial Indexing
- PostGIS GiST indexes on geometry columns
- BRIN indexes for time-series spatial data
- Materialized views for pre-computed aggregations

## 6.2 Heatmap Generation

### Aggregation Pipeline

```sql
-- Daily risk aggregation by H3 cell
CREATE MATERIALIZED VIEW daily_risk_heatmap AS
SELECT 
    h3_cell,
    COUNT(*) as incident_count,
    SUM(confidence_score) as total_confidence,
    AVG(confidence_score) as avg_confidence,
    MAX(severity) as max_severity,
    EXTRACT(HOUR FROM incident_time) as hour_bucket
FROM incidents
WHERE 
    incident_time >= CURRENT_DATE - INTERVAL '7 days'
    AND status = 'approved'
GROUP BY h3_cell, EXTRACT(HOUR FROM incident_time);
```

### Risk Scoring
```python
Cell_Risk_Score = (
    Incident_Density * 0.40 +
    Average_Confidence * 0.30 +
    Severity_Weight * 0.20 +
    Temporal_Decay * 0.10
)
```

### Temporal Decay
- Recent incidents weighted more heavily
- 7-day rolling window for heatmaps
- Exponential decay: weight = e^(-days/3)

### Heatmap Layers
- **Base Layer:** 30-day historical risk
- **Recent Layer:** 7-day recent risk
- **Live Layer:** Last 2 hours (fuzzed, delayed)
- **Trend Layer:** Week-over-week change

## 6.3 Safe Route Calculation

### Route Engine Integration
- Use OSRM or GraphHopper for base routing
- Custom cost function incorporating risk scores
- Multiple route alternatives (safe, balanced, fast)

### Risk-Based Cost Function
```python
Edge_Cost = (
    Distance * 0.30 +
    Travel_Time * 0.30 +
    Risk_Score * 0.30 +
    Road_Quality * 0.10
)
```

### Time-Based Risk Adjustment
- Night hours (18:00-06:00): risk multiplier 1.5x
- Peak hours: risk multiplier 1.2x
- Weekend nights: risk multiplier 1.8x

### Route Caching
- Cache common routes (major corridors)
- Invalidate on significant incident changes
- TTL: 15 minutes for dynamic, 1 hour for static

## 6.4 Circle Geofencing

### Circle Boundaries
- Admin-defined polygons for estates, campuses
- User-defined circles with radius limits
- Overlap detection and conflict resolution

### Location-Based Alerts
- User enters high-risk zone: silent notification
- User near circle incident: circle alert
- User in danger: emergency contact escalation

---

# 7. Data Privacy Principles

## 7.1 Data Minimization

### Collect Only What's Necessary
- **Required:** Phone number (verification only, hashed), approximate location (fuzzed), incident type
- **Optional:** Pseudonymous display name, circle membership, evidence (with consent)
- **Never:** Biometrics, exact home address, continuous location tracking, facial data

### Data Retention
- **Incident Reports:** 90 days (anonymized after 30)
- **Evidence Files:** 30 days (auto-delete)
- **User Activity Logs:** 7 days
- **Trust Score History:** 1 year (aggregated)
- **Audit Logs:** 2 years (compliance)

### Data Deletion
- User can delete account and all associated data
- Hard deletion within 30 days of request
- Anonymized data retained for analytics only
- Evidence files deleted immediately on request

## 7.2 Privacy by Design

### Default Settings
- Anonymous reporting by default
- Location fuzzing enabled by default
- Circle membership private by default
- Opt-in for all data sharing

### Transparency
- Clear privacy policy (plain language, Swahili + English)
- In-app privacy dashboard
- Data access logs visible to users
- Trust score calculation explained

### User Control
- Granular privacy controls per feature
- Easy data export (JSON format)
- One-click data deletion
- Privacy mode (disable all tracking)

## 7.3 Encryption and Security

### At Rest
- Database encryption (AES-256)
- Object storage encryption (S3 server-side)
- Key rotation every 90 days
- Separate encryption keys per data type

### In Transit
- TLS 1.3 for all connections
- Certificate pinning on mobile
- End-to-end encryption for circle messages
- Secure WebSocket (WSS)

### Key Management
- AWS KMS or HashiCorp Vault
- Hardware security modules (HSM) for production
- Key access logging
- Emergency key destruction procedure

## 7.4 Anonymization

### Techniques
- Differential privacy for analytics
- K-anonymity for location data (minimum 5 users per cell)
- Hashing of phone numbers (salted, one-way)
- Tokenization for external references

### Aggregation Thresholds
- Never show data for < 5 users
- Never show exact locations
- Never show individual user patterns
- Always aggregate to grid cells

---

# 8. Operational Risks

## 8.1 Major Risk Categories

### False Accusations
- **Risk:** Users falsely accusing individuals or groups
- **Mitigation:** No individual identification, aggregated data only, trust scoring, moderation
- **Detection:** Pattern analysis, community reporting, anomaly detection

### Mob Justice
- **Risk:** Platform used to coordinate vigilantism
- **Mitigation:** No exact location sharing, delayed incident publishing, no individual targeting, legal warnings
- **Detection:** Keyword monitoring, behavioral analysis, rapid response team

### Political Misuse
- **Risk:** Platform weaponized for political purposes
- **Mitigation:** Political neutrality, no actor classification, content moderation, transparency
- **Detection:** Pattern analysis, external monitoring, community reports

### Misinformation
- **Risk:** False reports causing panic
- **Mitigation:** Multi-signal validation, confidence scoring, rapid correction, source attribution
- **Detection:** AI triage, cross-referencing, community flagging

### Doxxing and Stalking
- **Risk:** Platform used to track individuals
- **Mitigation:** No individual identification, location fuzzing, privacy controls, reporting mechanisms
- **Detection:** Behavioral analysis, pattern detection, user reports

### Coordinated Manipulation
- **Risk:** Bad actors gaming trust system
- **Mitigation:** Trust decay, anomaly detection, device fingerprinting, rate limiting
- **Detection:** Network analysis, clustering algorithms, manual review

### Insider Abuse
- **Risk:** Staff misusing access to data
- **Mitigation:** Least privilege access, audit logging, background checks, access reviews
- **Detection:** Audit log analysis, anomaly detection, whistleblower channels

### Legal Liability
- **Risk:** Legal action from false reports or privacy violations
- **Mitigation:** Strong terms of service, legal review, insurance, compliance with local laws
- **Detection:** Legal monitoring, compliance audits

### Technical Failure
- **Risk:** System downtime during critical incidents
- **Mitigation:** Redundancy, failover, offline support, graceful degradation
- **Detection:** Monitoring, alerting, load testing

### Data Breach
- **Risk:** Unauthorized access to sensitive data
- **Mitigation:** Encryption, access controls, security audits, breach response plan
- **Detection:** Intrusion detection, anomaly monitoring, security scanning

## 8.2 Risk Monitoring

### Continuous Monitoring
- Real-time anomaly detection
- Automated alerting for risk thresholds
- Daily security reviews
- Weekly risk assessment meetings

### Incident Response
- 24/7 on-call rotation
- Pre-defined response playbooks
- Communication templates
- Post-incident reviews

---

# 9. Phased Rollout Strategy

## Phase 1: MVP Pilot (Months 1-3)

### Scope
- **Geography:** Single Nairobi neighborhood (e.g., Westlands or Kilimani)
- **Users:** 100-500 beta users (invited only)
- **Features:** 
  - Basic incident reporting
  - Simple heatmap (daily aggregation)
  - Manual moderation only
  - Single circle (pilot community)
  - Basic trust scoring

### Success Criteria
- > 70% user retention after 30 days
- > 50 reports per week
- < 24-hour moderation SLA
- Zero major abuse incidents
- Positive user feedback (> 4.0/5.0)

### Risks
- Low user adoption
- Technical issues
- Abuse attempts
- Community distrust

## Phase 2: Community Expansion (Months 4-6)

### Scope
- **Geography:** 3-5 Nairobi neighborhoods
- **Users:** 1,000-5,000 users
- **Features:**
  - Multiple circles
  - AI-assisted moderation
  - Safe route recommendations
  - Trusted contacts
  - Improved heatmap (real-time)
  - Enhanced trust scoring

### Success Criteria
- > 60% user retention after 30 days
- > 200 reports per week
- < 4-hour moderation SLA for high-priority
- < 5% false positive rate
- Successful route adoption

### Risks
- Scaling issues
- Moderation backlog
- Trust system gaming
- Increased abuse attempts

## Phase 3: City-Wide Launch (Months 7-12)

### Scope
- **Geography:** Entire Nairobi
- **Users:** 10,000-50,000 users
- **Features:**
  - Full feature set
  - Advanced anomaly detection
  - Circle discovery
  - Emergency escalation
  - Analytics dashboard
  - API for partners

### Success Criteria
- > 50% user retention after 30 days
- > 1,000 reports per week
- < 1-hour moderation SLA for high-priority
- < 2% false positive rate
- Positive media coverage

### Risks
- Major technical failures
- PR crises
- Legal challenges
- Political interference

## Phase 4: National Expansion (Year 2+)

### Scope
- **Geography:** Major Kenyan cities (Mombasa, Kisumu, Nakuru)
- **Users:** 100,000+ users
- **Features:**
  - Multi-language support
  - Institutional partnerships
  - Advanced analytics
  - Premium features
  - API ecosystem

### Success Criteria
- Sustainable user growth
- Positive impact metrics
- Financial sustainability
- Strong partnerships

### Risks
- Regulatory changes
- Competition
- Market saturation
- Economic downturns

---

# 10. Minimal Viable Features

## MVP Feature Set (Phase 1)

### Must Have
1. **Anonymous Incident Reporting**
   - Incident type selection
   - Location capture (auto-fuzzed)
   - Optional photo upload
   - Basic description
   - Submit to moderation queue

2. **Risk Heatmap**
   - Daily aggregated risk display
   - Color-coded risk levels
   - Basic time filtering (today, this week)
   - Zoom to neighborhood level

3. **Manual Moderation**
   - Admin dashboard for review
   - Approve/reject actions
   - Basic incident details
   - Evidence viewing

4. **Basic Trust Scoring**
   - Simple reputation system
   - Report consistency tracking
   - Trust score display (admin only)

5. **Single Circle**
   - Pilot community circle
   - Member invitation
   - Circle-scoped incident visibility
   - Basic circle notifications

6. **User Authentication**
   - Phone number verification
   - Basic session management
   - Anonymous mode option

### Should Have
7. **Push Notifications**
   - Incident approval notifications
   - Circle alerts
   - System announcements

8. **Offline Support**
   - Report queuing
   - Basic heatmap caching
   - Sync on reconnect

9. **Privacy Controls**
   - Data deletion request
   - Privacy settings
   - Anonymous mode toggle

### Could Have (Phase 2)
10. **Multiple Circles**
11. **Safe Routes**
12. **AI Moderation**
13. **Trusted Contacts**
14. **Real-time Heatmap**

---

# 11. What NOT to Build Initially

## Out of Scope for MVP

### Surveillance Features
- ❌ Facial recognition
- ❌ Biometric storage
- ❌ Exact live location tracking
- ❌ Individual identification
- ❌ License plate recognition
- ❌ Voice recognition

### Policing Features
- ❌ Direct police integration
- ❌ Emergency dispatch
- ❌ Suspect identification
- ❌ Evidence chain of custody
- ❌ Legal testimony support

### Social Features
- ❌ Public user profiles
- ❌ Social networking
- ❌ Public comments
- ❌ Like/share buttons
- ❌ Follower systems

### Advanced AI
- ❌ Predictive policing
- ❌ Autonomous decision-making
- ❌ Behavioral profiling
- ❌ Risk prediction for individuals
- ❌ Automated suspect identification

### Complex Integrations
- ❌ Government APIs
- ❌ Bank integrations
- ❌ Social media integrations
- ❌ Third-party data providers
- ❌ Complex partner ecosystems

### Premium Features
- ❌ Subscription tiers
- ❌ Paid features
- ❌ Advertising
- ❌ Data monetization
- ❌ Enterprise features

### Geographic Expansion
- ❌ Multi-city support
- ❌ International support
- ❌ Multi-language support
- ❌ Complex regional configurations

---

# 12. System Diagrams

## 12.1 Data Flow Diagram

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  User   │────▶│  Mobile │────▶│  API    │────▶│ Incident│
│         │     │   App   │     │ Gateway │     │ Service │
└─────────┘     └─────────┘     └─────────┘     └────┬────┘
                                                   │
                              ┌────────────────────┼────────────────────┐
                              ▼                    ▼                    ▼
                        ┌─────────┐          ┌─────────┐          ┌─────────┐
                        │  Trust  │          │   Geo   │          │Moderate │
                        │ Service │          │ Service │          │ Service │
                        └────┬────┘          └────┬────┘          └────┬────┘
                             │                    │                    │
                             └────────────────────┼────────────────────┘
                                                  ▼
                                           ┌─────────┐
                                           │Database │
                                           │ (PostGIS)│
                                           └────┬────┘
                                                │
                              ┌─────────────────┼─────────────────┐
                              ▼                 ▼                 ▼
                        ┌─────────┐      ┌─────────┐      ┌─────────┐
                        │  Heatmap│      │ Notify │      │ Analytics│
                        │Generator│      │ Service│      │ Service │
                        └────┬────┘      └────┬────┘      └─────────┘
                             │                │
                             └────────────────┼────────────────┐
                                              ▼                ▼
                                       ┌─────────┐      ┌─────────┐
                                       │  Users  │      │  Admin  │
                                       └─────────┘      └─────────┘
```

## 12.2 Trust System Flow

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  User   │────▶│  Report │────▶│  Trust  │────▶│  Score  │
│ Action  │     │ Submit  │     │ Engine  │     │ Update  │
└─────────┘     └─────────┘     └────┬────┘     └────┬────┘
                                     │                │
                      ┌──────────────┼──────────────┼──────────────┐
                      ▼              ▼              ▼              ▼
               ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
               │Consistency│  │Corroboration│ │Historical│  │Abuse    │
               │Check     │   │Check     │   │Reliability│ │Penalty  │
               └────┬────┘   └────┬────┘   └────┬────┘   └────┬────┘
                    │             │             │             │
                    └─────────────┼─────────────┼─────────────┘
                                  ▼             ▼
                           ┌─────────────────────┐
                           │  Trust Calculation │
                           └──────────┬──────────┘
                                      ▼
                           ┌─────────────────────┐
                           │  Score Applied     │
                           │  (Decay + Recovery) │
                           └─────────────────────┘
```

## 12.3 Moderation Pipeline

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ Incident│────▶│   AI    │────▶│  Queue  │────▶│ Human   │
│ Submit  │     │ Triage  │     │ Manager │     │ Review  │
└─────────┘     └────┬────┘     └────┬────┘     └────┬────┘
                     │                │                │
          ┌──────────┼──────────┐    │    ┌───────────┼───────────┐
          ▼          ▼          ▼    ▼    ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
    │  Auto   │ │  Flag   │ │  Auto   │ │ Approve │ │ Reject │ │Request  │
    │ Approve │ │ for     │ │ Reject │ │         │ │         │ │ More    │
    │         │ │ Review  │ │         │ │         │ │         │ │ Info    │
    └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
         │           │           │           │           │           │
         └───────────┴───────────┴───────────┴───────────┴───────────┘
                                      │
                                      ▼
                           ┌─────────────────────┐
                           │  Status Update      │
                           │  + Notification     │
                           │  + Trust Update     │
                           └─────────────────────┘
```

## 12.4 Geospatial Processing

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ Location│────▶│ Fuzzing │────▶│  H3     │────▶│ Spatial │
│ Capture │     │ (50-100m)│     │ Grid    │     │ Index   │
└─────────┘     └─────────┘     └────┬────┘     └────┬────┘
                                     │                │
                          ┌──────────┼──────────┐     │
                          ▼          ▼          ▼     ▼
                   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
                   │Cluster  │ │Aggregate│ │Risk     │ │Heatmap  │
                   │Analysis │ │by Cell  │ │Scoring  │ │Generation│
                   └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
                        │           │           │           │
                        └───────────┼───────────┼───────────┘
                                    ▼           ▼
                             ┌─────────────────────┐
                             │  Cached Heatmap     │
                             │  (Redis + CDN)      │
                             └──────────┬──────────┘
                                        │
                              ┌─────────┴─────────┐
                              ▼                   ▼
                       ┌─────────┐         ┌─────────┐
                       │  Mobile │         │   Web   │
                       │  App    │         │ Dashboard│
                       └─────────┘         └─────────┘
```

---

# 13. Database Schema Recommendations

## 13.1 Core Tables

### users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_hash VARCHAR(64) UNIQUE NOT NULL,  -- SHA-256 hashed phone
    display_name VARCHAR(100),  -- Optional pseudonym
    trust_score DECIMAL(5,2) DEFAULT 50.00,  -- 0-100 scale
    trust_score_history JSONB,  -- Historical scores
    account_status VARCHAR(20) DEFAULT 'active',  -- active, suspended, banned
    created_at TIMESTAMP DEFAULT NOW(),
    last_active TIMESTAMP,
    privacy_settings JSONB DEFAULT '{}',
    device_fingerprint VARCHAR(255),
    INDEX idx_phone_hash (phone_hash),
    INDEX idx_trust_score (trust_score),
    INDEX idx_account_status (account_status)
);
```

### incidents
```sql
CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    incident_type VARCHAR(50) NOT NULL,  -- robbery, harassment, etc.
    description TEXT,
    location GEOGRAPHY(POINT, 4326),  -- PostGIS point
    h3_cell VARCHAR(20),  -- H3 hex cell
    fuzzed_location GEOGRAPHY(POINT, 4326),  -- Privacy-fuzzed
    severity VARCHAR(20) DEFAULT 'medium',  -- low, medium, high, critical
    confidence_score DECIMAL(5,2),  -- 0-100
    status VARCHAR(20) DEFAULT 'pending',  -- pending, approved, rejected, under_review
    evidence_urls JSONB,  -- Array of S3 URLs
    reported_at TIMESTAMP DEFAULT NOW(),
    incident_time TIMESTAMP,  -- When incident occurred
    moderated_by UUID REFERENCES users(id),
    moderated_at TIMESTAMP,
    moderation_notes TEXT,
    corroborations JSONB DEFAULT '[]',  -- Array of corroboration data
    anomaly_flags JSONB DEFAULT '{}',
    INDEX idx_user_id (user_id),
    INDEX idx_location (location),
    INDEX idx_h3_cell (h3_cell),
    INDEX idx_status (status),
    INDEX idx_reported_at (reported_at),
    INDEX idx_incident_type (incident_type)
);
```

### circles
```sql
CREATE TABLE circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    creator_id UUID REFERENCES users(id),
    circle_type VARCHAR(50) DEFAULT 'community',  -- community, estate, campus, workplace
    boundary GEOGRAPHY(POLYGON, 4326),  -- Optional geofence
    member_count INTEGER DEFAULT 0,
    is_private BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_creator_id (creator_id),
    INDEX idx_circle_type (circle_type)
);
```

### circle_members
```sql
CREATE TABLE circle_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID REFERENCES circles(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member',  -- member, admin, moderator
    joined_at TIMESTAMP DEFAULT NOW(),
    trust_in_circle DECIMAL(5,2) DEFAULT 50.00,
    UNIQUE(circle_id, user_id),
    INDEX idx_circle_id (circle_id),
    INDEX idx_user_id (user_id)
);
```

### trusted_contacts
```sql
CREATE TABLE trusted_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    contact_name VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    contact_type VARCHAR(20) DEFAULT 'emergency',  -- emergency, family, friend
    priority INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id)
);
```

### trust_events
```sql
CREATE TABLE trust_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    event_type VARCHAR(50) NOT NULL,  -- report_approved, report_rejected, abuse_flagged, etc.
    score_change DECIMAL(5,2),
    previous_score DECIMAL(5,2),
    new_score DECIMAL(5,2),
    reason TEXT,
    related_incident_id UUID REFERENCES incidents(id),
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);
```

### moderation_queue
```sql
CREATE TABLE moderation_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID REFERENCES incidents(id),
    priority VARCHAR(20) DEFAULT 'normal',  -- low, normal, high, critical
    ai_classification JSONB,  -- AI triage results
    ai_confidence DECIMAL(5,2),
    assigned_to UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending',  -- pending, assigned, reviewed, escalated
    created_at TIMESTAMP DEFAULT NOW(),
    reviewed_at TIMESTAMP,
    review_duration_seconds INTEGER,
    INDEX idx_priority (priority),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

### anomaly_flags
```sql
CREATE TABLE anomaly_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    incident_id UUID REFERENCES incidents(id),
    flag_type VARCHAR(50) NOT NULL,  -- spam, coordinated, bot, etc.
    severity VARCHAR(20) DEFAULT 'medium',
    description TEXT,
    metadata JSONB,
    resolved BOOLEAN DEFAULT false,
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id),
    INDEX idx_incident_id (incident_id),
    INDEX idx_resolved (resolved)
);
```

### heatmap_cache
```sql
CREATE TABLE heatmap_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    h3_cell VARCHAR(20) NOT NULL,
    risk_score DECIMAL(5,2),
    incident_count INTEGER,
    avg_confidence DECIMAL(5,2),
    max_severity VARCHAR(20),
    time_bucket VARCHAR(20),  -- hour of day
    date_bucket DATE,
    layer_type VARCHAR(20),  -- base, recent, live, trend
    valid_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(h3_cell, time_bucket, date_bucket, layer_type),
    INDEX idx_h3_cell (h3_cell),
    INDEX idx_valid_until (valid_until)
);
```

### sessions
```sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    device_fingerprint VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    last_activity TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    INDEX idx_user_id (user_id),
    INDEX idx_device_fingerprint (device_fingerprint),
    INDEX idx_expires_at (expires_at)
);
```

### audit_logs
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_resource_type (resource_type),
    INDEX idx_created_at (created_at)
);
```

## 13.2 Materialized Views

### daily_risk_aggregation
```sql
CREATE MATERIALIZED VIEW daily_risk_aggregation AS
SELECT 
    DATE_TRUNC('day', incident_time) as date,
    h3_cell,
    incident_type,
    COUNT(*) as incident_count,
    AVG(confidence_score) as avg_confidence,
    MAX(severity) as max_severity,
    SUM(CASE WHEN severity = 'critical' THEN 1 ELSE 0 END) as critical_count,
    SUM(CASE WHEN severity = 'high' THEN 1 ELSE 0 END) as high_count
FROM incidents
WHERE status = 'approved'
GROUP BY DATE_TRUNC('day', incident_time), h3_cell, incident_type;

CREATE UNIQUE INDEX idx_daily_risk_agg ON daily_risk_aggregation(date, h3_cell, incident_type);
```

### user_trust_summary
```sql
CREATE MATERIALIZED VIEW user_trust_summary AS
SELECT 
    user_id,
    trust_score,
    COUNT(*) as total_reports,
    SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_reports,
    SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_reports,
    AVG(confidence_score) as avg_report_confidence,
    MAX(created_at) as last_report
FROM incidents
GROUP BY user_id, trust_score;

CREATE UNIQUE INDEX idx_user_trust_summary ON user_trust_summary(user_id);
```

---

# 14. API Structure Recommendations

## 14.1 REST API Endpoints

### Authentication
```
POST   /api/v1/auth/register
POST   /api/v1/auth/verify-phone
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh-token
```

### Incidents
```
POST   /api/v1/incidents
GET    /api/v1/incidents
GET    /api/v1/incidents/:id
PUT    /api/v1/incidents/:id
DELETE /api/v1/incidents/:id
GET    /api/v1/incidents/nearby
GET    /api/v1/incidents/heatmap
POST   /api/v1/incidents/:id/corroborate
POST   /api/v1/incidents/:id/report-abuse
```

### Users
```
GET    /api/v1/users/me
PUT    /api/v1/users/me
DELETE /api/v1/users/me
GET    /api/v1/users/me/trust-score
GET    /api/v1/users/me/incidents
POST   /api/v1/users/me/request-data-deletion
```

### Circles
```
POST   /api/v1/circles
GET    /api/v1/circles
GET    /api/v1/circles/:id
PUT    /api/v1/circles/:id
DELETE /api/v1/circles/:id
POST   /api/v1/circles/:id/members
DELETE /api/v1/circles/:id/members/:userId
GET    /api/v1/circles/:id/incidents
POST   /api/v1/circles/:id/invite
```

### Trusted Contacts
```
POST   /api/v1/trusted-contacts
GET    /api/v1/trusted-contacts
GET    /api/v1/trusted-contacts/:id
PUT    /api/v1/trusted-contacts/:id
DELETE /api/v1/trusted-contacts/:id
POST   /api/v1/trusted-contacts/:id/escalate
```

### Routes
```
POST   /api/v1/routes/safe
GET    /api/v1/routes/:id
```

### Moderation (Admin)
```
GET    /api/v1/admin/moderation/queue
GET    /api/v1/admin/moderation/queue/:id
PUT    /api/v1/admin/moderation/queue/:id/approve
PUT    /api/v1/admin/moderation/queue/:id/reject
PUT    /api/v1/admin/moderation/queue/:id/request-info
GET    /api/v1/admin/incidents
GET    /api/v1/admin/users
PUT    /api/v1/admin/users/:id/trust-score
GET    /api/v1/admin/analytics
GET    /api/v1/admin/anomaly-flags
PUT    /api/v1/admin/anomaly-flags/:id/resolve
```

### Health
```
GET    /api/v1/health
GET    /api/v1/health/detailed
```

## 14.2 WebSocket Events

### Client → Server
```javascript
// Subscribe to circle updates
{
  "event": "subscribe",
  "channel": "circle:{circleId}",
  "token": "jwt_token"
}

// Subscribe to nearby incidents
{
  "event": "subscribe",
  "channel": "nearby:{lat}:{lng}",
  "token": "jwt_token"
}

// Share live location (temporary session)
{
  "event": "share_location",
  "data": {
    "circleId": "uuid",
    "duration": 300,  // seconds
    "location": { "lat": -1.2921, "lng": 36.8219 }
  }
}
```

### Server → Client
```javascript
// New incident in circle
{
  "event": "incident_created",
  "data": {
    "incidentId": "uuid",
    "type": "robbery",
    "severity": "high",
    "location": { "lat": -1.2921, "lng": 36.8219 },
    "fuzzed": true
  }
}

// Incident status update
{
  "event": "incident_updated",
  "data": {
    "incidentId": "uuid",
    "status": "approved",
    "confidenceScore": 75.5
  }
}

// Circle alert
{
  "event": "circle_alert",
  "data": {
    "alertType": "high_risk_zone",
    "message": "Elevated risk detected in your area",
    "severity": "high"
  }
}

// Trust score update
{
  "event": "trust_updated",
  "data": {
    "newScore": 52.3,
    "change": 2.3,
    "reason": "report_corroborated"
  }
}
```

## 14.3 Rate Limiting

### Rate Limits (per user)
- **Incident Reporting:** 5/hour, 20/day
- **Incident Viewing:** 100/minute
- **Heatmap Requests:** 30/minute
- **Circle Operations:** 20/minute
- **Auth Attempts:** 5/minute, 10/hour

### Rate Limit Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1620000000
```

## 14.4 Response Format

### Success Response
```json
{
  "success": true,
  "data": {
    "incident": {
      "id": "uuid",
      "type": "robbery",
      "status": "pending"
    }
  },
  "meta": {
    "timestamp": "2026-05-27T12:00:00Z",
    "requestId": "uuid"
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "details": {
      "retryAfter": 60
    }
  },
  "meta": {
    "timestamp": "2026-05-27T12:00:00Z",
    "requestId": "uuid"
  }
}
```

---

# 15. Scaling Bottlenecks

## 15.1 Database Bottlenecks

### Write Bottlenecks
- **Incident Ingestion:** High write volume during peak times
- **Mitigation:** Write queue, connection pooling, read replicas
- **Monitoring:** Write latency, connection pool usage

### Read Bottlenecks
- **Heatmap Queries:** Complex spatial queries can be slow
- **Mitigation:** Materialized views, Redis caching, CDN
- **Monitoring:** Query latency, cache hit rates

### Index Bloat
- **Problem:** Frequent updates cause index fragmentation
- **Mitigation:** Regular index maintenance, partial indexes
- **Monitoring:** Index size, query performance

## 15.2 API Bottlenecks

### Authentication Overhead
- **Problem:** JWT validation on every request
- **Mitigation:** Short-lived tokens, token caching, session tokens
- **Monitoring:** Auth latency, token validation time

### Geospatial Calculations
- **Problem:** Complex spatial operations are CPU-intensive
- **Mitigation:** Pre-computation, caching, spatial indexing
- **Monitoring:** Spatial query latency, CPU usage

### Realtime Connections
- **Problem:** WebSocket connection limits
- **Mitigation:** Connection pooling, load balancing, pub/sub scaling
- **Monitoring:** Active connections, message latency

## 15.3 External Service Bottlenecks

### Map Rendering
- **Problem:** Map tile loading can be slow
- **Mitigation:** CDN caching, vector tiles, offline maps
- **Monitoring:** Tile load time, cache hit rate

### Push Notifications
- **Problem:** FCM rate limits, delivery delays
- **Mitigation:** Queue management, batching, fallback SMS
- **Monitoring:** Delivery rate, latency

### Object Storage
- **Problem:** Large file uploads can timeout
- **Mitigation:** Multipart upload, compression, size limits
- **Monitoring:** Upload time, storage usage

## 15.4 Scaling Strategy

### Vertical Scaling (MVP)
- Larger database instances
- More API server resources
- Simple and cost-effective for initial scale

### Horizontal Scaling (Growth)
- Database sharding (by geography)
- API server auto-scaling
- Read replicas for analytics
- Microservice decomposition

### Caching Strategy
- Redis for session data
- CDN for static assets
- Edge caching for heatmaps
- Application-level caching for computed data

---

# 16. Security Priorities

## 16.1 Critical Security Priorities

### 1. Data Protection
- **Encryption at Rest:** All sensitive data encrypted
- **Encryption in Transit:** TLS 1.3 for all connections
- **Key Management:** Secure key rotation, HSM for production
- **Data Minimization:** Collect only necessary data

### 2. Access Control
- **Authentication:** Strong phone verification, secure sessions
- **Authorization:** Role-based access control, least privilege
- **API Security:** Rate limiting, input validation, SQL injection prevention
- **Admin Access:** MFA, audit logging, access reviews

### 3. Abuse Prevention
- **Rate Limiting:** Prevent API abuse
- **Input Validation:** Sanitize all inputs
- **CSRF Protection:** Token-based CSRF protection
- **XSS Prevention:** Output encoding, CSP headers

### 4. Privacy Protection
- **Location Fuzzing:** Never store exact locations
- **Anonymization:** Hash identifiers, aggregate data
- **User Control:** Privacy settings, data deletion
- **Transparency:** Clear privacy policy, data access logs

## 16.2 Security Layers

### Layer 1: Network Security
- DDoS protection (Cloudflare)
- Web Application Firewall (WAF)
- Network segmentation
- VPN for admin access

### Layer 2: Application Security
- Secure coding practices
- Dependency scanning
- Security testing (SAST, DAST)
- Penetration testing

### Layer 3: Data Security
- Encryption (at rest, in transit)
- Secure backups
- Data retention policies
- Data deletion procedures

### Layer 4: Operational Security
- Security monitoring (SIEM)
- Incident response plan
- Security training
- Compliance audits

## 16.3 Security Monitoring

### Real-time Monitoring
- Intrusion detection
- Anomaly detection
- Rate limit alerts
- Authentication failures

### Logging
- Audit logs (all admin actions)
- Access logs (all API requests)
- Error logs (application errors)
- Security events (suspicious activity)

### Alerting
- Critical alerts (immediate)
- Warning alerts (within 1 hour)
- Info alerts (daily digest)

---

# 17. Threat Models

## 17.1 External Threats

### Malicious Users
- **Threat:** False reports, harassment, manipulation
- **Impact:** Reduced trust, panic, legal issues
- **Mitigation:** Trust scoring, moderation, rate limiting, bans

### Bot Networks
- **Threat:** Automated spam, manipulation attacks
- **Impact:** System overload, data pollution
- **Mitigation:** CAPTCHA, device fingerprinting, behavioral analysis

### Hackers
- **Threat:** Data breaches, system compromise
- **Impact:** Data exposure, service disruption
- **Mitigation:** Encryption, security audits, bug bounties

### State Actors
- **Threat:** Surveillance, data collection, political interference
- **Impact:** User privacy violations, platform manipulation
- **Mitigation:** Data minimization, encryption, legal protections

## 17.2 Internal Threats

### Rogue Employees
- **Threat:** Data theft, unauthorized access
- **Impact:** Privacy violations, trust loss
- **Mitigation:** Least privilege, audit logs, background checks

### Insider Accidents
- **Threat:** Misconfiguration, data deletion
- **Impact:** Service disruption, data loss
- **Mitigation:** Training, testing, backups

### Compromised Accounts
- **Threat:** Account takeover, unauthorized actions
- **Impact:** Trust score manipulation, false reports
- **Mitigation:** MFA, anomaly detection, session management

## 17.3 Systemic Threats

### DDoS Attacks
- **Threat:** Service disruption
- **Impact:** Unavailability during critical times
- **Mitigation:** DDoS protection, CDN, rate limiting

### Supply Chain Attacks
- **Threat:** Compromised dependencies
- **Impact:** System compromise, data breach
- **Mitigation:** Dependency scanning, SBOM, vendor vetting

### Misinformation Campaigns
- **Threat:** Coordinated false reports
- **Impact:** Panic, trust erosion
- **Mitigation:** Multi-signal validation, anomaly detection, rapid response

## 17.4 Kenya-Specific Threats

### Political Interference
- **Threat:** Government pressure, censorship
- **Impact:** Platform shutdown, data requests
- **Mitigation:** Legal counsel, data residency, transparency

### Network Infrastructure
- **Threat:** Internet shutdowns, poor connectivity
- **Impact:** Service unavailability
- **Mitigation:** Offline support, sync queues, redundancy

### Social Engineering
- **Threat:** Phishing, account takeover
- **Impact:** Fraud, trust manipulation
- **Mitigation:** User education, security warnings, MFA

---

# 18. Legal and Ethical Risks in Kenya

## 18.1 Legal Framework

### Data Protection Act (2019)
- **Requirements:** Consent for data collection, data minimization, right to deletion
- **Compliance:** Privacy policy, consent mechanisms, data deletion procedures
- **Risks:** Fines, legal action, reputational damage

### Computer Misuse and Cybercrimes Act (2018)
- **Requirements:** Cybersecurity measures, incident reporting
- **Compliance:** Security monitoring, breach response
- **Risks:** Criminal liability for negligence

### Communications Authority of Kenya (CAK) Regulations
- **Requirements:** Service provider licensing, content moderation
- **Compliance:** Content policies, moderation procedures
- **Risks:** Fines, service suspension

### Kenya Information and Communications Act (KICA)
- **Requirements:** Consumer protection, data privacy
- **Compliance:** User rights, transparency
- **Risks:** Regulatory action

## 18.2 Ethical Risks

### Privacy Violations
- **Risk:** Unintended exposure of sensitive information
- **Mitigation:** Privacy by design, regular audits, user control
- **Monitoring:** Privacy impact assessments

### Discrimination
- **Risk:** Biased risk scoring, unfair treatment
- **Mitigation:** Algorithmic transparency, bias testing, diverse training
- **Monitoring:** Fairness metrics, user feedback

### Stigmatization
- **Risk:** Labeling areas as "dangerous" affecting communities
- **Mitigation:** Contextual information, community engagement, nuance
- **Monitoring:** Community feedback, impact assessments

### Panic Amplification
- **Risk:** Exaggerating risks causing unnecessary fear
- **Mitigation:** Confidence scoring, contextual information, responsible communication
- **Monitoring:** User feedback, media monitoring

### Trust Erosion
- **Risk:** Loss of community trust due to errors or abuse
- **Mitigation:** Transparency, accountability, rapid response to issues
- **Monitoring:** Trust metrics, user surveys

## 18.3 Human Rights Considerations

### Right to Privacy
- **Requirement:** Protect user privacy, minimize data collection
- **Implementation:** Anonymization, encryption, user control

### Right to Freedom of Expression
- **Requirement:** Allow legitimate reporting, prevent censorship
- **Implementation:** Clear moderation policies, appeal process

### Right to Safety
- **Requirement:** Provide accurate safety information
- **Implementation:** Multi-signal validation, confidence scoring

### Right to Non-Discrimination
- **Requirement:** Fair treatment of all users
- **Implementation:** Bias testing, inclusive design

## 18.4 Compliance Strategy

### Legal Counsel
- Engage Kenyan legal experts
- Regular compliance reviews
- Stay updated on regulatory changes

### Data Protection Officer
- Appoint DPO (or equivalent)
- Implement data protection policies
- Handle data subject requests

### Regulatory Engagement
- Engage with CAK and other regulators
- Participate in industry consultations
- Build relationships with authorities

### Documentation
- Maintain comprehensive records
- Document compliance measures
- Prepare for audits

---

# 19. Resilience-Focused Design Approach

## 19.1 Resilience Principles

### Fail Gracefully
- **Principle:** System should degrade, not fail completely
- **Implementation:** Offline support, cached data, fallback modes
- **Example:** Show last known heatmap if live data unavailable

### Assume Failure
- **Principle:** Design for components to fail
- **Implementation:** Redundancy, circuit breakers, retries
- **Example:** Multiple database replicas, automatic failover

### Embrace Simplicity
- **Principle:** Complex systems break in complex ways
- **Implementation:** Simple architecture, clear dependencies
- **Example:** Monolithic MVP before microservices

### Iterate Quickly
- **Principle:** Fast feedback beats perfect planning
- **Implementation:** MVP approach, continuous deployment
- **Example:** Launch with manual moderation before AI

## 19.2 Operational Resilience

### High Availability
- **Goal:** 99.5% uptime (MVP), 99.9% (production)
- **Implementation:** Load balancing, auto-scaling, multi-AZ deployment
- **Monitoring:** Uptime monitoring, alerting

### Disaster Recovery
- **Goal:** RPO < 1 hour, RTO < 4 hours
- **Implementation:** Automated backups, disaster recovery plan
- **Testing:** Regular disaster recovery drills

### Incident Response
- **Goal:** Detect and respond to incidents within 15 minutes
- **Implementation:** 24/7 monitoring, on-call rotation, playbooks
- **Testing:** Regular incident response simulations

## 19.3 Data Resilience

### Backup Strategy
- **Database:** Daily full backups, hourly incremental
- **Object Storage:** Versioning enabled, cross-region replication
- **Configuration:** Git version control, infrastructure as code

### Data Integrity
- **Validation:** Input validation, data integrity checks
- **Verification:** Regular data audits, checksums
- **Recovery:** Point-in-time recovery, data repair tools

### Data Sovereignty
- **Residency:** Data stored in Africa region
- **Compliance:** Local data protection laws
- **Transparency:** Clear data location disclosure

## 19.4 Organizational Resilience

### Team Resilience
- **Cross-training:** Multiple people for critical roles
- **Documentation:** Comprehensive runbooks, architecture docs
- **Knowledge Sharing:** Regular team syncs, post-mortems

### Process Resilience
- **Automation:** Automated testing, deployment, monitoring
- **Standardization:** Coding standards, review processes
- **Continuous Improvement:** Regular retrospectives, process optimization

### Financial Resilience
- **Cost Management:** Monitoring, optimization, reserved capacity
- **Funding:** Diverse funding sources, runway planning
- **Sustainability:** Revenue planning, cost control

## 19.5 Community Resilience

### Trust Building
- **Transparency:** Open communication about decisions
- **Accountability:** Admit mistakes, fix issues publicly
- **Engagement:** Regular community feedback, user advisory board

### Abuse Resistance
- **Detection:** Multiple detection layers
- **Response:** Rapid response to abuse
- **Recovery:** System recovery after abuse incidents

### Adaptability
- **Feedback:** Continuous user feedback collection
- **Iteration:** Regular feature updates based on feedback
- **Evolution:** System evolves with community needs

---

# Conclusion

This architecture prioritizes:
- **Privacy:** Minimal data collection, strong encryption, user control
- **Resilience:** Graceful degradation, redundancy, simple design
- **Trust:** Behavioral trust scoring, multi-signal validation, transparency
- **Abuse Resistance:** Multiple defense layers, anomaly detection, rapid response
- **Simplicity:** MVP approach, proven technologies, clear responsibilities

The system is designed to:
- Start small and iterate quickly
- Scale gracefully as adoption grows
- Resist abuse and manipulation
- Protect user privacy above all
- Adapt to Kenya's unique context
- Build community trust over time

**Next Steps:**
1. Technical feasibility assessment
2. Legal consultation in Kenya
3. Community engagement and feedback
4. MVP development (Phase 1 features)
5. Pilot launch in single Nairobi neighborhood
6. Iterate based on learnings
7. Gradual expansion following phased strategy

**Success Metrics:**
- Increased civilian situational awareness
- Reduced victim isolation
- Trusted community coordination
- Improved safe route decisions
- Zero major privacy violations
- Positive community trust
