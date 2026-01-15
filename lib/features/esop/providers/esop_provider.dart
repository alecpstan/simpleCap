import 'package:flutter/foundation.dart';
import '../models/option_grant.dart';
import '../models/esop_pool_change.dart';
import '../../core/models/vesting_schedule.dart';
import '../../core/models/transaction.dart';
import '../esop_helpers.dart' as esop;

// Re-export EsopDilutionMethod for convenience
export '../esop_helpers.dart' show EsopDilutionMethod;

typedef EsopDilutionMethod = esop.EsopDilutionMethod;

/// Provider for ESOP pool and option grant management.
///
/// This provider manages:
/// - ESOP pool settings (dilution method, target percentage)
/// - ESOP pool changes (additions/subtractions)
/// - Option grants (CRUD, exercise, cancellation)
///
/// It requires access to CoreCapTableProvider for:
/// - Vesting schedules
/// - Transaction creation (for exercises)
/// - Share price data
class EsopProvider extends ChangeNotifier {
  // ESOP pool settings
  EsopDilutionMethod _esopDilutionMethod = EsopDilutionMethod.preRoundCap;
  double _esopPoolPercent = 10.0;
  List<EsopPoolChange> _esopPoolChanges = [];
  List<OptionGrant> _optionGrants = [];

  // Track if we've been initialized with data from core
  bool _initialized = false;

  // Callback for saving data (injected by parent)
  Future<void> Function()? _onSave;

  // Callback for creating transactions (injected by parent)
  Future<void> Function(Transaction)? _onAddTransaction;

  // Callback for deleting transactions (for undo exercise)
  void Function(String)? _onDeleteTransaction;

  // Callback for getting vesting schedule
  VestingSchedule? Function(String)? _getVestingSchedule;

  // Callback for deleting vesting schedule
  void Function(String)? _onDeleteVestingSchedule;

  // Callback for getting latest share price
  double Function()? _getLatestSharePrice;

  EsopProvider();

  /// Update this provider with data and callbacks from CoreCapTableProvider.
  /// Called by ChangeNotifierProxyProvider when core provider updates.
  void updateFromCore({
    required List<OptionGrant> optionGrants,
    required List<EsopPoolChange> esopPoolChanges,
    required EsopDilutionMethod esopDilutionMethod,
    required double esopPoolPercent,
    required Future<void> Function() onSave,
    required Future<void> Function(Transaction) onAddTransaction,
    required void Function(String) onDeleteTransaction,
    required VestingSchedule? Function(String) getVestingSchedule,
    required void Function(String) onDeleteVestingSchedule,
    required double Function() getLatestSharePrice,
  }) {
    // Store callback references
    _onSave = onSave;
    _onAddTransaction = onAddTransaction;
    _onDeleteTransaction = onDeleteTransaction;
    _getVestingSchedule = getVestingSchedule;
    _onDeleteVestingSchedule = onDeleteVestingSchedule;
    _getLatestSharePrice = getLatestSharePrice;

    // Only load data on first initialization to avoid overwriting local changes
    if (!_initialized) {
      _optionGrants = List.from(optionGrants);
      _esopPoolChanges = List.from(esopPoolChanges);
      _esopDilutionMethod = esopDilutionMethod;
      _esopPoolPercent = esopPoolPercent;
      _initialized = true;
      notifyListeners();
    }
  }

  /// Check if provider has been initialized with core data
  bool get isInitialized => _initialized;

  // === Getters ===

  EsopDilutionMethod get esopDilutionMethod => _esopDilutionMethod;
  double get esopPoolPercent => _esopPoolPercent;

  List<EsopPoolChange> get esopPoolChanges => List.unmodifiable(
    _esopPoolChanges..sort((a, b) => a.date.compareTo(b.date)),
  );

  List<OptionGrant> get optionGrants => List.unmodifiable(_optionGrants);

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

  /// Total ESOP pool shares (sum of all pool changes)
  int get esopPoolShares {
    if (_esopPoolChanges.isEmpty) return 0;
    final total = _esopPoolChanges.fold(0, (sum, c) => sum + c.sharesDelta);
    return total > 0 ? total : 0;
  }

  /// Allocated ESOP shares = option grants that are still active
  int get allocatedEsopShares {
    return _optionGrants
        .where(
          (g) =>
              g.status != OptionGrantStatus.cancelled &&
              g.status != OptionGrantStatus.forfeited,
        )
        .fold(0, (sum, g) => sum + g.numberOfOptions - g.cancelledCount);
  }

  /// ESOP shares that are unallocated (pool - allocated option grants)
  int get unallocatedEsopShares {
    final total = esopPoolShares;
    final allocated = allocatedEsopShares;
    return total > allocated ? total - allocated : 0;
  }

  // === ESOP Settings ===

