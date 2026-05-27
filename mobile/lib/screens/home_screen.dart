import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/incident_report_screen.dart';
import 'screens/heatmap_screen.dart';
import 'screens/auth_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authBox = Hive.box('authBox');
    final isLoggedIn = authBox.get('token') != null;

    if (!isLoggedIn) {
      return const AuthScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CUSIN'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authBox.clear();
              // Force rebuild
              ref.invalidate(authBox);
            },
          ),
        ],
      ),
      body: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Civilian Urban Safety',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncidentReportScreen(),
                ),
              );
            },
            icon: const Icon(Icons.report),
            label: const Text('Report Incident'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HeatmapScreen(),
                ),
              );
            },
            icon: const Icon(Icons.map),
            label: const Text('View Heatmap'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
