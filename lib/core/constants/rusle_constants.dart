/// Constants, thresholds, and equations for the Revised Universal Soil Loss Equation (RUSLE).
/// Equation: A = R * K * LS * C * P
///
/// Where:
/// - A: Average annual soil loss (metric tons / hectare / year)
/// - R: Rainfall runoff erosivity factor (MJ mm / ha h yr)
/// - K: Soil erodibility factor (t ha h / ha MJ mm)
/// - LS: Slope length and steepness factor (dimensionless)
/// - C: Cover management factor (dimensionless, derived from satellite NDVI)
/// - P: Conservation support practice factor (dimensionless, 0.0 - 1.0)
class RusleConstants {
  RusleConstants._();

  // Erosion Risk Severity Thresholds (t/ha/year)
  static const double thresholdLow = 5.0;
  static const double thresholdModerate = 10.0;
  static const double thresholdHigh = 20.0;
  static const double thresholdSevere = 40.0;

  static const String categoryLow = 'Low';
  static const String categoryModerate = 'Moderate';
  static const String categoryHigh = 'High';
  static const String categorySevere = 'Severe';
  static const String categoryVerySevere = 'Very Severe';

  static const List<String> allCategories = [
    categoryLow,
    categoryModerate,
    categoryHigh,
    categorySevere,
    categoryVerySevere,
  ];

  /// Categorize soil loss score according to standard ICAR & NBSS&LUP soil survey thresholds.
  static String categorize(double soilLoss) {
    if (soilLoss < thresholdLow) return categoryLow;
    if (soilLoss < thresholdModerate) return categoryModerate;
    if (soilLoss < thresholdHigh) return categoryHigh;
    if (soilLoss < thresholdSevere) return categorySevere;
    return categoryVerySevere;
  }

  /// Detailed scientific description for each risk category.
  static String getCategoryDescription(String category) {
    switch (category) {
      case categoryLow:
        return 'Tolerable soil loss (< 5 t/ha/yr). Soil formation rate exceeds or balances sheet erosion. Typical of coastal alluvium and flat lowlands.';
      case categoryModerate:
        return 'Moderate erosion (5 - 10 t/ha/yr). Noticeable topsoil depletion without appropriate conservation covers. Typical of undulating midlands.';
      case categoryHigh:
        return 'High erosion (10 - 20 t/ha/yr). Accelerated rill and gully erosion risk. Significant loss of organic matter and topsoil nutrients.';
      case categorySevere:
        return 'Severe erosion (20 - 40 t/ha/yr). Critical soil degradation hazard. Prone to mass wasting, heavy gullying, and watershed sediment loading.';
      case categoryVerySevere:
        return 'Very severe / catastrophic (> 40 t/ha/yr). Extreme landslide and topsoil stripping vulnerability on steep Western Ghats slopes under torrential monsoon rains.';
      default:
        return 'Unknown erosion classification.';
    }
  }

  /// Available satellite layer view modes
  static const String layerSoilErosion = 'erosion';
  static const String layerNdvi = 'ndvi';
  static const String layerRainfall = 'rainfall';
  static const String layerElevation = 'elevation';
  static const String layerSatelliteBase = 'satellite_base';

  // Supported historical observation years
  static const List<String> availableYears = [
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
  ];

  static const String defaultYear = '2024';
}
