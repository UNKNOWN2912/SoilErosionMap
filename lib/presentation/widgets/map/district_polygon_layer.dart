import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../../data/models/satellite_layer_config.dart';

/// Builds colored choropleth polygon overlays for all Kerala districts
/// based on active satellite layer, year, opacity, and selection state.
class DistrictPolygonLayerHelper {
  DistrictPolygonLayerHelper._();

  static List<Polygon<Object>> buildPolygons({
    required List<DistrictErosionModel> districts,
    required DistrictErosionModel? selectedDistrict,
    required DistrictErosionModel? hoveredDistrict,
    required String activeYear,
    required SatelliteLayerConfig config,
  }) {
    final List<Polygon<Object>> polygons = [];

    for (final district in districts) {
      final isSelected = selectedDistrict?.id == district.id;
      final isHovered = hoveredDistrict?.id == district.id;

      final baseColor = _getColorForLayer(district, activeYear, config.activeLayer);
      final fillColor = baseColor.withOpacity(
        isSelected ? (config.overlayOpacity * 1.15).clamp(0.0, 1.0) : config.overlayOpacity,
      );

      final borderColor = isSelected
          ? Colors.white
          : (isHovered
              ? Colors.amberAccent
              : (config.showDistrictBoundaries
                  ? (Colors.black.withOpacity(0.45))
                  : Colors.transparent));

      final borderWidth = isSelected ? 3.5 : (isHovered ? 2.5 : 1.2);

      for (final ring in district.geometry.polygonRings) {
        if (ring.length >= 3) {
          polygons.add(
            Polygon<Object>(
              points: ring,
              color: fillColor,
              borderColor: borderColor,
              borderStrokeWidth: borderWidth,
            ),
          );
        }
      }
    }

    return polygons;
  }

  static Color _getColorForLayer(
    DistrictErosionModel district,
    String year,
    SatelliteLayerType layerType,
  ) {
    switch (layerType) {
      case SatelliteLayerType.soilErosion:
        final score = district.getScoreForYear(year);
        return AppColors.colorForErosionScore(score);

      case SatelliteLayerType.ndvi:
        // C factor is inversely proportional to dense vegetation cover:
        // C ~ 0.05 is dense rainforest/tea canopy, C ~ 0.40 is open/disturbed
        final c = district.rusleFactors.cFactor;
        if (c < 0.10) return const Color(0xFF00E676); // High NDVI canopy
        if (c < 0.15) return const Color(0xFF66BB6A); // Moderate vegetative cover
        if (c < 0.20) return const Color(0xFFAED581); // Shrub / open cropland
        return const Color(0xFFFFD54F); // Low NDVI / exposed soil

      case SatelliteLayerType.rainfall:
        final r = district.rusleFactors.rFactor;
        if (r > 5000) return const Color(0xFF0D47A1); // Torrential Ghats rainfall
        if (r > 3500) return const Color(0xFF1976D2); // High monsoon precipitation
        if (r > 2500) return const Color(0xFF42A5F5); // Moderate precipitation
        return const Color(0xFF81D4FA); // Drier Palakkad gap / rainshadow

      case SatelliteLayerType.elevation:
        final ls = district.rusleFactors.lsFactor;
        if (ls > 14.0) return const Color(0xFF8E44AD); // Escarpment > 20 deg
        if (ls > 8.0) return const Color(0xFFD35400); // Steep mountain slopes
        if (ls > 4.0) return const Color(0xFFE67E22); // Midland hills
        return const Color(0xFFF39C12); // Coastal plains / delta
    }
  }
}
