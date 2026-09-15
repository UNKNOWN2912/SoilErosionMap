import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/hive_cache_service.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline caching service with Hive
  await HiveCacheService.init();

  runApp(
    const ProviderScope(
      child: KeralaSoilErosionApp(),
    ),
  );
}

class KeralaSoilErosionApp extends StatelessWidget {
  const KeralaSoilErosionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to sleek dark map theme
      home: const HomeScreen(),
    );
  }
}
