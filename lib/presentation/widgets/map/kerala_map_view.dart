import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../../data/models/satellite_layer_config.dart';
import '../../../data/models/taluk_erosion_model.dart';
import '../../state/map_providers.dart';
import '../../state/map_state.dart';
import '../details/custom_roi_card.dart';
import 'district_polygon_layer.dart';
import 'map_controls_overlay.dart';

/// Full-screen interactive Leaflet map centered on Kerala, supporting both
/// District overview and High-Precision Taluk modeling, plus custom ROI selection.
class KeralaMapView extends ConsumerStatefulWidget {
  final MapController mapController;
  final void Function(DistrictErosionModel district)? onDistrictSelected;
  final void Function(TalukErosionModel taluk)? onTalukSelected;

  const KeralaMapView({
    super.key,
    required this.mapController,
    this.onDistrictSelected,
    this.onTalukSelected,
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
    final mapState = ref.read(mapStateNotifierProvider);
    final notifier = ref.read(mapStateNotifierProvider.notifier);

    // If Custom Area of Interest (ROI) tool is active, place ROI at tap
    if (mapState.isRoiToolActive) {
      final allTaluksAsync = ref.read(taluksDataProvider);
      final allTaluks = allTaluksAsync.maybeWhen(data: (list) => list, orElse: () => <TalukErosionModel>[]);
      notifier.setCustomRoi(
        center: point,
        radiusKm: mapState.customRoiRadiusKm,
        allTaluks: allTaluks,
      );
      return;
    }

    if (mapState.granularity == GranularityLevel.taluk) {
      final taluks = ref.read(filteredTaluksProvider);
      TalukErosionModel? hitTaluk;
      for (final t in taluks) {
        if (t.geometry.contains(point)) {
          hitTaluk = t;
          break;
        }
      }
      notifier.selectTaluk(hitTaluk);
      if (hitTaluk != null) {
        widget.onTalukSelected?.call(hitTaluk);
      }
    } else {
      final districts = ref.read(filteredDistrictsProvider);
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
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final districts = ref.watch(filteredDistrictsProvider);
    final taluks = ref.watch(filteredTaluksProvider);
    final config = mapState.layerConfig;

    final tileUrl = _getTileUrl(config.activeBasemap);
    final isTalukMode = mapState.granularity == GranularityLevel.taluk;

    // Build choropleth polygons depending on selected granularity
    final List<Polygon<Object>> polygons = isTalukMode
        ? DistrictPolygonLayerHelper.buildTalukPolygons(
            taluks: taluks,
            selectedTaluk: mapState.selectedTaluk,
            hoveredTaluk: mapState.hoveredTaluk,
            activeYear: mapState.activeYear,
            config: config,
          )
        : DistrictPolygonLayerHelper.buildPolygons(
            districts: districts,
            selectedDistrict: mapState.selectedDistrict,
            hoveredDistrict: mapState.hoveredDistrict,
            activeYear: mapState.activeYear,
            config: config,
          );

    // Build hotspot markers and centroid labels
    final List<Marker> markers = [];
    if (config.showHotspotMarkers) {
      if (isTalukMode) {
        for (final taluk in taluks) {
          final score = taluk.getScoreForYear(mapState.activeYear);
          final color = AppColors.colorForErosionScore(score);
          final isSelected = mapState.selectedTaluk?.id == taluk.id;

          markers.add(
            Marker(
              point: taluk.geometry.centroid,
              width: isSelected ? 120 : 78,
              height: isSelected ? 42 : 32,
              child: GestureDetector(
                onTap: () {
                  ref.read(mapStateNotifierProvider.notifier).selectTaluk(taluk);
                  widget.onTalukSelected?.call(taluk);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.black.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? Colors.white : color, width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          taluk.talukName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 9.5,
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
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      } else {
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
                    color: isSelected ? color : Colors.black.withOpacity(0.75),
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
                        Icon(Icons.warning_amber_rounded, color: isSelected ? Colors.white : color, size: 13),
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
    }

    // Build Custom ROI Circle if set
    final List<CircleMarker> circleMarkers = [];
    if (mapState.isRoiToolActive && mapState.customRoiCenter != null) {
      circleMarkers.add(
        CircleMarker(
          point: mapState.customRoiCenter!,
          radius: mapState.customRoiRadiusKm * 1000.0, // meters
          useRadiusInMeter: true,
          color: AppColors.lateriteTerracotta.withOpacity(0.22),
          borderColor: AppColors.lateriteTerracotta,
          borderStrokeWidth: 2.5,
        ),
      );
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

            // 2. Analytical Choropleth Polygon Layer (Districts or Taluks)
            PolygonLayer(
              polygons: polygons,
              polygonCulling: true,
            ),

            // 3. Custom ROI Circle Layer (if active)
            if (circleMarkers.isNotEmpty)
              CircleLayer(circles: circleMarkers),

            // 4. Hotspot / Centroid Labels Marker Layer
            MarkerLayer(markers: markers),
          ],
        ),

        // Custom ROI Tool Active Indicator Banner
        if (mapState.isRoiToolActive)
          Positioned(
            top: 75,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lateriteTerracotta.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      mapState.customRoiCenter == null
                          ? 'Tap anywhere on the map to inspect custom area (${mapState.customRoiRadiusKm.toInt()}km radius)'
                          : 'Area Selected: Tap elsewhere to reposition ROI',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => ref.read(mapStateNotifierProvider.notifier).toggleRoiTool(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Exit ROI', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Custom ROI Floating Analysis Card
        if (mapState.customRoiStats != null)
          Positioned(
            left: 16,
            top: 120,
            child: CustomRoiCard(
              onClose: () => ref.read(mapStateNotifierProvider.notifier).clearCustomRoi(),
            ),
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
