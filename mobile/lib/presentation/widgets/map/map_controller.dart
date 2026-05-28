import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/location_service.dart';
import 'heatmap_layer.dart';
import 'marker_layer.dart';

/// Map controller provider
final mapControllerProvider = Provider<MapController>((ref) {
  return MapController(ref.read(locationServiceProvider.notifier));
});

/// Main map controller
class MapController {
  final LocationServiceNotifier locationService;
  GoogleMapController? _controller;
  HeatmapLayer? _heatmapLayer;
  MarkerLayer? _markerLayer;

  MapController(this.locationService);

  /// Initialize map controller
  void initialize(GoogleMapController controller) {
    _controller = controller;
    _heatmapLayer = HeatmapLayer(controller);
    _markerLayer = MarkerLayer(controller);
  }

  /// Get current controller
  GoogleMapController? get controller => _controller;

  /// Get heatmap layer
  HeatmapLayer? get heatmapLayer => _heatmapLayer;

  /// Get marker layer
  MarkerLayer? get markerLayer => _markerLayer;

  /// Center map on user location
  Future<void> centerOnUserLocation({double zoom = AppConstants.defaultMapZoom}) async {
    final position = locationService.state.currentPosition;
    if (position != null && _controller != null) {
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          zoom,
        ),
      );
    }
  }

  /// Center map on specific location
  Future<void> centerOnLocation({
    required double latitude,
    required double longitude,
    double zoom = AppConstants.defaultMapZoom,
  }) async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(latitude, longitude),
        zoom,
      ),
    );
  }

  /// Fit map to bounds
  Future<void> fitToBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    double padding = 50.0,
  }) async {
    final bounds = LatLngBounds(
      LatLng(south, west),
      LatLng(north, east),
    );
    await _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding: padding),
    );
  }

  /// Add incident markers
  Future<void> addIncidentMarkers(List<dynamic> markers) async {
    for (final marker in markers) {
      await _markerLayer?.addIncidentMarker(
        markerId: marker['id']?.toString() ?? '',
        latitude: marker['latitude'] ?? 0.0,
        longitude: marker['longitude'] ?? 0.0,
        incidentType: marker['incidentType'] ?? '',
        severity: marker['severity'] ?? '',
        confidence: marker['confidence'] ?? 0.0,
      );
    }
  }

  /// Add heatmap layer
  Future<void> addHeatmap({
    required List<dynamic> points,
    String layerId = 'heatmap',
    String sourceId = 'heatmap_source',
    bool timeWeighted = true,
  }) async {
    await _heatmapLayer?.addHeatmapLayer(
      points: points,
      layerId: layerId,
      sourceId: sourceId,
    );
  }

  /// Clear all layers
  Future<void> clearLayers() async {
    await _heatmapLayer?.removeHeatmapLayer(
      layerId: 'heatmap',
      sourceId: 'heatmap_source',
    );
    await _markerLayer?.removeAllMarkers();
  }

  /// Toggle heatmap visibility
  Future<void> toggleHeatmap({
    String layerId = 'heatmap',
    required bool visible,
  }) async {
    await _heatmapLayer?.toggleHeatmapVisibility(
      layerId: layerId,
      visible: visible,
    );
  }

  /// Set map style
  Future<void> setMapStyle(String styleUrl) async {
    await _controller?.setMapStyle(styleUrl);
  }

  /// Enable/disable user location
  Future<void> setUserLocationEnabled(bool enabled) async {
    // Google Maps handles this via myLocationEnabled property
  }

  /// Set user location tracking mode
  Future<void> setUserLocationTrackingMode(MyLocationTrackingMode mode) async {
    // Google Maps handles this via myLocationEnabled property
  }

  /// Get current camera position
  Future<CameraPosition?> getCameraPosition() async {
    return await _controller?.getCameraPosition();
  }

  /// Add map click listener
  void addMapClickListener({
    required Function(LatLng point) onTap,
  }) {
    // Google Maps click handling
  }

  /// Add marker click listener
  void addMarkerClickListener({
    required Function(String markerId) onTap,
  }) {
    // Google Maps marker click handling
  }

  /// Dispose controller
  void dispose() {
    _controller = null;
    _heatmapLayer = null;
    _markerLayer = null;
  }
}
