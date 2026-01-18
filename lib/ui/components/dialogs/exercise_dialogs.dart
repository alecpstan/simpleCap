import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/providers.dart';
import '../../../domain/constants/type_constants.dart';
import '../../../infrastructure/database/database.dart';
import '../../../shared/formatters.dart';
import '../feedback/info_box.dart';

// ============================================================
// Exercise Options Dialog
// ============================================================

/// Dialog for exercising stock options.
///
/// Accessible from both the options page and stakeholders page.
class ExerciseOptionsDialog extends ConsumerStatefulWidget {
  final OptionGrant option;
  final int maxExercisable;
  final String? stakeholderName;

  const ExerciseOptionsDialog({
    super.key,
    required this.option,
    required this.maxExercisable,
    this.stakeholderName,
  });

  /// Show the dialog and return true if options were exercised.
  static Future<bool?> show({
    required BuildContext context,
    required OptionGrant option,
    required int maxExercisable,
    String? stakeholderName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ExerciseOptionsDialog(
        option: option,
        maxExercisable: maxExercisable,
        stakeholderName: stakeholderName,
      ),
    );
  }

  @override
  ConsumerState<ExerciseOptionsDialog> createState() =>
      _ExerciseOptionsDialogState();
}

class _ExerciseOptionsDialogState extends ConsumerState<ExerciseOptionsDialog> {
  final _sharesController = TextEditingController();
  final _fmvController = TextEditingController();
  final _taxRateController = TextEditingController(text: '22');
  DateTime _exerciseDate = DateTime.now();
  String _exerciseType = ExerciseType.cash;
  bool _isProcessing = false;

  int get _shares => int.tryParse(_sharesController.text) ?? 0;
  double get _totalCost => _shares * widget.option.strikePrice;
  double? get _fmv => double.tryParse(_fmvController.text);
  double get _taxRate => (double.tryParse(_taxRateController.text) ?? 22) / 100;
  bool get _isValid {
    if (_shares <= 0 || _shares > widget.maxExercisable) return false;
    if (ExerciseType.withholdsShares(_exerciseType) ||
        ExerciseType.involvesSale(_exerciseType)) {
      if (_fmv == null || _fmv! <= 0) return false;
    }
    return true;
  }

  /// Calculate shares withheld to cover strike price (for net exercise).
  int get _sharesWithheldForStrike {
    if (!ExerciseType.withholdsShares(_exerciseType) ||
        _fmv == null ||
        _fmv! <= 0) {
      return 0;
    }
    // Shares needed = strike cost / FMV
    return (_totalCost / _fmv!).ceil();
  }

  /// Calculate shares withheld for taxes (for netWithTax or cashless).
  int get _sharesWithheldForTax {
    if (_exerciseType != ExerciseType.netWithTax ||
        _fmv == null ||
        _fmv! <= 0) {
      return 0;
    }
    // Tax on the spread (FMV - strike) for each share
    final spread = (_fmv! - widget.option.strikePrice) * _shares;
    if (spread <= 0) return 0;
    final taxAmount = spread * _taxRate;
    return (taxAmount / _fmv!).ceil();
  }

  /// Net shares received after withholding.
  int get _netSharesReceived {
    if (_exerciseType == ExerciseType.cash) return _shares;
    if (_exerciseType == ExerciseType.cashless)
      return 0; // Cashless results in cash, not shares
    return (_shares - _sharesWithheldForStrike - _sharesWithheldForTax).clamp(
      0,
      _shares,
    );
  }

