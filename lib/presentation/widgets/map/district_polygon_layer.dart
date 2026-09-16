import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../../data/models/satellite_layer_config.dart';
import '../../../data/models/taluk_erosion_model.dart';

/// Builds colored choropleth polygon overlays for all Kerala districts and taluks
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

  static List<Polygon<Object>> buildTalukPolygons({
    required List<TalukErosionModel> taluks,
    required TalukErosionModel? selectedTaluk,
    required TalukErosionModel? hoveredTaluk,
    required String activeYear,
    required SatelliteLayerConfig config,
  }) {
    final List<Polygon<Object>> polygons = [];

    for (final taluk in taluks) {
      final isSelected = selectedTaluk?.id == taluk.id;
      final isHovered = hoveredTaluk?.id == taluk.id;

      final baseColor = _getTalukColorForLayer(taluk, activeYear, config.activeLayer);
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

      final borderWidth = isSelected ? 3.5 : (isHovered ? 2.2 : 0.9);

      for (final ring in taluk.geometry.polygonRings) {
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
        final c = district.rusleFactors.cFactor;
        if (c < 0.10) return const Color(0xFF00E676);
        if (c < 0.15) return const Color(0xFF66BB6A);
        if (c < 0.20) return const Color(0xFFAED581);
        return const Color(0xFFFFD54F);

      case SatelliteLayerType.rainfall:
        final r = district.rusleFactors.rFactor;
        if (r > 5000) return const Color(0xFF0D47A1);
        if (r > 3500) return const Color(0xFF1976D2);
        if (r > 2500) return const Color(0xFF42A5F5);
        return const Color(0xFF81D4FA);

      case SatelliteLayerType.elevation:
        final ls = district.rusleFactors.lsFactor;
        if (ls > 14.0) return const Color(0xFF8E44AD);
        if (ls > 8.0) return const Color(0xFFD35400);
        if (ls > 4.0) return const Color(0xFFE67E22);
        return const Color(0xFFF39C12);
    }
  }

  static Color _getTalukColorForLayer(
    TalukErosionModel taluk,
    String year,
    SatelliteLayerType layerType,
  ) {
    switch (layerType) {
      case SatelliteLayerType.soilErosion:
        final score = taluk.getScoreForYear(year);
        return AppColors.colorForErosionScore(score);

      case SatelliteLayerType.ndvi:
        final c = taluk.rusleFactors.cFactor;
        if (c < 0.10) return const Color(0xFF00E676);
        if (c < 0.15) return const Color(0xFF66BB6A);
        if (c < 0.20) return const Color(0xFFAED581);
        return const Color(0xFFFFD54F);

      case SatelliteLayerType.rainfall:
        final r = taluk.rusleFactors.rFactor;
        if (r > 5500) return const Color(0xFF0D47A1);
        if (r > 3500) return const Color(0xFF1976D2);
        if (r > 2500) return const Color(0xFF42A5F5);
        return const Color(0xFF81D4FA);

      case SatelliteLayerType.elevation:
        final slope = taluk.slopeDegrees;
        if (slope > 20.0) return const Color(0xFF8E44AD);
        if (slope > 12.0) return const Color(0xFFD35400);
        if (slope > 5.0) return const Color(0xFFE67E22);
        return const Color(0xFFF39C12);
    }
  }
}
