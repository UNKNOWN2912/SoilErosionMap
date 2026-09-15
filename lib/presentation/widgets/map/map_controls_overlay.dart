import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Floating map navigation controls: zoom in, zoom out, and reset center to Kerala.
class MapControlsOverlay extends StatelessWidget {
  final MapController mapController;

  const MapControlsOverlay({super.key, required this.mapController});

  void _zoomIn() {
    final currentZoom = mapController.camera.zoom;
    if (currentZoom < AppConstants.maxZoom) {
      mapController.move(mapController.camera.center, currentZoom + 0.6);
    }
  }

  void _zoomOut() {
    final currentZoom = mapController.camera.zoom;
    if (currentZoom > AppConstants.minZoom) {
      mapController.move(mapController.camera.center, currentZoom - 0.6);
    }
  }

  void _resetCenter() {
    mapController.move(AppConstants.keralaCenter, AppConstants.defaultZoom);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.92) : AppColors.lightSurface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom In',
            icon: const Icon(Icons.add_rounded, size: 20),
            onPressed: _zoomIn,
          ),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          IconButton(
            tooltip: 'Zoom Out',
            icon: const Icon(Icons.remove_rounded, size: 20),
            onPressed: _zoomOut,
          ),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          IconButton(
            tooltip: 'Center on Kerala',
            icon: const Icon(Icons.my_location_rounded, size: 18, color: AppColors.forestGreenLight),
            onPressed: _resetCenter,
          ),
        ],
      ),
    );
  }
}
