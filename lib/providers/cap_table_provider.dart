import 'package:flutter/foundation.dart';
import '../models/investor.dart';
import '../models/share_class.dart';
import '../models/investment_round.dart';
import '../models/shareholding.dart';
import '../models/vesting_schedule.dart';
import '../models/share_sale.dart';
import '../services/storage_service.dart';

class CapTableProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Investor> _investors = [];
  List<ShareClass> _shareClasses = [];
  List<InvestmentRound> _rounds = [];
  List<Shareholding> _shareholdings = [];
  List<VestingSchedule> _vestingSchedules = [];
  List<ShareSale> _shareSales = [];
  String _companyName = 'My Company Pty Ltd';
  int _totalAuthorisedShares = 10000000;
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
  String get companyName => _companyName;
  int get totalAuthorisedShares => _totalAuthorisedShares;
  bool get isLoading => _isLoading;
  Map<String, double> get tableColumnWidths =>
      Map.unmodifiable(_tableColumnWidths);

  // Calculated properties
  int get totalIssuedShares =>
      _shareholdings.fold(0, (sum, s) => sum + s.numberOfShares);

  int get totalSharesSold =>
      _shareSales.fold(0, (sum, s) => sum + s.numberOfShares);

  int get totalCurrentShares => totalIssuedShares - totalSharesSold;

  double get totalInvested =>
      _shareholdings.fold(0.0, (sum, s) => sum + s.amountInvested);

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

    final data = await _storageService.loadData();

    _investors = (data['investors'] as List)
        .map((e) => Investor.fromJson(e))
        .toList();
    _shareClasses = (data['shareClasses'] as List)
        .map((e) => ShareClass.fromJson(e))
        .toList();
    _rounds = (data['rounds'] as List)
        .map((e) => InvestmentRound.fromJson(e))
        .toList();
    _shareholdings = (data['shareholdings'] as List)
        .map((e) => Shareholding.fromJson(e))
        .toList();
    _vestingSchedules = (data['vestingSchedules'] as List? ?? [])
        .map((e) => VestingSchedule.fromJson(e))
        .toList();
    _shareSales = (data['shareSales'] as List? ?? [])
        .map((e) => ShareSale.fromJson(e))
        .toList();
    _companyName = data['companyName'] ?? 'My Company Pty Ltd';
    _totalAuthorisedShares = data['totalAuthorisedShares'] ?? 10000000;
    _tableColumnWidths =
        (data['tableColumnWidths'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ??
        {};

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
      shareholdings: _shareholdings,
      vestingSchedules: _vestingSchedules,
      shareSales: _shareSales,
      companyName: _companyName,
      totalAuthorisedShares: _totalAuthorisedShares,
      tableColumnWidths: _tableColumnWidths,
    );
  }

  // Company settings
  Future<void> updateCompanyName(String name) async {
    _companyName = name;
    await _save();
    notifyListeners();
  }

  Future<void> updateTotalAuthorisedShares(int shares) async {
    _totalAuthorisedShares = shares;
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
    for (var shareholding in _shareholdings) {
      sharesByClass[shareholding.shareClassId] =
          (sharesByClass[shareholding.shareClassId] ?? 0) +
          shareholding.numberOfShares;
    }

    // Subtract sold shares by class
    for (var sale in _shareSales) {
      sharesByClass[sale.shareClassId] =
          (sharesByClass[sale.shareClassId] ?? 0) - sale.numberOfShares;
    }

    // Remove classes with no current shares
    sharesByClass.removeWhere((key, value) => value <= 0);

    final total = totalCurrentShares;
    if (total == 0) return {};

    return sharesByClass.map(
      (id, shares) => MapEntry(id, shares / total * 100),
    );
  }

  int getSharesByInvestor(String investorId) {
    return _shareholdings
        .where((s) => s.investorId == investorId)
        .fold(0, (sum, s) => sum + s.numberOfShares);
  }

  double getInvestmentByInvestor(String investorId) {
    return _shareholdings
        .where((s) => s.investorId == investorId)
        .fold(0.0, (sum, s) => sum + s.amountInvested);
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
    _companyName = 'My Company Pty Ltd';
    _totalAuthorisedShares = 10000000;
    await _storageService.clearData();
    await loadData(); // Reinitialize defaults
  }

  // Share Sale CRUD
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

  // Get total shares sold by an investor
  int getSharesSoldByInvestor(String investorId) {
    return _shareSales
        .where((s) => s.investorId == investorId)
        .fold(0, (sum, s) => sum + s.numberOfShares);
  }

  // Get total proceeds from sales for an investor
  double getSaleProceedsByInvestor(String investorId) {
    return _shareSales
        .where((s) => s.investorId == investorId)
        .fold(0.0, (sum, s) => sum + s.totalProceeds);
  }

  // Get current shares (original minus sold)
  int getCurrentSharesByInvestor(String investorId) {
    final acquired = getSharesByInvestor(investorId);
    final sold = getSharesSoldByInvestor(investorId);
    return acquired - sold;
  }

  // Check if investor has fully exited
  bool hasInvestorExited(String investorId) {
    return getCurrentSharesByInvestor(investorId) <= 0 &&
        getSharesByInvestor(investorId) > 0;
  }

  // Get exited investors
  List<Investor> get exitedInvestors {
    return _investors.where((i) => hasInvestorExited(i.id)).toList();
  }

  // Get active investors (have current shares)
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

  // Calculate realized profit (from sales only)
  double getRealizedProfitByInvestor(String investorId) {
    final sales = getSalesByInvestor(investorId);
    if (sales.isEmpty) return 0;

    // Calculate cost basis of sold shares (weighted average)
    final shareholdings = getShareholdingsByInvestor(investorId);
    if (shareholdings.isEmpty) return 0;

    final totalShares = shareholdings.fold(
      0,
      (sum, s) => sum + s.numberOfShares,
    );
    final totalCost = shareholdings.fold(
      0.0,
      (sum, s) => sum + s.amountInvested,
    );
    final avgCostPerShare = totalShares > 0 ? totalCost / totalShares : 0;

    final totalSold = getSharesSoldByInvestor(investorId);
    final costOfSoldShares = totalSold * avgCostPerShare;
    final proceeds = getSaleProceedsByInvestor(investorId);

    return proceeds - costOfSoldShares;
  }
}
