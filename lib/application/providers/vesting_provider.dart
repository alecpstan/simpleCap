import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/constants/constants.dart';
import '../../domain/services/vesting_calculator.dart';
import '../../infrastructure/database/database.dart';
import 'projection_adapters.dart';

part 'vesting_provider.g.dart';

/// Watches all vesting schedules for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<VestingSchedule>> vestingSchedulesStream(
  VestingSchedulesStreamRef ref,
) {
  return ref.watch(unifiedVestingSchedulesStreamProvider.stream);
}

/// Gets a specific vesting schedule by ID.
@riverpod
VestingSchedule? vestingSchedule(VestingScheduleRef ref, String? scheduleId) {
  if (scheduleId == null) return null;

  final schedules = ref.watch(vestingSchedulesStreamProvider).valueOrNull ?? [];
  return schedules.where((s) => s.id == scheduleId).firstOrNull;
}

/// Calculates vesting status for an option grant.
@riverpod
VestingStatus calculateVestingStatus(
  CalculateVestingStatusRef ref, {
  required int totalQuantity,
  required DateTime grantDate,
  required String? vestingScheduleId,
  DateTime? asOfDate,
}) {
  final schedule = ref.watch(vestingScheduleProvider(vestingScheduleId));
  final now = asOfDate ?? DateTime.now();

  if (schedule == null || vestingScheduleId == null) {
    // No vesting schedule = fully vested immediately
    return VestingStatus(
      totalQuantity: totalQuantity,
      vestedQuantity: totalQuantity,
      unvestedQuantity: 0,
      vestingPercent: 100.0,
      isFullyVested: true,
      nextVestingDate: null,
      nextVestingQuantity: 0,
      cliffDate: null,
      isCliffMet: true,
      vestingEndDate: grantDate,
    );
  }

  // Use VestingCalculator directly with Drift types
  final percent = VestingCalculator.vestingPercentAt(
    schedule: schedule,
    startDate: grantDate,
    asOfDate: now,
  );
  final vestedQty = VestingCalculator.unitsVestedAt(
    schedule: schedule,
    totalUnits: totalQuantity,
    startDate: grantDate,
    asOfDate: now,
  );
  final unvestedQty = totalQuantity - vestedQty;
  final isFullyVested = percent >= 100;

  // Calculate cliff date
  final cliffDate = schedule.cliffMonths > 0
      ? DateTime(
          grantDate.year,
          grantDate.month + schedule.cliffMonths,
          grantDate.day,
        )
      : null;
  final isCliffMet = cliffDate == null || now.isAfter(cliffDate);

  // Calculate vesting end date
  final totalMonths = schedule.totalMonths ?? 0;
  final vestingEndDate = DateTime(
    grantDate.year,
    grantDate.month + totalMonths,
    grantDate.day,
  );

  // Calculate next vesting date and quantity
  DateTime? nextVestingDate;
  int nextVestingQuantity = 0;

  if (!isFullyVested) {
    final monthsPerTranche = VestingFrequency.monthsPerTranche(
      schedule.frequency ?? VestingFrequency.monthly,
    );

    // Calculate months since grant
    final monthsElapsed = _monthsBetween(grantDate, now);

    if (!isCliffMet) {
      // Next vest is at cliff
      nextVestingDate = cliffDate;
      nextVestingQuantity = VestingCalculator.unitsVestedAt(
        schedule: schedule,
        totalUnits: totalQuantity,
        startDate: grantDate,
        asOfDate: cliffDate,
      );
    } else {
      // Next vest is at next tranche
      final nextTranche =
          ((monthsElapsed ~/ monthsPerTranche) + 1) * monthsPerTranche;
      if (nextTranche <= totalMonths) {
        nextVestingDate = DateTime(
          grantDate.year,
          grantDate.month + nextTranche,
          grantDate.day,
        );
        final nextVestedTotal = VestingCalculator.unitsVestedAt(
          schedule: schedule,
          totalUnits: totalQuantity,
          startDate: grantDate,
          asOfDate: nextVestingDate,
        );
        nextVestingQuantity = nextVestedTotal - vestedQty;
      }
    }
  }

  return VestingStatus(
    totalQuantity: totalQuantity,
    vestedQuantity: vestedQty,
    unvestedQuantity: unvestedQty,
    vestingPercent: percent,
    isFullyVested: isFullyVested,
    nextVestingDate: nextVestingDate,
    nextVestingQuantity: nextVestingQuantity,
    cliffDate: cliffDate,
    isCliffMet: isCliffMet,
    vestingEndDate: vestingEndDate,
  );
}

/// Vesting status for a grant at a point in time.
class VestingStatus {
  final int totalQuantity;
  final int vestedQuantity;
  final int unvestedQuantity;
  final double vestingPercent;
  final bool isFullyVested;
  final DateTime? nextVestingDate;
  final int nextVestingQuantity;
  final DateTime? cliffDate;
  final bool isCliffMet;
  final DateTime vestingEndDate;

  const VestingStatus({
    required this.totalQuantity,
    required this.vestedQuantity,
    required this.unvestedQuantity,
    required this.vestingPercent,
    required this.isFullyVested,
    required this.nextVestingDate,
    required this.nextVestingQuantity,
    required this.cliffDate,
    required this.isCliffMet,
    required this.vestingEndDate,
  });

  /// Days until next vesting event.
  int? get daysUntilNextVest {
    if (nextVestingDate == null) return null;
    final days = nextVestingDate!.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  /// Days until cliff is met.
  int? get daysUntilCliff {
    if (cliffDate == null || isCliffMet) return null;
    final days = cliffDate!.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }
}

int _monthsBetween(DateTime from, DateTime to) {
  return (to.year - from.year) * 12 + (to.month - from.month);
}
