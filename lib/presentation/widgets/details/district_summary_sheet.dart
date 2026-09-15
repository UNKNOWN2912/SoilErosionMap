import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../state/map_providers.dart';
import 'conservation_tips_card.dart';
import 'erosion_trend_chart.dart';
import 'rusle_breakdown_card.dart';

/// Comprehensive summary panel displaying district information, RUSLE breakdown,
/// time-series chart, and agronomic conservation tips.
class DistrictSummarySheet extends ConsumerWidget {
  final DistrictErosionModel district;
  final VoidCallback? onClose;
  final bool isSidePanel;

  const DistrictSummarySheet({
    super.key,
    required this.district,
    this.onClose,
    this.isSidePanel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final score = district.getScoreForYear(mapState.activeYear);
    final category = district.getCategoryForYear(mapState.activeYear);
    final categoryColor = AppColors.colorForErosionScore(score);

    final content = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, isSidePanel ? 20 : 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle for bottom sheet
          if (!isSidePanel)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          district.districtName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          district.malayalamName,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'HQ: ${district.headquarters} • Area: ${district.areaSqKm.toInt()} km²',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Severity Banner Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: categoryColor, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$category Erosion Risk Severity (${mapState.activeYear})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: categoryColor,
                        ),
                      ),
                      Text(
                        'Annual soil loss: ${score.toStringAsFixed(1)} metric tons / hectare / year',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Key Geospatial Indicators
          _buildInfoPillGrid(context),

          const SizedBox(height: 14),

          // Taluks Chips
          if (district.taluks.isNotEmpty) ...[
            const Text(
              'TALUKS & REVENUE DIVISIONS',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: district.taluks.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    t,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // RUSLE Model Factors Breakdown & Simulation Card
          RusleBreakdownCard(district: district),

          const SizedBox(height: 14),

          // Historical Trend Chart (2018–2024)
          ErosionTrendChart(district: district, activeYear: mapState.activeYear),

          const SizedBox(height: 14),

          // Agronomic Soil Conservation Recommendations
          ConservationTipsCard(district: district),
        ],
      ),
    );

    if (isSidePanel) {
      return Container(
        width: 380,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            left: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(-3, 0),
            ),
          ],
        ),
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: content,
    );
  }

  Widget _buildInfoPillGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.landscape_rounded,
          label: 'Terrain Zone',
          value: district.terrainCategory,
          isDark: isDark,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          icon: Icons.grass_rounded,
          label: 'Dominant Land Use',
          value: district.dominantLandUse,
          isDark: isDark,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          icon: Icons.layers_outlined,
          label: 'Soil Type',
          value: district.soilType,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.forestGreenLight),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
