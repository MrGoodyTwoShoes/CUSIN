import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/common/cusin_button.dart';
import '../../widgets/common/cusin_text_field.dart';

/// Phone verification screen
class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(authProvider.notifier).login(_phoneController.text);
    
    final authState = ref.read(authProvider);
    
    if (authState.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error!)),
        );
      }
      return;
    }
    
    if (mounted) {
      context.go('/auth/otp', queryParameters: {'phone': _phoneController.text});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Phone Number'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // Icon
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'What\'s your phone number?',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'We\'ll send you a verification code',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Phone input
                CUSINTextField(
                  label: 'Phone Number',
                  hint: '+2547XXXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                  validator: Validators.validatePhone,
                ),
                
                const SizedBox(height: 24),
                
                // Continue button
                CUSINButton(
                  text: 'Continue',
                  onPressed: _handleContinue,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Privacy note
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy. Your phone number will be hashed for privacy.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
