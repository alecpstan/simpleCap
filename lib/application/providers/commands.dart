import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/events/cap_table_event.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'esop_pools_provider.dart';
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

  /// Initialize default share classes and vesting schedules for a new company.
  ///
  /// This creates common share classes (Ordinary, ESOP, Preference A) and
  /// vesting schedules (4yr/1yr cliff, Immediate, 2yr/6mo cliff) that are
  /// useful for most startup scenarios.
  Future<void> initializeCompanyDefaults({required String companyId}) async {
    final now = DateTime.now();

    // Create default share classes
    final shareClassEvents = <CapTableEvent>[
      // Ordinary Shares - Standard voting shares for founders/employees
      ShareClassCreated(
        companyId: companyId,
        shareClassId: _uuid.v4(),
        name: 'Ordinary Shares',
        shareClassType: 'ordinary',
        votingMultiplier: 1.0,
        liquidationPreference: 1.0,
        isParticipating: false,
        dividendRate: 0.0,
        seniority: 0,
        antiDilutionType: 'none',
        notes: 'Standard voting shares for founders and employees',
        timestamp: now,
      ),
      // ESOP Pool - For employee stock options
      ShareClassCreated(
        companyId: companyId,
        shareClassId: _uuid.v4(),
        name: 'ESOP Pool',
        shareClassType: 'esop',
        votingMultiplier: 1.0,
        liquidationPreference: 1.0,
        isParticipating: false,
        dividendRate: 0.0,
        seniority: 0,
        antiDilutionType: 'none',
        notes: 'Employee Stock Option Pool for option grants',
        timestamp: now,
      ),
      // Preference A - First preference round for early investors
      ShareClassCreated(
        companyId: companyId,
        shareClassId: _uuid.v4(),
        name: 'Preference A',
        shareClassType: 'preferenceA',
        votingMultiplier: 1.0,
        liquidationPreference: 1.0,
        isParticipating: false,
        dividendRate: 0.0,
        seniority: 1,
        antiDilutionType: 'broadBased',
        notes: 'First preference round shares (Seed/Series A)',
        timestamp: now,
      ),
    ];

    // Create default vesting schedules
    final vestingEvents = <CapTableEvent>[
      // Standard 4 Year / 1 Year Cliff
      VestingScheduleCreated(
        companyId: companyId,
        scheduleId: _uuid.v4(),
        name: '4 Year / 1 Year Cliff',
        scheduleType: 'timeBased',
        totalMonths: 48,
        cliffMonths: 12,
        frequency: 'monthly',
        notes: 'Standard employee vesting schedule',
        timestamp: now,
      ),
      // Immediate Vesting
      VestingScheduleCreated(
        companyId: companyId,
        scheduleId: _uuid.v4(),
        name: 'Immediate',
        scheduleType: 'immediate',
        totalMonths: 0,
        cliffMonths: 0,
        notes: 'Immediate vesting for advisors or one-time grants',
        timestamp: now,
      ),
      // 2 Year / 6 Month Cliff (accelerated)
      VestingScheduleCreated(
        companyId: companyId,
        scheduleId: _uuid.v4(),
        name: '2 Year / 6 Month Cliff',
        scheduleType: 'timeBased',
        totalMonths: 24,
        cliffMonths: 6,
        frequency: 'monthly',
        notes: 'Accelerated vesting for contractors or consultants',
        timestamp: now,
      ),
    ];

    // Append all events
    await ref.read(eventLedgerProvider.notifier).appendForCompany(companyId, [
      ...shareClassEvents,
      ...vestingEvents,
    ]);
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

  /// Remove a stakeholder (soft delete - creates StakeholderRemoved event).
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

  /// Permanently delete a stakeholder and all related entities.
  /// This cascade deletes: holdings, options, warrants, convertibles.
  Future<List<String>> deleteStakeholder({
    required String stakeholderId,
  }) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(
          entityId: stakeholderId,
          entityType: EntityType.stakeholder,
        );
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

  /// Permanently delete a share class and cascade delete related holdings.
  Future<List<String>> deleteShareClass({required String shareClassId}) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(
          entityId: shareClassId,
          entityType: EntityType.shareClass,
        );
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

    final events = <CapTableEvent>[];

    // Create the round opened event
    final roundEvent = RoundOpened(
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
    events.add(roundEvent);

    // If pre-money valuation is provided, also create a valuation event
    if (preMoneyValuation != null && preMoneyValuation > 0) {
      final valuationEvent = ValuationRecorded(
        companyId: companyId,
        valuationId: _uuid.v4(),
        date: date,
        preMoneyValue: preMoneyValuation,
        method: 'round',
        methodParamsJson: '{"roundId": "$id", "roundName": "$name"}',
        notes: 'Pre-money valuation from $name round',
        timestamp: now,
        actorId: actorId,
      );
      events.add(valuationEvent);
    }

    await ref.read(eventLedgerProvider.notifier).append(events);
    return id;
  }

  /// Close a round with final terms.
  ///
  /// This also creates a post-money ValuationRecorded event if the round
  /// has a pre-money valuation set.
  Future<void> closeRound({
    required String roundId,
    required double amountRaised,
    String? roundName,
    double? preMoneyValuation,
    DateTime? roundDate,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final now = DateTime.now();
    final events = <CapTableEvent>[];

    // Create the round closed event
    final closeEvent = RoundClosed(
      companyId: companyId,
      roundId: roundId,
      amountRaised: amountRaised,
      timestamp: now,
      actorId: actorId,
    );
    events.add(closeEvent);

    // If pre-money valuation is provided, create a post-money valuation event
    if (preMoneyValuation != null && preMoneyValuation > 0) {
      final postMoneyValue = preMoneyValuation + amountRaised;
      final valuationEvent = ValuationRecorded(
        companyId: companyId,
        valuationId: _uuid.v4(),
        date: roundDate ?? now,
        preMoneyValue: postMoneyValue,
        method: 'round_post_money',
        methodParamsJson: '{"roundId": "$roundId", "roundName": "$roundName", "isPostMoney": true}',
        notes: 'Post-money valuation from ${roundName ?? 'round'} (\$${preMoneyValuation.toStringAsFixed(0)} pre-money + \$${amountRaised.toStringAsFixed(0)} raised)',
        timestamp: now,
        actorId: actorId,
      );
      events.add(valuationEvent);
    }

    // Auto-activate ESOP pools tied to this round
    final pools = await ref.read(esopPoolsStreamProvider.future);
    for (final pool in pools) {
      if (pool.roundId == roundId && pool.status == 'draft') {
        events.add(EsopPoolActivated(
          companyId: companyId,
          poolId: pool.id,
          timestamp: now,
          actorId: actorId,
        ));
      }
    }

    await ref.read(eventLedgerProvider.notifier).append(events);
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

    final now = DateTime.now();
    final events = <CapTableEvent>[];

    final amendEvent = RoundAmended(
      companyId: companyId,
      roundId: roundId,
      name: name,
      roundType: type,
      date: date,
      preMoneyValuation: preMoneyValuation,
      pricePerShare: pricePerShare,
      leadInvestorId: leadInvestorId,
      notes: notes,
      timestamp: now,
      actorId: actorId,
    );
    events.add(amendEvent);

    // If pre-money valuation is being updated, also create a valuation event
    if (preMoneyValuation != null && preMoneyValuation > 0) {
      final valuationEvent = ValuationRecorded(
        companyId: companyId,
        valuationId: _uuid.v4(),
        date: date ?? now,
        preMoneyValue: preMoneyValuation,
        method: 'round',
        methodParamsJson: '{"roundId": "$roundId", "amended": true}',
        notes:
            'Updated pre-money valuation${name != null ? ' from $name round' : ''}',
        timestamp: now,
        actorId: actorId,
      );
      events.add(valuationEvent);
    }

    await ref.read(eventLedgerProvider.notifier).append(events);
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

  /// Delete a round (soft delete - creates RoundDeleted event).
  Future<void> softDeleteRound({
    required String roundId,
    String? actorId,
  }) async {
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

  /// Permanently delete a round and cascade delete related entities.
  /// Only entities CREATED in this round are deleted (not exercised in it).
  Future<List<String>> deleteRound({required String roundId}) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(entityId: roundId, entityType: EntityType.round);
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

  /// Delete a holding permanently.
  /// Holdings don't have a soft delete - they are either transferred or deleted.
  Future<List<String>> deleteHolding({required String holdingId}) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(
          entityId: holdingId,
          entityType: EntityType.holding,
        );
  }

  /// Update an existing holding.
  Future<void> updateHolding({
    required String holdingId,
    int? shareCount,
    double? costBasis,
    DateTime? acquiredDate,
    String? shareClassId,
    String? vestingScheduleId,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = HoldingUpdated(
      companyId: companyId,
      holdingId: holdingId,
      shareCount: shareCount,
      costBasis: costBasis,
      acquiredDate: acquiredDate,
      shareClassId: shareClassId,
      vestingScheduleId: vestingScheduleId,
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
    // Advanced terms
    String? maturityBehavior,
    bool allowsVoluntaryConversion = false,
    String? liquidityEventBehavior,
    double? liquidityPayoutMultiple,
    String? dissolutionBehavior,
    String? preferredShareClassId,
    double? qualifiedFinancingThreshold,
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
      maturityBehavior: maturityBehavior,
      allowsVoluntaryConversion: allowsVoluntaryConversion,
      liquidityEventBehavior: liquidityEventBehavior,
      liquidityPayoutMultiple: liquidityPayoutMultiple,
      dissolutionBehavior: dissolutionBehavior,
      preferredShareClassId: preferredShareClassId,
      qualifiedFinancingThreshold: qualifiedFinancingThreshold,
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
    String? roundId, // Optional for voluntary conversions
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

  /// Cancel a convertible (soft cancel - creates ConvertibleCancelled event).
  /// This marks the convertible as cancelled but keeps the history.
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

  /// Permanently delete a convertible and cascade delete related entities.
  /// This removes all events and any warrants issued from this convertible.
  Future<List<String>> deleteConvertible({
    required String convertibleId,
  }) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(
          entityId: convertibleId,
          entityType: EntityType.convertible,
        );
  }

  /// Update an existing convertible's properties.
  /// Only non-null fields will be updated.
  Future<void> updateConvertible({
    required String convertibleId,
    double? principal,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? issueDate,
    DateTime? maturityDate,
    bool? hasMfn,
    bool? hasProRata,
    String? roundId,
    String? notes,
    // Advanced terms
    String? maturityBehavior,
    bool? allowsVoluntaryConversion,
    String? liquidityEventBehavior,
    double? liquidityPayoutMultiple,
    String? dissolutionBehavior,
    String? preferredShareClassId,
    double? qualifiedFinancingThreshold,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = ConvertibleUpdated(
      companyId: companyId,
      convertibleId: convertibleId,
      principal: principal,
      valuationCap: valuationCap,
      discountPercent: discountPercent,
      interestRate: interestRate,
      issueDate: issueDate,
      maturityDate: maturityDate,
      hasMfn: hasMfn,
      hasProRata: hasProRata,
      roundId: roundId,
      notes: notes,
      maturityBehavior: maturityBehavior,
      allowsVoluntaryConversion: allowsVoluntaryConversion,
      liquidityEventBehavior: liquidityEventBehavior,
      liquidityPayoutMultiple: liquidityPayoutMultiple,
      dissolutionBehavior: dissolutionBehavior,
      preferredShareClassId: preferredShareClassId,
      qualifiedFinancingThreshold: qualifiedFinancingThreshold,
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

  /// Update an ESOP pool's settings.
  Future<void> updatePool({
    required String poolId,
    String? name,
    double? targetPercentage,
    String? defaultVestingScheduleId,
    String? strikePriceMethod,
    double? defaultStrikePrice,
    int? defaultExpiryYears,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = EsopPoolUpdated(
      companyId: companyId,
      poolId: poolId,
      name: name,
      targetPercentage: targetPercentage,
      defaultVestingScheduleId: defaultVestingScheduleId,
      strikePriceMethod: strikePriceMethod,
      defaultStrikePrice: defaultStrikePrice,
      defaultExpiryYears: defaultExpiryYears,
      notes: notes,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Activate a draft ESOP pool (changes status from draft to active).
  /// Typically called when a round closes that created this pool.
  Future<void> activatePool({required String poolId, String? actorId}) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = EsopPoolActivated(
      companyId: companyId,
      poolId: poolId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Soft delete an ESOP pool (creates EsopPoolDeleted event).
  /// This marks the pool as deleted but keeps the history.
  Future<void> softDeletePool({required String poolId, String? actorId}) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = EsopPoolDeleted(
      companyId: companyId,
      poolId: poolId,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Permanently delete an ESOP pool and cascade delete all grants.
  /// This removes all events including any option grants from this pool
  /// and any holdings from exercised options.
  Future<List<String>> deletePool({required String poolId}) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(entityId: poolId, entityType: EntityType.esopPool);
  }

  /// Revert an ESOP pool expansion.
  Future<void> revertExpansion({
    required String expansionId,
    required String poolId,
    required int previousSize,
    required int sharesRemoved,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = EsopPoolExpansionReverted(
      companyId: companyId,
      expansionId: expansionId,
      poolId: poolId,
      previousSize: previousSize,
      revertedSize: previousSize - sharesRemoved,
      sharesRemoved: sharesRemoved,
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
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
  ///
  /// Supports different exercise types:
  /// - Cash: Pay strike price in cash, receive all shares
  /// - Cashless: Shares sold at FMV to cover costs, receive cash proceeds
  /// - Net: Shares withheld to cover strike price, receive net shares
  /// - NetWithTax: Shares withheld for strike + taxes, receive net shares
  Future<void> exerciseOptions({
    required String grantId,
    required int exercisedCount,
    required double exercisePrice,
    required DateTime exerciseDate,
    String exerciseType = 'cash',
    int? sharesWithheldForStrike,
    int? sharesWithheldForTax,
    int? netSharesReceived,
    double? fairMarketValue,
    double? proceedsReceived,
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
      exerciseType: exerciseType,
      sharesWithheldForStrike: sharesWithheldForStrike,
      sharesWithheldForTax: sharesWithheldForTax,
      netSharesReceived: netSharesReceived,
      fairMarketValue: fairMarketValue,
      proceedsReceived: proceedsReceived,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Cancel options (soft cancel - creates OptionsCancelled event).
  /// This records a cancellation event but keeps the grant history.
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

  /// Update an existing option grant.
  Future<void> updateOptionGrant({
    required String grantId,
    String? shareClassId,
    String? esopPoolId,
    int? quantity,
    double? strikePrice,
    DateTime? grantDate,
    DateTime? expiryDate,
    String? vestingScheduleId,
    String? roundId,
    bool? allowsEarlyExercise,
    String? notes,
    String? actorId,
  }) async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      throw StateError('No company selected');
    }

    final event = OptionGrantUpdated(
      companyId: companyId,
      grantId: grantId,
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
      timestamp: DateTime.now(),
      actorId: actorId,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Permanently delete an option grant and cascade delete related holdings.
  /// This removes all events including any holdings from exercising this option.
  Future<List<String>> deleteOptionGrant({required String grantId}) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(
          entityId: grantId,
          entityType: EntityType.optionGrant,
        );
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
  ///
  /// Supports different exercise types:
  /// - Cash: Pay strike price in cash, receive all shares
  /// - Cashless: Shares sold at FMV to cover costs, receive cash proceeds
  /// - Net: Shares withheld to cover strike price, receive net shares
  /// - NetWithTax: Shares withheld for strike + taxes, receive net shares
  Future<void> exerciseWarrants({
    required String warrantId,
    required int exercisedCount,
    required double exercisePrice,
    required DateTime exerciseDate,
    String exerciseType = 'cash',
    int? sharesWithheldForStrike,
    int? sharesWithheldForTax,
    int? netSharesReceived,
    double? fairMarketValue,
    double? proceedsReceived,
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
      exerciseType: exerciseType,
      sharesWithheldForStrike: sharesWithheldForStrike,
      sharesWithheldForTax: sharesWithheldForTax,
      netSharesReceived: netSharesReceived,
      fairMarketValue: fairMarketValue,
      proceedsReceived: proceedsReceived,
    );

    await ref.read(eventLedgerProvider.notifier).append([event]);
  }

  /// Cancel warrants (soft cancel - creates WarrantCancelled event).
  /// This records a cancellation event but keeps the warrant history.
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

  /// Permanently delete a warrant and cascade delete related holdings.
  /// This removes all events including any holdings from exercising this warrant.
  Future<List<String>> deleteWarrant({required String warrantId}) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(
          entityId: warrantId,
          entityType: EntityType.warrant,
        );
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

  /// Soft delete a vesting schedule (creates VestingScheduleDeleted event).
  Future<void> softDeleteVestingSchedule({
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

  /// Permanently delete a vesting schedule.
  Future<List<String>> deleteVestingSchedule({
    required String scheduleId,
  }) async {
    return ref
        .read(eventLedgerProvider.notifier)
        .cascadeDeleteEntity(
          entityId: scheduleId,
          entityType: EntityType.vestingSchedule,
        );
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

  /// Permanently delete a valuation.
  /// Valuations are leaf entities, so use permanentDeleteEntity.
  Future<void> deleteValuation({required String valuationId}) async {
    await ref
        .read(eventLedgerProvider.notifier)
        .permanentDeleteEntity(valuationId);
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

  /// Cancel a pending transfer (soft cancel - creates TransferCancelled event).
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

  /// Permanently delete a transfer.
  Future<void> deleteTransfer({required String transferId}) async {
    await ref
        .read(eventLedgerProvider.notifier)
        .permanentDeleteEntity(transferId);
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

  /// Soft delete a scenario (creates ScenarioDeleted event).
  Future<void> softDeleteScenario({
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

  /// Permanently delete a scenario.
  Future<void> deleteScenario({required String scenarioId}) async {
    await ref
        .read(eventLedgerProvider.notifier)
        .permanentDeleteEntity(scenarioId);
  }
}
