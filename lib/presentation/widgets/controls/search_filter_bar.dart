import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../../data/models/taluk_erosion_model.dart';
import '../../state/map_providers.dart';
import '../../state/map_state.dart';
import '../common/attribution_footer.dart';
import '../common/data_source_dialog.dart';
import 'layer_switcher_sheet.dart';
import 'region_selector_dialog.dart';

/// Top search and region selection control bar with autocomplete,
/// granularity switching (District vs Taluk), ROI area tool, and data settings.
class SearchFilterBar extends ConsumerStatefulWidget {
  final void Function(DistrictErosionModel district)? onDistrictSelected;
  final void Function(TalukErosionModel taluk)? onTalukSelected;

  const SearchFilterBar({
    super.key,
    this.onDistrictSelected,
    this.onTalukSelected,
  });

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
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    final allDistrictsAsync = ref.watch(districtsDataProvider);
    final allTaluksAsync = ref.watch(taluksDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allDistricts = allDistrictsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <DistrictErosionModel>[],
    );
    final allTaluks = allTaluksAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <TalukErosionModel>[],
    );

    // Filter suggestions based on query
    final query = _controller.text.trim().toLowerCase();
    final matchingDistricts = query.isEmpty
        ? <DistrictErosionModel>[]
        : allDistricts.where((d) {
            final nameMatch = d.districtName.toLowerCase().contains(query);
            final mlMatch = d.malayalamName.contains(query);
            return nameMatch || mlMatch;
          }).take(3).toList();

    final matchingTaluks = query.isEmpty
        ? <TalukErosionModel>[]
        : allTaluks.where((t) {
            final nameMatch = t.talukName.toLowerCase().contains(query);
            final distMatch = t.districtName.toLowerCase().contains(query);
            final mlMatch = t.malayalamName.contains(query);
            return nameMatch || distMatch || mlMatch;
          }).take(4).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Main Search & Action Bar
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
                      hintText: 'Search 61 taluks or 14 districts (e.g. Devikulam, Vythiri, Idukki)...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13.5),
                    onChanged: (val) {
                      notifier.setSearchQuery(val);
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
                      notifier.clearSearch();
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  ),

                // Select Region Hierarchical Button
                ElevatedButton.icon(
                  onPressed: () {
                    RegionSelectorDialog.show(
                      context,
                      onSelected: (district, taluk) {
                        if (district != null) widget.onDistrictSelected?.call(district);
                        if (taluk != null) widget.onTalukSelected?.call(taluk);
                      },
                    );
                  },
                  icon: const Icon(Icons.travel_explore_rounded, size: 16),
                  label: const Text('Select Region', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreenLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 6),

                // Custom ROI Tool Toggle Button
                IconButton(
                  tooltip: mapState.isRoiToolActive ? 'Exit Custom Area Tool' : 'Select Custom Area on Map (ROI)',
                  icon: Icon(
                    mapState.isRoiToolActive ? Icons.crop_free_rounded : Icons.crop_rounded,
                    color: mapState.isRoiToolActive ? AppColors.lateriteTerracotta : Colors.grey,
                  ),
                  onPressed: () => notifier.toggleRoiTool(null),
                ),

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

        // Sub-Bar: Granularity Switcher Pills
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface.withOpacity(0.92) : AppColors.lightSurface.withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGranularityChip(
                    label: 'Districts (14)',
                    level: GranularityLevel.district,
                    active: mapState.granularity == GranularityLevel.district,
                    onTap: () => notifier.setGranularity(GranularityLevel.district),
                  ),
                  const SizedBox(width: 4),
                  _buildGranularityChip(
                    label: 'Taluk Precision (61)',
                    level: GranularityLevel.taluk,
                    active: mapState.granularity == GranularityLevel.taluk,
                    onTap: () => notifier.setGranularity(GranularityLevel.taluk),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (mapState.selectedTaluk != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.forestGreenLight, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.forestGreenLight),
                    const SizedBox(width: 6),
                    Text(
                      'Taluk: ${mapState.selectedTaluk!.talukName}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestGreenLight),
                    ),
                  ],
                ),
              ),
            if (mapState.selectedDistrict != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lateriteTerracotta.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lateriteTerracotta, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.lateriteTerracotta),
                    const SizedBox(width: 6),
                    Text(
                      'District: ${mapState.selectedDistrict!.districtName}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lateriteTerracotta),
                    ),
                  ],
                ),
              ),
          ],
        ),

        // Autocomplete Suggestions Dropdown
        if (_showSuggestions && (matchingDistricts.isNotEmpty || matchingTaluks.isNotEmpty))
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
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                if (matchingTaluks.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 6, 14, 2),
                    child: Text('TALUKS (SUB-REGIONS)', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  ...matchingTaluks.map((t) {
                    final score = t.getScoreForYear(mapState.activeYear);
                    final cat = t.getCategoryForYear(mapState.activeYear);
                    final color = AppColors.colorForErosionScore(score);

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: color,
                        child: Text(score.toStringAsFixed(0), style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('${t.talukName} (${t.districtName})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text('Elev: ${t.elevationMeters.toInt()}m • Slope: ${t.slopeDegrees.toStringAsFixed(1)}° • $cat', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      onTap: () {
                        _controller.text = t.talukName;
                        notifier.setGranularity(GranularityLevel.taluk);
                        notifier.selectTaluk(t);
                        setState(() => _showSuggestions = false);
                        _focusNode.unfocus();
                        widget.onTalukSelected?.call(t);
                      },
                    );
                  }),
                ],
                if (matchingDistricts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 6, 14, 2),
                    child: Text('DISTRICTS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  ...matchingDistricts.map((d) {
                    final score = d.getScoreForYear(mapState.activeYear);
                    final cat = d.getCategoryForYear(mapState.activeYear);
                    final color = AppColors.colorForErosionScore(score);

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: color,
                        child: Text(score.toStringAsFixed(0), style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('${d.districtName} (${d.malayalamName})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text('${d.terrainCategory} • $cat (${score.toStringAsFixed(1)})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      onTap: () {
                        _controller.text = d.districtName;
                        notifier.setGranularity(GranularityLevel.district);
                        notifier.selectDistrict(d);
                        setState(() => _showSuggestions = false);
                        _focusNode.unfocus();
                        widget.onDistrictSelected?.call(d);
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGranularityChip({
    required String label,
    required GranularityLevel level,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.forestGreenLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
