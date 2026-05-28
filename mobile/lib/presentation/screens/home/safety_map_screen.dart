import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/location_service.dart';
import '../../widgets/map/map_controller.dart';
import '../../widgets/map/heatmap_layer.dart';

/// Safety map screen with Mapbox
class SafetyMapScreen extends ConsumerStatefulWidget {
  const SafetyMapScreen({super.key});

  @override
  ConsumerState<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends ConsumerState<SafetyMapScreen> {
  GoogleMapController? mapController;
  MapController? _mapController;
  bool _isLoading = true;
  bool _showHeatmap = true;
  bool _showMarkers = true;

  // Nairobi center
  static const double _initialLat = -1.2921;
  static const double _initialLng = 36.8219;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Request location permission
    await ref.read(locationServiceProvider.notifier).requestPermission();

    setState(() => _isLoading = false);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _mapController = ref.read(mapControllerProvider);
      _mapController?.initialize(controller);
    });

    // Load map data
    _loadMapData();
  }
  
  Future<void> _loadMapData() async {
    // TODO: Fetch incidents from API
    // TODO: Add heatmap layer
    // TODO: Add incident markers
    
    // Example heatmap data (replace with API data)
    final heatmapPoints = [
      HeatmapPoint(
        latitude: _initialLat + 0.01,
        longitude: _initialLng + 0.01,
        intensity: 0.7,
        confidence: 0.8,
      ),
      HeatmapPoint(
        latitude: _initialLat - 0.01,
        longitude: _initialLng - 0.01,
        intensity: 0.5,
        confidence: 0.9,
      ),
    ];
    
    await _mapController?.addHeatmap(points: heatmapPoints);
  }
  
  void _toggleHeatmap() {
    setState(() {
      _showHeatmap = !_showHeatmap;
    });
    _mapController?.toggleHeatmap(visible: _showHeatmap);
  }
  
  void _toggleMarkers() {
    setState(() {
      _showMarkers = !_showMarkers;
    });
    // TODO: Toggle marker visibility
  }
  
  Future<void> _centerOnLocation() async {
    await _mapController?.centerOnUserLocation();
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Heatmap'),
              value: _showHeatmap,
              onChanged: (value) {
                setState(() => _showHeatmap = value);
                _mapController?.toggleHeatmap(visible: _showHeatmap);
              },
            ),
            SwitchListTile(
              title: const Text('Show Markers'),
              value: _showMarkers,
              onChanged: (value) {
                setState(() => _showMarkers = value);
                _toggleMarkers();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showLegend() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safety Legend',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _LegendItem(
              color: Colors.green,
              label: 'Low Risk',
              value: '0-30%',
            ),
            _LegendItem(
              color: Colors.yellow,
              label: 'Medium-Low Risk',
              value: '30-50%',
            ),
            _LegendItem(
              color: Colors.orange,
              label: 'Medium Risk',
              value: '50-70%',
            ),
            _LegendItem(
              color: Colors.orange.shade700,
              label: 'High Risk',
              value: '70-90%',
            ),
            _LegendItem(
              color: Colors.red,
              label: 'Critical Risk',
              value: '90-100%',
            ),
            const SizedBox(height: 16),
            Text(
              'Note: Locations are fuzzed for privacy',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Safety Map'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Map'),
        actions: [
          IconButton(
            icon: Icon(_showHeatmap ? Icons.layers : Icons.layers_outlined),
            onPressed: _toggleHeatmap,
            tooltip: 'Toggle Heatmap',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnLocation,
            tooltip: 'My Location',
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final mapController = ref.watch(mapControllerProvider);
          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(_initialLat, _initialLng),
              zoom: AppConstants.defaultMapZoom,
            ),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            minMaxZoomPreference: const MinMaxZoomPreference(
              AppConstants.minMapZoom,
              AppConstants.maxMapZoom,
            ),
            markers: mapController?.markerLayer?.markers ?? {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLegend,
        icon: const Icon(Icons.legend_toggle),
        label: const Text('Legend'),
      ),
    );
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
