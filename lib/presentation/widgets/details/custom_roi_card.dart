import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../state/map_providers.dart';

/// Floating card displaying real-time spatial zonal erosion statistics
/// for the user-selected custom Region of Interest (ROI).
class CustomRoiCard extends ConsumerWidget {
  final VoidCallback? onClose;

  const CustomRoiCard({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final stats = mapState.customRoiStats;
    final center = mapState.customRoiCenter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (stats == null || center == null) return const SizedBox.shrink();

    final severityColor = AppColors.colorForCategory(stats.dominantRisk);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.95) : AppColors.lightSurface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: severityColor.withOpacity(0.7), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.crop_free_rounded, color: severityColor, size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Area Analysis',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'Zonal spatial statistics',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  ref.read(mapStateNotifierProvider.notifier).clearCustomRoi();
                  onClose?.call();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Mean Soil Loss Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.meanLoss.toStringAsFixed(1)} t/ha/yr',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: severityColor,
                      ),
                    ),
                    Text(
                      '${stats.dominantRisk} Severity Average',
                      style: TextStyle(fontSize: 10, color: severityColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stats.areaSqKm.toInt()} km²',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Text('Sampled Area', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Total Annual Soil Loss Tonnage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Soil Loss Est.:', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                '${stats.totalTonsPerYear.toStringAsFixed(0)} metric tons/yr',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Loss Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Intensity Range:', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                '${stats.minLoss} – ${stats.maxLoss} t/ha/yr',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Intersecting Taluks
          Text(
            'Intersecting Regions (${stats.intersectingRegions.length}):',
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          Text(
            stats.intersectingRegions.take(3).join(', ') + (stats.intersectingRegions.length > 3 ? '...' : ''),
            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          // Action Priority Alert
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: severityColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, size: 14, color: severityColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    stats.conservationPriority,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: severityColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
