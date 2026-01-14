import 'package:flutter/foundation.dart';
import '../models/investor.dart';
import '../models/share_class.dart';
import '../models/investment_round.dart';
import '../models/vesting_schedule.dart';
import '../models/transaction.dart';
import '../models/convertible_instrument.dart';
import '../models/milestone.dart';
import '../models/hours_vesting.dart';
import '../models/tax_rule.dart';
import '../models/option_grant.dart';
import '../services/storage_service.dart';

/// ESOP dilution calculation methods (Task 2.1)
enum EsopDilutionMethod {
  /// Post-round cap table (US-style): new shares = (pool % * post-money shares) / (1 - pool %)
  postRoundCap,

  /// Pre-round cap table (AU-style): new shares = pool % * pre-round shares
  preRoundCap,

  /// Fixed number of shares (no percentage calculation)
  fixedShares,
}

class CapTableProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Investor> _investors = [];
  List<ShareClass> _shareClasses = [];
  List<InvestmentRound> _rounds = [];
  List<VestingSchedule> _vestingSchedules = [];
  List<Transaction> _transactions = [];
  List<ConvertibleInstrument> _convertibles = [];
  List<Milestone> _milestones = [];
  List<HoursVestingSchedule> _hoursVestingSchedules = [];
  List<TaxRule> _taxRules = [];
  List<OptionGrant> _optionGrants = [];
  String _companyName = 'My Company Pty Ltd';
  bool _isLoading = true;
  Map<String, double> _tableColumnWidths = {};
  bool _showFullyDiluted = false; // Toggle for FD view
  int _themeModeIndex = 0; // 0=system, 1=light, 2=dark

  // === Task 2.1: ESOP dilution settings ===
  EsopDilutionMethod _esopDilutionMethod = EsopDilutionMethod.preRoundCap;
  double _esopPoolPercent = 10.0; // Default 10% ESOP pool

  // === Task 2.7: Authorized shares ===
  int _authorizedShares = 0;

  // Getters
  List<Investor> get investors => List.unmodifiable(_investors);
  List<ShareClass> get shareClasses => List.unmodifiable(_shareClasses);
  List<InvestmentRound> get rounds =>
      List.unmodifiable(_rounds..sort((a, b) => a.order.compareTo(b.order)));
  List<VestingSchedule> get vestingSchedules =>
      List.unmodifiable(_vestingSchedules);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<ConvertibleInstrument> get convertibles =>
      List.unmodifiable(_convertibles);
  List<Milestone> get milestones => List.unmodifiable(_milestones);
  List<HoursVestingSchedule> get hoursVestingSchedules =>
      List.unmodifiable(_hoursVestingSchedules);
  List<TaxRule> get taxRules => List.unmodifiable(_taxRules);
  List<OptionGrant> get optionGrants => List.unmodifiable(_optionGrants);
  bool get showFullyDiluted => _showFullyDiluted;
  int get themeModeIndex => _themeModeIndex;

  // ESOP settings getters
  EsopDilutionMethod get esopDilutionMethod => _esopDilutionMethod;
  double get esopPoolPercent => _esopPoolPercent;

  // Authorized shares getter
  int get authorizedShares => _authorizedShares;

  // Option grant getters
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

  /// Returns all transactions sorted chronologically
  List<Transaction> get sortedTransactions {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  String get companyName => _companyName;
  bool get isLoading => _isLoading;
  Map<String, double> get tableColumnWidths =>
      Map.unmodifiable(_tableColumnWidths);

  // Calculated properties - now transaction-based

  /// Total shares ever issued (sum of all acquisition transactions)
  int get totalIssuedShares {
    return _transactions
        .where((t) => t.isAcquisition)
        .fold(0, (sum, t) => sum + t.numberOfShares);
  }

  /// Total shares disposed of (sum of all disposal transactions)
  int get totalSharesSold {
    return _transactions
        .where((t) => t.isDisposal)
        .fold(0, (sum, t) => sum + t.numberOfShares);
  }

  /// Net current issued shares
  int get totalCurrentShares {
    return _transactions.fold(0, (sum, t) => sum + t.sharesDelta);
  }

  /// Shares that would be issued if all convertibles converted (Task 1.2 - Fixed)
  int get convertibleShares {
    if (totalCurrentShares == 0) return 0;

    return _convertibles
        .where((c) => c.status == ConvertibleStatus.outstanding)
        .fold(0, (sum, c) {
          double pricePerShare;

          if (c.valuationCap != null && c.valuationCap! > 0) {
            // Use cap-based conversion
            pricePerShare = c.valuationCap! / totalCurrentShares;
          } else if (latestValuation > 0) {
            // Fallback to latest round valuation (Task 1.2 fix)
            pricePerShare = latestValuation / totalCurrentShares;
            // Apply discount if available
            if (c.discountPercent != null && c.discountPercent! > 0) {
              pricePerShare *= (1 - c.discountPercent! / 100);
            }
          } else {
            // No valuation available, cannot estimate
            return sum;
          }

          if (pricePerShare <= 0) return sum;
          return sum + (c.convertibleAmount / pricePerShare).round();
        });
  }

  /// Unallocated ESOP pool shares (total ESOP - allocated to employees)
  int get esopPoolShares {
    final esopClasses = _shareClasses
        .where((s) => s.type == ShareClassType.esop)
        .map((s) => s.id)
        .toSet();

    if (esopClasses.isEmpty) return 0;

    // Total ESOP shares created
    return _transactions
        .where((t) => esopClasses.contains(t.shareClassId))
        .fold(0, (sum, t) => sum + t.sharesDelta);
  }

  /// ESOP shares that are unallocated (pool - allocated to specific employees)
  int get unallocatedEsopShares {
    final esopClasses = _shareClasses
        .where((s) => s.type == ShareClassType.esop)
        .map((s) => s.id)
        .toSet();

    if (esopClasses.isEmpty) return 0;

    // Find the ESOP pool holder (typically institution or designated holder)
    final esopPoolHolders = _investors
        .where(
          (i) =>
              i.type == InvestorType.institution ||
              i.name.toLowerCase().contains('esop'),
        )
        .map((i) => i.id)
        .toSet();

    // Total ESOP in pool (held by pool holder)
    final poolShares = _transactions
        .where(
          (t) =>
              esopClasses.contains(t.shareClassId) &&
              esopPoolHolders.contains(t.investorId),
        )
        .fold(0, (sum, t) => sum + t.sharesDelta);

    return poolShares > 0 ? poolShares : 0;
  }

  /// Fully diluted share count (Task 1.1 - Fixed to include ESOP)
  int get fullyDilutedShares {
    // Current issued + convertible estimates + unallocated ESOP pool
    return totalCurrentShares + convertibleShares + unallocatedEsopShares;
  }

  /// Calculate ESOP pool size based on dilution method (Task 2.1)
  int calculateEsopPoolSize({
    required double targetPercent,
    int? additionalNewShares,
  }) {
    final currentShares = totalCurrentShares;
    final newShares = additionalNewShares ?? 0;

    switch (_esopDilutionMethod) {
      case EsopDilutionMethod.postRoundCap:
        // US-style: pool is % of post-money
        // poolShares = (targetPercent * postMoneyShares) / (1 - targetPercent)
        final postMoney = currentShares + newShares;
        return ((targetPercent / 100) * postMoney / (1 - targetPercent / 100))
            .round();

      case EsopDilutionMethod.preRoundCap:
        // AU-style: pool is % of pre-round shares
        return ((targetPercent / 100) * currentShares).round();

      case EsopDilutionMethod.fixedShares:
        // Just return current unallocated pool
        return unallocatedEsopShares;
    }
  }

  /// Set ESOP dilution method
  void setEsopDilutionMethod(EsopDilutionMethod method) {
    _esopDilutionMethod = method;
    notifyListeners();
    _save();
  }

  /// Set ESOP pool target percentage
  void setEsopPoolPercent(double percent) {
    _esopPoolPercent = percent.clamp(0, 30); // Typically 10-15%, max 30%
    notifyListeners();
    _save();
  }

  /// Set authorized shares (Task 2.7)
  void setAuthorizedShares(int shares) {
    _authorizedShares = shares;
    notifyListeners();
    _save();
  }

  /// Remaining shares that can be issued (authorized - issued)
  int get remainingAuthorizedShares {
    if (_authorizedShares == 0) return 0; // No limit set
    return _authorizedShares - totalCurrentShares;
  }

  /// Whether current issuance exceeds authorization
  bool get isOverAuthorized {
    if (_authorizedShares == 0) return false; // No limit set
    return totalCurrentShares > _authorizedShares;
  }

  /// Toggle fully diluted view
  void toggleFullyDiluted([bool? value]) {
    _showFullyDiluted = value ?? !_showFullyDiluted;
    notifyListeners();
  }

  /// Set theme mode (0=system, 1=light, 2=dark)
  Future<void> setThemeMode(int index) async {
    _themeModeIndex = index.clamp(0, 2);
    await _save();
    notifyListeners();
  }

  /// Total amount invested (sum of acquisition transaction amounts)
  double get totalInvested {
    return _transactions
        .where((t) => t.isAcquisition)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  /// Total convertible principal outstanding
  double get totalConvertiblePrincipal {
    return _convertibles
        .where((c) => c.status == ConvertibleStatus.outstanding)
        .fold(0.0, (sum, c) => sum + c.principalAmount);
  }

  /// Total convertible amount including accrued interest
  double get totalConvertibleAmount {
    return _convertibles
        .where((c) => c.status == ConvertibleStatus.outstanding)
        .fold(0.0, (sum, c) => sum + c.convertibleAmount);
  }

  double get latestValuation {
    if (_rounds.isEmpty) return 0;
    final sortedRounds = List<InvestmentRound>.from(_rounds)
      ..sort((a, b) => b.date.compareTo(a.date));
    final latestRound = sortedRounds.first;
    final amountRaised = getAmountRaisedByRound(latestRound.id);
    return latestRound.preMoneyValuation + amountRaised;
  }

  double get latestSharePrice {
    if (_rounds.isEmpty || totalCurrentShares == 0) return 0;
    return latestValuation / totalCurrentShares;
  }

  // Initialize
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _storageService.loadData();

      _investors = (data['investors'] as List? ?? [])
          .map((e) => Investor.fromJson(e))
          .toList();
      _shareClasses = (data['shareClasses'] as List? ?? [])
          .map((e) => ShareClass.fromJson(e))
          .toList();
      _rounds = (data['rounds'] as List? ?? [])
          .map((e) => InvestmentRound.fromJson(e))
          .toList();
      _vestingSchedules = (data['vestingSchedules'] as List? ?? [])
          .map((e) => VestingSchedule.fromJson(e))
          .toList();
      _transactions = (data['transactions'] as List? ?? [])
          .map((e) => Transaction.fromJson(e))
          .toList();
      _convertibles = (data['convertibles'] as List? ?? [])
          .map((e) => ConvertibleInstrument.fromJson(e))
          .toList();
      _milestones = (data['milestones'] as List? ?? [])
          .map((e) => Milestone.fromJson(e))
          .toList();
      _hoursVestingSchedules = (data['hoursVestingSchedules'] as List? ?? [])
          .map((e) => HoursVestingSchedule.fromJson(e))
          .toList();
      _taxRules = (data['taxRules'] as List? ?? [])
          .map((e) => TaxRule.fromJson(e))
          .toList();
      _optionGrants = (data['optionGrants'] as List? ?? [])
          .map((e) => OptionGrant.fromJson(e))
          .toList();
      _companyName = data['companyName'] ?? 'My Company Pty Ltd';
      _tableColumnWidths =
          (data['tableColumnWidths'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {};
      _themeModeIndex = data['themeModeIndex'] ?? 0;

      // Load new settings
      _esopDilutionMethod =
          EsopDilutionMethod.values[data['esopDilutionMethod'] ??
              EsopDilutionMethod.preRoundCap.index];
      _esopPoolPercent = (data['esopPoolPercent'] ?? 10.0).toDouble();
      _authorizedShares = data['authorizedShares'] ?? 0;
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    // Initialize default share classes if empty
    if (_shareClasses.isEmpty) {
      _shareClasses = [
        ShareClass(
          name: 'Ordinary Shares',
          type: ShareClassType.ordinary,
          votingRightsMultiplier: 1.0,
          liquidationPreference: 1.0,
        ),
        ShareClass(
          name: 'Preference A Shares',
          type: ShareClassType.preferenceA,
          votingRightsMultiplier: 1.0,
          liquidationPreference: 1.0,
        ),
        ShareClass(
          name: 'ESOP Pool',
          type: ShareClassType.esop,
          votingRightsMultiplier: 0.0,
          liquidationPreference: 0.0,
        ),
      ];
      await _save();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await _storageService.saveData(
      investors: _investors,
      shareClasses: _shareClasses,
      rounds: _rounds,
      vestingSchedules: _vestingSchedules,
      transactions: _transactions,
      convertibles: _convertibles,
      milestones: _milestones,
      hoursVestingSchedules: _hoursVestingSchedules,
      taxRules: _taxRules,
      optionGrants: _optionGrants,
      companyName: _companyName,
      tableColumnWidths: _tableColumnWidths,
      themeModeIndex: _themeModeIndex,
      esopDilutionMethod: _esopDilutionMethod.index,
      esopPoolPercent: _esopPoolPercent,
      authorizedShares: _authorizedShares,
    );
  }

  // Company settings
  Future<void> updateCompanyName(String name) async {
    _companyName = name;
    await _save();
    notifyListeners();
  }

  Future<void> updateColumnWidth(String columnKey, double width) async {
    _tableColumnWidths[columnKey] = width;
    await _save();
    notifyListeners();
  }

  double getColumnWidth(String columnKey, double defaultWidth) {
    return _tableColumnWidths[columnKey] ?? defaultWidth;
  }

  // Investor CRUD
  Future<void> addInvestor(Investor investor) async {
    _investors.add(investor);
    await _save();
    notifyListeners();
  }

  Future<void> updateInvestor(Investor investor) async {
    final index = _investors.indexWhere((i) => i.id == investor.id);
    if (index != -1) {
      _investors[index] = investor;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteInvestor(String id) async {
    _investors.removeWhere((i) => i.id == id);
    // Remove all transactions for this investor
    _transactions.removeWhere((t) => t.investorId == id);
    // Remove vesting schedules for transactions by this investor
    final investorTransactionIds = _transactions
        .where((t) => t.investorId == id)
        .map((t) => t.id)
        .toSet();
    _vestingSchedules.removeWhere(
      (v) => investorTransactionIds.contains(v.transactionId),
    );
    await _save();
    notifyListeners();
  }

  Investor? getInvestorById(String id) {
    try {
      return _investors.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  // Share Class CRUD
  Future<void> addShareClass(ShareClass shareClass) async {
    _shareClasses.add(shareClass);
    await _save();
    notifyListeners();
  }

  Future<void> updateShareClass(ShareClass shareClass) async {
    final index = _shareClasses.indexWhere((s) => s.id == shareClass.id);
    if (index != -1) {
      _shareClasses[index] = shareClass;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteShareClass(String id) async {
    _shareClasses.removeWhere((s) => s.id == id);
    // Remove all transactions for this share class
    _transactions.removeWhere((t) => t.shareClassId == id);
    await _save();
    notifyListeners();
  }

  ShareClass? getShareClassById(String id) {
    try {
      return _shareClasses.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Round CRUD
  Future<void> addRound(InvestmentRound round) async {
    round.order = _rounds.length;
    _rounds.add(round);
    await _save();
    notifyListeners();
  }

  Future<void> updateRound(InvestmentRound round) async {
    final index = _rounds.indexWhere((r) => r.id == round.id);
    if (index != -1) {
      final oldRound = _rounds[index];
      _rounds[index] = round;

      // If the round date changed, update all associated transaction dates
      if (oldRound.date != round.date) {
        for (int i = 0; i < _transactions.length; i++) {
          if (_transactions[i].roundId == round.id) {
            _transactions[i] = _transactions[i].copyWith(date: round.date);
          }
        }
      }

      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteRound(String id) async {
    _rounds.removeWhere((r) => r.id == id);
    // Remove all transactions for this round
    final roundTransactionIds = _transactions
        .where((t) => t.roundId == id)
        .map((t) => t.id)
        .toSet();
    _transactions.removeWhere((t) => t.roundId == id);
    // Remove vesting schedules linked to these transactions
    _vestingSchedules.removeWhere(
      (v) => roundTransactionIds.contains(v.transactionId),
    );
    await _save();
    notifyListeners();
  }

  InvestmentRound? getRoundById(String id) {
    try {
      return _rounds.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // Investment/Transaction methods

  /// Adds an investment (purchase transaction) to a round
  Future<void> addInvestment(Transaction transaction) async {
    _transactions.add(transaction);
    await _save();
    notifyListeners();
  }

  /// Updates an existing investment transaction
  Future<void> updateInvestment(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _save();
      notifyListeners();
    }
  }

  /// Deletes an investment transaction (and related vesting)
  Future<void> deleteInvestment(String transactionId) async {
    _transactions.removeWhere((t) => t.id == transactionId);
    // Also remove any vesting schedules linked to this transaction
    _vestingSchedules.removeWhere((v) => v.transactionId == transactionId);
    await _save();
    notifyListeners();
  }

  /// Get all investment transactions for a round
  List<Transaction> getInvestmentsByRound(String roundId) {
    return _transactions
        .where(
          (t) => t.roundId == roundId && t.type == TransactionType.purchase,
        )
        .toList();
  }

  /// Get amount raised in a round (from transactions)
  double getAmountRaisedByRound(String roundId) {
    return _transactions
        .where(
          (t) => t.roundId == roundId && t.type == TransactionType.purchase,
        )
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  /// Get shares issued in a round (from transactions)
  int getSharesIssuedByRound(String roundId) {
    return _transactions
        .where(
          (t) => t.roundId == roundId && t.type == TransactionType.purchase,
        )
        .fold(0, (sum, t) => sum + t.numberOfShares);
  }

  /// Get total issued shares before a specific round
  /// Uses round order to determine which rounds came before
  int getIssuedSharesBeforeRound(String roundId) {
    final targetRound = getRoundById(roundId);
    if (targetRound == null) return totalCurrentShares;

    // Get all rounds that came before this one (by order)
    final priorRoundIds = _rounds
        .where((r) => r.order < targetRound.order)
        .map((r) => r.id)
        .toSet();

    // Sum shares from transactions in prior rounds
    // Also include any transactions not linked to a round (secondary, grants, etc.)
    // that occurred before this round's date
    return _transactions
        .where(
          (t) =>
              (t.roundId != null && priorRoundIds.contains(t.roundId)) ||
              (t.roundId == null && t.date.isBefore(targetRound.date)),
        )
        .fold(0, (sum, t) => sum + t.sharesDelta);
  }

  /// Calculate the implied price per share for a round based on pre-money valuation
  /// Price = Pre-Money Valuation / Issued Shares (pre-round)
  double? getImpliedPricePerShare(String roundId) {
    final round = getRoundById(roundId);
    if (round == null || round.preMoneyValuation <= 0) return null;

    final sharesBeforeRound = getIssuedSharesBeforeRound(roundId);
    if (sharesBeforeRound <= 0) return null;

    return round.preMoneyValuation / sharesBeforeRound;
  }

  /// Calculate implied pre-money valuation from price per share
  /// Pre-Money = Price per Share × Issued Shares (pre-round)
  double? getImpliedPreMoneyValuation(String roundId, double pricePerShare) {
    if (pricePerShare <= 0) return null;

    final sharesBeforeRound = getIssuedSharesBeforeRound(roundId);
    if (sharesBeforeRound <= 0) return null;

    return pricePerShare * sharesBeforeRound;
  }

  /// Update all transaction prices in a round
  Future<void> updateRoundTransactionPrices(
    String roundId,
    double newPricePerShare,
  ) async {
    for (int i = 0; i < _transactions.length; i++) {
      if (_transactions[i].roundId == roundId &&
          _transactions[i].type == TransactionType.purchase) {
        final t = _transactions[i];
        _transactions[i] = t.copyWith(
          pricePerShare: newPricePerShare,
          totalAmount: t.numberOfShares * newPricePerShare,
        );
      }
    }
    await _save();
    notifyListeners();
  }

  /// Get vesting schedule by ID
  VestingSchedule? getVestingScheduleById(String id) {
    try {
      return _vestingSchedules.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  // Vesting Schedule CRUD
  Future<void> addVestingSchedule(VestingSchedule schedule) async {
    _vestingSchedules.add(schedule);
    await _save();
    notifyListeners();
  }

  Future<void> updateVestingSchedule(VestingSchedule schedule) async {
    final index = _vestingSchedules.indexWhere((v) => v.id == schedule.id);
    if (index != -1) {
      _vestingSchedules[index] = schedule;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteVestingSchedule(String id) async {
    _vestingSchedules.removeWhere((v) => v.id == id);
    await _save();
    notifyListeners();
  }

  /// Get vesting schedule by transaction ID
  VestingSchedule? getVestingByTransaction(String transactionId) {
    try {
      return _vestingSchedules.firstWhere(
        (v) => v.transactionId == transactionId,
      );
    } catch (_) {
      return null;
    }
  }

  VestingSchedule? getVestingById(String id) {
    try {
      return _vestingSchedules.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  List<VestingSchedule> getActiveVestingSchedules() {
    return _vestingSchedules
        .where(
          (v) =>
              v.leaverStatus == LeaverStatus.active &&
              v.vestingPercentage < 100,
        )
        .toList();
  }

  List<VestingSchedule> getVestingByInvestor(String investorId) {
    // Get all transaction IDs for this investor
    final investorTransactionIds = _transactions
        .where((t) => t.investorId == investorId)
        .map((t) => t.id)
        .toSet();
    return _vestingSchedules
        .where((v) => investorTransactionIds.contains(v.transactionId))
        .toList();
  }

  // Get vested shares for a transaction
  int getVestedShares(String transactionId) {
    final transaction = _transactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => throw Exception('Transaction not found'),
    );
    final vesting = getVestingByTransaction(transactionId);
    if (vesting == null) {
      return transaction.numberOfShares; // No vesting = fully vested
    }
    return (transaction.numberOfShares * vesting.vestingPercentage / 100)
        .round();
  }

  // Get unvested shares for a transaction
  int getUnvestedShares(String transactionId) {
    final transaction = _transactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => throw Exception('Transaction not found'),
    );
    final vesting = getVestingByTransaction(transactionId);
    if (vesting == null) return 0; // No vesting = fully vested
    return transaction.numberOfShares - getVestedShares(transactionId);
  }

  // Convertible Instrument CRUD
  Future<void> addConvertible(ConvertibleInstrument convertible) async {
    _convertibles.add(convertible);
    await _save();
    notifyListeners();
  }

  Future<void> updateConvertible(ConvertibleInstrument convertible) async {
    final index = _convertibles.indexWhere((c) => c.id == convertible.id);
    if (index != -1) {
      _convertibles[index] = convertible;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteConvertible(String id) async {
    _convertibles.removeWhere((c) => c.id == id);
    await _save();
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

  List<ConvertibleInstrument> get outstandingConvertibles {
    return _convertibles
        .where((c) => c.status == ConvertibleStatus.outstanding)
        .toList();
  }

  /// Convert a convertible instrument to shares
  /// Requires round pre-money and issued shares to calculate conversion PPS
  Future<void> convertConvertible(
    String convertibleId,
    String shareClassId,
    String roundId,
    DateTime conversionDate,
  ) async {
    final index = _convertibles.indexWhere((c) => c.id == convertibleId);
    if (index == -1) return;

    final round = getRoundById(roundId);
    if (round == null) return;

    final convertible = _convertibles[index];
    final issuedSharesBeforeRound = getIssuedSharesBeforeRound(roundId);

    final shares = convertible.calculateConversionShares(
      roundPreMoney: round.preMoneyValuation,
      issuedSharesBeforeRound: issuedSharesBeforeRound,
    );

    final pps =
        convertible.calculateConversionPPS(
          roundPreMoney: round.preMoneyValuation,
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
    _transactions.add(transaction);

    // Mark convertible as converted
    _convertibles[index] = convertible.copyWith(
      status: ConvertibleStatus.converted,
      conversionRoundId: roundId,
      conversionShares: shares,
      conversionPricePerShare: pps,
      conversionDate: conversionDate,
    );

    await _save();
    notifyListeners();
  }

  /// Undo a conversion - restore convertible to outstanding and remove the transaction
  Future<bool> undoConversion(String convertibleId) async {
    final index = _convertibles.indexWhere((c) => c.id == convertibleId);
    if (index == -1) return false;

    final convertible = _convertibles[index];
    if (convertible.status != ConvertibleStatus.converted) return false;

    // Find and remove the conversion transaction
    final transactionIndex = _transactions.indexWhere(
      (t) =>
          t.type == TransactionType.conversion &&
          t.investorId == convertible.investorId &&
          t.roundId == convertible.conversionRoundId &&
          t.numberOfShares == convertible.conversionShares,
    );

    if (transactionIndex != -1) {
      _transactions.removeAt(transactionIndex);
    }

    // Reset convertible to outstanding
    _convertibles[index] = convertible.copyWith(
      status: ConvertibleStatus.outstanding,
      conversionRoundId: null,
      conversionShares: null,
      conversionPricePerShare: null,
      conversionDate: null,
    );

    await _save();
    notifyListeners();
    return true;
  }

  // Milestone CRUD
  Future<void> addMilestone(Milestone milestone) async {
    _milestones.add(milestone);
    await _save();
    notifyListeners();
  }

  Future<void> updateMilestone(Milestone milestone) async {
    final index = _milestones.indexWhere((m) => m.id == milestone.id);
    if (index != -1) {
      _milestones[index] = milestone;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteMilestone(String id) async {
    _milestones.removeWhere((m) => m.id == id);
    await _save();
    notifyListeners();
  }

  Milestone? getMilestoneById(String id) {
    try {
      return _milestones.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Milestone> getMilestonesByInvestor(String investorId) {
    return _milestones.where((m) => m.investorId == investorId).toList();
  }

  List<Milestone> get pendingMilestones {
    return _milestones.where((m) => !m.isCompleted && !m.isLapsed).toList();
  }

  /// Update progress for a graded milestone
  Future<void> updateMilestoneProgress(
    String milestoneId,
    double newValue,
  ) async {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index == -1) return;

    final milestone = _milestones[index];
    milestone.currentValue = newValue;
    _milestones[index] = milestone;

    await _save();
    notifyListeners();
  }

  /// Complete a milestone and award equity
  Future<void> completeMilestone(
    String milestoneId,
    String shareClassId,
    double pricePerShare,
  ) async {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index == -1) return;

    final milestone = _milestones[index];
    if (milestone.investorId == null) return;

    // Complete the milestone
    milestone.complete();

    // Calculate shares from equity percent
    final shares = (totalCurrentShares * milestone.earnedEquityPercent / 100)
        .round();

    // Create the transaction
    final transaction = Transaction(
      investorId: milestone.investorId!,
      shareClassId: shareClassId,
      type: TransactionType.grant,
      numberOfShares: shares,
      pricePerShare: pricePerShare,
      totalAmount: shares * pricePerShare,
      date: DateTime.now(),
      notes: 'Milestone achieved: ${milestone.name}',
    );
    _transactions.add(transaction);

    // Update milestone in list (already mutated but triggers save)
    _milestones[index] = milestone;

    await _save();
    notifyListeners();
  }

  // Hours Vesting Schedule CRUD
  Future<void> addHoursVestingSchedule(HoursVestingSchedule schedule) async {
    _hoursVestingSchedules.add(schedule);
    await _save();
    notifyListeners();
  }

  Future<void> updateHoursVestingSchedule(HoursVestingSchedule schedule) async {
    final index = _hoursVestingSchedules.indexWhere((h) => h.id == schedule.id);
    if (index != -1) {
      _hoursVestingSchedules[index] = schedule;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteHoursVestingSchedule(String id) async {
    _hoursVestingSchedules.removeWhere((h) => h.id == id);
    await _save();
    notifyListeners();
  }

  HoursVestingSchedule? getHoursVestingById(String id) {
    try {
      return _hoursVestingSchedules.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  List<HoursVestingSchedule> getHoursVestingByInvestor(String investorId) {
    return _hoursVestingSchedules
        .where((h) => h.investorId == investorId)
        .toList();
  }

  /// Log hours for an hours vesting schedule
  Future<void> logHoursForSchedule(
    String scheduleId,
    double hours,
    DateTime date,
    String? description,
  ) async {
    final index = _hoursVestingSchedules.indexWhere((h) => h.id == scheduleId);
    if (index == -1) return;

    final schedule = _hoursVestingSchedules[index];

    // logHours mutates the schedule in place
    schedule.logHours(hours, description: description, date: date);

    // Trigger save with the mutated schedule
    _hoursVestingSchedules[index] = schedule;

    await _save();
    notifyListeners();
  }

  // Tax Rule CRUD
  Future<void> addTaxRule(TaxRule rule) async {
    _taxRules.add(rule);
    await _save();
    notifyListeners();
  }

  Future<void> updateTaxRule(TaxRule rule) async {
    final index = _taxRules.indexWhere((t) => t.id == rule.id);
    if (index != -1) {
      _taxRules[index] = rule;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteTaxRule(String id) async {
    _taxRules.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  TaxRule? getTaxRuleById(String id) {
    try {
      return _taxRules.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all transactions with a specific tax rule
  List<Transaction> getTransactionsByTaxRule(String taxRuleId) {
    return _transactions.where((t) => t.taxRuleId == taxRuleId).toList();
  }

  /// Get all reequitization transactions (Task 2.2)
  List<Transaction> get reequitizationTransactions {
    return _transactions
        .where((t) => t.type == TransactionType.reequitization)
        .toList();
  }

  // Option Grant CRUD
  Future<void> addOptionGrant(OptionGrant grant) async {
    _optionGrants.add(grant);
    await _save();
    notifyListeners();
  }

  Future<void> updateOptionGrant(OptionGrant grant) async {
    final index = _optionGrants.indexWhere((g) => g.id == grant.id);
    if (index != -1) {
      _optionGrants[index] = grant;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteOptionGrant(String id) async {
    // Also remove any linked vesting schedule
    final grant = getOptionGrantById(id);
    if (grant?.vestingScheduleId != null) {
      _vestingSchedules.removeWhere((v) => v.id == grant!.vestingScheduleId);
    }
    _optionGrants.removeWhere((g) => g.id == id);
    await _save();
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

  /// Exercise options - creates a transaction and updates the grant
  Future<bool> exerciseOptions({
    required String grantId,
    required int numberOfOptions,
    required DateTime exerciseDate,
    String? notes,
  }) async {
    final index = _optionGrants.indexWhere((g) => g.id == grantId);
    if (index == -1) return false;

    final grant = _optionGrants[index];

    // Validate
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
    _transactions.add(transaction);

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

    await _save();
    notifyListeners();
    return true;
  }

  /// Cancel/forfeit options (e.g., employee termination)
  Future<bool> cancelOptions({
    required String grantId,
    required int numberOfOptions,
    required OptionGrantStatus reason, // cancelled or forfeited
    String? notes,
  }) async {
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

    await _save();
    notifyListeners();
    return true;
  }

  /// Check and update expired option grants
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
      await _save();
      notifyListeners();
    }
  }

  // Analysis methods
  Map<String, double> getOwnershipByInvestor() {
    final Map<String, int> sharesByInvestor = {};
    for (var investor in _investors) {
      final currentShares = getCurrentSharesByInvestor(investor.id);
      if (currentShares > 0) {
        sharesByInvestor[investor.id] = currentShares;
      }
    }

    final total = totalCurrentShares;
    if (total == 0) return {};

    return sharesByInvestor.map(
      (id, shares) => MapEntry(id, shares / total * 100),
    );
  }

  Map<String, double> getOwnershipByShareClass() {
    final Map<String, int> sharesByClass = {};

    // Use transactions to calculate current shares by class
    for (var transaction in _transactions) {
      sharesByClass[transaction.shareClassId] =
          (sharesByClass[transaction.shareClassId] ?? 0) +
          transaction.sharesDelta;
    }

    // Remove classes with no current shares
    sharesByClass.removeWhere((key, value) => value <= 0);

    final total = totalCurrentShares;
    if (total == 0) return {};

    return sharesByClass.map(
      (id, shares) => MapEntry(id, shares / total * 100),
    );
  }

  /// Get total shares ever acquired by investor (ignoring sales)
  int getSharesByInvestor(String investorId) {
    return _transactions
        .where((t) => t.investorId == investorId && t.isAcquisition)
        .fold(0, (sum, t) => sum + t.numberOfShares);
  }

  /// Get total amount invested by investor
  double getInvestmentByInvestor(String investorId) {
    return _transactions
        .where((t) => t.investorId == investorId && t.isAcquisition)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  double getOwnershipPercentage(String investorId) {
    if (totalCurrentShares == 0) return 0;
    return getCurrentSharesByInvestor(investorId) / totalCurrentShares * 100;
  }

  double getShareValueByInvestor(String investorId) {
    return getCurrentSharesByInvestor(investorId) * latestSharePrice;
  }

  /// Get voting power for an investor (shares × voting multiplier)
  double getVotingPowerByInvestor(String investorId) {
    double votes = 0;
    final investorTransactions = _transactions.where(
      (t) => t.investorId == investorId && t.isAcquisition,
    );

    // Sum shares sold (disposals)
    final soldShares = _transactions
        .where((t) => t.investorId == investorId && t.isDisposal)
        .fold(0, (sum, t) => sum + t.numberOfShares);

    // For each acquisition, apply the share class voting multiplier
    for (final t in investorTransactions) {
      final shareClass = getShareClassById(t.shareClassId);
      final multiplier = shareClass?.votingRightsMultiplier ?? 1.0;
      votes += t.numberOfShares * multiplier;
    }

    // Subtract sold shares (assume they lose voting proportionally)
    if (soldShares > 0) {
      final currentShares = getCurrentSharesByInvestor(investorId);
      final totalShares = getSharesByInvestor(investorId);
      if (totalShares > 0) {
        votes = votes * (currentShares / totalShares);
      }
    }

    return votes;
  }

  /// Total voting power across all investors
  double get totalVotingPower {
    return activeInvestors.fold(
      0.0,
      (sum, inv) => sum + getVotingPowerByInvestor(inv.id),
    );
  }

  /// Get voting percentage for an investor
  double getVotingPercentage(String investorId) {
    if (totalVotingPower == 0) return 0;
    return getVotingPowerByInvestor(investorId) / totalVotingPower * 100;
  }

  /// Calculate accrued dividends for an investor based on share class dividend rates
  double getAccruedDividendsByInvestor(String investorId) {
    double totalDividends = 0;

    final investorTransactions = _transactions
        .where((t) => t.investorId == investorId && t.isAcquisition)
        .toList();

    for (final t in investorTransactions) {
      final shareClass = getShareClassById(t.shareClassId);
      if (shareClass == null || shareClass.dividendRate <= 0) continue;

      // Calculate years since acquisition
      final yearsSince = DateTime.now().difference(t.date).inDays / 365.25;
      if (yearsSince <= 0) continue;

      // Dividend = invested amount × rate × years (simple interest)
      final dividend =
          t.totalAmount * (shareClass.dividendRate / 100) * yearsSince;
      totalDividends += dividend;
    }

    // Adjust for sold shares proportionally
    final currentShares = getCurrentSharesByInvestor(investorId);
    final originalShares = getSharesByInvestor(investorId);
    if (originalShares > 0 && currentShares < originalShares) {
      totalDividends = totalDividends * (currentShares / originalShares);
    }

    return totalDividends;
  }

  /// Total accrued dividends across all share classes
  double get totalAccruedDividends {
    return activeInvestors.fold(
      0.0,
      (sum, inv) => sum + getAccruedDividendsByInvestor(inv.id),
    );
  }

  // Pro-rata calculations
  double calculateProRataAllocation(String investorId, double newRoundSize) {
    final ownership = getOwnershipPercentage(investorId);
    return newRoundSize * (ownership / 100);
  }

  // Dilution calculation
  Map<String, double> calculateDilutionFromNewRound(double newShares) {
    final currentTotal = totalCurrentShares;
    final newTotal = currentTotal + newShares;

    final Map<String, double> dilution = {};
    for (var investor in activeInvestors) {
      final currentOwnership = getOwnershipPercentage(investor.id);
      final newOwnership =
          (getCurrentSharesByInvestor(investor.id) / newTotal) * 100;
      dilution[investor.id] = currentOwnership - newOwnership;
    }
    return dilution;
  }

  // Reset all data
  Future<void> resetData() async {
    _investors = [];
    _shareClasses = [];
    _rounds = [];
    _vestingSchedules = [];
    _transactions = [];
    _companyName = 'My Company Pty Ltd';
    await _storageService.clearData();
    await loadData(); // Reinitialize defaults
  }

  // Transaction CRUD
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _save();
    notifyListeners();
  }

  Future<void> addTransactions(List<Transaction> transactions) async {
    _transactions.addAll(transactions);
    await _save();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    // Also delete any related transaction (e.g., the other side of a secondary sale)
    final transaction = _transactions.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('Transaction not found'),
    );

    // If this is a conversion transaction, revert the convertible to outstanding
    if (transaction.type == TransactionType.conversion) {
      final convertibleIndex = _convertibles.indexWhere(
        (c) =>
            c.status == ConvertibleStatus.converted &&
            c.investorId == transaction.investorId &&
            c.conversionRoundId == transaction.roundId &&
            c.conversionShares == transaction.numberOfShares,
      );
      if (convertibleIndex != -1) {
        final convertible = _convertibles[convertibleIndex];
        _convertibles[convertibleIndex] = convertible.copyWith(
          status: ConvertibleStatus.outstanding,
          conversionRoundId: null,
          conversionShares: null,
          conversionPricePerShare: null,
          conversionDate: null,
        );
      }
    }

    if (transaction.relatedTransactionId != null) {
      _transactions.removeWhere(
        (t) => t.id == transaction.relatedTransactionId,
      );
    }
    _transactions.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Records a secondary sale between two investors in the cap table.
  /// Creates both the sale transaction (for seller) and purchase transaction (for buyer).
  Future<void> recordSecondarySale({
    required String sellerId,
    required String buyerId,
    required String shareClassId,
    required int numberOfShares,
    required double pricePerShare,
    required DateTime date,
    String? notes,
  }) async {
    final transactions = Transaction.createSecondarySale(
      sellerId: sellerId,
      buyerId: buyerId,
      shareClassId: shareClassId,
      numberOfShares: numberOfShares,
      pricePerShare: pricePerShare,
      date: date,
      notes: notes,
    );
    await addTransactions(transactions);
  }

  /// Records a company buyback (shares returned to company, not transferred to another investor)
  Future<void> recordBuyback({
    required String investorId,
    required String shareClassId,
    required int numberOfShares,
    required double pricePerShare,
    required DateTime date,
    String? notes,
  }) async {
    final transaction = Transaction.fromBuyback(
      investorId: investorId,
      shareClassId: shareClassId,
      numberOfShares: numberOfShares,
      pricePerShare: pricePerShare,
      date: date,
      notes: notes,
    );
    await addTransaction(transaction);
  }

  /// Get transactions for an investor, sorted chronologically
  List<Transaction> getTransactionsByInvestor(String investorId) {
    final investorTransactions = _transactions
        .where((t) => t.investorId == investorId)
        .toList();
    investorTransactions.sort((a, b) => a.date.compareTo(b.date));
    return investorTransactions;
  }

  /// Get acquisition transactions (purchases, grants, etc.) for an investor
  /// This replaces the old getShareholdingsByInvestor method
  List<Transaction> getAcquisitionsByInvestor(String investorId) {
    return _transactions
        .where((t) => t.investorId == investorId && t.isAcquisition)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get sale/disposal transactions for an investor
  /// This replaces the old getSalesByInvestor method
  List<Transaction> getSalesByInvestor(String investorId) {
    return _transactions
        .where((t) => t.investorId == investorId && t.isDisposal)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get total shares sold by an investor (using transactions)
  int getSharesSoldByInvestor(String investorId) {
    return _transactions
        .where((t) => t.investorId == investorId && t.isDisposal)
        .fold(0, (sum, t) => sum + t.numberOfShares);
  }

  /// Get total proceeds from sales for an investor
  double getSaleProceedsByInvestor(String investorId) {
    return _transactions
        .where((t) => t.investorId == investorId && t.isDisposal)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  /// Get current shares by stepping through all transactions chronologically.
  /// Handles buy -> sell -> buy scenarios correctly.
  int getCurrentSharesByInvestor(String investorId) {
    return _transactions
        .where((t) => t.investorId == investorId)
        .fold(0, (sum, t) => sum + t.sharesDelta);
  }

  /// Get current shares by share class for an investor
  int getCurrentSharesByInvestorAndClass(
    String investorId,
    String shareClassId,
  ) {
    return _transactions
        .where(
          (t) => t.investorId == investorId && t.shareClassId == shareClassId,
        )
        .fold(0, (sum, t) => sum + t.sharesDelta);
  }

  /// Check if investor has fully exited (had shares, now has none)
  bool hasInvestorExited(String investorId) {
    final acquired = getSharesByInvestor(investorId);
    final current = getCurrentSharesByInvestor(investorId);
    return current <= 0 && acquired > 0;
  }

  /// Check if investor has ever sold any shares
  bool hasInvestorSoldShares(String investorId) {
    return getSharesSoldByInvestor(investorId) > 0;
  }

  /// Get investors who have fully exited (no current shares)
  List<Investor> get exitedInvestors {
    return _investors.where((i) => hasInvestorExited(i.id)).toList();
  }

  /// Get the date of the investor's first acquisition
  DateTime? getFirstPurchaseDate(String investorId) {
    final acquisitions = getAcquisitionsByInvestor(investorId);
    if (acquisitions.isEmpty) return null;
    final earliest = acquisitions
        .map((t) => t.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    // Normalize to start of day
    return DateTime(earliest.year, earliest.month, earliest.day);
  }

  /// Get the date of the investor's first acquisition for a specific share class
  DateTime? getFirstPurchaseDateByClass(
    String investorId,
    String shareClassId,
  ) {
    final acquisitions = getAcquisitionsByInvestor(
      investorId,
    ).where((t) => t.shareClassId == shareClassId).toList();
    if (acquisitions.isEmpty) return null;
    final earliest = acquisitions
        .map((t) => t.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    // Normalize to start of day
    return DateTime(earliest.year, earliest.month, earliest.day);
  }

  /// Get shares owned by investor at a specific date
  /// Sums all transactions (acquisitions and sales) up to and including the date
  int getSharesAtDate(String investorId, DateTime date) {
    // Normalize to end of day to include all transactions on that date
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _transactions
        .where((t) => t.investorId == investorId && !t.date.isAfter(endOfDay))
        .fold(0, (sum, t) => sum + t.sharesDelta);
  }

  /// Get shares owned by investor for a specific share class at a specific date
  int getSharesAtDateByClass(
    String investorId,
    String shareClassId,
    DateTime date,
  ) {
    // Normalize to end of day to include all transactions on that date
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _transactions
        .where(
          (t) =>
              t.investorId == investorId &&
              t.shareClassId == shareClassId &&
              !t.date.isAfter(endOfDay),
        )
        .fold(0, (sum, t) => sum + t.sharesDelta);
  }

  /// Get investors who have sold shares (partial or full exit)
  List<Investor> get investorsWithSales {
    return _investors.where((i) => hasInvestorSoldShares(i.id)).toList();
  }

  /// Get active investors (have current shares)
  List<Investor> get activeInvestors {
    return _investors
        .where((i) => getCurrentSharesByInvestor(i.id) > 0)
        .toList();
  }

  // Calculate profit/loss for an investor
  double getProfitByInvestor(String investorId) {
    final invested = getInvestmentByInvestor(investorId);
    final proceeds = getSaleProceedsByInvestor(investorId);
    final currentValue =
        getCurrentSharesByInvestor(investorId) * latestSharePrice;
    return (proceeds + currentValue) - invested;
  }

  /// Calculate realized profit (from sales only) using transactions
  double getRealizedProfitByInvestor(String investorId) {
    final soldShares = getSharesSoldByInvestor(investorId);
    if (soldShares == 0) return 0;

    // Calculate cost basis using weighted average from acquisition transactions
    final acquisitions = _transactions.where(
      (t) => t.investorId == investorId && t.isAcquisition,
    );

    final totalAcquired = acquisitions.fold(
      0,
      (sum, t) => sum + t.numberOfShares,
    );
    final totalCost = acquisitions.fold(0.0, (sum, t) => sum + t.totalAmount);
    final avgCostPerShare = totalAcquired > 0 ? totalCost / totalAcquired : 0;

    final costOfSoldShares = soldShares * avgCostPerShare;
    final proceeds = getSaleProceedsByInvestor(investorId);

    return proceeds - costOfSoldShares;
  }

  /// Get sale transactions for display
  List<Transaction> getSaleTransactionsByInvestor(String investorId) {
    return _transactions
        .where((t) => t.investorId == investorId && t.isDisposal)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  /// Export all data as a Map for backup
  Map<String, dynamic> exportData() {
    return {
      'investors': _investors.map((e) => e.toJson()).toList(),
      'shareClasses': _shareClasses.map((e) => e.toJson()).toList(),
      'rounds': _rounds.map((e) => e.toJson()).toList(),
      'vestingSchedules': _vestingSchedules.map((e) => e.toJson()).toList(),
      'transactions': _transactions.map((e) => e.toJson()).toList(),
      'convertibles': _convertibles.map((e) => e.toJson()).toList(),
      'milestones': _milestones.map((e) => e.toJson()).toList(),
      'hoursVestingSchedules': _hoursVestingSchedules
          .map((e) => e.toJson())
          .toList(),
      'companyName': _companyName,
      'tableColumnWidths': _tableColumnWidths,
      'themeModeIndex': _themeModeIndex,
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '2.0', // Updated version for new models
    };
  }

  /// Import data from a backup Map
  Future<void> importData(Map<String, dynamic> data) async {
    _investors = (data['investors'] as List? ?? [])
        .map((e) => Investor.fromJson(e as Map<String, dynamic>))
        .toList();
    _shareClasses = (data['shareClasses'] as List? ?? [])
        .map((e) => ShareClass.fromJson(e as Map<String, dynamic>))
        .toList();
    _rounds = (data['rounds'] as List? ?? [])
        .map((e) => InvestmentRound.fromJson(e as Map<String, dynamic>))
        .toList();
    _vestingSchedules = (data['vestingSchedules'] as List? ?? [])
        .map((e) => VestingSchedule.fromJson(e as Map<String, dynamic>))
        .toList();
    _transactions = (data['transactions'] as List? ?? [])
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
    _convertibles = (data['convertibles'] as List? ?? [])
        .map((e) => ConvertibleInstrument.fromJson(e as Map<String, dynamic>))
        .toList();
    _milestones = (data['milestones'] as List? ?? [])
        .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
        .toList();
    _hoursVestingSchedules = (data['hoursVestingSchedules'] as List? ?? [])
        .map((e) => HoursVestingSchedule.fromJson(e as Map<String, dynamic>))
        .toList();
    _companyName = data['companyName'] as String? ?? 'My Company Pty Ltd';
    _tableColumnWidths = Map<String, double>.from(
      data['tableColumnWidths'] as Map? ?? {},
    );
    _themeModeIndex = data['themeModeIndex'] as int? ?? 0;

    await _save();
    notifyListeners();
  }
}
