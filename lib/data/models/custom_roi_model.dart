import 'package:latlong2/latlong.dart';
import '../../core/constants/rusle_constants.dart';
import 'taluk_erosion_model.dart';

/// Zonal statistics calculated for a user-selected custom Region of Interest (ROI).
class CustomRoiStats {
  final double areaSqKm;
  final double meanLoss; // t/ha/yr
  final double minLoss;
  final double maxLoss;
  final double totalTonsPerYear; // metric tons of soil lost annually across ROI
  final List<String> intersectingRegions;
  final String dominantRisk;
  final String conservationPriority;

  const CustomRoiStats({
    required this.areaSqKm,
    required this.meanLoss,
    required this.minLoss,
    required this.maxLoss,
    required this.totalTonsPerYear,
    required this.intersectingRegions,
    required this.dominantRisk,
    required this.conservationPriority,
  });

  /// Computes spatial zonal statistics across intersecting taluks within the ROI bounds
  factory CustomRoiStats.calculate({
    required LatLng center,
    required double radiusKm,
    required List<TalukErosionModel> allTaluks,
    required String activeYear,
  }) {
    // 1 deg latitude ~ 111 km
    final latDelta = radiusKm / 111.0;
    // 1 deg longitude ~ 111 * cos(lat) ~ 108 km in Kerala
    final lngDelta = radiusKm / 108.0;

    final minLat = center.latitude - latDelta;
    final maxLat = center.latitude + latDelta;
    final minLng = center.longitude - lngDelta;
    final maxLng = center.longitude + lngDelta;

    final matching = <TalukErosionModel>[];
    for (final t in allTaluks) {
      final g = t.geometry;
      final overlaps = !(g.maxLat < minLat ||
          g.minLat > maxLat ||
          g.maxLng < minLng ||
          g.minLng > maxLng);
      if (overlaps) {
        matching.add(t);
      }
    }

    // Default if no overlap
    if (matching.isEmpty) {
      final approxArea = 3.14159 * radiusKm * radiusKm;
      return CustomRoiStats(
        areaSqKm: approxArea,
        meanLoss: 8.5,
        minLoss: 5.0,
        maxLoss: 12.0,
        totalTonsPerYear: 8.5 * approxArea * 100,
        intersectingRegions: ['Kerala Midland Zone'],
        dominantRisk: 'Moderate',
        conservationPriority: 'Routine Soil Conservation Measures',
      );
    }

    double sum = 0.0;
    double minV = double.infinity;
    double maxV = -double.infinity;
    final names = <String>[];

    for (final m in matching) {
      final score = m.getScoreForYear(activeYear);
      sum += score;
      if (score < minV) minV = score;
      if (score > maxV) maxV = score;
      names.add('${m.talukName} (${m.districtName})');
    }

    final mean = sum / matching.length;
    final area = 3.14159 * radiusKm * radiusKm;
    // 1 km^2 = 100 hectares. Total tons = mean (t/ha) * area (km^2) * 100
    final totalTons = mean * area * 100;

    String priority = 'Routine Catchment Management';
    if (mean >= 30.0 || maxV >= 50.0) {
      priority = 'URGENT: Extreme Mass-Wasting & Gully Hazard';
    } else if (mean >= 15.0) {
      priority = 'HIGH: Active Topsoil Runoff Mitigation Required';
    } else if (mean >= 8.0) {
      priority = 'MODERATE: Contour Hedging & Vegetative Cover Recommended';
    }

    return CustomRoiStats(
      areaSqKm: double.parse(area.toStringAsFixed(1)),
      meanLoss: double.parse(mean.toStringAsFixed(1)),
      minLoss: double.parse(minV.toStringAsFixed(1)),
      maxLoss: double.parse(maxV.toStringAsFixed(1)),
      totalTonsPerYear: double.parse(totalTons.toStringAsFixed(0)),
      intersectingRegions: names,
      dominantRisk: RusleConstants.categorize(mean),
      conservationPriority: priority,
    );
  }
}