  void setEsopDilutionMethod(EsopDilutionMethod method) {
    _esopDilutionMethod = method;
    notifyListeners();
    _onSave?.call();
  }

  void setEsopPoolPercent(double percent) {
    _esopPoolPercent = percent.clamp(0, 30);
    notifyListeners();
    _onSave?.call();
  }

  Future<void> updateEsopSettings({
    double? targetPercent,
    EsopDilutionMethod? dilutionMethod,
  }) async {
    if (targetPercent != null) {
      _esopPoolPercent = targetPercent.clamp(0, 30);
    }
    if (dilutionMethod != null) {
      _esopDilutionMethod = dilutionMethod;
    }
    notifyListeners();
    await _onSave?.call();
  }

  /// Calculate ESOP pool size based on dilution method
  int calculateEsopPoolSize({
    required double targetPercent,
    required int currentShares,
    int additionalNewShares = 0,
  }) {
    return esop.calculateEsopPoolSize(
      method: _esopDilutionMethod,
      targetPercent: targetPercent,
      currentShares: currentShares,
      additionalNewShares: additionalNewShares,
      currentUnallocatedPool: unallocatedEsopShares,
    );
  }

  // === ESOP Pool Change CRUD ===

  Future<void> addEsopPoolChange(EsopPoolChange change) async {
    _esopPoolChanges.add(change);
    await _onSave?.call();
    notifyListeners();
  }

  Future<void> updateEsopPoolChange(EsopPoolChange change) async {
    final index = _esopPoolChanges.indexWhere((c) => c.id == change.id);
    if (index != -1) {
      _esopPoolChanges[index] = change;
      await _onSave?.call();
      notifyListeners();
    }
  }

  Future<void> deleteEsopPoolChange(String id) async {
    _esopPoolChanges.removeWhere((c) => c.id == id);
    await _onSave?.call();
    notifyListeners();
  }

