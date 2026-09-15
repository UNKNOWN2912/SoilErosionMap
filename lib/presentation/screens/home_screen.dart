import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/district_erosion_model.dart';
import '../state/map_providers.dart';
import '../widgets/common/demo_data_banner.dart';
import '../widgets/controls/map_legend_widget.dart';
import '../widgets/controls/search_filter_bar.dart';
import '../widgets/controls/time_slider_widget.dart';
import '../widgets/details/district_summary_sheet.dart';
import '../widgets/map/kerala_map_view.dart';

/// Main screen of the Kerala Soil Erosion Monitor application.
/// Provides a responsive layout supporting Web desktop, tablets, and mobile screens.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final MapController _mapController = MapController();

  void _onDistrictSelected(DistrictErosionModel district, bool isWideScreen) {
    // Smoothly animate map center to the district's centroid
    _mapController.move(district.geometry.centroid, 8.8);

    if (!isWideScreen) {
      _openMobileBottomSheet(district);
    }
  }

  void _openMobileBottomSheet(DistrictErosionModel district) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scrollController) => DistrictSummarySheet(
          district: district,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsDataProvider);
    final mapState = ref.watch(mapStateNotifierProvider);
    final isWideScreen = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      body: districtsAsync.when(
        loading: () => _buildLoadingView(),
        error: (err, stack) => _buildErrorView(err),
        data: (_) {
          return Row(
            children: [
              // Main Interactive Map Area
              Expanded(
                child: Stack(
                  children: [
                    // 1. Full-screen map
                    KeralaMapView(
                      mapController: _mapController,
                      onDistrictSelected: (d) => _onDistrictSelected(d, isWideScreen),
                    ),

                    // 2. Top Bar (Search + Watermark)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SearchFilterBar(
                                  onDistrictSelected: (d) => _onDistrictSelected(d, isWideScreen),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const DemoDataBanner(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 3. Floating Legend
                    const Positioned(
                      left: 16,
                      bottom: 110,
                      child: MapLegendWidget(),
                    ),

                    // 4. Bottom Time Scrubber
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).padding.bottom + 12,
                      child: const TimeSliderWidget(),
                    ),
                  ],
                ),
              ),

              // Desktop / Tablet Side Panel for District Details
              if (isWideScreen && mapState.selectedDistrict != null)
                DistrictSummarySheet(
                  district: mapState.selectedDistrict!,
                  isSidePanel: true,
                  onClose: () {
                    ref.read(mapStateNotifierProvider.notifier).selectDistrict(null);
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: AppColors.darkBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.forestGreenLight.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestGreenLight),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading Kerala Geospatial Data...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Parsing district boundaries and satellite RUSLE layers',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    return Container(
      color: AppColors.darkBackground,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.lateriteTerracotta, size: 54),
            const SizedBox(height: 16),
            const Text(
              'Geospatial Feed Unavailable',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(mapStateNotifierProvider.notifier).setDataSourceMode('bundled');
                ref.invalidate(districtsDataProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Load Offline Bundled GeoJSON'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreenLight,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
