import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/constants/constants.dart';
import '../../domain/services/vesting_calculator.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';

part 'vesting_provider.g.dart';

/// Watches all vesting schedules for the current company.
@riverpod
Stream<List<VestingSchedule>> vestingSchedulesStream(
  VestingSchedulesStreamRef ref,
) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchVestingSchedules(companyId);
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

/// Notifier for vesting schedule mutations.
@riverpod
class VestingScheduleMutations extends _$VestingScheduleMutations {
  @override
  FutureOr<void> build() {}

  /// Create a new vesting schedule.
  Future<String> create({
    required String companyId,
    required String name,
    required String type,
    int? totalMonths,
    int cliffMonths = 0,
    String? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db.upsertVestingSchedule(
      VestingSchedulesCompanion.insert(
        id: id,
        companyId: companyId,
        name: name,
        type: type,
        totalMonths: Value(totalMonths),
        cliffMonths: Value(cliffMonths),
        frequency: Value(frequency),
        milestonesJson: Value(milestonesJson),
        totalHours: Value(totalHours),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  /// Create standard 4-year / 1-year cliff schedule.
  Future<String> createStandard4Year({required String companyId}) async {
    return create(
      companyId: companyId,
      name: '4 Year / 1 Year Cliff',
      type: VestingType.timeBased,
      totalMonths: 48,
      cliffMonths: 12,
      frequency: VestingFrequency.monthly,
    );
  }

  /// Create 3-year monthly schedule (no cliff).
  Future<String> create3YearNoCliff({required String companyId}) async {
    return create(
      companyId: companyId,
      name: '3 Year / Monthly',
      type: VestingType.timeBased,
      totalMonths: 36,
      cliffMonths: 0,
      frequency: VestingFrequency.monthly,
    );
  }

  /// Update an existing vesting schedule.
  Future<void> updateSchedule({
    required String id,
    String? name,
    String? type,
    int? totalMonths,
    int? cliffMonths,
    String? frequency,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final schedules = await db.getVestingSchedules(
      ref.read(currentCompanyIdProvider) ?? '',
    );
    final existing = schedules.where((s) => s.id == id).firstOrNull;
    if (existing == null) return;

    await db.upsertVestingSchedule(
      VestingSchedulesCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        name: Value(name ?? existing.name),
        type: Value(type ?? existing.type),
        totalMonths: Value(totalMonths ?? existing.totalMonths),
        cliffMonths: Value(cliffMonths ?? existing.cliffMonths),
        frequency: Value(frequency ?? existing.frequency),
        milestonesJson: Value(existing.milestonesJson),
        totalHours: Value(existing.totalHours),
        notes: Value(notes ?? existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a vesting schedule.
  Future<void> deleteSchedule(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteVestingSchedule(id);
  }
}

int _monthsBetween(DateTime from, DateTime to) {
  return (to.year - from.year) * 12 + (to.month - from.month);
}
