import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/vesting_schedule.dart' as domain;
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';

part 'options_provider.g.dart';

/// Watches all option grants for the current company.
@riverpod
Stream<List<OptionGrant>> optionGrantsStream(OptionGrantsStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchOptionGrants(companyId);
}

/// Groups option grants by status.
@riverpod
Map<String, List<OptionGrant>> optionsByStatus(OptionsByStatusRef ref) {
  final optionsAsync = ref.watch(optionGrantsStreamProvider);

  return optionsAsync.when(
    data: (options) {
      final result = <String, List<OptionGrant>>{
        'pending': [],
        'active': [],
        'exercised': [],
        'cancelled': [],
        'expired': [],
      };

      for (final o in options) {
        final status = o.status;
        if (result.containsKey(status)) {
          result[status]!.add(o);
        } else {
          result['pending']!.add(o);
        }
      }

      return result;
    },
    loading: () => {},
    error: (e, s) => {},
  );
}

/// Summary of options for dashboard (with real vesting calculations).
@riverpod
Future<OptionsSummary> optionsSummary(OptionsSummaryRef ref) async {
  final options = await ref.watch(optionGrantsStreamProvider.future);
  final db = ref.watch(databaseProvider);
  final companyId = ref.watch(currentCompanyIdProvider);

  // Get all vesting schedules for lookups
  final schedules = companyId != null
      ? await db.getVestingSchedules(companyId)
      : <VestingSchedule>[];
  final scheduleMap = {for (final s in schedules) s.id: s};

  int totalGranted = 0;
  int totalExercised = 0;
  int totalCancelled = 0;
  int totalVested = 0;
  int totalUnvested = 0;
  int activeGrants = 0;
  final now = DateTime.now();

  for (final o in options) {
    totalGranted += o.quantity;
    totalExercised += o.exercisedCount;
    totalCancelled += o.cancelledCount;

    if (o.status == 'active' || o.status == 'pending') {
      activeGrants++;

      // Calculate vested using vesting schedule
      final schedule = o.vestingScheduleId != null
          ? scheduleMap[o.vestingScheduleId]
          : null;

      if (schedule != null) {
        final vestingEntity = _toVestingScheduleEntity(schedule);
        final outstanding = o.quantity - o.exercisedCount - o.cancelledCount;
        final vested = vestingEntity.unitsVestedAt(
          outstanding,
          o.grantDate,
          now,
        );
        totalVested += vested;
        totalUnvested += outstanding - vested;
      } else {
        // No schedule = immediate vesting
        final outstanding = o.quantity - o.exercisedCount - o.cancelledCount;
        totalVested += outstanding;
      }
    }
  }

  final outstandingOptions = totalGranted - totalExercised - totalCancelled;

  return OptionsSummary(
    totalGranted: totalGranted,
    totalExercised: totalExercised,
    totalCancelled: totalCancelled,
    totalVested: totalVested,
    totalUnvested: totalUnvested,
    outstandingOptions: outstandingOptions,
    activeGrants: activeGrants,
    totalGrants: options.length,
  );
}

// Helper to convert DB row to domain entity
domain.VestingSchedule _toVestingScheduleEntity(VestingSchedule data) {
  return domain.VestingSchedule(
    id: data.id,
    companyId: data.companyId,
    name: data.name,
    type: domain.VestingType.values.firstWhere(
      (t) => t.name == data.type,
      orElse: () => domain.VestingType.timeBased,
    ),
    totalMonths: data.totalMonths,
    cliffMonths: data.cliffMonths,
    frequency: data.frequency != null
        ? domain.VestingFrequency.values.firstWhere(
            (f) => f.name == data.frequency,
            orElse: () => domain.VestingFrequency.monthly,
          )
        : null,
    milestonesJson: data.milestonesJson,
    totalHours: data.totalHours,
    notes: data.notes,
    createdAt: data.createdAt,
    updatedAt: data.updatedAt,
  );
}

/// Summary data for options.
class OptionsSummary {
  final int totalGranted;
  final int totalExercised;
  final int totalCancelled;
  final int totalVested;
  final int totalUnvested;
  final int outstandingOptions;
  final int activeGrants;
  final int totalGrants;

  const OptionsSummary({
    required this.totalGranted,
    required this.totalExercised,
    required this.totalCancelled,
    required this.totalVested,
    required this.totalUnvested,
    required this.outstandingOptions,
    required this.activeGrants,
    required this.totalGrants,
  });
}

/// Notifier for option grant mutations.
@riverpod
class OptionGrantMutations extends _$OptionGrantMutations {
  @override
  FutureOr<void> build() {}

