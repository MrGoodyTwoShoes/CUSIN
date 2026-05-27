import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl/src/mapbox_gl.dart' as mapbox;
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

/// Marker layer for incident visualization
class MarkerLayer {
  final mapbox.MapboxMapController controller;
  
  MarkerLayer(this.controller);
  
  /// Add incident marker
  Future<void> addIncidentMarker({
    required String markerId,
    required double latitude,
    required double longitude,
    required String incidentType,
    required String severity,
    required double confidence,
  }) async {
    final icon = _getSeverityIcon(severity);
    
    await controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(latitude, longitude),
        iconImage: icon,
        iconSize: 0.3,
        iconAnchor: 'bottom',
      ),
    );
  }
  
  /// Add cluster marker
  Future<void> addClusterMarker({
    required String markerId,
    required double latitude,
    required double longitude,
    required int count,
    required double avgConfidence,
  }) async {
    final icon = _getClusterIcon(count);
    
    await controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(latitude, longitude),
        iconImage: icon,
        iconSize: 0.4,
        iconAnchor: 'center',
        textField: count.toString(),
        textSize: 12.0,
        textAnchor: 'center',
        textOffset: Offset(0, -10),
        textColor: '#FFFFFF',
        textHaloColor: '#000000',
        textHaloWidth: 1.0,
      ),
    );
  }
  
  /// Add custom marker with image
  Future<void> addCustomMarker({
    required String markerId,
    required double latitude,
    required double longitude,
    required String imagePath,
    double size = 0.3,
  }) async {
    await controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(latitude, longitude),
        iconImage: imagePath,
        iconSize: size,
        iconAnchor: 'bottom',
      ),
    );
  }
  
  /// Remove marker
  Future<void> removeMarker(String markerId) async {
    await controller.removeSymbol(markerId);
  }
  
  /// Remove all markers
  Future<void> removeAllMarkers() async {
    await controller.removeSymbols();
  }
  
  /// Add click listener to markers
  void addMarkerClickListener({
    required Function(String markerId) onMarkerTap,
  }) {
    controller.onSymbolTapped.add((symbol) {
      onMarkerTap(symbol.id);
    });
  }
  
  /// Get severity icon name
  String _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return 'severity-low';
      case 'medium':
        return 'severity-medium';
      case 'high':
        return 'severity-high';
      case 'critical':
        return 'severity-critical';
      default:
        return 'severity-medium';
    }
  }
  
  /// Get cluster icon based on count
  String _getClusterIcon(int count) {
    if (count < 10) return 'cluster-small';
    if (count < 50) return 'cluster-medium';
    if (count < 100) return 'cluster-large';
    return 'cluster-huge';
  }
  
  /// Add custom images for markers
  Future<void> addMarkerImages() async {
    // Add severity icons
    await _addSeverityIcons();
    
    // Add cluster icons
    await _addClusterIcons();
  }
  
  Future<void> _addSeverityIcons() async {
    // TODO: Add actual image assets for severity icons
    // These should be SVG or PNG images
    // await controller.addImage('severity-low', await _loadImage('assets/icons/severity_low.png'));
    // await controller.addImage('severity-medium', await _loadImage('assets/icons/severity_medium.png'));
    // await controller.addImage('severity-high', await _loadImage('assets/icons/severity_high.png'));
    // await controller.addImage('severity-critical', await _loadImage('assets/icons/severity_critical.png'));
  }
  
  Future<void> _addClusterIcons() async {
    // TODO: Add cluster icons
    // await controller.addImage('cluster-small', await _loadImage('assets/icons/cluster_small.png'));
    // await controller.addImage('cluster-medium', await _loadImage('assets/icons/cluster_medium.png'));
    // await controller.addImage('cluster-large', await _loadImage('assets/icons/cluster_large.png'));
    // await controller.addImage('cluster-huge', await _loadImage('assets/icons/cluster_huge.png'));
  }
  
  /// Animate marker to new position
  Future<void> animateMarkerTo({
    required String markerId,
    required double latitude,
    required double longitude,
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    // TODO: Implement marker animation
    // This requires tracking current marker position and animating
  }
  
  /// Show marker info window
  Future<void> showMarkerInfo({
    required String markerId,
    required String title,
    required String description,
  }) async {
    // TODO: Implement info window
    // This could use a custom overlay or mapbox's info window
  }
  
  /// Hide marker info window
  Future<void> hideMarkerInfo(String markerId) async {
    // TODO: Hide info window
  }
}

/// Incident marker data
class IncidentMarker {
  final String id;
  final double latitude;
  final double longitude;
  final String incidentType;
  final String severity;
  final double confidence;
  final DateTime timestamp;
  
  IncidentMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.incidentType,
    required this.severity,
    required this.confidence,
    required this.timestamp,
  });
  
  /// Convert to map marker
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'incidentType': incidentType,
      'severity': severity,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Cluster marker data
class ClusterMarker {
  final String id;
  final double latitude;
  final double longitude;
  final int count;
  final double avgConfidence;
  final List<String> incidentIds;
  
  ClusterMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.count,
    required this.avgConfidence,
    required this.incidentIds,
  });
}
