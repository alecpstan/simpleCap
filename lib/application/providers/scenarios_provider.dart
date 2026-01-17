import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'holdings_provider.dart';
import 'stakeholders_provider.dart';

part 'scenarios_provider.g.dart';

// =============================================================================
// Dilution Calculator
// =============================================================================

/// Input parameters for dilution modeling.
class DilutionScenario {
  final double newInvestment;
  final double preMoneyValuation;
  final double optionPoolIncrease; // As percentage of post-money
  final bool includeUnconvertedSafes;
  final bool includeUnexercisedOptions;

  const DilutionScenario({
    required this.newInvestment,
    required this.preMoneyValuation,
    this.optionPoolIncrease = 0,
    this.includeUnconvertedSafes = true,
    this.includeUnexercisedOptions = true,
  });

  double get postMoneyValuation => preMoneyValuation + newInvestment;
  double get pricePerShare => postMoneyValuation / 1000000; // Placeholder
}

/// Result of dilution calculation for a single stakeholder.
class DilutionResult {
  final String stakeholderId;
  final String stakeholderName;
  final int currentShares;
  final double currentOwnership;
  final int postRoundShares;
  final double postRoundOwnership;
  final double dilutionPercent;

  const DilutionResult({
    required this.stakeholderId,
    required this.stakeholderName,
    required this.currentShares,
    required this.currentOwnership,
    required this.postRoundShares,
    required this.postRoundOwnership,
    required this.dilutionPercent,
  });
}

/// Summary of a dilution scenario.
class DilutionSummary {
  final int currentTotalShares;
  final int newSharesIssued;
  final int postRoundTotalShares;
  final double newInvestorOwnership;
  final double optionPoolOwnership;
  final List<DilutionResult> stakeholderResults;

  const DilutionSummary({
    required this.currentTotalShares,
    required this.newSharesIssued,
    required this.postRoundTotalShares,
    required this.newInvestorOwnership,
    required this.optionPoolOwnership,
    required this.stakeholderResults,
  });
}

/// Provider for dilution calculations.
@riverpod
Future<DilutionSummary?> calculateDilution(
  CalculateDilutionRef ref,
  DilutionScenario scenario,
) async {
  final ownership = await ref.watch(ownershipSummaryProvider.future);
  final stakeholders = await ref.watch(stakeholdersStreamProvider.future);
  final holdings = await ref.watch(holdingsStreamProvider.future);

  if (ownership.totalIssuedShares == 0) return null;

  // Calculate current shares per stakeholder
  final stakeholderShares = <String, int>{};
  for (final holding in holdings) {
    stakeholderShares[holding.stakeholderId] =
        (stakeholderShares[holding.stakeholderId] ?? 0) + holding.shareCount;
  }

  // Calculate new shares to issue
  final pricePerShare =
      scenario.preMoneyValuation / ownership.totalIssuedShares;
  final newSharesForInvestor = (scenario.newInvestment / pricePerShare).round();

  // Calculate option pool shares if expanding
  final postMoneyShares = ownership.totalIssuedShares + newSharesForInvestor;
  final optionPoolShares = scenario.optionPoolIncrease > 0
      ? (postMoneyShares *
                scenario.optionPoolIncrease /
                (100 - scenario.optionPoolIncrease))
            .round()
      : 0;

  final totalNewShares = newSharesForInvestor + optionPoolShares;
  final postRoundTotalShares = ownership.totalIssuedShares + totalNewShares;

  // Calculate dilution for each stakeholder
  final results = <DilutionResult>[];
  for (final stakeholder in stakeholders) {
    final currentShares = stakeholderShares[stakeholder.id] ?? 0;
    if (currentShares == 0) continue;

    final currentOwnership = currentShares / ownership.totalIssuedShares * 100;
    final postRoundOwnership = currentShares / postRoundTotalShares * 100;
    final dilutionPercent =
        ((currentOwnership - postRoundOwnership) / currentOwnership) * 100;

    results.add(
      DilutionResult(
        stakeholderId: stakeholder.id,
        stakeholderName: stakeholder.name,
        currentShares: currentShares,
        currentOwnership: currentOwnership,
        postRoundShares: currentShares, // Shares don't change, just ownership
        postRoundOwnership: postRoundOwnership,
        dilutionPercent: dilutionPercent,
      ),
    );
  }

  // Sort by current ownership descending
  results.sort((a, b) => b.currentOwnership.compareTo(a.currentOwnership));

  return DilutionSummary(
    currentTotalShares: ownership.totalIssuedShares,
    newSharesIssued: totalNewShares,
    postRoundTotalShares: postRoundTotalShares,
    newInvestorOwnership: newSharesForInvestor / postRoundTotalShares * 100,
    optionPoolOwnership: optionPoolShares / postRoundTotalShares * 100,
    stakeholderResults: results,
  );
}

// =============================================================================
// Exit Waterfall Calculator
// =============================================================================

/// Input parameters for exit waterfall modeling.
class ExitScenario {
  final double exitValuation;
  final double transactionCosts; // As percentage
  final bool isAcquisition; // vs IPO

