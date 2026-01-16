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

/// Notifier for MFN upgrade mutations.
@riverpod
class MfnMutations extends _$MfnMutations {
  @override
  FutureOr<void> build() {}

  /// Apply a single MFN upgrade.
  ///
  /// This updates the target convertible with better terms from the source,
  /// and records the upgrade for audit trail and potential reversal.
  Future<void> applyUpgrade(MfnUpgradeOpportunity upgrade) async {
    final db = ref.read(databaseProvider);
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) throw Exception('No company selected');

    final target = upgrade.target;
    final now = DateTime.now();
    final upgradeId = now.millisecondsSinceEpoch.toString();

    // Record the upgrade before applying
    await db.insertMfnUpgrade(
      MfnUpgradesCompanion.insert(
        id: upgradeId,
        companyId: companyId,
        targetConvertibleId: target.id,
        sourceConvertibleId: upgrade.source.id,
        previousDiscountPercent: Value(target.discountPercent),
        previousValuationCap: Value(target.valuationCap),
        previousHasProRata: Value(target.hasProRata),
        newDiscountPercent: Value(
          upgrade.newDiscountPercent ?? target.discountPercent,
        ),
        newValuationCap: Value(upgrade.newValuationCap ?? target.valuationCap),
        newHasProRata: Value(upgrade.addsProRata ? true : target.hasProRata),
        upgradeDate: now,
        createdAt: now,
      ),
    );

