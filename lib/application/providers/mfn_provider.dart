import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/mfn_calculator.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'convertibles_provider.dart';

part 'mfn_provider.g.dart';

/// Watches all MFN upgrade records for the current company.
@riverpod
Stream<List<MfnUpgrade>> mfnUpgradesStream(MfnUpgradesStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchMfnUpgrades(companyId);
}

/// Detects pending MFN upgrade opportunities.
///
/// Returns a list of upgrade opportunities for convertibles with MFN clauses
/// that could be upgraded based on later convertibles with better terms.
@riverpod
Future<List<MfnUpgradeOpportunity>> pendingMfnUpgrades(
  PendingMfnUpgradesRef ref,
) async {
  final convertibles = await ref.watch(convertiblesStreamProvider.future);
  final existingUpgrades = await ref.watch(mfnUpgradesStreamProvider.future);

  return MfnCalculator.detectUpgrades(convertibles, existingUpgrades);
}

/// Whether there are pending MFN upgrades available.
@riverpod
Future<bool> hasPendingMfnUpgrades(HasPendingMfnUpgradesRef ref) async {
  final upgrades = await ref.watch(pendingMfnUpgradesProvider.future);
  return upgrades.isNotEmpty;
}

/// Count of pending MFN upgrades.
@riverpod
Future<int> pendingMfnUpgradeCount(PendingMfnUpgradeCountRef ref) async {
  final upgrades = await ref.watch(pendingMfnUpgradesProvider.future);
  return upgrades.length;
}
