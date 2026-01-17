import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'rounds_provider.dart';

part 'holdings_provider.g.dart';

/// Watches all holdings for the current company.
@riverpod
Stream<List<Holding>> holdingsStream(HoldingsStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchHoldings(companyId);
}

/// Gets holdings for a specific stakeholder.
@riverpod
Stream<List<Holding>> stakeholderHoldings(
  StakeholderHoldingsRef ref,
  String stakeholderId,
) {
  final db = ref.watch(databaseProvider);
  return db.watchStakeholderHoldings(stakeholderId);
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

/// Notifier for holding mutations.
@riverpod
class HoldingMutations extends _$HoldingMutations {
  @override
  FutureOr<void> build() {}

  Future<void> issueShares({
    required String companyId,
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    required double costBasis,
    required DateTime acquiredDate,
    String? vestingScheduleId,
    int? vestedCount,
    String? roundId,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db.upsertHolding(
      HoldingsCompanion.insert(
        id: id,
        companyId: companyId,
        stakeholderId: stakeholderId,
        shareClassId: shareClassId,
        shareCount: shareCount,
        costBasis: costBasis,
        acquiredDate: acquiredDate,
        vestingScheduleId: Value(vestingScheduleId),
        vestedCount: Value(vestedCount),
        roundId: Value(roundId),
        updatedAt: now,
      ),
    );
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteHolding(id);
  }

  /// Update an existing holding.
  Future<void> updateHolding({
    required String id,
    String? shareClassId,
    int? shareCount,
    double? costBasis,
    DateTime? acquiredDate,
    String? vestingScheduleId,
    int? vestedCount,
    String? roundId,
  }) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    await (db.update(db.holdings)..where((h) => h.id.equals(id))).write(
      HoldingsCompanion(
        shareClassId:
            shareClassId != null ? Value(shareClassId) : const Value.absent(),
        shareCount:
            shareCount != null ? Value(shareCount) : const Value.absent(),
        costBasis: costBasis != null ? Value(costBasis) : const Value.absent(),
        acquiredDate:
            acquiredDate != null ? Value(acquiredDate) : const Value.absent(),
        vestingScheduleId: vestingScheduleId != null
            ? Value(vestingScheduleId)
            : const Value.absent(),
        vestedCount:
            vestedCount != null ? Value(vestedCount) : const Value.absent(),
        roundId: roundId != null ? Value(roundId) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  /// Delete orphan holdings (those without a roundId).
  /// Returns the number of deleted holdings.
  Future<int> deleteOrphanHoldings(String companyId) async {
    final db = ref.read(databaseProvider);
    return db.deleteOrphanHoldings(companyId);
  }
}
