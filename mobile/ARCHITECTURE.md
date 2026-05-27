# CUSIN Mobile App Architecture

## Overview
Production-grade Flutter architecture for the CUSIN civilian urban safety platform, optimized for low-midrange Android devices with offline tolerance and battery efficiency.

## Architectural Principles

### 1. Clean Architecture
- **Separation of Concerns**: UI, business logic, and data layers are strictly separated
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Testability**: Each layer can be tested independently

### 2. Feature-Based Structure
- Each feature (auth, incidents, circles, etc.) is self-contained
- Reduces cognitive load when navigating codebase
- Enables feature toggling and modular development

### 3. Offline-First Design
- Local data source of truth
- Background sync when connectivity restored
- Optimistic UI updates for instant feedback

### 4. Performance Optimization
- Lazy loading of widgets
- Image caching and optimization
- Efficient state management with Riverpod
- Minimal rebuilds with const constructors

## Technology Choices

### State Management: Riverpod
**Why Riverpod over Bloc?**
- Simpler syntax with less boilerplate
- Better performance with selective rebuilds
- Compile-time safety
- Easier testing with provider overrides
- No BuildContext dependency for reading providers
- Better for offline scenarios with async state management

### Maps: Mapbox GL
**Why Mapbox over OpenStreetMap?**
- Superior performance on low-end devices
- Better vector tile rendering
- Offline map downloading
- Custom styling support
- Better gesture handling
- More consistent experience across devices

### Local Storage: Hive
**Why Hive over SQLite/SharedPreferences?**
- No SQL overhead, faster reads/writes
- Type-safe with code generation
- Better performance for large datasets
- Supports complex objects
- Lower battery consumption
- Encrypted box support for sensitive data

### Networking: Dio + Retrofit
**Why Dio over http package?**
- Interceptors for auth, logging, error handling
- Request/response transformation
- Timeout and retry logic
- File upload/download support
- Better error handling

### Caching: Dio Cache Manager
- HTTP response caching
- Cache invalidation strategies
- Offline data availability
- Reduces network usage

## Folder Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── app.dart                       # Root widget with providers
│   ├── router.dart                    # Navigation configuration
│   └── theme/
│       ├── app_theme.dart             # Theme configuration
│       ├── dark_theme.dart            # Dark mode colors
│       └── light_theme.dart           # Light mode colors
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── api_constants.dart         # API endpoints
│   │   └── storage_constants.dart     # Storage keys
│   ├── utils/
│   │   ├── validators.dart            # Input validators
│   │   ├── formatters.dart            # Data formatters
│   │   └── extensions.dart            # Dart extensions
│   ├── network/
│   │   ├── dio_client.dart            # Dio configuration
│   │   ├── api_interceptor.dart       # Auth/error interceptors
│   │   └── network_info.dart          # Connectivity checker
│   └── error/
│       ├── exceptions.dart            # Custom exceptions
│       └── failures.dart              # Failure types
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── local_datasource.dart  # Local storage interface
│   │   │   ├── auth_local_ds.dart     # Auth local operations
│   │   │   └── incidents_local_ds.dart # Incidents local operations
│   │   └── remote/
│   │       ├── remote_datasource.dart # Remote API interface
│   │       ├── auth_remote_ds.dart    # Auth API calls
│   │       └── incidents_remote_ds.dart # Incidents API calls
│   ├── models/
│   │   ├── user.dart                  # User model
│   │   ├── incident.dart              # Incident model
│   │   ├── circle.dart                # Circle model
│   │   └── contact.dart               # Contact model
│   └── repositories/
│       ├── repository.dart            # Base repository interface
│       ├── auth_repository.dart       # Auth data operations
│       ├── incident_repository.dart   # Incident data operations
│       └── circle_repository.dart     # Circle data operations
├── domain/
│   ├── entities/
│   │   ├── user.dart                  # User entity (pure business logic)
│   │   ├── incident.dart              # Incident entity
│   │   └── circle.dart                # Circle entity
│   ├── usecases/
│   │   ├── usecase.dart               # Base usecase interface
│   │   ├── auth/
│   │   │   ├── login_usecase.dart     # Login logic
│   │   │   └── verify_phone_usecase.dart # Phone verification
│   │   ├── incidents/
│   │   │   ├── get_incidents_usecase.dart
│   │   │   └── create_incident_usecase.dart
│   │   └── circles/
│   │       └── get_circles_usecase.dart
│   └── repositories/
│       ├── auth_repository.dart       # Auth repository interface
│       ├── incident_repository.dart   # Incident repository interface
│       └── circle_repository.dart     # Circle repository interface
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart         # Auth state management
│   │   ├── incident_provider.dart     # Incident state management
│   │   └── circle_provider.dart       # Circle state management
│   ├── screens/
│   │   ├── onboarding/
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets/
│   │   ├── auth/
│   │   │   ├── phone_verification_screen.dart
│   │   │   ├── otp_verification_screen.dart
│   │   │   └── widgets/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── safety_map_screen.dart
│   │   │   └── widgets/
│   │   ├── incidents/
│   │   │   ├── incident_report_screen.dart
│   │   │   ├── incident_detail_screen.dart
│   │   │   └── widgets/
│   │   ├── circles/
│   │   │   ├── circles_screen.dart
│   │   │   ├── circle_detail_screen.dart
│   │   │   └── widgets/
│   │   ├── contacts/
│   │   │   ├── contacts_screen.dart
│   │   │   ├── add_contact_screen.dart
│   │   │   └── widgets/
│   │   ├── notifications/
│   │   │   ├── notification_center_screen.dart
│   │   │   └── widgets/
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── widgets/
│   │   └── emergency/
│   │       └── emergency_modal.dart
│   └── widgets/
│       ├── common/
│       │   ├── cusin_button.dart      # Reusable button
│       │   ├── cusin_text_field.dart  # Reusable text field
│       │   ├── cusin_card.dart        # Reusable card
│       │   ├── loading_indicator.dart # Custom loading
│       │   └── error_widget.dart      # Error display
│       └── map/
│           ├── map_controller.dart    # Mapbox controller
│           ├── heatmap_layer.dart     # Heatmap overlay
│           └── marker_layer.dart      # Custom markers
└── services/
    ├── websocket_service.dart         # WebSocket connection
    ├── location_service.dart          # Location handling
    ├── notification_service.dart      # Push notifications
    └── sync_service.dart              # Background sync
