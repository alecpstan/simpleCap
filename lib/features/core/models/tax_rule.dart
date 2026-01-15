import 'package:uuid/uuid.dart';

/// Australian startup tax concession types
enum TaxRuleType {
  /// Standard CGT treatment (no concession)
  standard,

  /// ESS Division 83A - tax deferred until vesting
  essDivision83A,

  /// ESS Startup Concession (Division 83A) - 15-year exemption for qualifying startups
  essStartupConcession,

  /// Small Business CGT Concessions (50% reduction)
  smallBusinessCgt,

  /// 12-month CGT discount (50% reduction)
  cgtDiscount12Month,

  /// MIT (Managed Investment Trust) withholding
  mitWithholding,
}

/// Extension for display names
extension TaxRuleTypeDisplay on TaxRuleType {
  String get displayName {
    switch (this) {
      case TaxRuleType.standard:
        return 'Standard CGT';
      case TaxRuleType.essDivision83A:
        return 'ESS Division 83A (Deferred)';
      case TaxRuleType.essStartupConcession:
        return 'ESS Startup Concession';
      case TaxRuleType.smallBusinessCgt:
        return 'Small Business CGT';
      case TaxRuleType.cgtDiscount12Month:
        return '12-Month CGT Discount';
      case TaxRuleType.mitWithholding:
        return 'MIT Withholding';
    }
  }

  String get description {
    switch (this) {
      case TaxRuleType.standard:
        return 'Standard capital gains tax treatment without any concessions.';
      case TaxRuleType.essDivision83A:
        return 'Employee Share Scheme tax deferred until earliest of: shares sold, employment ends, or 15 years.';
      case TaxRuleType.essStartupConcession:
        return 'For qualifying startups: no tax until disposal, CGT discount available, 15-year exemption possible.';
      case TaxRuleType.smallBusinessCgt:
        return '50% reduction in CGT for small business entities meeting eligibility criteria.';
      case TaxRuleType.cgtDiscount12Month:
        return '50% CGT discount for assets held more than 12 months.';
      case TaxRuleType.mitWithholding:
        return 'Withholding tax rate for Managed Investment Trust distributions.';
    }
  }
}

/// Tax rule configuration for transactions
class TaxRule {
  final String id;

  /// Type of tax concession
  final TaxRuleType type;

  /// Display name for the rule
  final String name;

  /// Date the rule was applied/granted
  final DateTime? appliedDate;

  /// Expiry date for the concession (e.g., 15 years for ESS)
  final DateTime? expiryDate;

  /// Whether this investor is eligible for the ESS startup concession
  final bool? essEligible;

  /// For ESS: the market value at grant date
  final double? marketValueAtGrant;

  /// For ESS: the discount given (if any)
  final double? discountGiven;

  /// Holding period start date (for CGT discount calculation)
  final DateTime? holdingPeriodStart;

  /// Notes about eligibility or conditions
  final String? notes;

  TaxRule({
    String? id,
    required this.type,
    String? name,
    this.appliedDate,
    this.expiryDate,
    this.essEligible,
    this.marketValueAtGrant,
    this.discountGiven,
    this.holdingPeriodStart,
    this.notes,
  }) : id = id ?? const Uuid().v4(),
       name = name ?? type.displayName;

  /// Whether the concession is still active
  bool get isActive {
    if (expiryDate == null) return true;
    return DateTime.now().isBefore(expiryDate!);
  }

  /// For CGT discount: whether held more than 12 months
  bool get qualifiesForCgtDiscount {
    if (holdingPeriodStart == null) return false;
    final holdingDays = DateTime.now().difference(holdingPeriodStart!).inDays;
    return holdingDays > 365;
  }

  /// Days until expiry (for ESS concessions)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final diff = expiryDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'name': name,
    'appliedDate': appliedDate?.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
    'essEligible': essEligible,
    'marketValueAtGrant': marketValueAtGrant,
    'discountGiven': discountGiven,
    'holdingPeriodStart': holdingPeriodStart?.toIso8601String(),
    'notes': notes,
  };

  factory TaxRule.fromJson(Map<String, dynamic> json) => TaxRule(
    id: json['id'],
    type: TaxRuleType.values[json['type']],
    name: json['name'],
    appliedDate: json['appliedDate'] != null
        ? DateTime.parse(json['appliedDate'])
        : null,
    expiryDate: json['expiryDate'] != null
        ? DateTime.parse(json['expiryDate'])
        : null,
    essEligible: json['essEligible'],
    marketValueAtGrant: json['marketValueAtGrant'] != null
        ? (json['marketValueAtGrant'] as num).toDouble()
        : null,
    discountGiven: json['discountGiven'] != null
        ? (json['discountGiven'] as num).toDouble()
        : null,
    holdingPeriodStart: json['holdingPeriodStart'] != null
        ? DateTime.parse(json['holdingPeriodStart'])
        : null,
    notes: json['notes'],
  );

  TaxRule copyWith({
    TaxRuleType? type,
    String? name,
    DateTime? appliedDate,
    DateTime? expiryDate,
    bool? essEligible,
    double? marketValueAtGrant,
    double? discountGiven,
    DateTime? holdingPeriodStart,
    String? notes,
  }) {
    return TaxRule(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      appliedDate: appliedDate ?? this.appliedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      essEligible: essEligible ?? this.essEligible,
      marketValueAtGrant: marketValueAtGrant ?? this.marketValueAtGrant,
      discountGiven: discountGiven ?? this.discountGiven,
      holdingPeriodStart: holdingPeriodStart ?? this.holdingPeriodStart,
      notes: notes ?? this.notes,
    );
  }

  /// Create a standard ESS startup concession rule
  factory TaxRule.essStartup({
    required DateTime grantDate,
    double? marketValue,
    double? discount,
  }) {
    return TaxRule(
      type: TaxRuleType.essStartupConcession,
      appliedDate: grantDate,
      expiryDate: grantDate.add(const Duration(days: 365 * 15)), // 15 years
      essEligible: true,
      marketValueAtGrant: marketValue,
      discountGiven: discount,
      holdingPeriodStart: grantDate,
    );
  }

  /// Create a Division 83A deferred tax rule
  factory TaxRule.essDivision83A({
    required DateTime grantDate,
    double? marketValue,
    double? discount,
  }) {
    return TaxRule(
      type: TaxRuleType.essDivision83A,
      appliedDate: grantDate,
      // ESS Division 83A deferred taxing point is earliest of:
      // - shares sold, - employment ends, - 15 years
      expiryDate: grantDate.add(const Duration(days: 365 * 15)),
      marketValueAtGrant: marketValue,
      discountGiven: discount,
      holdingPeriodStart: grantDate,
    );
  }
}
