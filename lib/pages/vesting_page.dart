import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';
import '../models/vesting_schedule.dart';
import '../models/shareholding.dart';
import '../models/investor.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import '../widgets/avatars.dart';
import '../widgets/info_widgets.dart';
import '../utils/helpers.dart';

class VestingPage extends StatelessWidget {
  const VestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final vestingSchedules = provider.vestingSchedules;

        return Scaffold(
          body: vestingSchedules.isEmpty
              ? const EmptyState(
                  icon: Icons.schedule_outlined,
                  title: 'No vesting schedules',
                  subtitle:
                      'Add vesting schedules to track employee and founder share vesting',
                )
              : _VestingListView(
                  vestingSchedules: vestingSchedules,
                  provider: provider,
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddVestingDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Add Vesting'),
          ),
        );
      },
    );
  }

  void _showAddVestingDialog(BuildContext context, CapTableProvider provider) {
    // Get shareholdings that don't already have vesting
    final shareholdingsWithoutVesting = provider.shareholdings.where((s) {
      return provider.getVestingByShareholding(s.id) == null;
    }).toList();

    if (shareholdingsWithoutVesting.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All shareholdings already have vesting schedules'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => VestingScheduleDialog(
        shareholdings: shareholdingsWithoutVesting,
        provider: provider,
      ),
    );
  }
}

class _VestingListView extends StatelessWidget {
  final List<VestingSchedule> vestingSchedules;
  final CapTableProvider provider;

