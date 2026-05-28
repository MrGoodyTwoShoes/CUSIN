import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';

/// Safe route service using Google Maps Directions API
class SafeRouteService {
  final String googleMapsApiKey;
  final Set<Polyline> _polylines = {};
  final Dio _dio = Dio();

  SafeRouteService({required this.googleMapsApiKey});

  /// Get all polylines for the map
  Set<Polyline> get polylines => _polylines;

  void setMapController(GoogleMapController controller) {
    // GoogleMapController is no longer needed for polyline management
    // Polylines are managed via the Set<Polyline> getter
  }

  /// Get safe route between two points
  Future<SafeRoute> getSafeRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    bool avoidHighRiskAreas = true,
    String profile = 'walking',
  }) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '$startLat,$startLng',
          'destination': '$endLat,$endLng',
          'mode': profile,
          'key': googleMapsApiKey,
          'alternatives': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final legs = route['legs'][0];
          final distance = legs['distance']['value'] as int;
          final duration = Duration(seconds: legs['duration']['value'] as int);
          final polyline = route['overview_polyline']['points'] as String;
          final waypoints = _decodePolyline(polyline);

          // Calculate safety score based on route characteristics
          final safetyScore = _calculateSafetyScore(distance, duration);

          return SafeRoute(
            startLat: startLat,
            startLng: startLng,
            endLat: endLat,
            endLng: endLng,
            distance: distance,
            duration: duration,
            waypoints: waypoints,
            safetyScore: safetyScore,
            alternativeRoutes: [],
          );
        }
      }
    } catch (e) {
      print('Error getting directions: $e');
    }

    // Fallback to straight line
    return SafeRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      distance: _haversineDistance(startLat, startLng, endLat, endLng).toInt(),
      duration: const Duration(minutes: 0),
      waypoints: [
        LatLng(startLat, startLng),
        LatLng(endLat, endLng),
      ],
      safetyScore: 0.5,
      alternativeRoutes: [],
    );
  }

  /// Draw route on map
  Future<void> drawRoute(SafeRoute route) async {
    final polyline = Polyline(
      polylineId: PolylineId('safe_route'),
      points: route.waypoints,
      color: Colors.blue,
      width: 5,
      endCap: Cap.roundCap,
      startCap: Cap.roundCap,
      jointType: JointType.round,
    );

    _polylines.add(polyline);
  }

  /// Clear route from map
  Future<void> clearRoute() async {
    _polylines.removeWhere((polyline) => polyline.polylineId.value == 'safe_route');
  }

  /// Calculate safety score
  double _calculateSafetyScore(int distance, Duration duration) {
    // Simple heuristic: longer routes might be safer if they avoid high-risk areas
    // This would be enhanced with actual incident data
    final baseScore = 0.7;
    final distanceFactor = math.min(distance / 10000, 0.2); // Up to 0.2 bonus for longer routes
    return math.min(baseScore + distanceFactor, 1.0);
  }

  /// Haversine distance calculation
  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000; // meters
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.pow(math.sin(dLng / 2), 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  /// Decode Google Maps polyline
  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
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
    required List<LatLng> waypoints,
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
  final List<LatLng> waypoints;
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

/// Heatmap point for safety scoring
class HeatmapPoint {
  final double latitude;
  final double longitude;
  final double intensity;

  HeatmapPoint({
    required this.latitude,
    required this.longitude,
    required this.intensity,
  });
}
