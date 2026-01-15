import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../valuation_helpers.dart';

/// Comparable companies valuation method widget.
/// Calculates valuation based on multiples from similar companies.
class ComparablesMethod extends StatefulWidget {
  final Map<String, dynamic> initialParams;
  final void Function(double value, Map<String, dynamic> params) onValuationChanged;

  const ComparablesMethod({
    super.key,
    required this.initialParams,
    required this.onValuationChanged,
  });

  @override
  State<ComparablesMethod> createState() => _ComparablesMethodState();
}

class _ComparablesMethodState extends State<ComparablesMethod> {
  late TextEditingController _metricController;
  late List<_ComparableCompany> _comparables;
  String _metricType = 'revenue';

  @override
  void initState() {
    super.initState();
    _metricController = TextEditingController(
      text: widget.initialParams['metric_value']?.toString() ?? '',
    );
    _metricType = widget.initialParams['metric_type'] as String? ?? 'revenue';

    final comparablesData = widget.initialParams['comparables'] as List<dynamic>? ?? [];
    _comparables = comparablesData.map((c) {
      final map = c as Map<String, dynamic>;
      return _ComparableCompany(
        name: map['name'] as String? ?? '',
        multiple: (map['multiple'] as num?)?.toDouble() ?? 0,
      );
    }).toList();

    if (_comparables.isEmpty) {
      _comparables = [_ComparableCompany(name: '', multiple: 0)];
    }

    _metricController.addListener(_recalculate);

    if (widget.initialParams.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalculate());
    }
  }

  @override
  void dispose() {
    _metricController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final metricValue = double.tryParse(_metricController.text.replaceAll(',', '')) ?? 0;
    final validMultiples = _comparables
        .where((c) => c.multiple > 0)
        .map((c) => c.multiple)
        .toList();

    final valuation = calculateComparablesValuation(
      companyMetric: metricValue,
      comparableMultiples: validMultiples,
    );

    widget.onValuationChanged(valuation, {
      'metric_type': _metricType,
      'metric_value': metricValue,
      'comparables': _comparables
          .where((c) => c.name.isNotEmpty || c.multiple > 0)
          .map((c) => {'name': c.name, 'multiple': c.multiple})
          .toList(),
    });
  }

  void _addComparable() {
    setState(() {
      _comparables.add(_ComparableCompany(name: '', multiple: 0));
    });
  }

  void _removeComparable(int index) {
    if (_comparables.length > 1) {
      setState(() {
        _comparables.removeAt(index);
      });
      _recalculate();
    }
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
            'Comparable Companies',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Value your company based on multiples from similar public or recently funded companies.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 32),

          // Your company's metric
          Text(
            'Your Company\'s Metric',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _metricType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Metric Type',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'revenue', child: Text('Annual Revenue')),
                    DropdownMenuItem(value: 'arr', child: Text('ARR')),
                    DropdownMenuItem(value: 'ebitda', child: Text('EBITDA')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _metricType = value);
                      _recalculate();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _metricController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                    labelText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Comparable companies
          Row(
            children: [
              Expanded(
                child: Text(
                  'Comparable Companies',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _comparables.length < 5 ? _addComparable : null,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...List.generate(_comparables.length, (index) {
            return _ComparableRow(
              key: ValueKey(index),
              company: _comparables[index],
              canRemove: _comparables.length > 1,
              onChanged: (name, multiple) {
                _comparables[index] = _ComparableCompany(
                  name: name,
                  multiple: multiple,
                );
                _recalculate();
              },
              onRemove: () => _removeComparable(index),
            );
          }),

          const SizedBox(height: 24),

          // Average multiple display
          if (_comparables.any((c) => c.multiple > 0)) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Multiple',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_calculateAverageMultiple().toStringAsFixed(1)}x',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Companies Used',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_comparables.where((c) => c.multiple > 0).length}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _calculateAverageMultiple() {
    final validMultiples = _comparables
        .where((c) => c.multiple > 0)
        .map((c) => c.multiple)
        .toList();
    if (validMultiples.isEmpty) return 0;
    return validMultiples.reduce((a, b) => a + b) / validMultiples.length;
  }
}

class _ComparableCompany {
  final String name;
  final double multiple;

  _ComparableCompany({required this.name, required this.multiple});
}

class _ComparableRow extends StatefulWidget {
  final _ComparableCompany company;
  final bool canRemove;
  final void Function(String name, double multiple) onChanged;
  final VoidCallback onRemove;

  const _ComparableRow({
    super.key,
    required this.company,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_ComparableRow> createState() => _ComparableRowState();
}

class _ComparableRowState extends State<_ComparableRow> {
  late TextEditingController _nameController;
  late TextEditingController _multipleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company.name);
    _multipleController = TextEditingController(
      text: widget.company.multiple > 0 ? widget.company.multiple.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _multipleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Company name',
                isDense: true,
              ),
              onChanged: (value) {
                widget.onChanged(
                  value,
                  double.tryParse(_multipleController.text) ?? 0,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _multipleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Multiple',
                suffixText: 'x',
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                widget.onChanged(
                  _nameController.text,
                  double.tryParse(value) ?? 0,
                );
              },
            ),
          ),
          if (widget.canRemove) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.red,
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }
}
