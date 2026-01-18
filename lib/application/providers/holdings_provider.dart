import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'esop_pools_provider.dart';
import 'permanent_delete_provider.dart';
import 'rounds_provider.dart';
import 'projection_adapters.dart';

part 'holdings_provider.g.dart';

/// Watches all holdings for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<Holding>> holdingsStream(HoldingsStreamRef ref) {
  return ref.watch(unifiedHoldingsStreamProvider.stream);
}

/// Gets holdings for a specific stakeholder.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<Holding>> stakeholderHoldings(
  StakeholderHoldingsRef ref,
  String stakeholderId,
) {
  return ref.watch(unifiedStakeholderHoldingsProvider(stakeholderId).stream);
}

/// Calculates ownership summary for the cap table.
/// Respects the showDraft toggle - if off, draft holdings are excluded.
/// Includes ESOP pool reserved shares in fully diluted calculation.
@riverpod
Future<OwnershipSummary> ownershipSummary(OwnershipSummaryRef ref) async {
  final holdings = await ref.watch(holdingsStreamProvider.future);
  final showDraft = await ref.watch(showDraftProvider.future);
  final draftRounds = await ref.watch(draftRoundIdsProvider.future);
  final esopPoolsSummary = await ref.watch(allEsopPoolsSummaryProvider.future);

  int totalShares = 0;
  int fullyDilutedShares = 0;
  final byStakeholder = <String, int>{};
  final byShareClass = <String, int>{};

  for (final holding in holdings) {
    // Skip draft holdings if showDraft is off
    final isDraft =
        holding.roundId != null && (draftRounds[holding.roundId] ?? false);
    if (!showDraft && isDraft) continue;

    totalShares += holding.shareCount;
    fullyDilutedShares += holding.shareCount;

    byStakeholder.update(
      holding.stakeholderId,
      (v) => v + holding.shareCount,
      ifAbsent: () => holding.shareCount,
    );

    byShareClass.update(
      holding.shareClassId,
      (v) => v + holding.shareCount,
      ifAbsent: () => holding.shareCount,
    );
  }

  // Add ESOP pool reserved shares to fully diluted count
  // (pool size minus already exercised options = remaining reserved)
  final esopReserved = esopPoolsSummary.totalPoolSize - esopPoolsSummary.totalExercised;

  return OwnershipSummary(
    totalIssuedShares: totalShares,
    fullyDilutedShares: fullyDilutedShares + esopReserved,
    sharesByStakeholder: byStakeholder,
    sharesByClass: byShareClass,
    stakeholderCount: byStakeholder.length,
    esopReservedShares: esopReserved,
  );
}

/// Map of roundId to isDraft status for quick lookup.
@riverpod
Future<Map<String, bool>> draftRoundIds(DraftRoundIdsRef ref) async {
  final rounds = await ref.watch(roundsStreamProvider.future);
  return {for (final round in rounds) round.id: round.status == 'draft'};
}

/// Summary of ownership distribution.
class OwnershipSummary {
  final int totalIssuedShares;
  final int fullyDilutedShares;
  final Map<String, int> sharesByStakeholder;
  final Map<String, int> sharesByClass;
  final int stakeholderCount;

  /// Reserved shares in ESOP pools (not yet exercised).
  final int esopReservedShares;

  const OwnershipSummary({
    required this.totalIssuedShares,
    required this.fullyDilutedShares,
    required this.sharesByStakeholder,
    required this.sharesByClass,
    required this.stakeholderCount,
    this.esopReservedShares = 0,
  });

  double getOwnershipPercent(String stakeholderId) {
    if (totalIssuedShares == 0) return 0;
    final shares = sharesByStakeholder[stakeholderId] ?? 0;
    return (shares / totalIssuedShares) * 100;
  }

  double getFullyDilutedPercent(String stakeholderId) {
    if (fullyDilutedShares == 0) return 0;
    final shares = sharesByStakeholder[stakeholderId] ?? 0;
    return (shares / fullyDilutedShares) * 100;
  }
}
