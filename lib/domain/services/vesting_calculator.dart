import '../../infrastructure/database/database.dart';

/// Pure calculation functions for vesting schedules.
///
/// Extracted for testability without Riverpod.
abstract class VestingCalculator {
  /// Calculate vesting percentage at a given date from grant start.
  ///
  /// Returns 0-100 representing the percentage vested.
  static double vestingPercentAt({
    required VestingSchedule schedule,
    required DateTime startDate,
    required DateTime asOfDate,
  }) {
    if (schedule.type == 'immediate') return 100;
    if (schedule.totalMonths == null || schedule.totalMonths == 0) return 100;

    final monthsElapsed = _monthsBetween(startDate, asOfDate);

    // Before cliff: 0%
    if (monthsElapsed < schedule.cliffMonths) return 0;

    // After total period: 100%
    if (monthsElapsed >= schedule.totalMonths!) return 100;

    // Calculate vested portion based on frequency
    if (schedule.frequency == null) {
      // Linear vesting
      return (monthsElapsed / schedule.totalMonths!) * 100;
    }

    final monthsPerTranche = _monthsPerTranche(schedule.frequency!);

    // Cliff vesting (first tranche at cliff)
    final cliffPercent = (schedule.cliffMonths / schedule.totalMonths!) * 100;

    // Post-cliff months
    final postCliffMonths = monthsElapsed - schedule.cliffMonths;
    final postCliffTranches = postCliffMonths ~/ monthsPerTranche;
    final postCliffPeriod = schedule.totalMonths! - schedule.cliffMonths;
    final tranchesRemaining = postCliffPeriod ~/ monthsPerTranche;

    if (tranchesRemaining == 0) return cliffPercent;

    final postCliffPercent =
        (postCliffTranches / tranchesRemaining) * (100 - cliffPercent);

    return cliffPercent + postCliffPercent;
  }

  /// Calculate number of units vested at a given date.
  static int unitsVestedAt({
    required VestingSchedule schedule,
    required int totalUnits,
    required DateTime startDate,
    required DateTime asOfDate,
  }) {
    final percent = vestingPercentAt(
      schedule: schedule,
      startDate: startDate,
      asOfDate: asOfDate,
    );
    return (totalUnits * percent / 100).floor();
  }

  /// Calculate number of unvested units.
  static int unitsUnvested({
    required VestingSchedule schedule,
    required int totalUnits,
    required DateTime startDate,
    required DateTime asOfDate,
  }) {
    return totalUnits -
        unitsVestedAt(
          schedule: schedule,
          totalUnits: totalUnits,
          startDate: startDate,
          asOfDate: asOfDate,
        );
  }

  /// Whether vesting is complete.
  static bool isFullyVested({
    required VestingSchedule schedule,
    required DateTime startDate,
    required DateTime asOfDate,
  }) {
    return vestingPercentAt(
          schedule: schedule,
          startDate: startDate,
          asOfDate: asOfDate,
        ) >=
        100;
  }

  /// Whether still in cliff period.
  static bool isInCliff({
    required VestingSchedule schedule,
    required DateTime startDate,
    required DateTime asOfDate,
  }) {
    final monthsElapsed = _monthsBetween(startDate, asOfDate);
    return monthsElapsed < schedule.cliffMonths;
  }

  /// Months until cliff ends (0 if past cliff).
  static int monthsUntilCliff({
    required VestingSchedule schedule,
    required DateTime startDate,
    required DateTime asOfDate,
  }) {
    final monthsElapsed = _monthsBetween(startDate, asOfDate);
    final remaining = schedule.cliffMonths - monthsElapsed;
    return remaining > 0 ? remaining : 0;
  }

  /// Months until fully vested (0 if already vested).
  static int monthsUntilFullyVested({
    required VestingSchedule schedule,
    required DateTime startDate,
    required DateTime asOfDate,
  }) {
    if (schedule.totalMonths == null) return 0;
    final monthsElapsed = _monthsBetween(startDate, asOfDate);
    final remaining = schedule.totalMonths! - monthsElapsed;
    return remaining > 0 ? remaining : 0;
  }

  static int _monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  static int _monthsPerTranche(String frequency) => switch (frequency) {
    'monthly' => 1,
    'quarterly' => 3,
    'annually' => 12,
    _ => 1,
  };
}
