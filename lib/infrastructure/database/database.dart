import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

/// The main application database.
///
/// Uses Drift (formerly Moor) for type-safe SQLite access.
/// Schema is designed for future Supabase sync compatibility.
@DriftDatabase(
  tables: [
    Companies,
    Stakeholders,
    ShareClasses,
    Rounds,
    Holdings,
    Convertibles,
    EsopPools,
    OptionGrants,
    Warrants,
    VestingSchedules,
    Valuations,
    CapitalizationEvents,
    SavedScenarios,
    Transfers,
    MfnUpgrades,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing with a custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration from version 1 to 2: Add MfnUpgrades table
        if (from < 2) {
          await m.createTable(mfnUpgrades);
        }
        // Migration from version 2 to 3: Add roundId to holdings, esopPools table, esopPoolId to optionGrants
        if (from < 3) {
          // Add roundId column to holdings if it doesn't exist
          final holdingsColumns = await customSelect(
            "PRAGMA table_info(holdings)",
          ).get();
          final hasRoundId = holdingsColumns.any(
            (row) => row.read<String>('name') == 'round_id',
          );
          if (!hasRoundId) {
            await customStatement(
              'ALTER TABLE holdings ADD COLUMN round_id TEXT REFERENCES rounds(id)',
            );
          }
          // Create esopPools table if it doesn't exist
          await m.createTable(esopPools);
          // Add esopPoolId column to optionGrants if it doesn't exist
          final optionGrantsColumns = await customSelect(
            "PRAGMA table_info(option_grants)",
          ).get();
          final hasEsopPoolId = optionGrantsColumns.any(
            (row) => row.read<String>('name') == 'esop_pool_id',
          );
          if (!hasEsopPoolId) {
            await customStatement(
              'ALTER TABLE option_grants ADD COLUMN esop_pool_id TEXT',
            );
          }
        }
        // Migration from version 3 to 4: Add transfers table
        if (from < 4) {
          await m.createTable(transfers);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ===========================================================================
  // Company Operations
  // ===========================================================================

  /// Get all companies.
  Future<List<Company>> getAllCompanies() => select(companies).get();

  /// Watch all companies.
  Stream<List<Company>> watchCompanies() => select(companies).watch();

  /// Get a company by ID.
  Future<Company?> getCompany(String id) {
    return (select(companies)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update a company.
  Future<void> upsertCompany(CompaniesCompanion company) {
    return into(companies).insertOnConflictUpdate(company);
  }

  /// Delete a company and all related data.
  Future<void> deleteCompany(String id) async {
    await (delete(companies)..where((c) => c.id.equals(id))).go();
  }

  // ===========================================================================
  // Stakeholder Operations
  // ===========================================================================

  /// Get all stakeholders for a company.
  Future<List<Stakeholder>> getStakeholders(String companyId) {
    return (select(stakeholders)
          ..where((s) => s.companyId.equals(companyId))
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .get();
  }

  /// Watch stakeholders for real-time updates.
  Stream<List<Stakeholder>> watchStakeholders(String companyId) {
    return (select(stakeholders)
          ..where((s) => s.companyId.equals(companyId))
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }

  /// Get a stakeholder by ID.
  Future<Stakeholder?> getStakeholder(String id) {
    return (select(
      stakeholders,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update a stakeholder.
  Future<void> upsertStakeholder(StakeholdersCompanion stakeholder) {
    return into(stakeholders).insertOnConflictUpdate(stakeholder);
  }

  /// Delete a stakeholder and all related holdings, convertibles, warrants, etc.
  Future<void> deleteStakeholder(String id) async {
    await transaction(() async {
      // Delete holdings for this stakeholder
      await (delete(holdings)..where((h) => h.stakeholderId.equals(id))).go();

      // Delete convertibles for this stakeholder
      await (delete(
        convertibles,
      )..where((c) => c.stakeholderId.equals(id))).go();

      // Delete warrants for this stakeholder
      await (delete(warrants)..where((w) => w.stakeholderId.equals(id))).go();

      // Delete option grants for this stakeholder
      await (delete(
        optionGrants,
      )..where((o) => o.stakeholderId.equals(id))).go();

      // Delete transfers involving this stakeholder
      await (delete(transfers)..where(
            (t) =>
                t.sellerStakeholderId.equals(id) |
                t.buyerStakeholderId.equals(id),
          ))
          .go();

      // Clear leadInvestorId references in rounds
      await (update(rounds)..where((r) => r.leadInvestorId.equals(id))).write(
        const RoundsCompanion(leadInvestorId: Value(null)),
      );

      // Now delete the stakeholder
      await (delete(stakeholders)..where((s) => s.id.equals(id))).go();
    });
  }

  // ===========================================================================
  // Share Class Operations
  // ===========================================================================

  /// Get all share classes for a company.
  Future<List<ShareClassesData>> getShareClasses(String companyId) {
    return (select(shareClasses)
          ..where((s) => s.companyId.equals(companyId))
          ..orderBy([(s) => OrderingTerm.desc(s.seniority)]))
        .get();
  }

  /// Watch share classes for real-time updates.
  Stream<List<ShareClassesData>> watchShareClasses(String companyId) {
    return (select(shareClasses)
          ..where((s) => s.companyId.equals(companyId))
          ..orderBy([(s) => OrderingTerm.desc(s.seniority)]))
        .watch();
  }

  /// Insert or update a share class.
  Future<void> upsertShareClass(ShareClassesCompanion shareClass) {
    return into(shareClasses).insertOnConflictUpdate(shareClass);
  }

  /// Delete a share class.
  Future<void> deleteShareClass(String id) async {
    await (delete(shareClasses)..where((s) => s.id.equals(id))).go();
  }

  // ===========================================================================
  // Round Operations
  // ===========================================================================

  /// Get all rounds for a company.
  Future<List<Round>> getRounds(String companyId) {
    return (select(rounds)
          ..where((r) => r.companyId.equals(companyId))
          ..orderBy([(r) => OrderingTerm.desc(r.displayOrder)]))
        .get();
  }

  /// Get a round by ID.
  Future<Round?> getRound(String id) {
    return (select(rounds)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// Watch rounds for real-time updates.
  Stream<List<Round>> watchRounds(String companyId) {
    return (select(rounds)
          ..where((r) => r.companyId.equals(companyId))
          ..orderBy([(r) => OrderingTerm.desc(r.displayOrder)]))
        .watch();
  }

  /// Insert or update a round.
  Future<void> upsertRound(RoundsCompanion round) {
    return into(rounds).insertOnConflictUpdate(round);
  }

  /// Delete a round.
  ///
  /// Deletes holdings issued in this round and clears references in other tables.
  Future<void> deleteRound(String id) async {
    await transaction(() async {
      // Delete holdings that were issued in this round
      await (delete(holdings)..where((h) => h.roundId.equals(id))).go();

      // Clear roundId references in option grants
      await (update(optionGrants)..where((o) => o.roundId.equals(id))).write(
        const OptionGrantsCompanion(roundId: Value(null)),
      );

      // Clear roundId references in warrants
      await (update(warrants)..where((w) => w.roundId.equals(id))).write(
        const WarrantsCompanion(roundId: Value(null)),
      );

      // Clear roundId references in ESOP pools
      await (update(esopPools)..where((p) => p.roundId.equals(id))).write(
        const EsopPoolsCompanion(roundId: Value(null)),
      );

      // Clear roundId references in capitalization events
      await (update(capitalizationEvents)..where((e) => e.roundId.equals(id)))
          .write(const CapitalizationEventsCompanion(roundId: Value(null)));

      // Now delete the round
      await (delete(rounds)..where((r) => r.id.equals(id))).go();
    });
  }

  // ===========================================================================
  // Holding Operations
  // ===========================================================================

  /// Get all holdings for a company.
  Future<List<Holding>> getHoldings(String companyId) {
    return (select(
      holdings,
    )..where((h) => h.companyId.equals(companyId))).get();
  }

  /// Get holdings for a specific stakeholder.
  Future<List<Holding>> getStakeholderHoldings(String stakeholderId) {
    return (select(
      holdings,
    )..where((h) => h.stakeholderId.equals(stakeholderId))).get();
  }

  /// Watch holdings for a specific stakeholder.
  Stream<List<Holding>> watchStakeholderHoldings(String stakeholderId) {
    return (select(
      holdings,
    )..where((h) => h.stakeholderId.equals(stakeholderId))).watch();
  }

  /// Watch holdings for real-time updates.
  Stream<List<Holding>> watchHoldings(String companyId) {
    return (select(
      holdings,
    )..where((h) => h.companyId.equals(companyId))).watch();
  }

  /// Insert or update a holding.
  Future<void> upsertHolding(HoldingsCompanion holding) {
    return into(holdings).insertOnConflictUpdate(holding);
  }

  /// Delete a holding.
  Future<void> deleteHolding(String id) async {
    await (delete(holdings)..where((h) => h.id.equals(id))).go();
  }

  /// Delete all holdings for a specific round (for reopening rounds).
  Future<int> deleteHoldingsByRound(String roundId) async {
    return (delete(holdings)..where((h) => h.roundId.equals(roundId))).go();
  }

  /// Delete orphan holdings (those without a roundId).
  /// Useful for cleaning up data integrity issues.
  Future<int> deleteOrphanHoldings(String companyId) async {
    return (delete(
      holdings,
    )..where((h) => h.companyId.equals(companyId) & h.roundId.isNull())).go();
  }

  /// Get holdings created by a specific round.
  Future<List<Holding>> getHoldingsByRound(String roundId) {
    return (select(holdings)..where((h) => h.roundId.equals(roundId))).get();
  }

  // ===========================================================================
  // Convertible Operations
  // ===========================================================================

  /// Get all convertibles for a company.
  Future<List<Convertible>> getConvertibles(String companyId) {
    return (select(convertibles)
          ..where((c) => c.companyId.equals(companyId))
          ..orderBy([(c) => OrderingTerm.desc(c.issueDate)]))
        .get();
  }

  /// Watch convertibles for real-time updates.
  Stream<List<Convertible>> watchConvertibles(String companyId) {
    return (select(convertibles)
          ..where((c) => c.companyId.equals(companyId))
          ..orderBy([(c) => OrderingTerm.desc(c.issueDate)]))
        .watch();
  }

  /// Get a convertible by ID.
  Future<Convertible?> getConvertible(String id) {
    return (select(
      convertibles,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update a convertible.
  Future<void> upsertConvertible(ConvertiblesCompanion convertible) {
    return into(convertibles).insertOnConflictUpdate(convertible);
  }

  /// Delete a convertible.
  Future<void> deleteConvertible(String id) async {
    await (delete(convertibles)..where((c) => c.id.equals(id))).go();
  }

  /// Get convertibles that were converted in a specific round.
  Future<List<Convertible>> getConvertiblesByConversionEvent(
    String conversionEventId,
  ) {
    return (select(
      convertibles,
    )..where((c) => c.conversionEventId.equals(conversionEventId))).get();
  }

  /// Revert converted convertibles back to outstanding (for reopening rounds).
  Future<void> revertConvertiblesByConversionEvent(
    String conversionEventId,
  ) async {
    await (update(
      convertibles,
    )..where((c) => c.conversionEventId.equals(conversionEventId))).write(
      const ConvertiblesCompanion(
        status: Value('outstanding'),
        conversionEventId: Value(null),
        convertedToShareClassId: Value(null),
        sharesReceived: Value(null),
      ),
    );
  }

  /// Activate pending convertibles for a round (pending → outstanding).
  Future<void> activatePendingConvertibles(String roundId) async {
    await (update(convertibles)
          ..where(
            (c) => c.roundId.equals(roundId) & c.status.equals('pending'),
          ))
        .write(const ConvertiblesCompanion(status: Value('outstanding')));
  }

  /// Set convertibles back to pending for a round (outstanding → pending).
  Future<void> deactivateConvertiblesForRound(String roundId) async {
    await (update(convertibles)
          ..where(
            (c) => c.roundId.equals(roundId) & c.status.equals('outstanding'),
          ))
        .write(const ConvertiblesCompanion(status: Value('pending')));
  }

  // ===========================================================================
  // MFN Upgrade Operations
  // ===========================================================================

  /// Get all MFN upgrades for a company.
  Future<List<MfnUpgrade>> getMfnUpgrades(String companyId) {
    return (select(mfnUpgrades)
          ..where((u) => u.companyId.equals(companyId))
          ..orderBy([(u) => OrderingTerm.desc(u.upgradeDate)]))
        .get();
  }

  /// Watch MFN upgrades for real-time updates.
  Stream<List<MfnUpgrade>> watchMfnUpgrades(String companyId) {
    return (select(mfnUpgrades)
          ..where((u) => u.companyId.equals(companyId))
          ..orderBy([(u) => OrderingTerm.desc(u.upgradeDate)]))
        .watch();
  }

  /// Get MFN upgrades for a specific target convertible.
  Future<List<MfnUpgrade>> getMfnUpgradesForTarget(String targetConvertibleId) {
    return (select(mfnUpgrades)
          ..where((u) => u.targetConvertibleId.equals(targetConvertibleId))
          ..orderBy([(u) => OrderingTerm.asc(u.upgradeDate)]))
        .get();
  }

  /// Get MFN upgrades triggered by a specific source convertible.
  Future<List<MfnUpgrade>> getMfnUpgradesFromSource(
    String sourceConvertibleId,
  ) {
    return (select(
      mfnUpgrades,
    )..where((u) => u.sourceConvertibleId.equals(sourceConvertibleId))).get();
  }

  /// Insert an MFN upgrade record.
  Future<void> insertMfnUpgrade(MfnUpgradesCompanion upgrade) {
    return into(mfnUpgrades).insert(upgrade);
  }

  /// Delete an MFN upgrade record.
  Future<void> deleteMfnUpgrade(String id) async {
    await (delete(mfnUpgrades)..where((u) => u.id.equals(id))).go();
  }

  /// Delete all MFN upgrades triggered by a source convertible (for reversal).
  Future<List<MfnUpgrade>> deleteMfnUpgradesFromSource(
    String sourceConvertibleId,
  ) async {
    // First get the upgrades so we can return them for reversal
    final upgrades = await getMfnUpgradesFromSource(sourceConvertibleId);
    // Then delete them
    await (delete(
      mfnUpgrades,
    )..where((u) => u.sourceConvertibleId.equals(sourceConvertibleId))).go();
    return upgrades;
  }

  // ===========================================================================
  // ESOP Pool Operations
  // ===========================================================================

  /// Get all ESOP pools for a company.
  Future<List<EsopPool>> getEsopPools(String companyId) {
    return (select(esopPools)
          ..where((p) => p.companyId.equals(companyId))
          ..orderBy([(p) => OrderingTerm.desc(p.establishedDate)]))
        .get();
  }

  /// Watch ESOP pools for real-time updates.
  Stream<List<EsopPool>> watchEsopPools(String companyId) {
    return (select(esopPools)
          ..where((p) => p.companyId.equals(companyId))
          ..orderBy([(p) => OrderingTerm.desc(p.establishedDate)]))
        .watch();
  }

  /// Get an ESOP pool by ID.
  Future<EsopPool?> getEsopPool(String id) {
    return (select(esopPools)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update an ESOP pool.
  Future<void> upsertEsopPool(EsopPoolsCompanion pool) {
    return into(esopPools).insertOnConflictUpdate(pool);
  }

  /// Delete an ESOP pool.
  Future<void> deleteEsopPool(String id) async {
    await (delete(esopPools)..where((p) => p.id.equals(id))).go();
  }

  /// Get option grants for a specific ESOP pool.
  Future<List<OptionGrant>> getOptionGrantsForPool(String poolId) {
    return (select(optionGrants)
          ..where((o) => o.esopPoolId.equals(poolId))
          ..orderBy([(o) => OrderingTerm.desc(o.grantDate)]))
        .get();
  }

  /// Watch option grants for a specific ESOP pool.
  Stream<List<OptionGrant>> watchOptionGrantsForPool(String poolId) {
    return (select(optionGrants)
          ..where((o) => o.esopPoolId.equals(poolId))
          ..orderBy([(o) => OrderingTerm.desc(o.grantDate)]))
        .watch();
  }

  // ===========================================================================
  // Option Grant Operations
  // ===========================================================================

  /// Get all option grants for a company.
  Future<List<OptionGrant>> getOptionGrants(String companyId) {
    return (select(optionGrants)
          ..where((o) => o.companyId.equals(companyId))
          ..orderBy([(o) => OrderingTerm.desc(o.grantDate)]))
        .get();
  }

  /// Watch option grants for real-time updates.
  Stream<List<OptionGrant>> watchOptionGrants(String companyId) {
    return (select(optionGrants)
          ..where((o) => o.companyId.equals(companyId))
          ..orderBy([(o) => OrderingTerm.desc(o.grantDate)]))
        .watch();
  }

  /// Get an option grant by ID.
  Future<OptionGrant?> getOptionGrant(String id) {
    return (select(
      optionGrants,
    )..where((o) => o.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update an option grant.
  Future<void> upsertOptionGrant(OptionGrantsCompanion grant) {
    return into(optionGrants).insertOnConflictUpdate(grant);
  }

  /// Delete an option grant.
  Future<void> deleteOptionGrant(String id) async {
    await (delete(optionGrants)..where((o) => o.id.equals(id))).go();
  }

  // ===========================================================================
  // Warrant Operations
  // ===========================================================================

  /// Get all warrants for a company.
  Future<List<Warrant>> getWarrants(String companyId) {
    return (select(warrants)
          ..where((w) => w.companyId.equals(companyId))
          ..orderBy([(w) => OrderingTerm.desc(w.issueDate)]))
        .get();
  }

  /// Watch warrants for real-time updates.
  Stream<List<Warrant>> watchWarrants(String companyId) {
    return (select(warrants)
          ..where((w) => w.companyId.equals(companyId))
          ..orderBy([(w) => OrderingTerm.desc(w.issueDate)]))
        .watch();
  }

  /// Get a single warrant by ID.
  Future<Warrant?> getWarrant(String id) {
    return (select(warrants)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update a warrant.
  Future<void> upsertWarrant(WarrantsCompanion warrant) {
    return into(warrants).insertOnConflictUpdate(warrant);
  }

  /// Delete a warrant.
  Future<void> deleteWarrant(String id) async {
    await (delete(warrants)..where((w) => w.id.equals(id))).go();
  }

  /// Activate pending warrants for a round (pending → active).
  Future<void> activatePendingWarrants(String roundId) async {
    await (update(warrants)
          ..where(
            (w) => w.roundId.equals(roundId) & w.status.equals('pending'),
          ))
        .write(const WarrantsCompanion(status: Value('active')));
  }

  /// Set warrants back to pending for a round (active → pending).
  Future<void> deactivateWarrantsForRound(String roundId) async {
    await (update(warrants)
          ..where((w) => w.roundId.equals(roundId) & w.status.equals('active')))
        .write(const WarrantsCompanion(status: Value('pending')));
  }

  // ===========================================================================
  // Vesting Schedule Operations
  // ===========================================================================

  /// Get all vesting schedules for a company.
  Future<List<VestingSchedule>> getVestingSchedules(String companyId) {
    return (select(
      vestingSchedules,
    )..where((v) => v.companyId.equals(companyId))).get();
  }

  /// Watch vesting schedules for real-time updates.
  Stream<List<VestingSchedule>> watchVestingSchedules(String companyId) {
    return (select(vestingSchedules)
          ..where((v) => v.companyId.equals(companyId))
          ..orderBy([(v) => OrderingTerm.asc(v.name)]))
        .watch();
  }

  /// Insert or update a vesting schedule.
  Future<void> upsertVestingSchedule(VestingSchedulesCompanion schedule) {
    return into(vestingSchedules).insertOnConflictUpdate(schedule);
  }

  /// Delete a vesting schedule.
  Future<void> deleteVestingSchedule(String id) async {
    await (delete(vestingSchedules)..where((v) => v.id.equals(id))).go();
  }

  // ===========================================================================
  // Valuation Operations
  // ===========================================================================

  /// Get all valuations for a company.
  Future<List<Valuation>> getValuations(String companyId) {
    return (select(valuations)
          ..where((v) => v.companyId.equals(companyId))
          ..orderBy([(v) => OrderingTerm.desc(v.date)]))
        .get();
  }

  /// Watch valuations for real-time updates.
  Stream<List<Valuation>> watchValuations(String companyId) {
    return (select(valuations)
          ..where((v) => v.companyId.equals(companyId))
          ..orderBy([(v) => OrderingTerm.desc(v.date)]))
        .watch();
  }

  /// Get a single valuation by ID.
  Future<Valuation?> getValuation(String id) {
    return (select(
      valuations,
    )..where((v) => v.id.equals(id))).getSingleOrNull();
  }

  /// Insert a valuation.
  Future<void> insertValuation(ValuationsCompanion valuation) {
    return into(valuations).insert(valuation);
  }

  /// Insert or update a valuation.
  Future<void> upsertValuation(ValuationsCompanion valuation) {
    return into(valuations).insertOnConflictUpdate(valuation);
  }

  /// Delete a valuation.
  Future<void> deleteValuation(String id) async {
    await (delete(valuations)..where((v) => v.id.equals(id))).go();
  }

  // ===========================================================================
  // Capitalization Event Operations
  // ===========================================================================

  /// Get all events for a company.
  Future<List<CapitalizationEvent>> getEvents(String companyId) {
    return (select(capitalizationEvents)
          ..where((e) => e.companyId.equals(companyId))
          ..orderBy([(e) => OrderingTerm.asc(e.effectiveDate)]))
        .get();
  }

  /// Watch events for real-time updates.
  Stream<List<CapitalizationEvent>> watchEvents(String companyId) {
    return (select(capitalizationEvents)
          ..where((e) => e.companyId.equals(companyId))
          ..orderBy([(e) => OrderingTerm.asc(e.effectiveDate)]))
        .watch();
  }

  /// Insert an event (events are immutable, no updates).
  Future<void> insertEvent(CapitalizationEventsCompanion event) {
    return into(capitalizationEvents).insert(event);
  }

  // ===========================================================================
  // Saved Scenario Operations
  // ===========================================================================

  /// Get all saved scenarios for a company.
  Future<List<SavedScenario>> getSavedScenarios(String companyId) {
    return (select(savedScenarios)
          ..where((s) => s.companyId.equals(companyId))
          ..orderBy([(s) => OrderingTerm.desc(s.updatedAt)]))
        .get();
  }

  /// Watch saved scenarios for real-time updates.
  Stream<List<SavedScenario>> watchSavedScenarios(String companyId) {
    return (select(savedScenarios)
          ..where((s) => s.companyId.equals(companyId))
          ..orderBy([(s) => OrderingTerm.desc(s.updatedAt)]))
        .watch();
  }

  /// Insert or update a saved scenario.
  Future<void> upsertSavedScenario(SavedScenariosCompanion scenario) {
    return into(savedScenarios).insertOnConflictUpdate(scenario);
  }

  /// Delete a saved scenario.
  Future<void> deleteSavedScenario(String id) async {
    await (delete(savedScenarios)..where((s) => s.id.equals(id))).go();
  }

  // ===========================================================================
  // Transfer Operations (Secondary Sales)
  // ===========================================================================

  /// Get all transfers for a company.
  Future<List<Transfer>> getTransfers(String companyId) {
    return (select(transfers)
          ..where((t) => t.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Watch transfers for real-time updates.
  Stream<List<Transfer>> watchTransfers(String companyId) {
    return (select(transfers)
          ..where((t) => t.companyId.equals(companyId))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// Get transfers for a specific stakeholder (as seller or buyer).
  Future<List<Transfer>> getStakeholderTransfers(String stakeholderId) {
    return (select(transfers)
          ..where(
            (t) =>
                t.sellerStakeholderId.equals(stakeholderId) |
                t.buyerStakeholderId.equals(stakeholderId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Get a single transfer by ID.
  Future<Transfer?> getTransfer(String id) {
    return (select(transfers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update a transfer.
  Future<void> upsertTransfer(TransfersCompanion transfer) {
    return into(transfers).insertOnConflictUpdate(transfer);
  }

  /// Delete a transfer.
  Future<void> deleteTransfer(String id) async {
    await (delete(transfers)..where((t) => t.id.equals(id))).go();
  }

  /// Update a holding's share count (for transfers).
  Future<void> updateHoldingShares(String id, int newShareCount) async {
    await (update(holdings)..where((h) => h.id.equals(id))).write(
      HoldingsCompanion(
        shareCount: Value(newShareCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

/// Opens a connection to the database.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'simple_cap.db'));
    return NativeDatabase.createInBackground(file);
  });
}
