import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Collapsible or modal footer citing satellite data providers.
class AttributionFooter extends StatelessWidget {
  const AttributionFooter({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AttributionFooter(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.satellite_alt_rounded, color: AppColors.forestGreenLight),
              const SizedBox(width: 8),
              const Text(
                'Data Sources & Attribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildItem(
            icon: Icons.shield_outlined,
            title: 'ISRO Bhuvan (NRSC)',
            desc: AppConstants.attributionISRO,
            url: 'https://bhuvan.nrsc.gov.in',
          ),
          const SizedBox(height: 10),
          _buildItem(
            icon: Icons.public,
            title: 'Copernicus Sentinel-2 (ESA)',
            desc: AppConstants.attributionSentinel,
            url: 'https://sentinels.copernicus.eu',
          ),
          const SizedBox(height: 10),
          _buildItem(
            icon: Icons.terrain_rounded,
            title: 'NASA & NGA SRTM',
            desc: AppConstants.attributionSRTM,
            url: 'https://www.earthdata.nasa.gov',
          ),
          const SizedBox(height: 10),
          _buildItem(
            icon: Icons.water_drop_outlined,
            title: 'IMD & NASA GPM',
            desc: AppConstants.attributionIMD,
            url: 'https://mausam.imd.gov.in',
          ),
          const SizedBox(height: 10),
          _buildItem(
            icon: Icons.location_city_rounded,
            title: 'KSREC (Kerala State)',
            desc: AppConstants.attributionKSREC,
            url: 'https://ksrec.kerala.gov.in',
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'RUSLE Model: A = R × K × LS × C × P | Units: t/ha/year',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required String desc,
    required String url,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.ochreClay),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
