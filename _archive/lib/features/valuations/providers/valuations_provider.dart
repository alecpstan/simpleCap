import 'package:flutter/foundation.dart';
import '../models/valuation.dart';

/// Provider for company valuations management.
///
/// This provider manages:
/// - Pre-money valuations (CRUD)
/// - Valuation method parameters (for wizard editing)
/// - Getting latest valuation for auto-population
///
/// It syncs with CoreCapTableProvider for persistence.
class ValuationsProvider extends ChangeNotifier {
  List<Valuation> _valuations = [];

  // Track if we've been initialized with data from core
  bool _initialized = false;

  // Callback for saving data (injected by parent)
  Future<void> Function()? _onSave;

  ValuationsProvider();

  /// Update this provider with data and callbacks from CoreCapTableProvider.
  /// Called by ChangeNotifierProxyProvider when core provider updates.
  void updateFromCore({
    required List<Valuation> valuations,
    required Future<void> Function() onSave,
  }) {
    // Store callback reference
    _onSave = onSave;

    // Only load data on first initialization to avoid overwriting local changes
    if (!_initialized) {
      _valuations = List.from(valuations);
      _initialized = true;
      notifyListeners();
    }
  }

  /// Check if provider has been initialized with core data
  bool get isInitialized => _initialized;

  // === Getters ===

  /// All valuations sorted by date (newest first)
  List<Valuation> get valuations {
    final sorted = List<Valuation>.from(_valuations);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  /// Get the most recent valuation
  Valuation? get latestValuation {
    if (_valuations.isEmpty) return null;
    final sorted = List<Valuation>.from(_valuations);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }

  /// Get the most recent valuation before or on a given date
  Valuation? getLatestValuationBeforeDate(DateTime date) {
    final beforeDate = _valuations
        .where((v) => v.date.isBefore(date) || _isSameDay(v.date, date))
        .toList();
    if (beforeDate.isEmpty) return null;
    beforeDate.sort((a, b) => b.date.compareTo(a.date));
    return beforeDate.first;
  }

  /// Get the valuation after a given valuation (by date)
  Valuation? getNextValuation(DateTime afterDate) {
    final after = _valuations
        .where((v) => v.date.isAfter(afterDate))
        .toList();
    if (after.isEmpty) return null;
    after.sort((a, b) => a.date.compareTo(b.date));
    return after.first;
  }

  // === Valuation CRUD ===

  Future<void> addValuation(Valuation valuation) async {
    _valuations.add(valuation);
    await _onSave?.call();
    notifyListeners();
  }

  Future<void> updateValuation(Valuation valuation) async {
    final index = _valuations.indexWhere((v) => v.id == valuation.id);
    if (index != -1) {
      _valuations[index] = valuation;
      await _onSave?.call();
      notifyListeners();
    }
  }

  Future<void> deleteValuation(String id) async {
    _valuations.removeWhere((v) => v.id == id);
    await _onSave?.call();
    notifyListeners();
  }

  Valuation? getValuationById(String id) {
    try {
      return _valuations.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  // === Helper methods ===

  /// Calculate implied share price from a valuation
  double calculateSharePrice(double preMoneyValue, int totalShares) {
    if (totalShares <= 0) return 0;
    return preMoneyValue / totalShares;
  }

  /// Check if two dates are on the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // === Data loading/saving ===

  void loadData(List<Valuation> valuations) {
    _valuations = List.from(valuations);
    notifyListeners();
  }

  List<Map<String, dynamic>> exportData() {
    return _valuations.map((e) => e.toJson()).toList();
  }

  void importData(List<dynamic> data) {
    _valuations = data
        .map((e) => Valuation.fromJson(e as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  void clear() {
    _valuations = [];
    notifyListeners();
  }
}
