import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/events/cap_table_event.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'event_providers.dart';
import 'company_provider.dart';

part 'commands.g.dart';

/// Commands are the write-side of our event-sourced architecture.
/// Each command validates input and emits one or more events.
/// The events are then projected to update state.

const _uuid = Uuid();

// ============================================================
// Company Commands
// ============================================================

@riverpod
class CompanyCommands extends _$CompanyCommands {
  @override
  FutureOr<void> build() {}

  /// Create a new company.
  Future<String> createCompany({required String name, String? actorId}) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    // First insert into companies table (required for foreign key constraint)
    final db = ref.read(databaseProvider);
    await db
        .into(db.companies)
        .insert(
          CompaniesCompanion.insert(
            id: id,
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Then create and append the event
    final event = CompanyCreated(
      companyId: id,
      name: name,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).appendForCompany(id, [event]);

    return id;
  }

  /// Rename an existing company.
  Future<void> renameCompany({
    required String companyId,
    required String previousName,
    required String newName,
    String? actorId,
  }) async {
    final event = CompanyRenamed(
      companyId: companyId,
      previousName: previousName,
      newName: newName,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Stakeholder Commands
// ============================================================

@riverpod
class StakeholderCommands extends _$StakeholderCommands {
  @override
  FutureOr<void> build() {}

  /// Add a new stakeholder.
  Future<String> addStakeholder({
    required String name,
    required String type,
    String? email,
    String? phone,
    String? company,
    bool hasProRataRights = false,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = StakeholderAdded(
      companyId: companyId,
      stakeholderId: id,
      name: name,
      stakeholderType: type,
      email: email,
      phone: phone,
      company: company,
      hasProRataRights: hasProRataRights,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Update an existing stakeholder.
  Future<void> updateStakeholder({
    required String stakeholderId,
    String? name,
    String? type,
    String? email,
    String? phone,
    String? company,
    bool? hasProRataRights,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = StakeholderUpdated(
      companyId: companyId,
      stakeholderId: stakeholderId,
      name: name,
      stakeholderType: type,
      email: email,
      phone: phone,
      company: company,
      hasProRataRights: hasProRataRights,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Remove a stakeholder.
  Future<void> removeStakeholder({
    required String stakeholderId,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = StakeholderRemoved(
      companyId: companyId,
      stakeholderId: stakeholderId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Share Class Commands
// ============================================================

@riverpod
class ShareClassCommands extends _$ShareClassCommands {
  @override
  FutureOr<void> build() {}

  /// Create a new share class.
  Future<String> createShareClass({
    required String name,
    required String type,
    double votingMultiplier = 1.0,
    double liquidationPreference = 1.0,
    bool isParticipating = false,
    double dividendRate = 0.0,
    int seniority = 0,
    String antiDilutionType = 'none',
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = ShareClassCreated(
      companyId: companyId,
      shareClassId: id,
      name: name,
      shareClassType: type,
      votingMultiplier: votingMultiplier,
      liquidationPreference: liquidationPreference,
      isParticipating: isParticipating,
      dividendRate: dividendRate,
      seniority: seniority,
      antiDilutionType: antiDilutionType,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Update an existing share class.
  Future<void> updateShareClass({
    required String shareClassId,
    String? name,
    String? type,
    double? votingMultiplier,
    double? liquidationPreference,
    bool? isParticipating,
    double? dividendRate,
    int? seniority,
    String? antiDilutionType,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = ShareClassUpdated(
      companyId: companyId,
      shareClassId: shareClassId,
      name: name,
      shareClassType: type,
      votingMultiplier: votingMultiplier,
      liquidationPreference: liquidationPreference,
      isParticipating: isParticipating,
      dividendRate: dividendRate,
      seniority: seniority,
      antiDilutionType: antiDilutionType,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Round Commands
// ============================================================

@riverpod
class RoundCommands extends _$RoundCommands {
  @override
  FutureOr<void> build() {}

  /// Open a new funding round.
  Future<String> openRound({
    required String name,
    required String type,
    required DateTime date,
    required int displayOrder,
    double? preMoneyValuation,
    double? pricePerShare,
    String? leadInvestorId,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = RoundOpened(
      companyId: companyId,
      roundId: id,
      name: name,
      roundType: type,
      date: date,
      displayOrder: displayOrder,
      preMoneyValuation: preMoneyValuation,
      pricePerShare: pricePerShare,
      leadInvestorId: leadInvestorId,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Close a round with final terms.
  Future<void> closeRound({
    required String roundId,
    required double amountRaised,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = RoundClosed(
      companyId: companyId,
      roundId: roundId,
      amountRaised: amountRaised,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Amend round terms.
  Future<void> amendRound({
    required String roundId,
    String? name,
    String? type,
    DateTime? date,
    double? preMoneyValuation,
    double? pricePerShare,
    String? leadInvestorId,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = RoundAmended(
      companyId: companyId,
      roundId: roundId,
      name: name,
      roundType: type,
      date: date,
      preMoneyValuation: preMoneyValuation,
      pricePerShare: pricePerShare,
      leadInvestorId: leadInvestorId,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Reopen a closed round.
  Future<void> reopenRound({required String roundId, String? actorId}) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = RoundReopened(
      companyId: companyId,
      roundId: roundId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Delete a round.
  Future<void> deleteRound({required String roundId, String? actorId}) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = RoundDeleted(
      companyId: companyId,
      roundId: roundId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Holding Commands (Share Issuance)
// ============================================================

@riverpod
class HoldingCommands extends _$HoldingCommands {
  @override
  FutureOr<void> build() {}

  /// Issue shares to a stakeholder.
  Future<String> issueShares({
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    required double costBasis,
    required DateTime acquiredDate,
    String? roundId,
    String? vestingScheduleId,
    String? sourceOptionGrantId,
    String? sourceWarrantId,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final holdingId = _uuid.v4();
    final now = DateTime.now();

    final event = SharesIssued(
      companyId: companyId,
      holdingId: holdingId,
      stakeholderId: stakeholderId,
      shareClassId: shareClassId,
      shareCount: shareCount,
      costBasis: costBasis,
      acquiredDate: acquiredDate,
      roundId: roundId,
      vestingScheduleId: vestingScheduleId,
      sourceOptionGrantId: sourceOptionGrantId,
      sourceWarrantId: sourceWarrantId,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return holdingId;
  }

  /// Transfer shares between stakeholders.
  Future<String> transferShares({
    required String sellerStakeholderId,
    required String buyerStakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    double? fairMarketValue,
    required DateTime transactionDate,
    required String transferType,
    String? sourceHoldingId,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final transferId = _uuid.v4();

    final event = SharesTransferred(
      companyId: companyId,
      transferId: transferId,
      sellerStakeholderId: sellerStakeholderId,
      buyerStakeholderId: buyerStakeholderId,
      shareClassId: shareClassId,
      shareCount: shareCount,
      pricePerShare: pricePerShare,
      fairMarketValue: fairMarketValue,
      transactionDate: transactionDate,
      transferType: transferType,
      sourceHoldingId: sourceHoldingId,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return transferId;
  }

  /// Repurchase shares from a stakeholder.
  Future<void> repurchaseShares({
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    required DateTime repurchaseDate,
    String? holdingId,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = SharesRepurchased(
      companyId: companyId,
      stakeholderId: stakeholderId,
      shareClassId: shareClassId,
      shareCount: shareCount,
      pricePerShare: pricePerShare,
      repurchaseDate: repurchaseDate,
      holdingId: holdingId,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Convertible Commands (SAFEs/Notes)
// ============================================================

@riverpod
class ConvertibleCommands extends _$ConvertibleCommands {
  @override
  FutureOr<void> build() {}

  /// Issue a new convertible (SAFE or note).
  Future<String> issueConvertible({
    required String stakeholderId,
    required String type,
    required double principal,
    required DateTime issueDate,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? maturityDate,
    bool hasMfn = false,
    bool hasProRata = false,
    String? roundId,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = ConvertibleIssued(
      companyId: companyId,
      convertibleId: id,
      stakeholderId: stakeholderId,
      convertibleType: type,
      principal: principal,
      issueDate: issueDate,
      valuationCap: valuationCap,
      discountPercent: discountPercent,
      interestRate: interestRate,
      maturityDate: maturityDate,
      hasMfn: hasMfn,
      hasProRata: hasProRata,
      roundId: roundId,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Apply MFN upgrade to a convertible.
  Future<String> applyMfnUpgrade({
    required String targetConvertibleId,
    required String sourceConvertibleId,
    double? previousDiscountPercent,
    double? previousValuationCap,
    bool previousHasProRata = false,
    double? newDiscountPercent,
    double? newValuationCap,
    bool newHasProRata = false,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final upgradeId = _uuid.v4();

    final event = MfnUpgradeApplied(
      companyId: companyId,
      upgradeId: upgradeId,
      targetConvertibleId: targetConvertibleId,
      sourceConvertibleId: sourceConvertibleId,
      previousDiscountPercent: previousDiscountPercent,
      previousValuationCap: previousValuationCap,
      previousHasProRata: previousHasProRata,
      newDiscountPercent: newDiscountPercent,
      newValuationCap: newValuationCap,
      newHasProRata: newHasProRata,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return upgradeId;
  }

  /// Convert a convertible to shares.
  Future<void> convertConvertible({
    required String convertibleId,
    required String roundId,
    required String toShareClassId,
    required int sharesReceived,
    required double conversionPrice,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = ConvertibleConverted(
      companyId: companyId,
      convertibleId: convertibleId,
      roundId: roundId,
      toShareClassId: toShareClassId,
      sharesReceived: sharesReceived,
      conversionPrice: conversionPrice,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Cancel a convertible.
  Future<void> cancelConvertible({
    required String convertibleId,
    String? reason,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = ConvertibleCancelled(
      companyId: companyId,
      convertibleId: convertibleId,
      reason: reason,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// ESOP Pool Commands
// ============================================================

@riverpod
class EsopPoolCommands extends _$EsopPoolCommands {
  @override
  FutureOr<void> build() {}

  /// Create a new ESOP pool.
  Future<String> createPool({
    required String name,
    required String shareClassId,
    required int poolSize,
    double? targetPercentage,
    required DateTime establishedDate,
    String? resolutionReference,
    String? roundId,
    String? defaultVestingScheduleId,
    String strikePriceMethod = 'fmv',
    double? defaultStrikePrice,
    int defaultExpiryYears = 10,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = EsopPoolCreated(
      companyId: companyId,
      poolId: id,
      name: name,
      shareClassId: shareClassId,
      poolSize: poolSize,
      targetPercentage: targetPercentage,
      establishedDate: establishedDate,
      resolutionReference: resolutionReference,
      roundId: roundId,
      defaultVestingScheduleId: defaultVestingScheduleId,
      strikePriceMethod: strikePriceMethod,
      defaultStrikePrice: defaultStrikePrice,
      defaultExpiryYears: defaultExpiryYears,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Expand an ESOP pool.
  Future<String> expandPool({
    required String poolId,
    required int previousSize,
    required int newSize,
    required int sharesAdded,
    required String reason,
    String? resolutionReference,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final expansionId = _uuid.v4();

    final event = EsopPoolExpanded(
      companyId: companyId,
      expansionId: expansionId,
      poolId: poolId,
      previousSize: previousSize,
      newSize: newSize,
      sharesAdded: sharesAdded,
      reason: reason,
      resolutionReference: resolutionReference,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return expansionId;
  }
}

// ============================================================
// Option Grant Commands
// ============================================================

@riverpod
class OptionGrantCommands extends _$OptionGrantCommands {
  @override
  FutureOr<void> build() {}

  /// Grant options to a stakeholder.
  Future<String> grantOptions({
    required String stakeholderId,
    required String shareClassId,
    String? esopPoolId,
    required int quantity,
    required double strikePrice,
    required DateTime grantDate,
    required DateTime expiryDate,
    String? vestingScheduleId,
    String? roundId,
    bool allowsEarlyExercise = false,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = OptionGranted(
      companyId: companyId,
      grantId: id,
      stakeholderId: stakeholderId,
      shareClassId: shareClassId,
      esopPoolId: esopPoolId,
      quantity: quantity,
      strikePrice: strikePrice,
      grantDate: grantDate,
      expiryDate: expiryDate,
      vestingScheduleId: vestingScheduleId,
      roundId: roundId,
      allowsEarlyExercise: allowsEarlyExercise,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Exercise options.
  Future<void> exerciseOptions({
    required String grantId,
    required int exercisedCount,
    required double exercisePrice,
    required DateTime exerciseDate,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final resultingHoldingId = _uuid.v4();

    final event = OptionsExercised(
      companyId: companyId,
      grantId: grantId,
      exercisedCount: exercisedCount,
      exercisePrice: exercisePrice,
      exerciseDate: exerciseDate,
      resultingHoldingId: resultingHoldingId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Cancel options.
  Future<void> cancelOptions({
    required String grantId,
    required int cancelledCount,
    String? reason,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = OptionsCancelled(
      companyId: companyId,
      grantId: grantId,
      cancelledCount: cancelledCount,
      reason: reason,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Warrant Commands
// ============================================================

@riverpod
class WarrantCommands extends _$WarrantCommands {
  @override
  FutureOr<void> build() {}

  /// Issue a warrant.
  Future<String> issueWarrant({
    required String stakeholderId,
    required String shareClassId,
    required int quantity,
    required double strikePrice,
    required DateTime issueDate,
    required DateTime expiryDate,
    String? sourceConvertibleId,
    String? roundId,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = WarrantIssued(
      companyId: companyId,
      warrantId: id,
      stakeholderId: stakeholderId,
      shareClassId: shareClassId,
      quantity: quantity,
      strikePrice: strikePrice,
      issueDate: issueDate,
      expiryDate: expiryDate,
      sourceConvertibleId: sourceConvertibleId,
      roundId: roundId,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Exercise warrants.
  Future<void> exerciseWarrants({
    required String warrantId,
    required int exercisedCount,
    required double exercisePrice,
    required DateTime exerciseDate,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final resultingHoldingId = _uuid.v4();

    final event = WarrantExercised(
      companyId: companyId,
      warrantId: warrantId,
      exercisedCount: exercisedCount,
      exercisePrice: exercisePrice,
      exerciseDate: exerciseDate,
      resultingHoldingId: resultingHoldingId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Cancel warrants.
  Future<void> cancelWarrants({
    required String warrantId,
    required int cancelledCount,
    String? reason,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = WarrantCancelled(
      companyId: companyId,
      warrantId: warrantId,
      cancelledCount: cancelledCount,
      reason: reason,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Update a warrant.
  Future<void> updateWarrant({
    required String warrantId,
    String? shareClassId,
    int? quantity,
    double? strikePrice,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? roundId,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = WarrantUpdated(
      companyId: companyId,
      warrantId: warrantId,
      shareClassId: shareClassId,
      quantity: quantity,
      strikePrice: strikePrice,
      issueDate: issueDate,
      expiryDate: expiryDate,
      roundId: roundId,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Unexercise previously exercised warrants.
  Future<void> unexerciseWarrants({
    required String warrantId,
    required int unexercisedCount,
    String? reason,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = WarrantUnexercised(
      companyId: companyId,
      warrantId: warrantId,
      unexercisedCount: unexercisedCount,
      reason: reason,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Vesting Schedule Commands
// ============================================================

@riverpod
class VestingScheduleCommands extends _$VestingScheduleCommands {
  @override
  FutureOr<void> build() {}

  /// Create a vesting schedule.
  Future<String> createVestingSchedule({
    required String name,
    required String type,
    int? totalMonths,
    int cliffMonths = 0,
    String? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = VestingScheduleCreated(
      companyId: companyId,
      scheduleId: id,
      name: name,
      scheduleType: type,
      totalMonths: totalMonths,
      cliffMonths: cliffMonths,
      frequency: frequency,
      milestonesJson: milestonesJson,
      totalHours: totalHours,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Update a vesting schedule.
  Future<void> updateVestingSchedule({
    required String scheduleId,
    String? name,
    String? type,
    int? totalMonths,
    int? cliffMonths,
    String? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = VestingScheduleUpdated(
      companyId: companyId,
      scheduleId: scheduleId,
      name: name,
      scheduleType: type,
      totalMonths: totalMonths,
      cliffMonths: cliffMonths,
      frequency: frequency,
      milestonesJson: milestonesJson,
      totalHours: totalHours,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Create the standard 4-year / 1-year cliff schedule.
  Future<String> createStandard4YearSchedule() async {
    return createVestingSchedule(
      name: '4 Year / 1 Year Cliff',
      type: 'time_based',
      totalMonths: 48,
      cliffMonths: 12,
      frequency: 'monthly',
    );
  }

  /// Create a 3-year / no cliff schedule.
  Future<String> create3YearNoCliffSchedule() async {
    return createVestingSchedule(
      name: '3 Year / Monthly',
      type: 'time_based',
      totalMonths: 36,
      cliffMonths: 0,
      frequency: 'monthly',
    );
  }

  /// Delete a vesting schedule.
  Future<void> deleteVestingSchedule({
    required String scheduleId,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = VestingScheduleDeleted(
      companyId: companyId,
      scheduleId: scheduleId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Valuation Commands
// ============================================================

@riverpod
class ValuationCommands extends _$ValuationCommands {
  @override
  FutureOr<void> build() {}

  /// Record a valuation.
  Future<String> recordValuation({
    required DateTime date,
    required double preMoneyValue,
    required String method,
    String? methodParamsJson,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = ValuationRecorded(
      companyId: companyId,
      valuationId: id,
      date: date,
      preMoneyValue: preMoneyValue,
      method: method,
      methodParamsJson: methodParamsJson,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }
}

// ============================================================
// Transfer Commands
// ============================================================

@riverpod
class TransferCommands extends _$TransferCommands {
  @override
  FutureOr<void> build() {}

  /// Create/initiate a share transfer.
  Future<String> createTransfer({
    required String sellerStakeholderId,
    required String buyerStakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    required DateTime transactionDate,
    required String transferType,
    double? fairMarketValue,
    bool requiresRofr = false,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    final event = TransferInitiated(
      companyId: companyId,
      transferId: id,
      sellerStakeholderId: sellerStakeholderId,
      buyerStakeholderId: buyerStakeholderId,
      shareClassId: shareClassId,
      shareCount: shareCount,
      pricePerShare: pricePerShare,
      fairMarketValue: fairMarketValue,
      transactionDate: transactionDate,
      transferType: transferType,
      requiresRofr: requiresRofr,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return id;
  }

  /// Waive ROFR for a pending transfer.
  Future<void> waiveRofr({
    required String transferId,
    String? waivedBy,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = TransferRofrWaived(
      companyId: companyId,
      transferId: transferId,
      waivedBy: waivedBy,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Execute a pending transfer (shares actually move).
  Future<void> executeTransfer({
    required String transferId,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final resultingHoldingId = _uuid.v4();

    final event = TransferExecuted(
      companyId: companyId,
      transferId: transferId,
      resultingHoldingId: resultingHoldingId,
      executionDate: DateTime.now(),
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Cancel a pending transfer.
  Future<void> cancelTransfer({
    required String transferId,
    String? reason,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = TransferCancelled(
      companyId: companyId,
      transferId: transferId,
      reason: reason,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// MFN Upgrade Commands
// ============================================================

@riverpod
class MfnCommands extends _$MfnCommands {
  @override
  FutureOr<void> build() {}

  /// Apply an MFN upgrade.
  Future<String> applyUpgrade({
    required String targetConvertibleId,
    required String sourceConvertibleId,
    double? previousDiscountPercent,
    double? previousValuationCap,
    bool previousHasProRata = false,
    double? newDiscountPercent,
    double? newValuationCap,
    bool newHasProRata = false,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final upgradeId = _uuid.v4();

    final event = MfnUpgradeApplied(
      companyId: companyId,
      upgradeId: upgradeId,
      targetConvertibleId: targetConvertibleId,
      sourceConvertibleId: sourceConvertibleId,
      previousDiscountPercent: previousDiscountPercent,
      previousValuationCap: previousValuationCap,
      previousHasProRata: previousHasProRata,
      newDiscountPercent: newDiscountPercent,
      newValuationCap: newValuationCap,
      newHasProRata: newHasProRata,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return upgradeId;
  }

  /// Revert an MFN upgrade.
  Future<void> revertUpgrade({
    required String upgradeId,
    required String targetConvertibleId,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = MfnUpgradeReverted(
      companyId: companyId,
      upgradeId: upgradeId,
      targetConvertibleId: targetConvertibleId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}

// ============================================================
// Scenario Commands
// ============================================================

@riverpod
class ScenarioCommands extends _$ScenarioCommands {
  @override
  FutureOr<void> build() {}

  /// Save a scenario.
  Future<String> saveScenario({
    required String name,
    required String type,
    required String parametersJson,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final scenarioId = _uuid.v4();

    final event = ScenarioSaved(
      companyId: companyId,
      scenarioId: scenarioId,
      name: name,
      scenarioType: type,
      parametersJson: parametersJson,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
    return scenarioId;
  }

  /// Delete a scenario.
  Future<void> deleteScenario({
    required String scenarioId,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = ScenarioDeleted(
      companyId: companyId,
      scenarioId: scenarioId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }
}
