import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/investment_round.dart';
import '../models/shareholding.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/avatars.dart';
import '../widgets/dialogs.dart';
import '../widgets/shareholding_dialog.dart';
import '../widgets/valuation_wizard.dart';
import '../utils/helpers.dart';

class RoundsPage extends StatelessWidget {
  const RoundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: provider.rounds.isEmpty
              ? const EmptyState(
                  icon: Icons.layers_outlined,
                  title: 'No investment rounds yet',
                  subtitle: 'Add your first round to start tracking equity',
                )
              : _buildRoundsList(context, provider),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showRoundDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Add Round'),
          ),
        );
      },
    );
  }

  Widget _buildRoundsList(BuildContext context, CapTableProvider provider) {
    final sortedRounds = provider.rounds;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedRounds.length,
      itemBuilder: (context, index) {
        final round = sortedRounds[index];
        final shareholdings = provider.getShareholdingsByRound(round.id);
        final totalShares = shareholdings.fold(
          0,
          (sum, s) => sum + s.numberOfShares,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ExpansionTile(
            leading: RoundAvatar(order: index + 1, type: round.type),
            title: Text(round.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${round.typeDisplayName} • ${Formatters.date(round.date)}',
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (round.preMoneyValuation > 0)
                      Chip(
                        label: Text(
                          'Pre: ${Formatters.compactCurrency(round.preMoneyValuation)}',
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    if (round.amountRaised > 0)
                      Chip(
                        label: Text(
                          'Raised: ${Formatters.compactCurrency(round.amountRaised)}',
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    Chip(
                      label: Text('${shareholdings.length} investors'),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (round.isClosed)
                  const Chip(
                    label: Text('Closed'),
                    visualDensity: VisualDensity.compact,
                  ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_investor',
                      child: ListTile(
                        leading: Icon(Icons.person_add),
                        title: Text('Add Investor'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Round'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'add_investor':
                        _showAddInvestorToRoundDialog(context, provider, round);
                        break;
                      case 'edit':
                        _showRoundDialog(context, provider, round: round);
                        break;
                      case 'delete':
                        _confirmDeleteRound(context, provider, round);
                        break;
                    }
                  },
                ),
              ],
            ),
            children: [
              if (shareholdings.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No investors in this round yet'),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ...shareholdings.map((holding) {
                        final investor = provider.getInvestorById(
                          holding.investorId,
                        );
                        final shareClass = provider.getShareClassById(
                          holding.shareClassId,
                        );
                        return ListTile(
                          leading: InvestorAvatar(
                            name: investor?.name ?? '?',
                            type: investor?.type,
                            radius: 16,
                          ),
                          title: Text(investor?.name ?? 'Unknown'),
                          subtitle: Text(shareClass?.name ?? 'Unknown class'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(Formatters.number(holding.numberOfShares)),
                              Text(
                                Formatters.currency(holding.amountInvested),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          onTap: () => _showEditShareholdingDialog(
                            context,
                            provider,
                            holding,
                          ),
                          onLongPress: () => _confirmDeleteShareholding(
                            context,
                            provider,
                            holding,
                          ),
                        );
                      }),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total shares in round:'),
                            Text(
                              Formatters.number(totalShares),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showAddInvestorToRoundDialog(context, provider, round),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Investor to Round'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRoundDialog(
    BuildContext context,
    CapTableProvider provider, {
    InvestmentRound? round,
  }) async {
    final isEditing = round != null;
    final nameController = TextEditingController(text: round?.name ?? '');
    final preMoneyController = TextEditingController(
      text: round?.preMoneyValuation.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: round?.pricePerShare?.toString() ?? '',
    );
    final leadController = TextEditingController(
      text: round?.leadInvestor ?? '',
    );
    final notesController = TextEditingController(text: round?.notes ?? '');
    var selectedType = round?.type ?? RoundType.seed;
    var selectedDate = round?.date ?? DateTime.now();
    var isClosed = round?.isClosed ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Round' : 'Add Investment Round'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? 500
                  : double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<RoundType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Round Type',
                      prefixIcon: Icon(Icons.layers),
                    ),
                    items: RoundType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getRoundTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        if (nameController.text.isEmpty ||
                            RoundType.values.any(
                              (t) =>
                                  nameController.text == _getRoundTypeName(t),
                            )) {
                          nameController.text = _getRoundTypeName(value);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Round Name *',
                      hintText: 'e.g., Seed Round',
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date'),
                    subtitle: Text(Formatters.date(selectedDate)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: preMoneyController,
                    decoration: InputDecoration(
                      labelText: 'Pre-Money Valuation (AUD)',
                      hintText: '1000000',
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixIcon: ValuationWizardButton(
                        currentValuation: double.tryParse(
                          preMoneyController.text,
                        ),
                        onValuationSelected: (value) {
                          preMoneyController.text = value.round().toString();
                        },
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.payments),
                      title: const Text('Amount Raised'),
                      subtitle: Text(
                        Formatters.currency(
                          provider.getAmountRaisedByRound(round.id),
                        ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      trailing: Text(
                        '${provider.getShareholdingsByRound(round.id).length} investments',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price Per Share (optional)',
                      hintText: '1.00',
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: leadController,
                    decoration: const InputDecoration(
                      labelText: 'Lead Investor (optional)',
                      hintText: 'Acme Ventures',
                      prefixIcon: Icon(Icons.star),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Round Closed'),
                    value: isClosed,
                    onChanged: (value) {
                      setState(() => isClosed = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Additional details...',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      // Amount raised is calculated from shareholdings, not manually entered
      final calculatedAmount = isEditing
          ? provider.getAmountRaisedByRound(round.id)
          : 0.0;

      final newRound = InvestmentRound(
        id: round?.id,
        name: nameController.text,
        type: selectedType,
        date: selectedDate,
        preMoneyValuation: double.tryParse(preMoneyController.text) ?? 0,
        amountRaised: calculatedAmount,
        pricePerShare: double.tryParse(priceController.text),
        leadInvestor: leadController.text.isEmpty ? null : leadController.text,
        notes: notesController.text.isEmpty ? null : notesController.text,
        isClosed: isClosed,
        order: round?.order ?? provider.rounds.length,
      );

      if (isEditing) {
        await provider.updateRound(newRound);
      } else {
        await provider.addRound(newRound);
      }
    }
  }

  String _getRoundTypeName(RoundType type) {
    switch (type) {
      case RoundType.incorporation:
        return 'Incorporation';
      case RoundType.seed:
        return 'Seed';
      case RoundType.seriesA:
        return 'Series A';
      case RoundType.seriesB:
        return 'Series B';
      case RoundType.seriesC:
        return 'Series C';
      case RoundType.seriesD:
        return 'Series D';
      case RoundType.bridge:
        return 'Bridge';
      case RoundType.convertible:
        return 'Convertible Note';
      case RoundType.esopPool:
        return 'ESOP Pool';
      case RoundType.secondary:
        return 'Secondary';
      case RoundType.custom:
        return 'Custom';
    }
  }

  Future<void> _showAddInvestorToRoundDialog(
    BuildContext context,
    CapTableProvider provider,
    InvestmentRound round,
  ) async {
    final shareholding = await showShareholdingDialog(
      context: context,
      provider: provider,
      round: round,
    );

    if (shareholding != null) {
      await provider.addShareholding(shareholding);
    }
  }

  Future<void> _confirmDeleteRound(
    BuildContext context,
    CapTableProvider provider,
    InvestmentRound round,
  ) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Round',
      message:
          'Are you sure you want to delete ${round.name}? '
          'This will also remove all shareholdings in this round.',
    );

    if (confirmed) {
      await provider.deleteRound(round.id);
    }
  }

  Future<void> _showEditShareholdingDialog(
    BuildContext context,
    CapTableProvider provider,
    Shareholding holding,
  ) async {
    final round = provider.getRoundById(holding.roundId);
    if (round == null) return;

    final updatedShareholding = await showShareholdingDialog(
      context: context,
      provider: provider,
      round: round,
      existingShareholding: holding,
    );

    if (updatedShareholding != null) {
      await provider.updateShareholding(updatedShareholding);
    }
  }

  Future<void> _confirmDeleteShareholding(
    BuildContext context,
    CapTableProvider provider,
    Shareholding holding,
  ) async {
    final investor = provider.getInvestorById(holding.investorId);

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Shareholding',
      message:
          'Remove ${investor?.name ?? 'this investor'}\'s ${Formatters.number(holding.numberOfShares)} shares from this round?',
    );

    if (confirmed) {
      await provider.deleteShareholding(holding.id);
    }
  }
}
