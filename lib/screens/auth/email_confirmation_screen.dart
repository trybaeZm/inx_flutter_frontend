import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/notion_loading.dart';

class EmailConfirmationScreen extends ConsumerStatefulWidget {
  final String email;
  
  const EmailConfirmationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  ConsumerState<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends ConsumerState<EmailConfirmationScreen> {
  bool _isResending = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Start checking for confirmation every few seconds
    _startConfirmationCheck();
  }

  void _startConfirmationCheck() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkConfirmationStatus();
      }
    });
  }

  Future<void> _checkConfirmationStatus() async {
    if (_isChecking) return;
    
    setState(() => _isChecking = true);
    
    try {
      // Try to refresh the user session
      await ref.read(authProvider.notifier).refreshSession();
      
      // If user is now authenticated, redirect
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        if (mounted) {
          context.go('/business-selection');
        }
        return;
      }
      
      // Continue checking if still mounted
      if (mounted) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) _checkConfirmationStatus();
        });
      }
    } catch (e) {
      print('Error checking confirmation status: $e');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendConfirmation() async {
    setState(() => _isResending = true);
    
    try {
      await ref.read(authProvider.notifier).resendEmailConfirmation(widget.email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Confirmation email sent!'),
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
            content: Text('❌ Failed to resend: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      setState(() => _isResending = false);
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: NotionColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 40,
                  color: NotionColors.blue,
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
                'We sent a confirmation link to',
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
                  widget.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Instructions
              Text(
                'Click the link in the email to verify your account.\nThis page will automatically redirect when confirmed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Checking status
              if (_isChecking) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Checking confirmation status...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              
              // Resend button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isResending ? null : _resendConfirmation,
                  child: _isResending 
                    ? NotionLoading.buttonLoading()
                    : const Text('Resend confirmation email'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Back to sign in
              TextButton(
                onPressed: () => context.go('/sign-in'),
                child: const Text('Back to sign in'),
              ),
              
              const SizedBox(height: 32),
              
              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Didn\'t receive the email?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your spam/junk folder\n• Make sure ${widget.email} is correct\n• Try resending the confirmation email',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
