import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/hive_cache_service.dart';
import '../../../data/repositories/gee_proxy_erosion_repo.dart';
import '../../state/map_providers.dart';

class DataSourceDialog extends ConsumerStatefulWidget {
  const DataSourceDialog({super.key});

  @override
  ConsumerState<DataSourceDialog> createState() => _DataSourceDialogState();
}

class _DataSourceDialogState extends ConsumerState<DataSourceDialog> {
  late String _selectedMode;
  late TextEditingController _geeUrlController;
  late TextEditingController _geeKeyController;
  late TextEditingController _bhuvanTokenController;
  int _cachedCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedMode = ref.read(mapStateNotifierProvider).selectedDataSourceMode;

    _geeUrlController = TextEditingController(
      text: HiveCacheService.getSetting('gee_proxy_url',
          defaultValue: GeeProxyErosionRepository.defaultEndpoint) as String,
    );
    _geeKeyController = TextEditingController(
      text: HiveCacheService.getSetting('gee_api_key', defaultValue: '') as String,
    );
    _bhuvanTokenController = TextEditingController(
      text: HiveCacheService.getSetting('bhuvan_token', defaultValue: '') as String,
    );
    _cachedCount = HiveCacheService.getCachedItemCount();
  }

  @override
  void dispose() {
    _geeUrlController.dispose();
    _geeKeyController.dispose();
    _bhuvanTokenController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    HiveCacheService.saveSetting('gee_proxy_url', _geeUrlController.text.trim());
    HiveCacheService.saveSetting('gee_api_key', _geeKeyController.text.trim());
    HiveCacheService.saveSetting('bhuvan_token', _bhuvanTokenController.text.trim());

    ref.read(mapStateNotifierProvider.notifier).setDataSourceMode(_selectedMode);
    ref.invalidate(districtsDataProvider);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data source updated to: ${_getModeName(_selectedMode)}'),
        backgroundColor: AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getModeName(String mode) {
    switch (mode) {
      case 'gee_proxy':
        return 'Google Earth Engine Proxy';
      case 'bhuvan_wms':
        return 'ISRO Bhuvan Portal';
      default:
        return 'Bundled GeoJSON (Demo Data)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                    child: const Icon(Icons.satellite_alt_rounded, color: AppColors.forestGreenLight),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Geospatial Data Source',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Select live satellite feed or offline sample GeoJSON',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    // Mode 1: Bundled GeoJSON
                    _buildOptionTile(
                      mode: 'bundled',
                      title: 'Bundled GeoJSON (Demo Data Mode)',
                      subtitle:
                          'Official Kerala district boundaries with pre-processed RUSLE scores for 2018–2024. Operates 100% offline without API keys.',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.lateriteTerracotta,
                    ),
                    const SizedBox(height: 8),

                    // Mode 2: GEE Proxy
                    _buildOptionTile(
                      mode: 'gee_proxy',
                      title: 'Google Earth Engine (GEE Proxy)',
                      subtitle:
                          'Connects to a custom Python backend (tools/gee_rusle_processor.py) computing live RUSLE on Sentinel-2, SRTM, and CHIRPS.',
                      icon: Icons.cloud_sync_rounded,
                      color: AppColors.sentinelBlue,
                    ),
                    if (_selectedMode == 'gee_proxy') ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                        child: Column(
                          children: [
                            TextField(
                              controller: _geeUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Proxy Endpoint URL',
                                hintText: 'http://localhost:8000/api/v1/erosion/kerala-districts',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _geeKeyController,
                              decoration: const InputDecoration(
                                labelText: 'GEE API Key / Bearer Token (Optional)',
                                hintText: 'Enter proxy auth token if required',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Mode 3: ISRO Bhuvan
                    _buildOptionTile(
                      mode: 'bhuvan_wms',
                      title: 'ISRO Bhuvan Geoportal (NRSC WMS/WFS)',
                      subtitle:
                          'National Remote Sensing Centre (NRSC) Land Degradation & Soil Erosion vector layers for Kerala.',
                      icon: Icons.public_rounded,
                      color: AppColors.isroSaffron,
                    ),
                    if (_selectedMode == 'bhuvan_wms') ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                        child: TextField(
                          controller: _bhuvanTokenController,
                          decoration: const InputDecoration(
                            labelText: 'Bhuvan User Token / Key',
                            hintText: 'Enter Bhuvan session or token',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13),
                          obscureText: true,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Offline cache stats
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.offline_pin_rounded, color: AppColors.forestGreenLight, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Offline Cache: $_cachedCount items stored in Hive',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await HiveCacheService.clearAllCache();
                              setState(() {
                                _cachedCount = HiveCacheService.getCachedItemCount();
                              });
                            },
                            child: const Text('Clear', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Save & Apply'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkCard : AppColors.lightCard)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: mode,
              groupValue: _selectedMode,
              activeColor: color,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMode = val);
                }
              },
            ),
            const SizedBox(width: 4),
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
