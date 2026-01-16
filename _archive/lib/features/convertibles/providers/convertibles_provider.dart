import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/convertible_instrument.dart';
import '../../core/models/transaction.dart';
import '../../../shared/utils/helpers.dart';

/// Represents a detected MFN upgrade opportunity.
///
/// When a convertible with MFN clause finds another convertible
/// with better terms, this class captures what would change.
class MfnUpgrade {
  /// The convertible that has MFN and could be upgraded
  final ConvertibleInstrument target;

  /// The convertible with better terms (the source of the upgrade)
  final ConvertibleInstrument source;

  /// New discount percent if upgrading (null if no improvement)
  final double? newDiscountPercent;

  /// New valuation cap if upgrading (null if no improvement)
  final double? newValuationCap;

  /// Whether pro-rata rights would be added
  final bool addsProRata;

  const MfnUpgrade({
    required this.target,
    required this.source,
    this.newDiscountPercent,
    this.newValuationCap,
    this.addsProRata = false,
  });

  /// Whether this upgrade would change anything
  bool get hasUpgrade =>
      newDiscountPercent != null || newValuationCap != null || addsProRata;

  /// Description of what would change
  String get upgradeDescription {
    final parts = <String>[];
    if (newDiscountPercent != null) {
      final oldDiscount = (target.discountPercent ?? 0) * 100;
      final newDiscount = newDiscountPercent! * 100;
      parts.add('Discount: ${oldDiscount.toStringAsFixed(0)}% → ${newDiscount.toStringAsFixed(0)}%');
    }
    if (newValuationCap != null) {
      final oldCap = target.valuationCap ?? double.infinity;
      parts.add('Cap: ${Formatters.compactCurrencyString(oldCap)} → ${Formatters.compactCurrencyString(newValuationCap!)}');
    }
    if (addsProRata) {
      parts.add('Adds Pro-Rata Rights');
    }
    return parts.join(', ');
  }
}

/// Provider for convertible instruments management.
///
/// This provider manages:
/// - Convertible instruments (SAFEs, Convertible Notes) CRUD
/// - Conversion to shares
/// - Outstanding convertibles tracking
///
/// It requires access to CoreCapTableProvider for:
/// - Round data (for conversion calculations)
/// - Transaction creation (for conversions)
/// - Share count data
class ConvertiblesProvider extends ChangeNotifier {
  List<ConvertibleInstrument> _convertibles = [];

  // Track if we've been initialized with data from core
  bool _initialized = false;

  // Callback for saving data (injected by parent)
  Future<void> Function()? _onSave;

  // Callback for creating transactions (injected by parent)
  Future<void> Function(Transaction)? _onAddTransaction;

  ConvertiblesProvider();

  /// Update this provider with data and callbacks from CoreCapTableProvider.
  /// Called by ChangeNotifierProxyProvider when core provider updates.
  void updateFromCore({
    required List<ConvertibleInstrument> convertibles,
    required Future<void> Function() onSave,
    required Future<void> Function(Transaction) onAddTransaction,
  }) {
    // Store callback references
    _onSave = onSave;
    _onAddTransaction = onAddTransaction;

    // Only load data on first initialization to avoid overwriting local changes
    if (!_initialized) {
      _convertibles = List.from(convertibles);
      _initialized = true;
      notifyListeners();
    }
  }

  /// Check if provider has been initialized with core data
  bool get isInitialized => _initialized;

  // === Getters ===

  List<ConvertibleInstrument> get convertibles =>
      List.unmodifiable(_convertibles);

  List<ConvertibleInstrument> get outstandingConvertibles {
    return _convertibles
        .where((c) => c.status == ConvertibleStatus.outstanding)
        .toList();
  }

  /// Convertibles that are pending conversion (in a draft round)
  List<ConvertibleInstrument> get pendingConversions {
    return _convertibles
        .where((c) => c.status == ConvertibleStatus.pendingConversion)
        .toList();
  }

