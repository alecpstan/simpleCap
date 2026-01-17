import 'package:freezed_annotation/freezed_annotation.dart';

import '../events/cap_table_event.dart';

part 'cap_table_state.freezed.dart';
part 'cap_table_state.g.dart';

/// The complete projected state of a cap table.
///
/// This is computed by folding over all events for a company.
/// It contains all the materialized views needed by the UI.
@freezed
class CapTableState with _$CapTableState {
  const CapTableState._();

  const factory CapTableState({
    required String companyId,
    required String companyName,
    required DateTime companyCreatedAt,
    @Default({}) Map<String, StakeholderState> stakeholders,
    @Default({}) Map<String, ShareClassState> shareClasses,
    @Default({}) Map<String, RoundState> rounds,
    @Default({}) Map<String, HoldingState> holdings,
    @Default({}) Map<String, ConvertibleState> convertibles,
    @Default({}) Map<String, EsopPoolState> esopPools,
    @Default({}) Map<String, OptionGrantState> optionGrants,
    @Default({}) Map<String, WarrantState> warrants,
    @Default({}) Map<String, VestingScheduleState> vestingSchedules,
    @Default({}) Map<String, ValuationState> valuations,
    @Default({}) Map<String, TransferState> transfers,
    @Default({}) Map<String, ScenarioState> scenarios,
    @Default(0) int lastSequenceNumber,
  }) = _CapTableState;

  /// Create initial state from a CompanyCreated event.
  factory CapTableState.initial(CompanyCreated event) {
    return CapTableState(
      companyId: event.companyId,
      companyName: event.name,
      companyCreatedAt: event.timestamp,
    );
  }

  /// Build state from a list of events.
  static CapTableState fromEvents(List<CapTableEvent> events) {
    if (events.isEmpty) {
      throw ArgumentError('Cannot create state from empty events list');
    }

    final firstEvent = events.first;
    if (firstEvent is! CompanyCreated) {
      throw ArgumentError('First event must be CompanyCreated');
    }

    var state = CapTableState.initial(firstEvent);
    for (var i = 1; i < events.length; i++) {
      state = state.apply(events[i], sequenceNumber: i);
    }
    return state;
  }

  /// Apply a single event to produce new state.
  CapTableState apply(CapTableEvent event, {int? sequenceNumber}) {
    final newSequence = sequenceNumber ?? lastSequenceNumber + 1;

    return event.map(
      // Company
      companyCreated: (_) => this, // Already handled in initial
      companyRenamed: (e) =>
          copyWith(companyName: e.newName, lastSequenceNumber: newSequence),

      // Stakeholders
      stakeholderAdded: (e) => _addStakeholder(e, newSequence),
      stakeholderUpdated: (e) => _updateStakeholder(e, newSequence),
      stakeholderRemoved: (e) => _removeStakeholder(e, newSequence),

      // Share Classes
      shareClassCreated: (e) => _addShareClass(e, newSequence),
      shareClassUpdated: (e) => _updateShareClass(e, newSequence),

      // Rounds
      roundOpened: (e) => _addRound(e, newSequence),
      roundClosed: (e) => _closeRound(e, newSequence),
      roundAmended: (e) => _amendRound(e, newSequence),
      roundReopened: (e) => _reopenRound(e, newSequence),
      roundDeleted: (e) => _deleteRound(e, newSequence),

      // Holdings
      sharesIssued: (e) => _issueShares(e, newSequence),
      sharesTransferred: (e) => _transferShares(e, newSequence),
      sharesRepurchased: (e) => _repurchaseShares(e, newSequence),
      holdingVestingUpdated: (e) => _updateHoldingVesting(e, newSequence),

      // Convertibles
      convertibleIssued: (e) => _issueConvertible(e, newSequence),
      mfnUpgradeApplied: (e) => _applyMfnUpgrade(e, newSequence),
      convertibleConverted: (e) => _convertConvertible(e, newSequence),
      convertibleCancelled: (e) => _cancelConvertible(e, newSequence),

      // ESOP Pools
      esopPoolCreated: (e) => _createEsopPool(e, newSequence),
      esopPoolExpanded: (e) => _expandEsopPool(e, newSequence),
      esopPoolActivated: (e) => _activateEsopPool(e, newSequence),

      // Option Grants
      optionGranted: (e) => _grantOptions(e, newSequence),
      optionsVested: (e) => _vestOptions(e, newSequence),
      optionsExercised: (e) => _exerciseOptions(e, newSequence),
      optionsCancelled: (e) => _cancelOptions(e, newSequence),
      optionGrantStatusChanged: (e) => _changeOptionStatus(e, newSequence),

      // Warrants
      warrantIssued: (e) => _issueWarrant(e, newSequence),
      warrantExercised: (e) => _exerciseWarrant(e, newSequence),
      warrantCancelled: (e) => _cancelWarrant(e, newSequence),
      warrantUpdated: (e) => _updateWarrant(e, newSequence),
      warrantUnexercised: (e) => _unexerciseWarrant(e, newSequence),
      warrantStatusChanged: (e) => _changeWarrantStatus(e, newSequence),

      // Vesting Schedules
      vestingScheduleCreated: (e) => _createVestingSchedule(e, newSequence),
      vestingScheduleUpdated: (e) => _updateVestingSchedule(e, newSequence),
      vestingScheduleDeleted: (e) => _deleteVestingSchedule(e, newSequence),

      // Valuations
      valuationRecorded: (e) => _recordValuation(e, newSequence),
      valuationDeleted: (e) => _deleteValuation(e, newSequence),

      // Transfer Workflow
      transferInitiated: (e) => _initiateTransfer(e, newSequence),
      transferRofrWaived: (e) => _waiveTransferRofr(e, newSequence),
      transferExecuted: (e) => _executeTransfer(e, newSequence),
      transferCancelled: (e) => _cancelTransfer(e, newSequence),

      // MFN Upgrades
      mfnUpgradeReverted: (e) => _revertMfnUpgrade(e, newSequence),

      // Scenarios
      scenarioSaved: (e) => _saveScenario(e, newSequence),
      scenarioDeleted: (e) => _deleteScenario(e, newSequence),
    );
  }

