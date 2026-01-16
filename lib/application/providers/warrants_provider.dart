import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'providers.dart';

part 'warrants_provider.g.dart';

/// Stream of all warrants for the current company.
@riverpod
Stream<List<Warrant>> warrantsStream(WarrantsStreamRef ref) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final db = ref.watch(databaseProvider);
  yield* db.watchWarrants(companyId);
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

/// Mutations for warrants.
@riverpod
class WarrantMutations extends _$WarrantMutations {
  @override
  FutureOr<void> build() {}

  /// Create a new warrant.
  Future<String> create({
    required String companyId,
    required String stakeholderId,
    required String shareClassId,
    required int quantity,
    required double strikePrice,
    required DateTime issueDate,
    required DateTime expiryDate,
    String status = 'active', // 'pending' when created in round builder
    String? sourceConvertibleId,
    String? roundId,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db
        .into(db.warrants)
        .insert(
          WarrantsCompanion.insert(
            id: id,
            companyId: companyId,
            stakeholderId: stakeholderId,
            shareClassId: shareClassId,
            quantity: quantity,
            strikePrice: strikePrice,
            status: Value(status),
            issueDate: issueDate,
            expiryDate: expiryDate,
            sourceConvertibleId: Value(sourceConvertibleId),
            roundId: Value(roundId),
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return id;
  }

  /// Update an existing warrant.
  Future<void> updateWarrant({
    required String id,
    String? shareClassId,
    int? quantity,
    double? strikePrice,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? sourceConvertibleId,
    String? roundId,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    await (db.update(db.warrants)..where((w) => w.id.equals(id))).write(
      WarrantsCompanion(
        shareClassId: shareClassId != null
            ? Value(shareClassId)
            : const Value.absent(),
        quantity: quantity != null ? Value(quantity) : const Value.absent(),
        strikePrice: strikePrice != null
            ? Value(strikePrice)
            : const Value.absent(),
        issueDate: issueDate != null ? Value(issueDate) : const Value.absent(),
        expiryDate: expiryDate != null
            ? Value(expiryDate)
            : const Value.absent(),
        sourceConvertibleId: sourceConvertibleId != null
            ? Value(sourceConvertibleId)
            : const Value.absent(),
        roundId: roundId != null ? Value(roundId) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  /// Exercise warrants (convert to shares).
  Future<void> exercise({
    required String id,
    required int sharesToExercise,
    DateTime? exerciseDate,
  }) async {
    final db = ref.read(databaseProvider);
    final warrant = await db.getWarrant(id);
    if (warrant == null) return;

    final outstanding =
        warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;
    if (sharesToExercise > outstanding) return;

    final newExercised = warrant.exercisedCount + sharesToExercise;
    final effectiveDate = exerciseDate ?? DateTime.now();

    await (db.update(db.warrants)..where((w) => w.id.equals(id))).write(
      WarrantsCompanion(
        exercisedCount: Value(newExercised),
        status: Value(
          newExercised == warrant.quantity ? 'exercised' : 'active',
        ),
        updatedAt: Value(effectiveDate),
      ),
    );
  }

  /// Undo exercise (revert exercised warrants back to outstanding).
  Future<void> unexercise({
    required String id,
    required int sharesToUnexercise,
  }) async {
    final db = ref.read(databaseProvider);
    final warrant = await db.getWarrant(id);
    if (warrant == null) return;

    if (sharesToUnexercise > warrant.exercisedCount) return;

    final newExercised = warrant.exercisedCount - sharesToUnexercise;
    final now = DateTime.now();

    await (db.update(db.warrants)..where((w) => w.id.equals(id))).write(
      WarrantsCompanion(
        exercisedCount: Value(newExercised),
        status: const Value('active'), // Revert to active when unexercising
        updatedAt: Value(now),
      ),
    );
  }

  /// Cancel warrants.
  Future<void> cancel({required String id, required int sharesToCancel}) async {
    final db = ref.read(databaseProvider);
    final warrant = await db.getWarrant(id);
    if (warrant == null) return;

    final outstanding =
        warrant.quantity - warrant.exercisedCount - warrant.cancelledCount;
    if (sharesToCancel > outstanding) return;

    final newCancelled = warrant.cancelledCount + sharesToCancel;
    final now = DateTime.now();

    await (db.update(db.warrants)..where((w) => w.id.equals(id))).write(
      WarrantsCompanion(
        cancelledCount: Value(newCancelled),
        status: Value(
          newCancelled + warrant.exercisedCount == warrant.quantity
              ? 'cancelled'
              : 'active',
        ),
        updatedAt: Value(now),
      ),
    );
  }

  /// Delete a warrant.
  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.warrants)..where((w) => w.id.equals(id))).go();
  }
}
