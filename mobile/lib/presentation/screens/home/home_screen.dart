import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/cusin_button.dart';
import '../../widgets/common/cusin_card.dart';

/// Home screen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeTab(),
    const MapTab(),
    const CirclesTab(),
    const ProfileTab(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Circles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/incidents/report'),
              icon: const Icon(Icons.add),
              label: const Text('Report'),
            )
          : null,
    );
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('CUSIN'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.emergency),
                onPressed: () => context.push('/emergency'),
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.report,
                          label: 'Report',
                          onTap: () => context.push('/incidents/report'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.map,
                          label: 'View Map',
                          onTap: () => context.push('/map'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.directions,
                          label: 'Safe Routes',
                          onTap: () => context.push('/safe-routes'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.group,
                          label: 'Circles',
                          onTap: () => context.push('/circles'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.contacts,
                          label: 'Contacts',
                          onTap: () => context.push('/contacts'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent incidents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nearby Incidents',
                        style: theme.textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => context.push('/map'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Incident list placeholder
                  CUSINCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading nearby incidents...',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CUSINCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Map Tab'),
    );
  }
}

class CirclesTab extends StatelessWidget {
  const CirclesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Circles Tab'),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Tab'),
    );
  }
}
