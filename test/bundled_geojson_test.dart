import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kerala_soil_erosion_monitor/data/models/district_erosion_model.dart';

void main() {
  group('Bundled GeoJSON Integrity Tests', () {
    test('verifies all 14 official Kerala districts are present with valid RUSLE data', () {
      final file = File('assets/data/kerala_districts.geojson');
      expect(file.existsSync(), isTrue, reason: 'kerala_districts.geojson must exist');

      final content = file.readAsStringSync();
      final data = json.decode(content) as Map<String, dynamic>;

      expect(data['type'], 'FeatureCollection');
      final features = data['features'] as List<dynamic>;
      expect(features.length, 14, reason: 'Kerala has exactly 14 revenue districts');

      final expectedDistricts = [
        'Alappuzha',
        'Ernakulam',
        'Idukki',
        'Kannur',
        'Kasaragod',
        'Kollam',
        'Kottayam',
        'Kozhikode',
        'Malappuram',
        'Palakkad',
        'Pathanamthitta',
        'Thiruvananthapuram',
        'Thrissur',
        'Wayanad',
      ];

      final parsedDistricts = <String, DistrictErosionModel>{};

      for (final f in features) {
        final model = DistrictErosionModel.fromGeoJsonFeature(f as Map<String, dynamic>);
        parsedDistricts[model.districtName] = model;

        // Verify geometry
        expect(model.geometry.polygonRings.isNotEmpty, isTrue);
        expect(model.geometry.centroid.latitude, greaterThan(8.0));
        expect(model.geometry.centroid.latitude, lessThan(13.0));
        expect(model.geometry.centroid.longitude, greaterThan(74.0));
        expect(model.geometry.centroid.longitude, lessThan(78.0));

        // Verify RUSLE factors
        expect(model.rusleFactors.rFactor, greaterThan(1500));
        expect(model.rusleFactors.kFactor, greaterThan(0.01));
        expect(model.rusleFactors.lsFactor, greaterThan(0.5));
        expect(model.rusleFactors.cFactor, greaterThan(0.01));
        expect(model.rusleFactors.pFactor, greaterThan(0.3));
        expect(model.rusleFactors.calculatedLoss, greaterThan(0.0));

        // Verify time series exists for 2018 to 2024
        expect(model.timeSeries.containsKey('2018'), isTrue);
        expect(model.timeSeries.containsKey('2024'), isTrue);

        // Verify taluks
        expect(model.taluks.isNotEmpty, isTrue);

        // Verify conservation tips
        expect(model.conservationMeasures.isNotEmpty, isTrue);
      }

      for (final expected in expectedDistricts) {
        expect(parsedDistricts.containsKey(expected), isTrue,
            reason: 'District $expected should be present in GeoJSON');
      }

      // Check scientific consistency: Idukki and Wayanad should have higher erosion than Alappuzha
      final idukkiLoss = parsedDistricts['Idukki']!.rusleFactors.calculatedLoss;
      final wayanadLoss = parsedDistricts['Wayanad']!.rusleFactors.calculatedLoss;
      final alappuzhaLoss = parsedDistricts['Alappuzha']!.rusleFactors.calculatedLoss;

      expect(idukkiLoss, greaterThan(alappuzhaLoss));
      expect(wayanadLoss, greaterThan(alappuzhaLoss));
    });
  });
}
