import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../state/map_providers.dart';
import '../common/attribution_footer.dart';
import '../common/data_source_dialog.dart';
import 'layer_switcher_sheet.dart';

/// Top search bar with taluk/district autocompletion, layer quick-action,
/// and fast category filters.
class SearchFilterBar extends ConsumerStatefulWidget {
  final void Function(DistrictErosionModel district)? onDistrictSelected;

  const SearchFilterBar({super.key, this.onDistrictSelected});

  @override
  ConsumerState<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends ConsumerState<SearchFilterBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateNotifierProvider);
    final allDistrictsAsync = ref.watch(districtsDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allDistricts = allDistrictsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <DistrictErosionModel>[],
    );

    // Filter suggestions based on query
    final query = _controller.text.trim().toLowerCase();
    final matchingDistricts = query.isEmpty
        ? <DistrictErosionModel>[]
        : allDistricts.where((d) {
            final nameMatch = d.districtName.toLowerCase().contains(query);
            final mlMatch = d.malayalamName.contains(query);
            final talukMatch = d.taluks.any((t) => t.toLowerCase().contains(query));
            return nameMatch || mlMatch || talukMatch;
          }).take(5).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Search Card
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface.withOpacity(0.95) : AppColors.lightSurface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.forestGreenLight),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search district or taluk (e.g. Idukki, Devikulam, Vythiri)...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (val) {
                      ref.read(mapStateNotifierProvider.notifier).setSearchQuery(val);
                      setState(() {
                        _showSuggestions = val.isNotEmpty;
                      });
                    },
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _controller.clear();
                      ref.read(mapStateNotifierProvider.notifier).clearSearch();
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  ),
                const SizedBox(width: 4),
                // Layer Switcher Button
                IconButton(
                  tooltip: 'Satellite & Map Layers',
                  icon: const Icon(Icons.layers_outlined, color: AppColors.forestGreenLight),
                  onPressed: () => LayerSwitcherSheet.show(context),
                ),
                // Data Source Dialog Button
                IconButton(
                  tooltip: 'Data Source Settings',
                  icon: const Icon(Icons.tune_rounded, color: AppColors.ochreClay),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const DataSourceDialog(),
                    );
                  },
                ),
                // Attribution Info
                IconButton(
                  tooltip: 'Data Attribution',
                  icon: const Icon(Icons.info_outline_rounded, size: 20),
                  onPressed: () => AttributionFooter.show(context),
                ),
              ],
            ),
          ),
        ),

        // Autocomplete Suggestion Overlay
        if (_showSuggestions && matchingDistricts.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: matchingDistricts.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              itemBuilder: (context, index) {
                final d = matchingDistricts[index];
                final score = d.getScoreForYear(mapState.activeYear);
                final category = d.getCategoryForYear(mapState.activeYear);
                final color = AppColors.colorForErosionScore(score);

                // Highlight matching taluks
                final matchingTaluks = d.taluks
                    .where((t) => t.toLowerCase().contains(query))
                    .join(', ');

                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.25),
                    child: Icon(Icons.place_rounded, color: color, size: 18),
                  ),
                  title: Row(
                    children: [
                      Text(
                        d.districtName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        d.malayalamName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color, width: 0.8),
                        ),
                        child: Text(
                          '$category (${score.toStringAsFixed(1)})',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: matchingTaluks.isNotEmpty
                      ? Text(
                          'Taluk match: $matchingTaluks',
                          style: const TextStyle(fontSize: 11, color: AppColors.ochreClay),
                        )
                      : Text(
                          d.dominantLandUse,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  onTap: () {
                    _controller.text = d.districtName;
                    ref.read(mapStateNotifierProvider.notifier).selectDistrict(d);
                    setState(() {
                      _showSuggestions = false;
                    });
                    _focusNode.unfocus();
                    widget.onDistrictSelected?.call(d);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
