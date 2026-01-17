import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/events/cap_table_event.dart';
import '../../domain/projections/cap_table_state.dart';
import 'event_providers.dart';

part 'projection_providers.g.dart';

/// The main projected state for the current company.
///
/// This is computed by folding over all events. It provides the complete
/// materialized view of the cap table that the UI consumes.
@riverpod
Future<CapTableState?> capTableState(CapTableStateRef ref) async {
  final events = await ref.watch(eventsStreamProvider.future);

  if (events.isEmpty) return null;

  // Check that first event is CompanyCreated
  if (events.first is! CompanyCreated) {
    throw StateError('First event must be CompanyCreated');
  }

  return CapTableState.fromEvents(events);
}

/// Stream version of cap table state for reactive updates.
@riverpod
Stream<CapTableState?> capTableStateStream(CapTableStateStreamRef ref) async* {
  yield* ref.watch(eventsStreamProvider.stream).map((events) {
    if (events.isEmpty) return null;
    if (events.first is! CompanyCreated) return null;
    return CapTableState.fromEvents(events);
  });
}

// ============================================================
// Derived Providers (slices of CapTableState)
// ============================================================

/// All stakeholders from projected state.
@riverpod
Future<List<StakeholderState>> projectedStakeholders(
  ProjectedStakeholdersRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.stakeholders.values.toList() ?? [];
}

/// Stakeholders filtered by type.
@riverpod
Future<List<StakeholderState>> projectedStakeholdersByType(
  ProjectedStakeholdersByTypeRef ref,
  String type,
) async {
  final stakeholders = await ref.watch(projectedStakeholdersProvider.future);
  return stakeholders.where((s) => s.type == type).toList();
}

/// All share classes from projected state.
@riverpod
Future<List<ShareClassState>> projectedShareClasses(
  ProjectedShareClassesRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.shareClasses.values.toList() ?? [];
}

/// All rounds from projected state, sorted by display order.
@riverpod
Future<List<RoundState>> projectedRounds(ProjectedRoundsRef ref) async {
  final state = await ref.watch(capTableStateProvider.future);
  final rounds = state?.rounds.values.toList() ?? [];
  rounds.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  return rounds;
}

/// Rounds filtered by status.
@riverpod
Future<List<RoundState>> projectedRoundsByStatus(
  ProjectedRoundsByStatusRef ref,
  String status,
) async {
  final rounds = await ref.watch(projectedRoundsProvider.future);
  return rounds.where((r) => r.status == status).toList();
}

/// All holdings from projected state.
@riverpod
Future<List<HoldingState>> projectedHoldings(ProjectedHoldingsRef ref) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.holdings.values.toList() ?? [];
}

/// Holdings for a specific stakeholder.
@riverpod
Future<List<HoldingState>> projectedStakeholderHoldings(
  ProjectedStakeholderHoldingsRef ref,
  String stakeholderId,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.holdingsForStakeholder(stakeholderId) ?? [];
}

/// All convertibles from projected state.
@riverpod
Future<List<ConvertibleState>> projectedConvertibles(
  ProjectedConvertiblesRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.convertibles.values.toList() ?? [];
}

/// Outstanding convertibles only.
@riverpod
Future<List<ConvertibleState>> projectedOutstandingConvertibles(
  ProjectedOutstandingConvertiblesRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.outstandingConvertibles ?? [];
}

/// All ESOP pools from projected state.
@riverpod
Future<List<EsopPoolState>> projectedEsopPools(
  ProjectedEsopPoolsRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.esopPools.values.toList() ?? [];
}

/// All option grants from projected state.
@riverpod
Future<List<OptionGrantState>> projectedOptionGrants(
  ProjectedOptionGrantsRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.optionGrants.values.toList() ?? [];
}

/// All warrants from projected state.
@riverpod
Future<List<WarrantState>> projectedWarrants(ProjectedWarrantsRef ref) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.warrants.values.toList() ?? [];
}

/// All vesting schedules from projected state.
@riverpod
Future<List<VestingScheduleState>> projectedVestingSchedules(
  ProjectedVestingSchedulesRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.vestingSchedules.values.toList() ?? [];
}

