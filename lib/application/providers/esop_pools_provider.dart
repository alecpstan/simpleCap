import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';

part 'esop_pools_provider.g.dart';

/// Watches all ESOP pools for the current company.
@riverpod
Stream<List<EsopPool>> esopPoolsStream(EsopPoolsStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchEsopPools(companyId);
}

/// Gets the list of ESOP pools synchronously from the stream.
@riverpod
List<EsopPool> esopPools(EsopPoolsRef ref) {
  final poolsAsync = ref.watch(esopPoolsStreamProvider);
  return poolsAsync.valueOrNull ?? [];
}

/// Gets a specific ESOP pool by ID.
@riverpod
Future<EsopPool?> esopPoolById(EsopPoolByIdRef ref, String poolId) async {
  final db = ref.watch(databaseProvider);
  return db.getEsopPool(poolId);
}

/// Watches option grants for a specific ESOP pool.
@riverpod
Stream<List<OptionGrant>> poolOptionGrantsStream(
  PoolOptionGrantsStreamRef ref,
  String poolId,
) {
  final db = ref.watch(databaseProvider);
  return db.watchOptionGrantsForPool(poolId);
}

/// Summary data for an ESOP pool including allocation metrics.
class EsopPoolSummary {
  final EsopPool pool;
  final int allocated;
  final int available;
  final int exercised;
  final int activeGrants;
  final double utilizationPercent;

  EsopPoolSummary({
    required this.pool,
    required this.allocated,
    required this.available,
    required this.exercised,
    required this.activeGrants,
    required this.utilizationPercent,
  });
}

/// Provides detailed summary for an ESOP pool.
@riverpod
Future<EsopPoolSummary?> esopPoolSummary(
  EsopPoolSummaryRef ref,
  String poolId,
) async {
  final db = ref.watch(databaseProvider);

  final pool = await db.getEsopPool(poolId);
  if (pool == null) return null;

  final grants = await db.getOptionGrantsForPool(poolId);

  int allocated = 0;
  int exercised = 0;
  int activeGrants = 0;

  for (final grant in grants) {
    allocated += grant.quantity;
    exercised += grant.exercisedCount;
    if (grant.status == 'active' || grant.status == 'pending') {
      activeGrants++;
    }
  }

  final available = pool.poolSize - allocated;
  final utilizationPercent = pool.poolSize > 0
      ? (allocated / pool.poolSize) * 100
      : 0.0;

  return EsopPoolSummary(
    pool: pool,
    allocated: allocated,
    available: available,
    exercised: exercised,
    activeGrants: activeGrants,
    utilizationPercent: utilizationPercent,
  );
}

/// Aggregated summary across all ESOP pools.
@riverpod
Future<AllPoolsSummary> allEsopPoolsSummary(AllEsopPoolsSummaryRef ref) async {
  final pools = await ref.watch(esopPoolsStreamProvider.future);
  final db = ref.watch(databaseProvider);

  int totalPoolSize = 0;
  int totalAllocated = 0;
  int totalExercised = 0;
  int totalActiveGrants = 0;

  for (final pool in pools) {
    final grants = await db.getOptionGrantsForPool(pool.id);

    totalPoolSize += pool.poolSize;

    for (final grant in grants) {
      totalAllocated += grant.quantity;
      totalExercised += grant.exercisedCount;
      if (grant.status == 'active' || grant.status == 'pending') {
        totalActiveGrants++;
      }
    }
  }

  final totalAvailable = totalPoolSize - totalAllocated;

  return AllPoolsSummary(
    poolCount: pools.length,
    totalPoolSize: totalPoolSize,
    totalAllocated: totalAllocated,
    totalAvailable: totalAvailable,
    totalExercised: totalExercised,
    activeGrants: totalActiveGrants,
  );
}

/// Summary across all ESOP pools.
class AllPoolsSummary {
  final int poolCount;
  final int totalPoolSize;
  final int totalAllocated;
  final int totalAvailable;
  final int totalExercised;
  final int activeGrants;

  AllPoolsSummary({
    required this.poolCount,
    required this.totalPoolSize,
    required this.totalAllocated,
    required this.totalAvailable,
    required this.totalExercised,
    required this.activeGrants,
  });

  double get utilizationPercent =>
      totalPoolSize > 0 ? (totalAllocated / totalPoolSize) * 100 : 0.0;
}

// =============================================================================
// ESOP Pool Mutations (Create, Update, Delete)
// =============================================================================

/// Creates a new ESOP pool.
@riverpod
class CreateEsopPool extends _$CreateEsopPool {
  @override
  FutureOr<void> build() {}

