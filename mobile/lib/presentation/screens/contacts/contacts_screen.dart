import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Contacts screen
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/contacts/add'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Contacts'),
      ),
    );
  }
}
