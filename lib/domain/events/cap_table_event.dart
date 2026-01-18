import 'package:freezed_annotation/freezed_annotation.dart';

part 'cap_table_event.freezed.dart';
part 'cap_table_event.g.dart';

/// Base class for all cap table events.
///
/// Events are immutable facts that represent something that happened.
/// The cap table state is derived by folding over all events.
@Freezed(unionKey: 'type')
sealed class CapTableEvent with _$CapTableEvent {
  const CapTableEvent._();

  // ============================================================
  // COMPANY LIFECYCLE
  // ============================================================

  const factory CapTableEvent.companyCreated({
    required String companyId,
    required String name,
    required DateTime timestamp,
    String? actorId,
  }) = CompanyCreated;

  const factory CapTableEvent.companyRenamed({
    required String companyId,
    required String previousName,
    required String newName,
    required DateTime timestamp,
    String? actorId,
  }) = CompanyRenamed;

  // ============================================================
  // STAKEHOLDERS
  // ============================================================

  const factory CapTableEvent.stakeholderAdded({
    required String companyId,
    required String stakeholderId,
    required String name,
    required String stakeholderType,
    String? email,
    String? phone,
    String? company,
    @Default(false) bool hasProRataRights,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = StakeholderAdded;

  const factory CapTableEvent.stakeholderUpdated({
    required String companyId,
    required String stakeholderId,
    String? name,
    String? stakeholderType,
    String? email,
    String? phone,
    String? company,
    bool? hasProRataRights,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = StakeholderUpdated;

  const factory CapTableEvent.stakeholderRemoved({
    required String companyId,
    required String stakeholderId,
    required DateTime timestamp,
    String? actorId,
  }) = StakeholderRemoved;

  // ============================================================
  // SHARE CLASSES
  // ============================================================

  const factory CapTableEvent.shareClassCreated({
    required String companyId,
    required String shareClassId,
    required String name,
    required String shareClassType,
    @Default(1.0) double votingMultiplier,
    @Default(1.0) double liquidationPreference,
    @Default(false) bool isParticipating,
    @Default(0.0) double dividendRate,
    @Default(0) int seniority,
    @Default('none') String antiDilutionType,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = ShareClassCreated;

  const factory CapTableEvent.shareClassUpdated({
    required String companyId,
    required String shareClassId,
    String? name,
    String? shareClassType,
    double? votingMultiplier,
    double? liquidationPreference,
    bool? isParticipating,
    double? dividendRate,
    int? seniority,
    String? antiDilutionType,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = ShareClassUpdated;

  // ============================================================
  // FUNDING ROUNDS
  // ============================================================

  const factory CapTableEvent.roundOpened({
    required String companyId,
    required String roundId,
    required String name,
    required String roundType,
    required DateTime date,
    double? preMoneyValuation,
    double? pricePerShare,
    String? leadInvestorId,
    required int displayOrder,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = RoundOpened;

  const factory CapTableEvent.roundClosed({
    required String companyId,
    required String roundId,
    required double amountRaised,
    required DateTime timestamp,
    String? actorId,
  }) = RoundClosed;

  const factory CapTableEvent.roundAmended({
    required String companyId,
    required String roundId,
    String? name,
    String? roundType,
    DateTime? date,
    double? preMoneyValuation,
    double? pricePerShare,
    String? leadInvestorId,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = RoundAmended;

  const factory CapTableEvent.roundReopened({
    required String companyId,
    required String roundId,
    required DateTime timestamp,
    String? actorId,
  }) = RoundReopened;

  const factory CapTableEvent.roundDeleted({
    required String companyId,
    required String roundId,
    required DateTime timestamp,
    String? actorId,
  }) = RoundDeleted;

  // ============================================================
  // EQUITY TRANSACTIONS (HOLDINGS)
  // ============================================================

  const factory CapTableEvent.sharesIssued({
    required String companyId,
    required String holdingId,
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    required double costBasis,
    required DateTime acquiredDate,
    String? roundId,
    String? vestingScheduleId,
    String? sourceOptionGrantId,
    String? sourceWarrantId,
    required DateTime timestamp,
    String? actorId,
  }) = SharesIssued;

  const factory CapTableEvent.sharesTransferred({
    required String companyId,
    required String transferId,
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
    required DateTime timestamp,
    String? actorId,
  }) = SharesTransferred;

  const factory CapTableEvent.sharesRepurchased({
    required String companyId,
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    required DateTime repurchaseDate,
    String? holdingId,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = SharesRepurchased;

  const factory CapTableEvent.holdingDeleted({
    required String companyId,
    required String holdingId,
    required DateTime timestamp,
    String? actorId,
  }) = HoldingDeleted;

  const factory CapTableEvent.holdingUpdated({
    required String companyId,
    required String holdingId,
    int? shareCount,
    double? costBasis,
    DateTime? acquiredDate,
    String? shareClassId,
    String? vestingScheduleId,
    required DateTime timestamp,
    String? actorId,
  }) = HoldingUpdated;

  const factory CapTableEvent.holdingVestingUpdated({
    required String companyId,
    required String holdingId,
    required int vestedCount,
    required DateTime timestamp,
    String? actorId,
  }) = HoldingVestingUpdated;

  // ============================================================
  // CONVERTIBLES (SAFEs & Notes)
  // ============================================================

  const factory CapTableEvent.convertibleIssued({
    required String companyId,
    required String convertibleId,
    required String stakeholderId,
    required String convertibleType,
    required double principal,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? maturityDate,
    required DateTime issueDate,
    @Default(false) bool hasMfn,
    @Default(false) bool hasProRata,
    String? roundId,
    String? notes,
    // Advanced terms
    String? maturityBehavior,
    @Default(false) bool allowsVoluntaryConversion,
    String? liquidityEventBehavior,
    double? liquidityPayoutMultiple,
    String? dissolutionBehavior,
    String? preferredShareClassId,
    double? qualifiedFinancingThreshold,
    required DateTime timestamp,
    String? actorId,
  }) = ConvertibleIssued;

  const factory CapTableEvent.mfnUpgradeApplied({
    required String companyId,
    required String upgradeId,
    required String targetConvertibleId,
    required String sourceConvertibleId,
    // Previous terms
    double? previousDiscountPercent,
    double? previousValuationCap,
    @Default(false) bool previousHasProRata,
    // New terms
    double? newDiscountPercent,
    double? newValuationCap,
    @Default(false) bool newHasProRata,
    required DateTime timestamp,
    String? actorId,
  }) = MfnUpgradeApplied;

  const factory CapTableEvent.convertibleConverted({
    required String companyId,
    required String convertibleId,
    String? roundId, // Optional for voluntary conversions outside of a round
    required String toShareClassId,
    required int sharesReceived,
    required double conversionPrice,
    required DateTime timestamp,
    String? actorId,
  }) = ConvertibleConverted;

  const factory CapTableEvent.convertibleCancelled({
    required String companyId,
    required String convertibleId,
    String? reason,
    required DateTime timestamp,
    String? actorId,
  }) = ConvertibleCancelled;

  const factory CapTableEvent.convertibleUpdated({
    required String companyId,
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
    required DateTime timestamp,
    String? actorId,
  }) = ConvertibleUpdated;

  // ============================================================
  // ESOP POOLS
  // ============================================================

  const factory CapTableEvent.esopPoolCreated({
    required String companyId,
    required String poolId,
    required String name,
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
    required DateTime timestamp,
    String? actorId,
  }) = EsopPoolCreated;

  const factory CapTableEvent.esopPoolExpanded({
    required String companyId,
    required String expansionId,
    required String poolId,
    required int previousSize,
    required int newSize,
    required int sharesAdded,
    required String reason,
    String? resolutionReference,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = EsopPoolExpanded;

  const factory CapTableEvent.esopPoolActivated({
    required String companyId,
    required String poolId,
    required DateTime timestamp,
    String? actorId,
  }) = EsopPoolActivated;

  const factory CapTableEvent.esopPoolUpdated({
    required String companyId,
    required String poolId,
    String? name,
    double? targetPercentage,
    String? defaultVestingScheduleId,
    String? strikePriceMethod,
    double? defaultStrikePrice,
    int? defaultExpiryYears,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = EsopPoolUpdated;

  const factory CapTableEvent.esopPoolDeleted({
    required String companyId,
    required String poolId,
    required DateTime timestamp,
    String? actorId,
  }) = EsopPoolDeleted;

  const factory CapTableEvent.esopPoolExpansionReverted({
    required String companyId,
    required String expansionId,
    required String poolId,
    required int previousSize,
    required int revertedSize,
    required int sharesRemoved,
    required DateTime timestamp,
    String? actorId,
  }) = EsopPoolExpansionReverted;

  // ============================================================
  // OPTION GRANTS
  // ============================================================

  const factory CapTableEvent.optionGranted({
    required String companyId,
    required String grantId,
    required String stakeholderId,
    required String shareClassId,
    String? esopPoolId,
    required int quantity,
    required double strikePrice,
    required DateTime grantDate,
    required DateTime expiryDate,
    String? vestingScheduleId,
    String? roundId,
    @Default(false) bool allowsEarlyExercise,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = OptionGranted;

  const factory CapTableEvent.optionsVested({
    required String companyId,
    required String grantId,
    required int vestedCount,
    required DateTime vestingDate,
    required DateTime timestamp,
    String? actorId,
  }) = OptionsVested;

  const factory CapTableEvent.optionsExercised({
    required String companyId,
    required String grantId,
    required int exercisedCount,
    required double exercisePrice,
    required String resultingHoldingId,
    required DateTime exerciseDate,
    required DateTime timestamp,
    String? actorId,

    /// The type of exercise: cash, cashless, net, netWithTax
    @Default('cash') String exerciseType,

    /// Shares withheld to cover strike price (for net exercise)
    int? sharesWithheldForStrike,

    /// Shares withheld for tax withholding (for netWithTax or cashless)
    int? sharesWithheldForTax,

    /// Net shares received by the holder after withholding
    int? netSharesReceived,

    /// For cashless: the fair market value per share at exercise
    double? fairMarketValue,

    /// For cashless: proceeds received after costs
    double? proceedsReceived,
  }) = OptionsExercised;

  const factory CapTableEvent.optionsCancelled({
    required String companyId,
    required String grantId,
    required int cancelledCount,
    String? reason,
    required DateTime timestamp,
    String? actorId,
  }) = OptionsCancelled;

  const factory CapTableEvent.optionGrantStatusChanged({
    required String companyId,
    required String grantId,
    required String previousStatus,
    required String newStatus,
    required DateTime timestamp,
    String? actorId,
  }) = OptionGrantStatusChanged;

  const factory CapTableEvent.optionGrantUpdated({
    required String companyId,
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
    required DateTime timestamp,
    String? actorId,
  }) = OptionGrantUpdated;

  // ============================================================
  // WARRANTS
  // ============================================================

  const factory CapTableEvent.warrantIssued({
    required String companyId,
    required String warrantId,
    required String stakeholderId,
    required String shareClassId,
    required int quantity,
    required double strikePrice,
    required DateTime issueDate,
    required DateTime expiryDate,
    String? sourceConvertibleId,
    String? roundId,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = WarrantIssued;

  const factory CapTableEvent.warrantExercised({
    required String companyId,
    required String warrantId,
    required int exercisedCount,
    required double exercisePrice,
    required String resultingHoldingId,
    required DateTime exerciseDate,
    required DateTime timestamp,
    String? actorId,

    /// The type of exercise: cash, cashless, net, netWithTax
    @Default('cash') String exerciseType,

    /// Shares withheld to cover strike price (for net exercise)
    int? sharesWithheldForStrike,

    /// Shares withheld for tax withholding (for netWithTax or cashless)
    int? sharesWithheldForTax,

    /// Net shares received by the holder after withholding
    int? netSharesReceived,

    /// For cashless: the fair market value per share at exercise
    double? fairMarketValue,

    /// For cashless: proceeds received after costs
    double? proceedsReceived,
  }) = WarrantExercised;

  const factory CapTableEvent.warrantCancelled({
    required String companyId,
    required String warrantId,
    required int cancelledCount,
    String? reason,
    required DateTime timestamp,
    String? actorId,
  }) = WarrantCancelled;

  const factory CapTableEvent.warrantUpdated({
    required String companyId,
    required String warrantId,
    String? shareClassId,
    int? quantity,
    double? strikePrice,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? roundId,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = WarrantUpdated;

  const factory CapTableEvent.warrantUnexercised({
    required String companyId,
    required String warrantId,
    required int unexercisedCount,
    String? reason,
    required DateTime timestamp,
    String? actorId,
  }) = WarrantUnexercised;

  const factory CapTableEvent.warrantStatusChanged({
    required String companyId,
    required String warrantId,
    required String previousStatus,
    required String newStatus,
    required DateTime timestamp,
    String? actorId,
  }) = WarrantStatusChanged;

  // ============================================================
  // VESTING SCHEDULES
  // ============================================================

  const factory CapTableEvent.vestingScheduleCreated({
    required String companyId,
    required String scheduleId,
    required String name,
    required String scheduleType,
    int? totalMonths,
    @Default(0) int cliffMonths,
    String? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = VestingScheduleCreated;

  const factory CapTableEvent.vestingScheduleUpdated({
    required String companyId,
    required String scheduleId,
    String? name,
    String? scheduleType,
    int? totalMonths,
    int? cliffMonths,
    String? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = VestingScheduleUpdated;

  const factory CapTableEvent.vestingScheduleDeleted({
    required String companyId,
    required String scheduleId,
    required DateTime timestamp,
    String? actorId,
  }) = VestingScheduleDeleted;

  // ============================================================
  // VALUATIONS
  // ============================================================

  const factory CapTableEvent.valuationRecorded({
    required String companyId,
    required String valuationId,
    required DateTime date,
    required double preMoneyValue,
    required String method,
    String? methodParamsJson,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = ValuationRecorded;

  const factory CapTableEvent.valuationDeleted({
    required String companyId,
    required String valuationId,
    required DateTime timestamp,
    String? actorId,
  }) = ValuationDeleted;

  // ============================================================
  // TRANSFER WORKFLOW
  // ============================================================

  /// A transfer is initiated (pending approval/execution).
  const factory CapTableEvent.transferInitiated({
    required String companyId,
    required String transferId,
    required String sellerStakeholderId,
    required String buyerStakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    double? fairMarketValue,
    required DateTime transactionDate,
    required String transferType,
    @Default(false) bool requiresRofr,
    String? notes,
    required DateTime timestamp,
    String? actorId,
  }) = TransferInitiated;

  /// ROFR has been waived for a pending transfer.
  const factory CapTableEvent.transferRofrWaived({
    required String companyId,
    required String transferId,
    String? waivedBy,
    required DateTime timestamp,
    String? actorId,
  }) = TransferRofrWaived;

  /// A pending transfer is executed (shares actually move).
  const factory CapTableEvent.transferExecuted({
    required String companyId,
    required String transferId,
    required String resultingHoldingId,
    required DateTime executionDate,
    required DateTime timestamp,
    String? actorId,
  }) = TransferExecuted;

  /// A pending transfer is cancelled.
  const factory CapTableEvent.transferCancelled({
    required String companyId,
    required String transferId,
    String? reason,
    required DateTime timestamp,
    String? actorId,
  }) = TransferCancelled;

  // ============================================================
  // MFN UPGRADES
  // ============================================================

  /// Revert a previously applied MFN upgrade.
  const factory CapTableEvent.mfnUpgradeReverted({
    required String companyId,
    required String upgradeId,
    required String targetConvertibleId,
    required DateTime timestamp,
    String? actorId,
  }) = MfnUpgradeReverted;

  // ============================================================
  // SCENARIOS
  // ============================================================

  /// A scenario is saved for later reference.
  const factory CapTableEvent.scenarioSaved({
    required String companyId,
    required String scenarioId,
    required String name,
    required String scenarioType,
    required String parametersJson,
    required DateTime timestamp,
    String? actorId,
  }) = ScenarioSaved;

  /// A saved scenario is deleted.
  const factory CapTableEvent.scenarioDeleted({
    required String companyId,
    required String scenarioId,
    required DateTime timestamp,
    String? actorId,
  }) = ScenarioDeleted;

  // ============================================================
  // SERIALIZATION
  // ============================================================

  factory CapTableEvent.fromJson(Map<String, dynamic> json) =>
      _$CapTableEventFromJson(json);
}
