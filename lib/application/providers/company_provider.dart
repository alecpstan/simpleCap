import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';

part 'company_provider.g.dart';

const _kLastCompanyIdKey = 'last_company_id';

/// The currently selected company ID.
///
/// Persists the selection to SharedPreferences and auto-selects
/// the last used company on app startup.
@Riverpod(keepAlive: true)
class CurrentCompanyId extends _$CurrentCompanyId {
  @override
  String? build() {
    // Schedule auto-selection after build
    Future.microtask(() => _autoSelectCompany());
    return null;
  }

  Future<void> _autoSelectCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCompanyId = prefs.getString(_kLastCompanyIdKey);

    final db = ref.read(databaseProvider);
    final companies = await db.getAllCompanies();

    if (companies.isEmpty) return;

    // Try to restore last selected company, or pick first one
    if (lastCompanyId != null && companies.any((c) => c.id == lastCompanyId)) {
      state = lastCompanyId;
    } else {
      state = companies.first.id;
      await prefs.setString(_kLastCompanyIdKey, companies.first.id);
    }
  }

  Future<void> setCompany(String id) async {
    state = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastCompanyIdKey, id);
  }

  Future<void> clearCompany() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastCompanyIdKey);
  }
}

/// Watches all companies in the database.
@riverpod
Stream<List<Company>> companiesStream(CompaniesStreamRef ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCompanies();
}

/// Gets the current company data.
@riverpod
Future<Company?> currentCompany(CurrentCompanyRef ref) async {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return null;

  final db = ref.watch(databaseProvider);
  return db.getCompany(companyId);
}
