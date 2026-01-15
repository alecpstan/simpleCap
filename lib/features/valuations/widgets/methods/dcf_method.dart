import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../valuation_helpers.dart';
import '../../../../shared/utils/helpers.dart';

/// Discounted Cash Flow valuation method widget.
/// Calculates present value of projected future cash flows.
class DcfMethod extends StatefulWidget {
  final Map<String, dynamic> initialParams;
  final void Function(double value, Map<String, dynamic> params) onValuationChanged;

  const DcfMethod({
    super.key,
    required this.initialParams,
    required this.onValuationChanged,
  });

  @override
  State<DcfMethod> createState() => _DcfMethodState();
}

class _DcfMethodState extends State<DcfMethod> {
  late List<TextEditingController> _projectionControllers;
  late double _terminalGrowthRate;
  late double _discountRate;

  static const int _projectionYears = 5;

  @override
  void initState() {
    super.initState();

    final projections = widget.initialParams['projections'] as List<dynamic>? ?? [];
    _projectionControllers = List.generate(_projectionYears, (i) {
      final value = i < projections.length ? projections[i] : null;
      return TextEditingController(text: value?.toString() ?? '');
    });

    _terminalGrowthRate = (widget.initialParams['terminalGrowth'] as num?)?.toDouble() ?? 3.0;
    _discountRate = (widget.initialParams['discountRate'] as num?)?.toDouble() ?? 15.0;

    for (final controller in _projectionControllers) {
      controller.addListener(_recalculate);
    }

    if (widget.initialParams.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalculate());
    }
  }

  @override
  void dispose() {
    for (final controller in _projectionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _recalculate() {
    final projections = _projectionControllers
        .map((c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0)
        .toList();

    final valuation = calculateDcfValuation(
      projectedCashFlows: projections,
      terminalGrowthRate: _terminalGrowthRate / 100,
      discountRate: _discountRate / 100,
    );

    widget.onValuationChanged(valuation, {
      'projections': projections,
      'terminalGrowth': _terminalGrowthRate,
      'discountRate': _discountRate,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discounted Cash Flow',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calculate the present value of projected future cash flows, discounted back to today\'s value.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 32),

          // Cash flow projections
          Text(
            'Projected Annual Cash Flows (AUD)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(_projectionYears, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Year ${i + 1}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _projectionControllers[i],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Terminal growth rate
          Text(
            'Terminal Growth Rate: ${_terminalGrowthRate.toStringAsFixed(1)}%',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Expected long-term growth rate after the projection period',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Slider(
            value: _terminalGrowthRate,
            min: 0,
            max: 10,
            divisions: 20,
            label: '${_terminalGrowthRate.toStringAsFixed(1)}%',
            onChanged: (value) {
              setState(() => _terminalGrowthRate = value);
              _recalculate();
            },
          ),

          const SizedBox(height: 16),

          // Discount rate
          Text(
            'Discount Rate (WACC): ${_discountRate.toStringAsFixed(1)}%',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Required rate of return - typically 10-20% for startups',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Slider(
            value: _discountRate,
            min: 5,
            max: 30,
            divisions: 25,
            label: '${_discountRate.toStringAsFixed(1)}%',
            onChanged: (value) {
              setState(() => _discountRate = value);
              _recalculate();
            },
          ),

          const SizedBox(height: 32),

          // Calculation breakdown
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
                  'Calculation Breakdown',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBreakdownRow(
                  context,
                  'PV of Cash Flows',
                  _calculatePVCashFlows(),
                ),
                _buildBreakdownRow(
                  context,
                  'PV of Terminal Value',
                  _calculatePVTerminal(),
                ),
                const Divider(height: 16),
                _buildBreakdownRow(
                  context,
                  'Total Enterprise Value',
                  _calculatePVCashFlows() + _calculatePVTerminal(),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(BuildContext context, String label, double value,
      {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium,
          ),
          Text(
            Formatters.compactCurrency(value),
            style: isTotal
                ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  double _calculatePVCashFlows() {
    final projections = _projectionControllers
        .map((c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0)
        .toList();

    double pv = 0;
    for (int i = 0; i < projections.length; i++) {
      pv += projections[i] / _pow(1 + _discountRate / 100, i + 1);
    }
    return pv;
  }

  double _calculatePVTerminal() {
    final projections = _projectionControllers
        .map((c) => double.tryParse(c.text.replaceAll(',', '')) ?? 0)
        .toList();

    if (projections.isEmpty || projections.last == 0) return 0;
    if (_discountRate <= _terminalGrowthRate) return 0;

    final terminalCF = projections.last * (1 + _terminalGrowthRate / 100);
    final terminalValue = terminalCF / ((_discountRate - _terminalGrowthRate) / 100);
    return terminalValue / _pow(1 + _discountRate / 100, projections.length);
  }

  double _pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