  // ============================================================
  // Stakeholder Reducers
  // ============================================================

  CapTableState _addStakeholder(StakeholderAdded e, int seq) {
    final stakeholder = StakeholderState(
      id: e.stakeholderId,
      name: e.name,
      type: e.stakeholderType,
      email: e.email,
      phone: e.phone,
      company: e.company,
      hasProRataRights: e.hasProRataRights,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      stakeholders: {...stakeholders, e.stakeholderId: stakeholder},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _updateStakeholder(StakeholderUpdated e, int seq) {
    final existing = stakeholders[e.stakeholderId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      name: e.name ?? existing.name,
      type: e.stakeholderType ?? existing.type,
      email: e.email ?? existing.email,
      phone: e.phone ?? existing.phone,
      company: e.company ?? existing.company,
      hasProRataRights: e.hasProRataRights ?? existing.hasProRataRights,
      notes: e.notes ?? existing.notes,
      updatedAt: e.timestamp,
    );
    return copyWith(
      stakeholders: {...stakeholders, e.stakeholderId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _removeStakeholder(StakeholderRemoved e, int seq) {
    final newStakeholders = Map<String, StakeholderState>.from(stakeholders)
      ..remove(e.stakeholderId);
    return copyWith(stakeholders: newStakeholders, lastSequenceNumber: seq);
  }

  // ============================================================
  // Share Class Reducers
  // ============================================================

  CapTableState _addShareClass(ShareClassCreated e, int seq) {
    final shareClass = ShareClassState(
      id: e.shareClassId,
      name: e.name,
      type: e.shareClassType,
      votingMultiplier: e.votingMultiplier,
      liquidationPreference: e.liquidationPreference,
      isParticipating: e.isParticipating,
      dividendRate: e.dividendRate,
      seniority: e.seniority,
      antiDilutionType: e.antiDilutionType,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      shareClasses: {...shareClasses, e.shareClassId: shareClass},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _updateShareClass(ShareClassUpdated e, int seq) {
    final existing = shareClasses[e.shareClassId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      name: e.name ?? existing.name,
      type: e.shareClassType ?? existing.type,
      votingMultiplier: e.votingMultiplier ?? existing.votingMultiplier,
      liquidationPreference:
          e.liquidationPreference ?? existing.liquidationPreference,
      isParticipating: e.isParticipating ?? existing.isParticipating,
      dividendRate: e.dividendRate ?? existing.dividendRate,
      seniority: e.seniority ?? existing.seniority,
      antiDilutionType: e.antiDilutionType ?? existing.antiDilutionType,
      notes: e.notes ?? existing.notes,
      updatedAt: e.timestamp,
    );
    return copyWith(
      shareClasses: {...shareClasses, e.shareClassId: updated},
      lastSequenceNumber: seq,
    );
  }

  // ============================================================
  // Round Reducers
  // ============================================================

  CapTableState _addRound(RoundOpened e, int seq) {
    final round = RoundState(
      id: e.roundId,
      name: e.name,
      type: e.roundType,
      status: 'draft',
      date: e.date,
      preMoneyValuation: e.preMoneyValuation,
      pricePerShare: e.pricePerShare,
      amountRaised: 0,
      leadInvestorId: e.leadInvestorId,
      displayOrder: e.displayOrder,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      rounds: {...rounds, e.roundId: round},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _closeRound(RoundClosed e, int seq) {
    final existing = rounds[e.roundId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      status: 'closed',
      amountRaised: e.amountRaised,
      updatedAt: e.timestamp,
    );
    return copyWith(
      rounds: {...rounds, e.roundId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _amendRound(RoundAmended e, int seq) {
    final existing = rounds[e.roundId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      name: e.name ?? existing.name,
      type: e.roundType ?? existing.type,
      date: e.date ?? existing.date,
      preMoneyValuation: e.preMoneyValuation ?? existing.preMoneyValuation,
      pricePerShare: e.pricePerShare ?? existing.pricePerShare,
      leadInvestorId: e.leadInvestorId ?? existing.leadInvestorId,
      notes: e.notes ?? existing.notes,
      updatedAt: e.timestamp,
    );
    return copyWith(
      rounds: {...rounds, e.roundId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _reopenRound(RoundReopened e, int seq) {
    final existing = rounds[e.roundId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(status: 'draft', updatedAt: e.timestamp);
    return copyWith(
      rounds: {...rounds, e.roundId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _deleteRound(RoundDeleted e, int seq) {
    final newRounds = Map<String, RoundState>.from(rounds)..remove(e.roundId);
    return copyWith(rounds: newRounds, lastSequenceNumber: seq);
  }

  // ============================================================
  // Holding Reducers
  // ============================================================

  CapTableState _issueShares(SharesIssued e, int seq) {
    final holding = HoldingState(
      id: e.holdingId,
      stakeholderId: e.stakeholderId,
      shareClassId: e.shareClassId,
      shareCount: e.shareCount,
      costBasis: e.costBasis,
      acquiredDate: e.acquiredDate,
      roundId: e.roundId,
      vestingScheduleId: e.vestingScheduleId,
      vestedCount: null,
      sourceOptionGrantId: e.sourceOptionGrantId,
      sourceWarrantId: e.sourceWarrantId,
      updatedAt: e.timestamp,
    );
    return copyWith(
      holdings: {...holdings, e.holdingId: holding},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _transferShares(SharesTransferred e, int seq) {
    final transfer = TransferState(
      id: e.transferId,
      sellerStakeholderId: e.sellerStakeholderId,
      buyerStakeholderId: e.buyerStakeholderId,
      shareClassId: e.shareClassId,
      shareCount: e.shareCount,
      pricePerShare: e.pricePerShare,
      fairMarketValue: e.fairMarketValue,
      transactionDate: e.transactionDate,
      type: e.transferType,
      status: 'completed',
      sourceHoldingId: e.sourceHoldingId,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      transfers: {...transfers, e.transferId: transfer},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _repurchaseShares(SharesRepurchased e, int seq) {
    // Reduce shares from holding or remove if fully repurchased
    final existing = e.holdingId != null ? holdings[e.holdingId] : null;
    if (existing != null) {
      final newCount = existing.shareCount - e.shareCount;
      if (newCount <= 0) {
        final newHoldings = Map<String, HoldingState>.from(holdings)
          ..remove(e.holdingId);
        return copyWith(holdings: newHoldings, lastSequenceNumber: seq);
      } else {
        final updated = existing.copyWith(
          shareCount: newCount,
          updatedAt: e.timestamp,
        );
        return copyWith(
          holdings: {...holdings, e.holdingId!: updated},
          lastSequenceNumber: seq,
        );
      }
    }
    return copyWith(lastSequenceNumber: seq);
  }

  CapTableState _updateHoldingVesting(HoldingVestingUpdated e, int seq) {
    final existing = holdings[e.holdingId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      vestedCount: e.vestedCount,
      updatedAt: e.timestamp,
    );
    return copyWith(
      holdings: {...holdings, e.holdingId: updated},
      lastSequenceNumber: seq,
    );
  }

  // ============================================================
  // Convertible Reducers
  // ============================================================

  CapTableState _issueConvertible(ConvertibleIssued e, int seq) {
    final convertible = ConvertibleState(
      id: e.convertibleId,
      stakeholderId: e.stakeholderId,
      type: e.convertibleType,
      status: 'outstanding',
      principal: e.principal,
      valuationCap: e.valuationCap,
      discountPercent: e.discountPercent,
      interestRate: e.interestRate,
      maturityDate: e.maturityDate,
      issueDate: e.issueDate,
      hasMfn: e.hasMfn,
      hasProRata: e.hasProRata,
      roundId: e.roundId,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      convertibles: {...convertibles, e.convertibleId: convertible},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _applyMfnUpgrade(MfnUpgradeApplied e, int seq) {
    final existing = convertibles[e.targetConvertibleId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      valuationCap: e.newValuationCap ?? existing.valuationCap,
      discountPercent: e.newDiscountPercent ?? existing.discountPercent,
      hasProRata: e.newHasProRata,
      updatedAt: e.timestamp,
    );
    return copyWith(
      convertibles: {...convertibles, e.targetConvertibleId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _convertConvertible(ConvertibleConverted e, int seq) {
    final existing = convertibles[e.convertibleId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      status: 'converted',
      conversionRoundId: e.roundId,
      convertedToShareClassId: e.toShareClassId,
      sharesReceived: e.sharesReceived,
      updatedAt: e.timestamp,
    );
    return copyWith(
      convertibles: {...convertibles, e.convertibleId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _cancelConvertible(ConvertibleCancelled e, int seq) {
    final existing = convertibles[e.convertibleId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      status: 'cancelled',
      updatedAt: e.timestamp,
    );
    return copyWith(
      convertibles: {...convertibles, e.convertibleId: updated},
      lastSequenceNumber: seq,
    );
  }

  // ============================================================
  // ESOP Pool Reducers
  // ============================================================

  CapTableState _createEsopPool(EsopPoolCreated e, int seq) {
    final pool = EsopPoolState(
      id: e.poolId,
      name: e.name,
      shareClassId: e.shareClassId,
      status: 'draft',
      poolSize: e.poolSize,
      targetPercentage: e.targetPercentage,
      establishedDate: e.establishedDate,
      resolutionReference: e.resolutionReference,
      roundId: e.roundId,
      defaultVestingScheduleId: e.defaultVestingScheduleId,
      strikePriceMethod: e.strikePriceMethod,
      defaultStrikePrice: e.defaultStrikePrice,
      defaultExpiryYears: e.defaultExpiryYears,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      esopPools: {...esopPools, e.poolId: pool},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _expandEsopPool(EsopPoolExpanded e, int seq) {
    final existing = esopPools[e.poolId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      poolSize: e.newSize,
      updatedAt: e.timestamp,
    );
    return copyWith(
      esopPools: {...esopPools, e.poolId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _activateEsopPool(EsopPoolActivated e, int seq) {
    final existing = esopPools[e.poolId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(status: 'active', updatedAt: e.timestamp);
    return copyWith(
      esopPools: {...esopPools, e.poolId: updated},
      lastSequenceNumber: seq,
    );
  }

  // ============================================================
  // Option Grant Reducers
  // ============================================================

  CapTableState _grantOptions(OptionGranted e, int seq) {
    final grant = OptionGrantState(
      id: e.grantId,
      stakeholderId: e.stakeholderId,
      shareClassId: e.shareClassId,
      esopPoolId: e.esopPoolId,
      status: 'pending',
      quantity: e.quantity,
      strikePrice: e.strikePrice,
      grantDate: e.grantDate,
      expiryDate: e.expiryDate,
      exercisedCount: 0,
      cancelledCount: 0,
      vestingScheduleId: e.vestingScheduleId,
      roundId: e.roundId,
      allowsEarlyExercise: e.allowsEarlyExercise,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      optionGrants: {...optionGrants, e.grantId: grant},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _vestOptions(OptionsVested e, int seq) {
    // Vesting is tracked via vestingScheduleId, this is just an event log
    return copyWith(lastSequenceNumber: seq);
  }

  CapTableState _exerciseOptions(OptionsExercised e, int seq) {
    final existing = optionGrants[e.grantId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      exercisedCount: existing.exercisedCount + e.exercisedCount,
      status: _computeOptionStatus(existing, e.exercisedCount, 0),
      updatedAt: e.timestamp,
    );
    return copyWith(
      optionGrants: {...optionGrants, e.grantId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _cancelOptions(OptionsCancelled e, int seq) {
    final existing = optionGrants[e.grantId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      cancelledCount: existing.cancelledCount + e.cancelledCount,
      status: _computeOptionStatus(existing, 0, e.cancelledCount),
      updatedAt: e.timestamp,
    );
    return copyWith(
      optionGrants: {...optionGrants, e.grantId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _changeOptionStatus(OptionGrantStatusChanged e, int seq) {
    final existing = optionGrants[e.grantId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      status: e.newStatus,
      updatedAt: e.timestamp,
    );
    return copyWith(
      optionGrants: {...optionGrants, e.grantId: updated},
      lastSequenceNumber: seq,
    );
  }

  String _computeOptionStatus(
    OptionGrantState grant,
    int additionalExercised,
    int additionalCancelled,
  ) {
    final totalExercised = grant.exercisedCount + additionalExercised;
    final totalCancelled = grant.cancelledCount + additionalCancelled;
    final remaining = grant.quantity - totalExercised - totalCancelled;

    if (remaining <= 0) {
      return totalExercised > 0 ? 'fullyExercised' : 'cancelled';
    } else if (totalExercised > 0) {
      return 'partiallyExercised';
    }
    return grant.status;
  }

  // ============================================================
  // Warrant Reducers
  // ============================================================

  CapTableState _issueWarrant(WarrantIssued e, int seq) {
    final warrant = WarrantState(
      id: e.warrantId,
      stakeholderId: e.stakeholderId,
      shareClassId: e.shareClassId,
      status: 'pending',
      quantity: e.quantity,
      strikePrice: e.strikePrice,
      issueDate: e.issueDate,
      expiryDate: e.expiryDate,
      exercisedCount: 0,
      cancelledCount: 0,
      sourceConvertibleId: e.sourceConvertibleId,
      roundId: e.roundId,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      warrants: {...warrants, e.warrantId: warrant},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _exerciseWarrant(WarrantExercised e, int seq) {
    final existing = warrants[e.warrantId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      exercisedCount: existing.exercisedCount + e.exercisedCount,
      updatedAt: e.timestamp,
    );
    return copyWith(
      warrants: {...warrants, e.warrantId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _cancelWarrant(WarrantCancelled e, int seq) {
    final existing = warrants[e.warrantId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      cancelledCount: existing.cancelledCount + e.cancelledCount,
      updatedAt: e.timestamp,
    );
    return copyWith(
      warrants: {...warrants, e.warrantId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _changeWarrantStatus(WarrantStatusChanged e, int seq) {
    final existing = warrants[e.warrantId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      status: e.newStatus,
      updatedAt: e.timestamp,
    );
    return copyWith(
      warrants: {...warrants, e.warrantId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _updateWarrant(WarrantUpdated e, int seq) {
    final existing = warrants[e.warrantId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      shareClassId: e.shareClassId ?? existing.shareClassId,
      quantity: e.quantity ?? existing.quantity,
      strikePrice: e.strikePrice ?? existing.strikePrice,
      issueDate: e.issueDate ?? existing.issueDate,
      expiryDate: e.expiryDate ?? existing.expiryDate,
      roundId: e.roundId ?? existing.roundId,
      notes: e.notes ?? existing.notes,
      updatedAt: e.timestamp,
    );
    return copyWith(
      warrants: {...warrants, e.warrantId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _unexerciseWarrant(WarrantUnexercised e, int seq) {
    final existing = warrants[e.warrantId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      exercisedCount: (existing.exercisedCount - e.unexercisedCount).clamp(
        0,
        existing.quantity,
      ),
      updatedAt: e.timestamp,
    );
    return copyWith(
      warrants: {...warrants, e.warrantId: updated},
      lastSequenceNumber: seq,
    );
  }

  // ============================================================
  // Vesting Schedule Reducers
  // ============================================================

  CapTableState _createVestingSchedule(VestingScheduleCreated e, int seq) {
    final schedule = VestingScheduleState(
      id: e.scheduleId,
      name: e.name,
      type: e.scheduleType,
      totalMonths: e.totalMonths,
      cliffMonths: e.cliffMonths,
      frequency: e.frequency,
      milestonesJson: e.milestonesJson,
      totalHours: e.totalHours,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      vestingSchedules: {...vestingSchedules, e.scheduleId: schedule},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _updateVestingSchedule(VestingScheduleUpdated e, int seq) {
    final existing = vestingSchedules[e.scheduleId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      name: e.name ?? existing.name,
      type: e.scheduleType ?? existing.type,
      totalMonths: e.totalMonths ?? existing.totalMonths,
      cliffMonths: e.cliffMonths ?? existing.cliffMonths,
      frequency: e.frequency ?? existing.frequency,
      milestonesJson: e.milestonesJson ?? existing.milestonesJson,
      totalHours: e.totalHours ?? existing.totalHours,
      notes: e.notes ?? existing.notes,
      updatedAt: e.timestamp,
    );
    return copyWith(
      vestingSchedules: {...vestingSchedules, e.scheduleId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _deleteVestingSchedule(VestingScheduleDeleted e, int seq) {
    final newSchedules = Map<String, VestingScheduleState>.from(
      vestingSchedules,
    )..remove(e.scheduleId);
    return copyWith(vestingSchedules: newSchedules, lastSequenceNumber: seq);
  }

  // ============================================================
  // Valuation Reducers
  // ============================================================

  CapTableState _recordValuation(ValuationRecorded e, int seq) {
    final valuation = ValuationState(
      id: e.valuationId,
      date: e.date,
      preMoneyValue: e.preMoneyValue,
      method: e.method,
      methodParamsJson: e.methodParamsJson,
      notes: e.notes,
      createdAt: e.timestamp,
    );
    return copyWith(
      valuations: {...valuations, e.valuationId: valuation},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _deleteValuation(ValuationDeleted e, int seq) {
    final newValuations = Map<String, ValuationState>.from(valuations)
      ..remove(e.valuationId);
    return copyWith(valuations: newValuations, lastSequenceNumber: seq);
  }

  // ============================================================
  // Transfer Workflow Reducers
  // ============================================================

  CapTableState _initiateTransfer(TransferInitiated e, int seq) {
    final transfer = TransferState(
      id: e.transferId,
      sellerStakeholderId: e.sellerStakeholderId,
      buyerStakeholderId: e.buyerStakeholderId,
      shareClassId: e.shareClassId,
      shareCount: e.shareCount,
      pricePerShare: e.pricePerShare,
      fairMarketValue: e.fairMarketValue,
      transactionDate: e.transactionDate,
      type: e.transferType,
      status: 'pending',
      requiresRofr: e.requiresRofr,
      rofrWaived: false,
      notes: e.notes,
      createdAt: e.timestamp,
      updatedAt: e.timestamp,
    );
    return copyWith(
      transfers: {...transfers, e.transferId: transfer},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _waiveTransferRofr(TransferRofrWaived e, int seq) {
    final existing = transfers[e.transferId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(rofrWaived: true, updatedAt: e.timestamp);
    return copyWith(
      transfers: {...transfers, e.transferId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _executeTransfer(TransferExecuted e, int seq) {
    final existing = transfers[e.transferId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      status: 'executed',
      resultingHoldingId: e.resultingHoldingId,
      updatedAt: e.timestamp,
    );
    return copyWith(
      transfers: {...transfers, e.transferId: updated},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _cancelTransfer(TransferCancelled e, int seq) {
    final existing = transfers[e.transferId];
    if (existing == null) return copyWith(lastSequenceNumber: seq);

    final updated = existing.copyWith(
      status: 'cancelled',
      notes: e.reason ?? existing.notes,
      updatedAt: e.timestamp,
    );
    return copyWith(
      transfers: {...transfers, e.transferId: updated},
      lastSequenceNumber: seq,
    );
  }

  // ============================================================
  // MFN Upgrade Reducers
  // ============================================================

  CapTableState _revertMfnUpgrade(MfnUpgradeReverted e, int seq) {
    // Reverting an MFN upgrade would require storing the upgrade history
    // For now, just mark the sequence and log
    // In a full implementation, you'd look up the original terms and restore them
    return copyWith(lastSequenceNumber: seq);
  }

  // ============================================================
  // Scenario Reducers
  // ============================================================

  CapTableState _saveScenario(ScenarioSaved e, int seq) {
    final scenario = ScenarioState(
      id: e.scenarioId,
      name: e.name,
      type: e.scenarioType,
      parametersJson: e.parametersJson,
      createdAt: e.timestamp,
    );
    return copyWith(
      scenarios: {...scenarios, e.scenarioId: scenario},
      lastSequenceNumber: seq,
    );
  }

  CapTableState _deleteScenario(ScenarioDeleted e, int seq) {
    final newScenarios = Map<String, ScenarioState>.from(scenarios)
      ..remove(e.scenarioId);
    return copyWith(scenarios: newScenarios, lastSequenceNumber: seq);
  }

  // ============================================================
  // Computed Properties
  // ============================================================

  /// Total issued shares across all holdings.
  int get totalIssuedShares =>
      holdings.values.fold(0, (sum, h) => sum + h.shareCount);

  /// Total shares by stakeholder.
  Map<String, int> get sharesByStakeholder {
    final result = <String, int>{};
    for (final h in holdings.values) {
      result[h.stakeholderId] = (result[h.stakeholderId] ?? 0) + h.shareCount;
    }
    return result;
  }

  /// Total shares by share class.
  Map<String, int> get sharesByClass {
    final result = <String, int>{};
    for (final h in holdings.values) {
      result[h.shareClassId] = (result[h.shareClassId] ?? 0) + h.shareCount;
    }
    return result;
  }

  /// Holdings for a specific stakeholder.
  List<HoldingState> holdingsForStakeholder(String stakeholderId) =>
      holdings.values.where((h) => h.stakeholderId == stakeholderId).toList();

  /// Outstanding convertibles (not yet converted or cancelled).
  List<ConvertibleState> get outstandingConvertibles =>
      convertibles.values.where((c) => c.status == 'outstanding').toList();

  /// Total outstanding convertible principal.
  double get totalConvertiblePrincipal =>
      outstandingConvertibles.fold(0.0, (sum, c) => sum + c.principal);

  factory CapTableState.fromJson(Map<String, dynamic> json) =>
      _$CapTableStateFromJson(json);
}

// ============================================================
// Entity State Classes
// ============================================================

@freezed
class StakeholderState with _$StakeholderState {
  const factory StakeholderState({
    required String id,
    required String name,
    required String type,
    String? email,
    String? phone,
    String? company,
    @Default(false) bool hasProRataRights,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StakeholderState;

  factory StakeholderState.fromJson(Map<String, dynamic> json) =>
      _$StakeholderStateFromJson(json);
}

@freezed
class ShareClassState with _$ShareClassState {
  const factory ShareClassState({
    required String id,
    required String name,
    required String type,
    @Default(1.0) double votingMultiplier,
    @Default(1.0) double liquidationPreference,
    @Default(false) bool isParticipating,
    @Default(0.0) double dividendRate,
    @Default(0) int seniority,
    @Default('none') String antiDilutionType,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ShareClassState;

  factory ShareClassState.fromJson(Map<String, dynamic> json) =>
      _$ShareClassStateFromJson(json);
}

@freezed
class RoundState with _$RoundState {
  const factory RoundState({
    required String id,
    required String name,
    required String type,
    required String status,
    required DateTime date,
    double? preMoneyValuation,
    double? pricePerShare,
    @Default(0) double amountRaised,
    String? leadInvestorId,
    required int displayOrder,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RoundState;

  factory RoundState.fromJson(Map<String, dynamic> json) =>
      _$RoundStateFromJson(json);
}

@freezed
class HoldingState with _$HoldingState {
  const factory HoldingState({
    required String id,
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    required double costBasis,
    required DateTime acquiredDate,
    String? roundId,
    String? vestingScheduleId,
    int? vestedCount,
    String? sourceOptionGrantId,
    String? sourceWarrantId,
    required DateTime updatedAt,
  }) = _HoldingState;

  factory HoldingState.fromJson(Map<String, dynamic> json) =>
      _$HoldingStateFromJson(json);
}

@freezed
class ConvertibleState with _$ConvertibleState {
  const factory ConvertibleState({
    required String id,
    required String stakeholderId,
    required String type,
    required String status,
    required double principal,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? maturityDate,
    required DateTime issueDate,
    @Default(false) bool hasMfn,
    @Default(false) bool hasProRata,
    String? roundId,
    String? conversionRoundId,
    String? convertedToShareClassId,
    int? sharesReceived,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ConvertibleState;

  factory ConvertibleState.fromJson(Map<String, dynamic> json) =>
      _$ConvertibleStateFromJson(json);
}

@freezed
class EsopPoolState with _$EsopPoolState {
  const factory EsopPoolState({
    required String id,
    required String name,
    required String shareClassId,
    required String status,
    required int poolSize,
    double? targetPercentage,
    required DateTime establishedDate,
    String? resolutionReference,
    String? roundId,
    String? defaultVestingScheduleId,
    @Default('fmv') String strikePriceMethod,
    double? defaultStrikePrice,
    @Default(10) int defaultExpiryYears,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EsopPoolState;

  factory EsopPoolState.fromJson(Map<String, dynamic> json) =>
      _$EsopPoolStateFromJson(json);
}

@freezed
class OptionGrantState with _$OptionGrantState {
  const factory OptionGrantState({
    required String id,
    required String stakeholderId,
    required String shareClassId,
    String? esopPoolId,
    required String status,
    required int quantity,
    required double strikePrice,
    required DateTime grantDate,
    required DateTime expiryDate,
    @Default(0) int exercisedCount,
    @Default(0) int cancelledCount,
    String? vestingScheduleId,
    String? roundId,
    @Default(false) bool allowsEarlyExercise,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OptionGrantState;

  factory OptionGrantState.fromJson(Map<String, dynamic> json) =>
      _$OptionGrantStateFromJson(json);
}

@freezed
class WarrantState with _$WarrantState {
  const factory WarrantState({
    required String id,
    required String stakeholderId,
    required String shareClassId,
    required String status,
    required int quantity,
    required double strikePrice,
    required DateTime issueDate,
    required DateTime expiryDate,
    @Default(0) int exercisedCount,
    @Default(0) int cancelledCount,
    String? sourceConvertibleId,
    String? roundId,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WarrantState;

  factory WarrantState.fromJson(Map<String, dynamic> json) =>
      _$WarrantStateFromJson(json);
}

@freezed
class VestingScheduleState with _$VestingScheduleState {
  const factory VestingScheduleState({
    required String id,
    required String name,
    required String type,
    int? totalMonths,
    @Default(0) int cliffMonths,
    String? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VestingScheduleState;

  factory VestingScheduleState.fromJson(Map<String, dynamic> json) =>
      _$VestingScheduleStateFromJson(json);
}

@freezed
class ValuationState with _$ValuationState {
  const factory ValuationState({
    required String id,
    required DateTime date,
    required double preMoneyValue,
    required String method,
    String? methodParamsJson,
    String? notes,
    required DateTime createdAt,
  }) = _ValuationState;

  factory ValuationState.fromJson(Map<String, dynamic> json) =>
      _$ValuationStateFromJson(json);
}

@freezed
class TransferState with _$TransferState {
  const factory TransferState({
    required String id,
    required String sellerStakeholderId,
    required String buyerStakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    double? fairMarketValue,
    required DateTime transactionDate,
    required String type,
    required String status,
    @Default(false) bool requiresRofr,
    @Default(false) bool rofrWaived,
    String? sourceHoldingId,
    String? resultingHoldingId,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransferState;

  factory TransferState.fromJson(Map<String, dynamic> json) =>
      _$TransferStateFromJson(json);
}

@freezed
class ScenarioState with _$ScenarioState {
  const factory ScenarioState({
    required String id,
    required String name,
    required String type,
    required String parametersJson,
    required DateTime createdAt,
  }) = _ScenarioState;

  factory ScenarioState.fromJson(Map<String, dynamic> json) =>
      _$ScenarioStateFromJson(json);
}
