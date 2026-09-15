import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/rusle_constants.dart';
import '../../state/map_providers.dart';

/// Floating interactive legend explaining the RUSLE color scale.
/// Tapping a category toggles that category filter on the map.
class MapLegendWidget extends ConsumerStatefulWidget {
  const MapLegendWidget({super.key});

  @override
  ConsumerState<MapLegendWidget> createState() => _MapLegendWidgetState();
}

class _MapLegendWidgetState extends ConsumerState<MapLegendWidget> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {'name': RusleConstants.categoryLow, 'range': '< 5 t/ha/yr', 'color': AppColors.riskLow},
      {'name': RusleConstants.categoryModerate, 'range': '5 - 10 t/ha/yr', 'color': AppColors.riskModerate},
      {'name': RusleConstants.categoryHigh, 'range': '10 - 20 t/ha/yr', 'color': AppColors.riskHigh},
      {'name': RusleConstants.categorySevere, 'range': '20 - 40 t/ha/yr', 'color': AppColors.riskSevere},
      {'name': RusleConstants.categoryVerySevere, 'range': '> 40 t/ha/yr', 'color': AppColors.riskVerySevere},
    ];

    return Container(
      width: _isCollapsed ? 140 : 210,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withOpacity(0.92) : AppColors.lightSurface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.forestGreenLight),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Erosion Risk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _isCollapsed = !_isCollapsed),
                child: Icon(
                  _isCollapsed ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (!_isCollapsed) ...[
            const SizedBox(height: 6),
            ...categories.map((cat) {
              final name = cat['name'] as String;
              final range = cat['range'] as String;
              final color = cat['color'] as Color;
              final isEnabled = mapState.activeCategories.contains(name);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: InkWell(
                  onTap: () => notifier.toggleCategory(name),
                  borderRadius: BorderRadius.circular(6),
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.35,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.black26, width: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          range,
                          style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (mapState.activeCategories.length < RusleConstants.allCategories.length) ...[
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => notifier.resetCategories(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Show All', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
