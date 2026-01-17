import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/vesting_calculator.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'projection_adapters.dart';

part 'options_provider.g.dart';

/// Watches all option grants for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<OptionGrant>> optionGrantsStream(OptionGrantsStreamRef ref) {
  return ref.watch(unifiedOptionGrantsStreamProvider.stream);
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
        final outstanding = o.quantity - o.exercisedCount - o.cancelledCount;
        final vested = VestingCalculator.unitsVestedAt(
          schedule: schedule,
          totalUnits: outstanding,
          startDate: o.grantDate,
          asOfDate: now,
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
