import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/investment_round.dart';
import '../models/convertible_instrument.dart';
import '../models/share_class.dart';
import '../models/transaction.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/avatars.dart';
import '../widgets/expandable_card.dart';
import '../widgets/dialogs.dart';
import '../widgets/investment_dialog.dart';
import '../widgets/valuation_wizard.dart';
import '../widgets/help_icon.dart';
import '../widgets/transaction_editor.dart';
import '../widgets/stat_pill.dart';
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

    return CustomScrollView(
      slivers: [
        // Summary header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatPill(
                  label: 'rounds',
                  value: provider.rounds.length.toString(),
                  color: Colors.indigo,
                ),
                StatPill(
                  label: 'raised',
                  value: Formatters.compactCurrency(provider.totalInvested),
                  color: Colors.green,
                ),
                if (provider.outstandingConvertibles.isNotEmpty)
                  StatPill(
                    label: 'convertibles',
                    value: Formatters.compactCurrency(
                      provider.totalConvertiblePrincipal,
                    ),
                    color: Colors.teal,
                  ),
              ],
            ),
          ),
        ),

        // Rounds list
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final round = sortedRounds[index];
            return _RoundCard(
              round: round,
              roundOrder: index + 1,
              provider: provider,
              onEdit: () => _showRoundDialog(context, provider, round: round),
              onDelete: () => _confirmDeleteRound(context, provider, round),
              onAddInvestor: () =>
                  _showAddInvestorToRoundDialog(context, provider, round),
              onConvertNotes: provider.outstandingConvertibles.isNotEmpty
                  ? () => _showConvertNotesDialog(context, provider, round)
                  : null,
            );
          }, childCount: sortedRounds.length),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
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

  Future<void> _showConvertNotesDialog(
    BuildContext context,
    CapTableProvider provider,
    InvestmentRound round,
  ) async {
    final outstanding = provider.outstandingConvertibles;
    if (outstanding.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No outstanding convertibles to convert')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => _ConvertNotesDialog(
        provider: provider,
        round: round,
        convertibles: outstanding,
      ),
    );
  }
}

/// Dialog for batch converting SAFEs and Notes at a round
class _ConvertNotesDialog extends StatefulWidget {
  final CapTableProvider provider;
  final InvestmentRound round;
  final List<ConvertibleInstrument> convertibles;

  const _ConvertNotesDialog({
    required this.provider,
    required this.round,
    required this.convertibles,
  });

  @override
  State<_ConvertNotesDialog> createState() => _ConvertNotesDialogState();
}

class _ConvertNotesDialogState extends State<_ConvertNotesDialog> {
  // Map of convertible ID to selected share class ID (null = don't convert)
  final Map<String, String?> _selections = {};

  @override
  void initState() {
    super.initState();
    // Initialize all to "None" (not selected for conversion)
    for (final c in widget.convertibles) {
      _selections[c.id] = null;
    }
  }

  int get selectedCount => _selections.values.where((v) => v != null).length;

  @override
  Widget build(BuildContext context) {
    final shareClasses = widget.provider.shareClasses
        .where((sc) => sc.type != ShareClassType.esop)
        .toList();

    final issuedBefore = widget.provider.getIssuedSharesBeforeRound(
      widget.round.id,
    );

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text('Convert SAFE/Notes in ${widget.round.name}')),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width > 600 ? 550 : double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select a share class to convert each instrument. '
                      'Conversion uses the round date (${Formatters.date(widget.round.date)}) '
                      'and pre-money valuation.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.convertibles.map((convertible) {
                    final investor = widget.provider.getInvestorById(
                      convertible.investorId,
                    );

