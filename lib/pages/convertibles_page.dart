import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/convertible_instrument.dart';
import '../providers/cap_table_provider.dart';
import '../utils/helpers.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import '../widgets/help_icon.dart';

class ConvertiblesPage extends StatelessWidget {
  const ConvertiblesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final convertibles = provider.convertibles;
        final outstanding = provider.outstandingConvertibles;

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
                      onPressed: () =>
                          _showAddConvertibleDialog(context, provider),
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
                      _buildSummaryCards(context, provider, outstanding),
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
                            provider,
                            outstanding,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Converted/closed
                      _buildHistorySection(context, provider, convertibles),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddConvertibleDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Add Convertible'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    CapTableProvider provider,
    List<ConvertibleInstrument> outstanding,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryChip(
          label: 'Outstanding Principal',
          value: Formatters.compactCurrency(provider.totalConvertiblePrincipal),
          color: Colors.blue,
        ),
        _SummaryChip(
          label: 'Incl. Interest',
          value: Formatters.compactCurrency(provider.totalConvertibleAmount),
          color: Colors.orange,
        ),
        _SummaryChip(
          label: 'SAFEs',
          value: outstanding
              .where((c) => c.type == ConvertibleType.safe)
              .length
              .toString(),
          color: Colors.purple,
        ),
        _SummaryChip(
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
    CapTableProvider provider,
    List<ConvertibleInstrument> convertibles,
  ) {
    return Column(
      children: convertibles.map((c) {
        final investor = provider.getInvestorById(c.investorId);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: c.type == ConvertibleType.safe
                ? Colors.purple
                : Colors.teal,
            child: Icon(
              c.type == ConvertibleType.safe
                  ? Icons.flash_on
                  : Icons.description,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(investor?.name ?? 'Unknown Investor'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${c.typeDisplayName} • ${Formatters.currency(c.principalAmount)}',
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (c.valuationCap != null)
                    _TermChip(
                      label:
                          'Cap: ${Formatters.compactCurrency(c.valuationCap!)}',
                    ),
                  if (c.discountPercent != null)
                    _TermChip(
                      label:
                          '${(c.discountPercent! * 100).toStringAsFixed(0)}% Discount',
                    ),
                  if (c.interestRate != null)
                    _TermChip(
                      label:
                          '${(c.interestRate! * 100).toStringAsFixed(1)}% Interest',
                    ),
                  if (c.hasMFN) const _TermChip(label: 'MFN'),
                  if (c.hasProRata) const _TermChip(label: 'Pro-rata'),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'convert':
                  _showConvertDialog(context, provider, c);
                  break;
                case 'edit':
                  _showEditConvertibleDialog(context, provider, c);
                  break;
                case 'delete':
                  _confirmDelete(context, provider, c);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'convert',
                child: ListTile(
                  leading: Icon(Icons.swap_horiz),
                  title: Text('Convert to Equity'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
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
          ),
          isThreeLine: true,
        );
      }).toList(),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    CapTableProvider provider,
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
          final investor = provider.getInvestorById(c.investorId);
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
                ? () => _showConversionSummaryDialog(context, provider, c)
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
    CapTableProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ConvertibleDialog(provider: provider),
    );
  }

  void _showEditConvertibleDialog(
    BuildContext context,
    CapTableProvider provider,
    ConvertibleInstrument convertible,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _ConvertibleDialog(provider: provider, convertible: convertible),
    );
  }

  void _showConvertDialog(
    BuildContext context,
    CapTableProvider provider,
    ConvertibleInstrument convertible,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _ConversionDialog(provider: provider, convertible: convertible),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CapTableProvider provider,
    ConvertibleInstrument convertible,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Convertible?'),
        content: const Text(
          'This will permanently remove this convertible instrument.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteConvertible(convertible.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showConversionSummaryDialog(
    BuildContext context,
    CapTableProvider provider,
    ConvertibleInstrument convertible,
  ) {
    final investor = provider.getInvestorById(convertible.investorId);
    final round = convertible.conversionRoundId != null
        ? provider.getRoundById(convertible.conversionRoundId!)
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
              _SummaryRow(
                label: 'Investor',
                value: investor?.name ?? 'Unknown',
              ),
              _SummaryRow(
                label: 'Instrument',
                value: convertible.typeDisplayName,
              ),
              _SummaryRow(
                label: 'Principal',
                value: Formatters.currency(convertible.principalAmount),
              ),
              if (convertible.type == ConvertibleType.convertibleNote &&
                  convertible.accruedInterest > 0)
                _SummaryRow(
                  label: 'Accrued Interest',
                  value: Formatters.currency(convertible.accruedInterest),
                ),
              _SummaryRow(
                label: 'Total Converted',
                value: Formatters.currency(convertible.convertibleAmount),
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: 'Converted In',
                value: round?.name ?? 'Unknown Round',
              ),
              if (convertible.conversionDate != null)
                _SummaryRow(
                  label: 'Conversion Date',
                  value: Formatters.date(convertible.conversionDate!),
                ),
              if (convertible.conversionPricePerShare != null)
                _SummaryRow(
                  label: 'Conversion Price',
                  value: Formatters.currency(
                    convertible.conversionPricePerShare!,
                  ),
                ),
              if (convertible.conversionShares != null)
                _SummaryRow(
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              final success = await provider.undoConversion(convertible.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Conversion undone successfully'
                          : 'Failed to undo conversion',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.undo),
            label: const Text('Undo Conversion'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: valueStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermChip extends StatelessWidget {
  final String label;

  const _TermChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _ConvertibleDialog extends StatefulWidget {
  final CapTableProvider provider;
  final ConvertibleInstrument? convertible;

  const _ConvertibleDialog({required this.provider, this.convertible});

  @override
  State<_ConvertibleDialog> createState() => _ConvertibleDialogState();
}

class _ConvertibleDialogState extends State<_ConvertibleDialog> {
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

            // Investor dropdown
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Issue Date'),
              trailing: TextButton(
                onPressed: () => _pickDate(context, isIssue: true),
                child: Text(Formatters.date(_issueDate)),
              ),
            ),
            if (_type == ConvertibleType.convertibleNote)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Maturity Date'),
                trailing: TextButton(
                  onPressed: () => _pickDate(context, isIssue: false),
                  child: Text(
                    _maturityDate != null
                        ? Formatters.date(_maturityDate!)
                        : 'Set',
                  ),
                ),
              ),

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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSave() ? _save : null,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  bool _canSave() {
    return _investorId != null &&
        _principalController.text.isNotEmpty &&
        double.tryParse(_principalController.text) != null;
  }

  Future<void> _pickDate(BuildContext context, {required bool isIssue}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isIssue ? _issueDate : (_maturityDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssue) {
          _issueDate = picked;
        } else {
          _maturityDate = picked;
        }
      });
    }
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
      widget.provider.updateConvertible(convertible);
    } else {
      widget.provider.addConvertible(convertible);
    }

    Navigator.pop(context);
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

class _ConversionDialog extends StatefulWidget {
  final CapTableProvider provider;
  final ConvertibleInstrument convertible;

  const _ConversionDialog({required this.provider, required this.convertible});

  @override
  State<_ConversionDialog> createState() => _ConversionDialogState();
}

class _ConversionDialogState extends State<_ConversionDialog> {
  String? _roundId;
  String? _shareClassId;

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final convertible = widget.convertible;

    // Calculate conversion details if round selected
    int? shares;
    double? pps;
    if (_roundId != null) {
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
    }

    return AlertDialog(
      title: const Text('Convert to Equity'),
      content: SingleChildScrollView(
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

            // Round selection
            DropdownButtonFormField<String>(
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
            const SizedBox(height: 16),

            // Share class selection
            DropdownButtonFormField<String>(
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
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion Preview',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canConvert() ? _convert : null,
          child: const Text('Convert'),
        ),
      ],
    );
  }

  bool _canConvert() => _roundId != null && _shareClassId != null;

  void _convert() {
    final round = widget.provider.getRoundById(_roundId!);
    widget.provider.convertConvertible(
      widget.convertible.id,
      _shareClassId!,
      _roundId!,
      round?.date ?? DateTime.now(),
    );
    Navigator.pop(context);
  }
}
