import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../../data/models/satellite_layer_config.dart';
import '../../state/map_providers.dart';
import 'district_polygon_layer.dart';
import 'map_controls_overlay.dart';

/// Full-screen interactive Leaflet map centered on Kerala.
class KeralaMapView extends ConsumerStatefulWidget {
  final MapController mapController;
  final void Function(DistrictErosionModel district)? onDistrictSelected;

  const KeralaMapView({
    super.key,
    required this.mapController,
    this.onDistrictSelected,
  });

  @override
  ConsumerState<KeralaMapView> createState() => _KeralaMapViewState();
}

class _KeralaMapViewState extends ConsumerState<KeralaMapView> {
  String _getTileUrl(BasemapType type) {
    switch (type) {
      case BasemapType.esriSatellite:
        return AppConstants.esriSatelliteTileUrl;
      case BasemapType.cartoDark:
        return AppConstants.cartoDarkTileUrl;
      case BasemapType.openTopo:
        return AppConstants.topoMapTileUrl;
      case BasemapType.osmStandard:
        return AppConstants.osmTileUrl;
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    final districts = ref.read(filteredDistrictsProvider);
    final notifier = ref.read(mapStateNotifierProvider.notifier);

    DistrictErosionModel? hitDistrict;
    for (final d in districts) {
      if (d.geometry.contains(point)) {
        hitDistrict = d;
        break;
      }
    }

    notifier.selectDistrict(hitDistrict);
    if (hitDistrict != null) {
      widget.onDistrictSelected?.call(hitDistrict);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final districts = ref.watch(filteredDistrictsProvider);
    final config = mapState.layerConfig;

    final tileUrl = _getTileUrl(config.activeBasemap);

    // Build choropleth polygons
    final polygons = DistrictPolygonLayerHelper.buildPolygons(
      districts: districts,
      selectedDistrict: mapState.selectedDistrict,
      hoveredDistrict: mapState.hoveredDistrict,
      activeYear: mapState.activeYear,
      config: config,
    );

    // Build hotspot markers and centroid labels
    final List<Marker> markers = [];
    if (config.showHotspotMarkers) {
      for (final district in districts) {
        final score = district.getScoreForYear(mapState.activeYear);
        final color = AppColors.colorForErosionScore(score);
        final isSevere = score >= 20.0;
        final isSelected = mapState.selectedDistrict?.id == district.id;

        markers.add(
          Marker(
            point: district.geometry.centroid,
            width: isSelected ? 120 : 80,
            height: isSelected ? 48 : 36,
            child: GestureDetector(
              onTap: () {
                ref.read(mapStateNotifierProvider.notifier).selectDistrict(district);
                widget.onDistrictSelected?.call(district);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color
                      : (Colors.black.withOpacity(0.75)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.white : color,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSevere) ...[
                      Icon(
                        Icons.warning_amber_rounded,
                        color: isSelected ? Colors.white : color,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                    ],
                    Flexible(
                      child: Text(
                        district.districtName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      score.toStringAsFixed(0),
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: AppConstants.keralaCenter,
            initialZoom: AppConstants.defaultZoom,
            minZoom: AppConstants.minZoom,
            maxZoom: AppConstants.maxZoom,
            onTap: _handleMapTap,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // 1. Basemap Tile Layer
            TileLayer(
              urlTemplate: tileUrl,
              userAgentPackageName: 'in.kerala.geospatial.kerala_soil_erosion_monitor',
              subdomains: const ['a', 'b', 'c', 'd'],
              tileProvider: NetworkTileProvider(),
            ),

            // 2. Analytical Choropleth Polygon Layer
            PolygonLayer(
              polygons: polygons,
              polygonCulling: true,
            ),

            // 3. Hotspot Markers Layer
            MarkerLayer(markers: markers),
          ],
        ),

        // Floating Map Controls (Zoom / Recenter)
        Positioned(
          right: 16,
          bottom: 110,
          child: MapControlsOverlay(mapController: widget.mapController),
        ),
      ],
    );
  }
}
