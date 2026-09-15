/// Configuration for satellite, environmental, and basemap layers.
enum SatelliteLayerType {
  soilErosion('Soil Erosion Risk', 'RUSLE model loss in t/ha/yr', '🛰️'),
  ndvi('NDVI Vegetation Cover', 'Sentinel-2 MSI 10m vegetation density index', '🌿'),
  rainfall('Rainfall Intensity', 'NASA GPM & IMD precipitation erosivity R-factor', '🌧️'),
  elevation('Slope & Elevation', 'NASA SRTM 30m topographic hillshade & LS-factor', '⛰️');

  final String title;
  final String description;
  final String emoji;
  const SatelliteLayerType(this.title, this.description, this.emoji);
}

enum BasemapType {
  esriSatellite('ESRI Satellite', 'True-color high-resolution optical imagery', '🛰️'),
  osmStandard('OpenStreetMap', 'Detailed standard cartographic street map', '🗺️'),
  cartoDark('Dark Canvas', 'High-contrast minimalist dark theme for analytics', '🌑'),
  openTopo('Topographic', 'Contour relief and elevation shading', '🏔️');

  final String title;
  final String subtitle;
  final String emoji;
  const BasemapType(this.title, this.subtitle, this.emoji);
}

class SatelliteLayerConfig {
  final SatelliteLayerType activeLayer;
  final BasemapType activeBasemap;
  final double overlayOpacity;
  final bool showDistrictBoundaries;
  final bool showHotspotMarkers;

  const SatelliteLayerConfig({
    this.activeLayer = SatelliteLayerType.soilErosion,
    this.activeBasemap = BasemapType.esriSatellite,
    this.overlayOpacity = 0.75,
    this.showDistrictBoundaries = true,
    this.showHotspotMarkers = true,
  });

  SatelliteLayerConfig copyWith({
    SatelliteLayerType? activeLayer,
    BasemapType? activeBasemap,
    double? overlayOpacity,
    bool? showDistrictBoundaries,
    bool? showHotspotMarkers,
  }) {
    return SatelliteLayerConfig(
      activeLayer: activeLayer ?? this.activeLayer,
      activeBasemap: activeBasemap ?? this.activeBasemap,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      showDistrictBoundaries: showDistrictBoundaries ?? this.showDistrictBoundaries,
      showHotspotMarkers: showHotspotMarkers ?? this.showHotspotMarkers,
    );
  }
}
