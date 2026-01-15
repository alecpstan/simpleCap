import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/utils/helpers.dart';
import '../valuation_helpers.dart';

/// A wizard to help users determine pre-money valuation
class ValuationWizard extends StatefulWidget {
  final double? currentValuation;
  final Function(double) onValuationSelected;

  const ValuationWizard({
    super.key,
    this.currentValuation,
    required this.onValuationSelected,
  });

  /// Show the wizard as a dialog and return the selected valuation
  static Future<double?> show(
    BuildContext context, {
    double? currentValuation,
  }) async {
    return showDialog<double>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: ValuationWizard(
            currentValuation: currentValuation,
            onValuationSelected: (value) {
              Navigator.of(context).pop(value);
            },
          ),
        ),
      ),
    );
  }

  @override
  State<ValuationWizard> createState() => _ValuationWizardState();
}

class _ValuationWizardState extends State<ValuationWizard> {
  ValuationMethod _selectedMethod = ValuationMethod.benchmarkMultiple;
  int _currentStep = 0;

  // Benchmark multiple state
  IndustryType _selectedIndustry = IndustryType.saas;
  final _revenueController = TextEditingController();
  double _selectedMultiple = 10;

  // Pre-seed range state
  PreSeedRange _selectedRange = PreSeedRange.smallerMarkets;
  double _selectedPreSeedValue = 2000000;

  // Manual entry state
  final _manualController = TextEditingController();

  double get _calculatedValuation {
    switch (_selectedMethod) {
      case ValuationMethod.benchmarkMultiple:
        final revenue =
            double.tryParse(_revenueController.text.replaceAll(',', '')) ?? 0;
        return revenue * _selectedMultiple;
      case ValuationMethod.preSeedRange:
        return _selectedPreSeedValue;
      case ValuationMethod.manualEntry:
        return double.tryParse(_manualController.text.replaceAll(',', '')) ?? 0;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentValuation != null) {
      _manualController.text = widget.currentValuation!.round().toString();
    }
  }

