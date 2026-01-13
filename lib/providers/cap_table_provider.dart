import 'package:flutter/foundation.dart';
import '../models/investor.dart';
import '../models/share_class.dart';
import '../models/investment_round.dart';
import '../models/shareholding.dart';
import '../models/vesting_schedule.dart';
import '../models/share_sale.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class CapTableProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Investor> _investors = [];
  List<ShareClass> _shareClasses = [];
  List<InvestmentRound> _rounds = [];
  List<Shareholding> _shareholdings = [];
  List<VestingSchedule> _vestingSchedules = [];
  List<ShareSale> _shareSales = [];
  List<Transaction> _transactions = [];
  String _companyName = 'My Company Pty Ltd';
  bool _isLoading = true;
  Map<String, double> _tableColumnWidths = {};

  // Getters
  List<Investor> get investors => List.unmodifiable(_investors);
  List<ShareClass> get shareClasses => List.unmodifiable(_shareClasses);
  List<InvestmentRound> get rounds =>
      List.unmodifiable(_rounds..sort((a, b) => a.order.compareTo(b.order)));
  List<Shareholding> get shareholdings => List.unmodifiable(_shareholdings);
  List<VestingSchedule> get vestingSchedules =>
      List.unmodifiable(_vestingSchedules);
  List<ShareSale> get shareSales => List.unmodifiable(_shareSales);
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

  /// Net current shares outstanding
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
      _shareholdings = (data['shareholdings'] as List? ?? [])
          .map((e) => Shareholding.fromJson(e))
          .toList();
      _vestingSchedules = (data['vestingSchedules'] as List? ?? [])
          .map((e) => VestingSchedule.fromJson(e))
          .toList();
      _shareSales = (data['shareSales'] as List? ?? [])
          .map((e) => ShareSale.fromJson(e))
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

      // Migrate legacy data to transactions if transactions list is empty but we have shareholdings/sales
      if (_transactions.isEmpty &&
          (_shareholdings.isNotEmpty || _shareSales.isNotEmpty)) {
        await _migrateToTransactions();
      }
    } catch (e) {
      // If there's any error loading data, start with defaults
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

  /// Migrates legacy shareholdings and shareSales to the new transaction system
  Future<void> _migrateToTransactions() async {
    final List<Transaction> migratedTransactions = [];

    // Convert shareholdings to purchase transactions
    for (final holding in _shareholdings) {
      migratedTransactions.add(
        Transaction.fromPurchase(
          investorId: holding.investorId,
          shareClassId: holding.shareClassId,
          roundId: holding.roundId,
          numberOfShares: holding.numberOfShares,
          pricePerShare: holding.pricePerShare,
          date: holding.dateAcquired,
          notes: holding.notes,
        ),
      );
    }

    // Convert shareSales to transactions
    for (final sale in _shareSales) {
      if (sale.buyerInvestorId != null) {
        // Secondary sale with a buyer in the cap table
        final transactions = Transaction.createSecondarySale(
          sellerId: sale.investorId,
          buyerId: sale.buyerInvestorId!,
          shareClassId: sale.shareClassId,
          numberOfShares: sale.numberOfShares,
          pricePerShare: sale.pricePerShare,
          date: sale.saleDate,
          notes: sale.notes,
        );
        migratedTransactions.addAll(transactions);
      } else {
        // Buyback or exit (no buyer in cap table)
        migratedTransactions.add(
          Transaction.fromBuyback(
            investorId: sale.investorId,
            shareClassId: sale.shareClassId,
            numberOfShares: sale.numberOfShares,
            pricePerShare: sale.pricePerShare,
            date: sale.saleDate,
            notes: sale.notes,
          ),
        );
      }
    }

    // Sort by date to maintain chronological order
    migratedTransactions.sort((a, b) => a.date.compareTo(b.date));

    _transactions = migratedTransactions;
    await _save();
  }

  Future<void> _save() async {
    await _storageService.saveData(
      investors: _investors,
      shareClasses: _shareClasses,
      rounds: _rounds,
      shareholdings: _shareholdings,
      vestingSchedules: _vestingSchedules,
      shareSales: _shareSales,
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
    _shareholdings.removeWhere((s) => s.investorId == id);
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
    _shareholdings.removeWhere((s) => s.shareClassId == id);
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
      _rounds[index] = round;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteRound(String id) async {
    _rounds.removeWhere((r) => r.id == id);
    _shareholdings.removeWhere((s) => s.roundId == id);
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

  // Shareholding CRUD
  Future<void> addShareholding(Shareholding shareholding) async {
    _shareholdings.add(shareholding);

    // Also create a corresponding transaction
    final transaction = Transaction.fromPurchase(
      investorId: shareholding.investorId,
      shareClassId: shareholding.shareClassId,
      roundId: shareholding.roundId,
      numberOfShares: shareholding.numberOfShares,
      pricePerShare: shareholding.pricePerShare,
      date: shareholding.dateAcquired,
      notes: shareholding.notes,
    );
    _transactions.add(transaction);

    await _save();
    notifyListeners();
  }

  Future<void> updateShareholding(Shareholding shareholding) async {
    final index = _shareholdings.indexWhere((s) => s.id == shareholding.id);
    if (index != -1) {
      _shareholdings[index] = shareholding;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteShareholding(String id) async {
    _shareholdings.removeWhere((s) => s.id == id);
    // Also remove any vesting schedules linked to this shareholding
    _vestingSchedules.removeWhere((v) => v.shareholdingId == id);
    // Note: We keep the transaction for audit trail, but could remove if needed
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

  VestingSchedule? getVestingByShareholding(String shareholdingId) {
    try {
      return _vestingSchedules.firstWhere(
        (v) => v.shareholdingId == shareholdingId,
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
    final investorShareholdings = _shareholdings
        .where((s) => s.investorId == investorId)
        .map((s) => s.id)
        .toSet();
    return _vestingSchedules
        .where((v) => investorShareholdings.contains(v.shareholdingId))
        .toList();
  }

  // Get vested shares for a shareholding
  int getVestedShares(String shareholdingId) {
    final shareholding = _shareholdings.firstWhere(
      (s) => s.id == shareholdingId,
      orElse: () => throw Exception('Shareholding not found'),
    );
    final vesting = getVestingByShareholding(shareholdingId);
    if (vesting == null) {
      return shareholding.numberOfShares; // No vesting = fully vested
    }
    return (shareholding.numberOfShares * vesting.vestingPercentage / 100)
        .round();
  }

  // Get unvested shares for a shareholding
  int getUnvestedShares(String shareholdingId) {
    final shareholding = _shareholdings.firstWhere(
      (s) => s.id == shareholdingId,
      orElse: () => throw Exception('Shareholding not found'),
    );
    final vesting = getVestingByShareholding(shareholdingId);
    if (vesting == null) return 0; // No vesting = fully vested
    return shareholding.numberOfShares - getVestedShares(shareholdingId);
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

  List<Shareholding> getShareholdingsByInvestor(String investorId) {
    return _shareholdings.where((s) => s.investorId == investorId).toList();
  }

  List<Shareholding> getShareholdingsByRound(String roundId) {
    return _shareholdings.where((s) => s.roundId == roundId).toList();
  }

  double getAmountRaisedByRound(String roundId) {
    return _shareholdings
        .where((s) => s.roundId == roundId)
        .fold(0.0, (sum, s) => sum + s.amountInvested);
  }

  int getSharesIssuedByRound(String roundId) {
    return _shareholdings
        .where((s) => s.roundId == roundId)
        .fold(0, (sum, s) => sum + s.numberOfShares);
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
    _shareholdings = [];
    _vestingSchedules = [];
    _shareSales = [];
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

  // Share Sale CRUD (legacy - kept for compatibility)
  Future<void> addShareSale(ShareSale sale) async {
    _shareSales.add(sale);
    await _save();
    notifyListeners();
  }

  Future<void> updateShareSale(ShareSale sale) async {
    final index = _shareSales.indexWhere((s) => s.id == sale.id);
    if (index != -1) {
      _shareSales[index] = sale;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteShareSale(String id) async {
    _shareSales.removeWhere((s) => s.id == id);
    await _save();
    notifyListeners();
  }

  ShareSale? getShareSaleById(String id) {
    try {
      return _shareSales.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ShareSale> getSalesByInvestor(String investorId) {
    return _shareSales.where((s) => s.investorId == investorId).toList();
  }

  /// Get transactions for an investor, sorted chronologically
  List<Transaction> getTransactionsByInvestor(String investorId) {
    final investorTransactions = _transactions
        .where((t) => t.investorId == investorId)
        .toList();
    investorTransactions.sort((a, b) => a.date.compareTo(b.date));
    return investorTransactions;
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
}
