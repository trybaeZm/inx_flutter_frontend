import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables before initializing services
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Inxource - Notion Style',
      debugShowCheckedModeBanner: false,
      
      // Use Notion theme system (light by default)
      theme: NotionTheme.lightTheme,
      darkTheme: NotionTheme.darkTheme,
      themeMode: themeMode,
      
      // Router configuration
      routerConfig: router,
      
      // App-wide configuration
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
} 