import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Email form
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  // Phone form
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
      try {
        await ref.read(authProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        // Check for auth errors
        final authState = ref.read(authProvider);
        if (authState.error != null) {
          // Check if it's an email confirmation error
          if (authState.error!.contains('email') && authState.error!.contains('confirmation')) {
            if (mounted) {
              context.go('/email-confirmation', extra: _emailController.text.trim());
            }
            return;
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.error!),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
          return;
        }
        
        // Success - navigate to business selection
        if (mounted && authState.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Sign in successful!'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Small delay to show success message
          await Future.delayed(const Duration(milliseconds: 500));
          context.go('/business-selection');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Sign in failed: ${e.toString()}'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
  }

  Future<void> _signInWithPhone() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).signInWithPhone(_phoneController.text.trim());
      
      final authState = ref.read(authProvider);
      
      if (authState.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }
      
      // Navigate to phone verification screen
      if (mounted) {
        context.push('/phone-verification', extra: {
          'phone': _phoneController.text.trim(),
          'isSignUp': false,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to send OTP: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _signInWithProvider(String provider) async {
    try {
      // Show loading state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening $provider sign-in...'),
          duration: const Duration(seconds: 2),
        ),
      );

      switch (provider.toLowerCase()) {
        case 'google':
          await ref.read(authProvider.notifier).signInWithGoogle();
          break;
        case 'facebook':
          await ref.read(authProvider.notifier).signInWithFacebook();
          break;
      }
      
      if (mounted) {
        context.go('/business-selection');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left side - Brand and description
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(80),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          NotionColors.blue,
                          NotionColors.blue.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.business_center_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Welcome to Inxource',
                          style: GoogleFonts.inter(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AI-powered business management platform',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Manage sales, marketing, inventory, accounting, and more—all in one intelligent workspace.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Right side - Sign in form
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Text(
                                'Sign in to your account',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Welcome back! Choose your preferred sign-in method.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              // Social login buttons
                              _buildSocialButtons(isLoading),
                              
                              const SizedBox(height: 32),

                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: theme.dividerColor)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'or continue with',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: theme.dividerColor)),
                                ],
                              ),
                              
                              const SizedBox(height: 32),

                              // Tab bar
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: NotionColors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                                  labelStyle: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  unselectedLabelStyle: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  tabs: const [
                                    Tab(
                                      icon: Icon(Icons.email_outlined, size: 20),
                                      text: 'Email',
                                    ),
                                    Tab(
                                      icon: Icon(Icons.phone_outlined, size: 20),
                                      text: 'Phone',
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 32),

                              // Tab content
                              SizedBox(
                                height: 320,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildEmailForm(isLoading, theme),
                                    _buildPhoneForm(isLoading, theme),
                                  ],
                                ),
                              ),

                              // Create account link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t have an account? ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/sign-up'),
                                    child: const Text('Create account'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons(bool isLoading) {
    return Column(
      children: [
        // Google
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : () => _signInWithProvider('google'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.g_mobiledata,
              color: Color(0xFF4285F4),
              size: 24,
            ),
            label: Text(
              'Continue with Google',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Facebook
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : () => _signInWithProvider('facebook'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.facebook,
              color: Color(0xFF1877F2),
              size: 20,
            ),
            label: Text(
              'Continue with Facebook',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(bool isLoading, ThemeData theme) {
    return Form(
      key: _emailFormKey,
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
                return 'Email is required';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Remember me and Forgot password
          Row(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  Text(
                    'Remember me',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/password-reset'),
                child: const Text('Forgot password?'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _signInWithEmail,
              child: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Sign in with Email'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm(bool isLoading, ThemeData theme) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        children: [
          // Phone field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '+1 (555) 123-4567',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              // Basic phone validation (you can improve this)
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Info text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NotionColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: NotionColors.blue.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: NotionColors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'We\'ll send you a verification code via SMS',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: NotionColors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _signInWithPhone,
              child: isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Send verification code'),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF334155),
        title: Text(
          'Reset Password',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                try {
                  await ref.read(authProvider.notifier).resetPassword(emailController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text(
              'Send Reset Link',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 