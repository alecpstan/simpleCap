import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'holdings_provider.dart';
import 'options_provider.dart';
import 'projection_adapters.dart';

part 'esop_pools_provider.g.dart';

/// Watches all ESOP pools for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<EsopPool>> esopPoolsStream(EsopPoolsStreamRef ref) {
  return ref.watch(unifiedEsopPoolsStreamProvider.stream);
}

/// Gets the list of ESOP pools synchronously from the stream.
@riverpod
List<EsopPool> esopPools(EsopPoolsRef ref) {
  final poolsAsync = ref.watch(esopPoolsStreamProvider);
  return poolsAsync.valueOrNull ?? [];
}

/// Gets a specific ESOP pool by ID.
/// Uses projected state instead of database for event sourcing compatibility.
@riverpod
Future<EsopPool?> esopPoolById(EsopPoolByIdRef ref, String poolId) async {
  final pools = await ref.watch(esopPoolsStreamProvider.future);
  return pools.where((p) => p.id == poolId).firstOrNull;
}

/// Watches option grants for a specific ESOP pool.
/// Uses projected state instead of database for event sourcing compatibility.
@riverpod
Stream<List<OptionGrant>> poolOptionGrantsStream(
  PoolOptionGrantsStreamRef ref,
  String poolId,
) async* {
  final allGrants = await ref.watch(optionGrantsStreamProvider.future);
  yield allGrants.where((g) => g.esopPoolId == poolId).toList();
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
/// Uses projected state instead of database for event sourcing compatibility.
@riverpod
Future<EsopPoolSummary?> esopPoolSummary(
  EsopPoolSummaryRef ref,
  String poolId,
) async {
  // Get pool from projected state
  final pools = await ref.watch(esopPoolsStreamProvider.future);
  final pool = pools.where((p) => p.id == poolId).firstOrNull;
  if (pool == null) return null;

  // Get option grants from projected state
  final allGrants = await ref.watch(optionGrantsStreamProvider.future);
  final grants = allGrants.where((g) => g.esopPoolId == poolId).toList();

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
/// Uses projected state instead of database for event sourcing compatibility.
@riverpod
Future<AllPoolsSummary> allEsopPoolsSummary(AllEsopPoolsSummaryRef ref) async {
  final pools = await ref.watch(esopPoolsStreamProvider.future);
  final allGrants = await ref.watch(optionGrantsStreamProvider.future);

  int totalPoolSize = 0;
  int totalAllocated = 0;
  int totalExercised = 0;
  int totalActiveGrants = 0;

  for (final pool in pools) {
    final grants = allGrants.where((g) => g.esopPoolId == pool.id);

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
        needsExpansion.add(
          PoolExpansionNeeded(
            pool: pool,
            currentPercent: currentPercent,
            targetPercent: targetPercent,
            currentSize: pool.poolSize,
            suggestedNewSize: suggestedNewSize,
            sharesToAdd: sharesToAdd,
          ),
        );
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

// NOTE: PoolExpansionMutations removed - use EsopPoolCommands.expandPool instead
