import '../../core/constants/rusle_constants.dart';
import '../../core/utils/geojson_parser.dart';
import 'rusle_factors_model.dart';
import 'time_series_record.dart';

/// Comprehensive entity and data model representing a Kerala district's
/// soil erosion profile, geographic geometry, and environmental metrics.
class DistrictErosionModel {
  final String id;
  final String districtName;
  final String malayalamName;
  final String headquarters;
  final double areaSqKm;
  final String dominantLandUse;
  final String soilType;
  final String terrainCategory;
  final List<String> taluks;
  final RusleFactorsModel rusleFactors;
  final String riskCategory;
  final Map<String, TimeSeriesRecord> timeSeries;
  final List<String> conservationMeasures;
  final DistrictGeometry geometry;
  final String dataSource;
  final DateTime timestamp;
  final bool isSampleData;

  const DistrictErosionModel({
    required this.id,
    required this.districtName,
    required this.malayalamName,
    required this.headquarters,
    required this.areaSqKm,
    required this.dominantLandUse,
    required this.soilType,
    required this.terrainCategory,
    required this.taluks,
    required this.rusleFactors,
    required this.riskCategory,
    required this.timeSeries,
    required this.conservationMeasures,
    required this.geometry,
    required this.dataSource,
    required this.timestamp,
    required this.isSampleData,
  });

  /// Get average erosion score for the currently selected observation year
  double getScoreForYear(String year) {
    if (timeSeries.containsKey(year)) {
      return timeSeries[year]!.soilLossScore;
    }
    return rusleFactors.calculatedLoss;
  }

  /// Get risk category for the currently selected observation year
  String getCategoryForYear(String year) {
    if (timeSeries.containsKey(year)) {
      return timeSeries[year]!.riskCategory;
    }
    return riskCategory;
  }

  /// Factory parser from enriched GeoJSON Feature object
  factory DistrictErosionModel.fromGeoJsonFeature(
    Map<String, dynamic> feature, {
    bool isSample = true,
    String sourceName = 'ISRO Bhuvan / GEE RUSLE (Sample Mode)',
  }) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometryJson = feature['geometry'] as Map<String, dynamic>? ?? {};

    final districtName = (props['DISTRICT'] ?? props['district_name'] ?? 'Unknown').toString();
    final id = districtName.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final malayalamName = (props['malayalam_name'] ?? districtName).toString();
    final hq = (props['hq'] ?? districtName).toString();
    final area = (props['area_sq_km'] as num?)?.toDouble() ?? 2500.0;
    final landUse = (props['dominant_land_use'] ?? 'Mixed Vegetation & Cropland').toString();
    final soilType = (props['soil_type'] ?? 'Laterite Soil').toString();
    final terrain = (props['terrain_category'] ?? 'Undulating Highlands').toString();

    final List<String> taluks = [];
    if (props['taluks'] is List) {
      for (final t in props['taluks']) {
        taluks.add(t.toString());
      }
    }

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

    final List<String> conservation = [];
    if (props['conservation'] is List) {
      for (final c in props['conservation']) {
        conservation.add(c.toString());
      }
    }

    final parsedGeometry = GeoJsonParser.parseGeometry(geometryJson);
    final riskCategory = (props['risk_category'] ?? RusleConstants.categorize(rusleFactors.calculatedLoss)).toString();

    return DistrictErosionModel(
      id: id,
      districtName: districtName,
      malayalamName: malayalamName,
      headquarters: hq,
      areaSqKm: area,
      dominantLandUse: landUse,
      soilType: soilType,
      terrainCategory: terrain,
      taluks: taluks,
      rusleFactors: rusleFactors,
      riskCategory: riskCategory,
      timeSeries: series,
      conservationMeasures: conservation,
      geometry: parsedGeometry,
      dataSource: sourceName,
      timestamp: DateTime.now(),
      isSampleData: isSample,
    );
  }

  /// Create a copy with updated factors
  DistrictErosionModel copyWith({
    RusleFactorsModel? rusleFactors,
    String? dataSource,
    bool? isSampleData,
  }) {
    final updatedRusle = rusleFactors ?? this.rusleFactors;
    return DistrictErosionModel(
      id: id,
      districtName: districtName,
      malayalamName: malayalamName,
      headquarters: headquarters,
      areaSqKm: areaSqKm,
      dominantLandUse: dominantLandUse,
      soilType: soilType,
      terrainCategory: terrainCategory,
      taluks: taluks,
      rusleFactors: updatedRusle,
      riskCategory: RusleConstants.categorize(updatedRusle.calculatedLoss),
      timeSeries: timeSeries,
      conservationMeasures: conservationMeasures,
      geometry: geometry,
      dataSource: dataSource ?? this.dataSource,
      timestamp: timestamp,
      isSampleData: isSampleData ?? this.isSampleData,
    );
  }
}
