import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'projection_adapters.dart';

part 'transfers_provider.g.dart';

/// Watches all transfers for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<Transfer>> transfersStream(TransfersStreamRef ref) {
  return ref.watch(unifiedTransfersStreamProvider.stream);
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