  Future<String> call({
    required String name,
    required String shareClassId,
    required int poolSize,
    double? targetPercentage,
    required DateTime establishedDate,
    String? resolutionReference,
    String? roundId,
    String? defaultVestingScheduleId,
    String strikePriceMethod = 'fmv',
    double? defaultStrikePrice,
    int defaultExpiryYears = 10,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) throw Exception('No company selected');

    final now = DateTime.now();
    final id = 'pool_${now.millisecondsSinceEpoch}';

    await db.upsertEsopPool(
      EsopPoolsCompanion.insert(
        id: id,
        companyId: companyId,
        name: name,
        shareClassId: shareClassId,
        status: Value('active'),
        poolSize: poolSize,
        targetPercentage: Value(targetPercentage),
        establishedDate: establishedDate,
        resolutionReference: Value(resolutionReference),
        roundId: Value(roundId),
        defaultVestingScheduleId: Value(defaultVestingScheduleId),
        strikePriceMethod: Value(strikePriceMethod),
        defaultStrikePrice: Value(defaultStrikePrice),
        defaultExpiryYears: Value(defaultExpiryYears),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Invalidate streams to refresh UI
    ref.invalidate(esopPoolsStreamProvider);

    return id;
  }
}

/// Updates an existing ESOP pool.
@riverpod
class UpdateEsopPool extends _$UpdateEsopPool {
  @override
  FutureOr<void> build() {}

  Future<void> call({
    required String id,
    String? name,
    String? shareClassId,
    String? status,
    int? poolSize,
    double? targetPercentage,
    DateTime? establishedDate,
    String? resolutionReference,
    String? roundId,
    String? defaultVestingScheduleId,
    String? strikePriceMethod,
    double? defaultStrikePrice,
    int? defaultExpiryYears,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getEsopPool(id);
    if (existing == null) throw Exception('ESOP pool not found');

    await db.upsertEsopPool(
      EsopPoolsCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        name: Value(name ?? existing.name),
        shareClassId: Value(shareClassId ?? existing.shareClassId),
        status: Value(status ?? existing.status),
        poolSize: Value(poolSize ?? existing.poolSize),
        targetPercentage: Value(targetPercentage ?? existing.targetPercentage),
        establishedDate: Value(establishedDate ?? existing.establishedDate),
        resolutionReference: Value(
          resolutionReference ?? existing.resolutionReference,
        ),
        roundId: Value(roundId ?? existing.roundId),
        defaultVestingScheduleId: Value(
          defaultVestingScheduleId ?? existing.defaultVestingScheduleId,
        ),
        strikePriceMethod: Value(
          strikePriceMethod ?? existing.strikePriceMethod,
        ),
        defaultStrikePrice: Value(
          defaultStrikePrice ?? existing.defaultStrikePrice,
        ),
        defaultExpiryYears: Value(
          defaultExpiryYears ?? existing.defaultExpiryYears,
        ),
        notes: Value(notes ?? existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );

    ref.invalidate(esopPoolsStreamProvider);
    ref.invalidate(esopPoolByIdProvider(id));
    ref.invalidate(esopPoolSummaryProvider(id));
  }
}

/// Expands an existing ESOP pool by adding more shares.
@riverpod
class ExpandEsopPool extends _$ExpandEsopPool {
  @override
  FutureOr<void> build() {}

  Future<void> call({
    required String poolId,
    required int additionalShares,
    String? resolutionReference,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getEsopPool(poolId);
    if (existing == null) throw Exception('ESOP pool not found');

    final newSize = existing.poolSize + additionalShares;

    await db.upsertEsopPool(
      EsopPoolsCompanion(
        id: Value(poolId),
        companyId: Value(existing.companyId),
        name: Value(existing.name),
        shareClassId: Value(existing.shareClassId),
        status: Value(existing.status),
        poolSize: Value(newSize),
        targetPercentage: Value(existing.targetPercentage),
        establishedDate: Value(existing.establishedDate),
        resolutionReference: Value(
          resolutionReference ?? existing.resolutionReference,
        ),
        roundId: Value(existing.roundId),
        defaultVestingScheduleId: Value(existing.defaultVestingScheduleId),
        strikePriceMethod: Value(existing.strikePriceMethod),
        defaultStrikePrice: Value(existing.defaultStrikePrice),
        defaultExpiryYears: Value(existing.defaultExpiryYears),
        notes: Value(existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );

    ref.invalidate(esopPoolsStreamProvider);
    ref.invalidate(esopPoolByIdProvider(poolId));
    ref.invalidate(esopPoolSummaryProvider(poolId));
  }
}

/// Deletes an ESOP pool.
@riverpod
class DeleteEsopPool extends _$DeleteEsopPool {
  @override
  FutureOr<void> build() {}

  Future<void> call(String id) async {
    final db = ref.read(databaseProvider);

    // Check if there are any grants associated with this pool
    final grants = await db.getOptionGrantsForPool(id);
    if (grants.isNotEmpty) {
      throw Exception(
        'Cannot delete pool with ${grants.length} existing grants. '
        'Please transfer or delete the grants first.',
      );
    }

    await db.deleteEsopPool(id);
    ref.invalidate(esopPoolsStreamProvider);
  }
}

/// Checks if a grant can be made from a specific pool.
@riverpod
Future<bool> canGrantFromPool(
  CanGrantFromPoolRef ref, {
  required String poolId,
  required int quantity,
}) async {
  final summary = await ref.watch(esopPoolSummaryProvider(poolId).future);
  if (summary == null) return false;

  return summary.pool.status == 'active' && quantity <= summary.available;
}