```

## Data Flow

### 1. User Action → UI → Provider → UseCase → Repository → DataSource
```
User taps "Report Incident"
  ↓
IncidentReportScreen (UI)
  ↓
IncidentProvider (State Management)
  ↓
CreateIncidentUseCase (Business Logic)
  ↓
IncidentRepository (Data Coordination)
  ↓
IncidentRemoteDataSource (API Call)
  ↓
API Response
  ↓
Repository (Cache + Transform)
  ↓
UseCase (Validate)
  ↓
Provider (Update State)
  ↓
UI Rebuild (Optimistic Update)
```

### 2. Offline Flow
```
User creates incident (no network)
  ↓
IncidentProvider detects offline
  ↓
Save to IncidentLocalDataSource (Hive)
  ↓
Update UI with optimistic state
  ↓
Background sync when online
  ↓
SyncService processes queue
  ↓
API calls for pending items
  ↓
Update local cache on success
```

## State Management Strategy

### Provider Types
- **StateNotifierProvider**: For complex state with multiple states (loading, success, error)
- **FutureProvider**: For one-time async operations
- **StreamProvider**: For real-time data (WebSocket, location)
- **Provider**: For immutable dependencies (services, repositories)

### State Classes
```dart
class IncidentState {
  final bool isLoading;
  final List<Incident> incidents;
  final String? error;
  final bool isOffline;
  
  // CopyWith for immutable updates
  IncidentState copyWith({...});
}
```

## Offline Strategy

### 1. Connectivity Detection
- Use `connectivity_plus` for network status
- Debounce network changes to avoid false positives
- Background sync queue for pending operations

### 2. Local Storage
- Hive for structured data (users, incidents, circles)
- SharedPreferences for simple flags (onboarding completed)
- SQLite for complex queries (if needed later)

### 3. Cache Invalidation
- Time-based expiration (24 hours for incidents)
- Manual refresh on pull-to-refresh
- Version-based cache busting

### 4. Conflict Resolution
- Last-write-wins for simple data
- Server timestamp for conflicts
- Manual resolution for critical data

## Performance Optimizations

### 1. Widget Performance
- Use `const` constructors wherever possible
- Extract widgets to prevent unnecessary rebuilds
- Use `AutomaticKeepAliveClientMixin` for tab persistence
- Lazy loading with `ListView.builder`

### 2. Image Optimization
- Cached network images with `cached_network_image`
- WebP format for smaller file sizes
- Thumbnail generation for lists
- Progressive loading

### 3. Memory Management
- Dispose controllers properly
- Clear caches on logout
- Use `ValueKey` for list items
- Avoid memory leaks with Stream subscriptions

### 4. Battery Efficiency
- Batch location updates
- Reduce polling frequency
- Use work manager for background tasks
- Minimize wake locks

## Security Considerations

### 1. Data Encryption
- Encrypted Hive box for sensitive data
- SSL pinning for API calls
- Secure storage for tokens
- Hash phone numbers before storage

### 2. Privacy
- Location fuzzing (50-100m) before API calls
- No biometric data storage
- Anonymous mode option
- Data minimization

### 3. Authentication
- JWT token storage in secure storage
- Token refresh logic
- Session timeout handling
- Biometric auth option (optional)

## Accessibility

### 1. Semantic Labels
- All interactive elements have semantic labels
- Proper content descriptions for images
- Screen reader support

### 2. Visual Accessibility
- Minimum touch target size (48x48)
- Sufficient color contrast (4.5:1)
- Scalable text support
- High contrast mode

### 3. Navigation
- Keyboard navigation support
- Focus management
- Clear focus indicators

## Testing Strategy

### 1. Unit Tests
- Use cases and business logic
- Repository implementations
- Utility functions
- Validators and formatters

### 2. Widget Tests
- Individual widgets
- Provider state changes
- User interactions
- Navigation flows

### 3. Integration Tests
- Complete user flows
- API integration
- Offline scenarios
- End-to-end journeys

## Deployment Considerations

### 1. App Signing
- Separate debug and release signing
- Keystore management
- Play Store configuration

### 2. Build Configuration
- Different configs for dev/staging/prod
- Environment-specific API endpoints
- Feature flags

### 3. Monitoring
- Crashlytics integration
- Analytics for usage patterns
- Performance monitoring
- Error tracking

## Migration Path

### Phase 1 (Current)
- Core screens implemented
- Basic offline support
- Map integration

### Phase 2
- Advanced offline features
- Background sync improvements
- Enhanced caching

### Phase 3
- ML-based incident classification
- Predictive safety scoring
- Advanced route optimization
