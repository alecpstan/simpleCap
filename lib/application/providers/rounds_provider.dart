import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'projection_adapters.dart';

part 'rounds_provider.g.dart';

/// Watches all rounds for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<Round>> roundsStream(RoundsStreamRef ref) {
  return ref.watch(unifiedRoundsStreamProvider.stream);
}

/// Gets rounds grouped by status.
@riverpod
Future<Map<String, List<Round>>> roundsByStatus(RoundsByStatusRef ref) async {
  final rounds = await ref.watch(roundsStreamProvider.future);

  final grouped = <String, List<Round>>{};
  for (final round in rounds) {
    final status = round.status;
    grouped.putIfAbsent(status, () => []).add(round);
  }
  return grouped;
}

/// Gets a single round by ID.
@riverpod
Future<Round?> round(RoundRef ref, String id) async {
  final db = ref.watch(databaseProvider);
  return db.getRound(id);
}

/// Calculates summary stats for all rounds.
@riverpod
Future<RoundsSummary> roundsSummary(RoundsSummaryRef ref) async {
  final rounds = await ref.watch(roundsStreamProvider.future);

  double totalRaised = 0;
  int closedCount = 0;
  int draftCount = 0;

  for (final round in rounds) {
    if (round.status == 'closed') {
      totalRaised += round.amountRaised;
      closedCount++;
    } else if (round.status == 'draft') {
      draftCount++;
    }
  }

  return RoundsSummary(
    totalRaised: totalRaised,
    closedRounds: closedCount,
    draftRounds: draftCount,
    totalRounds: rounds.length,
  );
}

/// Summary data for rounds.
class RoundsSummary {
  final double totalRaised;
  final int closedRounds;
  final int draftRounds;
  final int totalRounds;

  const RoundsSummary({
    required this.totalRaised,
    required this.closedRounds,
    required this.draftRounds,
    required this.totalRounds,
  });
}
