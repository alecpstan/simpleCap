import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/convertible_instrument.dart';
import '../../core/models/investor.dart';
import '../../core/models/transaction.dart';
import '../../core/providers/core_cap_table_provider.dart';
import '../providers/convertibles_provider.dart';
import '../../../shared/utils/helpers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/info_widgets.dart';
import '../../../shared/widgets/help_icon.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/avatars.dart';
import '../../../shared/widgets/expandable_card.dart';

class ConvertiblesPage extends StatelessWidget {
  const ConvertiblesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CoreCapTableProvider, ConvertiblesProvider>(
      builder: (context, coreProvider, convertiblesProvider, child) {
        if (coreProvider.isLoading || !convertiblesProvider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final convertibles = convertiblesProvider.convertibles;
        final outstanding = convertiblesProvider.outstandingConvertibles;

        return Scaffold(
          appBar: AppBar(title: const Text('Convertibles')),
          body: convertibles.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyState(
                      icon: Icons.receipt_long,
                      title: 'No Convertible Instruments',
                      subtitle:
                          'Add SAFEs or Convertible Notes to track pre-equity investments.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showAddConvertibleDialog(
                        context,
                        coreProvider,
                        convertiblesProvider,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Convertible'),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary stats
                      _buildSummaryCards(context, coreProvider, outstanding),
                      const SizedBox(height: 24),

                      // Outstanding convertibles
                      if (outstanding.isNotEmpty) ...[
                        SectionCard(
                          title: 'Outstanding Convertibles',
                          trailing: Text(
                            '${outstanding.length} active',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          child: _buildConvertiblesList(
                            context,
                            coreProvider,
                            convertiblesProvider,
                            outstanding,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Converted/closed
                      _buildHistorySection(
                        context,
                        coreProvider,
                        convertiblesProvider,
                        convertibles,
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddConvertibleDialog(
              context,
              coreProvider,
              convertiblesProvider,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Convertible'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    CoreCapTableProvider provider,
    List<ConvertibleInstrument> outstanding,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ResultChip(
          label: 'Outstanding Principal',
          value: Formatters.compactCurrency(provider.totalConvertiblePrincipal),
          color: Colors.blue,
        ),
        ResultChip(
          label: 'Incl. Interest',
          value: Formatters.compactCurrency(provider.totalConvertibleAmount),
          color: Colors.orange,
        ),
        ResultChip(
          label: 'SAFEs',
          value: outstanding
              .where((c) => c.type == ConvertibleType.safe)
              .length
              .toString(),
          color: Colors.purple,
        ),
        ResultChip(
          label: 'Notes',
          value: outstanding
              .where((c) => c.type == ConvertibleType.convertibleNote)
              .length
              .toString(),
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildConvertiblesList(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    ConvertiblesProvider convertiblesProvider,
    List<ConvertibleInstrument> convertibles,
  ) {
    return Column(
      children: convertibles.map((c) {
        final investor = coreProvider.getInvestorById(c.investorId);
        return _ConvertibleTile(
          convertible: c,
          investorName: investor?.name ?? 'Unknown',
          investorType: investor?.type,
          onTap: () => _showConvertibleDetails(
            context,
            coreProvider,
            convertiblesProvider,
            c,
          ),
        );
      }).toList(),
    );
  }

  void _showConvertibleDetails(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    ConvertiblesProvider convertiblesProvider,
    ConvertibleInstrument convertible,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConvertibleDetailsDialog(
        convertible: convertible,
        coreProvider: coreProvider,
        convertiblesProvider: convertiblesProvider,
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    ConvertiblesProvider convertiblesProvider,
    List<ConvertibleInstrument> allConvertibles,
  ) {
    final closed = allConvertibles
        .where((c) => c.status != ConvertibleStatus.outstanding)
        .toList();

    if (closed.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'History',
      child: Column(
        children: closed.map((c) {
          final investor = coreProvider.getInvestorById(c.investorId);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: c.status == ConvertibleStatus.converted
                  ? Colors.green
                  : Colors.grey,
              child: Icon(
                _getStatusIcon(c.status),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(investor?.name ?? 'Unknown'),
            subtitle: Text('${c.typeDisplayName} • ${c.statusDisplayName}'),
            trailing: c.conversionShares != null
                ? Text('${Formatters.number(c.conversionShares!)} shares')
                : null,
            onTap: c.status == ConvertibleStatus.converted
                ? () => _showConversionSummaryDialog(
                    context,
                    coreProvider,
                    convertiblesProvider,
                    c,
                  )
                : null,
          );
        }).toList(),
      ),
    );
  }

  IconData _getStatusIcon(ConvertibleStatus status) {
    switch (status) {
      case ConvertibleStatus.outstanding:
        return Icons.hourglass_empty;
      case ConvertibleStatus.converted:
        return Icons.check_circle;
      case ConvertibleStatus.repaid:
        return Icons.payments;
      case ConvertibleStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _showAddConvertibleDialog(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    ConvertiblesProvider convertiblesProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => ConvertibleDialog(
        coreProvider: coreProvider,
        convertiblesProvider: convertiblesProvider,
      ),
    );
  }

  void _showConversionSummaryDialog(
    BuildContext context,
    CoreCapTableProvider coreProvider,
    ConvertiblesProvider convertiblesProvider,
    ConvertibleInstrument convertible,
  ) {
    final investor = coreProvider.getInvestorById(convertible.investorId);
    final round = convertible.conversionRoundId != null
        ? coreProvider.getRoundById(convertible.conversionRoundId!)
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.swap_horiz,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Conversion Summary')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SummaryRow(label: 'Investor', value: investor?.name ?? 'Unknown'),
              SummaryRow(
                label: 'Instrument',
                value: convertible.typeDisplayName,
              ),
              SummaryRow(
                label: 'Principal',
                value: Formatters.currency(convertible.principalAmount),
              ),
              if (convertible.type == ConvertibleType.convertibleNote &&
                  convertible.accruedInterest > 0)
                SummaryRow(
                  label: 'Accrued Interest',
                  value: Formatters.currency(convertible.accruedInterest),
                ),
              SummaryRow(
                label: 'Total Converted',
                value: Formatters.currency(convertible.convertibleAmount),
              ),
              const Divider(height: 24),
              SummaryRow(
                label: 'Converted In',
                value: round?.name ?? 'Unknown Round',
              ),
              if (convertible.conversionDate != null)
                SummaryRow(
                  label: 'Conversion Date',
                  value: Formatters.date(convertible.conversionDate!),
                ),
              if (convertible.conversionPricePerShare != null)
                SummaryRow(
                  label: 'Conversion Price',
                  value: Formatters.currency(
                    convertible.conversionPricePerShare!,
                  ),
                ),
              if (convertible.conversionShares != null)
                SummaryRow(
                  label: 'Shares Received',
                  value: Formatters.number(convertible.conversionShares!),
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
          const DialogCancelButton(label: 'Close'),
          DialogWarningButton(
            icon: Icons.undo,
            label: 'Undo',
            onPressed: () async {
              final success =
                  await convertiblesProvider.undoConversion(convertible.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  showSuccessSnackbar(context, 'Conversion undone successfully');
                } else {
                  showErrorSnackbar(context, 'Failed to undo conversion');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class ConvertibleDialog extends StatefulWidget {
  final CoreCapTableProvider coreProvider;
  final ConvertiblesProvider convertiblesProvider;
  final ConvertibleInstrument? convertible;

  // Compatibility getter
  CoreCapTableProvider get provider => coreProvider;

  const ConvertibleDialog({
    super.key,
    required this.coreProvider,
    required this.convertiblesProvider,
    this.convertible,
  });

  @override
  State<ConvertibleDialog> createState() => _ConvertibleDialogState();
}

class _ConvertibleDialogState extends State<ConvertibleDialog> {
  late ConvertibleType _type;
  String? _investorId;
  final _principalController = TextEditingController();
  final _discountController = TextEditingController();
  final _capController = TextEditingController();
  final _interestController = TextEditingController();
  DateTime _issueDate = DateTime.now();
  DateTime? _maturityDate;
  bool _hasMFN = false;
  bool _hasProRata = false;

  bool get isEditing => widget.convertible != null;

  @override
  void initState() {
    super.initState();
    if (widget.convertible != null) {
      final c = widget.convertible!;
      _type = c.type;
      _investorId = c.investorId;
      _principalController.text = c.principalAmount.toString();
      if (c.discountPercent != null) {
        _discountController.text = (c.discountPercent! * 100).toString();
      }
      if (c.valuationCap != null) {
        _capController.text = c.valuationCap.toString();
      }
      if (c.interestRate != null) {
        _interestController.text = (c.interestRate! * 100).toString();
      }
      _issueDate = c.issueDate;
      _maturityDate = c.maturityDate;
      _hasMFN = c.hasMFN;
      _hasProRata = c.hasProRata;
    } else {
      _type = ConvertibleType.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Convertible' : 'Add Convertible'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selection
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<ConvertibleType>(
                    segments: const [
                      ButtonSegment(
                        value: ConvertibleType.safe,
                        label: Text('SAFE'),
                      ),
                      ButtonSegment(
                        value: ConvertibleType.convertibleNote,
                        label: Text('Note'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (value) {
                      setState(() => _type = value.first);
                    },
                  ),
                ),
                const HelpIcon(helpKey: 'convertibles.safe'),
              ],
            ),
            const SizedBox(height: 16),

            // Investor (locked when editing)
            if (isEditing) ...[
              _buildLockedInvestorTile(
                widget.provider.getInvestorById(_investorId!),
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                initialValue: _investorId,
                decoration: const InputDecoration(
                  labelText: 'Investor',
                  border: OutlineInputBorder(),
                ),
                items: widget.provider.investors.map((inv) {
                  return DropdownMenuItem(value: inv.id, child: Text(inv.name));
                }).toList(),
                onChanged: (value) => setState(() => _investorId = value),
              ),
            ],
            const SizedBox(height: 16),

            // Principal
            TextField(
              controller: _principalController,
              decoration: const InputDecoration(
                labelText: 'Principal Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Terms row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: 'Discount %',
                      border: const OutlineInputBorder(),
                      suffixIcon: const HelpIcon(
                        helpKey: 'convertibles.discount',
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _capController,
                    decoration: InputDecoration(
                      labelText: 'Valuation Cap',
                      prefixText: '\$',
                      border: const OutlineInputBorder(),
                      suffixIcon: const HelpIcon(
                        helpKey: 'convertibles.valuationCap',
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interest (notes only)
            if (_type == ConvertibleType.convertibleNote) ...[
              TextField(
                controller: _interestController,
                decoration: const InputDecoration(
                  labelText: 'Annual Interest Rate %',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],

            // Dates
            AppDateField(
              value: _issueDate,
              labelText: 'Issue Date',
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onChanged: (date) => setState(() => _issueDate = date),
            ),
            if (_type == ConvertibleType.convertibleNote) ...[
              const SizedBox(height: 16),
              AppDateField(
                value:
                    _maturityDate ??
                    DateTime.now().add(const Duration(days: 365)),
                labelText: 'Maturity Date',
                firstDate: _issueDate,
                lastDate: DateTime(2100),
                onChanged: (date) => setState(() => _maturityDate = date),
              ),
            ],
            const SizedBox(height: 16),

            // Checkboxes
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Most Favored Nation (MFN)'),
              subtitle: const Text(
                'Match better terms given to later investors',
              ),
              value: _hasMFN,
              onChanged: (v) => setState(() => _hasMFN = v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pro-rata Rights'),
              subtitle: const Text('Right to invest in future rounds'),
              value: _hasProRata,
              onChanged: (v) => setState(() => _hasProRata = v ?? false),
            ),
          ],
        ),
      ),
      actions: [
        const DialogCancelButton(),
        DialogPrimaryButton(
          onPressed: _canSave() ? _save : null,
          label: isEditing ? 'Update' : 'Add',
        ),
      ],
    );
  }

  bool _canSave() {
    return _investorId != null &&
        _principalController.text.isNotEmpty &&
        double.tryParse(_principalController.text) != null;
  }

  void _save() {
    final principal = double.parse(_principalController.text);
    final discount = _discountController.text.isNotEmpty
        ? double.parse(_discountController.text) / 100
        : null;
    final cap = _capController.text.isNotEmpty
        ? double.parse(_capController.text)
        : null;
    final interest = _interestController.text.isNotEmpty
        ? double.parse(_interestController.text) / 100
        : null;

    final convertible = ConvertibleInstrument(
      id: widget.convertible?.id,
      investorId: _investorId!,
      type: _type,
      principalAmount: principal,
      discountPercent: discount,
      valuationCap: cap,
      interestRate: interest,
      issueDate: _issueDate,
      maturityDate: _maturityDate,
      hasMFN: _hasMFN,
      hasProRata: _hasProRata,
      status: widget.convertible?.status ?? ConvertibleStatus.outstanding,
    );

    if (isEditing) {
      widget.convertiblesProvider.updateConvertible(convertible);
    } else {
      widget.convertiblesProvider.addConvertible(convertible);
    }

    Navigator.pop(context);
  }

  Widget _buildLockedInvestorTile(Investor? investor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          InvestorAvatar(
            name: investor?.name ?? '?',
            type: investor?.type,
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  investor?.name ?? 'Unknown',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Investor',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _principalController.dispose();
    _discountController.dispose();
    _capController.dispose();
    _interestController.dispose();
    super.dispose();
  }
}

class ConversionDialog extends StatefulWidget {
  final CoreCapTableProvider coreProvider;
  final ConvertiblesProvider convertiblesProvider;
  final ConvertibleInstrument convertible;

  // Compatibility getter
  CoreCapTableProvider get provider => coreProvider;

  const ConversionDialog({
    super.key,
    required this.coreProvider,
    required this.convertiblesProvider,
    required this.convertible,
  });

  @override
  State<ConversionDialog> createState() => _ConversionDialogState();
}

enum _ConversionMode { atRound, atValuation }

class _ConversionDialogState extends State<ConversionDialog> {
  _ConversionMode _mode = _ConversionMode.atRound;
  String? _roundId;
  String? _shareClassId;
  final _valuationController = TextEditingController();
  late DateTime _conversionDate;

  @override
  void initState() {
    super.initState();
    _conversionDate = DateTime.now();

    // If no rounds exist, default to valuation mode
    if (widget.provider.rounds.isEmpty) {
      _mode = _ConversionMode.atValuation;
    }
  }

  @override
  void dispose() {
    _valuationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;
    final convertible = widget.convertible;

    // Calculate conversion details based on mode
    int? shares;
    double? pps;

    if (_mode == _ConversionMode.atRound && _roundId != null) {
      final round = provider.getRoundById(_roundId!);
      if (round != null) {
        final issuedBefore = provider.getIssuedSharesBeforeRound(_roundId!);
        pps = convertible.calculateConversionPPS(
          roundPreMoney: round.preMoneyValuation,
          issuedSharesBeforeRound: issuedBefore,
        );
        shares = convertible.calculateConversionShares(
          roundPreMoney: round.preMoneyValuation,
          issuedSharesBeforeRound: issuedBefore,
        );
      }
    } else if (_mode == _ConversionMode.atValuation) {
      final valuation = double.tryParse(_valuationController.text);
      if (valuation != null && valuation > 0) {
        final issuedShares = provider.totalCurrentShares;
        pps = convertible.calculateConversionPPS(
          roundPreMoney: valuation,
          issuedSharesBeforeRound: issuedShares,
        );
        shares = convertible.calculateConversionShares(
          roundPreMoney: valuation,
          issuedSharesBeforeRound: issuedShares,
        );
      }
    }

    return AlertDialog(
      title: const Text('Convert to Equity'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Convertible summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Principal: ${Formatters.currency(convertible.principalAmount)}',
                      ),
                      Text(
                        'Accrued Interest: ${Formatters.currency(convertible.accruedInterest)}',
                      ),
                      const Divider(),
                      Text(
                        'Total: ${Formatters.currency(convertible.convertibleAmount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (convertible.valuationCap != null)
                        Text(
                          'Cap: ${Formatters.compactCurrency(convertible.valuationCap!)}',
                        ),
                      if (convertible.discountPercent != null)
                        Text(
                          'Discount: ${(convertible.discountPercent! * 100).toStringAsFixed(0)}%',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Conversion mode selector
              Text(
                'Conversion Trigger',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<_ConversionMode>(
                segments: const [
                  ButtonSegment(
                    value: _ConversionMode.atRound,
                    label: Text('At Round'),
                    icon: Icon(Icons.account_balance, size: 18),
                  ),
                  ButtonSegment(
                    value: _ConversionMode.atValuation,
                    label: Text('At Valuation'),
                    icon: Icon(Icons.attach_money, size: 18),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _mode = selection.first;
                    // Clear the other selection
                    if (_mode == _ConversionMode.atRound) {
                      _valuationController.clear();
                    } else {
                      _roundId = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Mode-specific inputs
              if (_mode == _ConversionMode.atRound) ...[
                // Round selection
                DropdownButtonFormField<String>(
                  key: ValueKey('round_$_roundId'),
                  initialValue: _roundId,
                  decoration: const InputDecoration(
                    labelText: 'Converting in Round',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.rounds.map((r) {
                    return DropdownMenuItem(value: r.id, child: Text(r.name));
                  }).toList(),
                  onChanged: (value) => setState(() => _roundId = value),
                ),
              ] else ...[
                // Valuation input
                TextFormField(
                  controller: _valuationController,
                  decoration: const InputDecoration(
                    labelText: 'Valuation',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                    helperText:
                        'Company valuation for conversion (e.g., maturity, M&A)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Conversion date
                AppDateField(
                  value: _conversionDate,
                  labelText: 'Conversion Date',
                  firstDate: convertible.issueDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onChanged: (date) => setState(() => _conversionDate = date),
                ),
              ],
              const SizedBox(height: 16),

              // Share class selection
              DropdownButtonFormField<String>(
                key: ValueKey('shareclass_$_shareClassId'),
                initialValue: _shareClassId,
                decoration: const InputDecoration(
                  labelText: 'Share Class',
                  border: OutlineInputBorder(),
                ),
                items: provider.shareClasses.map((sc) {
                  return DropdownMenuItem(value: sc.id, child: Text(sc.name));
                }).toList(),
                onChanged: (value) => setState(() => _shareClassId = value),
              ),
              const SizedBox(height: 16),

              // Conversion preview
              if (pps != null && shares != null)
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conversion Preview',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Price per Share: ${Formatters.currency(pps)}'),
                        Text(
                          'Shares to Issue: ${Formatters.number(shares)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        const DialogCancelButton(),
        DialogPrimaryButton(
          onPressed: _canConvert() ? _convert : null,
          label: 'Convert',
        ),
      ],
    );
  }

  bool _canConvert() {
    if (_shareClassId == null) return false;
    if (_mode == _ConversionMode.atRound) {
      return _roundId != null;
    } else {
      final valuation = double.tryParse(_valuationController.text);
      return valuation != null && valuation > 0;
    }
  }

  void _convert() {
    if (_mode == _ConversionMode.atRound) {
      final round = widget.provider.getRoundById(_roundId!);
      final issuedBefore = widget.provider.getIssuedSharesBeforeRound(_roundId!);
      widget.convertiblesProvider.convertConvertible(
        convertibleId: widget.convertible.id,
        shareClassId: _shareClassId!,
        roundId: _roundId!,
        conversionDate: round?.date ?? DateTime.now(),
        roundPreMoney: round?.preMoneyValuation ?? 0,
        issuedSharesBeforeRound: issuedBefore,
      );
    } else {
      final valuation = double.parse(_valuationController.text);
      widget.convertiblesProvider.convertConvertibleAtValuation(
        convertibleId: widget.convertible.id,
        shareClassId: _shareClassId!,
        valuation: valuation,
        conversionDate: _conversionDate,
        issuedShares: widget.provider.totalCurrentShares,
      );
    }
    Navigator.pop(context);
  }
}

/// Compact tile for displaying a convertible instrument (matching Options style)
class _ConvertibleTile extends StatelessWidget {
  final ConvertibleInstrument convertible;
  final String investorName;
  final InvestorType? investorType;
  final VoidCallback onTap;

  const _ConvertibleTile({
    required this.convertible,
    required this.investorName,
    required this.investorType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSafe = convertible.type == ConvertibleType.safe;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isSafe ? Colors.purple : Colors.teal,
                  child: Icon(
                    isSafe ? Icons.flash_on : Icons.description,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investorName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${convertible.typeDisplayName} • ${Formatters.currency(convertible.principalAmount)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.colorScheme.outline),
              ],
            ),
            const SizedBox(height: 8),
            // Terms row
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (convertible.valuationCap != null)
                  _TermChip(
                    label: 'Cap',
                    value: Formatters.compactCurrency(
                      convertible.valuationCap!,
                    ),
                    color: Colors.blue,
                  ),
                if (convertible.discountPercent != null)
                  _TermChip(
                    label: 'Discount',
                    value:
                        '${(convertible.discountPercent! * 100).toStringAsFixed(0)}%',
                    color: Colors.orange,
                  ),
                if (convertible.interestRate != null)
                  _TermChip(
                    label: 'Interest',
                    value:
                        '${(convertible.interestRate! * 100).toStringAsFixed(1)}%',
                    color: Colors.teal,
                  ),
                if (convertible.hasMFN)
                  _TermChip(label: 'MFN', value: '', color: Colors.purple),
                if (convertible.hasProRata)
                  _TermChip(label: 'Pro-rata', value: '', color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TermChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TermChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value.isEmpty ? label : '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// Compact dialog for viewing convertible details (matching Options style)
class ConvertibleDetailsDialog extends StatelessWidget {
  final ConvertibleInstrument convertible;
  final CoreCapTableProvider coreProvider;
  final ConvertiblesProvider convertiblesProvider;

  // Compatibility getter
  CoreCapTableProvider get provider => coreProvider;

  const ConvertibleDetailsDialog({
    super.key,
    required this.convertible,
    required this.coreProvider,
    required this.convertiblesProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = provider.getInvestorById(convertible.investorId);
    final isSafe = convertible.type == ConvertibleType.safe;
    final isOutstanding = convertible.status == ConvertibleStatus.outstanding;

    // Find conversion transaction if converted
    Transaction? conversionTransaction;
    if (convertible.status == ConvertibleStatus.converted) {
      conversionTransaction = provider.transactions
          .cast<Transaction?>()
          .firstWhere(
            (t) =>
                t != null &&
                t.type == TransactionType.conversion &&
                t.investorId == convertible.investorId &&
                t.roundId == convertible.conversionRoundId &&
                t.numberOfShares == convertible.conversionShares,
            orElse: () => null,
          );
    }

    return AlertDialog(
      title: Text('${convertible.typeDisplayName} Details'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instrument info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isSafe ? Colors.purple : Colors.teal).withValues(
                    alpha: 0.1,
                  ),
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: convertible.status.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            convertible.statusDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      label: 'Principal',
                      value: Formatters.currency(convertible.principalAmount),
                    ),
                    DetailRow(
                      label: 'Issue Date',
                      value: Formatters.date(convertible.issueDate),
                    ),
                    if (convertible.maturityDate != null)
                      DetailRow(
                        label: 'Maturity Date',
                        value: Formatters.date(convertible.maturityDate!),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Terms
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (convertible.valuationCap != null)
                      DetailRow(
                        label: 'Valuation Cap',
                        value: Formatters.currency(convertible.valuationCap!),
                      ),
                    if (convertible.discountPercent != null)
                      DetailRow(
                        label: 'Discount',
                        value:
                            '${(convertible.discountPercent! * 100).toStringAsFixed(0)}%',
                      ),
                    if (convertible.interestRate != null) ...[
                      DetailRow(
                        label: 'Interest Rate',
                        value:
                            '${(convertible.interestRate! * 100).toStringAsFixed(1)}%',
                      ),
                      DetailRow(
                        label: 'Accrued Interest',
                        value: Formatters.currency(convertible.accruedInterest),
                      ),
                      DetailRow(
                        label: 'Total Amount',
                        value: Formatters.currency(
                          convertible.convertibleAmount,
                        ),
                      ),
                    ],
                    if (convertible.hasMFN || convertible.hasProRata) ...[
                      const Divider(height: 16),
                      if (convertible.hasMFN)
                        DetailRow(label: 'MFN', value: 'Yes'),
                      if (convertible.hasProRata)
                        DetailRow(label: 'Pro-rata Rights', value: 'Yes'),
                    ],
                  ],
                ),
              ),

              // Conversion details (if converted)
              if (convertible.status == ConvertibleStatus.converted) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (convertible.conversionDate != null)
                        DetailRow(
                          label: 'Date',
                          value: Formatters.date(convertible.conversionDate!),
                        ),
                      if (convertible.conversionPricePerShare != null)
                        DetailRow(
                          label: 'Price/Share',
                          value: Formatters.currency(
                            convertible.conversionPricePerShare!,
                          ),
                        ),
                      if (convertible.conversionShares != null)
                        DetailRow(
                          label: 'Shares Issued',
                          value: Formatters.number(
                            convertible.conversionShares!,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // Linked transactions
              if (conversionTransaction != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Linked Transactions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTransactionTile(
                        context,
                        conversionTransaction,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        FilledButton.icon(
          onPressed: isOutstanding
              ? () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => ConversionDialog(
                      convertible: convertible,
                      coreProvider: coreProvider,
                      convertiblesProvider: convertiblesProvider,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: const Text('Convert'),
        ),
        TextButton.icon(
          onPressed:
              (conversionTransaction == null &&
                  convertible.status == ConvertibleStatus.outstanding)
              ? () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => ConvertibleDialog(
                      coreProvider: coreProvider,
                      convertiblesProvider: convertiblesProvider,
                      convertible: convertible,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
        ),
        DialogDeleteButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final confirmed = await showConfirmDialog(
              context: context,
              title: 'Delete Convertible?',
              message:
                  'This will permanently remove this convertible instrument.',
            );
            if (confirmed && context.mounted) {
              await convertiblesProvider.deleteConvertible(convertible.id);
              navigator.pop();
              if (context.mounted) {
                showSuccessSnackbar(context, 'Convertible deleted');
              }
            }
          },
        ),
        const DialogCancelButton(label: 'Close'),
      ],
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    Transaction txn,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => _EditConversionTransactionDialog(
            transaction: txn,
            convertible: convertible,
            coreProvider: coreProvider,
            convertiblesProvider: convertiblesProvider,
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const Icon(Icons.swap_horiz, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversion - ${Formatters.number(txn.numberOfShares)} shares',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Formatters.date(txn.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, size: 16, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

/// Dialog for editing/deleting a conversion transaction
class _EditConversionTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final ConvertibleInstrument convertible;
  final CoreCapTableProvider coreProvider;
  final ConvertiblesProvider convertiblesProvider;

  // Compatibility getter
  CoreCapTableProvider get provider => coreProvider;

  const _EditConversionTransactionDialog({
    required this.transaction,
    required this.convertible,
    required this.coreProvider,
    required this.convertiblesProvider,
  });

  @override
  State<_EditConversionTransactionDialog> createState() =>
      _EditConversionTransactionDialogState();
}

class _EditConversionTransactionDialogState
    extends State<_EditConversionTransactionDialog> {
  late TextEditingController _sharesController;
  late DateTime _conversionDate;

  @override
  void initState() {
    super.initState();
    _sharesController = TextEditingController(
      text: widget.transaction.numberOfShares.toString(),
    );
    _conversionDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final investor = widget.provider.getInvestorById(
      widget.convertible.investorId,
    );

    return AlertDialog(
      title: const Text('Edit Conversion Transaction'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Convertible info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.convertible.typeDisplayName),
                  Text(
                    'Principal: ${Formatters.currency(widget.convertible.principalAmount)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Shares
            TextFormField(
              controller: _sharesController,
              decoration: const InputDecoration(
                labelText: 'Shares Issued',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Conversion date
            AppDateField(
              value: _conversionDate,
              labelText: 'Conversion Date',
              firstDate: widget.convertible.issueDate,
              lastDate: DateTime.now(),
              onChanged: (date) => setState(() => _conversionDate = date),
            ),
          ],
        ),
      ),
      actions: [
        DialogDeleteButton(onPressed: _delete),
        const DialogCancelButton(),
        DialogPrimaryButton(onPressed: _save, label: 'Save'),
      ],
    );
  }

  Future<void> _save() async {
    final shares = int.tryParse(_sharesController.text) ?? 0;
    if (shares <= 0) {
      showErrorSnackbar(context, 'Invalid number of shares');
      return;
    }

    // Update the transaction
    final updated = widget.transaction.copyWith(
      numberOfShares: shares,
      date: _conversionDate,
    );
    await widget.provider.updateTransaction(updated);

    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackbar(context, 'Transaction updated');
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Undo Conversion',
      message:
          'This will undo the conversion and restore the convertible to outstanding status. Continue?',
    );
    if (!confirmed) return;

    // Use existing undo conversion logic
    await widget.convertiblesProvider.undoConversion(widget.convertible.id);

    if (mounted) {
      Navigator.pop(context);
      showSuccessSnackbar(context, 'Conversion undone');
    }
  }
}
