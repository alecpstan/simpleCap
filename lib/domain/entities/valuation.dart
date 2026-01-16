import 'package:freezed_annotation/freezed_annotation.dart';

part 'valuation.freezed.dart';
part 'valuation.g.dart';

/// Methods for calculating company valuations.
enum ValuationMethod {
  /// Direct manual entry.
  manual,

  /// Revenue/ARR multiple.
  revenueMultiple,

  /// Comparable company analysis.
  comparables,

  /// Discounted cash flow.
  dcf,

  /// Scorecard method for early-stage.
  scorecard,

  /// Berkus method for pre-revenue.
  berkus;

  String get displayName => switch (this) {
    manual => 'Manual Entry',
    revenueMultiple => 'Revenue Multiple',
    comparables => 'Comparable Companies',
    dcf => 'Discounted Cash Flow',
    scorecard => 'Scorecard Method',
    berkus => 'Berkus Method',
  };

  String get description => switch (this) {
    manual => 'Enter a valuation directly',
    revenueMultiple => 'Value based on revenue × industry multiple',
    comparables => 'Value based on similar company multiples',
    dcf => 'Present value of projected future cash flows',
    scorecard => 'Weighted scoring against key factors',
    berkus => 'Pre-revenue milestone-based valuation',
  };
}

/// A point-in-time company valuation.
///
/// Valuations can be created manually or via calculation methods.
/// The methodParams stores inputs for wizard-based valuations,
/// allowing users to edit and recalculate.
@freezed
class Valuation with _$Valuation {
  const Valuation._();

  const factory Valuation({
    required String id,
    required String companyId,
    required DateTime date,

    /// Pre-money valuation in AUD.
    required double preMoneyValue,

    /// Method used to calculate.
    required ValuationMethod method,

    /// Parameters used for calculation (JSON).
    /// Structure depends on method.
    String? methodParamsJson,

    String? notes,
    required DateTime createdAt,
  }) = _Valuation;

  factory Valuation.fromJson(Map<String, dynamic> json) =>
      _$ValuationFromJson(json);

  /// Whether this valuation was calculated via wizard.
  bool get isCalculated => method != ValuationMethod.manual;

  /// Calculate share price given total shares.
  double sharePrice(int totalShares) {
    if (totalShares == 0) return 0;
    return preMoneyValue / totalShares;
  }
}
