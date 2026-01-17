import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'projection_adapters.dart';

part 'share_classes_provider.g.dart';

/// Watches all share classes for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<ShareClassesData>> shareClassesStream(ShareClassesStreamRef ref) {
  return ref.watch(unifiedShareClassesStreamProvider.stream);
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
