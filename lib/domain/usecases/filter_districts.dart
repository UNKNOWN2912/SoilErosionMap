import '../../data/models/district_erosion_model.dart';

/// Filters and searches districts by query (English or Malayalam district name, or taluk name),
/// and by active risk categories or terrain zones.
class FilterDistricts {
  const FilterDistricts();

  List<DistrictErosionModel> execute({
    required List<DistrictErosionModel> allDistricts,
    required String searchQuery,
    required Set<String> activeCategories,
    required String activeYear,
    String? terrainFilter,
  }) {
    final query = searchQuery.toLowerCase().trim();

    return allDistricts.where((district) {
      // 1. Search Query Match
      bool matchesQuery = true;
      if (query.isNotEmpty) {
        final nameMatches = district.districtName.toLowerCase().contains(query);
        final malayalamMatches = district.malayalamName.contains(query);
        final hqMatches = district.headquarters.toLowerCase().contains(query);
        final talukMatches = district.taluks.any((t) => t.toLowerCase().contains(query));

        matchesQuery = nameMatches || malayalamMatches || hqMatches || talukMatches;
      }

      if (!matchesQuery) return false;

      // 2. Risk Category Match for the current year
      final categoryForYear = district.getCategoryForYear(activeYear);
      if (activeCategories.isNotEmpty && !activeCategories.contains(categoryForYear)) {
        return false;
      }

      // 3. Terrain filter (if specified)
      if (terrainFilter != null && terrainFilter != 'All') {
        if (!district.terrainCategory.toLowerCase().contains(terrainFilter.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
