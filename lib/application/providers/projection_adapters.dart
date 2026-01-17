import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/projections/cap_table_state.dart';
import '../../infrastructure/database/database.dart';
import 'company_provider.dart';
import 'projection_providers.dart';

part 'projection_adapters.g.dart';

// ============================================================
// Stakeholder Adapters
// ============================================================

/// Converts StakeholderState to Drift Stakeholder entity.
Stakeholder _stakeholderFromState(StakeholderState state, String companyId) {
  return Stakeholder(
    id: state.id,
    companyId: companyId,
    name: state.name,
    type: state.type,
    email: state.email,
    phone: state.phone,
    company: state.company,
    hasProRataRights: state.hasProRataRights,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// Stakeholders provider using event-sourced projections.
@riverpod
Stream<List<Stakeholder>> unifiedStakeholdersStream(
  UnifiedStakeholdersStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final stakeholderStates = await ref.watch(
    projectedStakeholdersProvider.future,
  );
  yield stakeholderStates
      .map((s) => _stakeholderFromState(s, companyId))
      .toList();
}

// ============================================================
// Round Adapters
// ============================================================

/// Converts RoundState to Drift Round entity.
Round _roundFromState(RoundState state, String companyId) {
  return Round(
    id: state.id,
    companyId: companyId,
    name: state.name,
    type: state.type,
    status: state.status,
    displayOrder: state.displayOrder,
    date: state.date,
    preMoneyValuation: state.preMoneyValuation,
    pricePerShare: state.pricePerShare,
    amountRaised: state.amountRaised,
    leadInvestorId: state.leadInvestorId,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// Rounds provider using event-sourced projections.
@riverpod
Stream<List<Round>> unifiedRoundsStream(UnifiedRoundsStreamRef ref) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final roundStates = await ref.watch(projectedRoundsProvider.future);
  yield roundStates.map((r) => _roundFromState(r, companyId)).toList();
}

// ============================================================
// Holding Adapters
// ============================================================

/// Converts HoldingState to Drift Holding entity.
Holding _holdingFromState(HoldingState state, String companyId) {
  return Holding(
    id: state.id,
    companyId: companyId,
    stakeholderId: state.stakeholderId,
    shareClassId: state.shareClassId,
    shareCount: state.shareCount,
    costBasis: state.costBasis,
    acquiredDate: state.acquiredDate,
    vestingScheduleId: state.vestingScheduleId,
    vestedCount: state.vestedCount,
    roundId: state.roundId,
    updatedAt: state.updatedAt,
  );
}

/// Holdings provider using event-sourced projections.
@riverpod
Stream<List<Holding>> unifiedHoldingsStream(
  UnifiedHoldingsStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final holdingStates = await ref.watch(projectedHoldingsProvider.future);
  yield holdingStates.map((h) => _holdingFromState(h, companyId)).toList();
}

/// Stakeholder holdings provider using event-sourced projections.
@riverpod
Stream<List<Holding>> unifiedStakeholderHoldings(
  UnifiedStakeholderHoldingsRef ref,
  String stakeholderId,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final holdingStates = await ref.watch(
    projectedStakeholderHoldingsProvider(stakeholderId).future,
  );
  yield holdingStates.map((h) => _holdingFromState(h, companyId)).toList();
}

// ============================================================
// Share Class Adapters
// ============================================================

/// Converts ShareClassState to Drift ShareClassesData entity.
ShareClassesData _shareClassFromState(ShareClassState state, String companyId) {
  return ShareClassesData(
    id: state.id,
    companyId: companyId,
    name: state.name,
    type: state.type,
    seniority: state.seniority,
    liquidationPreference: state.liquidationPreference,
    isParticipating: state.isParticipating,
    votingMultiplier: state.votingMultiplier,
    dividendRate: state.dividendRate,
    antiDilutionType: state.antiDilutionType,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// Share classes provider using event-sourced projections.
@riverpod
Stream<List<ShareClassesData>> unifiedShareClassesStream(
  UnifiedShareClassesStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final states = await ref.watch(projectedShareClassesProvider.future);
  yield states.map((s) => _shareClassFromState(s, companyId)).toList();
}

// ============================================================
// Convertible Adapters
// ============================================================

/// Converts ConvertibleState to Drift Convertible entity.
Convertible _convertibleFromState(ConvertibleState state, String companyId) {
  return Convertible(
    id: state.id,
    companyId: companyId,
    stakeholderId: state.stakeholderId,
    type: state.type,
    status: state.status,
    principal: state.principal,
    issueDate: state.issueDate,
    maturityDate: state.maturityDate,
    interestRate: state.interestRate,
    valuationCap: state.valuationCap,
    discountPercent: state.discountPercent,
    hasMfn: state.hasMfn,
    hasProRata: state.hasProRata,
    roundId: state.roundId,
    conversionEventId: state.conversionRoundId,
    convertedToShareClassId: state.convertedToShareClassId,
    sharesReceived: state.sharesReceived,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// Convertibles provider using event-sourced projections.
@riverpod
Stream<List<Convertible>> unifiedConvertiblesStream(
  UnifiedConvertiblesStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final states = await ref.watch(projectedConvertiblesProvider.future);
  yield states.map((c) => _convertibleFromState(c, companyId)).toList();
}

// ============================================================
// ESOP Pool Adapters
// ============================================================

/// Converts EsopPoolState to Drift EsopPool entity.
EsopPool _esopPoolFromState(EsopPoolState state, String companyId) {
  return EsopPool(
    id: state.id,
    companyId: companyId,
    name: state.name,
    shareClassId: state.shareClassId,
    status: state.status,
    poolSize: state.poolSize,
    targetPercentage: state.targetPercentage,
    establishedDate: state.establishedDate,
    resolutionReference: state.resolutionReference,
    roundId: state.roundId,
    defaultVestingScheduleId: state.defaultVestingScheduleId,
    strikePriceMethod: state.strikePriceMethod,
    defaultStrikePrice: state.defaultStrikePrice,
    defaultExpiryYears: state.defaultExpiryYears,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// ESOP pools provider using event-sourced projections.
@riverpod
Stream<List<EsopPool>> unifiedEsopPoolsStream(
  UnifiedEsopPoolsStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final states = await ref.watch(projectedEsopPoolsProvider.future);
  yield states.map((p) => _esopPoolFromState(p, companyId)).toList();
}

// ============================================================
// Option Grant Adapters
// ============================================================

/// Converts OptionGrantState to Drift OptionGrant entity.
OptionGrant _optionGrantFromState(OptionGrantState state, String companyId) {
  return OptionGrant(
    id: state.id,
    companyId: companyId,
    stakeholderId: state.stakeholderId,
    shareClassId: state.shareClassId,
    esopPoolId: state.esopPoolId,
    status: state.status,
    quantity: state.quantity,
    strikePrice: state.strikePrice,
    grantDate: state.grantDate,
    expiryDate: state.expiryDate,
    exercisedCount: state.exercisedCount,
    cancelledCount: state.cancelledCount,
    vestingScheduleId: state.vestingScheduleId,
    roundId: state.roundId,
    allowsEarlyExercise: state.allowsEarlyExercise,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// Option grants provider using event-sourced projections.
@riverpod
Stream<List<OptionGrant>> unifiedOptionGrantsStream(
  UnifiedOptionGrantsStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final states = await ref.watch(projectedOptionGrantsProvider.future);
  yield states.map((g) => _optionGrantFromState(g, companyId)).toList();
}

// ============================================================
// Warrant Adapters
// ============================================================

/// Converts WarrantState to Drift Warrant entity.
Warrant _warrantFromState(WarrantState state, String companyId) {
  return Warrant(
    id: state.id,
    companyId: companyId,
    stakeholderId: state.stakeholderId,
    shareClassId: state.shareClassId,
    status: state.status,
    quantity: state.quantity,
    strikePrice: state.strikePrice,
    issueDate: state.issueDate,
    expiryDate: state.expiryDate,
    exercisedCount: state.exercisedCount,
    cancelledCount: state.cancelledCount,
    sourceConvertibleId: state.sourceConvertibleId,
    roundId: state.roundId,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// Warrants provider using event-sourced projections.
@riverpod
Stream<List<Warrant>> unifiedWarrantsStream(
  UnifiedWarrantsStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final states = await ref.watch(projectedWarrantsProvider.future);
  yield states.map((w) => _warrantFromState(w, companyId)).toList();
}

// ============================================================
// Vesting Schedule Adapters
// ============================================================

/// Converts VestingScheduleState to Drift VestingSchedule entity.
VestingSchedule _vestingScheduleFromState(
  VestingScheduleState state,
  String companyId,
) {
  return VestingSchedule(
    id: state.id,
    companyId: companyId,
    name: state.name,
    type: state.type,
    totalMonths: state.totalMonths,
    cliffMonths: state.cliffMonths,
    frequency: state.frequency,
    milestonesJson: state.milestonesJson,
    totalHours: state.totalHours,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// Vesting schedules provider using event-sourced projections.
@riverpod
Stream<List<VestingSchedule>> unifiedVestingSchedulesStream(
  UnifiedVestingSchedulesStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final states = await ref.watch(projectedVestingSchedulesProvider.future);
  yield states.map((v) => _vestingScheduleFromState(v, companyId)).toList();
}

// ============================================================
// Valuation Adapters
// ============================================================

/// Converts ValuationState to Drift Valuation entity.
Valuation _valuationFromState(ValuationState state, String companyId) {
  return Valuation(
    id: state.id,
    companyId: companyId,
    date: state.date,
    preMoneyValue: state.preMoneyValue,
    method: state.method,
    methodParamsJson: state.methodParamsJson,
    notes: state.notes,
    createdAt: state.createdAt,
  );
}

/// Valuations provider using event-sourced projections.
@riverpod
Stream<List<Valuation>> unifiedValuationsStream(
  UnifiedValuationsStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final states = await ref.watch(projectedValuationsProvider.future);
  yield states.map((v) => _valuationFromState(v, companyId)).toList();
}

// ============================================================
// Transfer Adapters
// ============================================================

/// Converts TransferState to Drift Transfer entity.
Transfer _transferFromState(TransferState state, String companyId) {
  return Transfer(
    id: state.id,
    companyId: companyId,
    sellerStakeholderId: state.sellerStakeholderId,
    buyerStakeholderId: state.buyerStakeholderId,
    shareClassId: state.shareClassId,
    shareCount: state.shareCount,
    pricePerShare: state.pricePerShare,
    fairMarketValue: state.fairMarketValue,
    transactionDate: state.transactionDate,
    type: state.type,
    status: state.status,
    rofrWaived: false,
    sourceHoldingId: state.sourceHoldingId,
    notes: state.notes,
    createdAt: state.createdAt,
    updatedAt: state.updatedAt,
  );
}

/// Transfers provider using event-sourced projections.
@riverpod
Stream<List<Transfer>> unifiedTransfersStream(
  UnifiedTransfersStreamRef ref,
) async* {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) {
    yield [];
    return;
  }

  final states = await ref.watch(projectedTransfersProvider.future);
  yield states.map((t) => _transferFromState(t, companyId)).toList();
}
