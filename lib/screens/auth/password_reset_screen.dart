import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/notion_loading.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).resetPassword(_emailController.text.trim());
      
      setState(() => _emailSent = true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Password reset email sent!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_emailSent) ..._buildResetForm(theme) else ..._buildSuccessView(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResetForm(ThemeData theme) {
    return [
      // Icon
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: NotionColors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Icon(
          Icons.lock_reset_outlined,
          size: 40,
          color: NotionColors.blue,
        ),
      ),
      
      const SizedBox(height: 32),
      
      // Title
      Text(
        'Reset your password',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 16),
      
      // Description
      Text(
        'Enter your email address and we\'ll send you a link to reset your password.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 32),
      
      // Form
      Form(
        key: _formKey,
        child: Column(
          children: [
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Reset button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendPasswordReset,
                child: _isLoading 
                  ? NotionLoading.buttonLoading()
                  : const Text('Send reset email'),
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 24),
      
      // Back to sign in
      TextButton(
        onPressed: () => context.go('/sign-in'),
        child: const Text('Back to sign in'),
      ),
    ];
  }

  List<Widget> _buildSuccessView(ThemeData theme) {
    return [
      // Success icon
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Icon(
          Icons.check_circle_outline,
          size: 40,
          color: Colors.green,
        ),
      ),
      
      const SizedBox(height: 32),
      
      // Title
      Text(
        'Check your email',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 16),
      
      // Description
      Text(
        'We sent a password reset link to',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ),
      
      const SizedBox(height: 8),
      
      // Email
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _emailController.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      
      const SizedBox(height: 32),
      
      // Instructions
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next steps:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Check your email (including spam folder)\n2. Click the reset link in the email\n3. Create a new password\n4. Sign in with your new password',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 24),
      
      // Resend button
      OutlinedButton(
        onPressed: () => setState(() => _emailSent = false),
        child: const Text('Send another email'),
      ),
      
      const SizedBox(height: 16),
      
      // Back to sign in
      TextButton(
        onPressed: () => context.go('/sign-in'),
        child: const Text('Back to sign in'),
      ),
    ];
  }
}
