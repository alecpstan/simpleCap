import 'package:flutter/foundation.dart';
import '../models/tax_rule.dart';

/// Provider for managing tax rules
/// Tax rules can be associated with transactions for tax optimization tracking
class TaxProvider extends ChangeNotifier {
  List<TaxRule> _taxRules = [];

  TaxProvider();
  List<TaxRule> get taxRules => List.unmodifiable(_taxRules);

  /// Get active tax rules
  List<TaxRule> get activeTaxRules =>
      _taxRules.where((r) => r.isActive).toList();

  // Initialize from saved data
  void loadFromData(List<TaxRule> taxRules) {
    _taxRules = taxRules;
    notifyListeners();
  }

  // Export data for saving
  List<Map<String, dynamic>> exportData() {
    return _taxRules.map((e) => e.toJson()).toList();
  }

  // === Tax Rule CRUD ===

  Future<void> addTaxRule(
    TaxRule rule, {
    required Future<void> Function() onSave,
  }) async {
    _taxRules.add(rule);
    await onSave();
    notifyListeners();
  }

  Future<void> updateTaxRule(
    TaxRule rule, {
    required Future<void> Function() onSave,
  }) async {
    final index = _taxRules.indexWhere((t) => t.id == rule.id);
    if (index != -1) {
      _taxRules[index] = rule;
      await onSave();
      notifyListeners();
    }
  }

  Future<void> deleteTaxRule(
    String id, {
    required Future<void> Function() onSave,
  }) async {
    _taxRules.removeWhere((t) => t.id == id);
    await onSave();
    notifyListeners();
  }

  TaxRule? getTaxRuleById(String id) {
    try {
      return _taxRules.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get tax rule by name
  TaxRule? getTaxRuleByName(String name) {
    try {
      return _taxRules.firstWhere(
        (t) => t.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get applicable tax rules for a transaction by type
  /// ESS rules typically apply to option exercises
  /// CGT rules apply to disposals
  List<TaxRule> getApplicableRules({
    required bool isDisposal,
    required bool isOptionExercise,
  }) {
    return _taxRules.where((r) {
      if (!r.isActive) return false;

      // ESS rules typically apply to option exercises
      if (isOptionExercise) {
        return r.type == TaxRuleType.essDivision83A ||
            r.type == TaxRuleType.essStartupConcession;
      }

      // CGT rules apply to disposals
      if (isDisposal) {
        return r.type == TaxRuleType.standard ||
            r.type == TaxRuleType.smallBusinessCgt ||
            r.type == TaxRuleType.cgtDiscount12Month;
      }

      return false;
    }).toList();
  }

  /// Get rules by type
  List<TaxRule> getRulesByType(TaxRuleType type) {
    return _taxRules.where((r) => r.type == type).toList();
  }

  /// Check if CGT discount applies (held > 12 months)
  bool checkCgtDiscountEligibility(DateTime acquisitionDate) {
    final holdingDays = DateTime.now().difference(acquisitionDate).inDays;
    return holdingDays > 365;
  }
}
