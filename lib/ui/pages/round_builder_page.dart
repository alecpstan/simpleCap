import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../domain/services/conversion_calculator.dart';
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
  static const int _totalSteps = 7;

  // Step 1: Round Details
  String _roundType = 'seed';
  final _nameController = TextEditingController();
  DateTime _roundDate = DateTime.now();
  final _leadInvestorController = TextEditingController();

  // Step 2: Valuation
  final _preMoneyController = TextEditingController();
  final _pricePerShareController = TextEditingController();
  String? _valuationSourceNote; // e.g. "409A Valuation on 15 Jan 2025"

  // Step 3: Investments
  final List<_PendingInvestment> _pendingInvestments = [];
  int? _editingInvestmentIndex; // null = adding new, index = editing existing

  // Step 4: Convertibles
  final Set<String> _selectedConvertibleIds = {};
  final Set<String> _newlyCreatedConvertibleIds =
      {}; // Track IDs created in this builder
  // Warrant coverage: convertibleId -> coverage percentage (e.g., 20 for 20%)
  final Map<String, double> _warrantCoveragePercents = {};

  // Step 5: Warrants
  final Set<String> _selectedWarrantIds = {};
  final Set<String> _newlyCreatedWarrantIds =
      {}; // Track IDs created in this builder

  // Step 6: ESOP
  final List<_PendingPoolExpansion> _pendingPoolExpansions = [];
  final List<_PendingNewPool> _pendingNewPools = [];

  // Step 7: Summary
  final _notesController = TextEditingController();

  bool get isEditing => widget.existingRound != null;

  /// Builds an "Issue New" button that respects premium lock status.
  Widget _buildIssueNewButton({
    required bool isLocked,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    if (isLocked) {
      return FilledButton.icon(
        onPressed: null,
        style: FilledButton.styleFrom(
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          disabledForegroundColor: theme.colorScheme.outline,
        ),
        icon: const Icon(Icons.lock, size: 18),
        label: const Text('Issue New'),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Issue New'),
    );
  }

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

    // Load existing securities for this round
    _loadExistingSecurities(round.id);
  }

  Future<void> _loadExistingSecurities(String roundId) async {
    // Use projection providers instead of direct database queries
    // since the app uses event sourcing and data lives in projections
    final holdings = await ref.read(holdingsStreamProvider.future);
    final roundHoldings = holdings.where((h) => h.roundId == roundId).toList();

    final convertibles = await ref.read(convertiblesStreamProvider.future);
    // Convertibles issued in this round
    final issuedConvertibles = convertibles
        .where((c) => c.roundId == roundId)
        .toList();
    // Convertibles being converted in this round
    final convertingConvertibles = convertibles
        .where((c) => c.conversionEventId == roundId)
        .toList();

    final warrants = await ref.read(warrantsStreamProvider.future);
    final roundWarrants = warrants.where((w) => w.roundId == roundId).toList();

    setState(() {
      // Add existing holdings
      for (final holding in roundHoldings) {
        _pendingInvestments.add(
          _PendingInvestment(
            existingId: holding.id,
            stakeholderId: holding.stakeholderId,
            shareClassId: holding.shareClassId,
            vestingScheduleId: holding.vestingScheduleId,
            amount: holding.costBasis * holding.shareCount,
            shares: holding.shareCount,
          ),
        );
      }

      // Pre-select convertibles that are being converted in this round
      for (final conv in convertingConvertibles) {
        _selectedConvertibleIds.add(conv.id);
      }

      // Track newly created convertibles issued in this round
      for (final conv in issuedConvertibles) {
        _newlyCreatedConvertibleIds.add(conv.id);
      }

      // Pre-select existing warrants that belong to this round
      for (final warrant in roundWarrants) {
        _selectedWarrantIds.add(warrant.id);
        // Track as newly created so they display correctly in the builder
        _newlyCreatedWarrantIds.add(warrant.id);
      }
    });
  }

  void _initializeDefaults() {
    _nameController.text = _getRoundTypeName(_roundType);
    _loadDefaultValuation();
  }

  Future<void> _loadDefaultValuation() async {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) return;

    // Get the effective valuation which considers BOTH manual valuations
    // AND round post-money valuations, returning the most recent
    final effectiveVal = await ref.read(effectiveValuationProvider.future);
    if (effectiveVal == null) return;

    setState(() {
      _preMoneyController.text = effectiveVal.value.toStringAsFixed(0);
      _valuationSourceNote = effectiveVal.sourceDescription;
    });
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
      'ESOP',
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
        return _buildEsopStep();
      case 6:
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
                // Reload valuation default if not editing and not manually changed
                if (!isEditing) {
                  _loadDefaultValuation();
                }
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
            onChanged: (_) => setState(() {
              // Clear the source note when user manually changes the value
              _valuationSourceNote = null;
            }),
          ),
          if (_valuationSourceNote != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Populated from $_valuationSourceNote (can be changed)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
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

          // Pro-Rata Rights Section
          _buildProRataSection(
            theme,
            stakeholders,
            holdingsAsync.valueOrNull ?? [],
            totalShares,
          ),

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

  /// Builds the pro-rata rights section showing investors entitled to participate.
  /// Pro-rata right = right to maintain ownership % by purchasing proportional shares.
  Widget _buildProRataSection(
    ThemeData theme,
    List<Stakeholder> stakeholders,
    List<Holding> holdings,
    int totalShares,
  ) {
    // Find stakeholders with pro-rata rights
    final proRataHolders = stakeholders
        .where((s) => s.hasProRataRights)
        .toList();

    if (proRataHolders.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate each holder's ownership percentage and pro-rata allocation
    final roundAmount = _pendingInvestments.fold<double>(
      0,
      (sum, inv) => sum + inv.amount,
    );

    // Build pro-rata data for each eligible holder
    final proRataData = <_ProRataData>[];
    for (final holder in proRataHolders) {
      // Get their current holdings
      final holderHoldings = holdings.where(
        (h) => h.stakeholderId == holder.id,
      );
      final holderShares = holderHoldings.fold<int>(
        0,
        (sum, h) => sum + h.shareCount,
      );

      if (totalShares == 0 || holderShares == 0) continue;

      final ownershipPercent = (holderShares / totalShares) * 100;
      final proRataAmount = roundAmount * (ownershipPercent / 100);

      // Check if they're already participating
      final isParticipating = _pendingInvestments.any(
        (inv) => inv.stakeholderId == holder.id,
      );
      final participationAmount = _pendingInvestments
          .where((inv) => inv.stakeholderId == holder.id)
          .fold<double>(0, (sum, inv) => sum + inv.amount);

      proRataData.add(
        _ProRataData(
          stakeholder: holder,
          ownershipPercent: ownershipPercent,
          proRataAmount: proRataAmount,
          isParticipating: isParticipating,
          participationAmount: participationAmount,
        ),
      );
    }

    if (proRataData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.verified_user,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Pro-Rata Rights',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'These investors have contractual rights to maintain their ownership percentage.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (int i = 0; i < proRataData.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _buildProRataRow(theme, proRataData[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProRataRow(ThemeData theme, _ProRataData data) {
    final fulfillmentPercent = data.proRataAmount > 0
        ? (data.participationAmount / data.proRataAmount * 100).clamp(0, 100)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.stakeholder.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${data.ownershipPercent.toStringAsFixed(1)}% ownership',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pro-rata: ${Formatters.currency(data.proRataAmount)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (data.isParticipating) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      fulfillmentPercent >= 100
                          ? Icons.check_circle
                          : Icons.pending,
                      size: 16,
                      color: fulfillmentPercent >= 100
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.currency(data.participationAmount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: fulfillmentPercent >= 100
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${fulfillmentPercent.toStringAsFixed(0)}% of pro-rata',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Not participating',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.w500,
                ),
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
    final convertiblesAsync = ref.watch(convertiblesStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final convertiblesLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.convertibles),
    );

    final convertibles = convertiblesAsync.valueOrNull ?? [];
    final stakeholders = stakeholdersAsync.valueOrNull ?? [];

    // Filter to convertibles that can be attached to a round:
    // 1. Pending or outstanding status (available for conversion)
    // 2. Already selected for conversion in this round (conversionEventId matches)
    // 3. Issued in this round (roundId matches) - these are newly created
    final roundId = widget.existingRound?.id;
    final outstanding = convertibles
        .where(
          (c) =>
              c.status == 'pending' ||
              c.status == 'outstanding' ||
              (roundId != null && c.conversionEventId == roundId) ||
              (roundId != null && c.roundId == roundId),
        )
        .toList();

    // Separate existing from newly created in this round
    final existingConvertibles = outstanding
        .where((c) => !_newlyCreatedConvertibleIds.contains(c.id))
        .toList();
    final newConvertibles = outstanding
        .where((c) => _newlyCreatedConvertibleIds.contains(c.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
              _buildIssueNewButton(
                isLocked: convertiblesLocked,
                onPressed: () =>
                    _showNewConvertibleDialog(context, stakeholders),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // MFN Upgrades Section
          _buildMfnUpgradesSection(stakeholders),

          // Existing Convertibles Section
          if (existingConvertibles.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Existing Convertibles',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Select all toggle for existing
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      final allSelected = existingConvertibles
                          .every((c) => _selectedConvertibleIds.contains(c.id));
                      if (allSelected) {
                        for (final c in existingConvertibles) {
                          _selectedConvertibleIds.remove(c.id);
                        }
                      } else {
                        _selectedConvertibleIds
                            .addAll(existingConvertibles.map((c) => c.id));
                      }
                    });
                  },
                  icon: Icon(
                    existingConvertibles.every(
                            (c) => _selectedConvertibleIds.contains(c.id))
                        ? Icons.deselect
                        : Icons.select_all,
                    size: 18,
                  ),
                  label: Text(
                    existingConvertibles.every(
                            (c) => _selectedConvertibleIds.contains(c.id))
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...existingConvertibles.map((conv) =>
                _buildConvertibleCard(conv, stakeholders, theme)),
            const SizedBox(height: 24),
          ],

          // New Convertibles Section (created in this round)
          if (newConvertibles.isNotEmpty) ...[
            Text(
              'New Convertibles (This Round)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...newConvertibles.map((conv) {
              final stakeholder = stakeholders
                  .where((s) => s.id == conv.stakeholderId)
                  .firstOrNull;
              final isSelected = _selectedConvertibleIds.contains(conv.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      Icons.add,
                      color: Colors.green.shade800,
                    ),
                  ),
                  title: Text(stakeholder?.name ?? 'Unknown'),
                  subtitle: Text(
                    '${conv.type.toUpperCase()} • ${Formatters.currency(conv.principal)}${conv.valuationCap != null ? ' • Cap: ${Formatters.compactCurrency(conv.valuationCap!)}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            _newlyCreatedConvertibleIds.remove(conv.id);
                            _selectedConvertibleIds.remove(conv.id);
                          });
                          // Note: The actual convertible is already created in DB
                          // This just removes it from the "new" tracking
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Empty state
          if (outstanding.isEmpty)
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
                    'No Convertibles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Issue a new SAFE or Convertible Note to convert in this round.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

          // Summary of selected convertibles
          if (_selectedConvertibleIds.isNotEmpty) ...[
            const Divider(height: 32),
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
                    '${_selectedConvertibleIds.length} selected for conversion',
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

            // Warrant Coverage Section
            const SizedBox(height: 24),
            _buildWarrantCoverageSection(
              theme,
              outstanding
                  .where((c) => _selectedConvertibleIds.contains(c.id))
                  .toList(),
              stakeholders,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConvertibleCard(
    Convertible conv,
    List<Stakeholder> stakeholders,
    ThemeData theme,
  ) {
    final stakeholder =
        stakeholders.where((s) => s.id == conv.stakeholderId).firstOrNull;
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
          backgroundColor:
              conv.type == 'safe' ? Colors.blue.shade100 : Colors.orange.shade100,
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
  }

  /// Build warrant coverage section for selected convertibles.
  /// Allows specifying coverage % to auto-create warrants.
  Widget _buildWarrantCoverageSection(
    ThemeData theme,
    List<Convertible> selectedConvertibles,
    List<Stakeholder> stakeholders,
  ) {
    if (selectedConvertibles.isEmpty) return const SizedBox.shrink();

    // Get implied price for calculations
    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final totalShares =
        holdingsAsync.valueOrNull?.fold<int>(
          0,
          (sum, h) => sum + h.shareCount,
        ) ??
        0;
    final impliedPrice = totalShares > 0 ? preMoneyVal / totalShares : 0.0;

    // Calculate total coverage warrants
    int totalWarrantShares = 0;
    for (final conv in selectedConvertibles) {
      final coverage = _warrantCoveragePercents[conv.id] ?? 0;
      if (coverage > 0 && impliedPrice > 0) {
        final convShares = (conv.principal / impliedPrice).floor();
        totalWarrantShares += (convShares * coverage / 100).floor();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.receipt_long,
              size: 18,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Warrant Coverage',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Optionally add warrant coverage to convertibles. Warrants give holders the right to purchase additional shares at the round price.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (int i = 0; i < selectedConvertibles.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _buildCoverageRow(
                  theme,
                  selectedConvertibles[i],
                  stakeholders,
                  impliedPrice,
                ),
              ],
            ],
          ),
        ),
        if (totalWarrantShares > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total warrant shares to issue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                Text(
                  Formatters.compactNumber(totalWarrantShares),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCoverageRow(
    ThemeData theme,
    Convertible conv,
    List<Stakeholder> stakeholders,
    double impliedPrice,
  ) {
    final stakeholder = stakeholders
        .where((s) => s.id == conv.stakeholderId)
        .firstOrNull;
    final coverage = _warrantCoveragePercents[conv.id] ?? 0;

    // Calculate warrant shares
    final convShares = impliedPrice > 0
        ? (conv.principal / impliedPrice).floor()
        : 0;
    final warrantShares = (convShares * coverage / 100).floor();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stakeholder?.name ?? 'Unknown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${Formatters.currency(conv.principal)} → ~${Formatters.compactNumber(convShares)} shares',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: const OutlineInputBorder(),
                suffixText: '%',
                hintText: '0',
              ),
              controller: TextEditingController(
                text: coverage > 0 ? coverage.toStringAsFixed(0) : '',
              ),
              onChanged: (value) {
                final percent = double.tryParse(value) ?? 0;
                setState(() {
                  if (percent > 0) {
                    _warrantCoveragePercents[conv.id] = percent;
                  } else {
                    _warrantCoveragePercents.remove(conv.id);
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              warrantShares > 0
                  ? '${Formatters.compactNumber(warrantShares)} sh'
                  : '-',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: warrantShares > 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              textAlign: TextAlign.end,
            ),
          ),
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
                            // Apply all MFN upgrades
                            for (final upgrade in upgrades) {
                              await ref
                                  .read(mfnCommandsProvider.notifier)
                                  .applyUpgrade(
                                    targetConvertibleId: upgrade.target.id,
                                    sourceConvertibleId: upgrade.source.id,
                                    previousDiscountPercent:
                                        upgrade.target.discountPercent,
                                    previousValuationCap:
                                        upgrade.target.valuationCap,
                                    previousHasProRata:
                                        upgrade.target.hasProRata,
                                    newDiscountPercent:
                                        upgrade.newDiscountPercent,
                                    newValuationCap: upgrade.newValuationCap,
                                    newHasProRata:
                                        upgrade.addsProRata ||
                                        upgrade.target.hasProRata,
                                  );
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Applied ${upgrades.length} MFN upgrades',
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
                                  .read(mfnCommandsProvider.notifier)
                                  .applyUpgrade(
                                    targetConvertibleId: upgrade.target.id,
                                    sourceConvertibleId: upgrade.source.id,
                                    previousDiscountPercent:
                                        upgrade.target.discountPercent,
                                    previousValuationCap:
                                        upgrade.target.valuationCap,
                                    previousHasProRata:
                                        upgrade.target.hasProRata,
                                    newDiscountPercent:
                                        upgrade.newDiscountPercent,
                                    newValuationCap: upgrade.newValuationCap,
                                    newHasProRata:
                                        upgrade.addsProRata ||
                                        upgrade.target.hasProRata,
                                  );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'MFN upgrade applied for ${investor.name}',
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
    final warrantsLocked = ref.watch(
      isFeatureLockedProvider(PremiumFeature.warrants),
    );

    final warrants = warrantsAsync.valueOrNull ?? [];
    final stakeholders = stakeholdersAsync.valueOrNull ?? [];

    // Filter to warrants that can be attached to a round:
    // 1. Pending, outstanding, or active status (available for attachment)
    // 2. Already belongs to this round (roundId matches)
    final roundId = widget.existingRound?.id;
    final outstanding = warrants
        .where(
          (w) =>
              w.status == 'pending' ||
              w.status == 'outstanding' ||
              w.status == 'active' ||
              (roundId != null && w.roundId == roundId),
        )
        .toList();

    // Separate existing from newly created in this round
    final existingWarrants = outstanding
        .where((w) => !_newlyCreatedWarrantIds.contains(w.id))
        .toList();
    final newWarrants = outstanding
        .where((w) => _newlyCreatedWarrantIds.contains(w.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
              _buildIssueNewButton(
                isLocked: warrantsLocked,
                onPressed: () => _showNewWarrantDialog(context, stakeholders),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Existing Warrants Section
          if (existingWarrants.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Existing Warrants',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Select all toggle for existing
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      final allSelected = existingWarrants
                          .every((w) => _selectedWarrantIds.contains(w.id));
                      if (allSelected) {
                        for (final w in existingWarrants) {
                          _selectedWarrantIds.remove(w.id);
                        }
                      } else {
                        _selectedWarrantIds
                            .addAll(existingWarrants.map((w) => w.id));
                      }
                    });
                  },
                  icon: Icon(
                    existingWarrants
                            .every((w) => _selectedWarrantIds.contains(w.id))
                        ? Icons.deselect
                        : Icons.select_all,
                    size: 18,
                  ),
                  label: Text(
                    existingWarrants
                            .every((w) => _selectedWarrantIds.contains(w.id))
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...existingWarrants
                .map((warrant) => _buildWarrantCard(warrant, stakeholders, theme)),
            const SizedBox(height: 24),
          ],

          // New Warrants Section (created in this round)
          if (newWarrants.isNotEmpty) ...[
            Text(
              'New Warrants (This Round)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...newWarrants.map((warrant) {
              final stakeholder = stakeholders
                  .where((s) => s.id == warrant.stakeholderId)
                  .firstOrNull;
              final isSelected = _selectedWarrantIds.contains(warrant.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      Icons.add,
                      color: Colors.green.shade800,
                    ),
                  ),
                  title: Text(stakeholder?.name ?? 'Unknown'),
                  subtitle: Text(
                    '${Formatters.compactNumber(warrant.quantity)} warrants @ ${Formatters.currency(warrant.strikePrice)} • Expires: ${Formatters.date(warrant.expiryDate)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            _newlyCreatedWarrantIds.remove(warrant.id);
                            _selectedWarrantIds.remove(warrant.id);
                          });
                          // Note: The actual warrant is already created in DB
                          // This just removes it from the "new" tracking
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Empty state
          if (outstanding.isEmpty)
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
                    'No Warrants',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Issue a new warrant to attach to this round.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

          // Summary of selected warrants
          if (_selectedWarrantIds.isNotEmpty) ...[
            const Divider(height: 32),
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

  Widget _buildWarrantCard(
    Warrant warrant,
    List<Stakeholder> stakeholders,
    ThemeData theme,
  ) {
    final stakeholder =
        stakeholders.where((s) => s.id == warrant.stakeholderId).firstOrNull;
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
  }

  // ─── Step 6: ESOP ──────────────────────────────────────────────────────────

  Widget _buildEsopStep() {
    final theme = Theme.of(context);
    final esopPoolsAsync = ref.watch(esopPoolsStreamProvider);
    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final vestingSchedulesAsync = ref.watch(vestingSchedulesStreamProvider);
    final esopLocked = ref.watch(isFeatureLockedProvider(PremiumFeature.options));

    final pools = esopPoolsAsync.valueOrNull ?? [];
    final vestingSchedules = vestingSchedulesAsync.valueOrNull ?? [];

    // Calculate post-money shares for target % calculations
    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final currentShares = holdingsAsync.valueOrNull?.fold<int>(0, (sum, h) => sum + h.shareCount) ?? 0;
    final newShares = _pendingInvestments.fold<int>(0, (sum, inv) => sum + inv.shares);
    final postMoneyShares = currentShares + newShares;

    // Calculate which pools need expansion based on their target percentage
    final poolsNeedingExpansion = <EsopPool, int>{};
    for (final pool in pools) {
      if (pool.targetPercentage != null && pool.targetPercentage! > 0 && postMoneyShares > 0) {
        final targetShares = (postMoneyShares * pool.targetPercentage! / 100).ceil();
        final currentPoolSize = pool.poolSize;
        // Add any pending expansion
        final pendingExpansion = _pendingPoolExpansions
            .where((e) => e.poolId == pool.id)
            .fold<int>(0, (sum, e) => sum + e.sharesToAdd);
        final totalPoolSize = currentPoolSize + pendingExpansion;
        if (targetShares > totalPoolSize) {
          poolsNeedingExpansion[pool] = targetShares - totalPoolSize;
        }
      }
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
                      'ESOP Pools',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expand existing pools or create new ones for this round.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              _buildIssueNewButton(
                isLocked: esopLocked,
                onPressed: () => _showNewPoolDialog(context, vestingSchedules),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pools needing expansion section
          if (poolsNeedingExpansion.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Pools Below Target',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...poolsNeedingExpansion.entries.map((entry) {
                    final pool = entry.key;
                    final sharesNeeded = entry.value;
                    final pendingExpansion = _pendingPoolExpansions
                        .where((e) => e.poolId == pool.id)
                        .fold<int>(0, (sum, e) => sum + e.sharesToAdd);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pool.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Target: ${pool.targetPercentage?.toStringAsFixed(1)}% • Need: +${Formatters.number(sharesNeeded)} shares',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (pendingExpansion > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${Formatters.number(pendingExpansion)}',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else
                            FilledButton.tonal(
                              onPressed: () => _addPoolExpansion(pool, sharesNeeded),
                              child: const Text('Top Up'),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Existing pools section
          if (pools.isNotEmpty) ...[
            Text(
              'Existing Pools',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...pools.map((pool) {
              final pendingExpansion = _pendingPoolExpansions
                  .where((e) => e.poolId == pool.id)
                  .fold<int>(0, (sum, e) => sum + e.sharesToAdd);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.groups_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(pool.name),
                  subtitle: Text(
                    '${Formatters.number(pool.poolSize)} shares${pendingExpansion > 0 ? ' (+${Formatters.number(pendingExpansion)} pending)' : ''}',
                  ),
                  trailing: pendingExpansion > 0
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                          onPressed: () => _removePoolExpansion(pool.id),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _showExpandPoolDialog(context, pool),
                        ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // New pools being created in this round
          if (_pendingNewPools.isNotEmpty) ...[
            Text(
              'New Pools (This Round)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._pendingNewPools.asMap().entries.map((entry) {
              final index = entry.key;
              final newPool = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      Icons.add,
                      color: Colors.green.shade800,
                    ),
                  ),
                  title: Text(newPool.name),
                  subtitle: Text(
                    '${Formatters.number(newPool.poolSize)} shares${newPool.targetPercentage != null ? ' • Target: ${newPool.targetPercentage!.toStringAsFixed(1)}%' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _pendingNewPools.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Empty state
          if (pools.isEmpty && _pendingNewPools.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ESOP Pools',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an employee option pool to reserve shares for future grants.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

          // Summary of ESOP changes
          if (_pendingPoolExpansions.isNotEmpty || _pendingNewPools.isNotEmpty) ...[
            const Divider(height: 32),
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
                    'ESOP Changes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '+${Formatters.number(_pendingPoolExpansions.fold<int>(0, (sum, e) => sum + e.sharesToAdd) + _pendingNewPools.fold<int>(0, (sum, p) => sum + p.poolSize))} shares',
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

  void _addPoolExpansion(EsopPool pool, int sharesToAdd) {
    setState(() {
      _pendingPoolExpansions.add(_PendingPoolExpansion(
        poolId: pool.id,
        poolName: pool.name,
        sharesToAdd: sharesToAdd,
      ));
    });
  }

  void _removePoolExpansion(String poolId) {
    setState(() {
      _pendingPoolExpansions.removeWhere((e) => e.poolId == poolId);
    });
  }

  void _showExpandPoolDialog(BuildContext context, EsopPool pool) {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Expand ${pool.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Shares to Add',
            hintText: 'Enter number of shares',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final shares = int.tryParse(controller.text);
              if (shares != null && shares > 0) {
                _addPoolExpansion(pool, shares);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showNewPoolDialog(BuildContext context, List<VestingSchedule> vestingSchedules) {
    final nameController = TextEditingController();
    final poolSizeController = TextEditingController();
    final targetPercentController = TextEditingController();
    String? selectedVestingScheduleId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create ESOP Pool'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pool Name *',
                    hintText: 'e.g., 2024 Employee Option Pool',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: poolSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pool Size (shares) *',
                    hintText: 'Total shares reserved',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetPercentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target % of Company',
                    hintText: 'Optional - e.g., 10',
                    suffixText: '%',
                  ),
                ),
                if (vestingSchedules.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedVestingScheduleId,
                    decoration: const InputDecoration(
                      labelText: 'Default Vesting Schedule',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None'),
                      ),
                      ...vestingSchedules.map(
                        (vs) => DropdownMenuItem(
                          value: vs.id,
                          child: Text(vs.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => selectedVestingScheduleId = v),
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
                final poolSize = int.tryParse(poolSizeController.text);
                if (nameController.text.isEmpty || poolSize == null || poolSize <= 0) {
                  return;
                }

                this.setState(() {
                  _pendingNewPools.add(_PendingNewPool(
                    name: nameController.text,
                    poolSize: poolSize,
                    targetPercentage: double.tryParse(targetPercentController.text),
                    defaultVestingScheduleId: selectedVestingScheduleId,
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 7: Summary ───────────────────────────────────────────────────────

  Widget _buildSummaryStep() {
    final theme = Theme.of(context);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);
    final convertiblesAsync = ref.watch(convertiblesStreamProvider);
    final warrantsAsync = ref.watch(warrantsStreamProvider);
    final holdingsAsync = ref.watch(holdingsStreamProvider);

    final stakeholders = stakeholdersAsync.valueOrNull ?? [];
    final convertibles = convertiblesAsync.valueOrNull ?? [];
    final warrants = warrantsAsync.valueOrNull ?? [];

    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final totalInvestment = _pendingInvestments.fold(
      0.0,
      (sum, inv) => sum + inv.amount,
    );
    final postMoneyVal = preMoneyVal + totalInvestment;

    // Calculate price per share for conversion calculations
    final pricePerShareOverride = double.tryParse(
      _pricePerShareController.text,
    );
    final totalShares =
        holdingsAsync.valueOrNull?.fold<int>(
          0,
          (sum, h) => sum + h.shareCount,
        ) ??
        0;
    final roundPricePerShare =
        pricePerShareOverride ??
        (totalShares > 0 ? preMoneyVal / totalShares : 0.0);

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
                  if (roundPricePerShare > 0)
                    _SummaryRow(
                      label: 'Price Per Share',
                      value: Formatters.currency(roundPricePerShare),
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

          // Convertibles summary with conversion details
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

              // Calculate conversion details
              final effectivePrice = totalShares > 0 && roundPricePerShare > 0
                  ? ConversionCalculator.effectivePrice(
                      convertible: conv,
                      roundPricePerShare: roundPricePerShare,
                      preMoneyShares: totalShares,
                    )
                  : roundPricePerShare;
              final totalValue = ConversionCalculator.totalValue(
                conv,
                asOf: _roundDate,
              );
              final sharesReceived = effectivePrice > 0
                  ? (totalValue / effectivePrice).floor()
                  : 0;

              // Determine which term was applied
              String termApplied = 'Round Price';
              if (conv.valuationCap != null &&
                  conv.discountPercent != null &&
                  totalShares > 0) {
                final capPrice = conv.valuationCap! / totalShares;
                final discountPrice =
                    roundPricePerShare * (1 - conv.discountPercent! / 100);
                if (capPrice < discountPrice) {
                  termApplied = 'Cap';
                } else {
                  termApplied = 'Discount';
                }
              } else if (conv.valuationCap != null && totalShares > 0) {
                termApplied = 'Cap';
              } else if (conv.discountPercent != null) {
                termApplied = 'Discount';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: conv.type == 'safe'
                                ? Colors.blue.shade100
                                : Colors.orange.shade100,
                            child: Icon(
                              conv.type == 'safe'
                                  ? Icons.security
                                  : Icons.receipt_long,
                              size: 14,
                              color: conv.type == 'safe'
                                  ? Colors.blue.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stakeholder?.name ?? 'Unknown',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              termApplied,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Principal',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              Text(Formatters.currency(conv.principal)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Eff. Price',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              Text(Formatters.currency(effectivePrice)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Shares',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              Text(
                                Formatters.compactNumber(sharesReceived),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (conv.valuationCap != null ||
                          conv.discountPercent != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (conv.valuationCap != null)
                              'Cap: ${Formatters.compactCurrency(conv.valuationCap!)}',
                            if (conv.discountPercent != null)
                              'Discount: ${conv.discountPercent!.toStringAsFixed(0)}%',
                          ].join(' • '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
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
      case 5: // ESOP - optional
        return true;
      case 6: // Summary
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

    final roundCommands = ref.read(roundCommandsProvider.notifier);
    final holdingCommands = ref.read(holdingCommandsProvider.notifier);
    final convertibleCommands = ref.read(convertibleCommandsProvider.notifier);
    final shareClassesAsync = ref.read(shareClassesStreamProvider);

    final preMoneyVal = double.tryParse(_preMoneyController.text) ?? 0;
    final pricePerShare = double.tryParse(_pricePerShareController.text);

    try {
      // Create or update the round
      final String roundId;
      if (isEditing) {
        roundId = widget.existingRound!.id;
        await roundCommands.amendRound(
          roundId: roundId,
          name: _nameController.text,
          type: _roundType,
          date: _roundDate,
          preMoneyValuation: preMoneyVal,
          pricePerShare: pricePerShare,
          leadInvestorId: _leadInvestorController.text.isEmpty
              ? null
              : _leadInvestorController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      } else {
        // Get current display order
        final roundsAsync = ref.read(roundsStreamProvider);
        final displayOrder = (roundsAsync.valueOrNull?.length ?? 0) + 1;

        roundId = await roundCommands.openRound(
          name: _nameController.text,
          type: _roundType,
          date: _roundDate,
          displayOrder: displayOrder,
          preMoneyValuation: preMoneyVal,
          pricePerShare: pricePerShare,
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
          pricePerShare ?? (totalShares > 0 ? preMoneyVal / totalShares : 0.0);

      // Create or update holdings
      for (final inv in _pendingInvestments) {
        if (inv.isExisting) {
          // TODO: Implement updateHolding in HoldingCommands
          // For now, we skip existing holdings as update is not yet supported
        } else {
          // Create new holding - use the investment's actual cost basis
          final costBasis = inv.shares > 0 ? inv.amount / inv.shares : pps;
          await holdingCommands.issueShares(
            stakeholderId: inv.stakeholderId,
            shareClassId: inv.shareClassId,
            shareCount: inv.shares,
            costBasis: costBasis,
            acquiredDate: _roundDate,
            vestingScheduleId: inv.vestingScheduleId,
            roundId: roundId,
          );
        }
      }

      // Link newly created convertibles to the round
      // TODO: Implement updateConvertible in ConvertibleCommands
      // For now, convertibles are issued with the roundId directly
      // for (final convId in _newlyCreatedConvertibleIds) {
      //   // Update to link to round
      // }

      // Link newly created warrants to the round
      // TODO: Implement updateWarrant in WarrantCommands
      // For now, warrants are issued with the roundId directly
      final warrantCommands = ref.read(warrantCommandsProvider.notifier);
      // for (final warrantId in _newlyCreatedWarrantIds) {
      //   // Update to link to round
      // }

      // Get share classes for warrant creation and conversions
      final shareClasses = shareClassesAsync.valueOrNull ?? [];
      final defaultShareClassId = shareClasses.isNotEmpty
          ? shareClasses.first.id
          : null;

      // Create warrants from warrant coverage on convertibles
      final convertiblesAsync = ref.read(convertiblesStreamProvider);
      final convertibles = convertiblesAsync.valueOrNull ?? [];
      for (final entry in _warrantCoveragePercents.entries) {
        final convId = entry.key;
        final coveragePercent = entry.value;
        if (coveragePercent <= 0) continue;

        final conv = convertibles.where((c) => c.id == convId).firstOrNull;
        if (conv == null) continue;

        // Calculate warrant shares: (principal / price) * coverage%
        final convShares = pps > 0 ? (conv.principal / pps).floor() : 0;
        final warrantShares = (convShares * coveragePercent / 100).floor();

        if (warrantShares > 0 && defaultShareClassId != null) {
          await warrantCommands.issueWarrant(
            stakeholderId: conv.stakeholderId,
            shareClassId: defaultShareClassId,
            quantity: warrantShares,
            strikePrice: pps,
            issueDate: _roundDate,
            expiryDate: _roundDate.add(const Duration(days: 365 * 10)),
            sourceConvertibleId: convId,
            roundId: roundId,
            notes:
                'Warrant coverage (${coveragePercent.toStringAsFixed(0)}%) from convertible',
          );
        }
      }

      // Convert selected convertibles using proper cap/discount math
      if (defaultShareClassId != null) {
        for (final convId in _selectedConvertibleIds) {
          final conv = convertibles.where((c) => c.id == convId).firstOrNull;
          if (conv == null) continue;

          // Calculate effective conversion price using cap and/or discount
          // ConversionCalculator returns the LOWER of cap-based price or discount-based price
          final effectivePrice = ConversionCalculator.effectivePrice(
            convertible: conv,
            roundPricePerShare: pps,
            preMoneyShares: totalShares,
          );

          // Calculate shares received: total value (principal + accrued interest) / effective price
          final sharesReceived = ConversionCalculator.sharesToReceive(
            convertible: conv,
            roundPricePerShare: pps,
            preMoneyShares: totalShares,
            asOf: _roundDate,
          );

          await convertibleCommands.convertConvertible(
            convertibleId: convId,
            roundId: roundId,
            toShareClassId: defaultShareClassId,
            sharesReceived: sharesReceived,
            conversionPrice: effectivePrice,
          );
        }
      }

      // Process ESOP pool expansions
      if (_pendingPoolExpansions.isNotEmpty) {
        final esopCommands = ref.read(esopPoolCommandsProvider.notifier);
        final pools = await ref.read(esopPoolsStreamProvider.future);

        for (final expansion in _pendingPoolExpansions) {
          // Find the current pool to get its current size
          final pool = pools.where((p) => p.id == expansion.poolId).firstOrNull;
          if (pool == null) continue;

          await esopCommands.expandPool(
            poolId: expansion.poolId,
            previousSize: pool.poolSize,
            newSize: pool.poolSize + expansion.sharesToAdd,
            sharesAdded: expansion.sharesToAdd,
            reason: 'Round expansion: ${_nameController.text}',
            resolutionReference: roundId,
          );
        }
      }

      // Create new ESOP pools (draft status tied to round)
      if (_pendingNewPools.isNotEmpty) {
        final esopCommands = ref.read(esopPoolCommandsProvider.notifier);

        for (final newPool in _pendingNewPools) {
          await esopCommands.createPool(
            name: newPool.name,
            poolSize: newPool.poolSize,
            targetPercentage: newPool.targetPercentage,
            establishedDate: _roundDate,
            defaultVestingScheduleId: newPool.defaultVestingScheduleId,
            roundId: roundId, // Links to round, starts as draft
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
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Issue Date',
                    suffixIcon: Icon(Icons.lock_outline, size: 18),
                  ),
                  child: Text(Formatters.date(issueDate)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date is set to match the round date',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: Theme.of(dialogContext).colorScheme.outline,
                  ),
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

                final commands = ref.read(convertibleCommandsProvider.notifier);
                final cap = double.tryParse(capController.text);
                final discount = double.tryParse(discountController.text);
                final interest = double.tryParse(interestController.text);

                final newId = await commands.issueConvertible(
                  stakeholderId: selectedStakeholderId!,
                  type: selectedType,
                  principal: principal,
                  issueDate: issueDate,
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
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Issue Date',
                    suffixIcon: Icon(Icons.lock_outline, size: 18),
                  ),
                  child: Text(Formatters.date(issueDate)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date is set to match the round date',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: Theme.of(dialogContext).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: expiryDate,
                      firstDate: issueDate,
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() => expiryDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(Formatters.date(expiryDate)),
                  ),
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

                final commands = ref.read(warrantCommandsProvider.notifier);

                final newId = await commands.issueWarrant(
                  stakeholderId: selectedStakeholderId!,
                  shareClassId: selectedShareClassId!,
                  quantity: quantity,
                  strikePrice: strike,
                  issueDate: issueDate,
                  expiryDate: expiryDate,
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

/// Helper class to track pending ESOP pool expansions
class _PendingPoolExpansion {
  final String poolId;
  final String poolName;
  final int sharesToAdd;

  const _PendingPoolExpansion({
    required this.poolId,
    required this.poolName,
    required this.sharesToAdd,
  });
}

/// Helper class to track new ESOP pools being created in this round
class _PendingNewPool {
  final String name;
  final int poolSize;
  final double? targetPercentage;
  final String? defaultVestingScheduleId;

  const _PendingNewPool({
    required this.name,
    required this.poolSize,
    this.targetPercentage,
    this.defaultVestingScheduleId,
  });
}

/// Helper class for pro-rata rights display
class _ProRataData {
  final Stakeholder stakeholder;
  final double ownershipPercent;
  final double proRataAmount;
  final bool isParticipating;
  final double participationAmount;

  const _ProRataData({
    required this.stakeholder,
    required this.ownershipPercent,
    required this.proRataAmount,
    required this.isParticipating,
    required this.participationAmount,
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
