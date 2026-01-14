import 'package:flutter/foundation.dart';
import '../models/option_grant.dart';
import '../models/transaction.dart';

/// Provider for managing stock option grants
/// Works in conjunction with CapTableProvider for transaction creation
class OptionsProvider extends ChangeNotifier {
  List<OptionGrant> _optionGrants = [];

  OptionsProvider();

  List<OptionGrant> get activeOptionGrants => _optionGrants
      .where(
        (g) =>
            g.status == OptionGrantStatus.active ||
            g.status == OptionGrantStatus.partiallyExercised,
      )
      .toList();

  /// Total options granted (not yet exercised)
  int get totalOptionsGranted =>
      _optionGrants.fold(0, (sum, g) => sum + g.remainingOptions);

  /// Total options exercised
  int get totalOptionsExercised =>
      _optionGrants.fold(0, (sum, g) => sum + g.exercisedCount);

  /// Total options cancelled/forfeited
  int get totalOptionsCancelled =>
      _optionGrants.fold(0, (sum, g) => sum + g.cancelledCount);

  // Initialize from saved data
  void loadFromData(List<OptionGrant> optionGrants) {
    _optionGrants = optionGrants;
    notifyListeners();
  }

  // Export data for saving
  List<Map<String, dynamic>> exportData() {
    return _optionGrants.map((e) => e.toJson()).toList();
  }

  // === Option Grant CRUD ===

  Future<void> addOptionGrant(
    OptionGrant grant, {
    required Future<void> Function() onSave,
  }) async {
    _optionGrants.add(grant);
    await onSave();
    notifyListeners();
  }

  Future<void> updateOptionGrant(
    OptionGrant grant, {
    required Future<void> Function() onSave,
  }) async {
    final index = _optionGrants.indexWhere((g) => g.id == grant.id);
    if (index != -1) {
      _optionGrants[index] = grant;
      await onSave();
      notifyListeners();
    }
  }

  Future<void> deleteOptionGrant(
    String id, {
    required Future<void> Function() onSave,
    String? Function(String grantId)? getVestingScheduleId,
    void Function(String vestingId)? removeVestingSchedule,
  }) async {
    final grant = getOptionGrantById(id);
    if (grant?.vestingScheduleId != null && removeVestingSchedule != null) {
      removeVestingSchedule(grant!.vestingScheduleId!);
    }
    _optionGrants.removeWhere((g) => g.id == id);
    await onSave();
    notifyListeners();
  }

  OptionGrant? getOptionGrantById(String id) {
    try {
      return _optionGrants.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<OptionGrant> getOptionGrantsByInvestor(String investorId) {
    return _optionGrants.where((g) => g.investorId == investorId).toList();
  }

  // === Exercise and Cancellation ===

  /// Exercise options - returns the transaction to be added
  /// Caller is responsible for adding transaction to CapTableProvider
  ExerciseResult? exerciseOptions({
    required String grantId,
    required int numberOfOptions,
    required DateTime exerciseDate,
    String? notes,
  }) {
    final index = _optionGrants.indexWhere((g) => g.id == grantId);
    if (index == -1) return null;

    final grant = _optionGrants[index];

    // Validate
    if (numberOfOptions <= 0 || numberOfOptions > grant.remainingOptions) {
      return null;
    }
    if (grant.isExpired) return null;

    // Create the exercise transaction
    final transaction = Transaction(
      investorId: grant.investorId,
      shareClassId: grant.shareClassId,
      type: TransactionType.optionExercise,
      numberOfShares: numberOfOptions,
      pricePerShare: grant.strikePrice,
      totalAmount: numberOfOptions * grant.strikePrice,
      date: exerciseDate,
      exercisePrice: grant.strikePrice,
      notes: notes ?? 'Option exercise from grant ${grant.id.substring(0, 8)}',
    );

    // Update the grant
    final newExercisedCount = grant.exercisedCount + numberOfOptions;
    final newStatus = newExercisedCount >= grant.numberOfOptions
        ? OptionGrantStatus.fullyExercised
        : OptionGrantStatus.partiallyExercised;

    _optionGrants[index] = grant.copyWith(
      exercisedCount: newExercisedCount,
      status: newStatus,
      exerciseTransactionId: transaction.id,
    );

    return ExerciseResult(
      transaction: transaction,
      updatedGrant: _optionGrants[index],
    );
  }

  /// Cancel/forfeit options (e.g., employee termination)
  bool cancelOptions({
    required String grantId,
    required int numberOfOptions,
    required OptionGrantStatus reason, // cancelled or forfeited
    String? notes,
  }) {
    final index = _optionGrants.indexWhere((g) => g.id == grantId);
    if (index == -1) return false;

    final grant = _optionGrants[index];

    // Validate
    if (numberOfOptions <= 0 || numberOfOptions > grant.remainingOptions) {
      return false;
    }
    if (reason != OptionGrantStatus.cancelled &&
        reason != OptionGrantStatus.forfeited) {
      return false;
    }

    // Update the grant
    final newCancelledCount = grant.cancelledCount + numberOfOptions;
    final newStatus = (grant.remainingOptions - numberOfOptions) <= 0
        ? reason
        : grant.status;

    _optionGrants[index] = grant.copyWith(
      cancelledCount: newCancelledCount,
      status: newStatus,
      notes: notes ?? grant.notes,
    );

    return true;
  }

  /// Check and update expired option grants
  Future<bool> updateExpiredOptionGrants({
    required Future<void> Function() onSave,
  }) async {
    bool changed = false;
    final now = DateTime.now();

    for (int i = 0; i < _optionGrants.length; i++) {
      final grant = _optionGrants[i];
      if (grant.status == OptionGrantStatus.active ||
          grant.status == OptionGrantStatus.partiallyExercised) {
        if (now.isAfter(grant.expiryDate)) {
          _optionGrants[i] = grant.copyWith(status: OptionGrantStatus.expired);
          changed = true;
        }
      }
    }

    if (changed) {
      await onSave();
      notifyListeners();
    }

    return changed;
  }

  // === Analytics ===

  /// Get total value of exercisable options at current share price
  double getTotalExercisableValue(double currentSharePrice) {
    double value = 0;
    for (final grant in activeOptionGrants) {
      if (currentSharePrice > grant.strikePrice) {
        final profit =
            (currentSharePrice - grant.strikePrice) * grant.remainingOptions;
        value += profit;
      }
    }
    return value;
  }

  /// Get options granted in the last N days
  List<OptionGrant> getRecentGrants(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _optionGrants.where((g) {
      if (g.status != OptionGrantStatus.active) return false;
      return g.grantDate.isAfter(cutoff);
    }).toList();
  }
}

/// Result of an option exercise operation
class ExerciseResult {
  final Transaction transaction;
  final OptionGrant updatedGrant;

  ExerciseResult({required this.transaction, required this.updatedGrant});
}
