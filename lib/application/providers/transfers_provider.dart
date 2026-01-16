import 'dart:async';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'holdings_provider.dart';

part 'transfers_provider.g.dart';

/// Watches all transfers for the current company.
@riverpod
Stream<List<Transfer>> transfersStream(TransfersStreamRef ref) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final db = ref.watch(databaseProvider);
  yield* db.watchTransfers(companyId);
}

/// Watches transfers filtered by status.
@riverpod
Stream<List<Transfer>> transfersByStatus(
  TransfersByStatusRef ref,
  String status,
) async* {
  final allTransfers = ref.watch(transfersStreamProvider);

  yield* allTransfers.when(
    data: (transfers) =>
        Stream.value(transfers.where((t) => t.status == status).toList()),
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}

/// Summary of transfer activity.
class TransfersSummary {
  final int totalTransfers;
  final int pendingTransfers;
  final int completedTransfers;
  final double totalValue;
  final int totalSharesTransferred;

  TransfersSummary({
    required this.totalTransfers,
    required this.pendingTransfers,
    required this.completedTransfers,
    required this.totalValue,
    required this.totalSharesTransferred,
  });
}

/// Provides summary statistics for transfers.
@riverpod
TransfersSummary transfersSummary(TransfersSummaryRef ref) {
  final transfersAsync = ref.watch(transfersStreamProvider);

  return transfersAsync.when(
    data: (transfers) {
      final pending = transfers.where((t) => t.status == 'pending').length;
      final completed = transfers.where((t) => t.status == 'completed').length;
      final totalValue = transfers
          .where((t) => t.status == 'completed')
          .fold<double>(0, (sum, t) => sum + (t.shareCount * t.pricePerShare));
      final totalShares = transfers
          .where((t) => t.status == 'completed')
          .fold<int>(0, (sum, t) => sum + t.shareCount);

      return TransfersSummary(
        totalTransfers: transfers.length,
        pendingTransfers: pending,
        completedTransfers: completed,
        totalValue: totalValue,
        totalSharesTransferred: totalShares,
      );
    },
    loading: () => TransfersSummary(
      totalTransfers: 0,
      pendingTransfers: 0,
      completedTransfers: 0,
      totalValue: 0,
      totalSharesTransferred: 0,
    ),
    error: (_, __) => TransfersSummary(
      totalTransfers: 0,
      pendingTransfers: 0,
      completedTransfers: 0,
      totalValue: 0,
      totalSharesTransferred: 0,
    ),
  );
}

/// Notifier for transfer mutations.
@riverpod
class TransferMutations extends _$TransferMutations {
  @override
  FutureOr<void> build() {}

  /// Create a new transfer (initially pending).
  Future<String> createTransfer({
    required String companyId,
    required String sellerStakeholderId,
    required String buyerStakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    required DateTime transactionDate,
    required String type,
    double? fairMarketValue,
    String? sourceHoldingId,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db.upsertTransfer(
      TransfersCompanion.insert(
        id: id,
        companyId: companyId,
        sellerStakeholderId: sellerStakeholderId,
        buyerStakeholderId: buyerStakeholderId,
        shareClassId: shareClassId,
        shareCount: shareCount,
        pricePerShare: pricePerShare,
        fairMarketValue: Value(fairMarketValue),
        transactionDate: transactionDate,
        type: type,
        status: const Value('pending'),
        rofrWaived: const Value(false),
        sourceHoldingId: Value(sourceHoldingId),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  /// Update transfer status.
  Future<void> updateStatus(String id, String status) async {
    final db = ref.read(databaseProvider);
    final transfer = await db.getTransfer(id);
    if (transfer == null) return;

    await db.upsertTransfer(
      TransfersCompanion(
        id: Value(id),
        companyId: Value(transfer.companyId),
        sellerStakeholderId: Value(transfer.sellerStakeholderId),
        buyerStakeholderId: Value(transfer.buyerStakeholderId),
        shareClassId: Value(transfer.shareClassId),
        shareCount: Value(transfer.shareCount),
        pricePerShare: Value(transfer.pricePerShare),
        fairMarketValue: Value(transfer.fairMarketValue),
        transactionDate: Value(transfer.transactionDate),
        type: Value(transfer.type),
        status: Value(status),
        rofrWaived: Value(transfer.rofrWaived),
        sourceHoldingId: Value(transfer.sourceHoldingId),
        notes: Value(transfer.notes),
        createdAt: Value(transfer.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Execute a completed transfer - adjusts holdings.
  Future<void> executeTransfer(String transferId) async {
    final db = ref.read(databaseProvider);
    final transfer = await db.getTransfer(transferId);
    if (transfer == null) return;

    // Get seller's holdings for this share class
    final sellerHoldings = await db.getStakeholderHoldings(
      transfer.sellerStakeholderId,
    );
    final sellerHolding = sellerHoldings.firstWhere(
      (h) => h.shareClassId == transfer.shareClassId,
      orElse: () =>
          throw Exception('Seller does not have shares in this class'),
    );

    // Validate seller has enough shares
    if (sellerHolding.shareCount < transfer.shareCount) {
      throw Exception(
        'Seller only has ${sellerHolding.shareCount} shares, '
        'cannot transfer ${transfer.shareCount}',
      );
    }

    // Reduce seller's shares
    final newSellerCount = sellerHolding.shareCount - transfer.shareCount;
    if (newSellerCount > 0) {
      await db.updateHoldingShares(sellerHolding.id, newSellerCount);
    } else {
      // Remove the holding entirely if no shares left
      await db.deleteHolding(sellerHolding.id);
    }

    // Check if buyer already has holdings in this share class
    final buyerHoldings = await db.getStakeholderHoldings(
      transfer.buyerStakeholderId,
    );
    final existingBuyerHolding = buyerHoldings
        .where((h) => h.shareClassId == transfer.shareClassId)
        .firstOrNull;

    if (existingBuyerHolding != null) {
      // Add to existing holding (use weighted average cost basis)
      final totalShares = existingBuyerHolding.shareCount + transfer.shareCount;
      final weightedCostBasis =
          ((existingBuyerHolding.costBasis * existingBuyerHolding.shareCount) +
              (transfer.pricePerShare * transfer.shareCount)) /
          totalShares;

      await db.upsertHolding(
        HoldingsCompanion(
          id: Value(existingBuyerHolding.id),
          companyId: Value(existingBuyerHolding.companyId),
          stakeholderId: Value(existingBuyerHolding.stakeholderId),
          shareClassId: Value(existingBuyerHolding.shareClassId),
          shareCount: Value(totalShares),
          costBasis: Value(weightedCostBasis),
          acquiredDate: Value(existingBuyerHolding.acquiredDate),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // Create new holding for buyer
      final holdingMutations = ref.read(holdingMutationsProvider.notifier);
      await holdingMutations.issueShares(
        companyId: transfer.companyId,
        stakeholderId: transfer.buyerStakeholderId,
        shareClassId: transfer.shareClassId,
        shareCount: transfer.shareCount,
        costBasis: transfer.pricePerShare,
        acquiredDate: transfer.transactionDate,
      );
    }

    // Mark transfer as completed
    await updateStatus(transferId, 'completed');
  }

  /// Waive ROFR for a transfer.
  Future<void> waiveRofr(String id) async {
    final db = ref.read(databaseProvider);
    final transfer = await db.getTransfer(id);
    if (transfer == null) return;

    await db.upsertTransfer(
      TransfersCompanion(
        id: Value(id),
        companyId: Value(transfer.companyId),
        sellerStakeholderId: Value(transfer.sellerStakeholderId),
        buyerStakeholderId: Value(transfer.buyerStakeholderId),
        shareClassId: Value(transfer.shareClassId),
        shareCount: Value(transfer.shareCount),
        pricePerShare: Value(transfer.pricePerShare),
        fairMarketValue: Value(transfer.fairMarketValue),
        transactionDate: Value(transfer.transactionDate),
        type: Value(transfer.type),
        status: Value(transfer.status),
        rofrWaived: const Value(true),
        sourceHoldingId: Value(transfer.sourceHoldingId),
        notes: Value(transfer.notes),
        createdAt: Value(transfer.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a transfer (only if pending).
  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    final transfer = await db.getTransfer(id);
    if (transfer == null) return;

    if (transfer.status == 'completed') {
      throw Exception('Cannot delete a completed transfer');
    }

    await db.deleteTransfer(id);
  }
}
