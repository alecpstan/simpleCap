import 'package:uuid/uuid.dart';

/// Methods available for calculating company valuations.
enum ValuationMethod {
  /// Direct manual entry of valuation
  manual,

  /// Revenue/ARR multiple based on industry benchmarks
  revenueMultiple,

  /// Comparable company analysis
  comparables,

  /// Discounted Cash Flow
  dcf,

  /// Scorecard method for early-stage startups
  scorecard,

  /// Berkus method for pre-revenue startups
  berkus,
}

/// Extension to provide display names for valuation methods.
extension ValuationMethodExtension on ValuationMethod {
  String get displayName {
    switch (this) {
      case ValuationMethod.manual:
        return 'Manual Entry';
      case ValuationMethod.revenueMultiple:
        return 'Revenue Multiple';
      case ValuationMethod.comparables:
        return 'Comparable Companies';
      case ValuationMethod.dcf:
        return 'Discounted Cash Flow';
      case ValuationMethod.scorecard:
        return 'Scorecard Method';
      case ValuationMethod.berkus:
        return 'Berkus Method';
    }
  }

  String get description {
    switch (this) {
      case ValuationMethod.manual:
        return 'Enter a valuation directly';
      case ValuationMethod.revenueMultiple:
        return 'Value based on revenue × industry multiple';
      case ValuationMethod.comparables:
        return 'Value based on similar company multiples';
      case ValuationMethod.dcf:
        return 'Present value of projected future cash flows';
      case ValuationMethod.scorecard:
        return 'Weighted scoring against key factors';
      case ValuationMethod.berkus:
        return 'Pre-revenue milestone-based valuation';
    }
  }

  /// Whether this method was created using a wizard (has editable params)
  bool get isWizardMethod => this != ValuationMethod.manual;
}

/// Represents a company valuation at a point in time.
///
/// Valuations can be created manually or via calculation methods (wizard).
/// When created via wizard, the [methodParams] stores the inputs used,
/// allowing users to edit and recalculate later.
class Valuation {
  final String id;

  /// Date of this valuation
  final DateTime date;

  /// Pre-money valuation amount in AUD
  final double preMoneyValue;

  /// Method used to calculate this valuation
  final ValuationMethod method;

  /// Parameters used for wizard-based valuations (for editing)
  /// Structure depends on the method:
  /// - revenueMultiple: { industry, revenue, multiple }
  /// - comparables: { comparables: [{name, multiple}], metric }
  /// - dcf: { projections, terminalGrowth, discountRate }
  /// - scorecard: { baseValuation, scores: {...} }
  /// - berkus: { scores: {...} }
  final Map<String, dynamic>? methodParams;

  /// Optional notes about this valuation
  final String? notes;

  Valuation({
    String? id,
    required this.date,
    required this.preMoneyValue,
    required this.method,
    this.methodParams,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  /// Whether this valuation was created using a wizard method
  bool get isWizardCreated => method.isWizardMethod;

  /// Create a copy with updated fields
  Valuation copyWith({
    DateTime? date,
    double? preMoneyValue,
    ValuationMethod? method,
    Map<String, dynamic>? methodParams,
    String? notes,
  }) {
    return Valuation(
      id: id,
      date: date ?? this.date,
      preMoneyValue: preMoneyValue ?? this.preMoneyValue,
      method: method ?? this.method,
      methodParams: methodParams ?? this.methodParams,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'preMoneyValue': preMoneyValue,
    'method': method.index,
    'methodParams': methodParams,
    'notes': notes,
  };

  factory Valuation.fromJson(Map<String, dynamic> json) => Valuation(
    id: json['id'],
    date: DateTime.parse(json['date']),
    preMoneyValue: (json['preMoneyValue'] as num).toDouble(),
    method: ValuationMethod.values[json['method'] as int],
    methodParams: json['methodParams'] != null
        ? Map<String, dynamic>.from(json['methodParams'])
        : null,
    notes: json['notes'],
  );
}