  @override
  void dispose() {
    _revenueController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Valuation Wizard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Get guidance on pre-money valuation for your startup',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Method selection
          if (_currentStep == 0)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a valuation method:',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    RadioGroup<ValuationMethod>(
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMethod = value);
                        }
                      },
                      child: Column(
                        children: [
                          _buildMethodCard(
                            method: ValuationMethod.benchmarkMultiple,
                            icon: Icons.trending_up,
                            title: 'Revenue Multiple',
                            subtitle:
                                'For companies with revenue - value based on industry multiples',
                          ),
                          const SizedBox(height: 8),
                          _buildMethodCard(
                            method: ValuationMethod.preSeedRange,
                            icon: Icons.rocket_launch,
                            title: 'Pre-Seed Ranges',
                            subtitle:
                                'For pre-revenue companies - based on team, market & region',
                          ),
                          const SizedBox(height: 8),
                          _buildMethodCard(
                            method: ValuationMethod.manualEntry,
                            icon: Icons.edit,
                            title: 'Manual Entry',
                            subtitle: 'Enter a specific valuation directly',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Step 2: Method-specific input
          if (_currentStep == 1)
            Expanded(
              child: SingleChildScrollView(child: _buildMethodContent()),
            ),

          // Footer
          const Divider(),
          const SizedBox(height: 16),

          // Calculated valuation display
          if (_currentStep == 1 && _calculatedValuation > 0)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Valuation',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        Formatters.compactCurrency(_calculatedValuation),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_currentStep > 0)
                TextButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  child: const Text('Back'),
                ),
              const SizedBox(width: 8),
              if (_currentStep == 0)
                FilledButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  child: const Text('Next'),
                )
              else
                FilledButton(
                  onPressed: _calculatedValuation > 0
                      ? () => widget.onValuationSelected(_calculatedValuation)
                      : null,
                  child: const Text('Use This Valuation'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required ValuationMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedMethod == method;

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.7,
                              )
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<ValuationMethod>.adaptive(value: method, toggleable: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodContent() {
    switch (_selectedMethod) {
      case ValuationMethod.benchmarkMultiple:
        return _buildBenchmarkContent();
      case ValuationMethod.preSeedRange:
        return _buildPreSeedContent();
      case ValuationMethod.manualEntry:
        return _buildManualContent();
    }
  }

  Widget _buildBenchmarkContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Revenue Multiple Method', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Startups are often valued at a multiple of their revenue. The multiple depends on industry, growth rate, and market conditions.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 24),

        // Industry selection
        Text('Industry:', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<IndustryType>(
          initialValue: _selectedIndustry,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: IndustryType.values.map((industry) {
            return DropdownMenuItem(
              value: industry,
              child: Text(industry.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedIndustry = value;
                _selectedMultiple =
                    (value.defaultMultipleLow + value.defaultMultipleHigh) / 2;
              });
            }
          },
        ),
        const SizedBox(height: 8),
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
                  _selectedIndustry.multipleDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Annual revenue
        Text('Annual Revenue (AUD):', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _revenueController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'e.g., 500000',
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),

        // Multiple slider
        Text(
          'Revenue Multiple: ${_selectedMultiple.toStringAsFixed(1)}x',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('${_selectedIndustry.defaultMultipleLow.toStringAsFixed(0)}x'),
            Expanded(
              child: Slider(
                value: _selectedMultiple,
                min: _selectedIndustry.defaultMultipleLow,
                max: _selectedIndustry.defaultMultipleHigh,
                divisions:
                    ((_selectedIndustry.defaultMultipleHigh -
                                _selectedIndustry.defaultMultipleLow) *
                            2)
                        .round(),
                onChanged: (value) => setState(() => _selectedMultiple = value),
              ),
            ),
            Text(
              '${_selectedIndustry.defaultMultipleHigh.toStringAsFixed(0)}x',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreSeedContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pre-Seed Valuation Ranges', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'For pre-revenue companies, valuation is based on team experience, market size, unique approach, and geographic region.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 24),

        // Range selection
        RadioGroup<PreSeedRange>(
          groupValue: _selectedRange,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedRange = value;
                _selectedPreSeedValue =
                    (value.lowValuation + value.highValuation) / 2;
              });
            }
          },
          child: Column(
            children: PreSeedRange.values.map((range) {
              final isSelected = _selectedRange == range;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  elevation: isSelected ? 2 : 0,
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRange = range;
                        _selectedPreSeedValue =
                            (range.lowValuation + range.highValuation) / 2;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Radio<PreSeedRange>.adaptive(
                                value: range,
                                toggleable: false,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  range.displayName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  range.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                              .withValues(alpha: 0.7)
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${Formatters.compactCurrency(range.lowValuation)} - ${Formatters.compactCurrency(range.highValuation)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Fine-tune slider
        Text('Fine-tune valuation:', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(Formatters.compactCurrency(_selectedRange.lowValuation)),
            Expanded(
              child: Slider(
                value: _selectedPreSeedValue,
                min: _selectedRange.lowValuation,
                max: _selectedRange.highValuation,
                divisions: 20,
                onChanged: (value) =>
                    setState(() => _selectedPreSeedValue = value),
              ),
            ),
            Text(Formatters.compactCurrency(_selectedRange.highValuation)),
          ],
        ),
      ],
    );
  }

  Widget _buildManualContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Manual Valuation Entry', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Enter your pre-money valuation directly if you already have a specific figure in mind or from investor negotiations.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _manualController,
          decoration: const InputDecoration(
            labelText: 'Pre-Money Valuation (AUD)',
            border: OutlineInputBorder(),
            hintText: 'e.g., 5000000',
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: 24),

        // Quick select buttons
        Text('Quick select:', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _quickSelectButton('\$1M', 1000000),
            _quickSelectButton('\$2M', 2000000),
            _quickSelectButton('\$3M', 3000000),
            _quickSelectButton('\$5M', 5000000),
            _quickSelectButton('\$10M', 10000000),
            _quickSelectButton('\$15M', 15000000),
            _quickSelectButton('\$20M', 20000000),
          ],
        ),
      ],
    );
  }

  Widget _quickSelectButton(String label, double value) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _manualController.text = value.round().toString();
        setState(() {});
      },
    );
  }
}

/// A small button to trigger the valuation wizard from anywhere
class ValuationWizardButton extends StatelessWidget {
  final double? currentValuation;
  final Function(double) onValuationSelected;
  final bool iconOnly;

  const ValuationWizardButton({
    super.key,
    this.currentValuation,
    required this.onValuationSelected,
    this.iconOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return IconButton(
        icon: const Icon(Icons.auto_awesome),
        tooltip: 'Valuation Wizard',
        onPressed: () async {
          final valuation = await ValuationWizard.show(
            context,
            currentValuation: currentValuation,
          );
          if (valuation != null) {
            onValuationSelected(valuation);
          }
        },
      );
    }

    return TextButton.icon(
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Wizard'),
      onPressed: () async {
        final valuation = await ValuationWizard.show(
          context,
          currentValuation: currentValuation,
        );
        if (valuation != null) {
          onValuationSelected(valuation);
        }
      },
    );
  }
}
