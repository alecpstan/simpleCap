import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../valuation_helpers.dart';
import '../../../../shared/utils/helpers.dart';

/// Scorecard valuation method widget.
/// Adjusts a base valuation based on weighted factor scores.
class ScorecardMethod extends StatefulWidget {
  final Map<String, dynamic> initialParams;
  final void Function(double value, Map<String, dynamic> params) onValuationChanged;

  const ScorecardMethod({
    super.key,
    required this.initialParams,
    required this.onValuationChanged,
  });

  @override
  State<ScorecardMethod> createState() => _ScorecardMethodState();
}

class _ScorecardMethodState extends State<ScorecardMethod> {
  late TextEditingController _baseValuationController;
  late Map<String, double> _scores;

  @override
  void initState() {
    super.initState();

    _baseValuationController = TextEditingController(
      text: widget.initialParams['baseValuation']?.toString() ?? '',
    );

    final savedScores = widget.initialParams['scores'] as Map<String, dynamic>? ?? {};
    _scores = {};
    for (final factor in ScorecardFactors.factors) {
      _scores[factor.key] = (savedScores[factor.key] as num?)?.toDouble() ?? 0.5;
    }

    _baseValuationController.addListener(_recalculate);

    if (widget.initialParams.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalculate());
    }
  }

  @override
  void dispose() {
    _baseValuationController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final baseValuation = double.tryParse(
      _baseValuationController.text.replaceAll(',', ''),
    ) ?? 0;

    final valuation = calculateScorecardValuation(
      baseValuation: baseValuation,
      scores: _scores,
    );

    widget.onValuationChanged(valuation, {
      'baseValuation': baseValuation,
      'scores': Map<String, double>.from(_scores),
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
            'Scorecard Method',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust a base valuation up or down based on how your startup scores across key factors.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 32),

          // Base valuation input
          Text(
            'Base Valuation (AUD)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Average pre-money valuation for similar stage startups in your region',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _baseValuationController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixText: '\$ ',
              hintText: 'e.g., 2000000',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),

          // Quick preset buttons
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _QuickValueChip(
                label: '\$1M',
                value: 1000000,
                onTap: () {
                  _baseValuationController.text = '1000000';
                  _recalculate();
                },
              ),
              _QuickValueChip(
                label: '\$2M',
                value: 2000000,
                onTap: () {
                  _baseValuationController.text = '2000000';
                  _recalculate();
                },
              ),
              _QuickValueChip(
                label: '\$3M',
                value: 3000000,
                onTap: () {
                  _baseValuationController.text = '3000000';
                  _recalculate();
                },
              ),
              _QuickValueChip(
                label: '\$5M',
                value: 5000000,
                onTap: () {
                  _baseValuationController.text = '5000000';
                  _recalculate();
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Factor scores
          Text(
            'Factor Scores',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rate each factor from "Below Average" to "Above Average"',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),

          ...ScorecardFactors.factors.map((factor) {
            return _FactorSlider(
              factor: factor,
              value: _scores[factor.key] ?? 0.5,
              onChanged: (value) {
                setState(() => _scores[factor.key] = value);
                _recalculate();
              },
            );
          }),

          const SizedBox(height: 24),

          // Adjustment summary
          _buildAdjustmentSummary(context),
        ],
      ),
    );
  }

  Widget _buildAdjustmentSummary(BuildContext context) {
    final theme = Theme.of(context);
    final baseValuation = double.tryParse(
      _baseValuationController.text.replaceAll(',', ''),
    ) ?? 0;

    double totalAdjustment = 0;
    for (final factor in ScorecardFactors.factors) {
      final score = _scores[factor.key] ?? 0.5;
      totalAdjustment += factor.weight * (score - 0.5) * 2 / 100;
    }

    final adjustmentPercent = (totalAdjustment * 100).toStringAsFixed(1);
    final isPositive = totalAdjustment >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adjustment Summary',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Base Valuation', style: theme.textTheme.bodySmall),
                    Text(
                      Formatters.compactCurrency(baseValuation),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Adjustment', style: theme.textTheme.bodySmall),
                    Text(
                      '${isPositive ? '+' : ''}$adjustmentPercent%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickValueChip extends StatelessWidget {
  final String label;
  final double value;
  final VoidCallback onTap;

  const _QuickValueChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _FactorSlider extends StatelessWidget {
  final ScorecardFactor factor;
  final double value;
  final ValueChanged<double> onChanged;

  const _FactorSlider({
    required this.factor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String getLabel() {
      if (value < 0.35) return 'Below Avg';
      if (value > 0.65) return 'Above Avg';
      return 'Average';
    }

    Color getColor() {
      if (value < 0.35) return Colors.red;
      if (value > 0.65) return Colors.green;
      return Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${factor.name} (${factor.weight.toStringAsFixed(0)}%)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      factor.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: getColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getLabel(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: getColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
