import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';

/// Full-screen wizard for creating investment rounds.
/// Guides users through: Details → Valuation → Investments → Convertibles → Warrants → Summary
class RoundBuilderPage extends ConsumerStatefulWidget {
  /// Optional existing round for editing
  final Round? existingRound;

  const RoundBuilderPage({super.key, this.existingRound});

  /// Show the wizard and return true if a round was created/edited
  static Future<bool?> show(BuildContext context, {Round? existingRound}) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RoundBuilderPage(existingRound: existingRound),
      ),
    );
  }

  @override
  ConsumerState<RoundBuilderPage> createState() => _RoundBuilderPageState();
}

class _RoundBuilderPageState extends ConsumerState<RoundBuilderPage> {
  int _currentStep = 0;
  static const int _totalSteps = 6;

  // Step 1: Round Details
  String _roundType = 'seed';
  final _nameController = TextEditingController();
  DateTime _roundDate = DateTime.now();
  final _leadInvestorController = TextEditingController();

  // Step 2: Valuation
  final _preMoneyController = TextEditingController();
  final _pricePerShareController = TextEditingController();

  // Step 3: Investments
  final List<_PendingInvestment> _pendingInvestments = [];
  int? _editingInvestmentIndex; // null = adding new, index = editing existing

  // Step 4: Convertibles
  final Set<String> _selectedConvertibleIds = {};
  final Set<String> _newlyCreatedConvertibleIds = {}; // Track IDs created in this builder

  // Step 5: Warrants
  final Set<String> _selectedWarrantIds = {};
  final Set<String> _newlyCreatedWarrantIds = {}; // Track IDs created in this builder

  // Step 6: Summary
  final _notesController = TextEditingController();

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
    setState(() {
      _roundType = round.type;
      _roundDate = round.date;
    });
    _nameController.text = round.name;
    _leadInvestorController.text = round.leadInvestorId ?? '';
    _preMoneyController.text =
        round.preMoneyValuation?.toStringAsFixed(0) ?? '';
    if (round.pricePerShare != null) {
      _pricePerShareController.text = round.pricePerShare!.toStringAsFixed(4);
    }
    _notesController.text = round.notes ?? '';

