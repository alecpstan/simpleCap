import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'projection_adapters.dart';

part 'warrants_provider.g.dart';

/// Stream of all warrants for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<Warrant>> warrantsStream(WarrantsStreamRef ref) {
  return ref.watch(unifiedWarrantsStreamProvider.stream);
}

/// Warrants grouped by status.
@riverpod
Map<String, List<Warrant>> warrantsByStatus(WarrantsByStatusRef ref) {
  final warrants = ref.watch(warrantsStreamProvider).valueOrNull ?? [];
  final grouped = <String, List<Warrant>>{};

  for (final warrant in warrants) {
    grouped.putIfAbsent(warrant.status, () => []).add(warrant);
  }

  return grouped;
}

/// Summary of all warrants for the current company.
class WarrantsSummary {
  final int totalIssued;
  final int totalExercised;
  final int totalCancelled;
  final int outstandingWarrants;
  final int activeWarrants;

  const WarrantsSummary({
    required this.totalIssued,
    required this.totalExercised,
    required this.totalCancelled,
    required this.outstandingWarrants,
    required this.activeWarrants,
  });

  factory WarrantsSummary.empty() => const WarrantsSummary(
    totalIssued: 0,
    totalExercised: 0,
    totalCancelled: 0,
    outstandingWarrants: 0,
    activeWarrants: 0,
  );
}

@riverpod
WarrantsSummary warrantsSummary(WarrantsSummaryRef ref) {
  final warrants = ref.watch(warrantsStreamProvider).valueOrNull ?? [];
  if (warrants.isEmpty) return WarrantsSummary.empty();

  int totalIssued = 0;
  int totalExercised = 0;
  int totalCancelled = 0;
  int activeWarrants = 0;

  for (final warrant in warrants) {
    totalIssued += warrant.quantity;
    totalExercised += warrant.exercisedCount;
    totalCancelled += warrant.cancelledCount;
    if (warrant.status == 'active') {
      activeWarrants++;
    }
  }

  return WarrantsSummary(
    totalIssued: totalIssued,
    totalExercised: totalExercised,
    totalCancelled: totalCancelled,
    outstandingWarrants: totalIssued - totalExercised - totalCancelled,
    activeWarrants: activeWarrants,
  );
}
