import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl/src/mapbox_gl.dart' as mapbox;
import '../../../core/constants/app_constants.dart';

/// Safe route service using Mapbox Directions API
class SafeRouteService {
  final String mapboxAccessToken;
  
  SafeRouteService({required this.mapboxAccessToken});
  
  /// Get safe route between two points
  Future<SafeRoute> getSafeRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    bool avoidHighRiskAreas = true,
    String profile = 'walking',
  }) async {
    // TODO: Implement Mapbox Directions API call
    // This would call Mapbox Directions API with custom parameters
    // to avoid high-risk areas based on heatmap data
    
    // Placeholder implementation
    return SafeRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      distance: 0,
      duration: const Duration(minutes: 0),
      waypoints: [],
      safetyScore: 0.8,
      alternativeRoutes: [],
    );
  }
  
  /// Get multiple route options with safety scores
  Future<List<SafeRoute>> getRouteOptions({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    int alternatives = 3,
  }) async {
    // TODO: Implement multi-route calculation
    // This would return multiple route options with different
    // safety scores based on heatmap data
    
    return [];
  }
  
  /// Calculate safety score for a route
  double calculateRouteSafetyScore({
    required List<Waypoint> waypoints,
    required List<HeatmapPoint> heatmapData,
  }) {
    if (heatmapData.isEmpty) return 1.0;
    
    double totalRisk = 0;
    int segments = 0;
    
    for (int i = 0; i < waypoints.length - 1; i++) {
      final start = waypoints[i];
      final end = waypoints[i + 1];
      
      // Find heatmap points near this segment
      final nearbyRisks = heatmapData.where((point) {
        final distance = _haversineDistance(
          start.latitude,
          start.longitude,
          point.latitude,
          point.longitude,
        );
        return distance < 100; // 100m radius
      }).toList();
      
      if (nearbyRisks.isNotEmpty) {
        final avgRisk = nearbyRisks
            .map((p) => p.intensity)
            .reduce((a, b) => a + b) / nearbyRisks.length;
        totalRisk += avgRisk;
        segments++;
      }
    }
    
    if (segments == 0) return 1.0;
    
    final avgRisk = totalRisk / segments;
    return (1.0 - avgRisk).clamp(0.0, 1.0);
  }
  
  /// Haversine distance calculation
  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000; // meters
    
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() * lat2.toRadians().cos() *
        (dLng / 2).sin() * (dLng / 2).sin();
    
    final c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}

/// Safe route data
class SafeRoute {
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final double distance; // in meters
  final Duration duration;
  final List<Waypoint> waypoints;
  final double safetyScore; // 0.0 to 1.0
  final List<SafeRoute> alternativeRoutes;
  
  SafeRoute({
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.distance,
    required this.duration,
    required this.waypoints,
    required this.safetyScore,
    this.alternativeRoutes = const [],
  });
  
  /// Get safety level
  String get safetyLevel {
    if (safetyScore >= 0.8) return 'Very Safe';
    if (safetyScore >= 0.6) return 'Safe';
    if (safetyScore >= 0.4) return 'Moderate Risk';
    if (safetyScore >= 0.2) return 'High Risk';
    return 'Very High Risk';
  }
  
  /// Get safety color
  Color get safetyColor {
    if (safetyScore >= 0.8) return const Color(0xFF4CAF50); // Green
    if (safetyScore >= 0.6) return const Color(0xFF8BC34A); // Light Green
    if (safetyScore >= 0.4) return const Color(0xFFFFC107); // Yellow
    if (safetyScore >= 0.2) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}

/// Route waypoint
class Waypoint {
  final double latitude;
  final double longitude;
  final String? instruction;
  
  Waypoint({
    required this.latitude,
    required this.longitude,
    this.instruction,
  });
}

import 'package:flutter/material.dart';
