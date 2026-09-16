import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/taluk_erosion_model.dart';
import '../../state/map_providers.dart';

/// Comprehensive details panel for an individual Taluk / sub-region,
/// presenting micro-topographic metrics, slope, elevation, RUSLE factor breakdown,
/// and targeted conservation actions.
class TalukSummarySheet extends ConsumerWidget {
  final TalukErosionModel taluk;
  final VoidCallback? onClose;
  final bool isSidePanel;

  const TalukSummarySheet({
    super.key,
    required this.taluk,
    this.onClose,
    this.isSidePanel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final score = taluk.getScoreForYear(mapState.activeYear);
    final category = taluk.getCategoryForYear(mapState.activeYear);
    final categoryColor = AppColors.colorForErosionScore(score);

    final content = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, isSidePanel ? 20 : 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // Header
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
                          taluk.talukName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          taluk.malayalamName,
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
                      'Taluk in ${taluk.districtName} District • Area ~ ${taluk.areaSqKm.toInt()} km²',
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
                        '$category Risk Severity (${mapState.activeYear})',
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

          // Micro-Topography Indicators (Elevation, Slope, Soil, Land Use)
          _buildTopographyPills(context),

          const SizedBox(height: 14),

          // RUSLE Model Factors Breakdown Card
          _buildTalukRusleCard(context, ref),

          const SizedBox(height: 14),

          // Time-Series Trend Chart
          _buildTrendChartCard(context, mapState.activeYear),

          const SizedBox(height: 14),

          // Tailored Conservation Tips
          _buildConservationTipsCard(context),
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

  Widget _buildTopographyPills(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricBadge(
                icon: Icons.terrain_rounded,
                label: 'Mean Elevation',
                value: '${taluk.elevationMeters.toInt()} m',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricBadge(
                icon: Icons.trending_up_rounded,
                label: 'Mean Slope',
                value: '${taluk.slopeDegrees.toStringAsFixed(1)}°',
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          icon: Icons.grass_rounded,
          label: 'Dominant Land Use',
          value: taluk.dominantLandUse,
          isDark: isDark,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          icon: Icons.layers_outlined,
          label: 'Soil Series',
          value: taluk.soilType,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildMetricBadge({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.forestGreenLight),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
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

  Widget _buildTalukRusleCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rusle = taluk.rusleFactors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate_rounded, color: AppColors.forestGreenLight, size: 18),
              SizedBox(width: 8),
              Text(
                'Localized RUSLE Factor Breakdown',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildFactorItem('R (Rainfall Erosivity)', '${rusle.rFactor.toStringAsFixed(0)} MJ·mm/ha·h·yr', AppColors.riverTeal),
          _buildFactorItem('K (Soil Erodibility)', rusle.kFactor.toStringAsFixed(3), AppColors.ochreClay),
          _buildFactorItem('LS (Slope & Steepness)', '${rusle.lsFactor.toStringAsFixed(1)} (Slope: ${taluk.slopeDegrees.toStringAsFixed(1)}°)', AppColors.lateriteTerracotta),
          _buildFactorItem('C (Vegetation Canopy)', rusle.cFactor.toStringAsFixed(2), AppColors.ndviGreen),
          _buildFactorItem('P (Conservation Practice)', rusle.pFactor.toStringAsFixed(2), Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildFactorItem(String title, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11.5)),
          Text(val, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard(BuildContext context, String activeYear) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.lateriteTerracotta, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Historical Erosion Trend (2018–2024)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Text(
                '${taluk.getScoreForYear(activeYear)} t/ha/yr',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lateriteTerracotta, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mini trend bars for each year
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: ['2018', '2019', '2020', '2021', '2022', '2023', '2024'].map((y) {
              final val = taluk.getScoreForYear(y);
              final isSelected = y == activeYear;
              final barColor = AppColors.colorForErosionScore(val);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(val.toStringAsFixed(0), style: TextStyle(fontSize: 9.5, color: isSelected ? barColor : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  const SizedBox(height: 3),
                  Container(
                    width: 16,
                    height: (val * 1.5).clamp(8.0, 70.0),
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(isSelected ? 1.0 : 0.6),
                      borderRadius: BorderRadius.circular(4),
                      border: isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(y.substring(2), style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? barColor : null)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConservationTipsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.nature_people_rounded, color: AppColors.forestGreenLight, size: 18),
              SizedBox(width: 8),
              Text(
                'Micro-Catchment Conservation Measures',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...taluk.conservationMeasures.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.forestGreenLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 11.5, height: 1.35),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
