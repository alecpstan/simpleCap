/// Industry types for revenue multiple valuations.
enum Industry {
  saas,
  ecommerce,
  marketplace,
  hardware,
  other,
}

extension IndustryExtension on Industry {
  String get displayName {
    switch (this) {
      case Industry.saas:
        return 'SaaS / Software';
      case Industry.ecommerce:
        return 'E-commerce';
      case Industry.marketplace:
        return 'Marketplace';
      case Industry.hardware:
        return 'Hardware';
      case Industry.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case Industry.saas:
        return 'Usually 8-15x revenue, higher with strong growth and retention';
      case Industry.ecommerce:
        return '2-4x revenue or 10-20x EBITDA for profitable businesses';
      case Industry.marketplace:
        return '1-3x GMV depending on take rate and growth';
      case Industry.hardware:
        return '1-3x revenue, higher margins command higher multiples';
      case Industry.other:
        return '2-5x revenue depending on growth and market';
    }
  }

  /// Default revenue multiple range for this industry
  (double min, double max) get multipleRange {
    switch (this) {
      case Industry.saas:
        return (8.0, 15.0);
      case Industry.ecommerce:
        return (2.0, 4.0);
      case Industry.marketplace:
        return (1.0, 3.0);
      case Industry.hardware:
        return (1.0, 3.0);
      case Industry.other:
        return (2.0, 5.0);
    }
  }

  /// Default starting multiple for this industry
  double get defaultMultiple {
    final range = multipleRange;
    return (range.$1 + range.$2) / 2;
  }
}

/// Scorecard method factor weights (must sum to 100).
class ScorecardFactors {
  static const double teamWeight = 30.0;
  static const double marketWeight = 25.0;
  static const double productWeight = 15.0;
  static const double competitiveWeight = 10.0;
  static const double marketingWeight = 10.0;
  static const double investmentWeight = 5.0;
  static const double otherWeight = 5.0;

  static const List<ScorecardFactor> factors = [
    ScorecardFactor(
      key: 'team',
      name: 'Team Strength',
      weight: teamWeight,
      description: 'Experience, track record, completeness of founding team',
    ),
    ScorecardFactor(
      key: 'market',
      name: 'Market Opportunity',
      weight: marketWeight,
      description: 'Size of addressable market and growth potential',
    ),
    ScorecardFactor(
      key: 'product',
      name: 'Product/Technology',
      weight: productWeight,
      description: 'Uniqueness, defensibility, and stage of development',
    ),
    ScorecardFactor(
      key: 'competitive',
      name: 'Competitive Position',
      weight: competitiveWeight,
      description: 'Competitive landscape and differentiation',
    ),
    ScorecardFactor(
      key: 'marketing',
      name: 'Marketing/Sales',
      weight: marketingWeight,
      description: 'Go-to-market strategy and early traction',
    ),
    ScorecardFactor(
      key: 'investment',
      name: 'Need for Investment',
      weight: investmentWeight,
      description: 'Capital efficiency and funding requirements',
    ),
    ScorecardFactor(
      key: 'other',
      name: 'Other Factors',
      weight: otherWeight,
      description: 'Industry relationships, partnerships, IP, etc.',
    ),
  ];
}

class ScorecardFactor {
  final String key;
  final String name;
  final double weight;
  final String description;

  const ScorecardFactor({
    required this.key,
    required this.name,
    required this.weight,
    required this.description,
  });
}

/// Berkus method elements (max $500K each, $2.5M total pre-revenue).
class BerkusElements {
  static const double maxPerElement = 500000.0;
  static const double maxTotal = 2500000.0;

  static const List<BerkusElement> elements = [
    BerkusElement(
      key: 'idea',
      name: 'Sound Idea',
      description: 'Basic value of the concept and business model',
    ),
    BerkusElement(
      key: 'prototype',
      name: 'Prototype',
      description: 'Working product or proof of concept reduces technology risk',
    ),
    BerkusElement(
      key: 'management',
      name: 'Quality Management',
      description: 'Experienced team reduces execution risk',
    ),
    BerkusElement(
      key: 'relationships',
      name: 'Strategic Relationships',
      description: 'Key partnerships, advisors, or customer relationships',
    ),
    BerkusElement(
      key: 'rollout',
      name: 'Product Rollout/Sales',
      description: 'Early sales or committed customers reduce market risk',
    ),
  ];
}

class BerkusElement {
  final String key;
  final String name;
  final String description;

  const BerkusElement({
    required this.key,
    required this.name,
    required this.description,
  });
}

/// Calculate valuation using revenue multiple method.
double calculateRevenueMultipleValuation({
  required double annualRevenue,
  required double multiple,
}) {
  return annualRevenue * multiple;
}

/// Calculate valuation using scorecard method.
/// Scores should be between 0 and 1 (percentage of max weight).
double calculateScorecardValuation({
  required double baseValuation,
  required Map<String, double> scores,
}) {
  double adjustment = 0;
  for (final factor in ScorecardFactors.factors) {
    final score = scores[factor.key] ?? 0.5; // Default to average
    // Score of 0.5 = no adjustment, >0.5 = positive, <0.5 = negative
    adjustment += factor.weight * (score - 0.5) * 2 / 100;
  }
  return baseValuation * (1 + adjustment);
}

/// Calculate valuation using Berkus method.
/// Scores should be between 0 and 1 for each element.
double calculateBerkusValuation({
  required Map<String, double> scores,
}) {
  double total = 0;
  for (final element in BerkusElements.elements) {
    final score = scores[element.key] ?? 0;
    total += BerkusElements.maxPerElement * score;
  }
  return total.clamp(0, BerkusElements.maxTotal);
}

/// Calculate valuation using DCF method.
/// Returns present value of projected cash flows plus terminal value.
double calculateDcfValuation({
  required List<double> projectedCashFlows,
  required double terminalGrowthRate,
  required double discountRate,
}) {
  if (projectedCashFlows.isEmpty || discountRate <= terminalGrowthRate) {
    return 0;
  }

  double presentValue = 0;

  // Present value of projected cash flows
  for (int i = 0; i < projectedCashFlows.length; i++) {
    final year = i + 1;
    presentValue += projectedCashFlows[i] / _pow(1 + discountRate, year);
  }

  // Terminal value using Gordon Growth Model
  final lastCashFlow = projectedCashFlows.last;
  final terminalCashFlow = lastCashFlow * (1 + terminalGrowthRate);
  final terminalValue = terminalCashFlow / (discountRate - terminalGrowthRate);
  final presentTerminalValue =
      terminalValue / _pow(1 + discountRate, projectedCashFlows.length);

  return presentValue + presentTerminalValue;
}

/// Calculate valuation using comparable companies method.
/// Returns average of comparable multiples applied to company metric.
double calculateComparablesValuation({
  required double companyMetric,
  required List<double> comparableMultiples,
}) {
  if (comparableMultiples.isEmpty) return 0;
  final avgMultiple =
      comparableMultiples.reduce((a, b) => a + b) / comparableMultiples.length;
  return companyMetric * avgMultiple;
}

/// Helper for power calculation (avoiding dart:math import)
double _pow(double base, int exponent) {
  double result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
