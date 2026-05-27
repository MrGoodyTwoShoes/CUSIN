import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/common/cusin_button.dart';
import '../../widgets/common/cusin_text_field.dart';

/// OTP verification screen
class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  
  const OTPVerificationScreen({
    super.key,
    required this.phone,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
  
  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(authProvider.notifier).verifyPhone(widget.phone, _otpController.text);
    
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
      context.go('/');
    }
  }
  
  Future<void> _handleResend() async {
    // TODO: Implement resend OTP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final formattedPhone = Formatters.maskPhone(widget.phone);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
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
                  Icons.sms,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Enter the code sent to $formattedPhone',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Check your SMS messages for the 6-digit code',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // OTP input
                CUSINTextField(
                  label: 'Verification Code',
                  hint: '123456',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  validator: Validators.validateOtp,
                ),
                
                const SizedBox(height: 24),
                
                // Verify button
                CUSINButton(
                  text: 'Verify',
                  onPressed: _handleVerify,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Resend link
                TextButton(
                  onPressed: _handleResend,
                  child: const Text('Resend Code'),
                ),
                
                const SizedBox(height: 16),
                
                // Wrong number
                TextButton(
                  onPressed: () => context.go('/auth/phone'),
                  child: const Text('Wrong number?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
