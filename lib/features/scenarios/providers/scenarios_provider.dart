import 'package:flutter/foundation.dart';
import '../../core/models/share_class.dart';

/// Result model for exit waterfall calculations
class WaterfallRow {
  final String investorId;
  final String investorName;
  final double shareOwnership;
  final double liquidationPreference;
  final double participating;
  final double totalProceeds;
  final double roi;

  const WaterfallRow({
    required this.investorId,
    required this.investorName,
    required this.shareOwnership,
    required this.liquidationPreference,
    required this.participating,
    required this.totalProceeds,
    required this.roi,
  });
}

/// Provider for scenario analysis and modeling.
///
/// This provider manages:
/// - Dilution calculations
/// - Exit waterfall analysis
/// - New round simulations
/// - Pro-rata calculations
///
/// It reads data from CoreCapTableProvider for calculations
/// but doesn't modify core data.
class ScenariosProvider extends ChangeNotifier {
  // Cache for scenario results
  Map<String, double> _lastDilutionResults = {};
  List<WaterfallRow> _lastWaterfallResults = [];

  // Getters for cached results
  Map<String, double> get lastDilutionResults =>
      Map.unmodifiable(_lastDilutionResults);
  List<WaterfallRow> get lastWaterfallResults =>
      List.unmodifiable(_lastWaterfallResults);

  /// Calculate dilution from a new round
  Map<String, double> calculateDilutionFromNewRound({
    required double newShares,
    required int currentTotalShares,
    required Map<String, int> currentSharesByInvestor,
  }) {
    if (newShares <= 0 || currentTotalShares == 0) return {};

    final newTotal = currentTotalShares + newShares;
    final Map<String, double> dilution = {};

    for (final entry in currentSharesByInvestor.entries) {
      final currentOwnership = (entry.value / currentTotalShares) * 100;
      final newOwnership = (entry.value / newTotal) * 100;
      dilution[entry.key] = currentOwnership - newOwnership;
    }

    _lastDilutionResults = dilution;
    notifyListeners();
    return dilution;
  }

  /// Calculate new shares from investment amount and valuation
  int calculateNewSharesFromInvestment({
    required double investmentAmount,
    required double preMoneyValuation,
    required int currentShares,
  }) {
    if (preMoneyValuation <= 0 || investmentAmount <= 0) return 0;

    final postMoney = preMoneyValuation + investmentAmount;
    final newOwnership = investmentAmount / postMoney;

    if (newOwnership >= 1) return 0;

    return (currentShares * (newOwnership / (1 - newOwnership))).round();
  }

  /// Calculate ownership percentage for new investor
  double calculateNewInvestorOwnership({
    required double newShares,
    required int currentShares,
  }) {
    if (newShares <= 0) return 0;
    final newTotal = currentShares + newShares;
    return (newShares / newTotal) * 100;
  }

  /// Calculate share price from investment
  double calculateImpliedSharePrice({
    required double investmentAmount,
    required double newShares,
  }) {
    if (newShares <= 0) return 0;
    return investmentAmount / newShares;
  }

  /// Calculate exit waterfall
  ///
  /// This calculates how proceeds are distributed at exit based on:
  /// - Liquidation preferences
  /// - Participation rights
  /// - Pro-rata share ownership
  List<WaterfallRow> calculateExitWaterfall({
    required double exitValuation,
    required List<WaterfallInvestorData> investors,
    required List<ShareClass> shareClasses,
    required int totalShares,
  }) {
    if (exitValuation <= 0 || totalShares == 0) return [];

    final results = <WaterfallRow>[];
    double remainingProceeds = exitValuation;

    // Phase 1: Pay liquidation preferences
    final preferencePayouts = <String, double>{};

    // Sort by seniority (higher seniority paid first)
    final sortedClasses = List<ShareClass>.from(shareClasses)
      ..sort((a, b) => b.seniority.compareTo(a.seniority));

    for (final shareClass in sortedClasses) {
      if (remainingProceeds <= 0) break;
      if (shareClass.liquidationPreference <= 0) continue;

      for (final investor in investors) {
        final sharesInClass = investor.sharesByClass[shareClass.id] ?? 0;
        if (sharesInClass <= 0) continue;

        // Calculate preference amount
        final preferenceMultiple = shareClass.liquidationPreference;
        final investmentInClass =
            investor.investmentByClass[shareClass.id] ?? 0;
        final preferenceAmount = investmentInClass * preferenceMultiple;

        final actualPayout = preferenceAmount.clamp(0, remainingProceeds);
        preferencePayouts[investor.id] =
            (preferencePayouts[investor.id] ?? 0) + actualPayout;
        remainingProceeds -= actualPayout;
      }
    }

    // Phase 2: Distribute remaining proceeds pro-rata
    final proRataPayouts = <String, double>{};

    if (remainingProceeds > 0) {
      for (final investor in investors) {
        final ownershipPercent = investor.totalShares / totalShares;
        final proRataPayout = remainingProceeds * ownershipPercent;
        proRataPayouts[investor.id] = proRataPayout;
      }
    }

    // Build results
    for (final investor in investors) {
      final ownership = (investor.totalShares / totalShares) * 100;
      final preference = preferencePayouts[investor.id] ?? 0;
      final proRata = proRataPayouts[investor.id] ?? 0;
      final total = preference + proRata;
      final roi = investor.totalInvestment > 0
          ? (total / investor.totalInvestment)
          : 0.0;

      results.add(
        WaterfallRow(
          investorId: investor.id,
          investorName: investor.name,
          shareOwnership: ownership,
          liquidationPreference: preference,
          participating: proRata,
          totalProceeds: total,
          roi: roi,
        ),
      );
    }

    // Sort by total proceeds descending
    results.sort((a, b) => b.totalProceeds.compareTo(a.totalProceeds));

    _lastWaterfallResults = results;
    notifyListeners();
    return results;
  }

