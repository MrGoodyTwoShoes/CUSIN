import 'package:flutter/material.dart';

/// Circles screen
class CirclesScreen extends StatelessWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Circles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Create new circle
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Circles'),
      ),
    );
  }
}
