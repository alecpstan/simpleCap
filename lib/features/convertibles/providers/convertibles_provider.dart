import 'package:flutter/foundation.dart';
import '../models/convertible_instrument.dart';
import '../../core/models/transaction.dart';

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

  // === Conversion methods ===

  /// Convert a convertible instrument to shares at a round
  Future<void> convertConvertible({
    required String convertibleId,
    required String shareClassId,
    required String roundId,
    required DateTime conversionDate,
    required double roundPreMoney,
    required int issuedSharesBeforeRound,
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

    // Mark convertible as converted
    _convertibles[index] = convertible.copyWith(
      status: ConvertibleStatus.converted,
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
