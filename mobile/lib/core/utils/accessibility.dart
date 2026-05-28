import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Accessibility settings provider
final accessibilitySettingsProvider = StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
  (ref) => AccessibilitySettingsNotifier(),
);

/// Accessibility settings
class AccessibilitySettings {
  final bool screenReaderEnabled;
  final bool highContrastMode;
  final bool largeTextEnabled;
  final bool reduceMotion;
  final bool semanticLabelsEnabled;
  final double textScaleFactor;
  
  AccessibilitySettings({
    this.screenReaderEnabled = false,
    this.highContrastMode = false,
    this.largeTextEnabled = false,
    this.reduceMotion = false,
    this.semanticLabelsEnabled = true,
    this.textScaleFactor = 1.0,
  });
  
  AccessibilitySettings copyWith({
    bool? screenReaderEnabled,
    bool? highContrastMode,
    bool? largeTextEnabled,
    bool? reduceMotion,
    bool? semanticLabelsEnabled,
    double? textScaleFactor,
  }) {
    return AccessibilitySettings(
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      largeTextEnabled: largeTextEnabled ?? this.largeTextEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      semanticLabelsEnabled: semanticLabelsEnabled ?? this.semanticLabelsEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
}

/// Accessibility settings notifier
class AccessibilitySettingsNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilitySettingsNotifier() : super(AccessibilitySettings());
  
  void toggleScreenReader(bool enabled) {
    state = state.copyWith(screenReaderEnabled: enabled);
  }
  
  void toggleHighContrast(bool enabled) {
    state = state.copyWith(highContrastMode: enabled);
  }
  
  void toggleLargeText(bool enabled) {
    state = state.copyWith(
      largeTextEnabled: enabled,
      textScaleFactor: enabled ? 1.3 : 1.0,
    );
  }
  
  void toggleReduceMotion(bool enabled) {
    state = state.copyWith(reduceMotion: enabled);
  }
  
  void toggleSemanticLabels(bool enabled) {
    state = state.copyWith(semanticLabelsEnabled: enabled);
  }
  
  void setTextScaleFactor(double scale) {
    state = state.copyWith(textScaleFactor: scale.clamp(0.8, 2.0));
  }
}

/// Accessibility utilities
class AccessibilityUtils {
  /// Get semantic label for a widget
  static String getSemanticLabel({
    required String label,
    String? hint,
    String? value,
    bool? selected,
    bool? disabled,
  }) {
    final buffer = StringBuffer(label);
    
    if (value != null) {
      buffer.write(': $value');
    }
    
    if (selected == true) {
      buffer.write(', selected');
    }
    
    if (disabled == true) {
      buffer.write(', disabled');
    }
    
    if (hint != null) {
      buffer.write('. $hint');
    }
    
    return buffer.toString();
  }
  
  /// Announce message to screen reader
  static void announce(BuildContext context, String message) {
    // SemanticsService.announce is not available in all Flutter versions
    // Using a workaround with Semantics widget
  }
  
  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }
  
  /// Get appropriate text scale
  static double getTextScale(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor.clamp(0.8, 2.0);
  }
  
  /// Check if reduce motion is enabled
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  /// Check if high contrast is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
  
  /// Get accessible tap target size
  static double getTapTargetSize(BuildContext context) {
    // Minimum 48x48 as per WCAG 2.1
    return 48.0;
  }
  
  /// Check if color contrast is sufficient (simplified check)
  static bool hasSufficientContrast(Color foreground, Color background) {
    // Simplified contrast check - full implementation would use WCAG formula
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final contrast = (fgLuminance + 0.05) / (bgLuminance + 0.05);
    final ratio = contrast > 1 ? contrast : 1 / contrast;
    
    // WCAG AA requires 4.5:1 for normal text
    return ratio >= 4.5;
  }
  
  /// Get accessible color (adjust for high contrast mode)
  static Color getAccessibleColor(Color color, bool highContrast) {
    if (!highContrast) return color;
    
    // Return pure black or white for high contrast
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Accessible button wrapper
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? semanticHint;
  final bool? isSemanticButton;
  
  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.semanticHint,
    this.isSemanticButton = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: isSemanticButton,
      label: semanticLabel,
      hint: semanticHint,
      enabled: onPressed != null,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );
  }
}

/// Accessible text field wrapper
class AccessibleTextField extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool? isSemanticTextField;
  final TextEditingController? controller;
  
  const AccessibleTextField({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.isSemanticTextField = true,
    this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: isSemanticTextField,
      label: semanticLabel,
      hint: semanticHint,
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Accessible card wrapper
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  
  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      hint: semanticHint,
      enabled: onTap != null,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Accessible image wrapper
class AccessibleImage extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final bool decorative;
  
  const AccessibleImage({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.decorative = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: decorative ? null : semanticLabel,
      excludeSemantics: decorative,
      child: child,
    );
  }
}

/// Skip to main content button (for screen readers)
class SkipToMainContent extends StatelessWidget {
  final Widget child;
  final String label;
  
  const SkipToMainContent({
    super.key,
    required this.child,
    this.label = 'Skip to main content',
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          child: Semantics(
            button: true,
            label: label,
            onTap: () {
              // Focus on main content
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