    // Apply the upgrade to the target convertible
    await db.upsertConvertible(
      ConvertiblesCompanion(
        id: Value(target.id),
        companyId: Value(target.companyId),
        stakeholderId: Value(target.stakeholderId),
        type: Value(target.type),
        status: Value(target.status),
        principal: Value(target.principal),
        valuationCap: Value(upgrade.newValuationCap ?? target.valuationCap),
        discountPercent: Value(
          upgrade.newDiscountPercent ?? target.discountPercent,
        ),
        interestRate: Value(target.interestRate),
        issueDate: Value(target.issueDate),
        maturityDate: Value(target.maturityDate),
        hasMfn: Value(target.hasMfn),
        hasProRata: Value(upgrade.addsProRata ? true : target.hasProRata),
        conversionEventId: Value(target.conversionEventId),
        convertedToShareClassId: Value(target.convertedToShareClassId),
        sharesReceived: Value(target.sharesReceived),
        notes: Value(target.notes),
        createdAt: Value(target.createdAt),
        updatedAt: Value(now),
      ),
    );
  }

  /// Apply all pending MFN upgrades.
  ///
  /// Returns the number of upgrades applied.
  Future<int> applyAllUpgrades() async {
    final upgrades = await ref.read(pendingMfnUpgradesProvider.future);
    if (upgrades.isEmpty) return 0;

    for (final upgrade in upgrades) {
      await applyUpgrade(upgrade);
    }

    return upgrades.length;
  }

  /// Revert MFN upgrades triggered by a source convertible.
  ///
  /// Called when a convertible is deleted or edited to terms that
  /// no longer trigger MFN upgrades.
  Future<int> revertUpgradesFromSource(String sourceConvertibleId) async {
    final db = ref.read(databaseProvider);

    // Get all upgrades that were triggered by this source
    final upgradesToRevert = await db.getMfnUpgradesFromSource(
      sourceConvertibleId,
    );

    if (upgradesToRevert.isEmpty) return 0;

    // Revert each upgrade
    for (final upgrade in upgradesToRevert) {
      final target = await db.getConvertible(upgrade.targetConvertibleId);
      if (target == null) continue;

      // Get all upgrades for this target to find the correct previous state
      final allUpgradesForTarget = await db.getMfnUpgradesForTarget(target.id);

      // Find the upgrade we're reverting and determine the correct previous state
      final upgradeIndex = allUpgradesForTarget.indexWhere(
        (u) => u.id == upgrade.id,
      );

      double? previousDiscount;
      double? previousCap;
      bool previousProRata;

      if (upgradeIndex == 0) {
        // This was the first upgrade, use original terms from the upgrade record
        previousDiscount = upgrade.previousDiscountPercent;
        previousCap = upgrade.previousValuationCap;
        previousProRata = upgrade.previousHasProRata;
      } else {
        // Use the terms from the previous upgrade's "new" values
        final previousUpgrade = allUpgradesForTarget[upgradeIndex - 1];
        previousDiscount = previousUpgrade.newDiscountPercent;
        previousCap = previousUpgrade.newValuationCap;
        previousProRata = previousUpgrade.newHasProRata;
      }

      // Restore the target to previous terms
      await db.upsertConvertible(
        ConvertiblesCompanion(
          id: Value(target.id),
          companyId: Value(target.companyId),
          stakeholderId: Value(target.stakeholderId),
          type: Value(target.type),
          status: Value(target.status),
          principal: Value(target.principal),
          valuationCap: Value(previousCap),
          discountPercent: Value(previousDiscount),
          interestRate: Value(target.interestRate),
          issueDate: Value(target.issueDate),
          maturityDate: Value(target.maturityDate),
          hasMfn: Value(target.hasMfn),
          hasProRata: Value(previousProRata),
          conversionEventId: Value(target.conversionEventId),
          convertedToShareClassId: Value(target.convertedToShareClassId),
          sharesReceived: Value(target.sharesReceived),
          notes: Value(target.notes),
          createdAt: Value(target.createdAt),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    // Delete the upgrade records
    await db.deleteMfnUpgradesFromSource(sourceConvertibleId);

    return upgradesToRevert.length;
  }

  /// Check and revert MFN upgrades if a convertible is edited.
  ///
  /// Called after a convertible is edited to check if it still triggers
  /// the MFN upgrades it previously triggered.
  Future<void> checkAndRevertIfNeeded(String editedConvertibleId) async {
    final db = ref.read(databaseProvider);

    // Get all upgrades triggered by this convertible
    final triggeredUpgrades = await db.getMfnUpgradesFromSource(
      editedConvertibleId,
    );

    if (triggeredUpgrades.isEmpty) return;

    // Get the edited convertible
    final editedSource = await db.getConvertible(editedConvertibleId);
    if (editedSource == null) {
      // Convertible was deleted, revert all upgrades
      await revertUpgradesFromSource(editedConvertibleId);
      return;
    }

    // Check each upgrade to see if it should be reverted
    for (final upgrade in triggeredUpgrades) {
      final target = await db.getConvertible(upgrade.targetConvertibleId);
      if (target == null) continue;

      // Check if the source still has better terms than the original
      final stillTriggers = MfnCalculator.sourceStillTriggersMfn(
        editedSource,
        target,
        upgrade,
      );

      if (!stillTriggers) {
        // This upgrade should be reverted
        await _revertSingleUpgrade(upgrade);
      }
    }
  }

  Future<void> _revertSingleUpgrade(MfnUpgrade upgrade) async {
    final db = ref.read(databaseProvider);
    final target = await db.getConvertible(upgrade.targetConvertibleId);
    if (target == null) return;

    // Restore to previous terms
    await db.upsertConvertible(
      ConvertiblesCompanion(
        id: Value(target.id),
        companyId: Value(target.companyId),
        stakeholderId: Value(target.stakeholderId),
        type: Value(target.type),
        status: Value(target.status),
        principal: Value(target.principal),
        valuationCap: Value(upgrade.previousValuationCap),
        discountPercent: Value(upgrade.previousDiscountPercent),
        interestRate: Value(target.interestRate),
        issueDate: Value(target.issueDate),
        maturityDate: Value(target.maturityDate),
        hasMfn: Value(target.hasMfn),
        hasProRata: Value(upgrade.previousHasProRata),
        conversionEventId: Value(target.conversionEventId),
        convertedToShareClassId: Value(target.convertedToShareClassId),
        sharesReceived: Value(target.sharesReceived),
        notes: Value(target.notes),
        createdAt: Value(target.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Delete the upgrade record
    await db.deleteMfnUpgrade(upgrade.id);
  }
}
