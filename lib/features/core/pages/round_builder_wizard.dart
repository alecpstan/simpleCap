import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/investment_round.dart';
import '../models/transaction.dart';
import '../models/vesting_schedule.dart';
import '../providers/core_cap_table_provider.dart';
import '../../convertibles/models/convertible_instrument.dart';
import '../../convertibles/providers/convertibles_provider.dart';
import '../../esop/models/option_grant.dart';
import '../../esop/models/warrant.dart';
import '../../esop/providers/esop_provider.dart';
import '../../valuations/providers/valuations_provider.dart';
import '../../valuations/widgets/valuation_wizard_screen.dart';
import '../../../shared/utils/helpers.dart';
import '../../../shared/widgets/avatars.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/help_icon.dart';

/// Full-screen wizard for creating investment rounds.
/// Guides users through: Details → Valuation → Investments → Convertibles → Summary
class RoundBuilderWizard extends StatefulWidget {
  /// Optional existing round for editing
  final InvestmentRound? existingRound;

  const RoundBuilderWizard({super.key, this.existingRound});

  /// Show the wizard and return true if a round was created/edited
  static Future<bool?> show(
    BuildContext context, {
    InvestmentRound? existingRound,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RoundBuilderWizard(existingRound: existingRound),
      ),
    );
  }

  @override
  State<RoundBuilderWizard> createState() => _RoundBuilderWizardState();
}

class _RoundBuilderWizardState extends State<RoundBuilderWizard> {
  int _currentStep = 0;
  static const int _totalSteps = 6;

  // Step 1: Round Details
  RoundType _roundType = RoundType.seed;
  final _nameController = TextEditingController();
  DateTime _roundDate = DateTime.now();
  final _leadInvestorController = TextEditingController();

  // Step 2: Valuation
  final _preMoneyController = TextEditingController();
  final _pricePerShareController = TextEditingController();

  // Step 3: Investments
  final List<_PendingInvestment> _pendingInvestments = [];
  String? _selectedInvestorId;
  String? _selectedShareClassId;
  final _investmentAmountController = TextEditingController();
  final _investmentSharesController = TextEditingController();
  final _investmentPriceController = TextEditingController();
  bool _editingFromAmount =
      false; // Track which field triggered the calculation
  bool _editingFromShares = false;
  bool _editingFromPrice = false;
  // Investment vesting fields
  bool _investmentHasVesting = false;
  int _investmentVestingPeriodMonths = 48;
  int _investmentCliffMonths = 12;
  VestingFrequency _investmentVestingFrequency = VestingFrequency.monthly;

  // Step 4: Convertibles
  final Set<String> _selectedConvertibleIds = {};

  // Step 5: New Instruments
  final List<_PendingConvertible> _pendingNewConvertibles = [];
  final List<_PendingWarrant> _pendingNewWarrants = [];
  final List<_PendingOption> _pendingNewOptions = [];
  int _newInstrumentsTabIndex = 0;

  // Step 6: Summary
  final _notesController = TextEditingController();
  bool _markAsClosed = false;

