import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom button widget with loading state
class CUSINButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isOutlined;
  final bool isSecondary;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  
  const CUSINButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isOutlined = false,
    this.isSecondary = false,
    this.icon,
    this.leading,
    this.trailing,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final effectiveDisabled = isDisabled || isLoading;
    
    Widget buttonChild;
    
    if (isLoading) {
      buttonChild = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(text),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      );
    }
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: effectiveDisabled ? null : onPressed,
        child: buttonChild,
      );
    }
    
    if (isSecondary) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
        ),
        onPressed: effectiveDisabled ? null : onPressed,
        child: buttonChild,
      );
    }
    
    return ElevatedButton(
      onPressed: effectiveDisabled ? null : onPressed,
      child: buttonChild,
    );
  }
}
