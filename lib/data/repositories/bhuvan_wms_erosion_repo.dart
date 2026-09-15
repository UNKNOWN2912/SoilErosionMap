import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../datasources/hive_cache_service.dart';
import '../models/district_erosion_model.dart';
import 'bundled_erosion_repo.dart';
import 'erosion_repository.dart';

/// Repository that connects to ISRO Bhuvan (National Remote Sensing Centre - NRSC)
/// Land Degradation & Soil Erosion WMS/WFS layers.
class BhuvanWmsErosionRepository implements ErosionRepository {
  final Dio _dio;
  final BundledErosionRepository _fallbackRepo;

  // ===========================================================================
  // FLAG: [API ENDPOINT & CREDENTIALS CONFIGURATION]
  // In production, supply your ISRO Bhuvan WFS/WMS layer URL and user security token.
  // Bhuvan documentation: https://bhuvan.nrsc.gov.in/bhuvan_links.php
  // Example: 'https://bhuvan-vec1.nrsc.gov.in/bhuvan/wfs?service=WFS&version=1.0.0...'
  // See tools/bhuvan_wms_proxy.py for the backend proxy script.
  // ===========================================================================
  static const String defaultWmsUrl =
      'https://bhuvan-vec1.nrsc.gov.in/bhuvan/wms';
  static const String defaultWfsUrl =
      'https://bhuvan-vec1.nrsc.gov.in/bhuvan/wfs?service=WFS&request=GetFeature&typeName=bhuvan:soil_erosion_kerala&outputFormat=application/json';

  BhuvanWmsErosionRepository({Dio? dio, BundledErosionRepository? fallbackRepo})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
            )),
        _fallbackRepo = fallbackRepo ?? BundledErosionRepository();

  String get currentWfsUrl {
    return (HiveCacheService.getSetting('bhuvan_wfs_url', defaultValue: defaultWfsUrl) as String?) ??
        defaultWfsUrl;
  }

  String? get currentBhuvanToken {
    // FLAG: [API KEY] ISRO Bhuvan access token / authorization header
    return HiveCacheService.getSetting('bhuvan_token') as String?;
  }

  @override
  String get sourceDisplayName => 'ISRO Bhuvan Geoportal (NRSC)';

  @override
  bool get isLiveSource => true;

  @override
  Future<List<DistrictErosionModel>> getDistricts({String? year}) async {
    try {
      final token = currentBhuvanToken;
      final options = Options(
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final response = await _dio.get(currentWfsUrl, options: options);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null;

        if (data != null && data['features'] is List) {
          final List<DistrictErosionModel> bhuvanDistricts = [];
          for (final f in data['features']) {
            if (f is Map<String, dynamic>) {
              bhuvanDistricts.add(DistrictErosionModel.fromGeoJsonFeature(
                f,
                isSample: false,
                sourceName: 'Live ISRO Bhuvan (NRSC Land Degradation)',
              ));
            }
          }
          if (bhuvanDistricts.isNotEmpty) {
            return bhuvanDistricts;
          }
        }
      }
    } catch (e) {
      debugPrint('Bhuvan WFS fetch failed: $e. Falling back to bundled dataset.');
    }

    return _fallbackRepo.getDistricts(year: year);
  }

  @override
  Future<DistrictErosionModel?> getDistrictById(String id) async {
    final list = await getDistricts();
    try {
      return list.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> checkConnection() async {
    try {
      final res = await _dio.get(
        currentWfsUrl,
        options: Options(validateStatus: (status) => status != null && status < 500),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