  /// Shares that would be issued if all convertibles converted
  int calculateConvertibleShares(
    int totalCurrentShares,
    double latestValuation,
  ) {
    if (totalCurrentShares == 0) return 0;

    return _convertibles
        .where((c) => c.status == ConvertibleStatus.outstanding)
        .fold(0, (sum, c) {
          double pricePerShare;

          if (c.valuationCap != null && c.valuationCap! > 0) {
            pricePerShare = c.valuationCap! / totalCurrentShares;
          } else if (latestValuation > 0) {
            pricePerShare = latestValuation / totalCurrentShares;
            if (c.discountPercent != null && c.discountPercent! > 0) {
              pricePerShare *= (1 - c.discountPercent! / 100);
            }
          } else {
            return sum;
          }

          if (pricePerShare <= 0) return sum;
          return sum + (c.convertibleAmount / pricePerShare).round();
        });
  }

  // === Convertible CRUD ===

  Future<void> addConvertible(ConvertibleInstrument convertible) async {
    _convertibles.add(convertible);
    await _onSave?.call();
    notifyListeners();
  }

  Future<void> updateConvertible(ConvertibleInstrument convertible) async {
    final index = _convertibles.indexWhere((c) => c.id == convertible.id);
    if (index != -1) {
      _convertibles[index] = convertible;
      await _onSave?.call();
      notifyListeners();
    }
  }

  Future<void> deleteConvertible(String id) async {
    _convertibles.removeWhere((c) => c.id == id);
    await _onSave?.call();
    notifyListeners();
  }

