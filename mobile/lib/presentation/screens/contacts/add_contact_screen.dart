import 'package:flutter/material.dart';

/// Add contact screen
class AddContactScreen extends StatelessWidget {
  const AddContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: const Center(
        child: Text('Add Contact'),
      ),
    );
  }
}
