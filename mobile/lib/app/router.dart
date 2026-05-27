import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/phone_verification_screen.dart';
import '../presentation/screens/auth/otp_verification_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/safety_map_screen.dart';
import '../presentation/screens/home/safe_route_screen.dart';
import '../presentation/screens/incidents/incident_report_screen.dart';
import '../presentation/screens/incidents/incident_detail_screen.dart';
import '../presentation/screens/circles/circles_screen.dart';
import '../presentation/screens/circles/circle_detail_screen.dart';
import '../presentation/screens/contacts/contacts_screen.dart';
import '../presentation/screens/contacts/add_contact_screen.dart';
import '../presentation/screens/notifications/notification_center_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/screens/emergency/emergency_modal.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: true,
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth
      GoRoute(
        path: '/auth/phone',
        name: 'phone_verification',
        builder: (context, state) => const PhoneVerificationScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        name: 'otp_verification',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OTPVerificationScreen(phone: phone);
        },
      ),
      
      // Home
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/map',
        name: 'safety_map',
        builder: (context, state) => const SafetyMapScreen(),
      ),
      GoRoute(
        path: '/safe-routes',
        name: 'safe_routes',
        builder: (context, state) => const SafeRouteScreen(),
      ),
      
      // Incidents
      GoRoute(
        path: '/incidents/report',
        name: 'report_incident',
        builder: (context, state) => const IncidentReportScreen(),
      ),
      GoRoute(
        path: '/incidents/:id',
        name: 'incident_detail',
        builder: (context, state) {
          final incidentId = state.pathParameters['id']!;
          return IncidentDetailScreen(incidentId: incidentId);
        },
      ),
      
      // Circles
      GoRoute(
        path: '/circles',
        name: 'circles',
        builder: (context, state) => const CirclesScreen(),
      ),
      GoRoute(
        path: '/circles/:id',
        name: 'circle_detail',
        builder: (context, state) {
          final circleId = state.pathParameters['id']!;
          return CircleDetailScreen(circleId: circleId);
        },
      ),
      
      // Contacts
      GoRoute(
        path: '/contacts',
        name: 'contacts',
        builder: (context, state) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/contacts/add',
        name: 'add_contact',
        builder: (context, state) => const AddContactScreen(),
      ),
      
      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      
      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Emergency (modal)
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: const EmergencyModal(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
