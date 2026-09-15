import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

/// Manages offline caching of satellite responses, GeoJSON data, and user preferences.
class HiveCacheService {
  static Box? _cacheBox;
  static Box? _settingsBox;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox(AppConstants.cacheBoxName);
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
      debugPrint('Hive cache initialized successfully.');
    } catch (e) {
      debugPrint('Hive initialization error: $e');
    }
  }

  // Cache GeoJSON raw string
  static Future<void> cacheGeoJson(String key, String geoJsonString) async {
    try {
      await _cacheBox?.put(key, geoJsonString);
      await _cacheBox?.put('${key}_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error caching GeoJSON: $e');
    }
  }

  static String? getCachedGeoJson(String key) {
    try {
      return _cacheBox?.get(key) as String?;
    } catch (e) {
      return null;
    }
  }

  static String? getCachedTimestamp(String key) {
    try {
      return _cacheBox?.get('${key}_timestamp') as String?;
    } catch (e) {
      return null;
    }
  }

  // Settings & API endpoints storage
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    if (_settingsBox == null) return defaultValue;
    return _settingsBox!.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  static int getCachedItemCount() {
    return _cacheBox?.length ?? 0;
  }

  static Future<void> clearAllCache() async {
    await _cacheBox?.clear();
  }
}
