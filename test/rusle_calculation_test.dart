import 'package:flutter_test/flutter_test.dart';
import 'package:kerala_soil_erosion_monitor/core/constants/rusle_constants.dart';
import 'package:kerala_soil_erosion_monitor/data/models/rusle_factors_model.dart';
import 'package:kerala_soil_erosion_monitor/domain/usecases/calculate_rusle_loss.dart';

void main() {
  group('RUSLE Equation & Categorization Tests', () {
    const calculator = CalculateRusleLoss();

    test('calculates soil loss A = R * K * LS * C * P accurately', () {
      // Example values: R=3000, K=0.03, LS=5.0, C=0.15, P=0.8
      // Expected A = 3000 * 0.03 * 5.0 * 0.15 * 0.8 = 54.0
      final loss = calculator.execute(
        r: 3000.0,
        k: 0.03,
        ls: 5.0,
        c: 0.15,
        p: 0.8,
      );

      expect(loss, 54.0);
    });

    test('categorizes soil loss into standard ICAR / NBSS&LUP thresholds', () {
      expect(RusleConstants.categorize(3.2), RusleConstants.categoryLow);
      expect(RusleConstants.categorize(7.5), RusleConstants.categoryModerate);
      expect(RusleConstants.categorize(14.8), RusleConstants.categoryHigh);
      expect(RusleConstants.categorize(28.4), RusleConstants.categorySevere);
      expect(RusleConstants.categorize(55.6), RusleConstants.categoryVerySevere);
    });

    test('simulates conservation intervention reduction percentage', () {
      final factors = RusleFactorsModel.calculate(
        rFactor: 4000.0,
        kFactor: 0.03,
        lsFactor: 8.0,
        cFactor: 0.20,
        pFactor: 0.80, // Baseline P = 0.80
      );

      // Baseline A = 4000 * 0.03 * 8 * 0.2 * 0.8 = 153.6
      expect(factors.calculatedLoss, 153.6);

      // Reduced P to 0.40 (e.g. bench terracing & vetiver hedges)
      final reduction = calculator.calculateReductionPercentage(
        baselineLoss: factors.calculatedLoss,
        newP: 0.40,
        currentFactors: factors,
      );

      // Should be exactly 50% reduction
      expect(reduction, 50.0);
    });
  });
}
