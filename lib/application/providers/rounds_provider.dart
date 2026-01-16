import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';

part 'rounds_provider.g.dart';

/// Watches all rounds for the current company.
@riverpod
Stream<List<Round>> roundsStream(RoundsStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchRounds(companyId);
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

/// Notifier for round mutations.
@riverpod
class RoundMutations extends _$RoundMutations {
  @override
  FutureOr<void> build() {}

  Future<String> create({
    required String companyId,
    required String name,
    required String type,
    String status = 'draft',
    DateTime? date,
    double? preMoneyValuation,
    double? pricePerShare,
    double? amountRaised,
    String? leadInvestorId,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    // Get next display order
    final existing = await db.getRounds(companyId);
    final displayOrder = existing.length;

    await db.upsertRound(
      RoundsCompanion.insert(
        id: id,
        companyId: companyId,
        name: name,
        type: type,
        status: Value(status),
        displayOrder: displayOrder,
        date: date ?? now,
        preMoneyValuation: Value(preMoneyValuation),
        pricePerShare: Value(pricePerShare),
        amountRaised: Value(amountRaised ?? 0.0),
        leadInvestorId: Value(leadInvestorId),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateRound({
    required String id,
    String? name,
    String? type,
    String? status,
    DateTime? date,
    double? preMoneyValuation,
    double? pricePerShare,
    double? amountRaised,
    String? leadInvestorId,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getRound(id);
    if (existing == null) throw Exception('Round not found');

    await db.upsertRound(
      RoundsCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        name: Value(name ?? existing.name),
        type: Value(type ?? existing.type),
        status: Value(status ?? existing.status),
        displayOrder: Value(existing.displayOrder),
        date: Value(date ?? existing.date),
        preMoneyValuation: Value(
          preMoneyValuation ?? existing.preMoneyValuation,
        ),
        pricePerShare: Value(pricePerShare ?? existing.pricePerShare),
        amountRaised: Value(amountRaised ?? existing.amountRaised),
        leadInvestorId: Value(leadInvestorId ?? existing.leadInvestorId),
        notes: Value(notes ?? existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteRound(id);
  }

  /// Closes a round by:
  /// 1. Setting the round status to 'closed'
  /// 2. Activating pending convertibles (pending → outstanding)
  /// 3. Activating pending warrants (pending → active)
  Future<void> closeRound(String roundId) async {
    final db = ref.read(databaseProvider);

    // 1. Activate pending convertibles for this round
    await db.activatePendingConvertibles(roundId);

    // 2. Activate pending warrants for this round
    await db.activatePendingWarrants(roundId);

    // 3. Set status to closed
    await updateRound(id: roundId, status: 'closed');
  }

  /// Reopens a closed round by:
  /// 1. Reverting any converted convertibles back to outstanding
  /// 2. Setting pending convertibles and warrants back to pending status
  /// 3. Setting the round status back to 'draft'
  /// Note: Holdings are preserved - they are only deleted if the round is deleted.
  Future<void> reopenRound(String roundId) async {
    final db = ref.read(databaseProvider);

    // 1. Revert any convertibles that were converted in this round
    // The conversionEventId should match the roundId when converted during close
    await db.revertConvertiblesByConversionEvent(roundId);

    // 2. Set instruments back to pending status (deactivate)
    await db.deactivateConvertiblesForRound(roundId);
    await db.deactivateWarrantsForRound(roundId);

    // 3. Set status back to draft
    await updateRound(id: roundId, status: 'draft');
  }
}
