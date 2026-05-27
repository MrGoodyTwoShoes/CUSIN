import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final _apiService = APIService();
  
  MapboxMapController? mapController;
  bool _isLoading = true;
  List<dynamic> _heatmapData = [];
  List<dynamic> _incidents = [];

  // Nairobi center
  static const double _initialLat = -1.2921;
  static const double _initialLng = 36.8219;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get heatmap data
      final heatmap = await _apiService.getHeatmap();
      
      // Get nearby incidents
      final position = await LocationService.getCurrentLocation();
      final incidents = await _apiService.getNearbyIncidents(
        lat: position.latitude,
        lng: position.longitude,
      );

      setState(() {
        _heatmapData = heatmap;
        _incidents = incidents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Heatmap'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapboxMap(
                  accessToken: 'YOUR_MAPBOX_ACCESS_TOKEN', // Replace with actual token
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(_initialLat, _initialLng),
                    zoom: 12.0,
                  ),
                  onMapCreated: _onMapCreated,
                  styleString: MapboxStyles.MAPBOX_STREETS,
                  myLocationEnabled: true,
                  myLocationTrackingMode: MyLocationTrackingMode.None,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nearby Incidents',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_incidents.length} incidents',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
