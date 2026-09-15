/// Model representing the 5 scientific factors of the
/// Revised Universal Soil Loss Equation (RUSLE): A = R * K * LS * C * P.
class RusleFactorsModel {
  /// R: Rainfall-Runoff Erosivity Factor (MJ mm / ha h yr)
  final double rFactor;

  /// K: Soil Erodibility Factor (t ha h / ha MJ mm)
  final double kFactor;

  /// LS: Topographic Factor (Slope Length L and Steepness S)
  final double lsFactor;

  /// C: Cover-Management Factor (derived from satellite NDVI, 0.0 - 1.0)
  final double cFactor;

  /// P: Support Conservation Practice Factor (contouring, terracing, 0.0 - 1.0)
  final double pFactor;

  /// Computed Annual Soil Loss A (metric tons / hectare / year)
  final double calculatedLoss;

  const RusleFactorsModel({
    required this.rFactor,
    required this.kFactor,
    required this.lsFactor,
    required this.cFactor,
    required this.pFactor,
    required this.calculatedLoss,
  });

  /// Factory to construct model and dynamically calculate A if not explicitly passed
  factory RusleFactorsModel.calculate({
    required double rFactor,
    required double kFactor,
    required double lsFactor,
    required double cFactor,
    required double pFactor,
    double? explicitLoss,
  }) {
    final loss = explicitLoss ?? (rFactor * kFactor * lsFactor * cFactor * pFactor);
    return RusleFactorsModel(
      rFactor: rFactor,
      kFactor: kFactor,
      lsFactor: lsFactor,
      cFactor: cFactor,
      pFactor: pFactor,
      calculatedLoss: double.parse(loss.toStringAsFixed(2)),
    );
  }

  factory RusleFactorsModel.fromJson(Map<String, dynamic> json) {
    final r = (json['R'] as num?)?.toDouble() ?? 3000.0;
    final k = (json['K'] as num?)?.toDouble() ?? 0.028;
    final ls = (json['LS'] as num?)?.toDouble() ?? 5.0;
    final c = (json['C'] as num?)?.toDouble() ?? 0.15;
    final p = (json['P'] as num?)?.toDouble() ?? 0.75;
    final explicitA = (json['A'] as num?)?.toDouble();

    return RusleFactorsModel.calculate(
      rFactor: r,
      kFactor: k,
      lsFactor: ls,
      cFactor: c,
      pFactor: p,
      explicitLoss: explicitA,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'R': rFactor,
      'K': kFactor,
      'LS': lsFactor,
      'C': cFactor,
      'P': pFactor,
      'A': calculatedLoss,
    };
  }

  RusleFactorsModel copyWith({
    double? rFactor,
    double? kFactor,
    double? lsFactor,
    double? cFactor,
    double? pFactor,
  }) {
    final r = rFactor ?? this.rFactor;
    final k = kFactor ?? this.kFactor;
    final ls = lsFactor ?? this.lsFactor;
    final c = cFactor ?? this.cFactor;
    final p = pFactor ?? this.pFactor;
    return RusleFactorsModel.calculate(
      rFactor: r,
      kFactor: k,
      lsFactor: ls,
      cFactor: c,
      pFactor: p,
    );
  }
}
