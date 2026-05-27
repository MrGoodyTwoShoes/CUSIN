import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = APIService();
  
  final _descriptionController = TextEditingController();
  
  String _incidentType = 'suspicious_activity';
  String _severity = 'medium';
  Position? _currentPosition;
  bool _isLoading = false;
  bool _isGettingLocation = false;

  final List<String> _incidentTypes = [
    'suspicious_activity',
    'robbery',
    'harassment',
    'violence',
    'kidnapping',
    'accident',
    'missing_person',
    'road_danger',
    'community_alert',
  ];

  final List<String> _severityLevels = ['low', 'medium', 'high', 'critical'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() => _currentPosition = position);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.createIncident(
        incidentType: _incidentType,
        description: _descriptionController.text.trim(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        severity: _severity,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident reported successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _isGettingLocation
                                ? const CircularProgressIndicator()
                                : Text(
                                    _currentPosition != null
                                        ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                                        : 'Location not available',
                                  ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _getCurrentLocation,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Incident type
              DropdownButtonFormField<String>(
                value: _incidentType,
                decoration: const InputDecoration(
                  labelText: 'Incident Type',
                  border: OutlineInputBorder(),
                ),
                items: _incidentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _incidentType = value!);
                },
              ),
              const SizedBox(height: 16),

              // Severity
              DropdownButtonFormField<String>(
                value: _severity,
                decoration: const InputDecoration(
                  labelText: 'Severity',
                  border: OutlineInputBorder(),
                ),
                items: _severityLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _severity = value!);
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Provide additional details...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 1000,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
