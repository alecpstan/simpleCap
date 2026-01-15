import 'package:flutter/material.dart';
import '../../valuation_helpers.dart';
import '../../../../shared/utils/helpers.dart';

/// Berkus method valuation widget.
/// Pre-revenue valuation based on milestone achievement.
class BerkusMethod extends StatefulWidget {
  final Map<String, dynamic> initialParams;
  final void Function(double value, Map<String, dynamic> params) onValuationChanged;

  const BerkusMethod({
    super.key,
    required this.initialParams,
    required this.onValuationChanged,
  });

  @override
  State<BerkusMethod> createState() => _BerkusMethodState();
}

class _BerkusMethodState extends State<BerkusMethod> {
  late Map<String, double> _scores;

  @override
  void initState() {
    super.initState();

    final savedScores = widget.initialParams['scores'] as Map<String, dynamic>? ?? {};
    _scores = {};
    for (final element in BerkusElements.elements) {
      _scores[element.key] = (savedScores[element.key] as num?)?.toDouble() ?? 0;
    }

    if (widget.initialParams.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalculate());
    }
  }

  void _recalculate() {
    final valuation = calculateBerkusValuation(scores: _scores);

    widget.onValuationChanged(valuation, {
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
            'Berkus Method',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Value pre-revenue startups based on key milestone achievements. Each element can contribute up to \$500K.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Maximum pre-revenue valuation: \$2.5M',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Element sliders
          ...BerkusElements.elements.map((element) {
            return _ElementSlider(
              element: element,
              value: _scores[element.key] ?? 0,
              onChanged: (value) {
                setState(() => _scores[element.key] = value);
                _recalculate();
              },
            );
          }),

          const SizedBox(height: 24),

          // Summary breakdown
          _buildSummary(context),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final theme = Theme.of(context);
    double total = 0;

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
            'Valuation Breakdown',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),

          ...BerkusElements.elements.map((element) {
            final value = (_scores[element.key] ?? 0) * BerkusElements.maxPerElement;
            total += value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(element.name, style: theme.textTheme.bodyMedium),
                  Text(
                    Formatters.compactCurrency(value),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Valuation',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Formatters.compactCurrency(total),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ElementSlider extends StatelessWidget {
  final BerkusElement element;
  final double value;
  final ValueChanged<double> onChanged;

  const _ElementSlider({
    required this.element,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dollarValue = value * BerkusElements.maxPerElement;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
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
                      element.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      element.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getValueColor(value).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  Formatters.compactCurrency(dollarValue),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _getValueColor(value),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('\$0', style: theme.textTheme.bodySmall),
              Expanded(
                child: Slider(
                  value: value,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  onChanged: onChanged,
                ),
              ),
              Text('\$500K', style: theme.textTheme.bodySmall),
            ],
          ),
          // Achievement level indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Not achieved',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                Text(
                  'Fully achieved',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColor(double value) {
    if (value < 0.3) return Colors.grey;
    if (value < 0.7) return Colors.orange;
    return Colors.green;
  }
}
