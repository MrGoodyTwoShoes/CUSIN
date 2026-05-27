import 'package:flutter/material.dart';

/// Custom loading indicator
class CUSINLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;
  
  const CUSINLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? theme.colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full screen loading overlay
class CUSINLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  
  const CUSINLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: CUSINLoadingIndicator(message: message),
          ),
      ],
    );
  }
}
