import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/investment_round.dart';
import '../models/transaction.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/avatars.dart';
import '../widgets/dialogs.dart';
import '../widgets/investment_dialog.dart';
import '../widgets/valuation_wizard.dart';
import '../widgets/help_icon.dart';
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
    // Sort rounds by date, oldest first
    final sortedRounds = List<InvestmentRound>.from(provider.rounds)
      ..sort((a, b) => a.date.compareTo(b.date));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedRounds.length,
      itemBuilder: (context, index) {
        final round = sortedRounds[index];
        final investments = provider.getInvestmentsByRound(round.id);
        final totalShares = investments.fold(
          0,
          (sum, t) => sum + t.numberOfShares,
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
                      label: Text('${investments.length} investors'),
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
              if (investments.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No investors in this round yet'),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ...investments.map((transaction) {
                        final investor = provider.getInvestorById(
                          transaction.investorId,
                        );
                        final shareClass = provider.getShareClassById(
                          transaction.shareClassId,
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
                              Text(
                                Formatters.number(transaction.numberOfShares),
                              ),
                              Text(
                                Formatters.currency(transaction.totalAmount),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          onTap: () => _showEditInvestmentDialog(
                            context,
                            provider,
                            transaction,
                          ),
                          onLongPress: () => _confirmDeleteInvestment(
                            context,
                            provider,
                            transaction,
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
                    decoration: InputDecoration(
                      labelText: 'Round Type',
                      prefixIcon: const Icon(Icons.layers),
                      suffixIcon: const HelpIcon(helpKey: 'rounds.roundType'),
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
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HelpIcon(helpKey: 'rounds.preMoneyValuation'),
                          ValuationWizardButton(
                            currentValuation: double.tryParse(
                              preMoneyController.text,
                            ),
                            onValuationSelected: (value) {
                              preMoneyController.text = value
                                  .round()
                                  .toString();
                              setState(
                                () {},
                              ); // Rebuild to update implied price
                            },
                          ),
                        ],
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) =>
                        setState(() {}), // Rebuild to update implied price
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.pie_chart),
                            title: const Text('Issued Shares Pre-Round'),
                            subtitle: Text(
                              Formatters.number(
                                provider.getIssuedSharesBeforeRound(round.id),
                              ),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      // Calculate implied price from pre-money valuation
                      String? helperText;
                      if (isEditing) {
                        final preMoneyVal =
                            double.tryParse(preMoneyController.text) ?? 0;
                        if (preMoneyVal > 0) {
                          final sharesBeforeRound = provider
                              .getIssuedSharesBeforeRound(round.id);
                          if (sharesBeforeRound > 0) {
                            final impliedPrice =
                                preMoneyVal / sharesBeforeRound;
                            helperText =
                                'Implied from valuation: ${Formatters.currency(impliedPrice)}';
                          }
                        }
                      }

                      return TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price Per Share (optional)',
                          hintText: '1.00',
                          prefixIcon: const Icon(Icons.monetization_on),
                          helperText: helperText,
                          helperMaxLines: 2,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) =>
                            setState(() {}), // Rebuild to update helper text
                      );
                    },
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

      final newPreMoney = double.tryParse(preMoneyController.text) ?? 0;
      final newPricePerShare = double.tryParse(priceController.text);

      final newRound = InvestmentRound(
        id: round?.id,
        name: nameController.text,
        type: selectedType,
        date: selectedDate,
        preMoneyValuation: newPreMoney,
        amountRaised: calculatedAmount,
        pricePerShare: newPricePerShare,
        leadInvestor: leadController.text.isEmpty ? null : leadController.text,
        notes: notesController.text.isEmpty ? null : notesController.text,
        isClosed: isClosed,
        order: round?.order ?? provider.rounds.length,
      );

      if (isEditing) {
        // Check if pre-money valuation changed and there are investments in this round
        final preMoneyChanged = round.preMoneyValuation != newPreMoney;
        final hasInvestments = provider
            .getInvestmentsByRound(round.id)
            .isNotEmpty;

        if (preMoneyChanged &&
            hasInvestments &&
            newPreMoney > 0 &&
            context.mounted) {
          // Calculate new implied price
          final sharesBeforeRound = provider.getIssuedSharesBeforeRound(
            round.id,
          );
          if (sharesBeforeRound > 0) {
            final impliedPrice = newPreMoney / sharesBeforeRound;

            final updatePrices = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Update Investor Prices?'),
                content: Text(
                  'The pre-money valuation has changed.\n\n'
                  'Based on ${Formatters.number(sharesBeforeRound)} issued shares, '
                  'the implied price per share is ${Formatters.currency(impliedPrice)}.\n\n'
                  'Would you like to update all investor prices in this round?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('No, Keep Prices'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Yes, Update Prices'),
                  ),
                ],
              ),
            );

            if (updatePrices == true) {
              // Update the round's price per share
              final updatedRound = InvestmentRound(
                id: newRound.id,
                name: newRound.name,
                type: newRound.type,
                date: newRound.date,
                preMoneyValuation: newRound.preMoneyValuation,
                amountRaised: newRound.amountRaised,
                pricePerShare: impliedPrice,
                leadInvestor: newRound.leadInvestor,
                notes: newRound.notes,
                isClosed: newRound.isClosed,
                order: newRound.order,
              );
              await provider.updateRound(updatedRound);
              await provider.updateRoundTransactionPrices(
                round.id,
                impliedPrice,
              );
              return;
            }
          }
        }

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
    final result = await showInvestmentDialog(
      context: context,
      provider: provider,
      round: round,
    );

    if (result.action == InvestmentDialogAction.saved &&
        result.transaction != null) {
      await provider.addInvestment(result.transaction!);
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
          'This will also remove all investments in this round.',
    );

    if (confirmed) {
      await provider.deleteRound(round.id);
    }
  }

  Future<void> _showEditInvestmentDialog(
    BuildContext context,
    CapTableProvider provider,
    Transaction transaction,
  ) async {
    final round = provider.getRoundById(transaction.roundId ?? '');
    if (round == null) return;

    final result = await showInvestmentDialog(
      context: context,
      provider: provider,
      round: round,
      existingTransaction: transaction,
    );

    switch (result.action) {
      case InvestmentDialogAction.saved:
        if (result.transaction != null) {
          await provider.updateInvestment(result.transaction!);
        }
      case InvestmentDialogAction.deleted:
        await provider.deleteInvestment(transaction.id);
      case InvestmentDialogAction.cancelled:
        break;
    }
  }

  Future<void> _confirmDeleteInvestment(
    BuildContext context,
    CapTableProvider provider,
    Transaction transaction,
  ) async {
    final investor = provider.getInvestorById(transaction.investorId);

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Investment',
      message:
          'Remove ${investor?.name ?? 'this investor'}\'s ${Formatters.number(transaction.numberOfShares)} shares from this round?',
    );

    if (confirmed) {
      await provider.deleteInvestment(transaction.id);
    }
  }
}
