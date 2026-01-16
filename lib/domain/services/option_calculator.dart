import '../../infrastructure/database/database.dart';

/// Pure calculation functions for option and warrant instruments.
///
/// Extracted from domain entities for testability without Riverpod.
abstract class OptionCalculator {
  /// Options remaining (not exercised or cancelled).
  static int remaining(OptionGrant option) =>
      option.quantity - option.exercisedCount - option.cancelledCount;

  /// Whether the grant is fully exercised.
  static bool isFullyExercised(OptionGrant option) =>
      remaining(option) == 0 && option.exercisedCount > 0;

  /// Whether options have expired.
  static bool isExpired(OptionGrant option) =>
      DateTime.now().isAfter(option.expiryDate);

  /// Days until expiry (negative if expired).
  static int daysUntilExpiry(OptionGrant option) =>
      option.expiryDate.difference(DateTime.now()).inDays;

  /// Total cost to exercise all remaining options.
  static double totalExerciseCost(OptionGrant option) =>
      remaining(option) * option.strikePrice;

  /// Intrinsic value at a given current share price.
  ///
  /// Returns 0 if options are underwater (strike > current price).
  static double intrinsicValue(OptionGrant option, double currentSharePrice) {
    final spread = currentSharePrice - option.strikePrice;
    if (spread <= 0) return 0;
    return spread * remaining(option);
  }

  /// Whether options are "in the money" at given price.
  static bool isInTheMoney(OptionGrant option, double currentSharePrice) =>
      currentSharePrice > option.strikePrice;

  /// Whether options can still be exercised based on status.
  static bool isExercisable(OptionGrant option) =>
      option.status == 'active' || option.status == 'partiallyExercised';
}

/// Pure calculation functions for warrants.
abstract class WarrantCalculator {
  /// Warrants remaining (not exercised or cancelled).
  static int remaining(Warrant warrant) =>
      warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;

  /// Whether fully exercised.
  static bool isFullyExercised(Warrant warrant) =>
      remaining(warrant) == 0 && warrant.exercisedCount > 0;

  /// Whether warrants have expired.
  static bool isExpired(Warrant warrant) =>
      DateTime.now().isAfter(warrant.expiryDate);

  /// Days until expiry (negative if expired).
  static int daysUntilExpiry(Warrant warrant) =>
      warrant.expiryDate.difference(DateTime.now()).inDays;

  /// Total cost to exercise all remaining warrants.
  static double totalExerciseCost(Warrant warrant) =>
      remaining(warrant) * warrant.strikePrice;

  /// Intrinsic value at a given current share price.
  static double intrinsicValue(Warrant warrant, double currentSharePrice) {
    final spread = currentSharePrice - warrant.strikePrice;
    if (spread <= 0) return 0;
    return spread * remaining(warrant);
  }

  /// Whether warrants can still be exercised based on status.
  static bool isExercisable(Warrant warrant) =>
      warrant.status == 'active' || warrant.status == 'partiallyExercised';
}