  bool get isEditing => widget.existingRound != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingRound();
    } else {
      _initializeDefaults();
    }
  }

  void _loadExistingRound() {
    final round = widget.existingRound!;
    _roundType = round.type;
    _nameController.text = round.name;
    _roundDate = round.date;
    _leadInvestorController.text = round.leadInvestor ?? '';
    _preMoneyController.text = round.preMoneyValuation.toStringAsFixed(0);
    if (round.pricePerShare != null) {
      _pricePerShareController.text = round.pricePerShare!.toString();
    }
    _notesController.text = round.notes ?? '';
    _markAsClosed = round.isClosed;

    // Load existing investments for this round
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<CoreCapTableProvider>();
      final existingInvestments = provider.getInvestmentsByRound(round.id);

      if (existingInvestments.isNotEmpty) {
        setState(() {
          for (final transaction in existingInvestments) {
            _pendingInvestments.add(
              _PendingInvestment(
                investorId: transaction.investorId,
                shareClassId: transaction.shareClassId,
                amount: transaction.totalAmount,
                shares: transaction.numberOfShares,
                existingTransactionId: transaction.id,
              ),
            );
          }
          // Set price from first investment if available
          if (_investmentPriceController.text.isEmpty &&
              existingInvestments.first.pricePerShare > 0) {
            _investmentPriceController.text = existingInvestments
                .first
                .pricePerShare
                .toStringAsFixed(4);
          }
        });
      }
    });
  }

  void _initializeDefaults() {
    // Auto-populate name from type
    _nameController.text = _getRoundTypeName(_roundType);

    // Try to get latest valuation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final valuationsProvider = context.read<ValuationsProvider>();
      final latestValuation = valuationsProvider.getLatestValuationBeforeDate(
        _roundDate,
      );
      if (latestValuation != null) {
        setState(() {
          _preMoneyController.text = latestValuation.preMoneyValue
              .round()
              .toString();
        });
        showInfoSnackbar(context, 'Pre-money pre-filled from latest valuation');
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _leadInvestorController.dispose();
    _preMoneyController.dispose();
    _pricePerShareController.dispose();
    _investmentAmountController.dispose();
    _investmentSharesController.dispose();
    _investmentPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Round' : 'Round Builder'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _confirmExit,
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),

          // Step indicator
          _buildStepIndicator(),

          // Content
          Expanded(child: _buildStepContent()),

          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final theme = Theme.of(context);
    final steps = [
      'Details',
      'Valuation',
      'Investments',
      'Convertibles',
      'New Instruments',
      'Summary',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isActive
                    ? theme.colorScheme.primary
                    : isCompleted
                    ? Colors.green
                    : theme.colorScheme.surfaceContainerHighest,
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.outline,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[index],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDetailsStep();
      case 1:
        return _buildValuationStep();
      case 2:
        return _buildInvestmentsStep();
      case 3:
        return _buildConvertiblesStep();
      case 4:
        return _buildNewInstrumentsStep();
      case 5:
        return _buildSummaryStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 1: Round Details ─────────────────────────────────────────────────

  Widget _buildDetailsStep() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Round Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by selecting the type of round and basic information.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Round Type
          DropdownButtonFormField<RoundType>(
            value: _roundType,
            decoration: InputDecoration(
              labelText: 'Round Type',
              prefixIcon: const Icon(Icons.layers),
              suffixIcon: const HelpIcon(helpKey: 'rounds.roundType'),
              border: const OutlineInputBorder(),
            ),
            items: RoundType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getRoundTypeName(type)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _roundType = value!;
                // Auto-update name if it's a default name
                if (_nameController.text.isEmpty ||
                    RoundType.values.any(
                      (t) => _nameController.text == _getRoundTypeName(t),
                    )) {
                  _nameController.text = _getRoundTypeName(value);
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // Round Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Round Name',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Date
          AppDateField(
            value: _roundDate,
            labelText: 'Round Date',
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onChanged: (date) => setState(() => _roundDate = date),
          ),
          const SizedBox(height: 16),

          // Lead Investor (optional)
          TextFormField(
            controller: _leadInvestorController,
            decoration: InputDecoration(
              labelText: 'Lead Investor (optional)',
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
              helperText: 'e.g., Sequoia Capital, Blackbird Ventures',
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Valuation ─────────────────────────────────────────────────────

  Widget _buildValuationStep() {
    final theme = Theme.of(context);
    final provider = context.watch<CoreCapTableProvider>();

    // Calculate implied price
    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final sharesBefore = provider.getIssuedSharesBeforeDate(_roundDate);
    final impliedPrice = sharesBefore > 0 ? preMoneyVal / sharesBefore : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valuation',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set the pre-money valuation for this round.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Pre-Money Valuation
          TextFormField(
            controller: _preMoneyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Pre-Money Valuation',
              prefixText: '\$ ',
              border: const OutlineInputBorder(),
              helperText: _getPreviousPostMoneyText(provider),
              helperMaxLines: 2,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HelpIcon(helpKey: 'rounds.preMoneyValuation'),
                  ValuationWizardButton(
                    onValuationSelected: (value) {
                      setState(() {
                        _preMoneyController.text = value.round().toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Implied Price Info
          if (sharesBefore > 0) ...[
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
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Implied Price per Share',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Text(
                          Formatters.currency(impliedPrice),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Based on ${Formatters.number(sharesBefore)} shares before round',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Optional: Override Price Per Share
          ExpansionTile(
            title: const Text('Advanced: Override Price'),
            tilePadding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _pricePerShareController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price Per Share (optional)',
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                  helperText:
                      'Leave empty to use implied price: ${Formatters.currency(impliedPrice)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Step 3: Investments ───────────────────────────────────────────────────

  Widget _buildInvestmentsStep() {
    final theme = Theme.of(context);
    final provider = context.watch<CoreCapTableProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investments',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add investors participating in this round. You can skip this step and add investors later.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Pending investments list
          if (_pendingInvestments.isNotEmpty) ...[
            Text(
              'Pending Investments',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_pendingInvestments.length, (index) {
              final inv = _pendingInvestments[index];
              final investor = provider.getInvestorById(inv.investorId);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: InvestorAvatar(
                    name: investor?.name ?? '?',
                    type: investor?.type,
                    radius: 18,
                  ),
                  title: Text(investor?.name ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Formatters.number(inv.shares)} shares • ${Formatters.currency(inv.amount)}',
                      ),
                      if (inv.hasVesting)
                        Text(
                          '${inv.vestingPeriodMonths! ~/ 12}yr vesting, ${inv.cliffMonths! > 0 ? '${inv.cliffMonths!}mo cliff' : 'no cliff'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => _pendingInvestments.removeAt(index));
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Add investment form
          Text(
            'Add Investment',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Investor dropdown
          DropdownButtonFormField<String>(
            value: _selectedInvestorId,
            decoration: const InputDecoration(
              labelText: 'Investor',
              border: OutlineInputBorder(),
            ),
            items: provider.investors.map((inv) {
              return DropdownMenuItem(value: inv.id, child: Text(inv.name));
            }).toList(),
            onChanged: (value) => setState(() => _selectedInvestorId = value),
          ),
          const SizedBox(height: 12),

          // Share class dropdown
          DropdownButtonFormField<String>(
            value: _selectedShareClassId,
            decoration: const InputDecoration(
              labelText: 'Share Class',
              border: OutlineInputBorder(),
            ),
            items: provider.shareClasses.map((sc) {
              return DropdownMenuItem(value: sc.id, child: Text(sc.name));
            }).toList(),
            onChanged: (value) => setState(() => _selectedShareClassId = value),
          ),
          const SizedBox(height: 12),

          // Price per share (auto-calculated or manual)
          TextFormField(
            controller: _investmentPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price Per Share',
              prefixText: '\$ ',
              border: const OutlineInputBorder(),
              helperText: _getImpliedPriceText(provider),
            ),
            onChanged: (_) => _calculateFromPrice(),
          ),
          const SizedBox(height: 12),

          // Amount and shares
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _investmentAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Investment',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _calculateFromAmount(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _investmentSharesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Shares',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _calculateFromShares(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter amount or shares - the other will auto-calculate',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          // Vesting toggle and settings
          _buildInvestmentVestingSection(),
          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _canAddInvestment() ? _addInvestment : null,
              icon: const Icon(Icons.add),
              label: const Text('Add to Round'),
            ),
          ),

          const SizedBox(height: 24),

          // Total summary
          if (_pendingInvestments.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    Formatters.currency(
                      _pendingInvestments.fold(
                        0.0,
                        (sum, inv) => sum + inv.amount,
                      ),
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Get helper text showing the most recent post-money valuation
  String? _getPreviousPostMoneyText(CoreCapTableProvider provider) {
    // Get the most recent closed round before this round's date
    final closedRounds = provider.rounds
        .where((r) => r.isClosed && r.date.isBefore(_roundDate))
        .toList();
    closedRounds.sort((a, b) => b.date.compareTo(a.date)); // Most recent first

    if (closedRounds.isEmpty) {
      // Check if there are any closed rounds at all
      final allClosedRounds = provider.rounds.where((r) => r.isClosed).toList();
      allClosedRounds.sort((a, b) => b.date.compareTo(a.date));

      if (allClosedRounds.isNotEmpty) {
        final mostRecent = allClosedRounds.first;
        // Use getAmountRaisedByRound to get actual amount from transactions
        final amountRaised = provider.getAmountRaisedByRound(mostRecent.id);
        final postMoney = mostRecent.preMoneyValuation + amountRaised;
        return 'Latest: ${Formatters.compactCurrency(postMoney)} post-money from ${mostRecent.name} (${Formatters.date(mostRecent.date)})';
      }
      return null;
    }

    final mostRecent = closedRounds.first;
    // Use getAmountRaisedByRound to get actual amount from transactions
    final amountRaised = provider.getAmountRaisedByRound(mostRecent.id);
    final postMoney = mostRecent.preMoneyValuation + amountRaised;
    return 'Previous: ${Formatters.compactCurrency(postMoney)} post-money from ${mostRecent.name} (${Formatters.date(mostRecent.date)})';
  }

  /// Get the implied price per share from pre-money valuation
  double? _getImpliedPrice() {
    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final provider = context.read<CoreCapTableProvider>();
    final sharesBefore = provider.getIssuedSharesBeforeDate(_roundDate);

    if (preMoneyVal > 0 && sharesBefore > 0) {
      return preMoneyVal / sharesBefore;
    }
    return null;
  }

  /// Get helper text for implied price
  String? _getImpliedPriceText(CoreCapTableProvider provider) {
    final impliedPrice = _getImpliedPrice();
    if (impliedPrice != null) {
      return 'Implied from valuation: ${Formatters.currency(impliedPrice)}';
    }
    final sharesBefore = provider.getIssuedSharesBeforeDate(_roundDate);
    if (sharesBefore == 0) {
      return 'No existing shares - enter price manually';
    }
    return null;
  }

  /// Initialize price from implied price when entering investments step
  void _initializeInvestmentPrice() {
    if (_investmentPriceController.text.isEmpty) {
      final impliedPrice = _getImpliedPrice();
      if (impliedPrice != null) {
        _investmentPriceController.text = impliedPrice.toStringAsFixed(4);
      }
    }
  }

  /// Calculate shares from amount and price
  void _calculateFromAmount() {
    if (_editingFromShares || _editingFromPrice) return;
    _editingFromAmount = true;

    final amount = double.tryParse(_investmentAmountController.text) ?? 0;
    final price = double.tryParse(_investmentPriceController.text) ?? 0;

    if (amount > 0 && price > 0) {
      final shares = (amount / price).round();
      _investmentSharesController.text = shares.toString();
    }

    _editingFromAmount = false;
    setState(() {});
  }

  /// Calculate amount from shares and price
  void _calculateFromShares() {
    if (_editingFromAmount || _editingFromPrice) return;
    _editingFromShares = true;

    final shares = int.tryParse(_investmentSharesController.text) ?? 0;
    final price = double.tryParse(_investmentPriceController.text) ?? 0;

    if (shares > 0 && price > 0) {
      final amount = shares * price;
      _investmentAmountController.text = amount.toStringAsFixed(2);
    }

    _editingFromShares = false;
    setState(() {});
  }

  /// Calculate shares from amount when price changes
  void _calculateFromPrice() {
    if (_editingFromAmount || _editingFromShares) return;
    _editingFromPrice = true;

    final amount = double.tryParse(_investmentAmountController.text) ?? 0;
    final price = double.tryParse(_investmentPriceController.text) ?? 0;

    if (amount > 0 && price > 0) {
      final shares = (amount / price).round();
      _investmentSharesController.text = shares.toString();
    }

    _editingFromPrice = false;
    setState(() {});
  }

  bool _canAddInvestment() {
    // Must have investor and share class selected
    if (_selectedInvestorId == null || _selectedShareClassId == null) {
      return false;
    }

    // Must have shares (calculated or manual)
    final shares = int.tryParse(_investmentSharesController.text) ?? 0;
    if (shares <= 0) return false;

    // Must have either amount or price to calculate the investment value
    final amount = double.tryParse(_investmentAmountController.text) ?? 0;
    final price = double.tryParse(_investmentPriceController.text) ?? 0;

    return amount > 0 || price > 0;
  }

  void _addInvestment() {
    var amount = double.tryParse(_investmentAmountController.text) ?? 0;
    final shares = int.tryParse(_investmentSharesController.text) ?? 0;
    final price = double.tryParse(_investmentPriceController.text) ?? 0;

    // If amount is 0 but we have shares and price, calculate amount
    if (amount == 0 && shares > 0 && price > 0) {
      amount = shares * price;
    }

    if (amount > 0 && shares > 0) {
      setState(() {
        _pendingInvestments.add(
          _PendingInvestment(
            investorId: _selectedInvestorId!,
            shareClassId: _selectedShareClassId!,
            amount: amount,
            shares: shares,
            hasVesting: _investmentHasVesting,
            vestingPeriodMonths: _investmentHasVesting
                ? _investmentVestingPeriodMonths
                : null,
            cliffMonths: _investmentHasVesting ? _investmentCliffMonths : null,
            vestingFrequency: _investmentHasVesting
                ? _investmentVestingFrequency
                : null,
          ),
        );
        // Clear form but keep price (same price for all investments in round)
        _selectedInvestorId = null;
        _investmentAmountController.clear();
        _investmentSharesController.clear();
        // Reset vesting to defaults
        _investmentHasVesting = false;
        _investmentVestingPeriodMonths = 48;
        _investmentCliffMonths = 12;
        _investmentVestingFrequency = VestingFrequency.monthly;
        // Don't clear price - it's the same for all investments in this round
      });
    }
  }

  Widget _buildInvestmentVestingSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  value: _investmentHasVesting,
                  onChanged: (v) => setState(() => _investmentHasVesting = v),
                  title: Text(
                    'Add Vesting Schedule',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text('For founder or employee shares'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          if (_investmentHasVesting) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _investmentVestingPeriodMonths,
                    decoration: const InputDecoration(
                      labelText: 'Vesting Period',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 24, child: Text('2 years')),
                      DropdownMenuItem(value: 36, child: Text('3 years')),
                      DropdownMenuItem(value: 48, child: Text('4 years')),
                      DropdownMenuItem(value: 60, child: Text('5 years')),
                    ],
                    onChanged: (v) => setState(
                      () => _investmentVestingPeriodMonths = v ?? 48,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _investmentCliffMonths,
                    decoration: const InputDecoration(
                      labelText: 'Cliff',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('No cliff')),
                      DropdownMenuItem(value: 6, child: Text('6 months')),
                      DropdownMenuItem(value: 12, child: Text('1 year')),
                      DropdownMenuItem(value: 18, child: Text('18 months')),
                    ],
                    onChanged: (v) =>
                        setState(() => _investmentCliffMonths = v ?? 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VestingFrequency>(
              value: _investmentVestingFrequency,
              decoration: const InputDecoration(
                labelText: 'Vesting Frequency',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: VestingFrequency.monthly,
                  child: Text('Monthly'),
                ),
                DropdownMenuItem(
                  value: VestingFrequency.quarterly,
                  child: Text('Quarterly'),
                ),
                DropdownMenuItem(
                  value: VestingFrequency.annually,
                  child: Text('Annually'),
                ),
              ],
              onChanged: (v) => setState(
                () =>
                    _investmentVestingFrequency = v ?? VestingFrequency.monthly,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Step 4: Convertibles ──────────────────────────────────────────────────

  Widget _buildConvertiblesStep() {
    final theme = Theme.of(context);
    final provider = context.watch<CoreCapTableProvider>();
    final convertiblesProvider = context.watch<ConvertiblesProvider>();

    final outstanding = convertiblesProvider.outstandingConvertibles;

    if (outstanding.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Convertibles',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Outstanding Convertibles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no SAFEs or Convertible Notes to convert in this round.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Convertibles',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select convertible instruments to convert in this round.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // MFN Upgrades Section
          Builder(
            builder: (context) {
              final mfnUpgrades = convertiblesProvider.detectMfnUpgrades();
              if (mfnUpgrades.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.upgrade,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MFN Upgrades Available',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                            const Spacer(),
                            if (mfnUpgrades.length > 1)
                              TextButton.icon(
                                onPressed: () async {
                                  final count = await convertiblesProvider
                                      .applyAllMfnUpgrades();
                                  if (mounted && count > 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Applied $count MFN upgrade${count > 1 ? 's' : ''}',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.done_all, size: 16),
                                label: const Text('Upgrade All'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'These convertibles have MFN clauses and can be upgraded to better terms:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...mfnUpgrades.map((upgrade) {
                          final investor = provider.getInvestorById(
                            upgrade.target.investorId,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        investor?.name ?? 'Unknown',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        upgrade.upgradeDescription,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: () async {
                                    await convertiblesProvider.applyMfnUpgrade(
                                      upgrade,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Upgraded ${investor?.name ?? "convertible"} terms',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.upgrade, size: 16),
                                  label: const Text('Upgrade'),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

          // Select all / none buttons
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedConvertibleIds.addAll(
                      outstanding.map((c) => c.id),
                    );
                  });
                },
                child: const Text('Select All'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _selectedConvertibleIds.clear());
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Convertibles list
          ...outstanding.map((conv) {
            final investor = provider.getInvestorById(conv.investorId);
            final isSelected = _selectedConvertibleIds.contains(conv.id);

            // Calculate estimated shares
            final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
            final sharesBefore = provider.getIssuedSharesBeforeDate(_roundDate);
            final estimatedShares = conv.calculateConversionShares(
              roundPreMoney: preMoneyVal,
              issuedSharesBeforeRound: sharesBefore,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isSelected
                    ? BorderSide(color: theme.colorScheme.primary, width: 2)
                    : BorderSide.none,
              ),
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedConvertibleIds.add(conv.id);
                    } else {
                      _selectedConvertibleIds.remove(conv.id);
                    }
                  });
                },
                title: Row(
                  children: [
                    Expanded(child: Text(investor?.name ?? 'Unknown')),
                    if (conv.hasMFN)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text(
                          'MFN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    if (conv.hasProRata) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text(
                          'Pro-rata',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${conv.typeDisplayName} • ${Formatters.currency(conv.principalAmount)}',
                    ),
                    // Show terms
                    Text(
                      [
                        if (conv.valuationCap != null)
                          'Cap: ${Formatters.compactCurrency(conv.valuationCap!)}',
                        if (conv.discountPercent != null)
                          '${(conv.discountPercent! * 100).toStringAsFixed(0)}% discount',
                      ].join(' • '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (preMoneyVal > 0 && sharesBefore > 0)
                      Text(
                        '→ Est. ${Formatters.number(estimatedShares)} shares',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                secondary: CircleAvatar(
                  backgroundColor: conv.type == ConvertibleType.safe
                      ? Colors.purple
                      : Colors.teal,
                  child: Icon(
                    conv.type == ConvertibleType.safe
                        ? Icons.flash_on
                        : Icons.description,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            );
          }),

          // Summary
          if (_selectedConvertibleIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedConvertibleIds.length} selected',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Will convert at round close',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
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

  // ─── Step 5: New Instruments ───────────────────────────────────────────────

  Widget _buildNewInstrumentsStep() {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      initialIndex: _newInstrumentsTabIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Instruments',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Issue new convertibles, warrants, or options as part of this round.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            onTap: (index) => setState(() => _newInstrumentsTabIndex = index),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.description_outlined, size: 18),
                    const SizedBox(width: 8),
                    const Text('Convertibles'),
                    if (_pendingNewConvertibles.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          '${_pendingNewConvertibles.length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 18),
                    const SizedBox(width: 8),
                    const Text('Warrants'),
                    if (_pendingNewWarrants.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          '${_pendingNewWarrants.length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined, size: 18),
                    const SizedBox(width: 8),
                    const Text('Options'),
                    if (_pendingNewOptions.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          '${_pendingNewOptions.length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildNewConvertiblesTab(),
                _buildNewWarrantsTab(),
                _buildNewOptionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewConvertiblesTab() {
    final theme = Theme.of(context);
    final provider = context.watch<CoreCapTableProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending convertibles list
          if (_pendingNewConvertibles.isNotEmpty) ...[
            Text(
              'New Convertibles to Issue',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_pendingNewConvertibles.length, (index) {
              final conv = _pendingNewConvertibles[index];
              final investor = provider.getInvestorById(conv.investorId);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: conv.type == ConvertibleType.safe
                        ? Colors.purple
                        : Colors.teal,
                    child: Icon(
                      conv.type == ConvertibleType.safe
                          ? Icons.flash_on
                          : Icons.description,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(investor?.name ?? 'Unknown'),
                  subtitle: Text(
                    '${conv.type == ConvertibleType.safe ? 'SAFE' : 'Note'} • ${Formatters.currency(conv.principalAmount)}'
                    '${conv.valuationCap != null ? ' • Cap: ${Formatters.compactCurrency(conv.valuationCap!)}' : ''}'
                    '${conv.discountPercent != null ? ' • ${(conv.discountPercent! * 100).toStringAsFixed(0)}% disc' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => _pendingNewConvertibles.removeAt(index));
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Add new convertible button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddConvertibleDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Convertible (SAFE/Note)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewWarrantsTab() {
    final theme = Theme.of(context);
    final provider = context.watch<CoreCapTableProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending warrants list
          if (_pendingNewWarrants.isNotEmpty) ...[
            Text(
              'New Warrants to Issue',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_pendingNewWarrants.length, (index) {
              final warrant = _pendingNewWarrants[index];
              final investor = provider.getInvestorById(warrant.investorId);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(investor?.name ?? 'Unknown'),
                  subtitle: Text(
                    '${Formatters.number(warrant.numberOfWarrants)} warrants @ ${Formatters.currency(warrant.strikePrice)}'
                    ' • Expires: ${Formatters.date(warrant.expiryDate)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => _pendingNewWarrants.removeAt(index));
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Add new warrant button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddWarrantDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Warrant'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewOptionsTab() {
    final theme = Theme.of(context);
    final provider = context.watch<CoreCapTableProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending options list
          if (_pendingNewOptions.isNotEmpty) ...[
            Text(
              'New Options to Grant',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_pendingNewOptions.length, (index) {
              final option = _pendingNewOptions[index];
              final investor = provider.getInvestorById(option.investorId);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(investor?.name ?? 'Unknown'),
                  subtitle: Text(
                    '${Formatters.number(option.numberOfOptions)} options @ ${Formatters.currency(option.strikePrice)}'
                    '${option.vestingPeriodMonths != null ? ' • ${option.vestingPeriodMonths! ~/ 12}yr vesting' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => _pendingNewOptions.removeAt(index));
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Add new option button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddOptionDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Option Grant'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddConvertibleDialog() async {
    final provider = context.read<CoreCapTableProvider>();
    String? selectedInvestorId;
    ConvertibleType selectedType = ConvertibleType.safe;
    final principalController = TextEditingController();
    final capController = TextEditingController();
    final discountController = TextEditingController();
    final interestController = TextEditingController();
    DateTime? maturityDate;
    bool hasMFN = false;
    bool hasProRata = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Convertible'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedInvestorId,
                  decoration: const InputDecoration(
                    labelText: 'Investor',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.investors.map((inv) {
                    return DropdownMenuItem(
                      value: inv.id,
                      child: Text(inv.name),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedInvestorId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ConvertibleType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ConvertibleType.safe,
                      child: Text('SAFE'),
                    ),
                    DropdownMenuItem(
                      value: ConvertibleType.convertibleNote,
                      child: Text('Convertible Note'),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedType = value!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: principalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Principal Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: capController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valuation Cap (optional)',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount % (optional)',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 20 for 20%',
                  ),
                ),
                if (selectedType == ConvertibleType.convertibleNote) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: interestController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate (annual)',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 8 for 8%',
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppDateField(
                    value:
                        maturityDate ??
                        _roundDate.add(const Duration(days: 730)),
                    labelText: 'Maturity Date',
                    firstDate: _roundDate,
                    lastDate: DateTime(2100),
                    onChanged: (date) =>
                        setDialogState(() => maturityDate = date),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        value: hasMFN,
                        onChanged: (v) =>
                            setDialogState(() => hasMFN = v ?? false),
                        title: const Text('MFN'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        value: hasProRata,
                        onChanged: (v) =>
                            setDialogState(() => hasProRata = v ?? false),
                        title: const Text('Pro-rata'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
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
              onPressed: () {
                final principal =
                    double.tryParse(principalController.text) ?? 0;
                if (selectedInvestorId != null && principal > 0) {
                  setState(() {
                    _pendingNewConvertibles.add(
                      _PendingConvertible(
                        investorId: selectedInvestorId!,
                        type: selectedType,
                        principalAmount: principal,
                        valuationCap: double.tryParse(capController.text),
                        discountPercent: discountController.text.isNotEmpty
                            ? (double.tryParse(discountController.text) ?? 0) /
                                  100
                            : null,
                        interestRate: interestController.text.isNotEmpty
                            ? (double.tryParse(interestController.text) ?? 0) /
                                  100
                            : null,
                        maturityDate: maturityDate,
                        hasMFN: hasMFN,
                        hasProRata: hasProRata,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddWarrantDialog() async {
    final provider = context.read<CoreCapTableProvider>();
    String? selectedInvestorId;
    String? selectedShareClassId;
    final warrantsController = TextEditingController();
    final strikePriceController = TextEditingController();
    DateTime expiryDate = _roundDate.add(const Duration(days: 365 * 5));

    // Pre-fill strike price from implied price
    final impliedPrice = _getImpliedPrice();
    if (impliedPrice != null) {
      strikePriceController.text = impliedPrice.toStringAsFixed(4);
    }

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Warrant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedInvestorId,
                  decoration: const InputDecoration(
                    labelText: 'Investor',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.investors.map((inv) {
                    return DropdownMenuItem(
                      value: inv.id,
                      child: Text(inv.name),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedInvestorId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedShareClassId,
                  decoration: const InputDecoration(
                    labelText: 'Share Class',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.shareClasses.map((sc) {
                    return DropdownMenuItem(value: sc.id, child: Text(sc.name));
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedShareClassId = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: warrantsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Warrants',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: strikePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Strike Price',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                AppDateField(
                  value: expiryDate,
                  labelText: 'Expiry Date',
                  firstDate: _roundDate,
                  lastDate: DateTime(2100),
                  onChanged: (date) => setDialogState(() => expiryDate = date),
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
              onPressed: () {
                final numWarrants = int.tryParse(warrantsController.text) ?? 0;
                final strikePrice =
                    double.tryParse(strikePriceController.text) ?? 0;
                if (selectedInvestorId != null &&
                    numWarrants > 0 &&
                    strikePrice > 0) {
                  setState(() {
                    _pendingNewWarrants.add(
                      _PendingWarrant(
                        investorId: selectedInvestorId!,
                        shareClassId: selectedShareClassId,
                        numberOfWarrants: numWarrants,
                        strikePrice: strikePrice,
                        expiryDate: expiryDate,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddOptionDialog() async {
    final provider = context.read<CoreCapTableProvider>();
    String? selectedInvestorId;
    String? selectedShareClassId;
    final optionsController = TextEditingController();
    final strikePriceController = TextEditingController();
    DateTime expiryDate = _roundDate.add(const Duration(days: 365 * 10));

    // Vesting settings
    bool hasVesting = true;
    int vestingPeriodMonths = 48;
    int cliffMonths = 12;
    VestingFrequency vestingFrequency = VestingFrequency.monthly;

    // Pre-fill strike price from implied price
    final impliedPrice = _getImpliedPrice();
    if (impliedPrice != null) {
      strikePriceController.text = impliedPrice.toStringAsFixed(4);
    }

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Option Grant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedInvestorId,
                  decoration: const InputDecoration(
                    labelText: 'Employee/Recipient',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.investors.map((inv) {
                    return DropdownMenuItem(
                      value: inv.id,
                      child: Text(inv.name),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedInvestorId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedShareClassId,
                  decoration: const InputDecoration(
                    labelText: 'Share Class',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.shareClasses.map((sc) {
                    return DropdownMenuItem(value: sc.id, child: Text(sc.name));
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedShareClassId = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Options',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: strikePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Strike Price',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                AppDateField(
                  value: expiryDate,
                  labelText: 'Expiry Date',
                  firstDate: _roundDate,
                  lastDate: DateTime(2100),
                  onChanged: (date) => setDialogState(() => expiryDate = date),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: hasVesting,
                  onChanged: (v) => setDialogState(() => hasVesting = v),
                  title: const Text('Add Vesting Schedule'),
                  contentPadding: EdgeInsets.zero,
                ),
                if (hasVesting) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: vestingPeriodMonths,
                          decoration: const InputDecoration(
                            labelText: 'Vesting Period',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 24, child: Text('2 years')),
                            DropdownMenuItem(value: 36, child: Text('3 years')),
                            DropdownMenuItem(value: 48, child: Text('4 years')),
                            DropdownMenuItem(value: 60, child: Text('5 years')),
                          ],
                          onChanged: (v) => setDialogState(
                            () => vestingPeriodMonths = v ?? 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: cliffMonths,
                          decoration: const InputDecoration(
                            labelText: 'Cliff',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('No cliff')),
                            DropdownMenuItem(value: 6, child: Text('6 months')),
                            DropdownMenuItem(value: 12, child: Text('1 year')),
                            DropdownMenuItem(
                              value: 18,
                              child: Text('18 months'),
                            ),
                          ],
                          onChanged: (v) =>
                              setDialogState(() => cliffMonths = v ?? 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<VestingFrequency>(
                    value: vestingFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Vesting Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: VestingFrequency.monthly,
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: VestingFrequency.quarterly,
                        child: Text('Quarterly'),
                      ),
                      DropdownMenuItem(
                        value: VestingFrequency.annually,
                        child: Text('Annually'),
                      ),
                    ],
                    onChanged: (v) => setDialogState(
                      () => vestingFrequency = v ?? VestingFrequency.monthly,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final numOptions = int.tryParse(optionsController.text) ?? 0;
                final strikePrice =
                    double.tryParse(strikePriceController.text) ?? 0;
                if (selectedInvestorId != null &&
                    numOptions > 0 &&
                    strikePrice > 0) {
                  setState(() {
                    _pendingNewOptions.add(
                      _PendingOption(
                        investorId: selectedInvestorId!,
                        shareClassId: selectedShareClassId,
                        numberOfOptions: numOptions,
                        strikePrice: strikePrice,
                        expiryDate: expiryDate,
                        hasVesting: hasVesting,
                        vestingPeriodMonths: hasVesting
                            ? vestingPeriodMonths
                            : null,
                        cliffMonths: hasVesting ? cliffMonths : null,
                        vestingFrequency: hasVesting ? vestingFrequency : null,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 6: Summary ───────────────────────────────────────────────────────

  Widget _buildSummaryStep() {
    final theme = Theme.of(context);
    final provider = context.watch<CoreCapTableProvider>();
    final convertiblesProvider = context.watch<ConvertiblesProvider>();

    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final totalInvestment = _pendingInvestments.fold(
      0.0,
      (sum, inv) => sum + inv.amount,
    );
    final postMoneyVal = preMoneyVal + totalInvestment;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review the round details before creating.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Round details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RoundAvatar(
                        type: _roundType,
                        order: provider.rounds.length + 1,
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Formatters.date(_roundDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: 'Pre-Money',
                    value: Formatters.currency(preMoneyVal),
                  ),
                  _SummaryRow(
                    label: 'Amount Raised',
                    value: Formatters.currency(totalInvestment),
                  ),
                  _SummaryRow(
                    label: 'Post-Money',
                    value: Formatters.currency(postMoneyVal),
                    isHighlighted: true,
                  ),
                  if (_leadInvestorController.text.isNotEmpty)
                    _SummaryRow(
                      label: 'Lead Investor',
                      value: _leadInvestorController.text,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Investments summary
          if (_pendingInvestments.isNotEmpty) ...[
            Text(
              'Investments (${_pendingInvestments.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_pendingInvestments.length, (index) {
              final inv = _pendingInvestments[index];
              final investor = provider.getInvestorById(inv.investorId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(investor?.name ?? 'Unknown')),
                    Text(
                      Formatters.currency(inv.amount),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Convertibles summary
          if (_selectedConvertibleIds.isNotEmpty) ...[
            Text(
              'Converting (${_selectedConvertibleIds.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._selectedConvertibleIds.map((id) {
              final conv = convertiblesProvider.getConvertibleById(id);
              if (conv == null) return const SizedBox.shrink();
              final investor = provider.getInvestorById(conv.investorId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(investor?.name ?? 'Unknown')),
                    Text(
                      Formatters.currency(conv.convertibleAmount),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // New Convertibles summary
          if (_pendingNewConvertibles.isNotEmpty) ...[
            Text(
              'New Convertibles (${_pendingNewConvertibles.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._pendingNewConvertibles.map((conv) {
              final investor = provider.getInvestorById(conv.investorId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${investor?.name ?? 'Unknown'} (${conv.type == ConvertibleType.safe ? 'SAFE' : 'Note'})',
                      ),
                    ),
                    Text(
                      Formatters.currency(conv.principalAmount),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // New Warrants summary
          if (_pendingNewWarrants.isNotEmpty) ...[
            Text(
              'New Warrants (${_pendingNewWarrants.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._pendingNewWarrants.map((warrant) {
              final investor = provider.getInvestorById(warrant.investorId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(investor?.name ?? 'Unknown')),
                    Text(
                      '${Formatters.number(warrant.numberOfWarrants)} @ ${Formatters.currency(warrant.strikePrice)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // New Options summary
          if (_pendingNewOptions.isNotEmpty) ...[
            Text(
              'New Options (${_pendingNewOptions.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._pendingNewOptions.map((option) {
              final investor = provider.getInvestorById(option.investorId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(investor?.name ?? 'Unknown')),
                    Text(
                      '${Formatters.number(option.numberOfOptions)} @ ${Formatters.currency(option.strikePrice)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Notes
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final theme = Theme.of(context);

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
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _canProceed() ? _handleNext : null,
                child: Text(
                  _currentStep == _totalSteps - 1
                      ? (isEditing ? 'Save Changes' : 'Create Round')
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Details
        return _nameController.text.isNotEmpty;
      case 1: // Valuation - allow 0 for incorporation rounds
        return _preMoneyController.text.isNotEmpty &&
            double.tryParse(_preMoneyController.text) != null;
      case 2: // Investments - optional, can always proceed
        return true;
      case 3: // Convertibles - optional, can always proceed
        return true;
      case 4: // New Instruments - optional, can always proceed
        return true;
      case 5: // Summary
        return true;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      // Initialize price when entering investments step
      if (_currentStep == 2) {
        _initializeInvestmentPrice();
      }
    } else {
      _createRound();
    }
  }

  Future<void> _createRound() async {
    final provider = context.read<CoreCapTableProvider>();
    final convertiblesProvider = context.read<ConvertiblesProvider>();
    final esopProvider = context.read<EsopProvider>();

    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final pricePerShare = double.tryParse(_pricePerShareController.text);
    final totalInvestment = _pendingInvestments.fold(
      0.0,
      (sum, inv) => sum + inv.amount,
    );

    // Create or update round
    final round = InvestmentRound(
      id: widget.existingRound?.id,
      name: _nameController.text,
      type: _roundType,
      date: _roundDate,
      preMoneyValuation: preMoneyVal,
      amountRaised: totalInvestment,
      pricePerShare: pricePerShare,
      leadInvestor: _leadInvestorController.text.isEmpty
          ? null
          : _leadInvestorController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      isClosed: _markAsClosed,
      order: widget.existingRound?.order ?? provider.rounds.length,
    );

    if (isEditing) {
      await provider.updateRound(round);
    } else {
      await provider.addRound(round);
    }

    // Handle investment transactions
    final sharesBefore = provider.getIssuedSharesBeforeDate(_roundDate);
    final pps =
        pricePerShare ?? (sharesBefore > 0 ? preMoneyVal / sharesBefore : 1.0);

    if (isEditing) {
      // Get existing transactions for this round
      final existingTransactions = provider.getInvestmentsByRound(round.id);
      final existingIds = _pendingInvestments
          .map((i) => i.existingTransactionId)
          .toSet();

      // Delete transactions that were removed
      for (final existing in existingTransactions) {
        if (!existingIds.contains(existing.id)) {
          await provider.deleteTransaction(existing.id);
        }
      }

      // Update existing and add new transactions
      for (final inv in _pendingInvestments) {
        if (inv.isExisting) {
          // Update existing transaction
          final existing = existingTransactions
              .where((t) => t.id == inv.existingTransactionId)
              .firstOrNull;
          if (existing != null) {
            await provider.updateTransaction(
              existing.copyWith(
                shareClassId: inv.shareClassId,
                numberOfShares: inv.shares,
                pricePerShare: pps,
                totalAmount: inv.amount,
                date: _roundDate,
              ),
            );
          }
        } else {
          // Add new transaction with optional vesting
          final transaction = Transaction(
            investorId: inv.investorId,
            shareClassId: inv.shareClassId,
            roundId: round.id,
            type: TransactionType.purchase,
            numberOfShares: inv.shares,
            pricePerShare: pps,
            totalAmount: inv.amount,
            date: _roundDate,
          );
          await provider.addTransaction(transaction);

          // Create vesting schedule if needed
          if (inv.hasVesting && inv.vestingPeriodMonths != null) {
            final vestingSchedule = VestingSchedule(
              transactionId: transaction.id,
              type: VestingType.timeBased,
              startDate: _roundDate,
              vestingPeriodMonths: inv.vestingPeriodMonths!,
              cliffMonths: inv.cliffMonths ?? 12,
              frequency: inv.vestingFrequency ?? VestingFrequency.monthly,
            );
            await provider.addVestingSchedule(vestingSchedule);
          }
        }
      }
    } else {
      // Add all investment transactions for new round
      for (final inv in _pendingInvestments) {
        final transaction = Transaction(
          investorId: inv.investorId,
          shareClassId: inv.shareClassId,
          roundId: round.id,
          type: TransactionType.purchase,
          numberOfShares: inv.shares,
          pricePerShare: pps,
          totalAmount: inv.amount,
          date: _roundDate,
        );
        await provider.addTransaction(transaction);

        // Create vesting schedule if needed
        if (inv.hasVesting && inv.vestingPeriodMonths != null) {
          final vestingSchedule = VestingSchedule(
            transactionId: transaction.id,
            type: VestingType.timeBased,
            startDate: _roundDate,
            vestingPeriodMonths: inv.vestingPeriodMonths!,
            cliffMonths: inv.cliffMonths ?? 12,
            frequency: inv.vestingFrequency ?? VestingFrequency.monthly,
          );
          await provider.addVestingSchedule(vestingSchedule);
        }
      }
    }

    // Convert selected convertibles
    final defaultShareClassId = provider.shareClasses.isNotEmpty
        ? provider.shareClasses.first.id
        : null;

    for (final convId in _selectedConvertibleIds) {
      if (defaultShareClassId != null) {
        await convertiblesProvider.convertConvertible(
          convertibleId: convId,
          shareClassId: defaultShareClassId,
          roundId: round.id,
          conversionDate: _roundDate,
          roundPreMoney: preMoneyVal,
          issuedSharesBeforeRound: sharesBefore,
          isRoundClosed: _markAsClosed,
        );
      }
    }

    // Add new convertibles
    for (final conv in _pendingNewConvertibles) {
      final convertible = ConvertibleInstrument(
        investorId: conv.investorId,
        type: conv.type,
        principalAmount: conv.principalAmount,
        valuationCap: conv.valuationCap,
        discountPercent: conv.discountPercent,
        interestRate: conv.interestRate,
        maturityDate: conv.maturityDate,
        issueDate: _roundDate,
        hasMFN: conv.hasMFN,
        hasProRata: conv.hasProRata,
      );
      await convertiblesProvider.addConvertible(convertible);
    }

    // Add new warrants
    for (final warrant in _pendingNewWarrants) {
      final newWarrant = Warrant(
        investorId: warrant.investorId,
        roundId: round.id,
        numberOfWarrants: warrant.numberOfWarrants,
        strikePrice: warrant.strikePrice,
        issueDate: _roundDate,
        expiryDate: warrant.expiryDate,
        shareClassId: warrant.shareClassId,
        status: _markAsClosed ? WarrantStatus.active : WarrantStatus.pending,
      );
      await esopProvider.addWarrant(newWarrant);
    }

    // Add new options with vesting
    for (final option in _pendingNewOptions) {
      final grant = OptionGrant(
        investorId: option.investorId,
        shareClassId: option.shareClassId ?? defaultShareClassId ?? '',
        numberOfOptions: option.numberOfOptions,
        strikePrice: option.strikePrice,
        grantDate: _roundDate,
        expiryDate: option.expiryDate,
        roundId: round.id,
        status: _markAsClosed
            ? OptionGrantStatus.active
            : OptionGrantStatus.pending,
      );
      await esopProvider.addOptionGrant(grant);

      // Create vesting schedule if needed
      if (option.hasVesting && option.vestingPeriodMonths != null) {
        final vestingSchedule = VestingSchedule(
          transactionId: grant.id, // Link to grant ID
          type: VestingType.timeBased,
          startDate: _roundDate,
          vestingPeriodMonths: option.vestingPeriodMonths!,
          cliffMonths: option.cliffMonths ?? 12,
          frequency: option.vestingFrequency ?? VestingFrequency.monthly,
        );
        await provider.addVestingSchedule(vestingSchedule);

        // Update grant with vesting schedule ID
        await esopProvider.updateOptionGrant(
          grant.copyWith(vestingScheduleId: vestingSchedule.id),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context, true);
      showSuccessSnackbar(
        context,
        isEditing ? 'Round updated successfully' : 'Round created successfully',
      );
    }
  }

  void _confirmExit() async {
    // Only confirm if there are changes
    final hasChanges =
        _nameController.text.isNotEmpty ||
        _pendingInvestments.isNotEmpty ||
        _selectedConvertibleIds.isNotEmpty ||
        _pendingNewConvertibles.isNotEmpty ||
        _pendingNewWarrants.isNotEmpty ||
        _pendingNewOptions.isNotEmpty;

    if (hasChanges) {
      final confirmed = await showConfirmDialog(
        context: context,
        title: 'Discard Changes?',
        message: 'You have unsaved changes. Are you sure you want to exit?',
      );
      if (confirmed && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  String _getRoundTypeName(RoundType type) {
    switch (type) {
      case RoundType.incorporation:
        return 'Incorporation';
      case RoundType.seed:
        return 'Seed';
      case RoundType.seriesA:
        return 'Series A';
      case RoundType.seriesB:
        return 'Series B';
      case RoundType.seriesC:
        return 'Series C';
      case RoundType.seriesD:
        return 'Series D';
      case RoundType.bridge:
        return 'Bridge';
      case RoundType.convertible:
        return 'Convertible Note';
      case RoundType.esopPool:
        return 'ESOP Pool';
      case RoundType.secondary:
        return 'Secondary';
      case RoundType.custom:
        return 'Custom';
    }
  }
}

/// Helper class to track pending investments before round creation
class _PendingInvestment {
  final String investorId;
  final String shareClassId;
  final double amount;
  final int shares;

  /// For editing: the existing transaction ID (null for new investments)
  final String? existingTransactionId;

  // Vesting fields
  final bool hasVesting;
  final int? vestingPeriodMonths;
  final int? cliffMonths;
  final VestingFrequency? vestingFrequency;

  const _PendingInvestment({
    required this.investorId,
    required this.shareClassId,
    required this.amount,
    required this.shares,
    this.existingTransactionId,
    this.hasVesting = false,
    this.vestingPeriodMonths,
    this.cliffMonths,
    this.vestingFrequency,
  });

  bool get isExisting => existingTransactionId != null;
}

/// Helper class to track pending new convertibles
class _PendingConvertible {
  final String investorId;
  final ConvertibleType type;
  final double principalAmount;
  final double? valuationCap;
  final double? discountPercent;
  final double? interestRate;
  final DateTime? maturityDate;
  final bool hasMFN;
  final bool hasProRata;

  const _PendingConvertible({
    required this.investorId,
    required this.type,
    required this.principalAmount,
    this.valuationCap,
    this.discountPercent,
    this.interestRate,
    this.maturityDate,
    this.hasMFN = false,
    this.hasProRata = false,
  });
}

/// Helper class to track pending new warrants
class _PendingWarrant {
  final String investorId;
  final String? shareClassId;
  final int numberOfWarrants;
  final double strikePrice;
  final DateTime expiryDate;

  const _PendingWarrant({
    required this.investorId,
    this.shareClassId,
    required this.numberOfWarrants,
    required this.strikePrice,
    required this.expiryDate,
  });
}

/// Helper class to track pending new option grants
class _PendingOption {
  final String investorId;
  final String? shareClassId;
  final int numberOfOptions;
  final double strikePrice;
  final DateTime expiryDate;
  final bool hasVesting;
  final int? vestingPeriodMonths;
  final int? cliffMonths;
  final VestingFrequency? vestingFrequency;

  const _PendingOption({
    required this.investorId,
    this.shareClassId,
    required this.numberOfOptions,
    required this.strikePrice,
    required this.expiryDate,
    this.hasVesting = false,
    this.vestingPeriodMonths,
    this.cliffMonths,
    this.vestingFrequency,
  });
}

/// Summary row widget for the final step
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color: isHighlighted ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