  const ExitScenario({
    required this.exitValuation,
    this.transactionCosts = 2.0,
    this.isAcquisition = true,
  });

  double get netProceeds => exitValuation * (1 - transactionCosts / 100);
}

/// Result of waterfall calculation for a single stakeholder.
class WaterfallResult {
  final String stakeholderId;
  final String stakeholderName;
  final String shareClassName;
  final int shares;
  final double ownershipPercent;
  final double liquidationPreference;
  final double participationAmount;
  final double totalProceeds;
  final double returnMultiple;

  const WaterfallResult({
    required this.stakeholderId,
    required this.stakeholderName,
    required this.shareClassName,
    required this.shares,
    required this.ownershipPercent,
    required this.liquidationPreference,
    required this.participationAmount,
    required this.totalProceeds,
    required this.returnMultiple,
  });
}

/// Summary of an exit waterfall.
class WaterfallSummary {
  final double exitValuation;
  final double netProceeds;
  final double totalLiquidationPreferences;
  final double remainingForCommon;
  final List<WaterfallResult> stakeholderResults;

  const WaterfallSummary({
    required this.exitValuation,
    required this.netProceeds,
    required this.totalLiquidationPreferences,
    required this.remainingForCommon,
    required this.stakeholderResults,
  });
}

/// Provider for exit waterfall calculations.
@riverpod
Future<WaterfallSummary?> calculateWaterfall(
  CalculateWaterfallRef ref,
  ExitScenario scenario,
) async {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return null;

  final db = ref.watch(databaseProvider);
  final holdings = await ref.watch(holdingsStreamProvider.future);
  final stakeholders = await ref.watch(stakeholdersStreamProvider.future);
  final shareClasses = await db.getShareClasses(companyId);

  if (holdings.isEmpty) return null;

  final netProceeds = scenario.netProceeds;

  // Build share class lookup
  final classMap = {for (final c in shareClasses) c.id: c};

  // Calculate total shares and liquidation preferences
  int totalShares = 0;
  double totalLiqPref = 0;

  final holdingsByStakeholder = <String, List<Holding>>{};
  for (final h in holdings) {
    totalShares += h.shareCount;
    holdingsByStakeholder.putIfAbsent(h.stakeholderId, () => []).add(h);

    final shareClass = classMap[h.shareClassId];
    if (shareClass != null && shareClass.type.contains('preference')) {
      totalLiqPref += h.costBasis * shareClass.liquidationPreference;
    }
  }

  // Simple waterfall: liquidation preferences first, then pro-rata
  final results = <WaterfallResult>[];

  // Build stakeholder lookup
  final stakeholderMap = {for (final s in stakeholders) s.id: s};

  for (final entry in holdingsByStakeholder.entries) {
    final stakeholder = stakeholderMap[entry.key];
    if (stakeholder == null) continue;

    double stakeholderLiqPref = 0;
    double stakeholderShares = 0;

    for (final h in entry.value) {
      stakeholderShares += h.shareCount;
      final shareClass = classMap[h.shareClassId];
      if (shareClass != null && shareClass.type.contains('preference')) {
        stakeholderLiqPref += h.costBasis * shareClass.liquidationPreference;
      }
    }

    final ownershipPercent = stakeholderShares / totalShares * 100;

    // Calculate proceeds (simplified - liq pref or pro-rata, whichever is higher)
    final proRataAmount = netProceeds * (stakeholderShares / totalShares);
    final proceeds = stakeholderLiqPref > 0
        ? (stakeholderLiqPref > proRataAmount
              ? stakeholderLiqPref
              : proRataAmount)
        : proRataAmount;

    final costBasis = entry.value.fold<double>(
      0,
      (sum, h) => sum + h.costBasis,
    );
    final returnMultiple = costBasis > 0 ? proceeds / costBasis : 0.0;

    results.add(
      WaterfallResult(
        stakeholderId: entry.key,
        stakeholderName: stakeholder.name,
        shareClassName: entry.value.length == 1
            ? (classMap[entry.value.first.shareClassId]?.name ?? 'Unknown')
            : 'Multiple',
        shares: stakeholderShares.round(),
        ownershipPercent: ownershipPercent,
        liquidationPreference: stakeholderLiqPref,
        participationAmount: 0, // Simplified - not calculating participation
        totalProceeds: proceeds,
        returnMultiple: returnMultiple.toDouble(),
      ),
    );
  }

  // Sort by proceeds descending
  results.sort((a, b) => b.totalProceeds.compareTo(a.totalProceeds));

  return WaterfallSummary(
    exitValuation: scenario.exitValuation,
    netProceeds: netProceeds,
    totalLiquidationPreferences: totalLiqPref,
    remainingForCommon: netProceeds - totalLiqPref,
    stakeholderResults: results,
  );
}

// =============================================================================
// Saved Scenarios
// =============================================================================

/// Stream of saved scenarios for the current company.
@riverpod
Stream<List<SavedScenario>> savedScenariosStream(SavedScenariosStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchSavedScenarios(companyId);
}