  /// Calculate pro-rata allocation for an investor in a new round
  double calculateProRataAllocation({
    required double ownershipPercent,
    required double newRoundSize,
  }) {
    return newRoundSize * (ownershipPercent / 100);
  }

  /// Simulate a new round and return post-money cap table
  SimulationResult simulateNewRound({
    required String roundName,
    required double raiseAmount,
    required double preMoneyValuation,
    required double esopExpansionPercent,
    required int currentShares,
    required int currentEsopPool,
    required Map<String, int> currentSharesByInvestor,
    required Map<String, String> investorNames,
  }) {
    final postMoney = preMoneyValuation + raiseAmount;
    final newInvestorOwnership = raiseAmount / postMoney;
    final newShares =
        (currentShares * (newInvestorOwnership / (1 - newInvestorOwnership)))
            .round();

    // ESOP expansion
    final esopExpansionShares = esopExpansionPercent > 0
        ? ((currentShares + newShares) * (esopExpansionPercent / 100)).round()
        : 0;

    final totalNewShares = currentShares + newShares + esopExpansionShares;

    final results = <SimulationInvestorResult>[];

    // Existing investors
    for (final entry in currentSharesByInvestor.entries) {
      final currentOwnership = entry.value / currentShares * 100;
      final newOwnership = entry.value / totalNewShares * 100;
      results.add(
        SimulationInvestorResult(
          investorId: entry.key,
          investorName: investorNames[entry.key] ?? 'Unknown',
          currentShares: entry.value,
          newShares: entry.value,
          currentOwnership: currentOwnership,
          newOwnership: newOwnership,
          dilution: currentOwnership - newOwnership,
        ),
      );
    }

    // New investor
    results.add(
      SimulationInvestorResult(
        investorId: '__NEW_INVESTOR__',
        investorName: 'New Investor',
        currentShares: 0,
        newShares: newShares,
        currentOwnership: 0,
        newOwnership: newShares / totalNewShares * 100,
        dilution: 0,
      ),
    );

    // ESOP if expanded
    if (esopExpansionShares > 0) {
      final currentEsopOwnership = currentEsopPool / currentShares * 100;
      final newEsopTotal = currentEsopPool + esopExpansionShares;
      final newEsopOwnership = newEsopTotal / totalNewShares * 100;
      results.add(
        SimulationInvestorResult(
          investorId: '__ESOP__',
          investorName: 'ESOP Pool',
          currentShares: currentEsopPool,
          newShares: newEsopTotal,
          currentOwnership: currentEsopOwnership,
          newOwnership: newEsopOwnership,
          dilution: currentEsopOwnership - newEsopOwnership,
        ),
      );
    }

    return SimulationResult(
      roundName: roundName,
      raiseAmount: raiseAmount,
      preMoneyValuation: preMoneyValuation,
      postMoneyValuation: postMoney,
      pricePerShare: preMoneyValuation / currentShares,
      newShares: newShares,
      esopExpansionShares: esopExpansionShares,
      totalShares: totalNewShares,
      investors: results,
    );
  }

  void clear() {
    _lastDilutionResults = {};
    _lastWaterfallResults = [];
    notifyListeners();
  }
}

/// Helper class for waterfall calculations
class WaterfallInvestorData {
  final String id;
  final String name;
  final int totalShares;
  final double totalInvestment;
  final Map<String, int> sharesByClass;
  final Map<String, double> investmentByClass;

  const WaterfallInvestorData({
    required this.id,
    required this.name,
    required this.totalShares,
    required this.totalInvestment,
    required this.sharesByClass,
    required this.investmentByClass,
  });
}

/// Result of a round simulation
class SimulationResult {
  final String roundName;
  final double raiseAmount;
  final double preMoneyValuation;
  final double postMoneyValuation;
  final double pricePerShare;
  final int newShares;
  final int esopExpansionShares;
  final int totalShares;
  final List<SimulationInvestorResult> investors;

  const SimulationResult({
    required this.roundName,
    required this.raiseAmount,
    required this.preMoneyValuation,
    required this.postMoneyValuation,
    required this.pricePerShare,
    required this.newShares,
    required this.esopExpansionShares,
    required this.totalShares,
    required this.investors,
  });
}

/// Per-investor result in a simulation
class SimulationInvestorResult {
  final String investorId;
  final String investorName;
  final int currentShares;
  final int newShares;
  final double currentOwnership;
  final double newOwnership;
  final double dilution;

  const SimulationInvestorResult({
    required this.investorId,
    required this.investorName,
    required this.currentShares,
    required this.newShares,
    required this.currentOwnership,
    required this.newOwnership,
    required this.dilution,
  });
}
