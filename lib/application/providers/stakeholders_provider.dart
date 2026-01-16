import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';

part 'stakeholders_provider.g.dart';

/// Watches all stakeholders for the current company.
@riverpod
Stream<List<Stakeholder>> stakeholdersStream(StakeholdersStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchStakeholders(companyId);
}

/// Gets stakeholders grouped by type.
@riverpod
Future<Map<String, List<Stakeholder>>> stakeholdersByType(
  StakeholdersByTypeRef ref,
) async {
  final stakeholders = await ref.watch(stakeholdersStreamProvider.future);

  final grouped = <String, List<Stakeholder>>{};
  for (final stakeholder in stakeholders) {
    final type = stakeholder.type;
    grouped.putIfAbsent(type, () => []).add(stakeholder);
  }
  return grouped;
}

/// Gets a single stakeholder by ID.
@riverpod
Future<Stakeholder?> stakeholder(StakeholderRef ref, String id) async {
  final db = ref.watch(databaseProvider);
  return db.getStakeholder(id);
}

/// Notifier for stakeholder mutations.
@riverpod
class StakeholderMutations extends _$StakeholderMutations {
  @override
  FutureOr<void> build() {}

  Future<void> create({
    required String companyId,
    required String name,
    required String type,
    String? email,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db.upsertStakeholder(
      StakeholdersCompanion.insert(
        id: id,
        companyId: companyId,
        name: name,
        type: type,
        email: Value(email),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateStakeholder({
    required String id,
    required String name,
    required String type,
    String? email,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getStakeholder(id);
    if (existing == null) throw Exception('Stakeholder not found');

    await db.upsertStakeholder(
      StakeholdersCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        name: Value(name),
        type: Value(type),
        email: Value(email),
        notes: Value(notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteStakeholder(id);
  }
}