  /// For cashless: proceeds received after costs.
  double get _proceedsReceived {
    if (_exerciseType != ExerciseType.cashless || _fmv == null) return 0;
    final grossProceeds = _shares * _fmv!;
    final strikeCost = _totalCost;
    final spread = (_fmv! - widget.option.strikePrice) * _shares;
    final taxWithholding = spread > 0 ? spread * _taxRate : 0;
    return (grossProceeds - strikeCost - taxWithholding).clamp(
      0,
      double.infinity,
    );
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _fmvController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveValuation = ref
        .watch(effectiveValuationProvider)
        .valueOrNull;
    final ownership = ref.watch(ownershipSummaryProvider).valueOrNull;

    // Calculate current price per share if valuation available
    double? pricePerShare;
    if (effectiveValuation != null && ownership != null) {
      final totalShares = ownership.totalIssuedShares;
      if (totalShares > 0) {
        pricePerShare = effectiveValuation.value / totalShares;
      }
    }

    final currentValue = pricePerShare != null ? _shares * pricePerShare : null;
    final potentialGain = currentValue != null
        ? currentValue - _totalCost
        : null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.call_made, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Exercise Options')),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.stakeholderName != null) ...[
                Text(
                  widget.stakeholderName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                '${Formatters.number(widget.maxExercisable)} vested options available to exercise',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),

              // Options to exercise input
              TextField(
                controller: _sharesController,
                decoration: InputDecoration(
                  labelText: 'Options to Exercise',
                  helperText:
                      'Max: ${Formatters.number(widget.maxExercisable)}',
                  suffixIcon: TextButton(
                    onPressed: () {
                      _sharesController.text = widget.maxExercisable.toString();
                      setState(() {});
                    },
                    child: const Text('Max'),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Exercise date picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _exerciseDate,
                    firstDate: widget.option.grantDate,
                    lastDate: widget.option.expiryDate.isBefore(DateTime.now())
                        ? widget.option.expiryDate
                        : DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _exerciseDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Exercise Date',
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(Formatters.date(_exerciseDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Exercise Type Selector
              DropdownButtonFormField<String>(
                value: _exerciseType,
                decoration: const InputDecoration(labelText: 'Exercise Type'),
                items: ExerciseType.all
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [Text(ExerciseType.displayName(type))],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _exerciseType = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                ExerciseType.description(_exerciseType),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),

              // FMV input (required for non-cash exercise)
              if (_exerciseType != ExerciseType.cash) ...[
                TextField(
                  controller: _fmvController,
                  decoration: InputDecoration(
                    labelText: 'Fair Market Value per Share',
                    prefixText: '\$ ',
                    helperText: pricePerShare != null
                        ? 'Current valuation: ${Formatters.currency(pricePerShare)}'
                        : 'Enter the FMV at time of exercise',
                    suffixIcon: pricePerShare != null
                        ? TextButton(
                            onPressed: () {
                              _fmvController.text = pricePerShare!
                                  .toStringAsFixed(2);
                              setState(() {});
                            },
                            child: const Text('Use'),
                          )
                        : null,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
              ],

              // Tax rate input (for netWithTax and cashless)
              if (_exerciseType == ExerciseType.netWithTax ||
                  _exerciseType == ExerciseType.cashless) ...[
                TextField(
                  controller: _taxRateController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Withholding Rate',
                    suffixText: '%',
                    helperText: 'Federal supplemental rate is typically 22%',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
              ],

              // Exercise Summary
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
                      'Exercise Summary',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Strike Price',
                      value: Formatters.currency(widget.option.strikePrice),
                    ),
                    _SummaryRow(
                      label: 'Options to Exercise',
                      value: Formatters.number(_shares),
                    ),
                    if (_fmv != null && _exerciseType != ExerciseType.cash) ...[
                      _SummaryRow(
                        label: 'Fair Market Value',
                        value: Formatters.currency(_fmv!),
                      ),
                    ],
                    const Divider(height: 16),

                    // Cash exercise: show total cost
                    if (_exerciseType == ExerciseType.cash) ...[
                      _SummaryRow(
                        label: 'Total Cost (Cash)',
                        value: Formatters.currency(_totalCost),
                        isBold: true,
                        valueColor: theme.colorScheme.primary,
                      ),
                      _SummaryRow(
                        label: 'Shares Received',
                        value: Formatters.number(_shares),
                        isBold: true,
                      ),
                    ],

                    // Net exercise: show withholding and net shares
                    if (ExerciseType.withholdsShares(_exerciseType) &&
                        _fmv != null) ...[
                      _SummaryRow(
                        label: 'Shares for Strike',
                        value:
                            '- ${Formatters.number(_sharesWithheldForStrike)}',
                        valueColor: Colors.orange,
                      ),
                      if (_exerciseType == ExerciseType.netWithTax)
                        _SummaryRow(
                          label: 'Shares for Tax',
                          value:
                              '- ${Formatters.number(_sharesWithheldForTax)}',
                          valueColor: Colors.orange,
                        ),
                      const Divider(height: 16),
                      _SummaryRow(
                        label: 'Net Shares Received',
                        value: Formatters.number(_netSharesReceived),
                        isBold: true,
                        valueColor: theme.colorScheme.primary,
                      ),
                    ],

                    // Cashless exercise: show proceeds
                    if (_exerciseType == ExerciseType.cashless &&
                        _fmv != null) ...[
                      _SummaryRow(
                        label: 'Gross Proceeds',
                        value: Formatters.currency(_shares * _fmv!),
                      ),
                      _SummaryRow(
                        label: 'Strike Cost',
                        value: '- ${Formatters.currency(_totalCost)}',
                        valueColor: Colors.orange,
                      ),
                      if (_taxRate > 0)
                        _SummaryRow(
                          label: 'Tax Withholding',
                          value:
                              '- ${Formatters.currency((_fmv! - widget.option.strikePrice) * _shares * _taxRate)}',
                          valueColor: Colors.orange,
                        ),
                      const Divider(height: 16),
                      _SummaryRow(
                        label: 'Net Proceeds',
                        value: Formatters.currency(_proceedsReceived),
                        isBold: true,
                        valueColor: theme.colorScheme.primary,
                      ),
                      _SummaryRow(
                        label: 'Shares Received',
                        value: '0 (same-day sale)',
                        valueColor: theme.colorScheme.outline,
                      ),
                    ],

                    // Show gain/loss for cash exercise
                    if (_exerciseType == ExerciseType.cash &&
                        pricePerShare != null &&
                        _shares > 0) ...[
                      const Divider(height: 16),
                      _SummaryRow(
                        label: 'Current Price/Share',
                        value: Formatters.currency(pricePerShare),
                      ),
                      _SummaryRow(
                        label: 'Current Value',
                        value: Formatters.currency(currentValue!),
                      ),
                      _SummaryRow(
                        label: 'Potential Gain/Loss',
                        value: Formatters.currency(potentialGain!),
                        valueColor: potentialGain >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info box based on exercise type
              InfoBox(
                type: InfoBoxType.info,
                message: switch (_exerciseType) {
                  ExerciseType.cash =>
                    'Cash exercise: Pay the strike price in cash to acquire shares.',
                  ExerciseType.cashless =>
                    'Cashless (same-day sale): All shares are sold at market price. You receive cash after deducting strike cost and taxes.',
                  ExerciseType.net =>
                    'Net exercise: Shares are withheld to cover the strike price. No cash payment required.',
                  ExerciseType.netWithTax =>
                    'Net exercise with tax: Shares are withheld for both strike price and tax withholding.',
                  _ => 'Exercise your options to convert them to shares.',
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isValid && !_isProcessing ? _exercise : null,
          icon: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check, size: 18),
          label: Text(_isProcessing ? 'Processing...' : 'Exercise'),
        ),
      ],
    );
  }

  Future<void> _exercise() async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(optionGrantCommandsProvider.notifier)
          .exerciseOptions(
            grantId: widget.option.id,
            exercisedCount: _shares,
            exercisePrice: widget.option.strikePrice,
            exerciseDate: _exerciseDate,
            exerciseType: _exerciseType,
            sharesWithheldForStrike: ExerciseType.withholdsShares(_exerciseType)
                ? _sharesWithheldForStrike
                : null,
            sharesWithheldForTax: _exerciseType == ExerciseType.netWithTax
                ? _sharesWithheldForTax
                : null,
            netSharesReceived: _exerciseType != ExerciseType.cash
                ? _netSharesReceived
                : null,
            fairMarketValue: _exerciseType != ExerciseType.cash ? _fmv : null,
            proceedsReceived: _exerciseType == ExerciseType.cashless
                ? _proceedsReceived
                : null,
          );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
}

// ============================================================
// Exercise Warrants Dialog
// ============================================================

/// Dialog for exercising warrants.
///
/// Accessible from both the warrants page and stakeholders page.
class ExerciseWarrantsDialog extends ConsumerStatefulWidget {
  final Warrant warrant;
  final int maxExercisable;
  final String? stakeholderName;

  const ExerciseWarrantsDialog({
    super.key,
    required this.warrant,
    required this.maxExercisable,
    this.stakeholderName,
  });

  /// Show the dialog and return true if warrants were exercised.
  static Future<bool?> show({
    required BuildContext context,
    required Warrant warrant,
    required int maxExercisable,
    String? stakeholderName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ExerciseWarrantsDialog(
        warrant: warrant,
        maxExercisable: maxExercisable,
        stakeholderName: stakeholderName,
      ),
    );
  }

  @override
  ConsumerState<ExerciseWarrantsDialog> createState() =>
      _ExerciseWarrantsDialogState();
}

class _ExerciseWarrantsDialogState
    extends ConsumerState<ExerciseWarrantsDialog> {
  final _sharesController = TextEditingController();
  final _fmvController = TextEditingController();
  final _taxRateController = TextEditingController(text: '22');
  DateTime _exerciseDate = DateTime.now();
  String _exerciseType = ExerciseType.cash;
  bool _isProcessing = false;

  int get _shares => int.tryParse(_sharesController.text) ?? 0;
  double get _totalCost => _shares * widget.warrant.strikePrice;
  double? get _fmv => double.tryParse(_fmvController.text);
  double get _taxRate => (double.tryParse(_taxRateController.text) ?? 22) / 100;
  bool get _isValid {
    if (_shares <= 0 || _shares > widget.maxExercisable) return false;
    if (ExerciseType.withholdsShares(_exerciseType) ||
        ExerciseType.involvesSale(_exerciseType)) {
      if (_fmv == null || _fmv! <= 0) return false;
    }
    return true;
  }

  /// Calculate shares withheld to cover strike price (for net exercise).
  int get _sharesWithheldForStrike {
    if (!ExerciseType.withholdsShares(_exerciseType) ||
        _fmv == null ||
        _fmv! <= 0) {
      return 0;
    }
    return (_totalCost / _fmv!).ceil();
  }

  /// Calculate shares withheld for taxes (for netWithTax).
  int get _sharesWithheldForTax {
    if (_exerciseType != ExerciseType.netWithTax ||
        _fmv == null ||
        _fmv! <= 0) {
      return 0;
    }
    final spread = (_fmv! - widget.warrant.strikePrice) * _shares;
    if (spread <= 0) return 0;
    final taxAmount = spread * _taxRate;
    return (taxAmount / _fmv!).ceil();
  }

  /// Net shares received after withholding.
  int get _netSharesReceived {
    if (_exerciseType == ExerciseType.cash) return _shares;
    if (_exerciseType == ExerciseType.cashless) return 0;
    return (_shares - _sharesWithheldForStrike - _sharesWithheldForTax).clamp(
      0,
      _shares,
    );
  }

  /// For cashless: proceeds received after costs.
  double get _proceedsReceived {
    if (_exerciseType != ExerciseType.cashless || _fmv == null) return 0;
    final grossProceeds = _shares * _fmv!;
    final strikeCost = _totalCost;
    final spread = (_fmv! - widget.warrant.strikePrice) * _shares;
    final taxWithholding = spread > 0 ? spread * _taxRate : 0;
    return (grossProceeds - strikeCost - taxWithholding).clamp(
      0,
      double.infinity,
    );
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _fmvController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveValuation = ref
        .watch(effectiveValuationProvider)
        .valueOrNull;
    final ownership = ref.watch(ownershipSummaryProvider).valueOrNull;

    // Calculate current price per share if valuation available
    double? pricePerShare;
    if (effectiveValuation != null && ownership != null) {
      final totalShares = ownership.totalIssuedShares;
      if (totalShares > 0) {
        pricePerShare = effectiveValuation.value / totalShares;
      }
    }

    final currentValue = pricePerShare != null ? _shares * pricePerShare : null;
    final potentialGain = currentValue != null
        ? currentValue - _totalCost
        : null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.receipt_long, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Exercise Warrants')),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.stakeholderName != null) ...[
                Text(
                  widget.stakeholderName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                '${Formatters.number(widget.maxExercisable)} warrants available to exercise',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),

              // Warrants to exercise input
              TextField(
                controller: _sharesController,
                decoration: InputDecoration(
                  labelText: 'Warrants to Exercise',
                  helperText:
                      'Max: ${Formatters.number(widget.maxExercisable)}',
                  suffixIcon: TextButton(
                    onPressed: () {
                      _sharesController.text = widget.maxExercisable.toString();
                      setState(() {});
                    },
                    child: const Text('Max'),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Exercise date picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _exerciseDate,
                    firstDate: widget.warrant.issueDate,
                    lastDate: widget.warrant.expiryDate.isBefore(DateTime.now())
                        ? widget.warrant.expiryDate
                        : DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _exerciseDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Exercise Date',
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(Formatters.date(_exerciseDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Exercise Type Selector
              DropdownButtonFormField<String>(
                value: _exerciseType,
                decoration: const InputDecoration(labelText: 'Exercise Type'),
                items: ExerciseType.all
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [Text(ExerciseType.displayName(type))],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _exerciseType = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                ExerciseType.description(_exerciseType),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),

              // FMV input (required for non-cash exercise)
              if (_exerciseType != ExerciseType.cash) ...[
                TextField(
                  controller: _fmvController,
                  decoration: InputDecoration(
                    labelText: 'Fair Market Value per Share',
                    prefixText: '\$ ',
                    helperText: pricePerShare != null
                        ? 'Current valuation: ${Formatters.currency(pricePerShare)}'
                        : 'Enter the FMV at time of exercise',
                    suffixIcon: pricePerShare != null
                        ? TextButton(
                            onPressed: () {
                              _fmvController.text = pricePerShare!
                                  .toStringAsFixed(2);
                              setState(() {});
                            },
                            child: const Text('Use'),
                          )
                        : null,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
              ],

              // Tax rate input (for netWithTax and cashless)
              if (_exerciseType == ExerciseType.netWithTax ||
                  _exerciseType == ExerciseType.cashless) ...[
                TextField(
                  controller: _taxRateController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Withholding Rate',
                    suffixText: '%',
                    helperText: 'Federal supplemental rate is typically 22%',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
              ],

              // Exercise Summary
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
                      'Exercise Summary',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Strike Price',
                      value: Formatters.currency(widget.warrant.strikePrice),
                    ),
                    _SummaryRow(
                      label: 'Warrants to Exercise',
                      value: Formatters.number(_shares),
                    ),
                    if (_fmv != null && _exerciseType != ExerciseType.cash) ...[
                      _SummaryRow(
                        label: 'Fair Market Value',
                        value: Formatters.currency(_fmv!),
                      ),
                    ],
                    const Divider(height: 16),

                    // Cash exercise: show total cost
                    if (_exerciseType == ExerciseType.cash) ...[
                      _SummaryRow(
                        label: 'Total Cost (Cash)',
                        value: Formatters.currency(_totalCost),
                        isBold: true,
                        valueColor: theme.colorScheme.primary,
                      ),
                      _SummaryRow(
                        label: 'Shares Received',
                        value: Formatters.number(_shares),
                        isBold: true,
                      ),
                    ],

                    // Net exercise: show withholding and net shares
                    if (ExerciseType.withholdsShares(_exerciseType) &&
                        _fmv != null) ...[
                      _SummaryRow(
                        label: 'Shares for Strike',
                        value:
                            '- ${Formatters.number(_sharesWithheldForStrike)}',
                        valueColor: Colors.orange,
                      ),
                      if (_exerciseType == ExerciseType.netWithTax)
                        _SummaryRow(
                          label: 'Shares for Tax',
                          value:
                              '- ${Formatters.number(_sharesWithheldForTax)}',
                          valueColor: Colors.orange,
                        ),
                      const Divider(height: 16),
                      _SummaryRow(
                        label: 'Net Shares Received',
                        value: Formatters.number(_netSharesReceived),
                        isBold: true,
                        valueColor: theme.colorScheme.primary,
                      ),
                    ],

                    // Cashless exercise: show proceeds
                    if (_exerciseType == ExerciseType.cashless &&
                        _fmv != null) ...[
                      _SummaryRow(
                        label: 'Gross Proceeds',
                        value: Formatters.currency(_shares * _fmv!),
                      ),
                      _SummaryRow(
                        label: 'Strike Cost',
                        value: '- ${Formatters.currency(_totalCost)}',
                        valueColor: Colors.orange,
                      ),
                      if (_taxRate > 0)
                        _SummaryRow(
                          label: 'Tax Withholding',
                          value:
                              '- ${Formatters.currency((_fmv! - widget.warrant.strikePrice) * _shares * _taxRate)}',
                          valueColor: Colors.orange,
                        ),
                      const Divider(height: 16),
                      _SummaryRow(
                        label: 'Net Proceeds',
                        value: Formatters.currency(_proceedsReceived),
                        isBold: true,
                        valueColor: theme.colorScheme.primary,
                      ),
                      _SummaryRow(
                        label: 'Shares Received',
                        value: '0 (same-day sale)',
                        valueColor: theme.colorScheme.outline,
                      ),
                    ],

                    // Show gain/loss for cash exercise
                    if (_exerciseType == ExerciseType.cash &&
                        pricePerShare != null &&
                        _shares > 0) ...[
                      const Divider(height: 16),
                      _SummaryRow(
                        label: 'Current Price/Share',
                        value: Formatters.currency(pricePerShare),
                      ),
                      _SummaryRow(
                        label: 'Current Value',
                        value: Formatters.currency(currentValue!),
                      ),
                      _SummaryRow(
                        label: 'Potential Gain/Loss',
                        value: Formatters.currency(potentialGain!),
                        valueColor: potentialGain >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info box based on exercise type
              InfoBox(
                type: InfoBoxType.info,
                message: switch (_exerciseType) {
                  ExerciseType.cash =>
                    'Cash exercise: Pay the strike price in cash to acquire shares.',
                  ExerciseType.cashless =>
                    'Cashless (same-day sale): All warrants are sold at market price. You receive cash after deducting strike cost and taxes.',
                  ExerciseType.net =>
                    'Net exercise: Shares are withheld to cover the strike price. No cash payment required.',
                  ExerciseType.netWithTax =>
                    'Net exercise with tax: Shares are withheld for both strike price and tax withholding.',
                  _ => 'Exercise your warrants to convert them to shares.',
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isValid && !_isProcessing ? _exercise : null,
          icon: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check, size: 18),
          label: Text(_isProcessing ? 'Processing...' : 'Exercise'),
        ),
      ],
    );
  }

  Future<void> _exercise() async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(warrantCommandsProvider.notifier)
          .exerciseWarrants(
            warrantId: widget.warrant.id,
            exercisedCount: _shares,
            exercisePrice: widget.warrant.strikePrice,
            exerciseDate: _exerciseDate,
            exerciseType: _exerciseType,
            sharesWithheldForStrike: ExerciseType.withholdsShares(_exerciseType)
                ? _sharesWithheldForStrike
                : null,
            sharesWithheldForTax: _exerciseType == ExerciseType.netWithTax
                ? _sharesWithheldForTax
                : null,
            netSharesReceived: _exerciseType != ExerciseType.cash
                ? _netSharesReceived
                : null,
            fairMarketValue: _exerciseType != ExerciseType.cash ? _fmv : null,
            proceedsReceived: _exerciseType == ExerciseType.cashless
                ? _proceedsReceived
                : null,
          );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
}

// ============================================================
// Convert Convertible Dialog
// ============================================================

/// Dialog for converting convertibles (SAFEs/Notes) to shares.
///
/// Accessible from both the convertibles page and stakeholders page.
class ConvertConvertibleDialog extends ConsumerStatefulWidget {
  final Convertible convertible;
  final String? stakeholderName;

  const ConvertConvertibleDialog({
    super.key,
    required this.convertible,
    this.stakeholderName,
  });

  /// Show the dialog and return true if convertible was converted.
  static Future<bool?> show({
    required BuildContext context,
    required Convertible convertible,
    String? stakeholderName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConvertConvertibleDialog(
        convertible: convertible,
        stakeholderName: stakeholderName,
      ),
    );
  }

  @override
  ConsumerState<ConvertConvertibleDialog> createState() =>
      _ConvertConvertibleDialogState();
}

class _ConvertConvertibleDialogState
    extends ConsumerState<ConvertConvertibleDialog> {
  final _sharesController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedShareClassId;
  bool _isProcessing = false;

  int get _shares => int.tryParse(_sharesController.text) ?? 0;
  double get _conversionPrice => double.tryParse(_priceController.text) ?? 0;
  bool get _isValid =>
      _shares > 0 && _conversionPrice > 0 && _selectedShareClassId != null;

  @override
  void initState() {
    super.initState();
    // Defer default calculation to after the first frame to ensure providers are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDefaultShares();
    });
  }

  void _calculateDefaultShares() {
    // Get current share price from effective valuation
    final effectiveValuation = ref.read(effectiveValuationProvider).valueOrNull;
    final ownership = ref.read(ownershipSummaryProvider).valueOrNull;

    double currentSharePrice = 1.0; // Default fallback
    if (effectiveValuation != null && ownership != null) {
      final totalShares = ownership.totalIssuedShares;
      if (totalShares > 0) {
        currentSharePrice = effectiveValuation.value / totalShares;
      }
    }

    final principal = widget.convertible.principal;
    final discount = widget.convertible.discountPercent;

    // Apply discount if present
    double effectivePrice = currentSharePrice;
    if (discount != null && discount > 0) {
      effectivePrice = currentSharePrice * (1 - discount);
    }

    // Set the conversion price (editable)
    _priceController.text = effectivePrice.toStringAsFixed(4);

    // Calculate shares based on principal / effective price
    final shares = effectivePrice > 0
        ? (principal / effectivePrice).round()
        : 0;
    _sharesController.text = shares.toString();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.transform, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Convert to Shares')),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.stakeholderName != null) ...[
                Text(
                  widget.stakeholderName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Convertible details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                      label: 'Type',
                      value: widget.convertible.type.toUpperCase(),
                    ),
                    _SummaryRow(
                      label: 'Principal',
                      value: Formatters.currency(widget.convertible.principal),
                    ),
                    if (widget.convertible.valuationCap != null)
                      _SummaryRow(
                        label: 'Valuation Cap',
                        value: Formatters.currency(
                          widget.convertible.valuationCap!,
                        ),
                      ),
                    if (widget.convertible.discountPercent != null)
                      _SummaryRow(
                        label: 'Discount',
                        value:
                            '${(widget.convertible.discountPercent! * 100).toStringAsFixed(0)}%',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Share class selection
              shareClassesAsync.when(
                data: (shareClasses) => DropdownButtonFormField<String>(
                  value: _selectedShareClassId,
                  decoration: const InputDecoration(
                    labelText: 'Share Class',
                    helperText: 'Shares will be issued in this class',
                  ),
                  items: shareClasses
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedShareClassId = value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading share classes'),
              ),
              const SizedBox(height: 16),

              // Conversion price
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Conversion Price per Share',
                  prefixText: '\$ ',
                  helperText: 'Price used to calculate shares issued',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  _recalculateShares();
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Shares to issue
              TextField(
                controller: _sharesController,
                decoration: const InputDecoration(
                  labelText: 'Shares to Issue',
                  helperText: 'Number of shares investor will receive',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Conversion Summary
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
                      'Conversion Result',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Shares to Issue',
                      value: Formatters.number(_shares),
                      valueColor: Colors.green.shade700,
                      isBold: true,
                    ),
                    if (_conversionPrice > 0)
                      _SummaryRow(
                        label: 'Implied Value',
                        value: Formatters.currency(_shares * _conversionPrice),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info box
              const InfoBox(
                type: InfoBoxType.warning,
                message:
                    'Converting will mark this instrument as converted and issue shares to the investor. This action records a conversion event.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isValid && !_isProcessing ? _convert : null,
          icon: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.transform, size: 18),
          label: Text(_isProcessing ? 'Converting...' : 'Convert'),
        ),
      ],
    );
  }

  void _recalculateShares() {
    final price = double.tryParse(_priceController.text);
    if (price != null && price > 0) {
      final principal = widget.convertible.principal;
      // Use the entered price directly for voluntary conversion
      _sharesController.text = (principal / price).round().toString();
    }
  }

  Future<void> _convert() async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(convertibleCommandsProvider.notifier)
          .convertConvertible(
            convertibleId: widget.convertible.id,
            // No roundId for voluntary conversion
            toShareClassId: _selectedShareClassId!,
            sharesReceived: _shares,
            conversionPrice: _conversionPrice,
          );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
}

// ============================================================
// Helper Widgets
// ============================================================

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
