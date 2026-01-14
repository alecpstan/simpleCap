/// Valuation helper enums and extensions
/// These provide data and calculations for valuation wizards

/// Valuation method types based on common startup valuation approaches
enum ValuationMethod { benchmarkMultiple, preSeedRange, manualEntry }

/// Industry types for revenue multiple calculation
enum IndustryType { saas, ecommerce, marketplace, travel, hardware, other }

extension IndustryTypeExtension on IndustryType {
  String get displayName {
    switch (this) {
      case IndustryType.saas:
        return 'SaaS / Software';
      case IndustryType.ecommerce:
        return 'E-commerce';
      case IndustryType.marketplace:
        return 'Marketplace';
      case IndustryType.travel:
        return 'Travel';
      case IndustryType.hardware:
        return 'Hardware';
      case IndustryType.other:
        return 'Other';
    }
  }

  double get defaultMultipleLow {
    switch (this) {
      case IndustryType.saas:
        return 8;
      case IndustryType.ecommerce:
        return 2;
      case IndustryType.marketplace:
        return 1;
      case IndustryType.travel:
        return 1;
      case IndustryType.hardware:
        return 1;
      case IndustryType.other:
        return 2;
    }
  }

  double get defaultMultipleHigh {
    switch (this) {
      case IndustryType.saas:
        return 15;
      case IndustryType.ecommerce:
        return 4;
      case IndustryType.marketplace:
        return 3;
      case IndustryType.travel:
        return 8;
      case IndustryType.hardware:
        return 3;
      case IndustryType.other:
        return 5;
    }
  }

  String get multipleDescription {
    switch (this) {
      case IndustryType.saas:
        return 'Usually 8-15x revenue, higher with strong growth';
      case IndustryType.ecommerce:
        return '2-4x revenue or 10-20x EBITDA';
      case IndustryType.marketplace:
        return '1-3x revenue (low-margin business)';
      case IndustryType.travel:
        return '1-2x (flights), 6-8x (hotels)';
      case IndustryType.hardware:
        return '1-3x revenue (lower margins)';
      case IndustryType.other:
        return 'Varies by business model';
    }
  }
}

/// Pre-seed valuation ranges based on region and team experience
enum PreSeedRange { smallerMarkets, tier1Europe, usTopTier }

extension PreSeedRangeExtension on PreSeedRange {
  String get displayName {
    switch (this) {
      case PreSeedRange.smallerMarkets:
        return 'Smaller Markets / Less Experience';
      case PreSeedRange.tier1Europe:
        return 'Tier 1 Europe / Strong Team';
      case PreSeedRange.usTopTier:
        return 'US / Top VC Backing';
    }
  }

  String get description {
    switch (this) {
      case PreSeedRange.smallerMarkets:
        return 'Smaller European markets, Latin America, Australia/NZ, or teams with less experience';
      case PreSeedRange.tier1Europe:
        return 'France, Germany, UK, or excellent mix of team/market/approach';
      case PreSeedRange.usTopTier:
        return 'US startups with top VC firms or well-known angel investors';
    }
  }

  double get lowValuation {
    switch (this) {
      case PreSeedRange.smallerMarkets:
        return 1000000;
      case PreSeedRange.tier1Europe:
        return 3000000;
      case PreSeedRange.usTopTier:
        return 10000000;
    }
  }

  double get highValuation {
    switch (this) {
      case PreSeedRange.smallerMarkets:
        return 3000000;
      case PreSeedRange.tier1Europe:
        return 5000000;
      case PreSeedRange.usTopTier:
        return 20000000;
    }
  }
}

/// Calculate valuation using benchmark multiple method
double calculateBenchmarkValuation({
  required double revenue,
  required double multiple,
}) {
  return revenue * multiple;
}
