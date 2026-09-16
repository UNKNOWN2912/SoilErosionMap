import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/rusle_constants.dart';
import '../../data/datasources/hive_cache_service.dart';
import '../../data/models/custom_roi_model.dart';
import '../../data/models/district_erosion_model.dart';
import '../../data/models/satellite_layer_config.dart';
import '../../data/models/taluk_erosion_model.dart';
import '../../data/repositories/bhuvan_wms_erosion_repo.dart';
import '../../data/repositories/bundled_erosion_repo.dart';
import '../../data/repositories/erosion_repository.dart';
import '../../data/repositories/gee_proxy_erosion_repo.dart';
import '../../domain/usecases/filter_districts.dart';
import 'map_state.dart';

// Repositories
final bundledRepoProvider = Provider<ErosionRepository>((ref) => BundledErosionRepository());
final geeRepoProvider = Provider<ErosionRepository>((ref) => GeeProxyErosionRepository());
final bhuvanRepoProvider = Provider<ErosionRepository>((ref) => BhuvanWmsErosionRepository());

final activeRepoProvider = Provider<ErosionRepository>((ref) {
  final mode = ref.watch(mapStateNotifierProvider.select((s) => s.selectedDataSourceMode));
  switch (mode) {
    case 'gee_proxy':
      return ref.watch(geeRepoProvider);
    case 'bhuvan_wms':
      return ref.watch(bhuvanRepoProvider);
    default:
      return ref.watch(bundledRepoProvider);
  }
});

// Districts AsyncProvider
final districtsDataProvider = FutureProvider<List<DistrictErosionModel>>((ref) async {
  final repo = ref.watch(activeRepoProvider);
  final year = ref.watch(mapStateNotifierProvider.select((s) => s.activeYear));
  return repo.getDistricts(year: year);
});

// Taluks AsyncProvider (61 Sub-Regions)
final taluksDataProvider = FutureProvider<List<TalukErosionModel>>((ref) async {
  final repo = ref.watch(activeRepoProvider);
  final year = ref.watch(mapStateNotifierProvider.select((s) => s.activeYear));
  return repo.getTaluks(year: year);
});

// Use cases
final filterDistrictsUseCaseProvider = Provider<FilterDistricts>((ref) => const FilterDistricts());

// MapStateNotifier
class MapStateNotifier extends StateNotifier<MapState> {
  Timer? _playbackTimer;

  MapStateNotifier()
      : super(MapState(
          selectedDataSourceMode:
              (HiveCacheService.getSetting('data_source_mode', defaultValue: 'bundled') as String?) ?? 'bundled',
          cachedItemsCount: HiveCacheService.getCachedItemCount(),
        ));

  void setGranularity(GranularityLevel level) {
    state = state.copyWith(
      granularity: level,
      selectedDistrict: () => null,
      selectedTaluk: () => null,
    );
  }

  void selectDistrict(DistrictErosionModel? district) {
    state = state.copyWith(
      selectedDistrict: () => district,
      selectedTaluk: () => null,
      simulatedPValue: district?.rusleFactors.pFactor ?? 0.7,
    );
  }

  void hoverDistrict(DistrictErosionModel? district) {
    if (state.hoveredDistrict?.id != district?.id) {
      state = state.copyWith(hoveredDistrict: () => district);
    }
  }

  void selectTaluk(TalukErosionModel? taluk) {
    state = state.copyWith(
      selectedTaluk: () => taluk,
      selectedDistrict: () => null,
      simulatedPValue: taluk?.rusleFactors.pFactor ?? 0.7,
    );
  }

  void hoverTaluk(TalukErosionModel? taluk) {
    if (state.hoveredTaluk?.id != taluk?.id) {
      state = state.copyWith(hoveredTaluk: () => taluk);
    }
  }

  void toggleRoiTool(bool? active) {
    final next = active ?? !state.isRoiToolActive;
    state = state.copyWith(
      isRoiToolActive: next,
      customRoiCenter: () => next ? state.customRoiCenter : null,
      customRoiStats: () => next ? state.customRoiStats : null,
    );
  }

  void setCustomRoi({
    required LatLng center,
    required double radiusKm,
    required List<TalukErosionModel> allTaluks,
  }) {
    final stats = CustomRoiStats.calculate(
      center: center,
      radiusKm: radiusKm,
      allTaluks: allTaluks,
      activeYear: state.activeYear,
    );

    state = state.copyWith(
      isRoiToolActive: true,
      customRoiCenter: () => center,
      customRoiRadiusKm: radiusKm,
      customRoiStats: () => stats,
    );
  }

