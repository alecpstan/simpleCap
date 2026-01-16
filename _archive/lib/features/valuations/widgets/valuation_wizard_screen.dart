import 'package:flutter/material.dart';
import '../models/valuation.dart';
import '../../../shared/utils/helpers.dart';
import 'methods/revenue_multiple_method.dart';
import 'methods/comparables_method.dart';
import 'methods/dcf_method.dart';
import 'methods/scorecard_method.dart';
import 'methods/berkus_method.dart';

/// Full-screen wizard for creating valuations using different methods.
/// Returns a [Valuation] object with the calculated value and method params.
class ValuationWizardScreen extends StatefulWidget {
  /// Optional existing valuation for editing
  final Valuation? existingValuation;

  const ValuationWizardScreen({
    super.key,
    this.existingValuation,
  });

  /// Show the wizard and return the created/edited valuation
  static Future<Valuation?> show(
    BuildContext context, {
    Valuation? existingValuation,
  }) {
    return Navigator.push<Valuation>(
      context,
      MaterialPageRoute(
        builder: (context) => ValuationWizardScreen(
          existingValuation: existingValuation,
        ),
      ),
    );
  }

  @override
  State<ValuationWizardScreen> createState() => _ValuationWizardScreenState();
}

class _ValuationWizardScreenState extends State<ValuationWizardScreen> {
  int _currentStep = 0;
  ValuationMethod? _selectedMethod;
  double _calculatedValue = 0;
  Map<String, dynamic> _methodParams = {};
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.existingValuation != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _selectedMethod = widget.existingValuation!.method;
      _calculatedValue = widget.existingValuation!.preMoneyValue;
      _methodParams = Map.from(widget.existingValuation!.methodParams ?? {});
      _selectedDate = widget.existingValuation!.date;
      _currentStep = 1; // Go directly to method step when editing
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Valuation' : 'Valuation Wizard'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 2,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),

          // Content
          Expanded(
            child: _currentStep == 0
                ? _buildMethodSelection()
                : _buildMethodInput(),
          ),

          // Bottom bar with result preview and actions
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildMethodSelection() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a valuation method',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the method that best fits your company\'s stage and available data.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Method cards (excluding manual - that's for direct entry)
          ...ValuationMethod.values
              .where((m) => m != ValuationMethod.manual)
              .map((method) => _MethodCard(
                    method: method,
                    isSelected: _selectedMethod == method,
                    onTap: () => setState(() => _selectedMethod = method),
                  )),
        ],
      ),
    );
  }

  Widget _buildMethodInput() {
    switch (_selectedMethod) {
      case ValuationMethod.revenueMultiple:
        return RevenueMultipleMethod(
          initialParams: _methodParams,
          onValuationChanged: (value, params) {
            setState(() {
              _calculatedValue = value;
              _methodParams = params;
            });
          },
        );
      case ValuationMethod.comparables:
        return ComparablesMethod(
          initialParams: _methodParams,
          onValuationChanged: (value, params) {
            setState(() {
              _calculatedValue = value;
              _methodParams = params;
            });
          },
        );
      case ValuationMethod.dcf:
        return DcfMethod(
          initialParams: _methodParams,
          onValuationChanged: (value, params) {
            setState(() {
              _calculatedValue = value;
              _methodParams = params;
            });
          },
        );
      case ValuationMethod.scorecard:
        return ScorecardMethod(
          initialParams: _methodParams,
          onValuationChanged: (value, params) {
            setState(() {
              _calculatedValue = value;
              _methodParams = params;
            });
          },
        );
      case ValuationMethod.berkus:
        return BerkusMethod(
          initialParams: _methodParams,
          onValuationChanged: (value, params) {
            setState(() {
              _calculatedValue = value;
              _methodParams = params;
            });
          },
        );
      default:
        return const Center(child: Text('Select a method'));
    }
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    final showPreview = _currentStep == 1 && _calculatedValue > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Value preview
            if (showPreview) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimated Valuation',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(_calculatedValue),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                if (_currentStep > 0 && !isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep = 0),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0 && !isEditing) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _canProceed ? _handleNext : null,
                    child: Text(_getButtonText()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _canProceed {
    if (_currentStep == 0) {
      return _selectedMethod != null;
    } else {
      return _calculatedValue > 0;
    }
  }

  String _getButtonText() {
    if (_currentStep == 0) {
      return 'Next';
    } else {
      return isEditing ? 'Save Changes' : 'Save Valuation';
    }
  }

  void _handleNext() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else {
      _saveValuation();
    }
  }

  void _saveValuation() {
    final valuation = Valuation(
      id: widget.existingValuation?.id,
      date: _selectedDate,
      preMoneyValue: _calculatedValue,
      method: _selectedMethod!,
      methodParams: _methodParams,
    );
    Navigator.pop(context, valuation);
  }
}

class _MethodCard extends StatelessWidget {
  final ValuationMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected ? true : null,
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getMethodIcon(method),
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMethodIcon(ValuationMethod method) {
    switch (method) {
      case ValuationMethod.revenueMultiple:
        return Icons.trending_up;
      case ValuationMethod.comparables:
        return Icons.compare_arrows;
      case ValuationMethod.dcf:
        return Icons.show_chart;
      case ValuationMethod.scorecard:
        return Icons.score;
      case ValuationMethod.berkus:
        return Icons.checklist;
      default:
        return Icons.calculate;
    }
  }
}

/// A button that opens the valuation wizard and returns the calculated value.
/// Useful for form fields where you want to populate a valuation.
class ValuationWizardButton extends StatelessWidget {
  /// Current valuation value (for display purposes)
  final double? currentValuation;

  /// Callback when a valuation is selected from the wizard
  final Function(double) onValuationSelected;

  /// If true, shows only an icon button; if false, shows a text button with label
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
        onPressed: () => _openWizard(context),
      );
    }

    return TextButton.icon(
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Wizard'),
      onPressed: () => _openWizard(context),
    );
  }

  Future<void> _openWizard(BuildContext context) async {
    final valuation = await ValuationWizardScreen.show(context);
    if (valuation != null) {
      onValuationSelected(valuation.preMoneyValue);
    }
  }
}