  EsopPoolChange? getEsopPoolChangeById(String id) {
    try {
      return _esopPoolChanges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // === Option Grant CRUD ===

  Future<void> addOptionGrant(OptionGrant grant) async {
    _optionGrants.add(grant);
    await _onSave?.call();
    notifyListeners();
  }

  Future<void> updateOptionGrant(OptionGrant grant) async {
    final index = _optionGrants.indexWhere((g) => g.id == grant.id);
    if (index != -1) {
      _optionGrants[index] = grant;
      await _onSave?.call();
      notifyListeners();
    }
  }

  Future<void> deleteOptionGrant(String id) async {
    final grant = getOptionGrantById(id);
    if (grant?.vestingScheduleId != null) {
      _onDeleteVestingSchedule?.call(grant!.vestingScheduleId!);
    }
    _optionGrants.removeWhere((g) => g.id == id);
    await _onSave?.call();
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

  // === Vesting calculations ===

  double getOptionVestingPercent(OptionGrant grant) {
    if (grant.vestingScheduleId == null) return 100.0;
    final vesting = _getVestingSchedule?.call(grant.vestingScheduleId!);
    if (vesting == null) return 100.0;
    return vesting.vestingPercentage;
  }

  int getVestedOptionsForGrant(OptionGrant grant) {
    final vestingPercent = getOptionVestingPercent(grant);
    return grant.vestedOptionsCount(vestingPercent);
  }

  int getExercisableOptionsForGrant(OptionGrant grant) {
    final vestingPercent = getOptionVestingPercent(grant);
    return grant.exercisableOptionsCount(vestingPercent);
  }

  double getVestedIntrinsicValueForGrant(OptionGrant grant) {
    final vestingPercent = getOptionVestingPercent(grant);
    final sharePrice = _getLatestSharePrice?.call() ?? 0;
    return grant.vestedIntrinsicValue(sharePrice, vestingPercent);
  }

  int getVestedOptionsByInvestor(String investorId) {
    final grants = getOptionGrantsByInvestor(investorId);
    return grants.fold(0, (sum, g) {
      if (g.status == OptionGrantStatus.cancelled ||
          g.status == OptionGrantStatus.forfeited) {
        return sum;
      }
      return sum + getVestedOptionsForGrant(g);
    });
  }

  int getExercisableOptionsByInvestor(String investorId) {
    final grants = getOptionGrantsByInvestor(investorId);
    return grants.fold(0, (sum, g) {
      if (g.status == OptionGrantStatus.cancelled ||
          g.status == OptionGrantStatus.forfeited ||
          g.status == OptionGrantStatus.expired) {
        return sum;
      }
      return sum + getExercisableOptionsForGrant(g);
    });
  }

  double getVestedOptionsValueByInvestor(String investorId) {
    final grants = getOptionGrantsByInvestor(investorId);
    return grants.fold(0.0, (sum, g) {
      if (g.status == OptionGrantStatus.cancelled ||
          g.status == OptionGrantStatus.forfeited ||
          g.status == OptionGrantStatus.expired) {
        return sum;
      }
      return sum + getVestedIntrinsicValueForGrant(g);
    });
  }

  int get totalVestedOptions {
    return activeOptionGrants.fold(
      0,
      (sum, g) => sum + getVestedOptionsForGrant(g),
    );
  }

  int get totalExercisableOptions {
    return activeOptionGrants.fold(
      0,
      (sum, g) => sum + getExercisableOptionsForGrant(g),
    );
  }

  double get totalVestedIntrinsicValue {
    return activeOptionGrants.fold(
      0.0,
      (sum, g) => sum + getVestedIntrinsicValueForGrant(g),
    );
  }

  // === Exercise and Cancel options ===

  Future<bool> exerciseOptions({
    required String grantId,
    required int numberOfOptions,
    required DateTime exerciseDate,
    String? notes,
  }) async {
    final index = _optionGrants.indexWhere((g) => g.id == grantId);
    if (index == -1) return false;

    final grant = _optionGrants[index];

    if (numberOfOptions <= 0 || numberOfOptions > grant.remainingOptions) {
      return false;
    }
    if (grant.isExpired) return false;

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

    await _onAddTransaction?.call(transaction);

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

    await _onSave?.call();
    notifyListeners();
    return true;
  }

  Future<bool> cancelOptions({
    required String grantId,
    required int numberOfOptions,
    required OptionGrantStatus reason,
    String? notes,
  }) async {
    final index = _optionGrants.indexWhere((g) => g.id == grantId);
    if (index == -1) return false;

    final grant = _optionGrants[index];

    if (numberOfOptions <= 0 || numberOfOptions > grant.remainingOptions) {
      return false;
    }
    if (reason != OptionGrantStatus.cancelled &&
        reason != OptionGrantStatus.forfeited) {
      return false;
    }

    final newCancelledCount = grant.cancelledCount + numberOfOptions;
    final newStatus = (grant.remainingOptions - numberOfOptions) <= 0
        ? reason
        : grant.status;

    _optionGrants[index] = grant.copyWith(
      cancelledCount: newCancelledCount,
      status: newStatus,
      notes: notes ?? grant.notes,
    );

    await _onSave?.call();
    notifyListeners();
    return true;
  }

  Future<bool> undoOptionExercise({required String grantId}) async {
    final index = _optionGrants.indexWhere((g) => g.id == grantId);
    if (index == -1) return false;

    final grant = _optionGrants[index];

    if (grant.exercisedCount == 0) return false;

    // Remove the exercise transaction if we have the ID
    if (grant.exerciseTransactionId != null) {
      _onDeleteTransaction?.call(grant.exerciseTransactionId!);
    }

    // Reset the grant to active status
    _optionGrants[index] = grant.copyWith(
      exercisedCount: 0,
      status: OptionGrantStatus.active,
      exerciseTransactionId: null,
    );

    await _onSave?.call();
    notifyListeners();
    return true;
  }

  Future<void> updateExpiredOptionGrants() async {
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
      await _onSave?.call();
      notifyListeners();
    }
  }

  // === Data loading/saving ===

  void loadData({
    required List<OptionGrant> optionGrants,
    required List<EsopPoolChange> esopPoolChanges,
    required EsopDilutionMethod esopDilutionMethod,
    required double esopPoolPercent,
  }) {
    _optionGrants = optionGrants;
    _esopPoolChanges = esopPoolChanges;
    _esopDilutionMethod = esopDilutionMethod;
    _esopPoolPercent = esopPoolPercent;
    notifyListeners();
  }

  Map<String, dynamic> exportData() {
    return {
      'optionGrants': _optionGrants.map((e) => e.toJson()).toList(),
      'esopPoolChanges': _esopPoolChanges.map((e) => e.toJson()).toList(),
      'esopDilutionMethod': _esopDilutionMethod.index,
      'esopPoolPercent': _esopPoolPercent,
    };
  }

  void importData(Map<String, dynamic> data) {
    _optionGrants = (data['optionGrants'] as List? ?? [])
        .map((e) => OptionGrant.fromJson(e as Map<String, dynamic>))
        .toList();
    _esopPoolChanges = (data['esopPoolChanges'] as List? ?? [])
        .map((e) => EsopPoolChange.fromJson(e as Map<String, dynamic>))
        .toList();
    _esopDilutionMethod =
        EsopDilutionMethod.values[(data['esopDilutionMethod'] as int?) ?? 0];
    _esopPoolPercent = (data['esopPoolPercent'] as num?)?.toDouble() ?? 10.0;
    notifyListeners();
  }

  void clear() {
    _optionGrants = [];
    _esopPoolChanges = [];
    _esopDilutionMethod = EsopDilutionMethod.preRoundCap;
    _esopPoolPercent = 10.0;
    notifyListeners();
  }
}
