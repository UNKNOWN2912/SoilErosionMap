import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Geometry data class holding coordinates for rendering map polygons.
class DistrictGeometry {
  final List<List<LatLng>> polygonRings;
  final LatLng centroid;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  DistrictGeometry({
    required this.polygonRings,
    required this.centroid,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  bool contains(LatLng point) {
    for (final ring in polygonRings) {
      if (_pointInPolygon(point, ring)) return true;
    }
    return false;
  }

  static bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCrossesSegment(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  static bool _rayCrossesSegment(LatLng point, LatLng a, LatLng b) {
    final double px = point.longitude;
    double py = point.latitude;
    final double ax = a.longitude;
    final double ay = a.latitude;
    final double bx = b.longitude;
    final double by = b.latitude;

    if (ay > by) {
      // Swap points
      return _rayCrossesSegment(point, b, a);
    }
    if (py == ay || py == by) {
      py += 0.00000001;
    }
    if (py > by || py < ay || px > (ax > bx ? ax : bx)) {
      return false;
    }
    if (px < (ax < bx ? ax : bx)) {
      return true;
    }
    final red = (ax != bx) ? ((by - ay) / (bx - ax)) : double.infinity;
    final blue = (ax != px) ? ((py - ay) / (px - ax)) : double.infinity;
    return blue >= red;
  }
}

/// Helper utility to parse GeoJSON features into Dart LatLng geometry models.
class GeoJsonParser {
  GeoJsonParser._();

  static DistrictGeometry parseGeometry(Map<String, dynamic> geometryJson) {
    final type = geometryJson['type'] as String?;
    final coordinates = geometryJson['coordinates'];
    final List<List<LatLng>> rings = [];

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;
    double sumLat = 0.0;
    double sumLng = 0.0;
    int pointCount = 0;

    void processCoord(dynamic rawCoord) {
      if (rawCoord is List && rawCoord.length >= 2) {
        final lng = (rawCoord[0] as num).toDouble();
        final lat = (rawCoord[1] as num).toDouble();

        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;

        sumLat += lat;
        sumLng += lng;
        pointCount++;
      }
    }

    if (type == 'Polygon' && coordinates is List) {
      for (final ring in coordinates) {
        if (ring is List) {
          final List<LatLng> latLngRing = [];
          for (final coord in ring) {
            processCoord(coord);
            if (coord is List && coord.length >= 2) {
              latLngRing.add(LatLng(
                (coord[1] as num).toDouble(),
                (coord[0] as num).toDouble(),
              ));
            }
          }
          if (latLngRing.isNotEmpty) {
            rings.add(latLngRing);
          }
        }
      }
    } else if (type == 'MultiPolygon' && coordinates is List) {
      for (final polygon in coordinates) {
        if (polygon is List) {
          for (final ring in polygon) {
            if (ring is List) {
              final List<LatLng> latLngRing = [];
              for (final coord in ring) {
                processCoord(coord);
                if (coord is List && coord.length >= 2) {
                  latLngRing.add(LatLng(
                    (coord[1] as num).toDouble(),
                    (coord[0] as num).toDouble(),
                  ));
                }
              }
              if (latLngRing.isNotEmpty) {
                rings.add(latLngRing);
              }
            }
          }
        }
      }
    } else {
      debugPrint('Unsupported geometry type: $type');
    }

    final centroid = pointCount > 0
        ? LatLng(sumLat / pointCount, sumLng / pointCount)
        : const LatLng(10.8505, 76.2711);

    return DistrictGeometry(
      polygonRings: rings,
      centroid: centroid,
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
    );
  }
}
