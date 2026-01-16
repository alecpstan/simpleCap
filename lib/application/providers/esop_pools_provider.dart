import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'holdings_provider.dart';

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

// =============================================================================
// ESOP Pool Expansion Detection
// =============================================================================

/// Represents a pool that needs expansion to meet its target percentage.
class PoolExpansionNeeded {
  final EsopPool pool;
  final double currentPercent;
  final double targetPercent;
  final int currentSize;
  final int suggestedNewSize;
  final int sharesToAdd;

  PoolExpansionNeeded({
    required this.pool,
    required this.currentPercent,
    required this.targetPercent,
    required this.currentSize,
    required this.suggestedNewSize,
    required this.sharesToAdd,
  });

  String get expansionDescription {
    final percentDiff = (targetPercent - currentPercent).abs();
    return 'Pool is ${currentPercent.toStringAsFixed(1)}% of company, '
        'target is ${targetPercent.toStringAsFixed(1)}% '
        '(${percentDiff.toStringAsFixed(1)}% below target)';
  }
}

/// Detects pools that need expansion to meet their target percentage.
@riverpod
Future<List<PoolExpansionNeeded>> poolsNeedingExpansion(
  PoolsNeedingExpansionRef ref,
) async {
  final pools = await ref.watch(esopPoolsStreamProvider.future);
  final ownershipSummary = await ref.watch(ownershipSummaryProvider.future);

  final totalShares = ownershipSummary.totalIssuedShares;
  if (totalShares == 0) return [];

  final needsExpansion = <PoolExpansionNeeded>[];

  for (final pool in pools) {
    // Skip pools without a target percentage
    if (pool.targetPercentage == null) continue;

    // Skip non-active pools
    if (pool.status != 'active') continue;

    final targetPercent = pool.targetPercentage!;

    // Calculate what the pool size represents as a percentage of total
    // Total company = total shares + pool size (pool is part of fully diluted)
    final fullyDiluted = totalShares + pool.poolSize;
    final currentPercent = (pool.poolSize / fullyDiluted) * 100;

    // Check if current percentage is below target (with small tolerance)
    if (currentPercent < targetPercent - 0.1) {
      // Calculate the needed pool size to meet target
      // target% = newPoolSize / (totalShares + newPoolSize) * 100
      // Solving for newPoolSize:
      // target/100 * (totalShares + newPoolSize) = newPoolSize
      // target/100 * totalShares + target/100 * newPoolSize = newPoolSize
      // target/100 * totalShares = newPoolSize - target/100 * newPoolSize
      // target/100 * totalShares = newPoolSize * (1 - target/100)
      // newPoolSize = (target/100 * totalShares) / (1 - target/100)
      final targetFraction = targetPercent / 100;
      final suggestedNewSize =
          ((targetFraction * totalShares) / (1 - targetFraction)).ceil();
      final sharesToAdd = suggestedNewSize - pool.poolSize;

      if (sharesToAdd > 0) {
        needsExpansion.add(PoolExpansionNeeded(
          pool: pool,
          currentPercent: currentPercent,
          targetPercent: targetPercent,
          currentSize: pool.poolSize,
          suggestedNewSize: suggestedNewSize,
          sharesToAdd: sharesToAdd,
        ));
      }
    }
  }

  return needsExpansion;
}

// =============================================================================
// ESOP Pool Expansion History
// =============================================================================

/// Watches all pool expansions for the current company.
@riverpod
Stream<List<EsopPoolExpansion>> poolExpansionsStream(
  PoolExpansionsStreamRef ref,
) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchPoolExpansions(companyId);
}

/// Watches expansions for a specific pool.
@riverpod
Stream<List<EsopPoolExpansion>> poolExpansionHistoryStream(
  PoolExpansionHistoryStreamRef ref,
  String poolId,
) {
  final db = ref.watch(databaseProvider);
  return db.watchExpansionsForPool(poolId);
}

/// Mutations for pool expansions (record, revert).
@riverpod
class PoolExpansionMutations extends _$PoolExpansionMutations {
  @override
  FutureOr<void> build() {}

  /// Record a pool expansion with history tracking.
  Future<void> expandPool({
    required String poolId,
    required int additionalShares,
    required String reason,
    String? resolutionReference,
    String? notes,
    DateTime? expansionDate,
  }) async {
    final db = ref.read(databaseProvider);
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) throw Exception('No company selected');

