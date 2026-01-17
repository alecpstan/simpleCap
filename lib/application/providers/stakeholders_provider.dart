import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'projection_adapters.dart';

part 'stakeholders_provider.g.dart';

/// Watches all stakeholders for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<Stakeholder>> stakeholdersStream(StakeholdersStreamRef ref) {
  return ref.watch(unifiedStakeholdersStreamProvider.stream);
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
