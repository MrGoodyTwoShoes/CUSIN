import 'package:flutter/material.dart';

/// Incident detail screen
class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;
  
  const IncidentDetailScreen({
    super.key,
    required this.incidentId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
      ),
      body: Center(
        child: Text('Incident ID: $incidentId'),
      ),
    );
  }
}
