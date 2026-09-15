import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../state/map_providers.dart';

/// Displays the 5 RUSLE factors (A = R * K * LS * C * P) with interactive
/// conservation practice (P-factor) simulation slider.
class RusleBreakdownCard extends ConsumerWidget {
  final DistrictErosionModel district;

  const RusleBreakdownCard({super.key, required this.district});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rusle = district.rusleFactors;
    final simulatedP = mapState.simulatedPValue;

    // Simulate new annual loss with custom P factor
    final baselineLoss = rusle.calculatedLoss;
    final simulatedLoss = double.parse(
      (rusle.rFactor * rusle.kFactor * rusle.lsFactor * rusle.cFactor * simulatedP).toStringAsFixed(2),
    );
    final reductionPct = baselineLoss > 0
        ? (((baselineLoss - simulatedLoss) / baselineLoss) * 100).toStringAsFixed(1)
        : '0.0';

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
              const Icon(Icons.calculate_rounded, color: AppColors.forestGreenLight, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'RUSLE Model Factors (A = R × K × LS × C × P)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Factor 1: R
          _buildFactorRow(
            symbol: 'R',
            title: 'Rainfall Erosivity',
            valStr: '${rusle.rFactor.toStringAsFixed(0)} MJ·mm/ha·h·yr',
            normValue: (rusle.rFactor / 7000.0).clamp(0.0, 1.0),
            color: AppColors.riverTeal,
            desc: 'IMD & NASA GPM satellite rainfall energy',
          ),
          const SizedBox(height: 8),

          // Factor 2: K
          _buildFactorRow(
            symbol: 'K',
            title: 'Soil Erodibility',
            valStr: rusle.kFactor.toStringAsFixed(3),
            normValue: (rusle.kFactor / 0.05).clamp(0.0, 1.0),
            color: AppColors.ochreClay,
            desc: district.soilType,
          ),
          const SizedBox(height: 8),

          // Factor 3: LS
          _buildFactorRow(
            symbol: 'LS',
            title: 'Topographic Slope Length & Steepness',
            valStr: rusle.lsFactor.toStringAsFixed(1),
            normValue: (rusle.lsFactor / 20.0).clamp(0.0, 1.0),
            color: AppColors.lateriteTerracotta,
            desc: 'NASA SRTM 30m Digital Elevation Model',
          ),
          const SizedBox(height: 8),

          // Factor 4: C
          _buildFactorRow(
            symbol: 'C',
            title: 'Cover & Management',
            valStr: rusle.cFactor.toStringAsFixed(2),
            normValue: (rusle.cFactor / 0.5).clamp(0.0, 1.0),
            color: AppColors.ndviGreen,
            desc: 'Sentinel-2 MSI 10m NDVI canopy factor',
          ),
          const SizedBox(height: 8),

          // Factor 5: P
          _buildFactorRow(
            symbol: 'P',
            title: 'Support Practice',
            valStr: rusle.pFactor.toStringAsFixed(2),
            normValue: rusle.pFactor.clamp(0.0, 1.0),
            color: Colors.purpleAccent,
            desc: 'Terracing, contouring & vegetative bunding',
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Conservation Simulation Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Simulate Conservation Practice (P)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              Text(
                'P = ${simulatedP.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.forestGreenLight,
                ),
              ),
            ],
          ),
          Slider(
            value: simulatedP,
            min: 0.35,
            max: 1.0,
            divisions: 13,
            activeColor: AppColors.forestGreenLight,
            onChanged: (val) => notifier.setSimulatedP(val),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.forestGreenLight.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, color: AppColors.forestGreenLight, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    simulatedP < rusle.pFactor
                        ? 'Simulated Loss: $simulatedLoss t/ha/yr ($reductionPct% reduction with contour terracing)'
                        : 'Baseline Soil Loss: $baselineLoss t/ha/yr',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorRow({
    required String symbol,
    required String title,
    required String valStr,
    required double normValue,
    required Color color,
    required String desc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                symbol,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              valStr,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 3),
        LinearProgressIndicator(
          value: normValue,
          backgroundColor: color.withOpacity(0.12),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}
