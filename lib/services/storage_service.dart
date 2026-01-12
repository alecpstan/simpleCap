import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/investor.dart';
import '../models/share_class.dart';
import '../models/investment_round.dart';
import '../models/shareholding.dart';
import '../models/vesting_schedule.dart';
import '../models/share_sale.dart';

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
    } catch (e) {
      // Return empty data on error
    }
    return {
      'investors': [],
      'shareClasses': [],
      'rounds': [],
      'shareholdings': [],
      'vestingSchedules': [],
      'shareSales': [],
      'companyName': 'My Company Pty Ltd',
      'totalAuthorisedShares': 10000000,
      'tableColumnWidths': <String, double>{},
    };
  }

  Future<void> saveData({
    required List<Investor> investors,
    required List<ShareClass> shareClasses,
    required List<InvestmentRound> rounds,
    required List<Shareholding> shareholdings,
    required List<VestingSchedule> vestingSchedules,
    required List<ShareSale> shareSales,
    required String companyName,
    required int totalAuthorisedShares,
    Map<String, double> tableColumnWidths = const {},
  }) async {
    final file = await _localFile;
    final data = {
      'investors': investors.map((e) => e.toJson()).toList(),
      'shareClasses': shareClasses.map((e) => e.toJson()).toList(),
      'rounds': rounds.map((e) => e.toJson()).toList(),
      'shareholdings': shareholdings.map((e) => e.toJson()).toList(),
      'vestingSchedules': vestingSchedules.map((e) => e.toJson()).toList(),
      'shareSales': shareSales.map((e) => e.toJson()).toList(),
      'companyName': companyName,
      'totalAuthorisedShares': totalAuthorisedShares,
      'tableColumnWidths': tableColumnWidths,
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
