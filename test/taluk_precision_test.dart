import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerala_soil_erosion_monitor/data/models/custom_roi_model.dart';
import 'package:kerala_soil_erosion_monitor/data/models/taluk_erosion_model.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('High-Precision Taluk & ROI Tests', () {
    test('verifies all 61 taluks exist with localized slope, elevation, and RUSLE', () {
      final file = File('assets/data/kerala_taluks.geojson');
      expect(file.existsSync(), isTrue);

      final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;
      expect(features.length, 61, reason: 'Kerala has 61 revenue taluks');

      final taluks = <TalukErosionModel>[];
      for (final f in features) {
        final model = TalukErosionModel.fromGeoJsonFeature(f as Map<String, dynamic>);
        taluks.add(model);

        expect(model.talukName.isNotEmpty, isTrue);
        expect(model.districtName.isNotEmpty, isTrue);
        expect(model.rusleFactors.calculatedLoss, greaterThan(0));
        expect(model.geometry.polygonRings.isNotEmpty, isTrue);
      }

      // Check micro-topographic precision: Devikulam (High Western Ghats) vs Kuttanad (Lowland Polders)
      final devikulam = taluks.firstWhere((t) => t.talukName == 'Devikulam');
      final kuttanad = taluks.firstWhere((t) => t.talukName == 'Kuttanad');

      expect(devikulam.elevationMeters, greaterThan(1000));
      expect(devikulam.slopeDegrees, greaterThan(20));
      expect(devikulam.rusleFactors.calculatedLoss, greaterThan(50)); // High risk

      expect(kuttanad.elevationMeters, lessThan(5));
      expect(kuttanad.slopeDegrees, lessThan(2));
      expect(kuttanad.rusleFactors.calculatedLoss, lessThan(5)); // Low risk
    });

    test('calculates Custom Area of Interest (ROI) zonal statistics accurately', () {
      final file = File('assets/data/kerala_taluks.geojson');
      final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;
      final taluks = features.map((f) => TalukErosionModel.fromGeoJsonFeature(f as Map<String, dynamic>)).toList();

      // Sample a 15km radius around Munnar / Devikulam (lat 10.08, lng 77.06)
      const munnarCenter = LatLng(10.08, 77.06);
      final stats = CustomRoiStats.calculate(
        center: munnarCenter,
        radiusKm: 15.0,
        allTaluks: taluks,
        activeYear: '2024',
      );

      expect(stats.areaSqKm, greaterThan(500));
      expect(stats.meanLoss, greaterThan(20.0)); // Mountainous zone should have high erosion mean
      expect(stats.totalTonsPerYear, greaterThan(1000000)); // Over 1 million tons
      expect(stats.intersectingRegions.isNotEmpty, isTrue);
    });
  });
}
