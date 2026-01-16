import 'package:freezed_annotation/freezed_annotation.dart';

part 'vesting_schedule.freezed.dart';
part 'vesting_schedule.g.dart';

/// Type of vesting schedule.
enum VestingType {
  /// Standard time-based vesting (monthly/quarterly).
  timeBased,

  /// Milestone-based vesting.
  milestone,

  /// Hours-based vesting (for part-time).
  hours,

  /// Immediate full vesting.
  immediate;

  String get displayName => switch (this) {
    timeBased => 'Time-Based',
    milestone => 'Milestone',
    hours => 'Hours-Based',
    immediate => 'Immediate',
  };
}

/// Frequency of vesting tranches.
enum VestingFrequency {
  monthly,
  quarterly,
  annually;

  String get displayName => switch (this) {
    monthly => 'Monthly',
    quarterly => 'Quarterly',
    annually => 'Annually',
  };

  int get monthsPerTranche => switch (this) {
    monthly => 1,
    quarterly => 3,
    annually => 12,
  };
}

/// A vesting schedule template.
///
/// Defines how shares/options vest over time. Can be reused
/// across multiple grants.
@freezed
class VestingSchedule with _$VestingSchedule {
  const VestingSchedule._();

  const factory VestingSchedule({
    required String id,
    required String companyId,
    required String name,
    required VestingType type,

    /// Total vesting period in months.
    int? totalMonths,

    /// Cliff period in months (no vesting until cliff).
    @Default(0) int cliffMonths,

    /// How often tranches vest after cliff.
    VestingFrequency? frequency,

    /// For milestone vesting: JSON description of milestones.
    String? milestonesJson,

    /// For hours vesting: total hours required.
    int? totalHours,

    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VestingSchedule;

  factory VestingSchedule.fromJson(Map<String, dynamic> json) =>
      _$VestingScheduleFromJson(json);

  /// Standard 4-year with 1-year cliff schedule.
  static VestingSchedule standard4Year({
    required String id,
    required String companyId,
  }) {
    final now = DateTime.now();
    return VestingSchedule(
      id: id,
      companyId: companyId,
      name: '4 Year / 1 Year Cliff',
      type: VestingType.timeBased,
      totalMonths: 48,
      cliffMonths: 12,
      frequency: VestingFrequency.monthly,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Calculate vesting percentage at a given date from start.
  double vestingPercentAt(DateTime startDate, DateTime asOfDate) {
    if (type == VestingType.immediate) return 100;
    if (totalMonths == null || totalMonths == 0) return 100;

    final monthsElapsed = _monthsBetween(startDate, asOfDate);

    // Before cliff: 0%
    if (monthsElapsed < cliffMonths) return 0;

    // After total period: 100%
    if (monthsElapsed >= totalMonths!) return 100;

    // Calculate vested portion
    if (frequency == null) {
      // Linear vesting
      return (monthsElapsed / totalMonths!) * 100;
    }

    // Tranched vesting
    final monthsPerTranche = frequency!.monthsPerTranche;
    final tranchesVested = monthsElapsed ~/ monthsPerTranche;
    final totalTranches = totalMonths! ~/ monthsPerTranche;

    return (tranchesVested / totalTranches) * 100;
  }

  /// Calculate number of units vested from a total grant.
  int unitsVestedAt(int totalUnits, DateTime startDate, DateTime asOfDate) {
    final percent = vestingPercentAt(startDate, asOfDate);
    return (totalUnits * percent / 100).floor();
  }

  int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  /// Human-readable description of the schedule.
  String get description {
    if (type == VestingType.immediate) return 'Immediate vesting';
    if (type == VestingType.milestone) return 'Milestone-based';
    if (type == VestingType.hours) return '$totalHours hours';

    final total = totalMonths ?? 0;
    final years = total ~/ 12;
    final cliff = cliffMonths;
    final freq = frequency?.displayName.toLowerCase() ?? 'monthly';

    if (cliff > 0) {
      final cliffYears = cliff ~/ 12;
      final cliffMonthsRemainder = cliff % 12;
      final cliffStr = cliffYears > 0
          ? '$cliffYears year${cliffYears > 1 ? 's' : ''}'
          : '$cliffMonthsRemainder month${cliffMonthsRemainder > 1 ? 's' : ''}';
      return '$years year${years > 1 ? 's' : ''} / $cliffStr cliff / $freq';
    }

    return '$years year${years > 1 ? 's' : ''} / $freq';
  }
}
