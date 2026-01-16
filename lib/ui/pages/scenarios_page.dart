import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';

class ScenariosPage extends ConsumerStatefulWidget {
  const ScenariosPage({super.key});

  @override
  ConsumerState<ScenariosPage> createState() => _ScenariosPageState();
}

class _ScenariosPageState extends ConsumerState<ScenariosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Scenarios & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_down), text: 'Dilution'),
            Tab(icon: Icon(Icons.waterfall_chart), text: 'Waterfall'),
            Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DilutionCalculatorTab(),
          _WaterfallCalculatorTab(),
          _SavedScenariosTab(),
        ],
      ),
    );
  }
}

// =============================================================================
// DILUTION CALCULATOR TAB
// =============================================================================

class _DilutionCalculatorTab extends ConsumerStatefulWidget {
  const _DilutionCalculatorTab();

  @override
  ConsumerState<_DilutionCalculatorTab> createState() =>
      _DilutionCalculatorTabState();
}

class _DilutionCalculatorTabState
    extends ConsumerState<_DilutionCalculatorTab> {
  final _formKey = GlobalKey<FormState>();
  final _investmentController = TextEditingController(text: '5000000');
  final _preMoneyController = TextEditingController(text: '15000000');
  final _optionPoolController = TextEditingController(text: '10');

  bool _includeUnconvertedSafes = true;
  bool _includeUnexercisedOptions = true;
  DilutionSummary? _result;

  @override
  void dispose() {
    _investmentController.dispose();
    _preMoneyController.dispose();
    _optionPoolController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final scenario = DilutionScenario(
      newInvestment: double.parse(_investmentController.text),
      preMoneyValuation: double.parse(_preMoneyController.text),
      optionPoolIncrease: double.parse(_optionPoolController.text),
      includeUnconvertedSafes: _includeUnconvertedSafes,
      includeUnexercisedOptions: _includeUnexercisedOptions,
    );

    final result = await ref.read(calculateDilutionProvider(scenario).future);
    setState(() => _result = result);
  }

  Future<void> _saveScenario() async {
    if (_result == null) return;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => _SaveScenarioDialog(
        defaultName:
            'Dilution - \$${NumberFormat.compact().format(double.parse(_investmentController.text))} @ \$${NumberFormat.compact().format(double.parse(_preMoneyController.text))}',
      ),
    );

    if (name == null || !mounted) return;

    final company = ref.read(currentCompanyProvider).value;
    if (company == null) return;

    final parametersJson = jsonEncode({
      'input': {
        'newInvestment': double.parse(_investmentController.text),
        'preMoneyValuation': double.parse(_preMoneyController.text),
        'optionPoolIncrease': double.parse(_optionPoolController.text),
        'includeUnconvertedSafes': _includeUnconvertedSafes,
        'includeUnexercisedOptions': _includeUnexercisedOptions,
      },
      'result': {
        'currentTotalShares': _result!.currentTotalShares,
        'newSharesIssued': _result!.newSharesIssued,
        'postRoundTotalShares': _result!.postRoundTotalShares,
        'newInvestorOwnership': _result!.newInvestorOwnership,
        'optionPoolOwnership': _result!.optionPoolOwnership,
        'stakeholderResults': _result!.stakeholderResults
            .map(
              (r) => {
                'stakeholderId': r.stakeholderId,
                'stakeholderName': r.stakeholderName,
                'currentShares': r.currentShares,
                'currentOwnership': r.currentOwnership,
                'postRoundShares': r.postRoundShares,
                'postRoundOwnership': r.postRoundOwnership,
                'dilutionPercent': r.dilutionPercent,
              },
            )
            .toList(),
      },
    });

    await ref
        .read(scenarioMutationsProvider.notifier)
        .save(
          companyId: company.id,
          name: name,
          type: 'dilution',
          parametersJson: parametersJson,
        );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Scenario saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Round Parameters',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _investmentController,
                      decoration: const InputDecoration(
                        labelText: 'Investment Amount',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _preMoneyController,
                      decoration: const InputDecoration(
                        labelText: 'Pre-Money Valuation',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _optionPoolController,
                      decoration: const InputDecoration(
                        labelText: 'Option Pool Increase',
                        suffixText: '%',
                        helperText: 'Percentage of post-money',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null) return 'Invalid';
                        if (val < 0 || val > 50) return '0-50%';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Include Unconverted SAFEs'),
                      subtitle: const Text(
                        'Model SAFE conversion in this round',
                      ),
                      value: _includeUnconvertedSafes,
                      onChanged: (v) =>
                          setState(() => _includeUnconvertedSafes = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('Include Unexercised Options'),
                      subtitle: const Text(
                        'Assume all vested options exercise',
                      ),
                      value: _includeUnexercisedOptions,
                      onChanged: (v) =>
                          setState(() => _includeUnexercisedOptions = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _calculate,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate Dilution'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Results',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: _saveScenario,
                          tooltip: 'Save Scenario',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ResultRow(
                      label: 'Post-Money Valuation',
                      value: currencyFormat.format(
                        double.parse(_preMoneyController.text) +
                            double.parse(_investmentController.text),
                      ),
                    ),
                    _ResultRow(
                      label: 'Current Total Shares',
                      value: NumberFormat.decimalPattern().format(
                        _result!.currentTotalShares,
                      ),
                    ),
                    _ResultRow(
                      label: 'New Shares Issued',
                      value: NumberFormat.decimalPattern().format(
                        _result!.newSharesIssued,
                      ),
                    ),
                    _ResultRow(
                      label: 'Post-Round Total Shares',
                      value: NumberFormat.decimalPattern().format(
                        _result!.postRoundTotalShares,
                      ),
                    ),
                    const Divider(),
                    _ResultRow(
                      label: 'New Investor Ownership',
                      value:
                          '${_result!.newInvestorOwnership.toStringAsFixed(1)}%',
                    ),
                    if (_result!.optionPoolOwnership > 0)
                      _ResultRow(
                        label: 'Option Pool',
                        value:
                            '${_result!.optionPoolOwnership.toStringAsFixed(1)}%',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Ownership Changes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Stakeholder')),
                        DataColumn(label: Text('Before'), numeric: true),
                        DataColumn(label: Text('After'), numeric: true),
                        DataColumn(label: Text('Dilution'), numeric: true),
                      ],
                      rows: _result!.stakeholderResults.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(Text(r.stakeholderName)),
                            DataCell(
                              Text('${r.currentOwnership.toStringAsFixed(1)}%'),
                            ),
                            DataCell(
                              Text(
                                '${r.postRoundOwnership.toStringAsFixed(1)}%',
                              ),
                            ),
                            DataCell(
                              Text(
                                '-${r.dilutionPercent.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

// =============================================================================
// WATERFALL CALCULATOR TAB
// =============================================================================

class _WaterfallCalculatorTab extends ConsumerStatefulWidget {
  const _WaterfallCalculatorTab();

  @override
  ConsumerState<_WaterfallCalculatorTab> createState() =>
      _WaterfallCalculatorTabState();
}

class _WaterfallCalculatorTabState
    extends ConsumerState<_WaterfallCalculatorTab> {
  final _formKey = GlobalKey<FormState>();
  final _exitValueController = TextEditingController(text: '50000000');
  final _transactionCostsController = TextEditingController(text: '2.0');

  bool _isAcquisition = true;
  WaterfallSummary? _result;

  @override
  void dispose() {
    _exitValueController.dispose();
    _transactionCostsController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final scenario = ExitScenario(
      exitValuation: double.parse(_exitValueController.text),
      transactionCosts: double.parse(_transactionCostsController.text),
      isAcquisition: _isAcquisition,
    );

    final result = await ref.read(calculateWaterfallProvider(scenario).future);
    setState(() => _result = result);
  }

  Future<void> _saveScenario() async {
    if (_result == null) return;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => _SaveScenarioDialog(
        defaultName:
            'Exit @ ${NumberFormat.compactCurrency(symbol: '\$').format(_result!.exitValuation)}',
      ),
    );

    if (name == null || !mounted) return;

    final company = ref.read(currentCompanyProvider).value;
    if (company == null) return;

    final parametersJson = jsonEncode({
      'input': {
        'exitValuation': double.parse(_exitValueController.text),
        'transactionCosts': double.parse(_transactionCostsController.text),
        'isAcquisition': _isAcquisition,
      },
      'result': {
        'exitValuation': _result!.exitValuation,
        'netProceeds': _result!.netProceeds,
        'totalLiquidationPreferences': _result!.totalLiquidationPreferences,
        'remainingForCommon': _result!.remainingForCommon,
        'stakeholderResults': _result!.stakeholderResults
            .map(
              (r) => {
                'stakeholderId': r.stakeholderId,
                'stakeholderName': r.stakeholderName,
                'shareClassName': r.shareClassName,
                'shares': r.shares,
                'ownershipPercent': r.ownershipPercent,
                'liquidationPreference': r.liquidationPreference,
                'totalProceeds': r.totalProceeds,
                'returnMultiple': r.returnMultiple,
              },
            )
            .toList(),
      },
    });

    await ref
        .read(scenarioMutationsProvider.notifier)
        .save(
          companyId: company.id,
          name: name,
          type: 'waterfall',
          parametersJson: parametersJson,
        );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Scenario saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exit Parameters',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _exitValueController,
                      decoration: const InputDecoration(
                        labelText: 'Exit Value (Sale Price)',
                        prefixText: '\$ ',
                        helperText: 'Total company sale price',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _transactionCostsController,
                      decoration: const InputDecoration(
                        labelText: 'Transaction Costs',
                        suffixText: '%',
                        helperText: 'Fees deducted from proceeds',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null) return 'Invalid';
                        if (val < 0 || val > 20) return '0-20%';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Acquisition'),
                          icon: Icon(Icons.handshake),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('IPO'),
                          icon: Icon(Icons.trending_up),
                        ),
                      ],
                      selected: {_isAcquisition},
                      onSelectionChanged: (v) =>
                          setState(() => _isAcquisition = v.first),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _calculate,
                        icon: const Icon(Icons.waterfall_chart),
                        label: const Text('Calculate Waterfall'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Distribution Summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: _saveScenario,
                          tooltip: 'Save Scenario',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ResultRow(
                      label: 'Exit Value',
                      value: currencyFormat.format(_result!.exitValuation),
                    ),
                    _ResultRow(
                      label: 'Net Proceeds',
                      value: currencyFormat.format(_result!.netProceeds),
                    ),
                    _ResultRow(
                      label: 'Total Liquidation Preferences',
                      value: currencyFormat.format(
                        _result!.totalLiquidationPreferences,
                      ),
                    ),
                    _ResultRow(
                      label: 'Remaining for Common',
                      value: currencyFormat.format(_result!.remainingForCommon),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Proceeds by Stakeholder',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ..._result!.stakeholderResults.map((r) {
                    return ListTile(
                      title: Text(r.stakeholderName),
                      subtitle: Text(r.shareClassName),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(r.totalProceeds),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            '${r.returnMultiple.toStringAsFixed(2)}x',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: r.returnMultiple >= 1
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Waterfall Breakdown',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Stakeholder')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Shares'), numeric: true),
                        DataColumn(label: Text('Liq. Pref'), numeric: true),
                        DataColumn(label: Text('Proceeds'), numeric: true),
                        DataColumn(label: Text('Return'), numeric: true),
                      ],
                      rows: _result!.stakeholderResults.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(Text(r.stakeholderName)),
                            DataCell(Text(r.shareClassName)),
                            DataCell(
                              Text(NumberFormat.compact().format(r.shares)),
                            ),
                            DataCell(
                              Text(
                                currencyFormat.format(r.liquidationPreference),
                              ),
                            ),
                            DataCell(
                              Text(currencyFormat.format(r.totalProceeds)),
                            ),
                            DataCell(
                              Text(
                                '${r.returnMultiple.toStringAsFixed(2)}x',
                                style: TextStyle(
                                  color: r.returnMultiple >= 1
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// SAVED SCENARIOS TAB
// =============================================================================

class _SavedScenariosTab extends ConsumerWidget {
  const _SavedScenariosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(savedScenariosStreamProvider);

    return scenariosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (scenarios) {
        if (scenarios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No saved scenarios',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Run a dilution or waterfall calculation\nand save it for future reference',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scenarios.length,
          itemBuilder: (context, index) {
            final scenario = scenarios[index];
            return _SavedScenarioCard(scenario: scenario);
          },
        );
      },
    );
  }
}

class _SavedScenarioCard extends ConsumerWidget {
  const _SavedScenarioCard({required this.scenario});

  final SavedScenario scenario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scenario.type == 'dilution'
              ? Colors.orange.shade100
              : Colors.blue.shade100,
          child: Icon(
            scenario.type == 'dilution'
                ? Icons.trending_down
                : Icons.waterfall_chart,
            color: scenario.type == 'dilution'
                ? Colors.orange.shade700
                : Colors.blue.shade700,
          ),
        ),
        title: Text(scenario.name),
        subtitle: Text(
          '${scenario.type.toUpperCase()} • ${dateFormat.format(scenario.createdAt)}',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Details'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'view') {
              _showScenarioDetails(context, scenario);
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Scenario?'),
                  content: Text('Delete "${scenario.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(scenarioMutationsProvider.notifier)
                    .delete(scenario.id);
              }
            }
          },
        ),
        onTap: () => _showScenarioDetails(context, scenario),
      ),
    );
  }

  void _showScenarioDetails(BuildContext context, SavedScenario scenario) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(scenario.parametersJson) as Map<String, dynamic>;
    } catch (_) {
      data = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  scenario.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(scenario.type.toUpperCase()),
                  avatar: Icon(
                    scenario.type == 'dilution'
                        ? Icons.trending_down
                        : Icons.waterfall_chart,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (data != null && data['input'] != null) ...[
                        Text(
                          'Input Parameters',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ..._buildDetailsFromMap(
                          data['input'] as Map<String, dynamic>,
                          currencyFormat,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (data != null && data['result'] != null) ...[
                        Text(
                          'Results',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ..._buildDetailsFromMap(
                          data['result'] as Map<String, dynamic>,
                          currencyFormat,
                          skipLists: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDetailsFromMap(
    Map<String, dynamic> data,
    NumberFormat currencyFormat, {
    bool skipLists = false,
  }) {
    final widgets = <Widget>[];
    data.forEach((key, value) {
      if (skipLists && value is List) return;

      String displayValue;
      if (value is double) {
        if (key.contains('Investment') ||
            key.contains('Valuation') ||
            key.contains('Value') ||
            key.contains('Proceeds') ||
            key.contains('Preference') ||
            key.contains('Remaining')) {
          displayValue = currencyFormat.format(value);
        } else if (key.contains('Percent') ||
            key.contains('Ownership') ||
            key.contains('Costs')) {
          displayValue = '${value.toStringAsFixed(1)}%';
        } else if (key.contains('Multiple')) {
          displayValue = '${value.toStringAsFixed(2)}x';
        } else {
          displayValue = value.toStringAsFixed(2);
        }
      } else if (value is int) {
        displayValue = NumberFormat.decimalPattern().format(value);
      } else if (value is bool) {
        displayValue = value ? 'Yes' : 'No';
      } else {
        displayValue = value.toString();
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(_formatKey(key)), Text(displayValue)],
          ),
        ),
      );
    });
    return widgets;
  }

  String _formatKey(String key) {
    // Convert camelCase to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .trim()
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

// =============================================================================
// SAVE SCENARIO DIALOG
// =============================================================================

class _SaveScenarioDialog extends StatefulWidget {
  const _SaveScenarioDialog({required this.defaultName});

  final String defaultName;

  @override
  State<_SaveScenarioDialog> createState() => _SaveScenarioDialogState();
}

class _SaveScenarioDialogState extends State<_SaveScenarioDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Scenario'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Scenario Name'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
