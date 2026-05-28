import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';

/// Heatmap layer for safety visualization
class HeatmapLayer {
  final GoogleMapController controller;
  final Map<String, Set<Circle>> _heatmapCircles = {};
  final Map<String, bool> _visibility = {};

  HeatmapLayer(this.controller);

  /// Add heatmap layer to map
  Future<void> addHeatmapLayer({
    required List<HeatmapPoint> points,
    required String layerId,
    required String sourceId,
    double radius = 25.0,
    double intensity = 0.5,
    double opacity = 0.6,
  }) async {
    final circles = <Circle>{};

    for (final point in points) {
      final color = _getColorForIntensity(point.intensity, opacity);
      final circle = Circle(
        circleId: CircleId('${layerId}_${point.latitude}_${point.longitude}'),
        center: LatLng(point.latitude, point.longitude),
        radius: radius * point.intensity * 100, // Scale radius by intensity
        fillColor: color,
        strokeColor: Colors.transparent,
        strokeWidth: 0,
      );
      circles.add(circle);
    }

    await controller.addCircles(circles);
    _heatmapCircles[layerId] = circles;
    _visibility[layerId] = true;
  }

  /// Update heatmap with new data
  Future<void> updateHeatmap({
    required List<HeatmapPoint> points,
    required String sourceId,
  }) async {
    // Remove existing and re-add
    for (final layerId in _heatmapCircles.keys) {
      await removeHeatmapLayer(layerId: layerId, sourceId: sourceId);
    }
    await addHeatmapLayer(
      points: points,
      layerId: sourceId,
      sourceId: sourceId,
    );
  }

  /// Remove heatmap layer
  Future<void> removeHeatmapLayer({
    required String layerId,
    required String sourceId,
  }) async {
    final circles = _heatmapCircles[layerId];
    if (circles != null) {
      for (final circle in circles) {
        await controller.removeCircle(circle.circleId);
      }
      _heatmapCircles.remove(layerId);
      _visibility.remove(layerId);
    }
  }

  /// Toggle heatmap visibility
  Future<void> toggleHeatmapVisibility({
    required String layerId,
    required bool visible,
  }) async {
    final circles = _heatmapCircles[layerId];
    if (circles != null) {
      final opacity = visible ? 0.6 : 0.0;
      for (final circle in circles) {
        final newColor = _updateColorOpacity(circle.fillColor, opacity);
        await controller.updateCircle(circle.circleId, CircleUpdates(fillColor: newColor));
      }
      _visibility[layerId] = visible;
    }
  }

  Color _getColorForIntensity(double intensity, double opacity) {
    // Color gradient from green (low) to red (high)
    if (intensity < 0.3) {
      return Colors.green.withOpacity(opacity * intensity);
    } else if (intensity < 0.5) {
      return Colors.yellow.withOpacity(opacity * intensity);
    } else if (intensity < 0.7) {
      return Colors.orange.withOpacity(opacity * intensity);
    } else {
      return Colors.red.withOpacity(opacity * intensity);
    }
  }

  Color _updateColorOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Add confidence-based weighting
  Future<void> addWeightedHeatmap({
    required List<HeatmapPoint> points,
    required String layerId,
    required String sourceId,
  }) async {
    // Weight points by confidence
    final weightedPoints = points.map((p) => HeatmapPoint(
          latitude: p.latitude,
          longitude: p.longitude,
          intensity: p.intensity * p.confidence,
          confidence: p.confidence,
          timestamp: p.timestamp,
        ));

    await addHeatmapLayer(
      points: weightedPoints.toList(),
      layerId: layerId,
      sourceId: sourceId,
    );
  }

  /// Add time-based heatmap
  Future<void> addTimeWeightedHeatmap({
    required List<HeatmapPoint> points,
    required String layerId,
    required String sourceId,
    DateTime? referenceTime,
  }) async {
    final refTime = referenceTime ?? DateTime.now();
    final timeWeightedPoints = points.map((p) {
      final hoursSince = refTime.difference(p.timestamp).inHours;
      final timeWeight = 1.0 / (1.0 + hoursSince / 24.0); // Decay over days
      return HeatmapPoint(
        latitude: p.latitude,
        longitude: p.longitude,
        intensity: p.intensity * timeWeight,
        confidence: p.confidence,
        timestamp: p.timestamp,
      );
    });

    await addHeatmapLayer(
      points: timeWeightedPoints.toList(),
      layerId: layerId,
      sourceId: sourceId,
    );
  }

  /// Add multiple heatmap layers
  Future<void> addMultiLayerHeatmap({
    required Map<String, List<HeatmapPoint>> incidentTypePoints,
    required Map<String, Color> typeColors,
  }) async {
    int index = 0;
    for (final entry in incidentTypePoints.entries) {
      final layerId = 'heatmap_${entry.key}_$index';
      final sourceId = 'heatmap_source_${entry.key}_$index';
      final color = typeColors[entry.key] ?? Colors.red;

      await addHeatmapLayer(
        points: entry.value,
        layerId: layerId,
        sourceId: sourceId,
      );
      index++;
    }
  }

  /// Convert points to GeoJSON
  String _pointsToGeojson(List<HeatmapPoint> points) {
    final features = points.map((p) => {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [p.longitude, p.latitude],
          },
          'properties': {
            'intensity': p.intensity,
            'confidence': p.confidence,
          },
        });

    return jsonEncode({
      'type': 'FeatureCollection',
      'features': features.toList(),
    });
  }
}

/// Heatmap point data
class HeatmapPoint {
  final double latitude;
  final double longitude;
  final double intensity; // 0.0 to 1.0
  final double confidence; // 0.0 to 1.0
  final DateTime timestamp;
  
  HeatmapPoint({
    required this.latitude,
    required this.longitude,
    required this.intensity,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Heatmap layer properties (stub)
class HeatmapLayerProperties {
  final double heatmapRadius;
  final double heatmapIntensity;
  final double heatmapOpacity;
  final List<dynamic>? heatmapColor;
  
  HeatmapLayerProperties({
    this.heatmapRadius = 25.0,
    this.heatmapIntensity = 0.5,
    this.heatmapOpacity = 0.6,
    this.heatmapColor,
  });
}
