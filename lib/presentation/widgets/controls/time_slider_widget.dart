import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/rusle_constants.dart';
import '../../state/map_providers.dart';

/// Interactive time slider with automated playback for scrubbing through
/// 2018–2024 satellite erosion observations.
class TimeSliderWidget extends ConsumerWidget {
  const TimeSliderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final years = RusleConstants.availableYears;
    final currentIndex = years.indexOf(mapState.activeYear).toDouble();

    final seasonNotes = _getSeasonNote(mapState.activeYear);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.94) : AppColors.lightSurface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
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
          Row(
            children: [
              // Play/Pause Button
              InkWell(
                onTap: () => notifier.toggleTimelinePlayback(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mapState.isPlayingTimeline
                        ? AppColors.lateriteTerracotta
                        : AppColors.forestGreenLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mapState.isPlayingTimeline ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Year ${mapState.activeYear}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreenLight.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          seasonNotes['badge'] ?? 'Monsoon',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreenLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    seasonNotes['desc'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              // Reset to current 2024
              if (mapState.activeYear != '2024')
                TextButton(
                  onPressed: () => notifier.setYear('2024'),
                  child: const Text('Latest (2024)', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.forestGreenLight,
              inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              thumbColor: AppColors.lateriteTerracotta,
              overlayColor: AppColors.lateriteTerracotta.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
            ),
            child: Slider(
              value: currentIndex,
              min: 0,
              max: (years.length - 1).toDouble(),
              divisions: years.length - 1,
              label: mapState.activeYear,
              onChanged: (val) {
                final selectedYear = years[val.toInt()];
                notifier.setYear(selectedYear);
              },
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, String> _getSeasonNote(String year) {
    switch (year) {
      case '2018':
        return {
          'badge': 'Centenary Floods',
          'desc': 'Severe widespread rainfall erosivity surge across high ranges.',
        };
      case '2019':
        return {
          'badge': 'Landslide Pulse',
          'desc': 'Heavy localized cloudbursts in Kavalappara and Wayanad hills.',
        };
      case '2020':
        return {
          'badge': 'Normal Monsoon',
          'desc': 'Standard monsoon cycle with mid-level catchment runoff.',
        };
      case '2021':
        return {
          'badge': 'Extended SW Monsoon',
          'desc': 'High rainfall duration causing sustained topsoil runoff.',
        };
      case '2022':
        return {
          'badge': 'Post-Monsoon Recovery',
          'desc': 'Improved vegetative cover (C-factor) in central midlands.',
        };
      case '2023':
        return {
          'badge': 'Deficit Monsoon',
          'desc': 'Reduced rainfall erosivity R-factor across Palakkad gap.',
        };
      case '2024':
        return {
          'badge': 'High Western Ghats Surge',
          'desc': 'Intense debris flows and soil stripping in Wayanad/Idukki.',
        };
      default:
        return {'badge': 'Annual', 'desc': 'Annual satellite observation layer.'};
    }
  }
}
