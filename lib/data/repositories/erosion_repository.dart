import '../models/district_erosion_model.dart';

/// Swappable repository interface for fetching Kerala soil erosion datasets.
/// Implementations can source from bundled GeoJSON, a Python/Node GEE proxy backend,
/// or ISRO Bhuvan OGC services.
abstract class ErosionRepository {
  /// Fetch all districts with their RUSLE parameters and geometry
  Future<List<DistrictErosionModel>> getDistricts({String? year});

  /// Fetch a single district by its unique ID
  Future<DistrictErosionModel?> getDistrictById(String id);

  /// Health check or connection verification for the data source
  Future<bool> checkConnection();

  /// Human-readable label for the current data source
  String get sourceDisplayName;

  /// Whether this repository is currently connected to a live satellite backend or using sample/offline data
  bool get isLiveSource;
}