    // Load existing holdings for this round
    _loadExistingInvestments(round.id);
  }

  Future<void> _loadExistingInvestments(String roundId) async {
    final db = ref.read(databaseProvider);
    final holdings = await db.getHoldings(widget.existingRound!.companyId);
    final roundHoldings = holdings.where((h) => h.roundId == roundId).toList();

    if (roundHoldings.isNotEmpty) {
      setState(() {
        for (final holding in roundHoldings) {
          _pendingInvestments.add(
            _PendingInvestment(
              existingId: holding.id, // Track the existing holding ID
              stakeholderId: holding.stakeholderId,
              shareClassId: holding.shareClassId,
              vestingScheduleId: holding.vestingScheduleId,
              amount: holding.costBasis * holding.shareCount,
              shares: holding.shareCount,
            ),
          );
        }
      });
    }
  }

  void _initializeDefaults() {
    _nameController.text = _getRoundTypeName(_roundType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _leadInvestorController.dispose();
    _preMoneyController.dispose();
    _pricePerShareController.dispose();
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
      'Warrants',
      'Summary',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Column(
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
        return _buildWarrantsStep();
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
          DropdownButtonFormField<String>(
            initialValue: _roundType,
            decoration: const InputDecoration(
              labelText: 'Round Type',
              prefixIcon: Icon(Icons.layers),
              border: OutlineInputBorder(),
            ),
            items: _roundTypes.map((type) {
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
                    _roundTypes.any(
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
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _roundDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() => _roundDate = date);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Round Date',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              child: Text(Formatters.date(_roundDate)),
            ),
          ),
          const SizedBox(height: 16),

          // Lead Investor (optional)
          TextFormField(
            controller: _leadInvestorController,
            decoration: const InputDecoration(
              labelText: 'Lead Investor (optional)',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
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
    final holdingsAsync = ref.watch(holdingsStreamProvider);

    // Calculate implied price
    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final totalShares =
        holdingsAsync.valueOrNull?.fold<int>(
          0,
          (sum, h) => sum + h.shareCount,
        ) ??
        0;
    final impliedPrice = totalShares > 0 ? preMoneyVal / totalShares : 0.0;

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
            decoration: const InputDecoration(
              labelText: 'Pre-Money Valuation',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Implied Price Info
          if (totalShares > 0) ...[
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
                          'Based on ${Formatters.compactNumber(totalShares)} existing shares',
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
                  helperText: impliedPrice > 0
                      ? 'Leave empty to use implied price: ${Formatters.currency(impliedPrice)}'
                      : null,
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
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);
    final vestingSchedulesAsync = ref.watch(vestingSchedulesStreamProvider);

    final stakeholders = stakeholdersAsync.valueOrNull ?? [];
    final shareClasses = shareClassesAsync.valueOrNull ?? [];
    final vestingSchedules = vestingSchedulesAsync.valueOrNull ?? [];

    // Get implied price for calculations
    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final totalShares =
        holdingsAsync.valueOrNull?.fold<int>(
          0,
          (sum, h) => sum + h.shareCount,
        ) ??
        0;
    final impliedPrice = totalShares > 0 ? preMoneyVal / totalShares : 0.0;

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
            'Add investors participating in this round. Tap an investment to edit it.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),

          // Pending investments list with inline editing
          if (_pendingInvestments.isNotEmpty) ...[
            Text(
              'Pending Investments',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_pendingInvestments.length, (index) {
              final isEditing = _editingInvestmentIndex == index;
              final inv = _pendingInvestments[index];

              if (isEditing) {
                // Show inline edit form
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _InvestmentForm(
                      stakeholders: stakeholders,
                      shareClasses: shareClasses,
                      vestingSchedules: vestingSchedules,
                      impliedPrice: impliedPrice,
                      initialInvestment: inv,
                      isEditing: true,
                      onSave: (updatedInv) {
                        setState(() {
                          _pendingInvestments[index] = updatedInv;
                          _editingInvestmentIndex = null;
                        });
                      },
                      onCancel: () {
                        setState(() => _editingInvestmentIndex = null);
                      },
                      onDelete: () {
                        setState(() {
                          _pendingInvestments.removeAt(index);
                          _editingInvestmentIndex = null;
                        });
                      },
                    ),
                  ),
                );
              }

              // Show collapsed view
              final stakeholder = stakeholders
                  .where((s) => s.id == inv.stakeholderId)
                  .firstOrNull;
              final vestingSchedule = inv.vestingScheduleId != null
                  ? vestingSchedules
                        .where((v) => v.id == inv.vestingScheduleId)
                        .firstOrNull
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() => _editingInvestmentIndex = index);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Text(
                            stakeholder?.name.substring(0, 1).toUpperCase() ??
                                '?',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stakeholder?.name ?? 'Unknown',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${Formatters.compactNumber(inv.shares)} shares • ${Formatters.currency(inv.amount)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              if (vestingSchedule != null)
                                Text(
                                  'Vesting: ${vestingSchedule.name}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: theme.colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Add investment form (only show if not editing an existing one)
          if (_editingInvestmentIndex == null) ...[
            Text(
              'Add Investment',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _InvestmentForm(
              stakeholders: stakeholders,
              shareClasses: shareClasses,
              vestingSchedules: vestingSchedules,
              impliedPrice: impliedPrice,
              isEditing: false,
              onSave: (newInv) {
                setState(() {
                  _pendingInvestments.add(newInv);
                });
              },
            ),
          ],

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

  // ─── Step 4: Convertibles ──────────────────────────────────────────────────

  Widget _buildConvertiblesStep() {
    final theme = Theme.of(context);
    final convertiblesAsync = ref.watch(convertiblesStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);

    final convertibles = convertiblesAsync.valueOrNull ?? [];
    final stakeholders = stakeholdersAsync.valueOrNull ?? [];

    // Filter to convertibles that can be attached to a round (pending or outstanding)
    final outstanding = convertibles
        .where((c) => c.status == 'pending' || c.status == 'outstanding')
        .toList();

    if (outstanding.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Convertibles',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _showNewConvertibleDialog(context, stakeholders),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Issue New'),
                ),
              ],
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
                    Icons.description_outlined,
                    size: 48,
                    color: theme.colorScheme.outline,
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
                    'Issue a new SAFE or Convertible Note, or skip this step.',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Convertibles',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select convertible instruments to convert in this round.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () =>
                    _showNewConvertibleDialog(context, stakeholders),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Issue New'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // MFN Upgrades Section
          _buildMfnUpgradesSection(stakeholders),

          // Select all toggle
          Row(
            children: [
              Checkbox(
                value: _selectedConvertibleIds.length == outstanding.length,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedConvertibleIds.addAll(
                        outstanding.map((c) => c.id),
                      );
                    } else {
                      _selectedConvertibleIds.clear();
                    }
                  });
                },
              ),
              Text(
                'Select All (${outstanding.length})',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const Divider(),

          // Convertibles list
          ...outstanding.map((conv) {
            final stakeholder = stakeholders
                .where((s) => s.id == conv.stakeholderId)
                .firstOrNull;
            final isSelected = _selectedConvertibleIds.contains(conv.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
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
                secondary: CircleAvatar(
                  backgroundColor: conv.type == 'safe'
                      ? Colors.blue.shade100
                      : Colors.orange.shade100,
                  child: Icon(
                    conv.type == 'safe' ? Icons.security : Icons.receipt_long,
                    color: conv.type == 'safe'
                        ? Colors.blue.shade700
                        : Colors.orange.shade700,
                    size: 20,
                  ),
                ),
                title: Text(stakeholder?.name ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${conv.type.toUpperCase()} • ${Formatters.currency(conv.principal)}',
                    ),
                    if (conv.valuationCap != null)
                      Text(
                        'Cap: ${Formatters.compactCurrency(conv.valuationCap!)}',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          }),

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
                    Formatters.currency(
                      outstanding
                          .where((c) => _selectedConvertibleIds.contains(c.id))
                          .fold(0.0, (sum, c) => sum + c.principal),
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
        ],
      ),
    );
  }

  Widget _buildMfnUpgradesSection(List<Stakeholder> stakeholders) {
    final mfnUpgradesAsync = ref.watch(pendingMfnUpgradesProvider);
    final theme = Theme.of(context);

    return mfnUpgradesAsync.when(
      data: (upgrades) {
        if (upgrades.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
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
                      if (upgrades.length > 1)
                        TextButton.icon(
                          onPressed: () async {
                            final count = await ref
                                .read(mfnMutationsProvider.notifier)
                                .applyAllUpgrades();
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
                  ...upgrades.map((upgrade) {
                    final investor = stakeholders.firstWhere(
                      (s) => s.id == upgrade.target.stakeholderId,
                      orElse: () => Stakeholder(
                        id: '',
                        companyId: '',
                        name: 'Unknown',
                        type: 'unknown',
                        hasProRataRights: false,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  investor.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  upgrade.upgradeDescription,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              await ref
                                  .read(mfnMutationsProvider.notifier)
                                  .applyUpgrade(upgrade);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Upgraded ${investor.name} terms',
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
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ─── Step 5: Warrants ──────────────────────────────────────────────────────

  Widget _buildWarrantsStep() {
    final theme = Theme.of(context);
    final warrantsAsync = ref.watch(warrantsStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);

    final warrants = warrantsAsync.valueOrNull ?? [];
    final stakeholders = stakeholdersAsync.valueOrNull ?? [];

    // Filter to warrants that can be attached to a round (pending, outstanding, or active)
    final outstanding = warrants
        .where((w) => w.status == 'pending' || w.status == 'outstanding' || w.status == 'active')
        .toList();

    if (outstanding.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Warrants',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showNewWarrantDialog(context, stakeholders),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Issue New'),
                ),
              ],
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
                    Icons.receipt_outlined,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Outstanding Warrants',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Issue a new warrant, or skip this step.',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warrants',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select warrants to attach to this round.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showNewWarrantDialog(context, stakeholders),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Issue New'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Select all toggle
          Row(
            children: [
              Checkbox(
                value: _selectedWarrantIds.length == outstanding.length,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedWarrantIds.addAll(outstanding.map((w) => w.id));
                    } else {
                      _selectedWarrantIds.clear();
                    }
                  });
                },
              ),
              Text(
                'Select All (${outstanding.length})',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const Divider(),

          // Warrants list
          ...outstanding.map((warrant) {
            final stakeholder = stakeholders
                .where((s) => s.id == warrant.stakeholderId)
                .firstOrNull;
            final isSelected = _selectedWarrantIds.contains(warrant.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedWarrantIds.add(warrant.id);
                    } else {
                      _selectedWarrantIds.remove(warrant.id);
                    }
                  });
                },
                secondary: CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Icon(
                    Icons.receipt,
                    color: Colors.indigo.shade700,
                    size: 20,
                  ),
                ),
                title: Text(stakeholder?.name ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Formatters.compactNumber(warrant.quantity)} warrants @ ${Formatters.currency(warrant.strikePrice)}',
                    ),
                    Text(
                      'Expires: ${Formatters.date(warrant.expiryDate)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          }),

          if (_selectedWarrantIds.isNotEmpty) ...[
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
                    '${_selectedWarrantIds.length} selected',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '${Formatters.compactNumber(outstanding.where((w) => _selectedWarrantIds.contains(w.id)).fold(0, (sum, w) => sum + w.quantity))} warrants',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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

  // ─── Step 6: Summary ───────────────────────────────────────────────────────

  Widget _buildSummaryStep() {
    final theme = Theme.of(context);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final convertiblesAsync = ref.watch(convertiblesStreamProvider);
    final warrantsAsync = ref.watch(warrantsStreamProvider);

    final stakeholders = stakeholdersAsync.valueOrNull ?? [];
    final convertibles = convertiblesAsync.valueOrNull ?? [];
    final warrants = warrantsAsync.valueOrNull ?? [];

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
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.layers,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
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
              final stakeholder = stakeholders
                  .where((s) => s.id == inv.stakeholderId)
                  .firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(stakeholder?.name ?? 'Unknown')),
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
              final conv = convertibles.where((c) => c.id == id).firstOrNull;
              if (conv == null) return const SizedBox.shrink();
              final stakeholder = stakeholders
                  .where((s) => s.id == conv.stakeholderId)
                  .firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(stakeholder?.name ?? 'Unknown')),
                    Text(
                      Formatters.currency(conv.principal),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Warrants summary
          if (_selectedWarrantIds.isNotEmpty) ...[
            Text(
              'Attached Warrants (${_selectedWarrantIds.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._selectedWarrantIds.map((id) {
              final warrant = warrants.where((w) => w.id == id).firstOrNull;
              if (warrant == null) return const SizedBox.shrink();
              final stakeholder = stakeholders
                  .where((s) => s.id == warrant.stakeholderId)
                  .firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(stakeholder?.name ?? 'Unknown')),
                    Text(
                      '${Formatters.compactNumber(warrant.quantity)} @ ${Formatters.currency(warrant.strikePrice)}',
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
      case 2: // Investments - optional
        return true;
      case 3: // Convertibles - optional
        return true;
      case 4: // Warrants - optional
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
    } else {
      _createRound();
    }
  }

  Future<void> _createRound() async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) return;

    final roundMutations = ref.read(roundMutationsProvider.notifier);
    final holdingMutations = ref.read(holdingMutationsProvider.notifier);
    final convertibleMutations = ref.read(
      convertibleMutationsProvider.notifier,
    );
    final shareClassesAsync = ref.read(shareClassesStreamProvider);

    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final pricePerShare = double.tryParse(_pricePerShareController.text);
    final totalInvestment = _pendingInvestments.fold(
      0.0,
      (sum, inv) => sum + inv.amount,
    );

    try {
      // Create or update the round
      final String roundId;
      if (isEditing) {
        roundId = widget.existingRound!.id;
        await roundMutations.updateRound(
          id: roundId,
          name: _nameController.text,
          type: _roundType,
          date: _roundDate,
          preMoneyValuation: preMoneyVal,
          pricePerShare: pricePerShare,
          amountRaised: totalInvestment,
          leadInvestorId: _leadInvestorController.text.isEmpty
              ? null
              : _leadInvestorController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      } else {
        roundId = await roundMutations.create(
          companyId: companyId,
          name: _nameController.text,
          type: _roundType,
          date: _roundDate,
          preMoneyValuation: preMoneyVal,
          pricePerShare: pricePerShare,
          amountRaised: totalInvestment,
          leadInvestorId: _leadInvestorController.text.isEmpty
              ? null
              : _leadInvestorController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      }

      // Calculate price per share for investments
      final holdingsAsync = ref.read(holdingsStreamProvider);
      final totalShares =
          holdingsAsync.valueOrNull?.fold<int>(
            0,
            (sum, h) => sum + h.shareCount,
          ) ??
          0;
      final pps =
          pricePerShare ?? (totalShares > 0 ? preMoneyVal / totalShares : 1.0);

      // Create holdings only for NEW investments (skip existing ones)
      for (final inv in _pendingInvestments) {
        if (inv.isExisting) continue; // Skip existing holdings

        await holdingMutations.issueShares(
          companyId: companyId,
          stakeholderId: inv.stakeholderId,
          shareClassId: inv.shareClassId,
          shareCount: inv.shares,
          costBasis: pps,
          acquiredDate: _roundDate,
          vestingScheduleId: inv.vestingScheduleId,
          vestedCount: inv.vestingScheduleId == null ? inv.shares : 0,
          roundId: roundId,
        );
      }

      // Link newly created convertibles to the round
      for (final convId in _newlyCreatedConvertibleIds) {
        await convertibleMutations.updateConvertible(
          id: convId,
          roundId: roundId,
        );
      }

      // Link newly created warrants to the round
      final warrantMutations = ref.read(warrantMutationsProvider.notifier);
      for (final warrantId in _newlyCreatedWarrantIds) {
        await warrantMutations.updateWarrant(
          id: warrantId,
          roundId: roundId,
        );
      }

      // Convert selected convertibles
      final shareClasses = shareClassesAsync.valueOrNull ?? [];
      final defaultShareClassId = shareClasses.isNotEmpty
          ? shareClasses.first.id
          : null;

      if (defaultShareClassId != null) {
        for (final convId in _selectedConvertibleIds) {
          // Convert the instrument and link it to this round
          // TODO: Full conversion math would calculate shares based on cap/discount
          await convertibleMutations.convert(
            id: convId,
            shareClassId: defaultShareClassId,
            sharesReceived: 0, // Placeholder - full math to be implemented
            conversionEventId: roundId, // Link to this round
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Round updated successfully'
                  : 'Round created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── Issue New Convertible Dialog ──────────────────────────────────────────

  void _showNewConvertibleDialog(
    BuildContext context,
    List<Stakeholder> stakeholders,
  ) {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) return;

    final principalController = TextEditingController();
    final capController = TextEditingController();
    final discountController = TextEditingController();
    final interestController = TextEditingController();
    final notesController = TextEditingController();

    String selectedType = 'safe';
    String? selectedStakeholderId;
    DateTime issueDate = _roundDate;
    bool hasMfn = false;
    bool hasProRata = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Issue New Convertible'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStakeholderId,
                  decoration: const InputDecoration(labelText: 'Investor'),
                  items: stakeholders
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedStakeholderId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'safe', child: Text('SAFE')),
                    DropdownMenuItem(
                      value: 'note',
                      child: Text('Convertible Note'),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v ?? 'safe'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: principalController,
                  decoration: const InputDecoration(
                    labelText: 'Principal Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capController,
                  decoration: const InputDecoration(
                    labelText: 'Valuation Cap (optional)',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount % (optional)',
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (selectedType == 'note') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: interestController,
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate % (optional)',
                      suffixText: '% p.a.',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('MFN (Most Favored Nation)'),
                  value: hasMfn,
                  onChanged: (v) => setDialogState(() => hasMfn = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Pro-rata Rights'),
                  value: hasProRata,
                  onChanged: (v) =>
                      setDialogState(() => hasProRata = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final principal = double.tryParse(principalController.text);
                if (principal == null || principal <= 0) return;
                if (selectedStakeholderId == null) return;

                final mutations = ref.read(
                  convertibleMutationsProvider.notifier,
                );
                final cap = double.tryParse(capController.text);
                final discount = double.tryParse(discountController.text);
                final interest = double.tryParse(interestController.text);

                final newId = await mutations.create(
                  companyId: companyId,
                  stakeholderId: selectedStakeholderId!,
                  type: selectedType,
                  principal: principal,
                  issueDate: issueDate,
                  status: 'pending', // Pending until round is closed
                  valuationCap: cap,
                  discountPercent: discount,
                  interestRate: interest,
                  hasMfn: hasMfn,
                  hasProRata: hasProRata,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );

                // Track the newly created ID for linking to round later
                setState(() => _newlyCreatedConvertibleIds.add(newId));

                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Issue'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Issue New Warrant Dialog ──────────────────────────────────────────────

  void _showNewWarrantDialog(
    BuildContext context,
    List<Stakeholder> stakeholders,
  ) {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) return;

    // Get share classes - need to watch to ensure we have latest data
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);
    final shareClasses = shareClassesAsync.valueOrNull ?? [];

    if (shareClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a share class first')),
      );
      return;
    }

    final quantityController = TextEditingController();
    final strikeController = TextEditingController();
    final notesController = TextEditingController();

    String? selectedStakeholderId;
    String? selectedShareClassId = shareClasses.first.id;
    DateTime issueDate = _roundDate;
    DateTime expiryDate = _roundDate.add(const Duration(days: 365 * 10));

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Issue New Warrant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStakeholderId,
                  decoration: const InputDecoration(labelText: 'Holder'),
                  items: stakeholders
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedStakeholderId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShareClassId,
                  decoration: const InputDecoration(labelText: 'Share Class'),
                  items: shareClasses
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedShareClassId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Warrants',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: strikeController,
                  decoration: const InputDecoration(
                    labelText: 'Strike Price',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text);
                final strike = double.tryParse(strikeController.text);
                if (quantity == null || quantity <= 0) return;
                if (strike == null || strike <= 0) return;
                if (selectedStakeholderId == null) return;
                if (selectedShareClassId == null) return;

                final mutations = ref.read(warrantMutationsProvider.notifier);

                final newId = await mutations.create(
                  companyId: companyId,
                  stakeholderId: selectedStakeholderId!,
                  shareClassId: selectedShareClassId!,
                  quantity: quantity,
                  strikePrice: strike,
                  issueDate: issueDate,
                  expiryDate: expiryDate,
                  status: 'pending', // Pending until round is closed
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );

                // Track the newly created ID for linking to round later
                setState(() => _newlyCreatedWarrantIds.add(newId));

                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Issue'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit() async {
    final hasChanges =
        _nameController.text.isNotEmpty ||
        _pendingInvestments.isNotEmpty ||
        _selectedConvertibleIds.isNotEmpty ||
        _selectedWarrantIds.isNotEmpty;

    if (hasChanges) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to exit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  static const List<String> _roundTypes = [
    'incorporation',
    'seed',
    'series_a',
    'series_b',
    'series_c',
    'series_d',
    'bridge',
    'convertible',
    'esop_pool',
    'secondary',
    'custom',
  ];

  String _getRoundTypeName(String type) {
    switch (type) {
      case 'incorporation':
        return 'Incorporation';
      case 'seed':
        return 'Seed';
      case 'series_a':
        return 'Series A';
      case 'series_b':
        return 'Series B';
      case 'series_c':
        return 'Series C';
      case 'series_d':
        return 'Series D';
      case 'bridge':
        return 'Bridge';
      case 'convertible':
        return 'Convertible Note';
      case 'esop_pool':
        return 'ESOP Pool';
      case 'secondary':
        return 'Secondary';
      case 'custom':
        return 'Custom';
      default:
        return type;
    }
  }
}

/// Helper class to track pending investments before round creation
class _PendingInvestment {
  final String? existingId; // Non-null if this is an existing holding
  final String stakeholderId;
  final String shareClassId;
  final String? vestingScheduleId;
  final double amount;
  final int shares;

  const _PendingInvestment({
    this.existingId,
    required this.stakeholderId,
    required this.shareClassId,
    this.vestingScheduleId,
    required this.amount,
    required this.shares,
  });

  bool get isExisting => existingId != null;
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

/// Reusable investment form widget for adding and editing investments.
class _InvestmentForm extends StatefulWidget {
  final List<Stakeholder> stakeholders;
  final List<ShareClassesData> shareClasses;
  final List<VestingSchedule> vestingSchedules;
  final double impliedPrice;
  final _PendingInvestment? initialInvestment;
  final bool isEditing;
  final void Function(_PendingInvestment investment) onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const _InvestmentForm({
    required this.stakeholders,
    required this.shareClasses,
    required this.vestingSchedules,
    required this.impliedPrice,
    this.initialInvestment,
    required this.isEditing,
    required this.onSave,
    this.onCancel,
    this.onDelete,
  });

  @override
  State<_InvestmentForm> createState() => _InvestmentFormState();
}

class _InvestmentFormState extends State<_InvestmentForm> {
  String? _selectedStakeholderId;
  String? _selectedShareClassId;
  String? _selectedVestingScheduleId;
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  final _sharesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialInvestment != null) {
      final inv = widget.initialInvestment!;
      _selectedStakeholderId = inv.stakeholderId;
      _selectedShareClassId = inv.shareClassId;
      _selectedVestingScheduleId = inv.vestingScheduleId;
      _amountController.text = inv.amount.toStringAsFixed(2);
      _sharesController.text = inv.shares.toString();
      // Calculate price from amount and shares
      if (inv.shares > 0 && inv.amount > 0) {
        _priceController.text = (inv.amount / inv.shares).toStringAsFixed(4);
      } else if (widget.impliedPrice > 0) {
        _priceController.text = widget.impliedPrice.toStringAsFixed(4);
      }
    } else if (widget.impliedPrice > 0) {
      _priceController.text = widget.impliedPrice.toStringAsFixed(4);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    _sharesController.dispose();
    super.dispose();
  }

  void _calculateFromAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;

    if (amount > 0 && price > 0) {
      final shares = (amount / price).round();
      _sharesController.text = shares.toString();
    }
    setState(() {});
  }

  void _calculateFromShares() {
    final shares = int.tryParse(_sharesController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;

    if (shares > 0 && price > 0) {
      final amount = shares * price;
      _amountController.text = amount.toStringAsFixed(2);
    }
    setState(() {});
  }

  void _calculateFromPrice() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;

    if (amount > 0 && price > 0) {
      final shares = (amount / price).round();
      _sharesController.text = shares.toString();
    }
    setState(() {});
  }

  bool _canSave() {
    if (_selectedStakeholderId == null || _selectedShareClassId == null) {
      return false;
    }
    final shares = int.tryParse(_sharesController.text) ?? 0;
    return shares > 0;
  }

  void _handleSave() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final shares = int.tryParse(_sharesController.text) ?? 0;

    if (shares > 0) {
      widget.onSave(
        _PendingInvestment(
          stakeholderId: _selectedStakeholderId!,
          shareClassId: _selectedShareClassId!,
          vestingScheduleId: _selectedVestingScheduleId,
          amount: amount,
          shares: shares,
        ),
      );

      // Clear form if adding (not editing)
      if (!widget.isEditing) {
        setState(() {
          _selectedStakeholderId = null;
          _selectedVestingScheduleId = null;
          _amountController.clear();
          _sharesController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stakeholder dropdown
        DropdownButtonFormField<String>(
          value: _selectedStakeholderId,
          decoration: const InputDecoration(
            labelText: 'Investor',
            border: OutlineInputBorder(),
          ),
          items: widget.stakeholders.map((s) {
            return DropdownMenuItem(value: s.id, child: Text(s.name));
          }).toList(),
          onChanged: (value) => setState(() => _selectedStakeholderId = value),
        ),
        const SizedBox(height: 12),

        // Share class dropdown
        DropdownButtonFormField<String>(
          value: _selectedShareClassId,
          decoration: const InputDecoration(
            labelText: 'Share Class',
            border: OutlineInputBorder(),
          ),
          items: widget.shareClasses.map((sc) {
            return DropdownMenuItem(value: sc.id, child: Text(sc.name));
          }).toList(),
          onChanged: (value) => setState(() => _selectedShareClassId = value),
        ),
        const SizedBox(height: 12),

        // Vesting schedule dropdown (optional)
        DropdownButtonFormField<String?>(
          value: _selectedVestingScheduleId,
          decoration: const InputDecoration(
            labelText: 'Vesting Schedule (optional)',
            border: OutlineInputBorder(),
            helperText: 'Leave empty for immediate vesting',
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('No vesting (immediate)'),
            ),
            ...widget.vestingSchedules.map((vs) {
              return DropdownMenuItem(value: vs.id, child: Text(vs.name));
            }),
          ],
          onChanged: (value) =>
              setState(() => _selectedVestingScheduleId = value),
        ),
        const SizedBox(height: 12),

        // Price per share
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Price Per Share',
            prefixText: '\$ ',
            border: const OutlineInputBorder(),
            helperText: widget.impliedPrice > 0
                ? 'Implied from valuation: ${Formatters.currency(widget.impliedPrice)}'
                : null,
          ),
          onChanged: (_) => _calculateFromPrice(),
        ),
        const SizedBox(height: 12),

        // Amount and shares
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _amountController,
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
                controller: _sharesController,
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

        // Action buttons
        if (widget.isEditing)
          Row(
            children: [
              if (widget.onDelete != null)
                OutlinedButton.icon(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _canSave() ? _handleSave : null,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save'),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _canSave() ? _handleSave : null,
              icon: const Icon(Icons.add),
              label: const Text('Add to Round'),
            ),
          ),
      ],
    );
  }
}