  ConvertibleInstrument? getConvertibleById(String id) {
    try {
      return _convertibles.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ConvertibleInstrument> getConvertiblesByInvestor(String investorId) {
    return _convertibles.where((c) => c.investorId == investorId).toList();
  }

  // === MFN Detection & Upgrade ===

  /// Detect all possible MFN upgrades for outstanding convertibles.
  ///
  /// MFN (Most Favored Nation) allows early investors to upgrade their terms
  /// if later investors get better terms on similar instruments.
  ///
  /// Returns a list of [MfnUpgrade] objects describing what would change.
  List<MfnUpgrade> detectMfnUpgrades() {
    final upgrades = <MfnUpgrade>[];

    // Get outstanding convertibles with MFN that haven't been upgraded yet
    final mfnEligible = _convertibles.where((c) =>
        c.status == ConvertibleStatus.outstanding &&
        c.hasMFN &&
        !c.mfnWasApplied).toList();

    // Get all outstanding convertibles (potential sources of better terms)
    final allOutstanding = _convertibles
        .where((c) => c.status == ConvertibleStatus.outstanding)
        .toList();

    for (final target in mfnEligible) {
      MfnUpgrade? bestUpgrade;

      for (final source in allOutstanding) {
        // Skip self-comparison
        if (source.id == target.id) continue;

        // MFN typically applies to instruments issued AFTER the MFN holder
        if (!source.issueDate.isAfter(target.issueDate)) continue;

        // Check for better terms
        final upgrade = _compareMfnTerms(target, source);
        if (upgrade != null && upgrade.hasUpgrade) {
          // Keep the most favorable upgrade (most improvements)
          if (bestUpgrade == null || _isBetterUpgrade(upgrade, bestUpgrade)) {
            bestUpgrade = upgrade;
          }
        }
      }

      if (bestUpgrade != null) {
        upgrades.add(bestUpgrade);
      }
    }

    return upgrades;
  }

  /// Compare terms between MFN holder and a later instrument.
  /// Returns an MfnUpgrade if source has any better terms.
  MfnUpgrade? _compareMfnTerms(
    ConvertibleInstrument target,
    ConvertibleInstrument source,
  ) {
    double? newDiscount;
    double? newCap;
    bool addsProRata = false;

    // Check discount: higher discount is better for investor
    final targetDiscount = target.discountPercent ?? 0;
    final sourceDiscount = source.discountPercent ?? 0;
    if (sourceDiscount > targetDiscount) {
      newDiscount = sourceDiscount;
    }

    // Check cap: lower cap is better for investor
    final targetCap = target.valuationCap;
    final sourceCap = source.valuationCap;
    if (sourceCap != null) {
      if (targetCap == null || sourceCap < targetCap) {
        newCap = sourceCap;
      }
    }

    // Check pro-rata: gaining rights is better
    if (source.hasProRata && !target.hasProRata) {
      addsProRata = true;
    }

    // Only return upgrade if there's something to improve
    if (newDiscount != null || newCap != null || addsProRata) {
      return MfnUpgrade(
        target: target,
        source: source,
        newDiscountPercent: newDiscount,
        newValuationCap: newCap,
        addsProRata: addsProRata,
      );
    }

    return null;
  }

  /// Determine if upgrade A is better than upgrade B (more improvements).
  bool _isBetterUpgrade(MfnUpgrade a, MfnUpgrade b) {
    int scoreA = 0;
    int scoreB = 0;

    if (a.newDiscountPercent != null) scoreA++;
    if (b.newDiscountPercent != null) scoreB++;
    if (a.newValuationCap != null) scoreA++;
    if (b.newValuationCap != null) scoreB++;
    if (a.addsProRata) scoreA++;
    if (b.addsProRata) scoreB++;

    if (scoreA != scoreB) return scoreA > scoreB;

    // If same number of improvements, prefer higher discount
    final discountA = a.newDiscountPercent ?? 0;
    final discountB = b.newDiscountPercent ?? 0;
    if (discountA != discountB) return discountA > discountB;

    // Then prefer lower cap
    final capA = a.newValuationCap ?? double.infinity;
    final capB = b.newValuationCap ?? double.infinity;
    return capA < capB;
  }

  /// Whether there are any pending MFN upgrades available.
  bool get hasPendingMfnUpgrades => detectMfnUpgrades().isNotEmpty;

  /// Count of convertibles eligible for MFN upgrade.
  int get pendingMfnUpgradeCount => detectMfnUpgrades().length;

  /// Apply a single MFN upgrade.
  ///
  /// This updates the target convertible with better terms from the source,
  /// adding an upgrade record to the history for proper audit trail and reversal.
  Future<void> applyMfnUpgrade(MfnUpgrade upgrade) async {
    final index = _convertibles.indexWhere((c) => c.id == upgrade.target.id);
    if (index == -1) return;

    final target = _convertibles[index];

    // Create upgrade record capturing the change
    final upgradeRecord = MfnUpgradeRecord(
      id: const Uuid().v4(),
      upgradeDate: DateTime.now(),
      sourceConvertibleId: upgrade.source.id,
      previousDiscountPercent: target.discountPercent,
      previousValuationCap: target.valuationCap,
      previousHasProRata: target.hasProRata,
      newDiscountPercent: upgrade.newDiscountPercent ?? target.discountPercent,
      newValuationCap: upgrade.newValuationCap ?? target.valuationCap,
      newHasProRata: upgrade.addsProRata ? true : target.hasProRata,
    );

    // Add to history and apply new terms
    _convertibles[index] = target.copyWith(
      discountPercent: upgrade.newDiscountPercent ?? target.discountPercent,
      valuationCap: upgrade.newValuationCap ?? target.valuationCap,
      hasProRata: upgrade.addsProRata ? true : target.hasProRata,
      mfnUpgradeHistory: [...target.mfnUpgradeHistory, upgradeRecord],
    );

    await _onSave?.call();
    notifyListeners();
  }

  /// Apply all pending MFN upgrades in one action.
  ///
  /// Returns the number of upgrades applied.
  Future<int> applyAllMfnUpgrades() async {
    final upgrades = detectMfnUpgrades();
    if (upgrades.isEmpty) return 0;

    for (final upgrade in upgrades) {
      final index = _convertibles.indexWhere((c) => c.id == upgrade.target.id);
      if (index == -1) continue;

      final target = _convertibles[index];

      // Create upgrade record
      final upgradeRecord = MfnUpgradeRecord(
        id: const Uuid().v4(),
        upgradeDate: DateTime.now(),
        sourceConvertibleId: upgrade.source.id,
        previousDiscountPercent: target.discountPercent,
        previousValuationCap: target.valuationCap,
        previousHasProRata: target.hasProRata,
        newDiscountPercent: upgrade.newDiscountPercent ?? target.discountPercent,
        newValuationCap: upgrade.newValuationCap ?? target.valuationCap,
        newHasProRata: upgrade.addsProRata ? true : target.hasProRata,
      );

      _convertibles[index] = target.copyWith(
        discountPercent: upgrade.newDiscountPercent ?? target.discountPercent,
        valuationCap: upgrade.newValuationCap ?? target.valuationCap,
        hasProRata: upgrade.addsProRata ? true : target.hasProRata,
        mfnUpgradeHistory: [...target.mfnUpgradeHistory, upgradeRecord],
      );
    }

    await _onSave?.call();
    notifyListeners();
    return upgrades.length;
  }

  /// Revert the most recent MFN upgrade, restoring previous terms.
  ///
  /// Pops the last upgrade record from the history and restores the terms
  /// to what they were before that upgrade was applied.
  Future<bool> revertMfnUpgrade(String convertibleId) async {
    final index = _convertibles.indexWhere((c) => c.id == convertibleId);
    if (index == -1) return false;

    final target = _convertibles[index];
    if (!target.mfnWasApplied) return false;

    // Get the last upgrade record
    final lastUpgrade = target.mfnUpgradeHistory.last;

    // Create new history without the last record
    final newHistory = target.mfnUpgradeHistory.sublist(
      0,
      target.mfnUpgradeHistory.length - 1,
    );

    // Restore to terms before this upgrade
    _convertibles[index] = target.copyWith(
      discountPercent: lastUpgrade.previousDiscountPercent,
      valuationCap: lastUpgrade.previousValuationCap,
      hasProRata: lastUpgrade.previousHasProRata,
      mfnUpgradeHistory: newHistory,
    );

    await _onSave?.call();
    notifyListeners();
    return true;
  }

  /// Revert all MFN upgrades caused by a specific source convertible.
  ///
  /// Called when a convertible is deleted to cascade the MFN reversion.
  /// Returns a list of affected convertibles for user notification.
  Future<List<ConvertibleInstrument>> revertMfnUpgradesBySource(
    String sourceConvertibleId,
  ) async {
    final affectedConvertibles = <ConvertibleInstrument>[];

    for (int i = 0; i < _convertibles.length; i++) {
      final target = _convertibles[i];

      // Check if this convertible has any upgrades from the source
      final upgradesFromSource = target.mfnUpgradeHistory
          .where((u) => u.sourceConvertibleId == sourceConvertibleId)
          .toList();

      if (upgradesFromSource.isEmpty) continue;

      affectedConvertibles.add(target);

      // Remove all upgrades from this source and recalculate terms
      var newHistory = target.mfnUpgradeHistory
          .where((u) => u.sourceConvertibleId != sourceConvertibleId)
          .toList();

      // Determine what terms should be after removing these upgrades
      double? newDiscount;
      double? newCap;
      bool newProRata = false;

      if (newHistory.isEmpty) {
        // No more upgrades - restore to original terms from first removed upgrade
        final firstRemoved = upgradesFromSource.first;
        newDiscount = firstRemoved.previousDiscountPercent;
        newCap = firstRemoved.previousValuationCap;
        newProRata = firstRemoved.previousHasProRata;
      } else {
        // Still have upgrades - use the latest remaining upgrade's new terms
        final lastRemaining = newHistory.last;
        newDiscount = lastRemaining.newDiscountPercent;
        newCap = lastRemaining.newValuationCap;
        newProRata = lastRemaining.newHasProRata;
      }

      _convertibles[i] = target.copyWith(
        discountPercent: newDiscount,
        valuationCap: newCap,
        hasProRata: newProRata,
        mfnUpgradeHistory: newHistory,
      );
    }

    if (affectedConvertibles.isNotEmpty) {
      await _onSave?.call();
      notifyListeners();
    }

    return affectedConvertibles;
  }

  /// Get all convertibles that have been upgraded by a specific source.
  ///
  /// Useful for showing warnings before deleting a convertible.
  List<ConvertibleInstrument> getConvertiblesUpgradedBySource(
    String sourceConvertibleId,
  ) {
    return _convertibles.where((c) {
      return c.mfnUpgradeHistory.any(
        (u) => u.sourceConvertibleId == sourceConvertibleId,
      );
    }).toList();
  }

  // === Conversion methods ===

  /// Convert a convertible instrument to shares at a round.
  ///
  /// If [isRoundClosed] is false (round is still draft), the convertible
  /// will be marked as 'pendingConversion' instead of 'converted'.
  /// The status will change to 'converted' when the round is closed.
  Future<void> convertConvertible({
    required String convertibleId,
    required String shareClassId,
    required String roundId,
    required DateTime conversionDate,
    required double roundPreMoney,
    required int issuedSharesBeforeRound,
    bool isRoundClosed = true,
  }) async {
    final index = _convertibles.indexWhere((c) => c.id == convertibleId);
    if (index == -1) return;

    final convertible = _convertibles[index];

    final shares = convertible.calculateConversionShares(
      roundPreMoney: roundPreMoney,
      issuedSharesBeforeRound: issuedSharesBeforeRound,
    );

    final pps =
        convertible.calculateConversionPPS(
          roundPreMoney: roundPreMoney,
          issuedSharesBeforeRound: issuedSharesBeforeRound,
        ) ??
        0;

    // Create the transaction
    final transaction = Transaction(
      investorId: convertible.investorId,
      shareClassId: shareClassId,
      roundId: roundId,
      type: TransactionType.conversion,
      numberOfShares: shares,
      pricePerShare: pps,
      totalAmount: convertible.convertibleAmount,
      date: conversionDate,
      notes: 'Converted from ${convertible.typeDisplayName}',
    );

    await _onAddTransaction?.call(transaction);

    // Mark convertible as converted or pending conversion based on round status
    _convertibles[index] = convertible.copyWith(
      status: isRoundClosed
          ? ConvertibleStatus.converted
          : ConvertibleStatus.pendingConversion,
      conversionRoundId: roundId,
      conversionShares: shares,
      conversionPricePerShare: pps,
      conversionDate: conversionDate,
    );

    await _onSave?.call();
    notifyListeners();
  }

  /// Convert a convertible instrument at a specific valuation (no round)
  Future<void> convertConvertibleAtValuation({
    required String convertibleId,
    required String shareClassId,
    required double valuation,
    required DateTime conversionDate,
    required int issuedShares,
    String? notes,
  }) async {
    final index = _convertibles.indexWhere((c) => c.id == convertibleId);
    if (index == -1) return;

    final convertible = _convertibles[index];

    final shares = convertible.calculateConversionShares(
      roundPreMoney: valuation,
      issuedSharesBeforeRound: issuedShares,
    );

    final pps =
        convertible.calculateConversionPPS(
          roundPreMoney: valuation,
          issuedSharesBeforeRound: issuedShares,
        ) ??
        0;

    final transaction = Transaction(
      investorId: convertible.investorId,
      shareClassId: shareClassId,
      type: TransactionType.conversion,
      numberOfShares: shares,
      pricePerShare: pps,
      totalAmount: convertible.convertibleAmount,
      date: conversionDate,
      notes:
          notes ??
          'Converted from ${convertible.typeDisplayName} at \$${valuation.toStringAsFixed(0)} valuation',
    );

    await _onAddTransaction?.call(transaction);

    _convertibles[index] = convertible.copyWith(
      status: ConvertibleStatus.converted,
      conversionShares: shares,
      conversionPricePerShare: pps,
      conversionDate: conversionDate,
    );

    await _onSave?.call();
    notifyListeners();
  }

  /// Undo a conversion - restore convertible to outstanding
  Future<bool> undoConversion(
    String convertibleId, {
    void Function(ConvertibleInstrument)? onFindTransaction,
  }) async {
    final index = _convertibles.indexWhere((c) => c.id == convertibleId);
    if (index == -1) return false;

    final convertible = _convertibles[index];
    if (convertible.status != ConvertibleStatus.converted) return false;

    // Notify parent to find and remove the conversion transaction
    onFindTransaction?.call(convertible);

    // Reset convertible to outstanding
    _convertibles[index] = convertible.copyWith(
      status: ConvertibleStatus.outstanding,
      conversionRoundId: null,
      conversionShares: null,
      conversionPricePerShare: null,
      conversionDate: null,
    );

    await _onSave?.call();
    notifyListeners();
    return true;
  }

  /// Revert a convertible back to outstanding (called when transaction is deleted)
  void revertConvertibleToOutstanding(ConvertibleInstrument convertible) {
    final index = _convertibles.indexWhere((c) => c.id == convertible.id);
    if (index != -1) {
      _convertibles[index] = convertible.copyWith(
        status: ConvertibleStatus.outstanding,
        conversionRoundId: null,
        conversionShares: null,
        conversionPricePerShare: null,
        conversionDate: null,
      );
      notifyListeners();
    }
  }

  // === Data loading/saving ===

  void loadData(List<ConvertibleInstrument> convertibles) {
    _convertibles = convertibles;
    notifyListeners();
  }

  List<Map<String, dynamic>> exportData() {
    return _convertibles.map((e) => e.toJson()).toList();
  }

  void importData(List<dynamic> data) {
    _convertibles = data
        .map((e) => ConvertibleInstrument.fromJson(e as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  void clear() {
    _convertibles = [];
    notifyListeners();
  }
}
