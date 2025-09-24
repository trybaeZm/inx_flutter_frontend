import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../../screens/auth/sign_in_screen.dart';
import '../../screens/auth/sign_up_screen.dart';
import '../../screens/business/business_selection_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/customers/customers_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/sales_analytics/sales_analytics_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/insights/insights_overview_screen.dart';
import '../../screens/customer_analytics/customer_analytics_screen.dart';
import '../../screens/customer_analytics/customer_gender_ratio_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/ai/ai_agents_screen.dart';
import '../../screens/ai/whatsapp_agent_screen.dart';
import '../../screens/wallet/wallet_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/auth/email_confirmation_screen.dart';
import '../../screens/auth/password_reset_screen.dart';
import '../../screens/auth/phone_verification_screen.dart';
import '../../widgets/layout/main_layout.dart';
import '../../screens/lennyai/lennyai_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  
  return GoRouter(
    initialLocation: '/sign-in',
    // Re-run redirect whenever Supabase auth state changes
    refreshListenable: GoRouterRefreshStream(SupabaseService.authStateChanges),
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isAuthRoute = state.fullPath?.startsWith('/sign-') ?? false ||
                         state.fullPath == '/email-confirmation' ||
                         state.fullPath == '/password-reset' ||
                         state.fullPath == '/phone-verification';
      final isBusinessRoute = state.fullPath == '/business-selection';
      
      // If not authenticated and not on auth route, redirect to sign-in
      if (!isAuthenticated && !isAuthRoute) {
        return '/sign-in';
      }
      
      // If authenticated and on auth route, redirect to business selection
      if (isAuthenticated && isAuthRoute) {
        return '/business-selection';
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/email-confirmation',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailConfirmationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/phone-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phone'] as String? ?? '';
          final isSignUp = extra['isSignUp'] as bool? ?? false;
          return PhoneVerificationScreen(
            phoneNumber: phone,
            isSignUp: isSignUp,
          );
        },
      ),
      
      // Business selection route
      GoRoute(
        path: '/business-selection',
        builder: (context, state) => const BusinessSelectionScreen(),
      ),
      
      // Main app routes (with layout)
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomersScreen(),
          ),
          GoRoute(
            path: '/lennyai',
            builder: (context, state) => const LennyAiScreen(),
          ),
          GoRoute(
            path: '/trychat',
            builder: (context, state) => const LennyAiScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsOverviewScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/sales-analytics',
            builder: (context, state) => const SalesAnalyticsScreen(),
          ),
          GoRoute(
            path: '/customer-analytics',
            builder: (context, state) => const CustomerAnalyticsScreen(),
          ),
          GoRoute(
            path: '/customer-analytics/customer_gender_ratio',
            builder: (context, state) => const CustomerGenderRatioScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/ai-agents',
            builder: (context, state) => const AiAgentsScreen(),
          ),
          GoRoute(
            path: '/whatsapp',
            builder: (context, state) => const WhatsAppAgentScreen(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

// Listenable that notifies GoRouter whenever the provided stream emits
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}