/// All valuations from projected state, sorted by date descending.
@riverpod
Future<List<ValuationState>> projectedValuations(
  ProjectedValuationsRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  final valuations = state?.valuations.values.toList() ?? [];
  valuations.sort((a, b) => b.date.compareTo(a.date));
  return valuations;
}

/// Latest valuation (most recent by date).
@riverpod
Future<ValuationState?> projectedLatestValuation(
  ProjectedLatestValuationRef ref,
) async {
  final valuations = await ref.watch(projectedValuationsProvider.future);
  return valuations.isNotEmpty ? valuations.first : null;
}

/// All transfers from projected state.
@riverpod
Future<List<TransferState>> projectedTransfers(
  ProjectedTransfersRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);
  return state?.transfers.values.toList() ?? [];
}

// ============================================================
// Summary Providers
// ============================================================

/// Ownership summary computed from projected state.
@riverpod
Future<ProjectedOwnershipSummary> projectedOwnershipSummary(
  ProjectedOwnershipSummaryRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);

  if (state == null) {
    return const ProjectedOwnershipSummary(
      totalIssuedShares: 0,
      stakeholderCount: 0,
      sharesByStakeholder: {},
      sharesByClass: {},
    );
  }

  return ProjectedOwnershipSummary(
    totalIssuedShares: state.totalIssuedShares,
    stakeholderCount: state.stakeholders.length,
    sharesByStakeholder: state.sharesByStakeholder,
    sharesByClass: state.sharesByClass,
  );
}

/// Rounds summary computed from projected state.
@riverpod
Future<ProjectedRoundsSummary> projectedRoundsSummary(
  ProjectedRoundsSummaryRef ref,
) async {
  final rounds = await ref.watch(projectedRoundsProvider.future);

  final closedRounds = rounds.where((r) => r.status == 'closed').toList();
  final totalRaised = closedRounds.fold(0.0, (sum, r) => sum + r.amountRaised);

  return ProjectedRoundsSummary(
    totalRounds: rounds.length,
    closedRounds: closedRounds.length,
    draftRounds: rounds.length - closedRounds.length,
    totalRaised: totalRaised,
  );
}

/// Convertibles summary computed from projected state.
@riverpod
Future<ProjectedConvertiblesSummary> projectedConvertiblesSummary(
  ProjectedConvertiblesSummaryRef ref,
) async {
  final state = await ref.watch(capTableStateProvider.future);

  if (state == null) {
    return const ProjectedConvertiblesSummary(
      totalCount: 0,
      outstandingCount: 0,
      convertedCount: 0,
      totalPrincipal: 0,
      outstandingPrincipal: 0,
    );
  }

  final convertibles = state.convertibles.values.toList();
  final outstanding = convertibles
      .where((c) => c.status == 'outstanding')
      .toList();
  final converted = convertibles.where((c) => c.status == 'converted').toList();

  return ProjectedConvertiblesSummary(
    totalCount: convertibles.length,
    outstandingCount: outstanding.length,
    convertedCount: converted.length,
    totalPrincipal: convertibles.fold(0.0, (sum, c) => sum + c.principal),
    outstandingPrincipal: outstanding.fold(0.0, (sum, c) => sum + c.principal),
  );
}

// ============================================================
// Summary Classes
// ============================================================

class ProjectedOwnershipSummary {
  final int totalIssuedShares;
  final int stakeholderCount;
  final Map<String, int> sharesByStakeholder;
  final Map<String, int> sharesByClass;

  const ProjectedOwnershipSummary({
    required this.totalIssuedShares,
    required this.stakeholderCount,
    required this.sharesByStakeholder,
    required this.sharesByClass,
  });
}

class ProjectedRoundsSummary {
  final int totalRounds;
  final int closedRounds;
  final int draftRounds;
  final double totalRaised;

  const ProjectedRoundsSummary({
    required this.totalRounds,
    required this.closedRounds,
    required this.draftRounds,
    required this.totalRaised,
  });
}

class ProjectedConvertiblesSummary {
  final int totalCount;
  final int outstandingCount;
  final int convertedCount;
  final double totalPrincipal;
  final double outstandingPrincipal;

  const ProjectedConvertiblesSummary({
    required this.totalCount,
    required this.outstandingCount,
    required this.convertedCount,
    required this.totalPrincipal,
    required this.outstandingPrincipal,
  });
}