  const _VestingListView({
    required this.vestingSchedules,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    // Group vesting by status
    final active = vestingSchedules
        .where((v) => v.leaverStatus == LeaverStatus.active)
        .toList();
    final fullyVested = active
        .where((v) => v.vestingPercentage >= 100)
        .toList();
    final vesting = active.where((v) => v.vestingPercentage < 100).toList();
    final terminated = vestingSchedules
        .where((v) => v.leaverStatus != LeaverStatus.active)
        .toList();

    // Sort by vesting percentage (least vested first for active)
    vesting.sort((a, b) => a.vestingPercentage.compareTo(b.vestingPercentage));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Stats
          _VestingSummaryCard(
            vestingSchedules: vestingSchedules,
            provider: provider,
          ),
          const SizedBox(height: 24),

          // Currently Vesting
          if (vesting.isNotEmpty) ...[
            _buildSectionHeader(context, 'Currently Vesting', vesting.length),
            const SizedBox(height: 8),
            ...vesting.map(
              (v) => _VestingCard(schedule: v, provider: provider),
            ),
            const SizedBox(height: 24),
          ],

          // Fully Vested
          if (fullyVested.isNotEmpty) ...[
            _buildSectionHeader(context, 'Fully Vested', fullyVested.length),
            const SizedBox(height: 8),
            ...fullyVested.map(
              (v) => _VestingCard(schedule: v, provider: provider),
            ),
            const SizedBox(height: 24),
          ],

          // Terminated
          if (terminated.isNotEmpty) ...[
            _buildSectionHeader(context, 'Terminated', terminated.length),
            const SizedBox(height: 8),
            ...terminated.map(
              (v) => _VestingCard(schedule: v, provider: provider),
            ),
          ],

          // Space for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _VestingSummaryCard extends StatelessWidget {
  final List<VestingSchedule> vestingSchedules;
  final CapTableProvider provider;

  const _VestingSummaryCard({
    required this.vestingSchedules,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    int totalSharesUnderVesting = 0;
    int totalVestedShares = 0;
    int totalUnvestedShares = 0;

    for (final schedule in vestingSchedules) {
      try {
        final shareholding = provider.shareholdings.firstWhere(
          (s) => s.id == schedule.shareholdingId,
        );
        totalSharesUnderVesting += shareholding.numberOfShares;
        final vested =
            (shareholding.numberOfShares * schedule.vestingPercentage / 100)
                .round();
        totalVestedShares += vested;
        totalUnvestedShares += shareholding.numberOfShares - vested;
      } catch (_) {
        // Shareholding not found
      }
    }

    final activeCount = vestingSchedules
        .where((v) => v.leaverStatus == LeaverStatus.active)
        .length;
    final vestedCount = vestingSchedules
        .where((v) => v.vestingPercentage >= 100)
        .length;

    return SectionCard(
      title: 'Vesting Summary',
      icon: Icons.schedule,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: 'Total Schedules',
                  value: vestingSchedules.length.toString(),
                ),
              ),
              Expanded(
                child: MiniStat(label: 'Active', value: activeCount.toString()),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Fully Vested',
                  value: vestedCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: 'Shares Under Vesting',
                  value: Formatters.number(totalSharesUnderVesting),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Vested',
                  value: Formatters.number(totalVestedShares),
                ),
              ),
              Expanded(
                child: MiniStat(
                  label: 'Unvested',
                  value: Formatters.number(totalUnvestedShares),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VestingCard extends StatelessWidget {
  final VestingSchedule schedule;
  final CapTableProvider provider;

  const _VestingCard({required this.schedule, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get related data
    Shareholding? shareholding;
    Investor? investor;
    try {
      shareholding = provider.shareholdings.firstWhere(
        (s) => s.id == schedule.shareholdingId,
      );
      investor = provider.getInvestorById(shareholding.investorId);
    } catch (_) {}

    if (shareholding == null || investor == null) {
      return const SizedBox.shrink();
    }

    final round = provider.getRoundById(shareholding.roundId);
    final vestedShares =
        (shareholding.numberOfShares * schedule.vestingPercentage / 100)
            .round();
    final unvestedShares = shareholding.numberOfShares - vestedShares;

    // Status color
    Color statusColor;
    String statusText;
    switch (schedule.leaverStatus) {
      case LeaverStatus.active:
        if (schedule.vestingPercentage >= 100) {
          statusColor = Colors.green;
          statusText = 'Fully Vested';
        } else if (!schedule.cliffPassed) {
          statusColor = Colors.orange;
          statusText = 'In Cliff';
        } else {
          statusColor = Colors.blue;
          statusText = 'Vesting';
        }
        break;
      case LeaverStatus.goodLeaver:
        statusColor = Colors.amber;
        statusText = 'Good Leaver';
        break;
      case LeaverStatus.badLeaver:
        statusColor = Colors.red;
        statusText = 'Bad Leaver';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: InvestorAvatar(name: investor.name, type: investor.type),
        title: Text(
          investor.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            // Progress indicator
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: schedule.vestingPercentage / 100,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: statusColor,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.percent(schedule.vestingPercentage)} vested',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shares info
                Row(
                  children: [
                    Expanded(
                      child: ResultChip(
                        label: 'Total Shares',
                        value: Formatters.number(shareholding.numberOfShares),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResultChip(
                        label: 'Vested',
                        value: Formatters.number(vestedShares),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResultChip(
                        label: 'Unvested',
                        value: Formatters.number(unvestedShares),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Schedule details
                _buildDetailRow(context, 'Round', round?.name ?? 'Unknown'),
                _buildDetailRow(
                  context,
                  'Vesting Type',
                  _getVestingTypeLabel(schedule.type),
                ),
                _buildDetailRow(
                  context,
                  'Schedule',
                  '${schedule.vestingPeriodMonths} months with ${schedule.cliffMonths} month cliff',
                ),
                _buildDetailRow(
                  context,
                  'Frequency',
                  _getFrequencyLabel(schedule.frequency),
                ),
                _buildDetailRow(
                  context,
                  'Start Date',
                  Formatters.date(schedule.startDate),
                ),
                _buildDetailRow(
                  context,
                  'Cliff Date',
                  Formatters.date(schedule.cliffDate),
                ),
                _buildDetailRow(
                  context,
                  'End Date',
                  Formatters.date(schedule.endDate),
                ),
                if (schedule.nextVestingDate != null)
                  _buildDetailRow(
                    context,
                    'Next Vesting',
                    Formatters.date(schedule.nextVestingDate!),
                  ),
                if (schedule.accelerationPercent > 0)
                  _buildDetailRow(
                    context,
                    'Acceleration',
                    '${schedule.accelerationPercent.toStringAsFixed(0)}% on liquidity event',
                  ),
                if (schedule.terminationDate != null)
                  _buildDetailRow(
                    context,
                    'Termination Date',
                    Formatters.date(schedule.terminationDate!),
                  ),
                if (schedule.notes != null && schedule.notes!.isNotEmpty)
                  _buildDetailRow(context, 'Notes', schedule.notes!),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (schedule.leaverStatus == LeaverStatus.active) ...[
                      TextButton.icon(
                        onPressed: () => _showTerminateDialog(context),
                        icon: const Icon(Icons.person_off_outlined),
                        label: const Text('Terminate'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    TextButton.icon(
                      onPressed: () => _showEditDialog(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _getVestingTypeLabel(VestingType type) {
    switch (type) {
      case VestingType.timeBased:
        return 'Time-based';
      case VestingType.milestoneBased:
        return 'Milestone-based';
      case VestingType.reverse:
        return 'Reverse vesting';
    }
  }

  String _getFrequencyLabel(VestingFrequency frequency) {
    switch (frequency) {
      case VestingFrequency.monthly:
        return 'Monthly';
      case VestingFrequency.quarterly:
        return 'Quarterly';
      case VestingFrequency.annually:
        return 'Annually';
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VestingScheduleDialog(
        shareholdings: provider.shareholdings,
        provider: provider,
        existingSchedule: schedule,
      ),
    );
  }

  void _showTerminateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          _TerminateVestingDialog(schedule: schedule, provider: provider),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vesting Schedule'),
        content: const Text(
          'Are you sure you want to delete this vesting schedule? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteVestingSchedule(schedule.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TerminateVestingDialog extends StatefulWidget {
  final VestingSchedule schedule;
  final CapTableProvider provider;

  const _TerminateVestingDialog({
    required this.schedule,
    required this.provider,
  });

  @override
  State<_TerminateVestingDialog> createState() =>
      _TerminateVestingDialogState();
}

class _TerminateVestingDialogState extends State<_TerminateVestingDialog> {
  late DateTime _terminationDate;
  LeaverStatus _leaverStatus = LeaverStatus.goodLeaver;

  @override
  void initState() {
    super.initState();
    _terminationDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terminate Vesting'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select the termination date and leaver status. Good leavers keep their vested shares, bad leavers forfeit all shares.',
          ),
          const SizedBox(height: 24),

          // Termination Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Termination Date'),
            subtitle: Text(Formatters.date(_terminationDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _terminationDate,
                firstDate: widget.schedule.startDate,
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _terminationDate = date);
              }
            },
          ),

          const SizedBox(height: 16),

          // Leaver Status
          const Text('Leaver Status'),
          const SizedBox(height: 8),
          SegmentedButton<LeaverStatus>(
            segments: const [
              ButtonSegment(
                value: LeaverStatus.goodLeaver,
                label: Text('Good'),
                icon: Icon(Icons.thumb_up_outlined),
              ),
              ButtonSegment(
                value: LeaverStatus.badLeaver,
                label: Text('Bad'),
                icon: Icon(Icons.thumb_down_outlined),
              ),
            ],
            selected: {_leaverStatus},
            onSelectionChanged: (set) {
              setState(() => _leaverStatus = set.first);
            },
          ),

          const SizedBox(height: 16),

          // Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _leaverStatus == LeaverStatus.goodLeaver
                  ? Colors.amber.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _leaverStatus == LeaverStatus.goodLeaver
                      ? 'Good Leaver: Keeps vested shares'
                      : 'Bad Leaver: Forfeits all shares',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _leaverStatus == LeaverStatus.goodLeaver
                        ? Colors.amber.shade700
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _leaverStatus == LeaverStatus.goodLeaver
                      ? 'Vested: ${widget.schedule.vestingPercentage.toStringAsFixed(1)}%'
                      : 'All shares returned to pool',
                  style: Theme.of(context).textTheme.bodySmall,
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
          onPressed: () {
            final updated = widget.schedule.copyWith(
              leaverStatus: _leaverStatus,
              terminationDate: _terminationDate,
            );
            widget.provider.updateVestingSchedule(updated);
            Navigator.pop(context);
          },
          child: const Text('Terminate'),
        ),
      ],
    );
  }
}

class VestingScheduleDialog extends StatefulWidget {
  final List<Shareholding> shareholdings;
  final CapTableProvider provider;
  final VestingSchedule? existingSchedule;

  const VestingScheduleDialog({
    super.key,
    required this.shareholdings,
    required this.provider,
    this.existingSchedule,
  });

  @override
  State<VestingScheduleDialog> createState() => _VestingScheduleDialogState();
}

class _VestingScheduleDialogState extends State<VestingScheduleDialog> {
  late String? _selectedShareholdingId;
  late VestingType _vestingType;
  late DateTime _startDate;
  late int _vestingPeriodMonths;
  late int _cliffMonths;
  late VestingFrequency _frequency;
  late double _accelerationPercent;
  late String _notes;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSchedule;
    _selectedShareholdingId =
        existing?.shareholdingId ??
        (widget.shareholdings.isNotEmpty
            ? widget.shareholdings.first.id
            : null);
    _vestingType = existing?.type ?? VestingType.timeBased;
    _startDate = existing?.startDate ?? DateTime.now();
    _vestingPeriodMonths = existing?.vestingPeriodMonths ?? 48;
    _cliffMonths = existing?.cliffMonths ?? 12;
    _frequency = existing?.frequency ?? VestingFrequency.monthly;
    _accelerationPercent = existing?.accelerationPercent ?? 0;
    _notes = existing?.notes ?? '';
  }

  bool get isEditing => widget.existingSchedule != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Vesting Schedule' : 'Add Vesting Schedule'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shareholding selection (only for new)
                if (!isEditing) ...[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Shareholding',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedShareholdingId,
                    items: widget.shareholdings.map((s) {
                      final investor = widget.provider.getInvestorById(
                        s.investorId,
                      );
                      final round = widget.provider.getRoundById(s.roundId);
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(
                          '${investor?.name ?? 'Unknown'} - ${round?.name ?? 'Unknown'} (${Formatters.number(s.numberOfShares)} shares)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedShareholdingId = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a shareholding' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Vesting Type
                DropdownButtonFormField<VestingType>(
                  decoration: const InputDecoration(
                    labelText: 'Vesting Type',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _vestingType,
                  items: VestingType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getVestingTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _vestingType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Start Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start Date'),
                  subtitle: Text(Formatters.date(_startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Vesting Period
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Vesting Period',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _vestingPeriodMonths,
                        items: [12, 24, 36, 48, 60].map((months) {
                          return DropdownMenuItem(
                            value: months,
                            child: Text('${months ~/ 12} years'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _vestingPeriodMonths = value;
                              // Ensure cliff doesn't exceed vesting period
                              if (_cliffMonths > value) {
                                _cliffMonths = value ~/ 4;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Cliff Period',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _cliffMonths,
                        items: [0, 3, 6, 9, 12, 18, 24]
                            .where((m) => m <= _vestingPeriodMonths)
                            .map((months) {
                              return DropdownMenuItem(
                                value: months,
                                child: Text(
                                  months == 0 ? 'No cliff' : '$months months',
                                ),
                              );
                            })
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _cliffMonths = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Frequency
                DropdownButtonFormField<VestingFrequency>(
                  decoration: const InputDecoration(
                    labelText: 'Vesting Frequency',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _frequency,
                  items: VestingFrequency.values.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(_getFrequencyLabel(freq)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _frequency = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Acceleration
                DropdownButtonFormField<double>(
                  decoration: const InputDecoration(
                    labelText: 'Acceleration on Liquidity Event',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _accelerationPercent,
                  items: [0.0, 25.0, 50.0, 100.0].map((percent) {
                    return DropdownMenuItem(
                      value: percent,
                      child: Text(
                        percent == 0
                            ? 'None'
                            : '${percent.toInt()}% acceleration',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _accelerationPercent = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _notes,
                  maxLines: 2,
                  onChanged: (value) => _notes = value,
                ),

                const SizedBox(height: 16),

                // Preview
                _buildPreview(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: Text(isEditing ? 'Save' : 'Add')),
      ],
    );
  }

  Widget _buildPreview() {
    final cliffDate = DateTime(
      _startDate.year,
      _startDate.month + _cliffMonths,
      _startDate.day,
    );
    final endDate = DateTime(
      _startDate.year,
      _startDate.month + _vestingPeriodMonths,
      _startDate.day,
    );
    final cliffPercent = (_cliffMonths / _vestingPeriodMonths * 100)
        .toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Preview',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '• Cliff: ${Formatters.date(cliffDate)} ($cliffPercent% vests)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '• End: ${Formatters.date(endDate)} (100% vested)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '• Vests ${_getFrequencyLabel(_frequency).toLowerCase()} after cliff',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getVestingTypeLabel(VestingType type) {
    switch (type) {
      case VestingType.timeBased:
        return 'Time-based';
      case VestingType.milestoneBased:
        return 'Milestone-based';
      case VestingType.reverse:
        return 'Reverse vesting';
    }
  }

  String _getFrequencyLabel(VestingFrequency frequency) {
    switch (frequency) {
      case VestingFrequency.monthly:
        return 'Monthly';
      case VestingFrequency.quarterly:
        return 'Quarterly';
      case VestingFrequency.annually:
        return 'Annually';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedShareholdingId == null) return;

    final schedule = VestingSchedule(
      id: widget.existingSchedule?.id,
      shareholdingId: _selectedShareholdingId!,
      type: _vestingType,
      startDate: _startDate,
      vestingPeriodMonths: _vestingPeriodMonths,
      cliffMonths: _cliffMonths,
      frequency: _frequency,
      accelerationPercent: _accelerationPercent,
      leaverStatus:
          widget.existingSchedule?.leaverStatus ?? LeaverStatus.active,
      terminationDate: widget.existingSchedule?.terminationDate,
      notes: _notes.isEmpty ? null : _notes,
    );

    if (isEditing) {
      widget.provider.updateVestingSchedule(schedule);
    } else {
      widget.provider.addVestingSchedule(schedule);
    }

    Navigator.pop(context);
  }
}
