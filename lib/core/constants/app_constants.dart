import 'package:latlong2/latlong.dart';

/// Core application constants, geospatial center coordinates, and tile service endpoints.
class AppConstants {
  AppConstants._();

  static const String appName = 'Kerala Soil Erosion Monitor';
  static const String appTagline = 'Satellite-Derived RUSLE Geospatial Erosion Intelligence';

  // Geographic bounds and center for the State of Kerala, India
  static const double keralaCenterLat = 10.8505;
  static const double keralaCenterLng = 76.2711;
  static const LatLng keralaCenter = LatLng(keralaCenterLat, keralaCenterLng);

  static const double minLat = 8.15;
  static const double maxLat = 12.85;
  static const double minLng = 74.85;
  static const double maxLng = 77.60;

  static const double defaultZoom = 7.6;
  static const double minZoom = 6.8;
  static const double maxZoom = 15.0;

  // Tile layer URLs
  // OpenStreetMap standard carto
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // High-resolution ESRI World Imagery (Public True Color Satellite Basemap)
  static const String esriSatelliteTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  // Carto Dark Matter basemap (ideal for high-contrast choropleths)
  static const String cartoDarkTileUrl =
      'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';

  // OpenTopoMap for topographic elevation & contour relief
  static const String topoMapTileUrl =
      'https://tile.opentopomap.org/{z}/{x}/{y}.png';

  // Live data placeholders and attribution
  static const String attributionISRO = 'ISRO Bhuvan (NRSC Land Degradation & Erosion)';
  static const String attributionSentinel = 'Copernicus Sentinel-2 (ESA, 10m NDVI)';
  static const String attributionSRTM = 'NASA SRTM DEM (30m Topographic Relief)';
  static const String attributionIMD = 'IMD & NASA GPM (Rainfall Erosivity Index)';
  static const String attributionKSREC = 'Kerala State Remote Sensing & Environment Centre';

  // Assets path
  static const String bundledGeoJsonPath = 'assets/data/kerala_districts.geojson';

  // Hive Box names
  static const String cacheBoxName = 'erosion_data_cache';
  static const String settingsBoxName = 'app_settings_cache';
}
