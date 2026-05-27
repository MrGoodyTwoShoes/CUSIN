import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_gl/src/mapbox_gl.dart' as mapbox;
import '../../../core/constants/app_constants.dart';

/// Heatmap layer for safety visualization
class HeatmapLayer {
  final mapbox.MapboxMapController controller;
  
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
    // Convert points to GeoJSON
    final geojson = _pointsToGeoJson(points);
    
    // Add source
    await controller.addSource(
      sourceId,
      mapbox.GeojsonSourceProperties(data: geojson),
    );
    
    // Add heatmap layer
    await controller.addHeatmapLayer(
      layerId,
      sourceId,
      properties: HeatmapLayerProperties(
        heatmapRadius: radius,
        heatmapIntensity: intensity,
        heatmapOpacity: opacity,
        heatmapColor: _getHeatmapColorExpression(),
      ),
      belowLayerId: 'road-label',
    );
  }
  
  /// Update heatmap with new data
  Future<void> updateHeatmap({
    required List<HeatmapPoint> points,
    required String sourceId,
  }) async {
    final geojson = _pointsToGeoJson(points);
    await controller.setSource(sourceId, mapbox.GeojsonSourceProperties(data: geojson));
  }
  
  /// Remove heatmap layer
  Future<void> removeHeatmapLayer({
    required String layerId,
    required String sourceId,
  }) async {
    await controller.removeLayer(layerId);
    await controller.removeSource(sourceId);
  }
  
  /// Toggle heatmap visibility
  Future<void> toggleHeatmapVisibility({
    required String layerId,
    required bool visible,
  }) async {
    await controller.setLayerVisibility(layerId, visible);
  }
  
  /// Convert points to GeoJSON format
  String _pointsToGeoJson(List<HeatmapPoint> points) {
    final features = points.map((point) {
      return {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [point.longitude, point.latitude],
        },
        'properties': {
          'intensity': point.intensity,
          'confidence': point.confidence,
        },
      };
    }).toList();
    
    return '''
    {
      "type": "FeatureCollection",
      "features": ${features.toString()}
    }
    ''';
  }
  
  /// Get heatmap color expression based on intensity
  List<dynamic> _getHeatmapColorExpression() {
    return [
      'interpolate',
      ['linear'],
      ['heatmap-density'],
      0.0, 'rgba(0, 255, 0, 0)', // Green - low risk
      0.3, 'rgba(255, 255, 0, 0.5)', // Yellow - medium-low risk
      0.5, 'rgba(255, 165, 0, 0.7)', // Orange - medium risk
      0.7, 'rgba(255, 69, 0, 0.8)', // Red-orange - high risk
      1.0, 'rgba(255, 0, 0, 1)', // Red - critical risk
    ];
  }
  
  /// Add confidence-based weighting
  Future<void> addWeightedHeatmap({
    required List<HeatmapPoint> points,
    required String layerId,
    required String sourceId,
  }) async {
    // Weight points by confidence score
    final weightedPoints = points.map((point) {
      final weight = point.confidence * point.intensity;
      return HeatmapPoint(
        latitude: point.latitude,
        longitude: point.longitude,
        intensity: weight,
        confidence: point.confidence,
      );
    }).toList();
    
    await addHeatmapLayer(
      points: weightedPoints,
      layerId: layerId,
      sourceId: sourceId,
    );
  }
  
  /// Add time-based heatmap (recent incidents weighted higher)
  Future<void> addTimeWeightedHeatmap({
    required List<HeatmapPoint> points,
    required String layerId,
    required String sourceId,
    DateTime? referenceTime,
  }) async {
    final now = referenceTime ?? DateTime.now();
    final timeWeightedPoints = points.map((point) {
      final hoursSinceIncident = now.difference(point.timestamp).inHours;
      final timeWeight = _calculateTimeWeight(hoursSinceIncident);
      final weightedIntensity = point.intensity * timeWeight * point.confidence;
      
      return HeatmapPoint(
        latitude: point.latitude,
        longitude: point.longitude,
        intensity: weightedIntensity,
        confidence: point.confidence,
        timestamp: point.timestamp,
      );
    }).toList();
    
    await addHeatmapLayer(
      points: timeWeightedPoints,
      layerId: layerId,
      sourceId: sourceId,
    );
  }
  
  /// Calculate time weight (recent incidents weighted higher)
  double _calculateTimeWeight(int hoursSince) {
    if (hoursSince < 1) return 1.0;
    if (hoursSince < 6) return 0.8;
    if (hoursSince < 12) return 0.6;
    if (hoursSince < 24) return 0.4;
    if (hoursSince < 48) return 0.2;
    return 0.1;
  }
  
  /// Add multiple heatmap layers for different incident types
  Future<void> addMultiLayerHeatmap({
    required Map<String, List<HeatmapPoint>> incidentTypePoints,
    required Map<String, Color> typeColors,
  }) async {
    for (final entry in incidentTypePoints.entries) {
      final type = entry.key;
      final points = entry.value;
      final color = typeColors[type] ?? Colors.blue;
      
      await addHeatmapLayer(
        points: points,
        layerId: 'heatmap_$type',
        sourceId: 'heatmap_source_$type',
        radius: 20.0,
        intensity: 0.4,
        opacity: 0.5,
      );
    }
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

/// Heatmap layer properties
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
  
  mapbox.HeatmapLayerProperties toMapboxProperties() {
    return mapbox.HeatmapLayerProperties(
      heatmapRadius: heatmapRadius,
      heatmapIntensity: heatmapIntensity,
      heatmapOpacity: heatmapOpacity,
      heatmapColor: heatmapColor,
    );
  }
}
