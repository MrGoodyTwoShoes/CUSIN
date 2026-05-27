import 'package:flutter/material.dart';

/// Custom card widget
class CUSINCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Clip? clipBehavior;
  
  const CUSINCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.clipBehavior,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final card = Card(
      color: color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      clipBehavior: clipBehavior,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Container(
          margin: margin,
          child: card,
        ),
      );
    }
    
    return Container(
      margin: margin,
      child: card,
    );
  }
}
