import 'package:flutter/material.dart';

/// Circle detail screen
class CircleDetailScreen extends StatelessWidget {
  final String circleId;
  
  const CircleDetailScreen({
    super.key,
    required this.circleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Details'),
      ),
      body: Center(
        child: Text('Circle ID: $circleId'),
      ),
    );
  }
}
