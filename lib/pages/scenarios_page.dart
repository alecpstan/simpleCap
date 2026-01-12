import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/section_card.dart';
import '../widgets/info_widgets.dart';
import '../widgets/avatars.dart';
import '../widgets/valuation_wizard.dart';
import '../utils/helpers.dart';

class ScenariosPage extends StatefulWidget {
  const ScenariosPage({super.key});

  @override
  State<ScenariosPage> createState() => _ScenariosPageState();
}

class _ScenariosPageState extends State<ScenariosPage> {
  final _newSharesController = TextEditingController();
  final _newInvestmentController = TextEditingController();
  final _preMoneyController = TextEditingController();
  Map<String, double> _dilutionResults = {};
  double _newOwnershipPercentage = 0;
  double _impliedSharePrice = 0;

  @override
  void dispose() {
    _newSharesController.dispose();
    _newInvestmentController.dispose();
    _preMoneyController.dispose();
    super.dispose();
  }

  void _calculateDilution(CapTableProvider provider) {
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

  void _calculateFromValuation(CapTableProvider provider) {
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
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
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
                                    Formatters.number(
                                      provider.totalCurrentShares,
                                    ),
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
                        final currentOwnership = provider
                            .getOwnershipPercentage(entry.key);
                        final newOwnership = currentOwnership - entry.value;

                        return DataRow(
                          cells: [
                            DataCell(Text(investor?.name ?? 'Unknown')),
                            DataCell(
                              Text(Formatters.percent(currentOwnership)),
                            ),
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
      },
    );
  }

  List<Widget> _buildProRataList(CapTableProvider provider) {
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
