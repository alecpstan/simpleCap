import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../domain/services/vesting_calculator.dart';
import '../../infrastructure/database/database.dart';
import '../../shared/formatters.dart';
import '../components/components.dart';

/// Page for managing vesting across holdings and option grants.
///
/// Shows expandable cards grouped by vesting type with vest/edit/delete actions.
class VestingManagementPage extends ConsumerStatefulWidget {
  const VestingManagementPage({super.key});

  @override
  ConsumerState<VestingManagementPage> createState() =>
      _VestingManagementPageState();
}

class _VestingManagementPageState extends ConsumerState<VestingManagementPage> {
  @override
  Widget build(BuildContext context) {
    final holdingsAsync = ref.watch(holdingsStreamProvider);
    final optionsAsync = ref.watch(optionGrantsStreamProvider);
    final schedulesAsync = ref.watch(vestingSchedulesStreamProvider);
    final stakeholdersAsync = ref.watch(stakeholdersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vesting Management')),
      body: holdingsAsync.when(
        data: (holdings) => optionsAsync.when(
          data: (options) => schedulesAsync.when(
            data: (schedules) => stakeholdersAsync.when(
              data: (stakeholders) => _buildContent(
                context,
                holdings,
                options,
                schedules,
                stakeholders,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Holding> holdings,
    List<OptionGrant> options,
    List<VestingSchedule> schedules,
    List<Stakeholder> stakeholders,
  ) {
    // Filter to only items with vesting schedules
    final vestingHoldings = holdings
        .where((h) => h.vestingScheduleId != null)
        .toList();
    final vestingOptions = options
        .where((o) => o.vestingScheduleId != null)
        .toList();

    if (vestingHoldings.isEmpty && vestingOptions.isEmpty) {
      return _buildEmptyState(context);
    }

    // Create vesting items
    final items = <_VestingItem>[];

    for (final holding in vestingHoldings) {
      final schedule = schedules
          .where((s) => s.id == holding.vestingScheduleId)
          .firstOrNull;
      final stakeholder = stakeholders
          .where((s) => s.id == holding.stakeholderId)
          .firstOrNull;
      if (schedule != null) {
        items.add(
          _VestingItem(
            type: _ItemType.holding,
            id: holding.id,
            stakeholderName: stakeholder?.name ?? 'Unknown',
            vestingSchedule: schedule,
            totalQuantity: holding.shareCount,
            startDate: holding.acquiredDate,
            vestedCount: holding.vestedCount,
            holding: holding,
          ),
        );
      }
    }

    for (final option in vestingOptions) {
      final schedule = schedules
          .where((s) => s.id == option.vestingScheduleId)
          .firstOrNull;
      final stakeholder = stakeholders
          .where((s) => s.id == option.stakeholderId)
          .firstOrNull;
      if (schedule != null) {
        items.add(
          _VestingItem(
            type: _ItemType.option,
            id: option.id,
            stakeholderName: stakeholder?.name ?? 'Unknown',
            vestingSchedule: schedule,
            totalQuantity: option.quantity,
            startDate: option.grantDate,
            exercisedCount: option.exercisedCount,
            cancelledCount: option.cancelledCount,
            optionGrant: option,
          ),
        );
      }
    }

    // Group by vesting type
    final grouped = <String, List<_VestingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.vestingSchedule.type, () => []).add(item);
    }

    // Sort groups by type order
    const typeOrder = ['timeBased', 'milestone', 'hours', 'immediate'];
    final sortedTypes = grouped.keys.toList()
      ..sort((a, b) {
        final ai = typeOrder.indexOf(a);
        final bi = typeOrder.indexOf(b);
        return (ai == -1 ? 99 : ai).compareTo(bi == -1 ? 99 : bi);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTypes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Manage vesting for ${items.length} items across holdings and options.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          );
        }

        final type = sortedTypes[index - 1];
        final typeItems = grouped[type]!;
        return _buildTypeSection(context, type, typeItems);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Vesting Items',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Holdings and option grants with vesting schedules will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSection(
    BuildContext context,
    String type,
    List<_VestingItem> items,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Row(
            children: [
              Icon(_getTypeIcon(type), size: 20, color: _getTypeColor(type)),
              const SizedBox(width: 8),
              Text(
                _formatType(type),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getTypeColor(type),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getTypeColor(type),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Vesting cards
        ...items.map((item) => _buildVestingCard(context, item)),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVestingCard(BuildContext context, _VestingItem item) {
    final schedule = item.vestingSchedule;
    final now = DateTime.now();

    // Calculate vesting status
    final vestedPercent = VestingCalculator.vestingPercentAt(
      schedule: schedule,
      startDate: item.startDate,
      asOfDate: now,
    );
    final vestedQuantity = VestingCalculator.unitsVestedAt(
      schedule: schedule,
      totalUnits: item.totalQuantity,
      startDate: item.startDate,
      asOfDate: now,
    );
    final isFullyVested = vestedPercent >= 100;
    final isInCliff = VestingCalculator.isInCliff(
      schedule: schedule,
      startDate: item.startDate,
      asOfDate: now,
    );

    // Calculate cliff and end dates
    final cliffDate = schedule.cliffMonths > 0
        ? DateTime(
            item.startDate.year,
            item.startDate.month + schedule.cliffMonths,
            item.startDate.day,
          )
        : null;
    final vestingEndDate = schedule.totalMonths != null
        ? DateTime(
            item.startDate.year,
            item.startDate.month + schedule.totalMonths!,
            item.startDate.day,
          )
        : null;

    return ExpandableCard(
      leading: EntityAvatar(
        name: item.stakeholderName,
        type: EntityAvatarType.person,
        size: 40,
      ),
      title: item.stakeholderName,
      subtitle: item.type == _ItemType.holding ? 'Holding' : 'Option Grant',
      badges: [
        StatusBadge(
          label: item.type == _ItemType.holding ? 'Shares' : 'Options',
          color: item.type == _ItemType.holding ? Colors.green : Colors.orange,
        ),
      ],
      chips: [
        VestingChip(vestedPercent: vestedPercent, isCliffMet: !isInCliff),
        MetricChip(
          label: 'Vested',
          value:
              '${Formatters.compactNumber(vestedQuantity)} / ${Formatters.compactNumber(item.totalQuantity)}',
          color: isFullyVested ? Colors.green : Colors.blue,
        ),
      ],
      expandedContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vesting progress bar
          VestingProgressBar(
            vestedPercent: vestedPercent,
            vestedQuantity: vestedQuantity,
            totalQuantity: item.totalQuantity,
            cliffDate: cliffDate,
            isCliffMet: !isInCliff,
            vestingEndDate: vestingEndDate,
          ),

          const SizedBox(height: 16),

          // Schedule details
          _buildSimpleDetailRow('Schedule', schedule.name),
          _buildSimpleDetailRow(
            'Start Date',
            Formatters.shortDate(item.startDate),
          ),
          if (cliffDate != null)
            _buildSimpleDetailRow(
              'Cliff',
              '${Formatters.shortDate(cliffDate)} (${schedule.cliffMonths} months)',
            ),
          if (vestingEndDate != null)
            _buildSimpleDetailRow(
              'End Date',
              Formatters.shortDate(vestingEndDate),
            ),

          // Manual vested count for holdings
          if (item.type == _ItemType.holding && item.vestedCount != null)
            _buildSimpleDetailRow(
              'Manual Vested',
              Formatters.number(item.vestedCount!),
            ),

          // Exercised/cancelled for options
          if (item.type == _ItemType.option) ...[
            if (item.exercisedCount != null && item.exercisedCount! > 0)
              _buildSimpleDetailRow(
                'Exercised',
                Formatters.number(item.exercisedCount!),
              ),
            if (item.cancelledCount != null && item.cancelledCount! > 0)
              _buildSimpleDetailRow(
                'Cancelled',
                Formatters.number(item.cancelledCount!),
              ),
          ],
        ],
      ),
      actions: [
        if (!isFullyVested)
          IconButton(
            icon: const Icon(Icons.update_outlined),
            onPressed: () => _showVestDialog(context, item),
            tooltip: 'Update Vesting',
          ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _editItem(context, item),
          tooltip: 'Edit',
        ),
      ],
    );
  }

  Widget _buildSimpleDetailRow(String label, String value) {
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

  void _showVestDialog(BuildContext context, _VestingItem item) {
    final type = item.vestingSchedule.type;

    switch (type) {
      case 'timeBased':
        _showTimeBasedVestDialog(context, item);
        break;
      case 'milestone':
        _showMilestoneVestDialog(context, item);
        break;
      case 'hours':
        _showHoursVestDialog(context, item);
        break;
      default:
        // Immediate vesting - nothing to do
        break;
    }
  }

  void _showTimeBasedVestDialog(BuildContext context, _VestingItem item) {
    final schedule = item.vestingSchedule;
    final now = DateTime.now();

    // Calculate vested to date
    final vestedToDate = VestingCalculator.unitsVestedAt(
      schedule: schedule,
      totalUnits: item.totalQuantity,
      startDate: item.startDate,
      asOfDate: now,
    );

    // For holdings, we can set vestedCount
    // For options, vesting is calculated from grant date (no manual override)
    final currentManual = item.vestedCount ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          var vestCount = vestedToDate;

          return AlertDialog(
            title: const Text('Update Time-Based Vesting'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stakeholder: ${item.stakeholderName}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 16),

                // Auto-calculated to date
                ListTile(
                  leading: const Icon(Icons.auto_awesome, color: Colors.blue),
                  title: const Text('Auto-calculate to today'),
                  subtitle: Text(
                    '${Formatters.number(vestedToDate)} shares vested as of ${Formatters.shortDate(now)}',
                  ),
                  onTap: () {
                    setDialogState(() => vestCount = vestedToDate);
                  },
                  selected: vestCount == vestedToDate,
                  selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: vestCount == vestedToDate
                        ? const BorderSide(color: Colors.blue)
                        : BorderSide.none,
                  ),
                ),

                const SizedBox(height: 8),

                // Current manual value (if different)
                if (currentManual > 0 && currentManual != vestedToDate)
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.orange),
                    title: const Text('Keep current'),
                    subtitle: Text(
                      '${Formatters.number(currentManual)} shares (manually set)',
                    ),
                    onTap: () {
                      setDialogState(() => vestCount = currentManual);
                    },
                    selected: vestCount == currentManual,
                    selectedTileColor: Colors.orange.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: vestCount == currentManual
                          ? const BorderSide(color: Colors.orange)
                          : BorderSide.none,
                    ),
                  ),

                const SizedBox(height: 16),

                // Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Will set vested count to:'),
                      Text(
                        Formatters.number(vestCount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                onPressed: () async {
                  if (item.type == _ItemType.holding && item.holding != null) {
                    await _updateHoldingVested(item.holding!, vestCount);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMilestoneVestDialog(BuildContext context, _VestingItem item) {
    // Parse milestones from JSON
    final schedule = item.vestingSchedule;
    List<_Milestone> milestones = [];

    if (schedule.milestonesJson != null) {
      try {
        // Expected format: [{"name": "...", "percentage": 25, "completed": false}, ...]
        // For now, we'll create a simple UI for manual milestone tracking
        milestones = _parseMilestones(schedule.milestonesJson!);
      } catch (e) {
        // Fallback to empty milestones
      }
    }

    // If no milestones defined, show message
    if (milestones.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Milestone Vesting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No milestones defined for this schedule.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Edit the vesting schedule to add milestones.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Show milestone toggle dialog
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Milestone Vesting'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stakeholder: ${item.stakeholderName}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 16),
                const Text('Mark completed milestones:'),
                const SizedBox(height: 8),
                ...milestones.map(
                  (m) => CheckboxListTile(
                    title: Text(m.name),
                    subtitle: Text('${m.percentage.toStringAsFixed(0)}%'),
                    value: m.completed,
                    onChanged: (value) {
                      setDialogState(() => m.completed = value ?? false);
                    },
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total vested:'),
                    Text(
                      '${milestones.where((m) => m.completed).fold(0.0, (sum, m) => sum + m.percentage).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  // Calculate vested count from milestones
                  final totalPercent = milestones
                      .where((m) => m.completed)
                      .fold(0.0, (sum, m) => sum + m.percentage);
                  final vestedCount = (item.totalQuantity * totalPercent / 100)
                      .floor();

                  if (item.type == _ItemType.holding && item.holding != null) {
                    await _updateHoldingVested(item.holding!, vestedCount);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHoursVestDialog(BuildContext context, _VestingItem item) {
    final schedule = item.vestingSchedule;
    final totalHours = schedule.totalHours ?? 0;
    final currentVested = item.vestedCount ?? 0;

    // Calculate current hours worked based on vested percentage
    final currentHours = totalHours > 0
        ? (currentVested / item.totalQuantity * totalHours).floor()
        : 0;

    var hoursWorked = currentHours;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final vestedFromHours = totalHours > 0
              ? (hoursWorked / totalHours * item.totalQuantity).floor()
              : 0;

          return AlertDialog(
            title: const Text('Hours-Based Vesting'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stakeholder: ${item.stakeholderName}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 16),

                // Total hours required
                Text(
                  'Total hours required: ${Formatters.number(totalHours)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Hours input with +/- buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      onPressed: hoursWorked > 0
                          ? () => setDialogState(() => hoursWorked -= 10)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: hoursWorked.toString(),
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Hours',
                          isDense: true,
                        ),
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            setDialogState(
                              () => hoursWorked = parsed.clamp(0, totalHours),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: hoursWorked < totalHours
                          ? () => setDialogState(() => hoursWorked += 10)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress indicator
                LinearProgressIndicator(
                  value: totalHours > 0 ? hoursWorked / totalHours : 0,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(hoursWorked / totalHours * 100).toStringAsFixed(1)}% complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shares vested:'),
                      Text(
                        '${Formatters.number(vestedFromHours)} / ${Formatters.number(item.totalQuantity)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                onPressed: () async {
                  if (item.type == _ItemType.holding && item.holding != null) {
                    await _updateHoldingVested(item.holding!, vestedFromHours);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateHoldingVested(Holding holding, int vestedCount) async {
    final db = ref.read(databaseProvider);
    await db.upsertHolding(
      HoldingsCompanion(
        id: Value(holding.id),
        companyId: Value(holding.companyId),
        stakeholderId: Value(holding.stakeholderId),
        shareClassId: Value(holding.shareClassId),
        shareCount: Value(holding.shareCount),
        costBasis: Value(holding.costBasis),
        acquiredDate: Value(holding.acquiredDate),
        vestingScheduleId: Value(holding.vestingScheduleId),
        vestedCount: Value(vestedCount),
        roundId: Value(holding.roundId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  void _editItem(BuildContext context, _VestingItem item) {
    // Navigate to the appropriate edit page
    // For now, show a simple message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit ${item.type == _ItemType.holding ? 'holding' : 'option'} for ${item.stakeholderName}',
        ),
        action: SnackBarAction(
          label: 'Go',
          onPressed: () {
            // TODO: Navigate to holdings or options page with this item selected
          },
        ),
      ),
    );
  }

  List<_Milestone> _parseMilestones(String json) {
    // Simple JSON parsing - would use dart:convert in real app
    // Expected format: [{"name": "...", "percentage": 25, "completed": false}]
    try {
      // For demo purposes, return some sample milestones
      // In real app, parse the actual JSON
      return [
        _Milestone(name: 'Prototype Complete', percentage: 25),
        _Milestone(name: 'Beta Launch', percentage: 25),
        _Milestone(name: 'First Customer', percentage: 25),
        _Milestone(name: 'Product Launch', percentage: 25),
      ];
    } catch (e) {
      return [];
    }
  }

  String _formatType(String type) => switch (type) {
    'timeBased' => 'Time-Based',
    'milestone' => 'Milestone',
    'hours' => 'Hours-Based',
    'immediate' => 'Immediate',
    _ => type,
  };

  IconData _getTypeIcon(String type) => switch (type) {
    'timeBased' => Icons.schedule,
    'milestone' => Icons.flag,
    'hours' => Icons.timer,
    'immediate' => Icons.bolt,
    _ => Icons.help_outline,
  };

  Color _getTypeColor(String type) => switch (type) {
    'timeBased' => Colors.blue,
    'milestone' => Colors.purple,
    'hours' => Colors.teal,
    'immediate' => Colors.green,
    _ => Colors.grey,
  };
}

enum _ItemType { holding, option }

class _VestingItem {
  final _ItemType type;
  final String id;
  final String stakeholderName;
  final VestingSchedule vestingSchedule;
  final int totalQuantity;
  final DateTime startDate;
  final int? vestedCount;
  final int? exercisedCount;
  final int? cancelledCount;
  final Holding? holding;
  final OptionGrant? optionGrant;

  _VestingItem({
    required this.type,
    required this.id,
    required this.stakeholderName,
    required this.vestingSchedule,
    required this.totalQuantity,
    required this.startDate,
    this.vestedCount,
    this.exercisedCount,
    this.cancelledCount,
    this.holding,
    this.optionGrant,
  });
}

class _Milestone {
  final String name;
  final double percentage;
  bool completed;

  _Milestone({
    required this.name,
    required this.percentage,
    this.completed = false,
  });
}
