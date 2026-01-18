import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page for managing employee stock options.
class OptionsPage extends ConsumerWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(optionGrantsStreamProvider);
    final summaryAsync = ref.watch(optionsSummaryProvider);
    final companyId = ref.watch(currentCompanyIdProvider);
    final stakeholders = ref.watch(stakeholdersStreamProvider);
    final shareClasses = ref.watch(shareClassesStreamProvider);
    final vestingSchedules = ref.watch(vestingSchedulesStreamProvider);
    final esopPools = ref.watch(esopPoolsStreamProvider);
    final deleteEnabled = ref.watch(deleteEnabledProvider).valueOrNull ?? false;
    final ownership = ref.watch(ownershipSummaryProvider).valueOrNull;
    final effectiveValuation = ref
        .watch(effectiveValuationProvider)
        .valueOrNull;

    // Calculate current share price for "in the money" display
    double? currentSharePrice;
    if (effectiveValuation != null && ownership != null) {
      final totalShares = ownership.totalIssuedShares;
      if (totalShares > 0) {
        currentSharePrice = effectiveValuation.value / totalShares;
      }
    }

    if (companyId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Stock Options'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const EmptyState(
          icon: Icons.business,
          title: 'No company selected',
          message: 'Please create or select a company first.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Options'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context, summaryAsync),
          Expanded(
            child: optionsAsync.when(
              data: (options) {
                if (options.isEmpty) {
                  return EmptyState.noItems(
                    itemType: 'option grant',
                    onAdd: () => _showAddDialog(
                      context,
                      ref,
                      companyId,
                      stakeholders.valueOrNull ?? [],
                      shareClasses.valueOrNull ?? [],
                      vestingSchedules.valueOrNull ?? [],
                      esopPools.valueOrNull ?? [],
                    ),
                  );
                }
                return _buildOptionsList(
                  context,
                  ref,
                  options,
                  stakeholders.valueOrNull ?? [],
                  shareClasses.valueOrNull ?? [],
                  vestingSchedules.valueOrNull ?? [],
                  esopPools.valueOrNull ?? [],
                  deleteEnabled,
                  currentSharePrice,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(optionGrantsStreamProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(
          context,
          ref,
          companyId,
          stakeholders.valueOrNull ?? [],
          shareClasses.valueOrNull ?? [],
          vestingSchedules.valueOrNull ?? [],
          esopPools.valueOrNull ?? [],
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<OptionsSummary> summaryAsync,
  ) {
    return PageHeader(
      title: 'Options',
      child: summaryAsync.when(
        data: (summary) => SummaryCardsRow(
          cards: [
            SummaryCard(
              label: 'Outstanding',
              value: Formatters.compactNumber(summary.outstandingOptions),
              icon: Icons.pending_actions,
              color: Colors.blue,
            ),
            SummaryCard(
              label: 'Vested',
              value: Formatters.compactNumber(summary.totalVested),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            if (summary.totalUnvested > 0)
              SummaryCard(
                label: 'Unvested',
                value: Formatters.compactNumber(summary.totalUnvested),
                icon: Icons.schedule,
                color: Colors.orange,
              ),
            if (summary.totalExercised > 0)
              SummaryCard(
                label: 'Exercised',
                value: Formatters.compactNumber(summary.totalExercised),
                icon: Icons.check_circle_outline,
                color: Colors.teal,
              ),
            SummaryCard(
              label: 'Active Grants',
              value: summary.activeGrants.toString(),
              icon: Icons.assignment_ind,
              color: Colors.purple,
            ),
          ],
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildOptionsList(
    BuildContext context,
    WidgetRef ref,
    List<OptionGrant> options,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
    List<EsopPool> esopPools,
    bool deleteEnabled,
    double? currentSharePrice,
  ) {
    // Calculate exercisable options
    final exercisableInfo = _calculateExercisableOptions(
      options,
      vestingSchedules,
    );

    return Column(
      children: [
        // Exercisable options notice
        if (exercisableInfo.totalExercisable > 0)
          CollapsibleNotice.action(
            persistKey: 'options_exercisable_notice',
            title: 'Options Ready to Exercise',
            count: exercisableInfo.grantsWithExercisable,
            message:
                '${exercisableInfo.totalExercisable} vested options across '
                '${exercisableInfo.grantsWithExercisable} grant(s) are ready to be exercised. '
                'Tap on a grant to view exercise options.',
          ),
        // Options list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return _buildOptionCard(
                context,
                ref,
                option,
                stakeholders,
                shareClasses,
                vestingSchedules,
                esopPools,
                deleteEnabled,
                currentSharePrice,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Calculate how many options are exercisable across all grants.
  _ExercisableInfo _calculateExercisableOptions(
    List<OptionGrant> options,
    List<VestingSchedule> vestingSchedules,
  ) {
    final scheduleMap = {for (final s in vestingSchedules) s.id: s};
    int totalExercisable = 0;
    int grantsWithExercisable = 0;

    for (final option in options) {
      // Skip non-active options
      final status = option.status;
      if (status != 'active' &&
          status != 'pending' &&
          status != 'partiallyExercised') {
        continue;
      }

      final schedule = option.vestingScheduleId != null
          ? scheduleMap[option.vestingScheduleId]
          : null;
      final vestingStatus = _calculateVestingStatus(option, schedule);

      // Exercisable = vested - already exercised
      final exercisable = vestingStatus.vestedQuantity - option.exercisedCount;
      if (exercisable > 0) {
        totalExercisable += exercisable;
        grantsWithExercisable++;
      }
    }

    return _ExercisableInfo(
      totalExercisable: totalExercisable,
      grantsWithExercisable: grantsWithExercisable,
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    WidgetRef ref,
    OptionGrant option,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
    List<EsopPool> esopPools,
    bool deleteEnabled,
    double? currentSharePrice,
  ) {
    final stakeholder = stakeholders.firstWhere(
      (s) => s.id == option.stakeholderId,
      orElse: () => Stakeholder(
        id: option.stakeholderId,
        companyId: option.companyId,
        name: 'Unknown',
        type: 'unknown',
        hasProRataRights: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final shareClass = shareClasses.firstWhere(
      (s) => s.id == option.shareClassId,
      orElse: () => ShareClassesData(
        id: option.shareClassId,
        companyId: option.companyId,
        name: 'Unknown',
        type: 'unknown',
        votingMultiplier: 1.0,
        liquidationPreference: 1.0,
        isParticipating: false,
        dividendRate: 0,
        seniority: 0,
        antiDilutionType: 'none',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final vestingSchedule = option.vestingScheduleId != null
        ? vestingSchedules
              .where((v) => v.id == option.vestingScheduleId)
              .firstOrNull
        : null;

    final outstanding =
        option.quantity - option.exercisedCount - option.cancelledCount;

    // Calculate vesting status
    final vestingStatus = _calculateVestingStatus(option, vestingSchedule);

    return ExpandableCard(
      leading: EntityAvatar(
        name: stakeholder.name,
        type: EntityAvatarType.person,
        size: 40,
      ),
      title: stakeholder.name,
      subtitle:
          '${Formatters.number(option.quantity)} options @ ${Formatters.currency(option.strikePrice)}',
      badges: [
        StatusBadge(
          label: _formatStatus(option.status),
          color: _getStatusColor(option.status),
        ),
        VestingChip(
          vestedPercent: vestingStatus.vestingPercent,
          isCliffMet: vestingStatus.isCliffMet,
        ),
      ],
      chips: [
        MetricChip(
          label: 'Vested',
          value: Formatters.compactNumber(vestingStatus.vestedQuantity),
          color: Colors.green,
        ),
        if (vestingStatus.unvestedQuantity > 0)
          MetricChip(
            label: 'Unvested',
            value: Formatters.compactNumber(vestingStatus.unvestedQuantity),
            color: Colors.orange,
          ),
        if (option.exercisedCount > 0)
          MetricChip(
            label: 'Exercised',
            value: Formatters.compactNumber(option.exercisedCount),
            color: Colors.teal,
          ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vesting progress bar
          if (vestingSchedule != null) ...[
            VestingProgressBar(
              vestedPercent: vestingStatus.vestingPercent,
              vestedQuantity: vestingStatus.vestedQuantity,
              totalQuantity: outstanding,
              cliffDate: vestingStatus.cliffDate,
              isCliffMet: vestingStatus.isCliffMet,
              vestingEndDate: vestingStatus.vestingEndDate,
              nextVestingDate: vestingStatus.nextVestingDate,
              nextVestingQuantity: vestingStatus.nextVestingQuantity,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
          ],
          _buildDetailRow('Grantee', stakeholder.name),
          _buildDetailRow('Share Class', shareClass.name),
          if (option.esopPoolId != null)
            _buildDetailRow(
              'ESOP Pool',
              esopPools
                      .where((p) => p.id == option.esopPoolId)
                      .firstOrNull
                      ?.name ??
                  'Unknown',
            ),
          _buildDetailRow('Quantity', Formatters.number(option.quantity)),
          _buildDetailRow(
            'Strike Price',
            Formatters.currency(option.strikePrice),
          ),
          _buildDetailRow('Grant Date', Formatters.date(option.grantDate)),
          _buildDetailRow('Expiry Date', Formatters.date(option.expiryDate)),
          if (vestingSchedule != null)
            _buildDetailRow('Vesting', vestingSchedule.name),
          _buildDetailRow(
            'Exercised',
            Formatters.number(option.exercisedCount),
          ),
          _buildDetailRow(
            'Cancelled',
            Formatters.number(option.cancelledCount),
          ),
          _buildDetailRow('Outstanding', Formatters.number(outstanding)),
          if (option.allowsEarlyExercise)
            _buildDetailRow('Early Exercise', 'Allowed'),
          if (option.notes != null && option.notes!.isNotEmpty)
            _buildDetailRow('Notes', option.notes!),

          // In the Money section
          if (currentSharePrice != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildInTheMoneySection(
              context,
              option.strikePrice,
              currentSharePrice,
              outstanding,
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditDialog(
            context,
            ref,
            option,
            stakeholders,
            shareClasses,
            vestingSchedules,
            esopPools,
          ),
          tooltip: 'Edit',
        ),
        // Exercise button - only show if:
        // 1. Outstanding options > 0 and status is active, AND
        // 2. Either allowsEarlyExercise is true OR options are fully vested
        if (outstanding > 0 &&
            option.status == 'active' &&
            (option.allowsEarlyExercise ||
                vestingStatus.vestingPercent >= 100 ||
                vestingSchedule == null))
          IconButton(
            icon: const Icon(Icons.play_arrow_outlined),
            onPressed: () => _showExerciseDialog(
              context,
              ref,
              option,
              vestingStatus.vestedQuantity - option.exercisedCount,
            ),
            tooltip: 'Exercise',
          ),
        if (option.exercisedCount > 0)
          IconButton(
            icon: const Icon(Icons.undo_outlined),
            onPressed: () => _showUnexerciseDialog(context, ref, option),
            tooltip: 'Undo Exercise',
          ),
        if (outstanding > 0 && option.status == 'active')
          IconButton(
            icon: Icon(
              Icons.cancel_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _confirmCancel(context, ref, option),
            tooltip: 'Cancel',
          ),
        if (deleteEnabled)
          IconButton(
            icon: Icon(
              Icons.delete_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _confirmDelete(context, ref, option),
            tooltip: 'Delete',
          ),
      ],
    );
  }

  /// Calculate vesting status locally (without provider for performance).
  _VestingStatusLocal _calculateVestingStatus(
    OptionGrant option,
    VestingSchedule? schedule,
  ) {
    final outstanding =
        option.quantity - option.exercisedCount - option.cancelledCount;
    final now = DateTime.now();
    final grantDate = option.grantDate;

    if (schedule == null) {
      // No schedule = immediate vesting
      return _VestingStatusLocal(
        vestedQuantity: outstanding,
        unvestedQuantity: 0,
        vestingPercent: 100.0,
        isCliffMet: true,
        cliffDate: null,
        vestingEndDate: grantDate,
        nextVestingDate: null,
        nextVestingQuantity: 0,
      );
    }

    final totalMonths = schedule.totalMonths ?? 0;
    final cliffMonths = schedule.cliffMonths;
    final frequencyStr = schedule.frequency ?? 'monthly';
    final monthsPerTranche = frequencyStr == 'quarterly'
        ? 3
        : (frequencyStr == 'annually' ? 12 : 1);

    // Calculate months elapsed
    final monthsElapsed =
        (now.year - grantDate.year) * 12 + (now.month - grantDate.month);

    // Cliff date
    final cliffDate = cliffMonths > 0
        ? DateTime(grantDate.year, grantDate.month + cliffMonths, grantDate.day)
        : null;
    final isCliffMet = cliffDate == null || now.isAfter(cliffDate);

    // Vesting end date
    final vestingEndDate = DateTime(
      grantDate.year,
      grantDate.month + totalMonths,
      grantDate.day,
    );

    // Calculate vesting percent
    double vestingPercent;
    if (schedule.type == 'immediate') {
      vestingPercent = 100.0;
    } else if (totalMonths == 0) {
      vestingPercent = 100.0;
    } else if (monthsElapsed < cliffMonths) {
      vestingPercent = 0.0;
    } else if (monthsElapsed >= totalMonths) {
      vestingPercent = 100.0;
    } else {
      // Tranched vesting
      final tranchesVested = monthsElapsed ~/ monthsPerTranche;
      final totalTranches = totalMonths ~/ monthsPerTranche;
      vestingPercent = totalTranches > 0
          ? (tranchesVested / totalTranches) * 100
          : 100.0;
    }

    final vestedQty = (outstanding * vestingPercent / 100).floor();
    final unvestedQty = outstanding - vestedQty;

    // Calculate next vesting date
    DateTime? nextVestingDate;
    int nextVestingQuantity = 0;
    if (vestingPercent < 100) {
      if (!isCliffMet && cliffDate != null) {
        nextVestingDate = cliffDate;
        final cliffPercent = (cliffMonths / totalMonths) * 100;
        nextVestingQuantity = (outstanding * cliffPercent / 100).floor();
      } else {
        final nextTranche =
            ((monthsElapsed ~/ monthsPerTranche) + 1) * monthsPerTranche;
        if (nextTranche <= totalMonths) {
          nextVestingDate = DateTime(
            grantDate.year,
            grantDate.month + nextTranche,
            grantDate.day,
          );
          final nextPercent = (nextTranche / totalMonths) * 100;
          final nextVestedTotal = (outstanding * nextPercent / 100).floor();
          nextVestingQuantity = nextVestedTotal - vestedQty;
        }
      }
    }

    return _VestingStatusLocal(
      vestedQuantity: vestedQty,
      unvestedQuantity: unvestedQty,
      vestingPercent: vestingPercent,
      isCliffMet: isCliffMet,
      cliffDate: cliffDate,
      vestingEndDate: vestingEndDate,
      nextVestingDate: nextVestingDate,
      nextVestingQuantity: nextVestingQuantity,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildInTheMoneySection(
    BuildContext context,
    double strikePrice,
    double currentSharePrice,
    int outstanding,
  ) {
    final isInTheMoney = currentSharePrice > strikePrice;
    final intrinsicValue = isInTheMoney
        ? (currentSharePrice - strikePrice) * outstanding
        : 0.0;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isInTheMoney
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInTheMoney
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isInTheMoney ? Icons.trending_up : Icons.trending_flat,
            color: isInTheMoney ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInTheMoney ? 'In The Money' : 'Out of Money',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isInTheMoney ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  'FMV: ${Formatters.currency(currentSharePrice)} vs Strike: ${Formatters.currency(strikePrice)}',
                  style: theme.textTheme.bodySmall,
                ),
                if (isInTheMoney)
                  Text(
                    'Intrinsic value: ${Formatters.currency(intrinsicValue)}',
                    style: theme.textTheme.bodySmall?.copyWith(
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

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'active':
        return Colors.green;
      case 'exercised':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
    List<EsopPool> esopPools,
  ) {
    _showOptionDialog(
      context,
      ref,
      companyId: companyId,
      stakeholders: stakeholders,
      shareClasses: shareClasses,
      vestingSchedules: vestingSchedules,
      esopPools: esopPools,
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    OptionGrant option,
    List<Stakeholder> stakeholders,
    List<ShareClassesData> shareClasses,
    List<VestingSchedule> vestingSchedules,
    List<EsopPool> esopPools,
  ) {
    _showOptionDialog(
      context,
      ref,
      option: option,
      stakeholders: stakeholders,
      shareClasses: shareClasses,
      vestingSchedules: vestingSchedules,
      esopPools: esopPools,
    );
  }

  void _showOptionDialog(
    BuildContext context,
    WidgetRef ref, {
    String? companyId,
    OptionGrant? option,
    required List<Stakeholder> stakeholders,
    required List<ShareClassesData> shareClasses,
    required List<VestingSchedule> vestingSchedules,
    required List<EsopPool> esopPools,
  }) {
    final isEditing = option != null;
    final quantityController = TextEditingController(
      text: option?.quantity.toString() ?? '',
    );
    final strikeController = TextEditingController(
      text: option?.strikePrice.toString() ?? '',
    );
    final notesController = TextEditingController(text: option?.notes ?? '');

    String? selectedStakeholderId = option?.stakeholderId;
    String? selectedShareClassId = option?.shareClassId;
    String? selectedVestingScheduleId = option?.vestingScheduleId;
    String? selectedEsopPoolId = option?.esopPoolId;
    DateTime grantDate = option?.grantDate ?? DateTime.now();
    DateTime expiryDate =
        option?.expiryDate ??
        DateTime.now().add(const Duration(days: 365 * 10));
    bool allowsEarlyExercise = option?.allowsEarlyExercise ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Option Grant' : 'New Option Grant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStakeholderId,
                  decoration: const InputDecoration(labelText: 'Grantee'),
                  items: stakeholders
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: isEditing
                      ? null
                      : (v) => setDialogState(() => selectedStakeholderId = v),
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
                DropdownButtonFormField<String?>(
                  value: selectedVestingScheduleId,
                  decoration: const InputDecoration(
                    labelText: 'Vesting Schedule',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Immediate (no vesting)'),
                    ),
                    ...vestingSchedules.map(
                      (v) => DropdownMenuItem(value: v.id, child: Text(v.name)),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedVestingScheduleId = v),
                ),
                if (vestingSchedules.isEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showCreateVestingScheduleDialog(
                      context,
                      ref,
                      companyId ?? option?.companyId ?? '',
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create vesting schedule'),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: selectedEsopPoolId,
                  decoration: const InputDecoration(
                    labelText: 'ESOP Pool (Optional)',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...esopPools.map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selectedEsopPoolId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Options',
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
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: grantDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setDialogState(() {
                        grantDate = date;
                        // If expiry is before grant, adjust it
                        if (expiryDate.isBefore(grantDate)) {
                          expiryDate = grantDate.add(
                            const Duration(days: 365 * 10),
                          );
                        }
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Grant Date',
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(Formatters.date(grantDate)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: expiryDate,
                      firstDate: grantDate,
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
                CheckboxListTile(
                  title: const Text('Allow Early Exercise'),
                  value: allowsEarlyExercise,
                  onChanged: (v) =>
                      setDialogState(() => allowsEarlyExercise = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
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
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text);
                final strike = double.tryParse(strikeController.text);
                if (quantity == null || quantity <= 0) return;
                if (strike == null || strike <= 0) return;
                if (!isEditing && selectedStakeholderId == null) return;
                if (selectedShareClassId == null) return;

                final commands = ref.read(optionGrantCommandsProvider.notifier);

                if (isEditing) {
                  await commands.updateOptionGrant(
                    grantId: option!.id,
                    shareClassId: selectedShareClassId,
                    esopPoolId: selectedEsopPoolId,
                    quantity: quantity,
                    strikePrice: strike,
                    grantDate: grantDate,
                    expiryDate: expiryDate,
                    vestingScheduleId: selectedVestingScheduleId,
                    allowsEarlyExercise: allowsEarlyExercise,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                } else {
                  await commands.grantOptions(
                    stakeholderId: selectedStakeholderId!,
                    shareClassId: selectedShareClassId!,
                    vestingScheduleId: selectedVestingScheduleId,
                    esopPoolId: selectedEsopPoolId,
                    quantity: quantity,
                    strikePrice: strike,
                    grantDate: grantDate,
                    expiryDate: expiryDate,
                    allowsEarlyExercise: allowsEarlyExercise,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExerciseDialog(
    BuildContext context,
    WidgetRef ref,
    OptionGrant option,
    int maxShares,
  ) async {
    if (maxShares <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No vested options available to exercise'),
        ),
      );
      return;
    }

    // Get stakeholder name
    final stakeholders = ref.read(stakeholdersStreamProvider).valueOrNull ?? [];
    final stakeholder = stakeholders
        .where((s) => s.id == option.stakeholderId)
        .firstOrNull;

    await ExerciseOptionsDialog.show(
      context: context,
      option: option,
      maxExercisable: maxShares,
      stakeholderName: stakeholder?.name,
    );
  }

  void _showUnexerciseDialog(
    BuildContext context,
    WidgetRef ref,
    OptionGrant option,
  ) {
    final sharesController = TextEditingController();
    final maxShares = option.exercisedCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revert up to ${Formatters.number(maxShares)} exercised options',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sharesController,
              decoration: const InputDecoration(
                labelText: 'Options to Unexercise',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    size: 18,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will revert exercised options back to outstanding. Use this to correct mistakes.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              final shares = int.tryParse(sharesController.text);
              if (shares == null || shares <= 0 || shares > maxShares) return;

              // TODO: Implement unexercise in OptionGrantCommands
              // The current commands only have exerciseOptions and cancelOptions
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unexercise not yet implemented')),
              );

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Undo Exercise'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    OptionGrant option,
  ) async {
    final outstanding =
        option.quantity - option.exercisedCount - option.cancelledCount;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Cancel Options',
      message:
          'Are you sure you want to cancel the remaining $outstanding option(s)? This will record a cancellation event.',
      confirmLabel: 'Cancel Options',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref
          .read(optionGrantCommandsProvider.notifier)
          .cancelOptions(
            grantId: option.id,
            cancelledCount: outstanding,
            reason: 'Cancelled by user',
          );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    OptionGrant option,
  ) async {
    // Preview cascade impact
    final cascadeImpact = await ref
        .read(eventLedgerProvider.notifier)
        .previewCascadeDelete(
          entityId: option.id,
          entityType: EntityType.optionGrant,
        );

    final impactLines = <String>[];
    cascadeImpact.forEach((type, count) {
      if (count > 0) {
        impactLines.add('• $count ${type.name}(s)');
      }
    });

    String message;
    if (impactLines.isEmpty) {
      message = option.exercisedCount > 0
          ? 'Warning: ${option.exercisedCount} options have already been exercised. This cannot be undone.'
          : 'Are you sure you want to permanently delete this option grant? This cannot be undone.';
    } else {
      message = 'This will permanently delete:\n${impactLines.join('\n')}\n\n';
      if (option.exercisedCount > 0) {
        message +=
            'Warning: ${option.exercisedCount} options have already been exercised.\n';
      }
      message += 'This cannot be undone.';
    }

    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: 'option grant',
      customMessage: message,
    );

    if (confirmed && context.mounted) {
      await ref
          .read(optionGrantCommandsProvider.notifier)
          .deleteOptionGrant(grantId: option.id);
    }
  }

  void _showCreateVestingScheduleDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Vesting Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a template:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('4 Year / 1 Year Cliff'),
              subtitle: const Text('Standard startup vesting'),
              onTap: () async {
                await ref
                    .read(vestingScheduleCommandsProvider.notifier)
                    .createStandard4YearSchedule();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('3 Year / Monthly'),
              subtitle: const Text('No cliff, monthly vesting'),
              onTap: () async {
                await ref
                    .read(vestingScheduleCommandsProvider.notifier)
                    .create3YearNoCliffSchedule();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Local vesting status for UI calculations (avoids provider lookups per card).
class _VestingStatusLocal {
  final int vestedQuantity;
  final int unvestedQuantity;
  final double vestingPercent;
  final bool isCliffMet;
  final DateTime? cliffDate;
  final DateTime vestingEndDate;
  final DateTime? nextVestingDate;
  final int nextVestingQuantity;

  const _VestingStatusLocal({
    required this.vestedQuantity,
    required this.unvestedQuantity,
    required this.vestingPercent,
    required this.isCliffMet,
    required this.cliffDate,
    required this.vestingEndDate,
    required this.nextVestingDate,
    required this.nextVestingQuantity,
  });
}

/// Information about exercisable options across all grants.
class _ExercisableInfo {
  final int totalExercisable;
  final int grantsWithExercisable;

  const _ExercisableInfo({
    required this.totalExercisable,
    required this.grantsWithExercisable,
  });
}
