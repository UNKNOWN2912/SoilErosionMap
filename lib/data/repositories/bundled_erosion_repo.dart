import '../datasources/local_geojson_source.dart';
import '../models/district_erosion_model.dart';
import 'erosion_repository.dart';

/// Default offline-first repository utilizing pre-processed and research-backed
/// Kerala district boundaries and RUSLE parameters.
class BundledErosionRepository implements ErosionRepository {
  final LocalGeoJsonSource _localSource;
  List<DistrictErosionModel>? _cachedMemoryDistricts;

  BundledErosionRepository({LocalGeoJsonSource? localSource})
      : _localSource = localSource ?? LocalGeoJsonSource();

  @override
  String get sourceDisplayName => 'Bundled GeoJSON (Demo Data Mode)';

  @override
  bool get isLiveSource => false;

  @override
  Future<List<DistrictErosionModel>> getDistricts({String? year}) async {
    if (_cachedMemoryDistricts != null && _cachedMemoryDistricts!.isNotEmpty) {
      return _cachedMemoryDistricts!;
    }
    final loaded = await _localSource.loadBundledDistricts();
    _cachedMemoryDistricts = loaded;
    return loaded;
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
    // Local asset and cache are always available offline
    return true;
  }
}
