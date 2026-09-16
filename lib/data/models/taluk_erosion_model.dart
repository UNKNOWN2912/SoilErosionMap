import '../../core/constants/rusle_constants.dart';
import '../../core/utils/geojson_parser.dart';
import 'rusle_factors_model.dart';
import 'time_series_record.dart';

/// Represents a high-precision sub-district (Taluk) soil erosion profile,
/// localized slope angle, elevation, and micro-topographic RUSLE modeling.
class TalukErosionModel {
  final String id;
  final String talukName;
  final String malayalamName;
  final String districtName;
  final double elevationMeters;
  final double slopeDegrees;
  final double areaSqKm;
  final String dominantLandUse;
  final String soilType;
  final RusleFactorsModel rusleFactors;
  final String riskCategory;
  final Map<String, TimeSeriesRecord> timeSeries;
  final List<String> conservationMeasures;
  final DistrictGeometry geometry;
  final bool isSampleData;

  const TalukErosionModel({
    required this.id,
    required this.talukName,
    required this.malayalamName,
    required this.districtName,
    required this.elevationMeters,
    required this.slopeDegrees,
    required this.areaSqKm,
    required this.dominantLandUse,
    required this.soilType,
    required this.rusleFactors,
    required this.riskCategory,
    required this.timeSeries,
    required this.conservationMeasures,
    required this.geometry,
    required this.isSampleData,
  });

  double getScoreForYear(String year) {
    if (timeSeries.containsKey(year)) {
      return timeSeries[year]!.soilLossScore;
    }
    return rusleFactors.calculatedLoss;
  }

  String getCategoryForYear(String year) {
    if (timeSeries.containsKey(year)) {
      return timeSeries[year]!.riskCategory;
    }
    return riskCategory;
  }

  factory TalukErosionModel.fromGeoJsonFeature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometryJson = feature['geometry'] as Map<String, dynamic>? ?? {};

    final talukName = (props['taluk_name'] ?? props['TALUK'] ?? 'Unknown').toString();
    final districtName = (props['district_name'] ?? props['DISTRICT'] ?? 'Unknown').toString();
    final id = '${districtName}_$talukName'.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final ml = (props['malayalam_name'] ?? talukName).toString();
    final elev = (props['elevation_m'] as num?)?.toDouble() ?? 100.0;
    final slope = (props['slope_degrees'] as num?)?.toDouble() ?? 5.0;
    final areaDeg = (props['Shape_Area'] as num?)?.toDouble() ?? 0.05;
    final areaKm = areaDeg * 12300.0; // Approximation from degree^2 to km^2 for Kerala latitudes

    final landUse = (props['dominant_land_use'] ?? 'Mixed Agriculture & Plantations').toString();
    final soilType = (props['soil_type'] ?? 'Laterite Soil').toString();

    final rusleMap = props['rusle'] as Map<String, dynamic>? ?? {};
    final rusleFactors = RusleFactorsModel.fromJson(rusleMap);

    final Map<String, TimeSeriesRecord> series = {};
    if (props['time_series'] is Map) {
      final tsMap = props['time_series'] as Map<String, dynamic>;
      tsMap.forEach((year, val) {
        if (val is num) {
          series[year] = TimeSeriesRecord.fromEntry(year, val.toDouble());
        }
      });
    }

    final List<String> tips = [];
    if (props['conservation_measures'] is List) {
      for (final t in props['conservation_measures']) {
        tips.add(t.toString());
      }
    }

    final geometry = GeoJsonParser.parseGeometry(geometryJson);
    final riskCategory = (props['risk_category'] ?? RusleConstants.categorize(rusleFactors.calculatedLoss)).toString();

    return TalukErosionModel(
      id: id,
      talukName: talukName,
      malayalamName: ml,
      districtName: districtName,
      elevationMeters: elev,
      slopeDegrees: slope,
      areaSqKm: areaKm,
      dominantLandUse: landUse,
      soilType: soilType,
      rusleFactors: rusleFactors,
      riskCategory: riskCategory,
      timeSeries: series,
      conservationMeasures: tips,
      geometry: geometry,
      isSampleData: true,
    );
  }
}
