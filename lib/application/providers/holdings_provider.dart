import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
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
@riverpod
Future<OwnershipSummary> ownershipSummary(OwnershipSummaryRef ref) async {
  final holdings = await ref.watch(holdingsStreamProvider.future);

  int totalShares = 0;
  int fullyDilutedShares = 0;
  final byStakeholder = <String, int>{};
  final byShareClass = <String, int>{};

  for (final holding in holdings) {
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

  return OwnershipSummary(
    totalIssuedShares: totalShares,
    fullyDilutedShares: fullyDilutedShares,
    sharesByStakeholder: byStakeholder,
    sharesByClass: byShareClass,
    stakeholderCount: byStakeholder.length,
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

  const OwnershipSummary({
    required this.totalIssuedShares,
    required this.fullyDilutedShares,
    required this.sharesByStakeholder,
    required this.sharesByClass,
    required this.stakeholderCount,
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
