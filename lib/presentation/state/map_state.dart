import '../../core/constants/rusle_constants.dart';
import '../../data/models/district_erosion_model.dart';
import '../../data/models/satellite_layer_config.dart';

/// Immutable state container for the map viewer, active filters,
/// selected district, time slider, and satellite layer configuration.
class MapState {
  final DistrictErosionModel? selectedDistrict;
  final DistrictErosionModel? hoveredDistrict;
  final String searchQuery;
  final String activeYear;
  final bool isPlayingTimeline;
  final Set<String> activeCategories;
  final SatelliteLayerConfig layerConfig;
  final String selectedDataSourceMode; // 'bundled', 'gee_proxy', 'bhuvan_wms'
  final bool isConnected;
  final int cachedItemsCount;
  final double simulatedPValue;

  const MapState({
    this.selectedDistrict,
    this.hoveredDistrict,
    this.searchQuery = '',
    this.activeYear = RusleConstants.defaultYear,
    this.isPlayingTimeline = false,
    this.activeCategories = const {
      RusleConstants.categoryLow,
      RusleConstants.categoryModerate,
      RusleConstants.categoryHigh,
      RusleConstants.categorySevere,
      RusleConstants.categoryVerySevere,
    },
    this.layerConfig = const SatelliteLayerConfig(),
    this.selectedDataSourceMode = 'bundled',
    this.isConnected = true,
    this.cachedItemsCount = 14,
    this.simulatedPValue = 0.7,
  });

  MapState copyWith({
    DistrictErosionModel? Function()? selectedDistrict,
    DistrictErosionModel? Function()? hoveredDistrict,
    String? searchQuery,
    String? activeYear,
    bool? isPlayingTimeline,
    Set<String>? activeCategories,
    SatelliteLayerConfig? layerConfig,
    String? selectedDataSourceMode,
    bool? isConnected,
    int? cachedItemsCount,
    double? simulatedPValue,
  }) {
    return MapState(
      selectedDistrict: selectedDistrict != null ? selectedDistrict() : this.selectedDistrict,
      hoveredDistrict: hoveredDistrict != null ? hoveredDistrict() : this.hoveredDistrict,
      searchQuery: searchQuery ?? this.searchQuery,
      activeYear: activeYear ?? this.activeYear,
      isPlayingTimeline: isPlayingTimeline ?? this.isPlayingTimeline,
      activeCategories: activeCategories ?? this.activeCategories,
      layerConfig: layerConfig ?? this.layerConfig,
      selectedDataSourceMode: selectedDataSourceMode ?? this.selectedDataSourceMode,
      isConnected: isConnected ?? this.isConnected,
      cachedItemsCount: cachedItemsCount ?? this.cachedItemsCount,
      simulatedPValue: simulatedPValue ?? this.simulatedPValue,
    );
  }
}
