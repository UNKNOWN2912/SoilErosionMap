import 'package:latlong2/latlong.dart';
import '../../core/constants/rusle_constants.dart';
import '../../data/models/custom_roi_model.dart';
import '../../data/models/district_erosion_model.dart';
import '../../data/models/satellite_layer_config.dart';
import '../../data/models/taluk_erosion_model.dart';

/// Supported spatial granularity view modes
enum GranularityLevel {
  district('District Level (14 Districts)', 'Regional state-wide administrative overview', '🏛️'),
  taluk('Taluk Level (61 Sub-Regions)', 'High-precision micro-topographic zonal modeling', '🔬');

  final String title;
  final String description;
  final String emoji;
  const GranularityLevel(this.title, this.description, this.emoji);
}

/// Immutable state container for the map viewer, active filters,
/// selected district, taluk, custom ROI, time slider, and satellite layer configuration.
class MapState {
  final GranularityLevel granularity;
  final DistrictErosionModel? selectedDistrict;
  final DistrictErosionModel? hoveredDistrict;
  final TalukErosionModel? selectedTaluk;
  final TalukErosionModel? hoveredTaluk;
  final String searchQuery;
  final String activeYear;
  final bool isPlayingTimeline;
  final Set<String> activeCategories;
  final SatelliteLayerConfig layerConfig;
  final String selectedDataSourceMode; // 'bundled', 'gee_proxy', 'bhuvan_wms'
  final bool isConnected;
  final int cachedItemsCount;
  final double simulatedPValue;

  // Custom Area of Interest (ROI) selection
  final bool isRoiToolActive;
  final LatLng? customRoiCenter;
  final double customRoiRadiusKm;
  final CustomRoiStats? customRoiStats;

  const MapState({
    this.granularity = GranularityLevel.district,
    this.selectedDistrict,
    this.hoveredDistrict,
    this.selectedTaluk,
    this.hoveredTaluk,
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
    this.isRoiToolActive = false,
    this.customRoiCenter,
    this.customRoiRadiusKm = 10.0,
    this.customRoiStats,
  });

  MapState copyWith({
    GranularityLevel? granularity,
    DistrictErosionModel? Function()? selectedDistrict,
    DistrictErosionModel? Function()? hoveredDistrict,
    TalukErosionModel? Function()? selectedTaluk,
    TalukErosionModel? Function()? hoveredTaluk,
    String? searchQuery,
    String? activeYear,
    bool? isPlayingTimeline,
    Set<String>? activeCategories,
    SatelliteLayerConfig? layerConfig,
    String? selectedDataSourceMode,
    bool? isConnected,
    int? cachedItemsCount,
    double? simulatedPValue,
    bool? isRoiToolActive,
    LatLng? Function()? customRoiCenter,
    double? customRoiRadiusKm,
    CustomRoiStats? Function()? customRoiStats,
  }) {
    return MapState(
      granularity: granularity ?? this.granularity,
      selectedDistrict: selectedDistrict != null ? selectedDistrict() : this.selectedDistrict,
      hoveredDistrict: hoveredDistrict != null ? hoveredDistrict() : this.hoveredDistrict,
      selectedTaluk: selectedTaluk != null ? selectedTaluk() : this.selectedTaluk,
      hoveredTaluk: hoveredTaluk != null ? hoveredTaluk() : this.hoveredTaluk,
      searchQuery: searchQuery ?? this.searchQuery,
      activeYear: activeYear ?? this.activeYear,
      isPlayingTimeline: isPlayingTimeline ?? this.isPlayingTimeline,
      activeCategories: activeCategories ?? this.activeCategories,
      layerConfig: layerConfig ?? this.layerConfig,
      selectedDataSourceMode: selectedDataSourceMode ?? this.selectedDataSourceMode,
      isConnected: isConnected ?? this.isConnected,
      cachedItemsCount: cachedItemsCount ?? this.cachedItemsCount,
      simulatedPValue: simulatedPValue ?? this.simulatedPValue,
      isRoiToolActive: isRoiToolActive ?? this.isRoiToolActive,
      customRoiCenter: customRoiCenter != null ? customRoiCenter() : this.customRoiCenter,
      customRoiRadiusKm: customRoiRadiusKm ?? this.customRoiRadiusKm,
      customRoiStats: customRoiStats != null ? customRoiStats() : this.customRoiStats,
    );
  }
}
