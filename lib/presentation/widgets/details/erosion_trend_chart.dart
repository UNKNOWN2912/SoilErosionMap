import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/rusle_constants.dart';
import '../../../data/models/district_erosion_model.dart';

/// Interactive time-series line chart displaying 2018–2024 soil erosion trends.
class ErosionTrendChart extends StatelessWidget {
  final DistrictErosionModel district;
  final String activeYear;

  const ErosionTrendChart({
    super.key,
    required this.district,
    required this.activeYear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final years = RusleConstants.availableYears;

    final List<FlSpot> spots = [];
    double maxLoss = 10.0;

    for (int i = 0; i < years.length; i++) {
      final y = years[i];
      final score = district.getScoreForYear(y);
      spots.add(FlSpot(i.toDouble(), score));
      if (score > maxLoss) maxLoss = score;
    }

    // Add 15% headroom to Y-axis
    final maxY = (maxLoss * 1.15).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, color: AppColors.lateriteTerracotta, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Historical Erosion Trend (2018–2024)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lateriteTerracotta.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Current: ${district.getScoreForYear(activeYear)} t/ha/yr',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lateriteTerracotta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (years.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: isDark ? Colors.white10 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final index = val.toInt();
                        if (index >= 0 && index < years.length) {
                          final isSelected = years[index] == activeYear;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              years[index].substring(2), // '18, '19 ...
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.lateriteTerracotta
                                    : (isDark ? Colors.white54 : Colors.black54),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (val, meta) {
                        return Text(
                          val.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.lateriteTerracotta,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final isSelected = years[index] == activeYear;
                        return FlDotCirclePainter(
                          radius: isSelected ? 6 : 3.5,
                          color: isSelected ? Colors.white : AppColors.lateriteTerracotta,
                          strokeWidth: isSelected ? 3 : 1.5,
                          strokeColor: AppColors.lateriteTerracotta,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.lateriteTerracotta.withOpacity(0.35),
                          AppColors.lateriteTerracotta.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Observation years (2018: Great Floods pulse | 2024: Current post-monsoon)',
              style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}
