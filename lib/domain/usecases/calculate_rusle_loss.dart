import '../../core/constants/rusle_constants.dart';
import '../../data/models/rusle_factors_model.dart';

/// Pure domain usecase to evaluate the Revised Universal Soil Loss Equation (RUSLE).
/// Supports both calculating baseline loss and simulating soil conservation interventions.
class CalculateRusleLoss {
  const CalculateRusleLoss();

  /// Computes soil loss: A = R * K * LS * C * P (t/ha/year)
  double execute({
    required double r,
    required double k,
    required double ls,
    required double c,
    required double p,
  }) {
    final raw = r * k * ls * c * p;
    return double.parse(raw.toStringAsFixed(2));
  }

  /// Recalculates RusleFactorsModel with new factors
  RusleFactorsModel recalculate(RusleFactorsModel current, {
    double? r,
    double? k,
    double? ls,
    double? c,
    double? p,
  }) {
    return current.copyWith(
      rFactor: r,
      kFactor: k,
      lsFactor: ls,
      cFactor: c,
      pFactor: p,
    );
  }

  /// Categorize score into Low, Moderate, High, Severe, Very Severe
  String categorize(double soilLoss) {
    return RusleConstants.categorize(soilLoss);
  }

  /// Conservation scenario simulation:
  /// Calculates soil loss reduction percentage if farmers introduce
  /// bench terracing or vegetative contour hedges (reducing P factor).
  double calculateReductionPercentage({
    required double baselineLoss,
    required double newP,
    required RusleFactorsModel currentFactors,
  }) {
    if (baselineLoss <= 0) return 0.0;
    final simulatedLoss = execute(
      r: currentFactors.rFactor,
      k: currentFactors.kFactor,
      ls: currentFactors.lsFactor,
      c: currentFactors.cFactor,
      p: newP,
    );
    final diff = baselineLoss - simulatedLoss;
    return double.parse(((diff / baselineLoss) * 100).toStringAsFixed(1));
  }
}
