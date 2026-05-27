import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl/src/mapbox_gl.dart' as mapbox;
import '../../../core/constants/app_constants.dart';
import '../../../services/location_service.dart';
import 'heatmap_layer.dart';
import 'marker_layer.dart';

/// Map controller provider
final mapControllerProvider = Provider<MapController>((ref) {
  return MapController(ref.read(locationServiceProvider));
});

/// Main map controller
class MapController {
  final LocationServiceNotifier locationService;
  mapbox.MapboxMapController? _controller;
  HeatmapLayer? _heatmapLayer;
  MarkerLayer? _markerLayer;
  
  MapController(this.locationService);
  
  /// Initialize map controller
  void initialize(mapbox.MapboxMapController controller) {
    _controller = controller;
    _heatmapLayer = HeatmapLayer(controller);
    _markerLayer = MarkerLayer(controller);
    
    // Add marker images
    _markerLayer?.addMarkerImages();
  }
  
  /// Get current controller
  mapbox.MapboxMapController? get controller => _controller;
  
  /// Get heatmap layer
  HeatmapLayer? get heatmapLayer => _heatmapLayer;
  
  /// Get marker layer
  MarkerLayer? get markerLayer => _markerLayer;
  
  /// Center map on user location
  Future<void> centerOnUserLocation({double zoom = AppConstants.defaultMapZoom}) async {
    final locationState = locationService.state;
    if (locationState.currentPosition != null) {
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            locationState.currentPosition!.latitude,
            locationState.currentPosition!.longitude,
          ),
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
  Future<void> addIncidentMarkers(List<IncidentMarker> markers) async {
    for (final marker in markers) {
      await _markerLayer?.addIncidentMarker(
        markerId: marker.id,
        latitude: marker.latitude,
        longitude: marker.longitude,
        incidentType: marker.incidentType,
        severity: marker.severity,
        confidence: marker.confidence,
      );
    }
  }
  
  /// Add heatmap layer
  Future<void> addHeatmap({
    required List<HeatmapPoint> points,
    String layerId = 'heatmap',
    String sourceId = 'heatmap_source',
    bool timeWeighted = true,
  }) async {
    if (timeWeighted) {
      await _heatmapLayer?.addTimeWeightedHeatmap(
        points: points,
        layerId: layerId,
        sourceId: sourceId,
      );
    } else {
      await _heatmapLayer?.addHeatmapLayer(
        points: points,
        layerId: layerId,
        sourceId: sourceId,
      );
    }
  }
  
  /// Clear all layers
  Future<void> clearLayers() async {
    await _markerLayer?.removeAllMarkers();
    // Heatmap layers need to be removed individually
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
    await _controller?.setStyleString(styleUrl);
  }
  
  /// Enable/disable user location
  Future<void> setUserLocationEnabled(bool enabled) async {
    await _controller?.myLocationEnabled = enabled;
  }
  
  /// Set user location tracking mode
  Future<void> setUserLocationTrackingMode(MyLocationTrackingMode mode) async {
    await _controller?.myLocationTrackingMode = mode;
  }
  
  /// Get current camera position
  Future<CameraPosition?> getCameraPosition() async {
    return await _controller?.getCameraPosition();
  }
  
  /// Add map click listener
  void addMapClickListener({
    required Function(LatLng point) onTap,
  }) {
    _controller?.onMapClick.add((point) {
      onTap(point);
    });
  }
  
  /// Add marker click listener
  void addMarkerClickListener({
    required Function(String markerId) onTap,
  }) {
    _markerLayer?.addMarkerClickListener(onMarkerTap: onTap);
  }
  
  /// Dispose controller
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _heatmapLayer = null;
    _markerLayer = null;
  }
}
