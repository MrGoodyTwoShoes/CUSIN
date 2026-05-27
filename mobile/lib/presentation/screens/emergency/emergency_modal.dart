import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/cusin_button.dart';

/// Emergency escalation modal
class EmergencyModal extends StatelessWidget {
  const EmergencyModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text('Emergency'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Warning icon
              Icon(
                Icons.emergency,
                size: 100,
                color: Colors.red,
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Emergency Assistance',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                'If you are in immediate danger, please contact emergency services.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Emergency contacts
              _EmergencyButton(
                icon: Icons.phone,
                label: 'Call Police',
                color: Colors.red,
                onTap: () {
                  // TODO: Call emergency services
                },
              ),
              
              const SizedBox(height: 16),
              
              _EmergencyButton(
                icon: Icons.local_hospital,
                label: 'Call Ambulance',
                color: Colors.orange,
                onTap: () {
                  // TODO: Call ambulance
                },
              ),
              
              const SizedBox(height: 16),
              
              _EmergencyButton(
                icon: Icons.fire_truck,
                label: 'Call Fire Department',
                color: Colors.orange.shade700,
                onTap: () {
                  // TODO: Call fire department
                },
              ),
              
              const SizedBox(height: 32),
              
              // Notify circles
              CUSINButton(
                text: 'Notify Trusted Contacts',
                onPressed: () {
                  // TODO: Notify trusted contacts
                },
                isSecondary: true,
              ),
              
              const SizedBox(height: 16),
              
              // Share location
              CUSINButton(
                text: 'Share Live Location',
                onPressed: () {
                  // TODO: Share live location
                },
                isSecondary: true,
              ),
              
              const Spacer(),
              
              // Cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _EmergencyButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppConstants.minTouchTarget * 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
