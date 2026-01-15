import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/share_class.dart';
import '../../core/providers/core_cap_table_provider.dart';
import '../providers/scenarios_provider.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/info_widgets.dart';
import '../../../shared/widgets/avatars.dart';
import '../widgets/valuation_wizard.dart';
import '../../../shared/widgets/help_icon.dart';
import '../../../shared/utils/helpers.dart';

class ScenariosPage extends StatefulWidget {
  const ScenariosPage({super.key});

  @override
  State<ScenariosPage> createState() => _ScenariosPageState();
}

class _ScenariosPageState extends State<ScenariosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dilution Calculator
  final _newSharesController = TextEditingController();
  final _newInvestmentController = TextEditingController();
  final _preMoneyController = TextEditingController();
  Map<String, double> _dilutionResults = {};
  double _newOwnershipPercentage = 0;
  double _impliedSharePrice = 0;

  // Exit Waterfall
  final _exitValuationController = TextEditingController();
  List<WaterfallRow> _waterfallResults = [];

  // New Round Simulation
  final _simRoundNameController = TextEditingController();
  final _simRaiseAmountController = TextEditingController();
  final _simPreMoneyController = TextEditingController();
  double _simEsopExpansion = 0;
  List<_SimulationResult> _simulationResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _exitValuationController.text = '10000000'; // Default $10M exit
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newSharesController.dispose();
    _newInvestmentController.dispose();
    _preMoneyController.dispose();
    _exitValuationController.dispose();
    _simRoundNameController.dispose();
    _simRaiseAmountController.dispose();
    _simPreMoneyController.dispose();
    super.dispose();
  }

  void _calculateDilution(CoreCapTableProvider provider) {
    final newShares = double.tryParse(_newSharesController.text) ?? 0;

    if (newShares > 0) {
      setState(() {
        _dilutionResults = provider.calculateDilutionFromNewRound(newShares);
        final currentTotal = provider.totalCurrentShares;
        final newTotal = currentTotal + newShares;
        _newOwnershipPercentage = (newShares / newTotal) * 100;

        final investment = double.tryParse(_newInvestmentController.text) ?? 0;
        if (investment > 0 && newShares > 0) {
          _impliedSharePrice = investment / newShares;
        }
      });
    }
  }

  void _calculateFromValuation(CoreCapTableProvider provider) {
    final preMoney = double.tryParse(_preMoneyController.text) ?? 0;
    final investment = double.tryParse(_newInvestmentController.text) ?? 0;

    if (preMoney > 0 && investment > 0) {
      final postMoney = preMoney + investment;
      final newOwnership = investment / postMoney;
      final currentShares = provider.totalCurrentShares;

      // New shares = current shares * (new ownership / (1 - new ownership))
      if (newOwnership < 1) {
        final newShares = currentShares * (newOwnership / (1 - newOwnership));
        _newSharesController.text = newShares.round().toString();
        _calculateDilution(provider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scenarios'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calculate), text: 'Dilution'),
            Tab(icon: Icon(Icons.waterfall_chart), text: 'Exit Waterfall'),
            Tab(icon: Icon(Icons.science), text: 'New Round'),
          ],
        ),
      ),
      body: Consumer2<CoreCapTableProvider, ScenariosProvider>(
        builder: (context, coreProvider, scenariosProvider, child) {
          if (coreProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDilutionTab(coreProvider, scenariosProvider),
              _buildExitWaterfallTab(coreProvider),
              _buildNewRoundSimulatorTab(coreProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDilutionTab(
    CoreCapTableProvider provider,
    ScenariosProvider scenariosProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dilution Calculator
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Dilution Calculator',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const HelpIcon(helpKey: 'dilution.dilution'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'See how a new funding round would affect existing shareholders',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Current state info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Shares'),
                              Text(
                                Formatters.number(provider.totalCurrentShares),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Valuation'),
                              Text(
                                Formatters.compactCurrency(
                                  provider.latestValuation,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input method 1: By shares
                  Text(
                    'Calculate by New Shares:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newSharesController,
                          decoration: const InputDecoration(
                            labelText: 'New Shares to Issue',
                            hintText: '1000000',
                            prefixIcon: Icon(Icons.pie_chart),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _calculateDilution(provider),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _newInvestmentController,
                          decoration: const InputDecoration(
                            labelText: 'Investment Amount (AUD)',
                            hintText: '500000',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _calculateDilution(provider),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Input method 2: By valuation
                  Text(
                    'Or Calculate by Valuation:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _preMoneyController,
                          decoration: InputDecoration(
                            labelText: 'Pre-Money Valuation (AUD)',
                            hintText: '5000000',
                            prefixIcon: const Icon(Icons.trending_up),
                            suffixIcon: ValuationWizardButton(
                              currentValuation: double.tryParse(
                                _preMoneyController.text,
                              ),
                              onValuationSelected: (value) {
                                _preMoneyController.text = value
                                    .round()
                                    .toString();
                                _calculateFromValuation(provider);
                              },
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: () => _calculateFromValuation(provider),
                        child: const Text('Calculate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results
          if (_dilutionResults.isNotEmpty) ...[
            SectionCard(
              title: 'New Round Summary',
              helpKey: 'rounds.fundingRound',
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  ResultChip(
                    label: 'New Investor Ownership',
                    value: Formatters.percent(_newOwnershipPercentage),
                    color: Colors.green,
                  ),
                  if (_impliedSharePrice > 0)
                    ResultChip(
                      label: 'Implied Share Price',
                      value: Formatters.currency(_impliedSharePrice),
                      color: Colors.blue,
                    ),
                  ResultChip(
                    label: 'Post-Round Shares',
                    value: Formatters.number(
                      provider.totalCurrentShares +
                          (int.tryParse(_newSharesController.text) ?? 0),
                    ),
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Dilution Impact on Existing Shareholders',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Investor')),
                    DataColumn(label: Text('Current %'), numeric: true),
                    DataColumn(label: Text('After Round %'), numeric: true),
                    DataColumn(label: Text('Dilution'), numeric: true),
                  ],
                  rows: _dilutionResults.entries.map((entry) {
                    final investor = provider.getInvestorById(entry.key);
                    final currentOwnership = provider.getOwnershipPercentage(
                      entry.key,
                    );
                    final newOwnership = currentOwnership - entry.value;

                    return DataRow(
                      cells: [
                        DataCell(Text(investor?.name ?? 'Unknown')),
                        DataCell(Text(Formatters.percent(currentOwnership))),
                        DataCell(Text(Formatters.percent(newOwnership))),
                        DataCell(
                          Text(
                            '-${Formatters.percent(entry.value)}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Pro-rata Calculator
          SectionCard(
            title: 'Pro-Rata Rights',
            icon: Icons.balance,
            helpKey: 'investors.proRataRights',
            subtitle:
                'How much each investor with pro-rata rights can invest to maintain their ownership',
            child:
                provider.activeInvestors
                    .where((i) => i.hasProRataRights)
                    .isEmpty
                ? const Text('No active investors with pro-rata rights')
                : Column(children: _buildProRataList(provider)),
          ),
        ],
      ),
    );
  }

  // === Exit Waterfall Tab ===
  Widget _buildExitWaterfallTab(CoreCapTableProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.waterfall_chart, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Exit Waterfall Calculator',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const HelpIcon(helpKey: 'scenarios.exitWaterfall'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'See how proceeds would be distributed based on share class preferences',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _exitValuationController,
                          decoration: const InputDecoration(
                            labelText: 'Exit Valuation (AUD)',
                            hintText: '10000000',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: () => _calculateExitWaterfall(provider),
                        child: const Text('Calculate Waterfall'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_waterfallResults.isNotEmpty) ...[
            SectionCard(
              title: 'Distribution Waterfall',
              helpKey: 'scenarios.exitWaterfall',
              child: Column(
                children: [
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Exit Valuation'),
                              Text(
                                Formatters.compactCurrency(
                                  double.tryParse(
                                        _exitValuationController.text,
                                      ) ??
                                      0,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Distributed'),
                              Text(
                                Formatters.compactCurrency(
                                  _waterfallResults.fold(
                                    0.0,
                                    (sum, r) => sum + r.proceeds,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Waterfall table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Investor')),
                        DataColumn(label: Text('Share Class')),
                        DataColumn(label: Text('Shares'), numeric: true),
                        DataColumn(label: Text('% Ownership'), numeric: true),
                        DataColumn(label: Text('Proceeds'), numeric: true),
                        DataColumn(label: Text('Multiple'), numeric: true),
                      ],
                      rows: _waterfallResults
                          .map(
                            (row) => DataRow(
                              cells: [
                                DataCell(Text(row.investorName)),
                                DataCell(Text(row.shareClassName)),
                                DataCell(Text(Formatters.number(row.shares))),
                                DataCell(
                                  Text(
                                    Formatters.percent(row.ownershipPercent),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    Formatters.currency(row.proceeds),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${row.multiple.toStringAsFixed(1)}x',
                                    style: TextStyle(
                                      color: row.multiple >= 1
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
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

  void _calculateExitWaterfall(CoreCapTableProvider provider) {
    final exitValue = double.tryParse(_exitValuationController.text) ?? 0;
    if (exitValue <= 0) return;

    final results = <WaterfallRow>[];
    final totalShares = provider.totalCurrentShares;
    if (totalShares == 0) return;

    // Build investor holdings with share class info
    final investorHoldings = <_InvestorHolding>[];
    for (final investor in provider.activeInvestors) {
      final transactions = provider
          .getTransactionsByInvestor(investor.id)
          .where((t) => t.isAcquisition);

      // Group shares by share class
      final sharesByClass = <String, int>{};
      final investmentByClass = <String, double>{};
      for (final t in transactions) {
        sharesByClass[t.shareClassId] =
            (sharesByClass[t.shareClassId] ?? 0) + t.numberOfShares;
        investmentByClass[t.shareClassId] =
            (investmentByClass[t.shareClassId] ?? 0) + t.totalAmount;
      }

      // Handle sold shares (reduce proportionally)
      final soldShares = provider
          .getTransactionsByInvestor(investor.id)
          .where((t) => t.isDisposal)
          .fold(0, (sum, t) => sum + t.numberOfShares);

      final originalTotal = sharesByClass.values.fold(0, (a, b) => a + b);
      final ratio = originalTotal > 0
          ? (originalTotal - soldShares) / originalTotal
          : 0.0;

      for (final entry in sharesByClass.entries) {
        final shareClass = provider.getShareClassById(entry.key);
        if (shareClass == null) continue;

        final adjustedShares = (entry.value * ratio).round();
        if (adjustedShares <= 0) continue;

        investorHoldings.add(
          _InvestorHolding(
            investorId: investor.id,
            investorName: investor.name,
            shareClass: shareClass,
            shares: adjustedShares,
            invested: (investmentByClass[entry.key] ?? 0) * ratio,
          ),
        );
      }
    }

    // Calculate proceeds using waterfall
    final proceeds = <String, double>{}; // investorId -> total proceeds
    var remainingValue = exitValue;

    // Step 1: Pay liquidation preferences by seniority (highest first)
    final seniorityLevels =
        investorHoldings.map((h) => h.shareClass.seniority).toSet().toList()
          ..sort((a, b) => b.compareTo(a)); // Descending

    for (final seniority in seniorityLevels) {
      if (remainingValue <= 0) break;

      final holdingsAtLevel = investorHoldings
          .where((h) => h.shareClass.seniority == seniority)
          .toList();

      // Calculate total preference due at this level (including accrued dividends)
      double totalPreferenceDue = 0;
      for (final h in holdingsAtLevel) {
        if (h.shareClass.liquidationPreference > 0) {
          // Base preference
          var preference = h.invested * h.shareClass.liquidationPreference;
          // Add accrued dividends if any
          if (h.shareClass.dividendRate > 0) {
            final dividends = provider.getAccruedDividendsByInvestor(
              h.investorId,
            );
            // Proportional dividends for this holding
            final totalInvested = provider.getInvestmentByInvestor(
              h.investorId,
            );
            if (totalInvested > 0) {
              preference += dividends * (h.invested / totalInvested);
            }
          }
          totalPreferenceDue += preference;
        }
      }

      if (totalPreferenceDue > 0) {
        // Pay out preferences (may be pro-rata if not enough)
        final payoutRatio = remainingValue >= totalPreferenceDue
            ? 1.0
            : remainingValue / totalPreferenceDue;

        for (final h in holdingsAtLevel) {
          if (h.shareClass.liquidationPreference > 0) {
            var preference = h.invested * h.shareClass.liquidationPreference;
            // Add accrued dividends
            if (h.shareClass.dividendRate > 0) {
              final dividends = provider.getAccruedDividendsByInvestor(
                h.investorId,
              );
              final totalInvested = provider.getInvestmentByInvestor(
                h.investorId,
              );
              if (totalInvested > 0) {
                preference += dividends * (h.invested / totalInvested);
              }
            }
            final payout = preference * payoutRatio;
            proceeds[h.investorId] = (proceeds[h.investorId] ?? 0) + payout;
            remainingValue -= payout;
          }
        }
      }
    }

    // Step 2: Distribute remaining value pro-rata
    if (remainingValue > 0) {
      // For participating preferred, they get their share too
      // For non-participating, they already got their preference
      double eligibleShares = 0;
      for (final h in investorHoldings) {
        if (h.shareClass.participating ||
            h.shareClass.liquidationPreference == 0) {
          eligibleShares += h.shares;
        }
      }

      if (eligibleShares > 0) {
        final perShare = remainingValue / eligibleShares;
        for (final h in investorHoldings) {
          if (h.shareClass.participating ||
              h.shareClass.liquidationPreference == 0) {
            final proRata = h.shares * perShare;
            proceeds[h.investorId] = (proceeds[h.investorId] ?? 0) + proRata;
          }
        }
      }
    }

    // Build results
    for (final investor in provider.activeInvestors) {
      final investorProceeds = proceeds[investor.id] ?? 0;
      if (investorProceeds <= 0) continue;

      final shares = provider.getCurrentSharesByInvestor(investor.id);
      final ownershipPercent = (shares / totalShares) * 100;
      final invested = provider.getInvestmentByInvestor(investor.id);
      final multiple = invested > 0 ? investorProceeds / invested : 0.0;

      // Get primary share class for display
      final transactions = provider.getTransactionsByInvestor(investor.id);
      String shareClassName = 'Mixed';
      if (transactions.isNotEmpty) {
        final shareClass = provider.getShareClassById(
          transactions.first.shareClassId,
        );
        shareClassName = shareClass?.name ?? 'Unknown';
      }

      results.add(
        WaterfallRow(
          investorName: investor.name,
          shareClassName: shareClassName,
          shares: shares,
          ownershipPercent: ownershipPercent,
          proceeds: investorProceeds,
          multiple: multiple,
        ),
      );
    }

    // Sort by proceeds descending
    results.sort((a, b) => b.proceeds.compareTo(a.proceeds));

    setState(() {
      _waterfallResults = results;
    });
  }

  // === New Round Simulator Tab ===
  Widget _buildNewRoundSimulatorTab(CoreCapTableProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'New Round Simulator',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const HelpIcon(helpKey: 'scenarios.roundSimulator'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Model a new funding round with ESOP expansion',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _simRoundNameController,
                    decoration: const InputDecoration(
                      labelText: 'Round Name',
                      hintText: 'Series A',
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _simRaiseAmountController,
                          decoration: const InputDecoration(
                            labelText: 'Raise Amount (AUD)',
                            hintText: '2000000',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _simPreMoneyController,
                          decoration: const InputDecoration(
                            labelText: 'Pre-Money Valuation',
                            hintText: '8000000',
                            prefixIcon: Icon(Icons.trending_up),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'ESOP Expansion: ${_simEsopExpansion.toStringAsFixed(1)}%',
                                ),
                                const HelpIcon(helpKey: 'esop.poolExpansion'),
                              ],
                            ),
                            Slider(
                              value: _simEsopExpansion,
                              min: 0,
                              max: 15,
                              divisions: 30,
                              label: '${_simEsopExpansion.toStringAsFixed(1)}%',
                              onChanged: (value) {
                                setState(() {
                                  _simEsopExpansion = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: () => _simulateNewRound(provider),
                        child: const Text('Simulate Round'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_simulationResults.isNotEmpty) ...[
            SectionCard(
              title:
                  'Simulation Results: ${_simRoundNameController.text.isEmpty ? "New Round" : _simRoundNameController.text}',
              child: Column(
                children: [
                  // Summary cards
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      ResultChip(
                        label: 'Post-Money Valuation',
                        value: Formatters.compactCurrency(
                          (double.tryParse(_simPreMoneyController.text) ?? 0) +
                              (double.tryParse(
                                    _simRaiseAmountController.text,
                                  ) ??
                                  0),
                        ),
                        color: Colors.green,
                      ),
                      ResultChip(
                        label: 'New Investor Ownership',
                        value: Formatters.percent(
                          _simulationResults
                              .firstWhere(
                                (r) => r.isNewInvestor,
                                orElse: () => _SimulationResult(
                                  name: '',
                                  isNewInvestor: false,
                                  preShares: 0,
                                  postShares: 0,
                                  prePercent: 0,
                                  postPercent: 0,
                                  dilutionPercent: 0,
                                ),
                              )
                              .postPercent,
                        ),
                        color: Colors.blue,
                      ),
                      if (_simEsopExpansion > 0)
                        ResultChip(
                          label: 'ESOP Pool',
                          value: '${_simEsopExpansion.toStringAsFixed(1)}%',
                          color: Colors.purple,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Results table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Stakeholder')),
                        DataColumn(label: Text('Pre-Round %'), numeric: true),
                        DataColumn(label: Text('Post-Round %'), numeric: true),
                        DataColumn(label: Text('Dilution'), numeric: true),
                      ],
                      rows: _simulationResults
                          .map(
                            (result) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    result.name,
                                    style: TextStyle(
                                      fontWeight: result.isNewInvestor
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: result.isNewInvestor
                                          ? Colors.green
                                          : null,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(Formatters.percent(result.prePercent)),
                                ),
                                DataCell(
                                  Text(Formatters.percent(result.postPercent)),
                                ),
                                DataCell(
                                  Text(
                                    result.dilutionPercent >= 0
                                        ? '+${Formatters.percent(result.dilutionPercent)}'
                                        : Formatters.percent(
                                            result.dilutionPercent,
                                          ),
                                    style: TextStyle(
                                      color: result.dilutionPercent >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
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

  void _simulateNewRound(CoreCapTableProvider provider) {
    final raiseAmount = double.tryParse(_simRaiseAmountController.text) ?? 0;
    final preMoney = double.tryParse(_simPreMoneyController.text) ?? 0;

    if (raiseAmount <= 0 || preMoney <= 0) return;

    final postMoney = preMoney + raiseAmount;
    final newInvestorPercent = (raiseAmount / postMoney) * 100;
    final currentShares = provider.totalCurrentShares;

    // New shares for investors = current * (new% / (1 - new%))
    final totalNewPercent = newInvestorPercent + _simEsopExpansion;
    final newSharesNeeded =
        currentShares * (totalNewPercent / 100) / (1 - totalNewPercent / 100);
    final newInvestorShares =
        (newSharesNeeded * (newInvestorPercent / totalNewPercent)).round();
    final postRoundShares = currentShares + newSharesNeeded.round();

    final results = <_SimulationResult>[];

    // Existing investors
    for (final investor in provider.activeInvestors) {
      final shares = provider.getCurrentSharesByInvestor(investor.id);
      if (shares <= 0) continue;

      final prePercent = (shares / currentShares) * 100;
      final postPercent = (shares / postRoundShares) * 100;

      results.add(
        _SimulationResult(
          name: investor.name,
          isNewInvestor: false,
          preShares: shares,
          postShares: shares,
          prePercent: prePercent,
          postPercent: postPercent,
          dilutionPercent: postPercent - prePercent,
        ),
      );
    }

    // New investor
    results.add(
      _SimulationResult(
        name: 'New Investor',
        isNewInvestor: true,
        preShares: 0,
        postShares: newInvestorShares,
        prePercent: 0,
        postPercent: (newInvestorShares / postRoundShares) * 100,
        dilutionPercent: (newInvestorShares / postRoundShares) * 100,
      ),
    );

    // ESOP expansion
    if (_simEsopExpansion > 0) {
      final esopShares = (newSharesNeeded - newInvestorShares).round();
      results.add(
        _SimulationResult(
          name: 'ESOP Pool (Expansion)',
          isNewInvestor: false,
          preShares: 0,
          postShares: esopShares,
          prePercent: 0,
          postPercent: (esopShares / postRoundShares) * 100,
          dilutionPercent: (esopShares / postRoundShares) * 100,
        ),
      );
    }

    // Sort: new investor first, then by post-percent descending
    results.sort((a, b) {
      if (a.isNewInvestor && !b.isNewInvestor) return -1;
      if (!a.isNewInvestor && b.isNewInvestor) return 1;
      return b.postPercent.compareTo(a.postPercent);
    });

    setState(() {
      _simulationResults = results;
    });
  }

  List<Widget> _buildProRataList(CoreCapTableProvider provider) {
    final investment = double.tryParse(_newInvestmentController.text) ?? 0;
    // Only show active investors with pro-rata rights
    final proRataInvestors = provider.activeInvestors
        .where((i) => i.hasProRataRights)
        .toList();

    return proRataInvestors.map((investor) {
      final proRataAmount = provider.calculateProRataAllocation(
        investor.id,
        investment,
      );
      final ownership = provider.getOwnershipPercentage(investor.id);

      return ListTile(
        leading: InvestorAvatar(name: investor.name, type: investor.type),
        title: Text(investor.name),
        subtitle: Text('Current ownership: ${Formatters.percent(ownership)}'),
        trailing: investment > 0
            ? Text(
                Formatters.currency(proRataAmount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : const Text('Enter investment above'),
      );
    }).toList();
  }
}

/// Result row for exit waterfall
class WaterfallRow {
  final String investorName;
  final String shareClassName;
  final int shares;
  final double ownershipPercent;
  final double proceeds;
  final double multiple;

  WaterfallRow({
    required this.investorName,
    required this.shareClassName,
    required this.shares,
    required this.ownershipPercent,
    required this.proceeds,
    required this.multiple,
  });
}

/// Helper for waterfall calculation
class _InvestorHolding {
  final String investorId;
  final String investorName;
  final ShareClass shareClass;
  final int shares;
  final double invested;

  _InvestorHolding({
    required this.investorId,
    required this.investorName,
    required this.shareClass,
    required this.shares,
    required this.invested,
  });
}

/// Result row for round simulation
class _SimulationResult {
  final String name;
  final bool isNewInvestor;
  final int preShares;
  final int postShares;
  final double prePercent;
  final double postPercent;
  final double dilutionPercent;

  _SimulationResult({
    required this.name,
    required this.isNewInvestor,
    required this.preShares,
    required this.postShares,
    required this.prePercent,
    required this.postPercent,
    required this.dilutionPercent,
  });
}
