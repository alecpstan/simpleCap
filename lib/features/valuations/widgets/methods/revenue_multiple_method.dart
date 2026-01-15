import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../valuation_helpers.dart';
import '../../../../shared/utils/helpers.dart';

/// Revenue multiple valuation method widget.
/// Calculates valuation = annual revenue × industry multiple.
class RevenueMultipleMethod extends StatefulWidget {
  final Map<String, dynamic> initialParams;
  final void Function(double value, Map<String, dynamic> params) onValuationChanged;

  const RevenueMultipleMethod({
    super.key,
    required this.initialParams,
    required this.onValuationChanged,
  });

  @override
  State<RevenueMultipleMethod> createState() => _RevenueMultipleMethodState();
}

class _RevenueMultipleMethodState extends State<RevenueMultipleMethod> {
  late Industry _selectedIndustry;
  late TextEditingController _revenueController;
  late double _multiple;

  @override
  void initState() {
    super.initState();
    _selectedIndustry = widget.initialParams['industry'] != null
        ? Industry.values[widget.initialParams['industry'] as int]
        : Industry.saas;
    _revenueController = TextEditingController(
      text: widget.initialParams['revenue']?.toString() ?? '',
    );
    _multiple = widget.initialParams['multiple'] as double? ??
        _selectedIndustry.defaultMultiple;

    _revenueController.addListener(_recalculate);

    // Initial calculation if editing
    if (widget.initialParams.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalculate());
    }
  }

  @override
  void dispose() {
    _revenueController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final revenue = double.tryParse(_revenueController.text.replaceAll(',', '')) ?? 0;
    final valuation = calculateRevenueMultipleValuation(
      annualRevenue: revenue,
      multiple: _multiple,
    );
    widget.onValuationChanged(valuation, {
      'industry': _selectedIndustry.index,
      'revenue': revenue,
      'multiple': _multiple,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = _selectedIndustry.multipleRange;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Multiple Method',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Value your company based on annual revenue multiplied by an industry-specific multiple.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 32),

          // Industry selector
          Text(
            'Industry',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Industry>(
            value: _selectedIndustry,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: Industry.values.map((industry) {
              return DropdownMenuItem(
                value: industry,
                child: Text(industry.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedIndustry = value;
                  _multiple = value.defaultMultiple;
                });
                _recalculate();
              }
            },
          ),
          const SizedBox(height: 8),

          // Industry description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedIndustry.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Annual revenue input
          Text(
            'Annual Revenue (AUD)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _revenueController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixText: '\$ ',
              hintText: 'Enter annual revenue',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 24),

          // Multiple slider
          Text(
            'Revenue Multiple: ${_multiple.toStringAsFixed(1)}x',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${range.$1.toStringAsFixed(0)}x',
                style: theme.textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: _multiple,
                  min: range.$1,
                  max: range.$2,
                  divisions: ((range.$2 - range.$1) * 2).round(),
                  label: '${_multiple.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    setState(() => _multiple = value);
                    _recalculate();
                  },
                ),
              ),
              Text(
                '${range.$2.toStringAsFixed(0)}x',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Formula preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calculation',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${Formatters.compactCurrency(double.tryParse(_revenueController.text.replaceAll(',', '')) ?? 0)} × ${_multiple.toStringAsFixed(1)}x',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
