import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Application theme definitions using Material 3 and Kerala-inspired earthy tones.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.forestGreenLight,
        onPrimary: Colors.white,
        secondary: AppColors.lateriteTerracotta,
        onSecondary: Colors.white,
        tertiary: AppColors.ochreClay,
        surface: AppColors.darkSurface,
        onSurface: Color(0xFFECEFF1),
        background: AppColors.darkBackground,
        onBackground: Color(0xFFECEFF1),
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(letterSpacing: 0.2),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forestGreen,
        onPrimary: Colors.white,
        secondary: AppColors.lateriteTerracotta,
        onSecondary: Colors.white,
        tertiary: AppColors.ochreClay,
        surface: AppColors.lightSurface,
        onSurface: Color(0xFF1B2421),
        background: AppColors.lightBackground,
        onBackground: Color(0xFF1B2421),
        outline: AppColors.lightBorder,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: Color(0xFF1B2421),
        elevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(letterSpacing: 0.2),
      ),
    );
  }
}
