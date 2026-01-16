import 'package:drift/drift.dart';

/// Companies table - the legal entity being tracked.
class Companies extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stakeholders table - anyone who can hold securities.
class Stakeholders extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // StakeholderType enum as string
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get company => text().nullable()();
  BoolColumn get hasProRataRights =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Share classes table - types of shares with their rights.
class ShareClasses extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // ShareClassType enum as string
  RealColumn get votingMultiplier => real().withDefault(const Constant(1.0))();
  RealColumn get liquidationPreference =>
      real().withDefault(const Constant(1.0))();
  BoolColumn get isParticipating =>
      boolean().withDefault(const Constant(false))();
  RealColumn get dividendRate => real().withDefault(const Constant(0.0))();
  IntColumn get seniority => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Rounds table - financing events.
class Rounds extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // RoundType enum as string
  TextColumn get status =>
      text().withDefault(const Constant('draft'))(); // RoundStatus
  DateTimeColumn get date => dateTime()();
  RealColumn get preMoneyValuation => real().nullable()();
  RealColumn get pricePerShare => real().nullable()();
  RealColumn get amountRaised => real().withDefault(const Constant(0.0))();
  TextColumn get leadInvestorId =>
      text().nullable().references(Stakeholders, #id)();
  IntColumn get displayOrder => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Holdings table - current share ownership (computed from events).
class Holdings extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get stakeholderId => text().references(Stakeholders, #id)();
  TextColumn get shareClassId => text().references(ShareClasses, #id)();
  IntColumn get shareCount => integer()();
  RealColumn get costBasis => real()();
  DateTimeColumn get acquiredDate => dateTime()();
  TextColumn get vestingScheduleId => text().nullable()();
  IntColumn get vestedCount => integer().nullable()();
  TextColumn get roundId => text().nullable().references(Rounds, #id)();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Convertibles table - SAFEs and convertible notes.
class Convertibles extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get stakeholderId => text().references(Stakeholders, #id)();
  TextColumn get type => text()(); // ConvertibleType enum
  TextColumn get status => text().withDefault(const Constant('outstanding'))();
  RealColumn get principal => real()();
  RealColumn get valuationCap => real().nullable()();
  RealColumn get discountPercent => real().nullable()();
  RealColumn get interestRate => real().nullable()();
  DateTimeColumn get maturityDate => dateTime().nullable()();
  DateTimeColumn get issueDate => dateTime()();
  BoolColumn get hasMfn => boolean().withDefault(const Constant(false))();
  BoolColumn get hasProRata => boolean().withDefault(const Constant(false))();
  TextColumn get roundId =>
      text().nullable().references(Rounds, #id)(); // Round issued in
  TextColumn get conversionEventId => text().nullable()();
  TextColumn get convertedToShareClassId => text().nullable()();
  IntColumn get sharesReceived => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Option grants table.
class OptionGrants extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get stakeholderId => text().references(Stakeholders, #id)();
  TextColumn get shareClassId => text().references(ShareClasses, #id)();
  TextColumn get esopPoolId => text().nullable()(); // References EsopPools
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get quantity => integer()();
  RealColumn get strikePrice => real()();
  DateTimeColumn get grantDate => dateTime()();
  DateTimeColumn get expiryDate => dateTime()();
  IntColumn get exercisedCount => integer().withDefault(const Constant(0))();
  IntColumn get cancelledCount => integer().withDefault(const Constant(0))();
  TextColumn get vestingScheduleId => text().nullable()();
  TextColumn get roundId => text().nullable().references(Rounds, #id)();
  BoolColumn get allowsEarlyExercise =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Warrants table.
class Warrants extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get stakeholderId => text().references(Stakeholders, #id)();
  TextColumn get shareClassId => text().references(ShareClasses, #id)();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get quantity => integer()();
  RealColumn get strikePrice => real()();
  DateTimeColumn get issueDate => dateTime()();
  DateTimeColumn get expiryDate => dateTime()();
  IntColumn get exercisedCount => integer().withDefault(const Constant(0))();
  IntColumn get cancelledCount => integer().withDefault(const Constant(0))();
  TextColumn get sourceConvertibleId =>
      text().nullable().references(Convertibles, #id)();
  TextColumn get roundId => text().nullable().references(Rounds, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Vesting schedules table.
class VestingSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // VestingType enum
  IntColumn get totalMonths => integer().nullable()();
  IntColumn get cliffMonths => integer().withDefault(const Constant(0))();
  TextColumn get frequency => text().nullable()(); // VestingFrequency enum
  TextColumn get milestonesJson => text().nullable()();
  IntColumn get totalHours => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Valuations table.
class Valuations extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  DateTimeColumn get date => dateTime()();
  RealColumn get preMoneyValue => real()();
  TextColumn get method => text()(); // ValuationMethod enum
  TextColumn get methodParamsJson => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ESOP pools table - employee stock option pools.
class EsopPools extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get shareClassId => text().references(ShareClasses, #id)();
  TextColumn get status =>
      text().withDefault(const Constant('draft'))(); // EsopPoolStatus
  IntColumn get poolSize => integer()();
  RealColumn get targetPercentage => real().nullable()();
  DateTimeColumn get establishedDate => dateTime()();
  TextColumn get resolutionReference => text().nullable()();
  TextColumn get roundId => text().nullable().references(Rounds, #id)();
  TextColumn get defaultVestingScheduleId => text().nullable()();
  TextColumn get strikePriceMethod =>
      text().withDefault(const Constant('fmv'))();
  RealColumn get defaultStrikePrice => real().nullable()();
  IntColumn get defaultExpiryYears =>
      integer().withDefault(const Constant(10))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Capitalization events table (event sourcing).
class CapitalizationEvents extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get eventType => text()(); // CapEventType enum
  DateTimeColumn get effectiveDate => dateTime()();
  TextColumn get eventDataJson => text()();
  TextColumn get roundId => text().nullable().references(Rounds, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Saved scenarios table.
class SavedScenarios extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // ScenarioType enum
  TextColumn get parametersJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Share transfers table - secondary sales, tender offers, gifts.
class Transfers extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();

  // Parties involved
  @ReferenceName('sellerTransfers')
  TextColumn get sellerStakeholderId => text().references(Stakeholders, #id)();
  @ReferenceName('buyerTransfers')
  TextColumn get buyerStakeholderId => text().references(Stakeholders, #id)();

  // What's being transferred
  TextColumn get shareClassId => text().references(ShareClasses, #id)();
  IntColumn get shareCount => integer()();

  // Pricing
  RealColumn get pricePerShare => real()();
  RealColumn get fairMarketValue => real().nullable()(); // FMV at time for tax

  // Dates
  DateTimeColumn get transactionDate => dateTime()();

  // Type and status
  TextColumn get type =>
      text()(); // 'secondary', 'tender_offer', 'rofr', 'gift'
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending, approved, completed, cancelled
  BoolColumn get rofrWaived => boolean().withDefault(const Constant(false))();

  // References
  TextColumn get sourceHoldingId =>
      text().nullable().references(Holdings, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// MFN (Most Favored Nation) upgrade history table.
///
/// Tracks when convertibles with MFN clauses have their terms upgraded
/// based on later convertibles with better terms. Enables proper reversal
/// if the triggering convertible is deleted or edited.
class MfnUpgrades extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id)();

  /// The convertible that was upgraded (has MFN clause)
  @ReferenceName('mfnTargetUpgrades')
  TextColumn get targetConvertibleId => text().references(Convertibles, #id)();

  /// The convertible that triggered the upgrade (has better terms)
  @ReferenceName('mfnSourceUpgrades')
  TextColumn get sourceConvertibleId => text().references(Convertibles, #id)();

  /// Terms BEFORE upgrade
  RealColumn get previousDiscountPercent => real().nullable()();
  RealColumn get previousValuationCap => real().nullable()();
  BoolColumn get previousHasProRata =>
      boolean().withDefault(const Constant(false))();

  /// Terms AFTER upgrade
  RealColumn get newDiscountPercent => real().nullable()();
  RealColumn get newValuationCap => real().nullable()();
  BoolColumn get newHasProRata =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get upgradeDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
