import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/investor.dart';
import '../models/share_class.dart';
import '../models/investment_round.dart';
import '../models/vesting_schedule.dart';
import '../models/transaction.dart';
import '../../convertibles/models/convertible_instrument.dart';
import '../models/milestone.dart';
import '../models/hours_vesting.dart';
import '../models/tax_rule.dart';
import '../../esop/models/option_grant.dart';
import '../../esop/models/esop_pool_change.dart';
import '../../esop/models/warrant.dart';
import '../../valuations/models/valuation.dart';
import '../../scenarios/models/saved_scenario.dart';

class StorageService {
  static const String _fileName = 'cap_table_data.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<Map<String, dynamic>> loadData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents) as Map<String, dynamic>;
      }
    } catch (e, stack) {
      debugPrint('StorageService.loadData error: $e');
      debugPrint('Stack trace: $stack');
    }
    return _defaultData();
  }

  Map<String, dynamic> _defaultData() {
    return {
      'investors': [],
      'shareClasses': [],
      'rounds': [],
      'vestingSchedules': [],
      'transactions': [],
      'convertibles': [],
      'milestones': [],
      'hoursVestingSchedules': [],
      'taxRules': [],
      'optionGrants': [],
      'warrants': [],
      'valuations': [],
      'savedScenarios': [],
      'esopPoolChanges': [],
      'companyName': 'My Company Pty Ltd',
      'tableColumnWidths': <String, double>{},
      'esopDilutionMethod': 1, // preRoundCap
      'esopPoolPercent': 10.0,
      'authorizedShares': 0,
    };
  }

  Future<void> saveData({
    required List<Investor> investors,
    required List<ShareClass> shareClasses,
    required List<InvestmentRound> rounds,
    required List<VestingSchedule> vestingSchedules,
    required List<Transaction> transactions,
    required List<ConvertibleInstrument> convertibles,
    required List<Milestone> milestones,
    required List<HoursVestingSchedule> hoursVestingSchedules,
    required List<TaxRule> taxRules,
    required List<OptionGrant> optionGrants,
    required List<Warrant> warrants,
    required List<Valuation> valuations,
    required List<SavedScenario> savedScenarios,
    required List<EsopPoolChange> esopPoolChanges,
    required String companyName,
    Map<String, double> tableColumnWidths = const {},
    int themeModeIndex = 0,
    int esopDilutionMethod = 1,
    double esopPoolPercent = 10.0,
    int authorizedShares = 0,
  }) async {
    final file = await _localFile;
    final data = {
      'investors': investors.map((e) => e.toJson()).toList(),
      'shareClasses': shareClasses.map((e) => e.toJson()).toList(),
      'rounds': rounds.map((e) => e.toJson()).toList(),
      'vestingSchedules': vestingSchedules.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'convertibles': convertibles.map((e) => e.toJson()).toList(),
      'milestones': milestones.map((e) => e.toJson()).toList(),
      'hoursVestingSchedules': hoursVestingSchedules
          .map((e) => e.toJson())
          .toList(),
      'taxRules': taxRules.map((e) => e.toJson()).toList(),
      'optionGrants': optionGrants.map((e) => e.toJson()).toList(),
      'warrants': warrants.map((e) => e.toJson()).toList(),
      'valuations': valuations.map((e) => e.toJson()).toList(),
      'savedScenarios': savedScenarios.map((e) => e.toJson()).toList(),
      'esopPoolChanges': esopPoolChanges.map((e) => e.toJson()).toList(),
      'companyName': companyName,
      'tableColumnWidths': tableColumnWidths,
      'themeModeIndex': themeModeIndex,
      'esopDilutionMethod': esopDilutionMethod,
      'esopPoolPercent': esopPoolPercent,
      'authorizedShares': authorizedShares,
    };
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> clearData() async {
    final file = await _localFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
