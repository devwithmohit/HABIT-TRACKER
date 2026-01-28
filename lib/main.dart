import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create provider container
  final container = ProviderContainer();

  try {
    // Initialize all services
    await initializeServices(container);

    if (kDebugMode) {
      print('✅ Services initialized successfully');
    }
  } catch (e, stackTrace) {
    // Log initialization error but continue
    if (kDebugMode) {
      print('⚠️ Initialization error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch settings for theme
    final settingsState = ref.watch(settingsProvider);
    final themeMode = settingsState.settings.themeMode;

    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _getThemeMode(themeMode),
      home: const HomeScreen(),
    );
  }

  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
      case 'amoled':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
