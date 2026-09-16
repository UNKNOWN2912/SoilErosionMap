import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/district_erosion_model.dart';
import '../../../data/models/taluk_erosion_model.dart';
import '../../state/map_providers.dart';
import '../../state/map_state.dart';

/// Hierarchical and searchable Region Selector modal allowing users to
/// pick a District or a specific Taluk across Kerala with instant fly-to.
class RegionSelectorDialog extends ConsumerStatefulWidget {
  final void Function(DistrictErosionModel? district, TalukErosionModel? taluk)? onRegionSelected;

  const RegionSelectorDialog({super.key, this.onRegionSelected});

  static void show(BuildContext context, {void Function(DistrictErosionModel?, TalukErosionModel?)? onSelected}) {
    showDialog(
      context: context,
      builder: (_) => RegionSelectorDialog(onRegionSelected: onSelected),
    );
  }

  @override
  ConsumerState<RegionSelectorDialog> createState() => _RegionSelectorDialogState();
}

class _RegionSelectorDialogState extends ConsumerState<RegionSelectorDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // If currently in taluk mode, open taluks tab by default
    final currentGranularity = ref.read(mapStateNotifierProvider).granularity;
    if (currentGranularity == GranularityLevel.taluk) {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final districtsAsync = ref.watch(districtsDataProvider);
    final taluksAsync = ref.watch(taluksDataProvider);
    final activeYear = ref.watch(mapStateNotifierProvider.select((s) => s.activeYear));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreenLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.travel_explore_rounded, color: AppColors.forestGreenLight),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Geographic Region',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Choose an administrative district or high-precision taluk',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Input
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search region (e.g. Devikulam, Munnar, Idukki, Kuttanad)...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _filterText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _filterText = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
                onChanged: (val) {
                  setState(() => _filterText = val.toLowerCase().trim());
                },
              ),
              const SizedBox(height: 12),

              // Tabs: Districts vs Taluks
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.forestGreenLight,
                labelColor: AppColors.forestGreenLight,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Districts (14)'),
                  Tab(text: 'Taluks & Micro-Regions (61)'),
                ],
              ),
              const SizedBox(height: 10),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Districts
                    districtsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (districts) {
                        final filtered = districts.where((d) {
                          if (_filterText.isEmpty) return true;
                          return d.districtName.toLowerCase().contains(_filterText) ||
                              d.malayalamName.contains(_filterText) ||
                              d.taluks.any((t) => t.toLowerCase().contains(_filterText));
                        }).toList();

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          itemBuilder: (context, index) {
                            final d = filtered[index];
                            final score = d.getScoreForYear(activeYear);
                            final cat = d.getCategoryForYear(activeYear);
                            final color = AppColors.colorForErosionScore(score);

                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: color,
                                child: Text(
                                  score.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text('${d.districtName} (${d.malayalamName})',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${d.terrainCategory} • ${d.taluks.length} taluks',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color, width: 0.8),
                                ),
                                child: Text(
                                  '$cat (${score.toStringAsFixed(1)})',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                                ),
                              ),
                              onTap: () {
                                ref.read(mapStateNotifierProvider.notifier).setGranularity(GranularityLevel.district);
                                ref.read(mapStateNotifierProvider.notifier).selectDistrict(d);
                                widget.onRegionSelected?.call(d, null);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    ),

                    // Tab 2: Taluks
                    taluksAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (taluks) {
                        final filtered = taluks.where((t) {
                          if (_filterText.isEmpty) return true;
                          return t.talukName.toLowerCase().contains(_filterText) ||
                              t.districtName.toLowerCase().contains(_filterText) ||
                              t.malayalamName.contains(_filterText);
                        }).toList();

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          itemBuilder: (context, index) {
                            final t = filtered[index];
                            final score = t.getScoreForYear(activeYear);
                            final cat = t.getCategoryForYear(activeYear);
                            final color = AppColors.colorForErosionScore(score);

                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: color,
                                child: Text(
                                  score.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(t.talukName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  Text('(${t.districtName})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              subtitle: Text(
                                'Elev: ${t.elevationMeters.toInt()}m • Slope: ${t.slopeDegrees.toStringAsFixed(1)}° • ${t.dominantLandUse}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color, width: 0.8),
                                ),
                                child: Text(
                                  '$cat (${score.toStringAsFixed(1)})',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                                ),
                              ),
                              onTap: () {
                                ref.read(mapStateNotifierProvider.notifier).setGranularity(GranularityLevel.taluk);
                                ref.read(mapStateNotifierProvider.notifier).selectTaluk(t);
                                widget.onRegionSelected?.call(null, t);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
