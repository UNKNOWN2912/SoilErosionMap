import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/district_erosion_model.dart';

/// Actionable soil conservation recommendations tailored to the district's
/// specific topography, soil type, and land use patterns.
class ConservationTipsCard extends StatelessWidget {
  final DistrictErosionModel district;

  const ConservationTipsCard({super.key, required this.district});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          const Row(
            children: [
              Icon(Icons.nature_people_rounded, color: AppColors.forestGreenLight, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recommended Soil Conservation Measures',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...district.conservationMeasures.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 12, height: 1.4),
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
