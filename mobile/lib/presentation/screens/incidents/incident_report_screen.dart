import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../services/location_service.dart';
import '../../providers/providers.dart';
import '../../widgets/common/cusin_button.dart';
import '../../widgets/common/cusin_card.dart';
import '../../widgets/common/cusin_text_field.dart';

/// Incident report screen
class IncidentReportScreen extends ConsumerStatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  ConsumerState<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends ConsumerState<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String _incidentType = 'suspicious_activity';
  String _severity = 'medium';
  bool _isAnonymous = false;
  List<XFile> _evidenceImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  
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
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    if (_evidenceImages.length >= AppConstants.maxEvidenceCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${AppConstants.maxEvidenceCount} images allowed'),
        ),
      );
      return;
    }
    
    final images = await _imagePicker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (images != null) {
      setState(() {
        _evidenceImages.addAll(images.take(
          AppConstants.maxEvidenceCount - _evidenceImages.length,
        ));
      });
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _evidenceImages.removeAt(index);
    });
  }
  
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Get current location
    final locationState = ref.read(locationServiceProvider);
    if (locationState.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required')),
      );
      return;
    }
    
    // Fuzz location for privacy
    final fuzzedLocation = ref.read(locationServiceProvider.notifier).fuzzLocation(
      locationState.currentPosition!,
    );
    
    await ref.read(incidentProvider.notifier).createIncident(
      incidentType: _incidentType,
      description: _descriptionController.text.trim(),
      latitude: fuzzedLocation.latitude,
      longitude: fuzzedLocation.longitude,
      severity: _severity,
      isAnonymous: _isAnonymous,
    );
    
    final incidentState = ref.read(incidentProvider);
    
    if (incidentState.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(incidentState.error!)),
        );
      }
      return;
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident reported successfully')),
      );
      context.pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationState = ref.watch(locationServiceProvider);
    final incidentState = ref.watch(incidentProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Location display
              CUSINCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: locationState.currentPosition != null
                          ? Text(
                              'Lat: ${locationState.currentPosition!.latitude.toStringAsFixed(4)}, '
                              'Lng: ${locationState.currentPosition!.longitude.toStringAsFixed(4)}',
                            )
                          : const Text('Getting location...'),
                    ),
                    if (locationState.currentPosition != null)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          await ref.read(locationServiceProvider.notifier).getCurrentLocation();
                        },
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Anonymous toggle
              CUSINCard(
                child: SwitchListTile(
                  title: const Text('Report Anonymously'),
                  subtitle: const Text('Your identity will be hidden'),
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value;
                    });
                  },
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
                    child: Text(Formatters.formatIncidentType(type)),
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
                    child: Text(Formatters.formatSeverity(level)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _severity = value!);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description
              CUSINTextField(
                label: 'Description (Optional)',
                hint: 'Provide additional details...',
                controller: _descriptionController,
                maxLines: 4,
                maxLength: AppConstants.maxDescriptionLength,
                validator: (value) => Validators.validateDescription(value),
              ),
              
              const SizedBox(height: 16),
              
              // Evidence upload
              CUSINCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Evidence (${_evidenceImages.length}/${AppConstants.maxEvidenceCount})',
                          style: theme.textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add Photo'),
                        ),
                      ],
                    ),
                    if (_evidenceImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _evidenceImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _evidenceImages[index].path as Object,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () => _removeImage(index),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Confidence indicator
              CUSINCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your report will be reviewed by moderators before being published',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit button
              CUSINButton(
                text: 'Submit Report',
                onPressed: _submitReport,
                isLoading: incidentState.isCreating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