  Future<void> create({
    required String companyId,
    required String stakeholderId,
    required String shareClassId,
    required int quantity,
    required double strikePrice,
    required DateTime grantDate,
    required DateTime expiryDate,
    String? vestingScheduleId,
    String? roundId,
    bool allowsEarlyExercise = false,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db.upsertOptionGrant(
      OptionGrantsCompanion.insert(
        id: id,
        companyId: companyId,
        stakeholderId: stakeholderId,
        shareClassId: shareClassId,
        quantity: quantity,
        strikePrice: strikePrice,
        grantDate: grantDate,
        expiryDate: expiryDate,
        vestingScheduleId: Value(vestingScheduleId),
        roundId: Value(roundId),
        allowsEarlyExercise: Value(allowsEarlyExercise),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateOptionGrant({
    required String id,
    String? stakeholderId,
    String? shareClassId,
    String? status,
    int? quantity,
    double? strikePrice,
    DateTime? grantDate,
    DateTime? expiryDate,
    String? vestingScheduleId,
    String? roundId,
    bool? allowsEarlyExercise,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getOptionGrant(id);
    if (existing == null) throw Exception('Option grant not found');

    await db.upsertOptionGrant(
      OptionGrantsCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        stakeholderId: Value(stakeholderId ?? existing.stakeholderId),
        shareClassId: Value(shareClassId ?? existing.shareClassId),
        status: Value(status ?? existing.status),
        quantity: Value(quantity ?? existing.quantity),
        strikePrice: Value(strikePrice ?? existing.strikePrice),
        grantDate: Value(grantDate ?? existing.grantDate),
        expiryDate: Value(expiryDate ?? existing.expiryDate),
        exercisedCount: Value(existing.exercisedCount),
        cancelledCount: Value(existing.cancelledCount),
        vestingScheduleId: Value(
          vestingScheduleId ?? existing.vestingScheduleId,
        ),
        roundId: Value(roundId ?? existing.roundId),
        allowsEarlyExercise: Value(
          allowsEarlyExercise ?? existing.allowsEarlyExercise,
        ),
        notes: Value(notes ?? existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> exercise({
    required String id,
    required int sharesToExercise,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getOptionGrant(id);
    if (existing == null) throw Exception('Option grant not found');

    final availableToExercise =
        existing.quantity - existing.exercisedCount - existing.cancelledCount;
    if (sharesToExercise > availableToExercise) {
      throw Exception('Cannot exercise more than available options');
    }

    final newExercisedCount = existing.exercisedCount + sharesToExercise;
    final isFullyExercised =
        newExercisedCount >= existing.quantity - existing.cancelledCount;

    await db.upsertOptionGrant(
      OptionGrantsCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        stakeholderId: Value(existing.stakeholderId),
        shareClassId: Value(existing.shareClassId),
        status: Value(isFullyExercised ? 'exercised' : existing.status),
        quantity: Value(existing.quantity),
        strikePrice: Value(existing.strikePrice),
        grantDate: Value(existing.grantDate),
        expiryDate: Value(existing.expiryDate),
        exercisedCount: Value(newExercisedCount),
        cancelledCount: Value(existing.cancelledCount),
        vestingScheduleId: Value(existing.vestingScheduleId),
        roundId: Value(existing.roundId),
        allowsEarlyExercise: Value(existing.allowsEarlyExercise),
        notes: Value(existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> cancel({required String id, required int sharesToCancel}) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getOptionGrant(id);
    if (existing == null) throw Exception('Option grant not found');

    final availableToCancel =
        existing.quantity - existing.exercisedCount - existing.cancelledCount;
    if (sharesToCancel > availableToCancel) {
      throw Exception('Cannot cancel more than available options');
    }

    final newCancelledCount = existing.cancelledCount + sharesToCancel;
    final isFullyCancelled =
        newCancelledCount >= existing.quantity - existing.exercisedCount;

    await db.upsertOptionGrant(
      OptionGrantsCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        stakeholderId: Value(existing.stakeholderId),
        shareClassId: Value(existing.shareClassId),
        status: Value(isFullyCancelled ? 'cancelled' : existing.status),
        quantity: Value(existing.quantity),
        strikePrice: Value(existing.strikePrice),
        grantDate: Value(existing.grantDate),
        expiryDate: Value(existing.expiryDate),
        exercisedCount: Value(existing.exercisedCount),
        cancelledCount: Value(newCancelledCount),
        vestingScheduleId: Value(existing.vestingScheduleId),
        roundId: Value(existing.roundId),
        allowsEarlyExercise: Value(existing.allowsEarlyExercise),
        notes: Value(existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteOptionGrant(id);
  }
}
