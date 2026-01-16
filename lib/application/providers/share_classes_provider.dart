import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';

part 'share_classes_provider.g.dart';

/// Watches all share classes for the current company.
@riverpod
Stream<List<ShareClassesData>> shareClassesStream(ShareClassesStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchShareClasses(companyId);
}

/// Gets a single share class by ID.
@riverpod
Future<ShareClassesData?> shareClass(ShareClassRef ref, String id) async {
  final db = ref.watch(databaseProvider);
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return null;

  final classes = await db.getShareClasses(companyId);
  return classes.where((c) => c.id == id).firstOrNull;
}

/// Notifier for share class mutations.
@riverpod
class ShareClassMutations extends _$ShareClassMutations {
  @override
  FutureOr<void> build() {}

  Future<void> create({
    required String companyId,
    required String name,
    required String type,
    int seniority = 0,
    double liquidationPreference = 1.0,
    bool isParticipating = false,
    double votingMultiplier = 1.0,
    double dividendRate = 0.0,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db.upsertShareClass(
      ShareClassesCompanion.insert(
        id: id,
        companyId: companyId,
        name: name,
        type: type,
        seniority: Value(seniority),
        liquidationPreference: Value(liquidationPreference),
        isParticipating: Value(isParticipating),
        votingMultiplier: Value(votingMultiplier),
        dividendRate: Value(dividendRate),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteShareClass(id);
  }
}
