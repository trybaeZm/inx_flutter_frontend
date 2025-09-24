import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initialize();
  }

  void _initialize() {
    // Listen to auth changes
    SupabaseService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        _handleUserSignedIn(authState.session?.user);
      } else if (authState.event == AuthChangeEvent.signedOut) {
        _handleUserSignedOut();
      }
    });

    // Check initial auth state
    final currentUser = SupabaseService.currentUser;
    if (currentUser != null) {
      _handleUserSignedIn(currentUser);
    }
  }

  Future<void> _handleUserSignedIn(User? user) async {
    if (user != null) {
      // Set auth token for API service
      final session = SupabaseService.client.auth.currentSession;
      if (session != null) {
        ApiService().setAuthToken(session.accessToken);
      }

      // Update UI state immediately to allow router redirect
      state = state.copyWith(user: user, isLoading: false, error: null);

      // Fire-and-forget backend sync so UI isn't blocked
      Future.microtask(() async {
        try {
          await _syncUserToBackend(user);
        } catch (_) {}
      });
    }
  }

  void _handleUserSignedOut() {
    ApiService().setAuthToken(null);
    state = state.copyWith(user: null, isLoading: false, error: null);
  }

  // Sign in with email and password (Supabase Auth + Backend sync)
  Future<void> signInWithEmail(String email, String password) async {
    print('🔐 Starting sign in for: $email');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // First, authenticate with Supabase
      print('📧 Authenticating with Supabase...');
      final response = await SupabaseService.signInWithEmail(email, password);
      
      print('📊 Supabase response: ${response.user?.id}, Session: ${response.session?.accessToken != null}');
      
      if (response.user != null) {
        // Set auth token
        if (response.session != null) {
          ApiService().setAuthToken(response.session!.accessToken);
          print('🔑 Auth token set successfully');
        }
        
        // Sync user to our backend database
        try {
          print('💾 Syncing user to backend database...');
          await _syncUserToBackend(response.user!);
          print('✅ User synced to backend successfully');
        } catch (syncError) {
          print('⚠️ Warning: Failed to sync user to backend: $syncError');
          // Continue anyway since Supabase auth succeeded
        }
        
        state = state.copyWith(
          user: response.user,
          isLoading: false,
        );
        
        print('🎉 Sign in completed successfully');
      } else {
        print('❌ No user returned from Supabase');
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid email or password',
        );
      }
    } catch (e) {
      print('💥 Sign in error: $e');
      String errorMessage = 'Sign in failed';
      
      // Parse Supabase error messages
      String errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid login credentials') || errorStr.contains('invalid user')) {
        errorMessage = 'Invalid email or password. Please check your credentials and try again.';
      } else if (errorStr.contains('email not confirmed')) {
        errorMessage = 'Please check your email and click the confirmation link to activate your account.';
      } else if (errorStr.contains('too many requests')) {
        errorMessage = 'Too many attempts. Please try again later.';
      } else if (errorStr.contains('signup is disabled')) {
        errorMessage = 'This account needs to be activated. Please contact support.';
      } else {
        errorMessage = 'Sign in failed. Please check your credentials or try creating a new account.';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  // Sign up with email and password (Supabase Auth + Backend sync)
  Future<void> signUpWithEmail(String email, String password, {String? fullName}) async {
    print('🔐 Starting sign up for: $email');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // First, create account with Supabase
      print('📧 Creating Supabase Auth account...');
      final response = await SupabaseService.signUpWithEmail(email, password, fullName: fullName);
      
      print('📊 Supabase response: ${response.user?.id}, Session: ${response.session?.accessToken != null}');
      
      if (response.user != null) {
        // Check if email confirmation is required
        if (response.session == null) {
          // Email confirmation required
          state = state.copyWith(
            isLoading: false,
            error: 'Please check your email and click the confirmation link to activate your account.',
          );
          return;
        }
        
        // Set auth token
        if (response.session != null) {
          ApiService().setAuthToken(response.session!.accessToken);
          print('🔑 Auth token set successfully');
        }
        
        // Sync user to our backend database
        try {
          print('💾 Syncing user to backend database...');
          await _syncUserToBackend(response.user!, fullName: fullName);
          print('✅ User synced to backend successfully');
        } catch (syncError) {
          print('⚠️ Warning: Failed to sync user to backend: $syncError');
          // Continue anyway since Supabase auth succeeded
        }
        
        state = state.copyWith(
          user: response.user,
          isLoading: false,
        );
        
        print('🎉 Sign up completed successfully');
      } else {
        print('❌ No user returned from Supabase');
        state = state.copyWith(
          isLoading: false,
          error: 'Account creation failed. Please try again.',
        );
      }
    } catch (e) {
      print('💥 Sign up error: $e');
      String errorMessage = 'Sign up failed';
      
      // Parse Supabase error messages
      String errorStr = e.toString().toLowerCase();
      if (errorStr.contains('user already registered') || errorStr.contains('already been registered')) {
        errorMessage = 'An account with this email already exists. Try signing in instead.';
      } else if (errorStr.contains('password should be at least')) {
        errorMessage = 'Password must be at least 6 characters long';
      } else if (errorStr.contains('invalid email')) {
        errorMessage = 'Please enter a valid email address';
      } else if (errorStr.contains('signup is disabled')) {
        errorMessage = 'Account creation is currently disabled. Please contact support.';
      } else {
        errorMessage = 'Account creation failed. Please try again or contact support.';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  // Sync user data to our backend database
  Future<void> _syncUserToBackend(User user, {String? fullName}) async {
    try {
      final apiService = ApiService();
      
      // Create user payload matching our backend User model
      final userData = {
        'id': user.id,
        'email': user.email ?? '',
        'full_name': fullName ?? user.userMetadata?['full_name'] ?? '',
        'created_at': user.createdAt,  // Already a string from Supabase
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': true,
      };
      
      // Try to create or update user in our backend
      await apiService.post('/auth/sync-user', userData);
      
      print('✅ User synced to backend successfully');
    } catch (e) {
      print('❌ Failed to sync user to backend: $e');
      throw e;
    }
  }

  // Social sign in methods (keeping these for future use)
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await SupabaseService.signInWithGoogle();
      
      if (success) {
        final currentUser = SupabaseService.currentUser;
        final session = SupabaseService.client.auth.currentSession;
        
        if (currentUser != null && session != null) {
          ApiService().setAuthToken(session.accessToken);
          
          // Sync to backend
          try {
            await _syncUserToBackend(currentUser);
          } catch (syncError) {
            print('Warning: Failed to sync user to backend: $syncError');
          }
          
          state = state.copyWith(
            user: currentUser,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Google sign in failed',
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Google sign in was cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed: ${e.toString()}',
      );
    }
  }

  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await SupabaseService.signInWithFacebook();
      
      if (success) {
        final currentUser = SupabaseService.currentUser;
        final session = SupabaseService.client.auth.currentSession;
        
        if (currentUser != null && session != null) {
          ApiService().setAuthToken(session.accessToken);
          await _syncUserToBackend(currentUser);
          state = state.copyWith(
            user: currentUser,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Facebook sign in failed',
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Facebook sign in was cancelled',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Facebook sign in failed: ${e.toString()}',
      );
    }
  }

  // Phone Authentication
  Future<void> signInWithPhone(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await SupabaseService.signInWithPhone(phone);
      
      // Don't change loading state here, wait for OTP verification
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send OTP: ${e.toString()}',
      );
    }
  }

  Future<void> verifyPhoneOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await SupabaseService.verifyPhoneOtp(phone, otp);
      
      if (response.user != null) {
        // Set auth token
        if (response.session != null) {
          ApiService().setAuthToken(response.session!.accessToken);
        }
        
        // Sync user to backend
        try {
          await _syncUserToBackend(response.user!);
        } catch (syncError) {
          print('Warning: Failed to sync user to backend: $syncError');
        }
        
        state = state.copyWith(
          user: response.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Phone verification failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid OTP code. Please try again.',
      );
    }
  }

  Future<void> signUpWithPhone(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await SupabaseService.signUpWithPhone(phone);
      
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send OTP: ${e.toString()}',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await SupabaseService.signOut();
      ApiService().setAuthToken(null);
      // Emit a manual signedOut event by updating state to ensure router refresh
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sign out failed: ${e.toString()}',
      );
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await SupabaseService.resetPassword(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  // Resend email confirmation
  Future<void> resendEmailConfirmation(String email) async {
    try {
      await SupabaseService.resendEmailConfirmation(email);
    } catch (e) {
      throw Exception('Failed to resend confirmation email: ${e.toString()}');
    }
  }

  // Refresh session to check for email confirmation
  Future<void> refreshSession() async {
    try {
      final session = await SupabaseService.refreshSession();
      if (session?.user != null) {
        state = state.copyWith(
          user: session!.user,
          isLoading: false,
          error: null,
        );
        
        // Set auth token
        ApiService().setAuthToken(session.accessToken);
        
        // Sync to backend
        try {
          await _syncUserToBackend(session.user!);
        } catch (syncError) {
          print('Warning: Failed to sync user to backend: $syncError');
        }
      }
    } catch (e) {
      print('Failed to refresh session: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({String? fullName, String? email}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedUser = await SupabaseService.updateProfile(
        fullName: fullName,
        email: email,
      );
      
      if (updatedUser != null) {
        // Sync changes to backend
        try {
          await _syncUserToBackend(updatedUser, fullName: fullName);
        } catch (syncError) {
          print('Warning: Failed to sync profile update to backend: $syncError');
        }
        
        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to update profile',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Profile update failed: ${e.toString()}',
      );
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await SupabaseService.changePassword(newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Password change failed: ${e.toString()}',
      );
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await SupabaseService.deleteAccount();
      ApiService().setAuthToken(null);
      
      state = state.copyWith(
        user: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Account deletion failed: ${e.toString()}',
      );
    }
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
}); 