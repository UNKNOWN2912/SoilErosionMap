import 'package:flutter_test/flutter_test.dart';
import 'package:kerala_soil_erosion_monitor/core/constants/rusle_constants.dart';
import 'package:kerala_soil_erosion_monitor/core/utils/geojson_parser.dart';
import 'package:kerala_soil_erosion_monitor/data/models/district_erosion_model.dart';
import 'package:kerala_soil_erosion_monitor/data/models/rusle_factors_model.dart';
import 'package:kerala_soil_erosion_monitor/data/models/time_series_record.dart';
import 'package:kerala_soil_erosion_monitor/domain/usecases/filter_districts.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('FilterDistricts UseCase Tests', () {
    const filter = FilterDistricts();

    final dummyGeometry = DistrictGeometry(
      polygonRings: [],
      centroid: const LatLng(10.0, 76.0),
      minLat: 9.0,
      maxLat: 11.0,
      minLng: 75.0,
      maxLng: 77.0,
    );

    final idukki = DistrictErosionModel(
      id: 'idukki',
      districtName: 'Idukki',
      malayalamName: 'ഇടുക്കി',
      headquarters: 'Painavu',
      areaSqKm: 4358,
      dominantLandUse: 'Tea & Forest',
      soilType: 'Forest Loam',
      terrainCategory: 'High Western Ghats Escarpment',
      taluks: ['Devikulam', 'Peerumade', 'Udumbanchola'],
      rusleFactors: RusleFactorsModel.calculate(
        rFactor: 6000,
        kFactor: 0.035,
        lsFactor: 16.0,
        cFactor: 0.20,
        pFactor: 0.70,
      ),
      riskCategory: RusleConstants.categoryVerySevere,
      timeSeries: {
        '2024': TimeSeriesRecord.fromEntry('2024', 58.2),
      },
      conservationMeasures: [],
      geometry: dummyGeometry,
      dataSource: 'Test',
      timestamp: DateTime.now(),
      isSampleData: true,
    );

    final alappuzha = DistrictErosionModel(
      id: 'alappuzha',
      districtName: 'Alappuzha',
      malayalamName: 'ആലപ്പുഴ',
      headquarters: 'Alappuzha',
      areaSqKm: 1414,
      dominantLandUse: 'Paddy',
      soilType: 'Coastal Alluvium',
      terrainCategory: 'Coastal Plains',
      taluks: ['Ambalappuzha', 'Cherthala', 'Kuttanad'],
      rusleFactors: RusleFactorsModel.calculate(
        rFactor: 2400,
        kFactor: 0.018,
        lsFactor: 1.1,
        cFactor: 0.08,
        pFactor: 0.85,
      ),
      riskCategory: RusleConstants.categoryLow,
      timeSeries: {
        '2024': TimeSeriesRecord.fromEntry('2024', 3.2),
      },
      conservationMeasures: [],
      geometry: dummyGeometry,
      dataSource: 'Test',
      timestamp: DateTime.now(),
      isSampleData: true,
    );

    final all = [idukki, alappuzha];

    test('matches by district name', () {
      final res = filter.execute(
        allDistricts: all,
        searchQuery: 'Idukki',
        activeCategories: Set.from(RusleConstants.allCategories),
        activeYear: '2024',
      );
      expect(res.length, 1);
      expect(res.first.districtName, 'Idukki');
    });

    test('matches by Malayalam district name', () {
      final res = filter.execute(
        allDistricts: all,
        searchQuery: 'ആലപ്പുഴ',
        activeCategories: Set.from(RusleConstants.allCategories),
        activeYear: '2024',
      );
      expect(res.length, 1);
      expect(res.first.districtName, 'Alappuzha');
    });

    test('matches by taluk name (Devikulam)', () {
      final res = filter.execute(
        allDistricts: all,
        searchQuery: 'Devikulam',
        activeCategories: Set.from(RusleConstants.allCategories),
        activeYear: '2024',
      );
      expect(res.length, 1);
      expect(res.first.districtName, 'Idukki');
    });

    test('filters by category', () {
      final res = filter.execute(
        allDistricts: all,
        searchQuery: '',
        activeCategories: {RusleConstants.categoryLow},
        activeYear: '2024',
      );
      expect(res.length, 1);
      expect(res.first.districtName, 'Alappuzha');
    });
  });
}