                    // Calculate estimated shares for preview
                    final selectedClassId = _selections[convertible.id];
                    int? estimatedShares;
                    if (selectedClassId != null &&
                        issuedBefore > 0 &&
                        widget.round.preMoneyValuation > 0) {
                      estimatedShares = convertible.calculateConversionShares(
                        roundPreMoney: widget.round.preMoneyValuation,
                        issuedSharesBeforeRound: issuedBefore,
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      convertible.type == ConvertibleType.safe
                                      ? Colors.purple
                                      : Colors.teal,
                                  child: Icon(
                                    convertible.type == ConvertibleType.safe
                                        ? Icons.flash_on
                                        : Icons.description,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        investor?.name ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${convertible.typeDisplayName} • '
                                        '${Formatters.currency(convertible.convertibleAmount)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (estimatedShares != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '≈ ${Formatters.number(estimatedShares)} shares',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Terms as simple text
                                Expanded(
                                  child: Text(
                                    [
                                      if (convertible.valuationCap != null)
                                        'Cap: ${Formatters.compactCurrency(convertible.valuationCap!)}',
                                      if (convertible.discountPercent != null)
                                        '${(convertible.discountPercent! * 100).toStringAsFixed(0)}% discount',
                                    ].join(' • '),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                  ),
                                ),
                                // Share class dropdown
                                SizedBox(
                                  width: 150,
                                  child: DropdownButtonFormField<String?>(
                                    initialValue: _selections[convertible.id],
                                    decoration: const InputDecoration(
                                      labelText: 'Share Class',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      isDense: true,
                                    ),
                                    items: [
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('None'),
                                      ),
                                      ...shareClasses.map((sc) {
                                        return DropdownMenuItem(
                                          value: sc.id,
                                          child: Text(sc.name),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selections[convertible.id] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: selectedCount > 0 ? _convertSelected : null,
          child: Text(
            selectedCount > 0
                ? 'Convert $selectedCount Instrument${selectedCount > 1 ? 's' : ''}'
                : 'Select instruments to convert',
          ),
        ),
      ],
    );
  }

  Future<void> _convertSelected() async {
    int successCount = 0;

    for (final entry in _selections.entries) {
      final shareClassId = entry.value;
      if (shareClassId == null) continue;

      try {
        await widget.provider.convertConvertible(
          entry.key,
          shareClassId,
          widget.round.id,
          widget.round.date,
        );
        successCount++;
      } catch (e) {
        debugPrint('Error converting ${entry.key}: $e');
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Converted $successCount instrument${successCount > 1 ? 's' : ''}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Expandable round card with prominent "Add Investor" button
class _RoundCard extends StatefulWidget {
  final InvestmentRound round;
  final int roundOrder;
  final CapTableProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddInvestor;
  final VoidCallback? onConvertNotes;

  const _RoundCard({
    required this.round,
    required this.roundOrder,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
    required this.onAddInvestor,
    this.onConvertNotes,
  });

  @override
  State<_RoundCard> createState() => _RoundCardState();
}

class _RoundCardState extends State<_RoundCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final round = widget.round;
    final provider = widget.provider;
    final investments = provider.getInvestmentsByRound(round.id);
    final conversions = provider.convertibles
        .where(
          (c) =>
              c.conversionRoundId == round.id &&
              c.status == ConvertibleStatus.converted,
        )
        .toList();
    final totalShares = investments.fold<int>(
      0,
      (sum, t) => sum + t.numberOfShares,
    );
    final totalRaised = investments.fold<double>(
      0,
      (sum, t) => sum + t.totalAmount,
    );

    return ExpandableCard(
      leading: RoundAvatar(order: widget.roundOrder, type: round.type),
      title: round.name,
      subtitle: '${round.typeDisplayName} • ${Formatters.date(round.date)}',
      trailing: round.isClosed
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'CLOSED',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          : null,
      chips: [
        if (round.preMoneyValuation > 0)
          InfoTag(
            label: 'Pre',
            value: Formatters.compactCurrency(round.preMoneyValuation),
            color: Colors.blue,
          ),
        if (totalRaised > 0)
          InfoTag(
            label: 'Raised',
            value: Formatters.compactCurrency(totalRaised),
            color: Colors.green,
          ),
        InfoTag(
          label: 'Investors',
          value: investments.length.toString(),
          icon: Icons.people_outline,
        ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round details
          DetailRow(
            label: 'Pre-Money Valuation',
            value: round.preMoneyValuation > 0
                ? Formatters.currency(round.preMoneyValuation)
                : 'Not set',
          ),
          DetailRow(
            label: 'Post-Money Valuation',
            value: round.preMoneyValuation > 0 || totalRaised > 0
                ? Formatters.currency(round.preMoneyValuation + totalRaised)
                : 'Not set',
          ),
          if (round.pricePerShare != null)
            DetailRow(
              label: 'Price per Share',
              value: Formatters.currency(round.pricePerShare!),
            ),
          if (round.leadInvestor != null && round.leadInvestor!.isNotEmpty)
            DetailRow(label: 'Lead Investor', value: round.leadInvestor!),

          // Investments in this round (tap to edit)
          if (investments.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Investments',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap to edit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...investments.map((t) => _buildInvestmentItem(t, provider)),
            const SizedBox(height: 8),
            DetailRow(
              label: 'Total Shares',
              value: Formatters.number(totalShares),
              highlight: true,
            ),
          ],

          // Note conversions in this round (tap to undo)
          if (conversions.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conversions',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap to undo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...conversions.map((c) => _buildConversionItem(c, provider)),
          ],
        ],
      ),
      actions: [
        // All buttons in a Column with 2 rows
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Add Investor and Convert buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: widget.onAddInvestor,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Add Investor'),
                    ),
                  ),
                  if (widget.onConvertNotes != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: widget.onConvertNotes,
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('Convert'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: Edit and Delete buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: widget.onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentItem(Transaction t, CapTableProvider provider) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(t.investorId);
    final shareClass = provider.getShareClassById(t.shareClassId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _editInvestment(t),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              InvestorAvatar(
                name: investor?.name ?? '?',
                type: investor?.type,
                radius: 12,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investor?.name ?? 'Unknown',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      shareClass?.name ?? 'Unknown class',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.number(t.numberOfShares),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    Formatters.compactCurrency(t.totalAmount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editInvestment(Transaction transaction) async {
    final result = await TransactionEditor.edit(
      context: context,
      transaction: transaction,
      provider: widget.provider,
      round: widget.round,
    );

    if (result) {
      setState(() {}); // Refresh the card
    }
  }

  Widget _buildConversionItem(
    ConvertibleInstrument convertible,
    CapTableProvider provider,
  ) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(convertible.investorId);

    // Find the conversion transaction to get the share class
    final conversionTransaction = provider.transactions
        .where(
          (t) =>
              t.type == TransactionType.conversion &&
              t.investorId == convertible.investorId &&
              t.roundId == convertible.conversionRoundId &&
              t.numberOfShares == convertible.conversionShares,
        )
        .firstOrNull;
    final shareClass = conversionTransaction != null
        ? provider.getShareClassById(conversionTransaction.shareClassId)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _showUndoConversionDialog(convertible, provider),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.transform,
                  color: Colors.teal,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investor?.name ?? 'Unknown',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${convertible.typeDisplayName} → ${shareClass?.name ?? 'shares'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.number(convertible.conversionShares ?? 0),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    Formatters.compactCurrency(convertible.principalAmount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.undo, size: 16, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUndoConversionDialog(
    ConvertibleInstrument convertible,
    CapTableProvider provider,
  ) async {
    final investor = provider.getInvestorById(convertible.investorId);

    // Find the conversion transaction to get the share class
    final conversionTransaction = provider.transactions
        .where(
          (t) =>
              t.type == TransactionType.conversion &&
              t.investorId == convertible.investorId &&
              t.roundId == convertible.conversionRoundId &&
              t.numberOfShares == convertible.conversionShares,
        )
        .firstOrNull;
    final shareClass = conversionTransaction != null
        ? provider.getShareClassById(conversionTransaction.shareClassId)
        : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo Conversion'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conversion details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InvestorAvatar(
                          name: investor?.name ?? '?',
                          type: investor?.type,
                          radius: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          investor?.name ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Type: ${convertible.typeDisplayName}'),
                    Text(
                      'Principal: ${Formatters.currency(convertible.principalAmount)}',
                    ),
                    Text(
                      'Shares: ${Formatters.number(convertible.conversionShares ?? 0)}',
                    ),
                    Text('Class: ${shareClass?.name ?? 'Unknown'}'),
                    if (convertible.conversionDate != null)
                      Text(
                        'Date: ${Formatters.date(convertible.conversionDate!)}',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Undoing will remove the conversion transaction and restore this instrument to outstanding status.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              final success = await provider.undoConversion(convertible.id);
              if (context.mounted) {
                Navigator.pop(context, success);
              }
            },
            icon: const Icon(Icons.undo),
            label: const Text('Undo Conversion'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh the card
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversion undone successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
