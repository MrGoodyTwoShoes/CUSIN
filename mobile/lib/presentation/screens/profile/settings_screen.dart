import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/accessibility.dart';
import '../../providers/providers.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final accessibilitySettings = ref.watch(accessibilitySettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state = value
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
          
          const Divider(),
          
          // Notifications
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive incident alerts'),
            value: true,
            onChanged: (value) {
              // TODO: Implement notification toggle
            },
          ),
          
          SwitchListTile(
            title: const Text('Location Sharing'),
            subtitle: const Text('Share location with circles'),
            value: true,
            onChanged: (value) {
              // TODO: Implement location sharing toggle
            },
          ),
          
          const Divider(),
          
          // Accessibility
          Text(
            'Accessibility',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          SwitchListTile(
            title: const Text('Screen Reader'),
            subtitle: const Text('Optimize for screen readers'),
            value: accessibilitySettings.screenReaderEnabled,
            onChanged: (value) {
              ref.read(accessibilitySettingsProvider.notifier).toggleScreenReader(value);
            },
          ),
          
          SwitchListTile(
            title: const Text('High Contrast'),
            subtitle: const Text('Increase color contrast'),
            value: accessibilitySettings.highContrastMode,
            onChanged: (value) {
              ref.read(accessibilitySettingsProvider.notifier).toggleHighContrast(value);
            },
          ),
          
          SwitchListTile(
            title: const Text('Large Text'),
            subtitle: const Text('Increase text size'),
            value: accessibilitySettings.largeTextEnabled,
            onChanged: (value) {
              ref.read(accessibilitySettingsProvider.notifier).toggleLargeText(value);
            },
          ),
          
          SwitchListTile(
            title: const Text('Reduce Motion'),
            subtitle: const Text('Minimize animations'),
            value: accessibilitySettings.reduceMotion,
            onChanged: (value) {
              ref.read(accessibilitySettingsProvider.notifier).toggleReduceMotion(value);
            },
          ),
          
          const Divider(),
          
          // Privacy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to security settings
            },
          ),
          
          const Divider(),
          
          // Data
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Cache'),
            onTap: () {
              // TODO: Clear cache
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download Offline Maps'),
            onTap: () {
              // TODO: Download maps
            },
          ),
        ],
      ),
    );
  }
}
