import 'package:flutter/material.dart';

/// Earthy and environmental color palette inspired by Kerala's geography:
/// Western Ghats evergreen forests, midland laterite soils, coastal backwaters,
/// and agricultural paddy fields.
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color forestGreen = Color(0xFF1B4D3E);
  static const Color forestGreenDark = Color(0xFF0F2E25);
  static const Color forestGreenLight = Color(0xFF2D6A56);
  static const Color lateriteTerracotta = Color(0xFFC2593F);
  static const Color ochreClay = Color(0xFFD48B38);
  static const Color riverTeal = Color(0xFF16A085);
  static const Color warmSand = Color(0xFFF7F5EE);

  // Background and surface colors
  static const Color darkBackground = Color(0xFF0F1411);
  static const Color darkSurface = Color(0xFF17201C);
  static const Color darkCard = Color(0xFF1F2B26);
  static const Color darkBorder = Color(0xFF2C3E36);

  static const Color lightBackground = Color(0xFFF9F8F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF4F1EC);
  static const Color lightBorder = Color(0xFFE2DDD5);

  // RUSLE Soil Erosion Severity scale
  static const Color riskLow = Color(0xFF2ECC71);        // < 5 t/ha/yr (Green)
  static const Color riskModerate = Color(0xFFF1C40F);   // 5 - 10 t/ha/yr (Yellow)
  static const Color riskHigh = Color(0xFFE67E22);       // 10 - 20 t/ha/yr (Orange)
  static const Color riskSevere = Color(0xFFE74C3C);     // 20 - 40 t/ha/yr (Crimson Red)
  static const Color riskVerySevere = Color(0xFF8E44AD); // > 40 t/ha/yr (Deep Purple/Maroon)

  // Satellite and sensor indicator badges
  static const Color sentinelBlue = Color(0xFF3498DB);
  static const Color isroSaffron = Color(0xFFFF9933);
  static const Color srtmBrown = Color(0xFF8D6E63);
  static const Color ndviGreen = Color(0xFF00E676);

  /// Return corresponding color for erosion risk score in t/ha/year
  static Color colorForErosionScore(double score) {
    if (score < 5.0) return riskLow;
    if (score < 10.0) return riskModerate;
    if (score < 20.0) return riskHigh;
    if (score < 40.0) return riskSevere;
    return riskVerySevere;
  }

  /// Return corresponding color for risk category string
  static Color colorForCategory(String category) {
    switch (category.toLowerCase().trim()) {
      case 'low':
        return riskLow;
      case 'moderate':
        return riskModerate;
      case 'high':
        return riskHigh;
      case 'severe':
        return riskSevere;
      case 'very severe':
        return riskVerySevere;
      default:
        return Colors.grey;
    }
  }
}
