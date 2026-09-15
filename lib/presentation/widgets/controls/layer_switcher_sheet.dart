import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/satellite_layer_config.dart';
import '../../state/map_providers.dart';

/// Modal bottom sheet or side panel for toggling satellite layers,
/// adjusting overlay opacity, and switching basemaps.
class LayerSwitcherSheet extends ConsumerWidget {
  const LayerSwitcherSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LayerSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    final config = mapState.layerConfig;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreenLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.layers_rounded, color: AppColors.forestGreenLight),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Geospatial Layers & Basemap',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 1: Analytical Satellite Overlay
            const Text(
              'SATELLITE / GEOSPATIAL LAYER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...SatelliteLayerType.values.map((layer) {
              final isSelected = config.activeLayer == layer;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () => notifier.setActiveLayer(layer),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.forestGreen.withOpacity(0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.forestGreenLight
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(layer.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                layer.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isSelected ? AppColors.forestGreenLight : null,
                                ),
                              ),
                              Text(
                                layer.description,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.forestGreenLight, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Section 2: Opacity Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'OVERLAY OPACITY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${(config.overlayOpacity * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            Slider(
              value: config.overlayOpacity,
              min: 0.1,
              max: 1.0,
              divisions: 18,
              activeColor: AppColors.forestGreenLight,
              inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              onChanged: (val) => notifier.setOverlayOpacity(val),
            ),

            const SizedBox(height: 12),

            // Section 3: Basemap Provider
            const Text(
              'BASEMAP TILES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BasemapType.values.map((basemap) {
                final isSelected = config.activeBasemap == basemap;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(basemap.emoji),
                      const SizedBox(width: 6),
                      Text(basemap.title),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.forestGreenLight.withOpacity(0.25),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.forestGreenLight
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  onSelected: (_) => notifier.setActiveBasemap(basemap),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Section 4: Display Toggles
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('District Boundary Outlines', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Render crisp administrative polygon borders',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              value: config.showDistrictBoundaries,
              activeColor: AppColors.forestGreenLight,
              onChanged: (val) => notifier.toggleBoundaries(val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Erosion Vulnerability Hotspots', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Show pinpoint icons over high and severe zones',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              value: config.showHotspotMarkers,
              activeColor: AppColors.lateriteTerracotta,
              onChanged: (val) => notifier.toggleHotspots(val),
            ),
          ],
        ),
      ),
    );
  }
}
