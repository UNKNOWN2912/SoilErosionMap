import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../models/district_erosion_model.dart';
import '../models/taluk_erosion_model.dart';

/// Loads and decodes bundled Kerala district and taluk GeoJSON assets.
class LocalGeoJsonSource {
  final String assetPath;

  LocalGeoJsonSource({this.assetPath = AppConstants.bundledGeoJsonPath});

  Future<List<DistrictErosionModel>> loadBundledDistricts() async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];

      final List<DistrictErosionModel> districts = [];
      for (final f in features) {
        if (f is Map<String, dynamic>) {
          districts.add(DistrictErosionModel.fromGeoJsonFeature(
            f,
            isSample: true,
            sourceName: 'Sample Kerala GeoJSON (ISRO Bhuvan / GEE RUSLE)',
          ));
        }
      }
      return districts;
    } catch (e) {
      throw Exception('Failed to parse bundled GeoJSON at $assetPath: $e');
    }
  }

  Future<List<TalukErosionModel>> loadBundledTaluks({
    String talukAssetPath = 'assets/data/kerala_taluks.geojson',
  }) async {
    try {
      final jsonString = await rootBundle.loadString(talukAssetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];

      final List<TalukErosionModel> taluks = [];
      for (final f in features) {
        if (f is Map<String, dynamic>) {
          taluks.add(TalukErosionModel.fromGeoJsonFeature(f));
        }
      }
      return taluks;
    } catch (e) {
      throw Exception('Failed to parse bundled taluks GeoJSON at $talukAssetPath: $e');
    }
  }
}
