import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';

/// Marker layer for incident visualization
class MarkerLayer {
  final GoogleMapController controller;
  final Map<String, Marker> _markers = {};

  MarkerLayer(this.controller);

  /// Get all markers for the map
  Set<Marker> get markers => _markers.values.toSet();

  /// Add incident marker
  Future<void> addIncidentMarker({
    required String markerId,
    required double latitude,
    required double longitude,
    required String incidentType,
    required String severity,
    required double confidence,
  }) async {
    final icon = _getBitmapDescriptorForIncident(incidentType, severity);
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
      icon: icon,
      infoWindow: InfoWindow(title: incidentType, snippet: severity),
    );
    _markers[markerId] = marker;
  }

  /// Add cluster marker
  Future<void> addClusterMarker({
    required String markerId,
    required double latitude,
    required double longitude,
    required int count,
    required double avgConfidence,
  }) async {
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: '$count incidents', snippet: 'Cluster'),
    );
    _markers[markerId] = marker;
  }

  /// Add custom marker with image
  Future<void> addCustomMarker({
    required String markerId,
    required double latitude,
    required double longitude,
    required String imagePath,
    double size = 0.3,
  }) async {
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarker,
    );
    _markers[markerId] = marker;
  }

  /// Remove marker
  Future<void> removeMarker(String markerId) async {
    _markers.remove(markerId);
  }

  /// Remove all markers
  Future<void> removeAllMarkers() async {
    _markers.clear();
  }

  /// Add click listener to markers
  void addMarkerClickListener({
    required Function(String markerId) onMarkerTap,
  }) {
    // Google Maps marker click handling via onMarkerTap callback
  }

  /// Add custom images for markers
  Future<void> addMarkerImages() async {
    // Google Maps uses BitmapDescriptor.fromAsset or fromBytes
  }

  /// Animate marker to new position
  Future<void> animateMarkerTo({
    required String markerId,
    required double latitude,
    required double longitude,
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await removeMarker(markerId);
    final marker = _markers[markerId];
    if (marker != null) {
      await addIncidentMarker(
        markerId: markerId,
        latitude: latitude,
        longitude: longitude,
        incidentType: marker.infoWindow.title ?? '',
        severity: marker.infoWindow.snippet ?? '',
        confidence: 1.0,
      );
    }
  }

  /// Show marker info window
  Future<void> showMarkerInfo({
    required String markerId,
    required String title,
    required String description,
  }) async {
    // Google Maps info windows show automatically on tap
  }

  /// Hide marker info window
  Future<void> hideMarkerInfo(String markerId) async {
    // Google Maps info windows hide automatically
  }

  BitmapDescriptor _getBitmapDescriptorForIncident(String incidentType, String severity) {
    final severityLower = severity.toLowerCase();
    if (severityLower.contains('critical')) return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    if (severityLower.contains('high')) return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    if (severityLower.contains('medium')) return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
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
