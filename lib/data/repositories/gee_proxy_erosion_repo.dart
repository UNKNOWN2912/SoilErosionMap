import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../datasources/hive_cache_service.dart';
import '../models/district_erosion_model.dart';
import '../models/taluk_erosion_model.dart';
import 'bundled_erosion_repo.dart';
import 'erosion_repository.dart';

/// Repository that connects to a live Google Earth Engine (GEE) backend proxy.
/// The backend computes live RUSLE (A = R * K * LS * C * P) from Sentinel-2 MSI,
/// SRTM DEM, and CHIRPS rainfall, exporting dynamic GeoJSON polygons.
class GeeProxyErosionRepository implements ErosionRepository {
  final Dio _dio;
  final BundledErosionRepository _fallbackRepo;

  // ===========================================================================
  // FLAG: [API ENDPOINT & CREDENTIALS CONFIGURATION]
  // In production, supply your Google Earth Engine proxy server URL and authorization
  // token here or via the in-app Data Source Switcher dialog.
  // Example: 'https://gee-kerala-proxy.internal.domain/api/v1/erosion/districts'
  // See tools/gee_rusle_processor.py for the backend script.
  // ===========================================================================
  static const String defaultEndpoint = 'http://localhost:8000/api/v1/erosion/kerala-districts';

  GeeProxyErosionRepository({Dio? dio, BundledErosionRepository? fallbackRepo})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
            )),
        _fallbackRepo = fallbackRepo ?? BundledErosionRepository();

  String get currentEndpoint {
    return (HiveCacheService.getSetting('gee_proxy_url', defaultValue: defaultEndpoint) as String?) ??
        defaultEndpoint;
  }

  String? get currentApiKey {
    // FLAG: [API KEY] GEE Proxy Authorization Bearer token
    return HiveCacheService.getSetting('gee_api_key') as String?;
  }

  @override
  String get sourceDisplayName => 'Google Earth Engine RUSLE Proxy';

  @override
  bool get isLiveSource => true;

  @override
  Future<List<DistrictErosionModel>> getDistricts({String? year}) async {
    try {
      final endpoint = currentEndpoint;
      final apiKey = currentApiKey;

      final options = Options(
        headers: {
          'Accept': 'application/json',
          if (apiKey != null && apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
        },
      );

      final response = await _dio.get(
        endpoint,
        queryParameters: {'year': year ?? '2024'},
        options: options,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null;

        if (data != null && data['features'] is List) {
          final List<DistrictErosionModel> liveDistricts = [];
          for (final f in data['features']) {
            if (f is Map<String, dynamic>) {
              liveDistricts.add(DistrictErosionModel.fromGeoJsonFeature(
                f,
                isSample: false,
                sourceName: 'Live Google Earth Engine (Sentinel-2 / SRTM)',
              ));
            }
          }
          if (liveDistricts.isNotEmpty) {
            return liveDistricts;
          }
        }
      }
    } catch (e) {
      debugPrint('GEE Proxy fetch failed: $e. Falling back to cached bundled data.');
    }

    // Graceful fallback to bundled GeoJSON if proxy is offline or keys not configured
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
  Future<List<TalukErosionModel>> getTaluks({String? districtName, String? year}) async {
    return _fallbackRepo.getTaluks(districtName: districtName, year: year);
  }

  @override
  Future<TalukErosionModel?> getTalukById(String id) async {
    return _fallbackRepo.getTalukById(id);
  }

  @override
  Future<bool> checkConnection() async {
    try {
      final res = await _dio.get(
        currentEndpoint,
        options: Options(validateStatus: (status) => status != null && status < 500),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
