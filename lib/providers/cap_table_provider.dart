import 'package:flutter/foundation.dart';
import '../models/investor.dart';
import '../models/share_class.dart';
import '../models/investment_round.dart';
import '../models/vesting_schedule.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class CapTableProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Investor> _investors = [];
  List<ShareClass> _shareClasses = [];
  List<InvestmentRound> _rounds = [];
  List<VestingSchedule> _vestingSchedules = [];
  List<Transaction> _transactions = [];
  String _companyName = 'My Company Pty Ltd';
  bool _isLoading = true;
  Map<String, double> _tableColumnWidths = {};

  // Getters
  List<Investor> get investors => List.unmodifiable(_investors);
  List<ShareClass> get shareClasses => List.unmodifiable(_shareClasses);
  List<InvestmentRound> get rounds =>
      List.unmodifiable(_rounds..sort((a, b) => a.order.compareTo(b.order)));
  List<VestingSchedule> get vestingSchedules =>
      List.unmodifiable(_vestingSchedules);
  List<Transaction> get transactions => List.unmodifiable(_transactions);

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

  /// Total amount invested (sum of acquisition transaction amounts)
  double get totalInvested {
    return _transactions
        .where((t) => t.isAcquisition)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  double get latestValuation {
    if (_rounds.isEmpty) return 0;
    final sortedRounds = List<InvestmentRound>.from(_rounds)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedRounds.first.postMoneyValuation;
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
      _companyName = data['companyName'] ?? 'My Company Pty Ltd';
      _tableColumnWidths =
          (data['tableColumnWidths'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {};
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
      companyName: _companyName,
      tableColumnWidths: _tableColumnWidths,
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
      (v) => investorTransactionIds.contains(v.shareholdingId),
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
      (v) => roundTransactionIds.contains(v.shareholdingId),
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
    _vestingSchedules.removeWhere((v) => v.shareholdingId == transactionId);
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
        .where((t) =>
            (t.roundId != null && priorRoundIds.contains(t.roundId)) ||
            (t.roundId == null && t.date.isBefore(targetRound.date)))
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
        (v) => v.shareholdingId == transactionId,
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
        .where((v) => investorTransactionIds.contains(v.shareholdingId))
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

  Future<void> deleteTransaction(String id) async {
    // Also delete any related transaction (e.g., the other side of a secondary sale)
    final transaction = _transactions.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('Transaction not found'),
    );
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
  DateTime? getFirstPurchaseDateByClass(String investorId, String shareClassId) {
    final acquisitions = getAcquisitionsByInvestor(investorId)
        .where((t) => t.shareClassId == shareClassId)
        .toList();
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
        .where((t) =>
            t.investorId == investorId &&
            !t.date.isAfter(endOfDay))
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
        .where((t) =>
            t.investorId == investorId &&
            t.shareClassId == shareClassId &&
            !t.date.isAfter(endOfDay))
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
      'companyName': _companyName,
      'tableColumnWidths': _tableColumnWidths,
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
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
    _companyName = data['companyName'] as String? ?? 'My Company Pty Ltd';
    _tableColumnWidths = Map<String, double>.from(
      data['tableColumnWidths'] as Map? ?? {},
    );

    await _save();
    notifyListeners();
  }
}