    final pool = await db.getEsopPool(poolId);
    if (pool == null) throw Exception('Pool not found');

    final now = DateTime.now();
    final effectiveDate = expansionDate ?? now;
    final previousSize = pool.poolSize;
    final newSize = previousSize + additionalShares;

    // Record the expansion in history
    final expansionId = 'exp_${now.millisecondsSinceEpoch}';
    await db.insertPoolExpansion(
      EsopPoolExpansionsCompanion.insert(
        id: expansionId,
        companyId: companyId,
        poolId: poolId,
        previousSize: previousSize,
        newSize: newSize,
        sharesAdded: additionalShares,
        reason: reason,
        resolutionReference: Value(resolutionReference),
        expansionDate: effectiveDate,
        notes: Value(notes),
        createdAt: now,
      ),
    );

    // Update the pool size
    await db.upsertEsopPool(
      EsopPoolsCompanion(
        id: Value(poolId),
        companyId: Value(pool.companyId),
        name: Value(pool.name),
        shareClassId: Value(pool.shareClassId),
        status: Value(pool.status),
        poolSize: Value(newSize),
        targetPercentage: Value(pool.targetPercentage),
        establishedDate: Value(pool.establishedDate),
        resolutionReference: Value(resolutionReference ?? pool.resolutionReference),
        roundId: Value(pool.roundId),
        defaultVestingScheduleId: Value(pool.defaultVestingScheduleId),
        strikePriceMethod: Value(pool.strikePriceMethod),
        defaultStrikePrice: Value(pool.defaultStrikePrice),
        defaultExpiryYears: Value(pool.defaultExpiryYears),
        notes: Value(pool.notes),
        createdAt: Value(pool.createdAt),
        updatedAt: Value(now),
      ),
    );

    // Invalidate relevant providers
    ref.invalidate(esopPoolsStreamProvider);
    ref.invalidate(esopPoolByIdProvider(poolId));
    ref.invalidate(esopPoolSummaryProvider(poolId));
    ref.invalidate(poolExpansionsStreamProvider);
    ref.invalidate(poolExpansionHistoryStreamProvider(poolId));
    ref.invalidate(poolsNeedingExpansionProvider);
  }

  /// Revert the most recent expansion for a pool.
  Future<void> revertLatestExpansion(String poolId) async {
    final db = ref.read(databaseProvider);

    final latestExpansion = await db.getLatestExpansionForPool(poolId);
    if (latestExpansion == null) {
      throw Exception('No expansion history found for this pool');
    }

    final pool = await db.getEsopPool(poolId);
    if (pool == null) throw Exception('Pool not found');

    // Verify the pool size matches what we expect
    if (pool.poolSize != latestExpansion.newSize) {
      throw Exception(
        'Pool size has been modified since the last expansion. '
        'Expected ${latestExpansion.newSize}, found ${pool.poolSize}',
      );
    }

    // Revert the pool size
    await db.upsertEsopPool(
      EsopPoolsCompanion(
        id: Value(poolId),
        companyId: Value(pool.companyId),
        name: Value(pool.name),
        shareClassId: Value(pool.shareClassId),
        status: Value(pool.status),
        poolSize: Value(latestExpansion.previousSize),
        targetPercentage: Value(pool.targetPercentage),
        establishedDate: Value(pool.establishedDate),
        resolutionReference: Value(pool.resolutionReference),
        roundId: Value(pool.roundId),
        defaultVestingScheduleId: Value(pool.defaultVestingScheduleId),
        strikePriceMethod: Value(pool.strikePriceMethod),
        defaultStrikePrice: Value(pool.defaultStrikePrice),
        defaultExpiryYears: Value(pool.defaultExpiryYears),
        notes: Value(pool.notes),
        createdAt: Value(pool.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Delete the expansion record
    await db.deletePoolExpansion(latestExpansion.id);

    // Invalidate relevant providers
    ref.invalidate(esopPoolsStreamProvider);
    ref.invalidate(esopPoolByIdProvider(poolId));
    ref.invalidate(esopPoolSummaryProvider(poolId));
    ref.invalidate(poolExpansionsStreamProvider);
    ref.invalidate(poolExpansionHistoryStreamProvider(poolId));
    ref.invalidate(poolsNeedingExpansionProvider);
  }
}
