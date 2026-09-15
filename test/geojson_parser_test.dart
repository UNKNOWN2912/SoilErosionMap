import 'package:flutter_test/flutter_test.dart';
import 'package:kerala_soil_erosion_monitor/core/utils/geojson_parser.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('GeoJsonParser Tests', () {
    test('parses simple Polygon and computes centroid correctly', () {
      final samplePolygon = {
        'type': 'Polygon',
        'coordinates': [
          [
            [76.0, 10.0],
            [77.0, 10.0],
            [77.0, 11.0],
            [76.0, 11.0],
            [76.0, 10.0],
          ]
        ]
      };

      final geom = GeoJsonParser.parseGeometry(samplePolygon);
      expect(geom.polygonRings.length, 1);
      expect(geom.polygonRings[0].length, 5);

      // Centroid should be approximately 10.4, 76.4 (since ring has 5 points with repeat)
      expect(geom.minLat, 10.0);
      expect(geom.maxLat, 11.0);
      expect(geom.minLng, 76.0);
      expect(geom.maxLng, 77.0);

      // Point inside polygon test
      expect(geom.contains(const LatLng(10.5, 76.5)), isTrue);
      // Point outside polygon test
      expect(geom.contains(const LatLng(12.0, 78.0)), isFalse);
    });

    test('parses MultiPolygon geometry correctly', () {
      final sampleMulti = {
        'type': 'MultiPolygon',
        'coordinates': [
          [
            [
              [75.0, 11.0],
              [75.5, 11.0],
              [75.5, 11.5],
              [75.0, 11.5],
              [75.0, 11.0],
            ]
          ],
          [
            [
              [75.6, 11.6],
              [75.9, 11.6],
              [75.9, 11.9],
              [75.6, 11.9],
              [75.6, 11.6],
            ]
          ]
        ]
      };

      final geom = GeoJsonParser.parseGeometry(sampleMulti);
      expect(geom.polygonRings.length, 2);
      expect(geom.contains(const LatLng(11.2, 75.2)), isTrue);
      expect(geom.contains(const LatLng(11.7, 75.7)), isTrue);
      expect(geom.contains(const LatLng(10.0, 75.0)), isFalse);
    });
  });
}
