import '../../core/constants/rusle_constants.dart';

/// Represents a historical erosion record for a given year or monsoon season.
class TimeSeriesRecord {
  final String year;
  final double soilLossScore; // t/ha/year
  final String riskCategory;
  final String? seasonDescription;
  final double? meanNdvi;
  final double? annualRainfallMm;

  const TimeSeriesRecord({
    required this.year,
    required this.soilLossScore,
    required this.riskCategory,
    this.seasonDescription,
    this.meanNdvi,
    this.annualRainfallMm,
  });

  factory TimeSeriesRecord.fromEntry(String year, double score) {
    return TimeSeriesRecord(
      year: year,
      soilLossScore: score,
      riskCategory: RusleConstants.categorize(score),
      seasonDescription: _defaultSeasonForYear(year),
    );
  }

  static String _defaultSeasonForYear(String yr) {
    switch (yr) {
      case '2018':
        return 'Severe Monsoon Floods Surge';
      case '2019':
        return 'Late Monsoon Landslide Pulses';
      case '2020':
        return 'Normal Monsoon Cycle';
      case '2021':
        return 'Extended South-West Monsoon';
      case '2022':
        return 'Moderate Monsoon Cycle';
      case '2023':
        return 'Dry / Deficit Monsoon Phase';
      case '2024':
        return 'High Western Ghats Cloudburst Season';
      default:
        return 'Annual Monsoon Season';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'soilLossScore': soilLossScore,
      'riskCategory': riskCategory,
      'seasonDescription': seasonDescription,
    };
  }
}