  void clearCustomRoi() {
    state = state.copyWith(
      customRoiCenter: () => null,
      customRoiStats: () => null,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void setYear(String year) {
    state = state.copyWith(activeYear: year);
    // Recalculate ROI stats if active
    if (state.customRoiCenter != null) {
      // Re-trigger ROI calculation on year change
    }
  }

  void toggleTimelinePlayback() {
    if (state.isPlayingTimeline) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    state = state.copyWith(isPlayingTimeline: true);
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      final years = RusleConstants.availableYears;
      final currentIndex = years.indexOf(state.activeYear);
      final nextIndex = (currentIndex + 1) % years.length;
      state = state.copyWith(activeYear: years[nextIndex]);
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    state = state.copyWith(isPlayingTimeline: false);
  }

  void toggleCategory(String category) {
    final updated = Set<String>.from(state.activeCategories);
    if (updated.contains(category)) {
      if (updated.length > 1) {
        updated.remove(category);
      }
    } else {
      updated.add(category);
    }
    state = state.copyWith(activeCategories: updated);
  }

  void resetCategories() {
    state = state.copyWith(activeCategories: Set.from(RusleConstants.allCategories));
  }

  void setActiveLayer(SatelliteLayerType layer) {
    state = state.copyWith(
      layerConfig: state.layerConfig.copyWith(activeLayer: layer),
    );
  }

  void setActiveBasemap(BasemapType basemap) {
    state = state.copyWith(
      layerConfig: state.layerConfig.copyWith(activeBasemap: basemap),
    );
  }

  void setOverlayOpacity(double opacity) {
    state = state.copyWith(
      layerConfig: state.layerConfig.copyWith(overlayOpacity: opacity),
    );
  }

  void toggleBoundaries(bool show) {
    state = state.copyWith(
      layerConfig: state.layerConfig.copyWith(showDistrictBoundaries: show),
    );
  }

  void toggleHotspots(bool show) {
    state = state.copyWith(
      layerConfig: state.layerConfig.copyWith(showHotspotMarkers: show),
    );
  }

  void setDataSourceMode(String mode) {
    HiveCacheService.saveSetting('data_source_mode', mode);
    state = state.copyWith(selectedDataSourceMode: mode);
  }

  void setSimulatedP(double val) {
    state = state.copyWith(simulatedPValue: val);
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}

final mapStateNotifierProvider = StateNotifierProvider<MapStateNotifier, MapState>((ref) {
  return MapStateNotifier();
});

// Filtered Districts Provider
final filteredDistrictsProvider = Provider<List<DistrictErosionModel>>((ref) {
  final asyncDistricts = ref.watch(districtsDataProvider);
  final mapState = ref.watch(mapStateNotifierProvider);
  final filterUseCase = ref.watch(filterDistrictsUseCaseProvider);

  return asyncDistricts.maybeWhen(
    data: (districts) => filterUseCase.execute(
      allDistricts: districts,
      searchQuery: mapState.searchQuery,
      activeCategories: mapState.activeCategories,
      activeYear: mapState.activeYear,
    ),
    orElse: () => [],
  );
});

// Filtered Taluks Provider (61 Sub-Regions)
final filteredTaluksProvider = Provider<List<TalukErosionModel>>((ref) {
  final asyncTaluks = ref.watch(taluksDataProvider);
  final mapState = ref.watch(mapStateNotifierProvider);

  return asyncTaluks.maybeWhen(
    data: (taluks) {
      final query = mapState.searchQuery.toLowerCase().trim();
      return taluks.where((t) {
        // 1. Search query match
        if (query.isNotEmpty) {
          final matchTaluk = t.talukName.toLowerCase().contains(query);
          final matchDistrict = t.districtName.toLowerCase().contains(query);
          final matchMl = t.malayalamName.contains(query);
          if (!matchTaluk && !matchDistrict && !matchMl) return false;
        }

        // 2. Risk category match
        final cat = t.getCategoryForYear(mapState.activeYear);
        if (mapState.activeCategories.isNotEmpty && !mapState.activeCategories.contains(cat)) {
          return false;
        }

        return true;
      }).toList();
    },
    orElse: () => [],
  );
});
