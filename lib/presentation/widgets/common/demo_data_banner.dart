import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../state/map_providers.dart';
import 'data_source_dialog.dart';

/// Prominent top banner/badge that explicitly flags whether the application is
/// running in Demo / Sample Data Mode or connected to a Live Satellite Source.
class DemoDataBanner extends ConsumerWidget {
  const DemoDataBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final isLive = mapState.selectedDataSourceMode != 'bundled';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isLive
            ? AppColors.forestGreen.withOpacity(0.92)
            : AppColors.lateriteTerracotta.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const DataSourceDialog(),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLive ? Icons.satellite_alt_rounded : Icons.info_outline_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isLive ? 'LIVE SATELLITE FEED' : 'DEMO DATA (Sample Mode)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Configure',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
