import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static late Supabase _instance;
  static SupabaseClient get client => _instance.client;

  static Future<void> initialize() async {
    // Ensure env is loaded before accessing variables
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseUrl.isEmpty ||
        supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase env vars not set. Please define SUPABASE_URL and SUPABASE_ANON_KEY in a .env file.');
    }

    _instance = await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Email/Password Authentication
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  static Future<AuthResponse> signUpWithEmail(String email, String password, {String? fullName}) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Social Authentication
  static Future<bool> signInWithGoogle() async {
    try {
      final redirect = kIsWeb ? '${Uri.base.origin}/#/business-selection' : null;
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirect,
      );
      return true; // On web this redirects; authStateChanges will handle session
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  static Future<bool> signInWithFacebook() async {
    try {
      final redirect = kIsWeb ? '${Uri.base.origin}/#/business-selection' : null;
      await client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: redirect,
      );
      return true; // On web this redirects; authStateChanges will handle session
    } catch (e) {
      throw Exception('Facebook sign in failed: $e');
    }
  }

  // Phone Authentication
  static Future<void> signInWithPhone(String phone) async {
    try {
      await client.auth.signInWithOtp(
        phone: phone,
        channel: OtpChannel.sms,
      );
    } catch (e) {
      throw Exception('Phone sign in failed: $e');
    }
  }

  static Future<AuthResponse> verifyPhoneOtp(String phone, String token) async {
    try {
      final response = await client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: token,
      );
      return response;
    } catch (e) {
      throw Exception('Phone verification failed: $e');
    }
  }

  static Future<void> signUpWithPhone(String phone) async {
    try {
      await client.auth.signInWithOtp(
        phone: phone,
        channel: OtpChannel.sms,
      );
    } catch (e) {
      throw Exception('Phone sign up failed: $e');
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Password Reset
  static Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://localhost:3000/reset-password',
      );
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Get Current User
  static User? get currentUser => client.auth.currentUser;

  // Auth State Stream
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Resend Email Confirmation
  static Future<void> resendEmailConfirmation(String email) async {
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to resend confirmation: $e');
    }
  }

  // Refresh Session
  static Future<Session?> refreshSession() async {
    try {
      final response = await client.auth.refreshSession();
      return response.session;
    } catch (e) {
      throw Exception('Failed to refresh session: $e');
    }
  }

  // Update Profile
  static Future<User?> updateProfile({String? fullName, String? email}) async {
    try {
      final response = await client.auth.updateUser(
        UserAttributes(
          email: email,
          data: fullName != null ? {'full_name': fullName} : null,
        ),
      );
      return response.user;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change Password
  static Future<void> changePassword(String newPassword) async {
    try {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Delete Account (Note: Supabase doesn't have direct user deletion from client)
  static Future<void> deleteAccount() async {
    try {
      // This would typically be handled by calling a backend endpoint
      // that uses the service role key to delete the user
      throw Exception('Account deletion must be handled by backend service');
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
} 