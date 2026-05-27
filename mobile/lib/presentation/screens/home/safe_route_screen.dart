import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/accessibility.dart';
import '../../../services/location_service.dart';
import '../../widgets/common/cusin_button.dart';
import '../../widgets/common/cusin_card.dart';
import '../../widgets/map/safe_route_service.dart';

/// Safe route screen
class SafeRouteScreen extends ConsumerStatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  ConsumerState<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends ConsumerState<SafeRouteScreen> {
  final _destinationController = TextEditingController();
  bool _isLoading = false;
  SafeRoute? _selectedRoute;
  List<SafeRoute> _routeOptions = [];
  
  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }
  
  Future<void> _calculateRoutes() async {
    final locationState = ref.read(locationServiceProvider);
    if (locationState.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final safeRouteService = SafeRouteService(
        mapboxAccessToken: AppConstants.mapboxAccessToken,
      );
      
      // TODO: Geocode destination address to coordinates
      // For now, use placeholder coordinates
      final destinationLat = -1.2921; // Nairobi center
      final destinationLng = 36.8219;
      
      final routes = await safeRouteService.getRouteOptions(
        startLat: locationState.currentPosition!.latitude,
        startLng: locationState.currentPosition!.longitude,
        endLat: destinationLat,
        endLng: destinationLng,
        alternatives: 3,
      );
      
      setState(() {
        _routeOptions = routes;
        _selectedRoute = routes.isNotEmpty ? routes.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  void _selectRoute(SafeRoute route) {
    setState(() => _selectedRoute = route);
  }
  
  void _startNavigation() {
    if (_selectedRoute == null) return;
    
    // TODO: Start navigation with selected route
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation starting...')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessibilitySettings = ref.watch(accessibilitySettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Routes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Destination input
            CUSINCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Where are you going?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter destination',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    textScaleFactor: accessibilitySettings.textScaleFactor,
                  ),
                  const SizedBox(height: 12),
                  CUSINButton(
                    text: 'Find Safe Routes',
                    onPressed: _calculateRoutes,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Route options
            if (_routeOptions.isNotEmpty) ...[
              Text(
                'Route Options',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ..._routeOptions.map((route) => _RouteOptionCard(
                route: route,
                isSelected: _selectedRoute == route,
                onTap: () => _selectRoute(route),
                textScaleFactor: accessibilitySettings.textScaleFactor,
              )),
              
              const SizedBox(height: 16),
              
              // Start navigation button
              CUSINButton(
                text: 'Start Navigation',
                onPressed: _startNavigation,
              ),
            ],
            
            // Info card
            CUSINCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Safe routes are calculated based on incident data and safety scores.',
                          style: theme.textTheme.bodySmall,
                          textScaleFactor: accessibilitySettings.textScaleFactor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteOptionCard extends StatelessWidget {
  final SafeRoute route;
  final bool isSelected;
  final VoidCallback onTap;
  final double textScaleFactor;
  
  const _RouteOptionCard({
    required this.route,
    required this.isSelected,
    required this.onTap,
    required this.textScaleFactor,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AccessibleCard(
      onTap: onTap,
      semanticLabel: 'Route option, ${route.safetyLevel}, ${route.distance.toStringAsFixed(0)} meters, ${route.duration.inMinutes} minutes',
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Safety indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: route.safetyColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            
            // Route info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.safetyLevel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: route.safetyColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textScaleFactor: textScaleFactor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${route.distance.toStringAsFixed(0)}m • ${route.duration.inMinutes} min',
                    style: theme.textTheme.bodyMedium,
                    textScaleFactor: textScaleFactor,
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
