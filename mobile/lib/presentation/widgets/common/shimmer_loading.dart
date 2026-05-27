import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading widget for skeleton screens
class CUSINShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  
  const CUSINShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Shimmer.fromColors(
      baseColor: baseColor ?? theme.colorScheme.surface,
      highlightColor: highlightColor ?? theme.colorScheme.surface.withOpacity(0.5),
      child: child,
    );
  }
}

/// Shimmer card placeholder
class ShimmerCard extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  
  const ShimmerCard({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return CUSINShimmer(
      child: Container(
        height: height ?? 100,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Shimmer list placeholder
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  
  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ShimmerCard(height: itemHeight),
        );
      },
    );
  }
}
