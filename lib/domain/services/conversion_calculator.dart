import '../../infrastructure/database/database.dart';

/// Pure calculation functions for convertible instrument conversions.
///
/// Extracted from domain entities to keep business logic separate
/// from data types. All methods are static and take Drift types directly.
abstract class ConversionCalculator {
  /// Calculate accrued interest for a convertible note.
  ///
  /// Returns 0 for SAFEs (no interest).
  static double accruedInterest(Convertible convertible, {DateTime? asOf}) {
    if (convertible.type != 'convertibleNote') return 0;
    if (convertible.interestRate == null) return 0;

    final endDate = asOf ?? DateTime.now();
    final years = endDate.difference(convertible.issueDate).inDays / 365;
    return convertible.principal * (convertible.interestRate! / 100) * years;
  }

  /// Total value including principal + accrued interest.
  static double totalValue(Convertible convertible, {DateTime? asOf}) {
    return convertible.principal + accruedInterest(convertible, asOf: asOf);
  }

  /// Calculate effective price per share for conversion.
  ///
  /// Returns the lower of:
  /// - Cap-based price (valuation cap / pre-money shares)
  /// - Discount-based price (round price × (1 - discount%))
  /// - Round price (if no cap or discount)
  static double effectivePrice({
    required Convertible convertible,
    required double roundPricePerShare,
    required int preMoneyShares,
  }) {
    double? capPrice;
    double? discountPrice;

    // Cap-based price
    if (convertible.valuationCap != null &&
        convertible.valuationCap! > 0 &&
        preMoneyShares > 0) {
      capPrice = convertible.valuationCap! / preMoneyShares;
    }

    // Discount-based price
    if (convertible.discountPercent != null &&
        convertible.discountPercent! > 0) {
      discountPrice =
          roundPricePerShare * (1 - convertible.discountPercent! / 100);
    }

    // Return the lower of cap or discount (better for investor)
    if (capPrice != null && discountPrice != null) {
      return capPrice < discountPrice ? capPrice : discountPrice;
    }
    return capPrice ?? discountPrice ?? roundPricePerShare;
  }

  /// Calculate shares to receive upon conversion.
  static int sharesToReceive({
    required Convertible convertible,
    required double roundPricePerShare,
    required int preMoneyShares,
    DateTime? asOf,
  }) {
    final price = effectivePrice(
      convertible: convertible,
      roundPricePerShare: roundPricePerShare,
      preMoneyShares: preMoneyShares,
    );
    if (price <= 0) return 0;

    final total = totalValue(convertible, asOf: asOf);
    return (total / price).floor();
  }

  /// Whether the convertible is still outstanding.
  static bool isOutstanding(Convertible convertible) =>
      convertible.status == 'outstanding';

  /// Whether the convertible has been converted.
  static bool isConverted(Convertible convertible) =>
      convertible.status == 'converted';

  /// Whether this is a SAFE (vs convertible note).
  static bool isSafe(Convertible convertible) => convertible.type == 'safe';

  /// Whether this is a convertible note.
  static bool isNote(Convertible convertible) =>
      convertible.type == 'convertibleNote';
}
