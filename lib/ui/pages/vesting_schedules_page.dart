import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../domain/constants/constants.dart';
import '../../infrastructure/database/database.dart';
import '../components/components.dart';

/// Page for managing vesting schedule templates.
///
/// Allows users to create, edit, and delete vesting schedules
/// that can be used when granting options.
class VestingSchedulesPage extends ConsumerWidget {
  const VestingSchedulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vestingAsync = ref.watch(vestingSchedulesStreamProvider);
    final companyId = ref.watch(currentCompanyIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vesting Schedules'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Quick Add',
            onSelected: (value) async {
              if (companyId == null) return;
              final commands = ref.read(
                vestingScheduleCommandsProvider.notifier,
              );

              if (value == '4year') {
                await commands.createStandard4YearSchedule();
              } else if (value == '3year') {
                await commands.create3YearNoCliffSchedule();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '4year',
                child: ListTile(
                  leading: Icon(Icons.bolt),
                  title: Text('4 Year / 1 Year Cliff'),
                  subtitle: Text('Standard schedule'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: '3year',
                child: ListTile(
                  leading: Icon(Icons.bolt),
                  title: Text('3 Year / Monthly'),
                  subtitle: Text('No cliff'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: companyId == null
          ? const EmptyState(
              icon: Icons.business,
              title: 'No company selected',
              message: 'Please create or select a company first.',
            )
          : vestingAsync.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return EmptyState.noItems(
                    itemType: 'vesting schedule',
                    onAdd: () =>
                        _showVestingScheduleDialog(context, ref, companyId),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: schedules.length + 1,
                  itemBuilder: (context, index) {
                    if (index == schedules.length) {
                      return const SizedBox(height: 80);
                    }
                    return _buildScheduleCard(context, ref, schedules[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(vestingSchedulesStreamProvider),
              ),
            ),
      floatingActionButton: companyId != null
          ? FloatingActionButton(
              onPressed: () =>
                  _showVestingScheduleDialog(context, ref, companyId),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    WidgetRef ref,
    VestingSchedule schedule,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(schedule.type).withOpacity(0.2),
          child: Icon(
            _getTypeIcon(schedule.type),
            color: _getTypeColor(schedule.type),
          ),
        ),
        title: Text(
          schedule.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_buildDescription(schedule)),
            if (schedule.notes?.isNotEmpty == true)
              Text(
                schedule.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (schedule.cliffMonths > 0)
              _buildBadge(
                context,
                '${schedule.cliffMonths}mo cliff',
                Colors.orange,
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) {
                if (action == 'edit') {
                  _showVestingScheduleDialog(
                    context,
                    ref,
                    schedule.companyId,
                    existing: schedule,
                  );
                } else if (action == 'delete') {
                  _confirmDelete(context, ref, schedule);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Delete',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: schedule.notes?.isNotEmpty == true,
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _buildDescription(VestingSchedule schedule) {
    final type = schedule.type;

    if (type == VestingType.immediate) return 'Immediate vesting';
    if (type == VestingType.milestone) return 'Milestone-based';
    if (type == VestingType.hours) {
      return '${schedule.totalHours ?? 0} hours';
    }

    final total = schedule.totalMonths ?? 0;
    final years = total ~/ 12;
    final remainingMonths = total % 12;
    final freq = schedule.frequency != null
        ? VestingFrequency.displayName(schedule.frequency!).toLowerCase()
        : null;

    final parts = <String>[];

    if (years > 0) {
      parts.add('$years year${years > 1 ? 's' : ''}');
    }
    if (remainingMonths > 0) {
      parts.add('$remainingMonths month${remainingMonths > 1 ? 's' : ''}');
    }
    if (freq != null) {
      parts.add(freq);
    }

    return parts.join(' / ');
  }

  void _showVestingScheduleDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId, {
    VestingSchedule? existing,
  }) {
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name);
    final notesController = TextEditingController(text: existing?.notes);

    String selectedType = existing?.type ?? VestingType.timeBased;
    int totalMonths = existing?.totalMonths ?? 48;
    int cliffMonths = existing?.cliffMonths ?? 12;
    String? frequency = existing?.frequency ?? VestingFrequency.monthly;
    int totalHours = existing?.totalHours ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isEditing ? 'Edit Vesting Schedule' : 'Add Vesting Schedule',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: !isEditing,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: VestingType.all
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(VestingType.displayName(t)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setDialogState(
                      () => selectedType = v ?? VestingType.timeBased,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Time-based options
                if (selectedType == VestingType.timeBased) ...[
                  Text(
                    'Vesting Period',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Duration (months)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Slider(
                              value: totalMonths.toDouble(),
                              min: 1,
                              max: 60,
                              divisions: 59,
                              label: _formatMonthsAsYears(totalMonths),
                              onChanged: (v) {
                                setDialogState(() {
                                  totalMonths = v.toInt();
                                  // Ensure cliff doesn't exceed total
                                  if (cliffMonths > totalMonths) {
                                    cliffMonths = totalMonths;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          _formatMonthsAsYears(totalMonths),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cliff Period (months)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Slider(
                              value: cliffMonths
                                  .clamp(0, totalMonths)
                                  .toDouble(),
                              min: 0,
                              max: totalMonths.toDouble(),
                              divisions: totalMonths > 0 ? totalMonths : 1,
                              label: cliffMonths == 0
                                  ? 'No cliff'
                                  : _formatMonthsAsYears(cliffMonths),
                              onChanged: (v) {
                                setDialogState(() => cliffMonths = v.toInt());
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          cliffMonths == 0
                              ? 'None'
                              : _formatMonthsAsYears(cliffMonths),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    decoration: const InputDecoration(
                      labelText: 'Vesting Frequency',
                    ),
                    items: VestingFrequency.all
                        .map(
                          (f) => DropdownMenuItem(
                            value: f,
                            child: Text(VestingFrequency.displayName(f)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setDialogState(() => frequency = v);
                    },
                  ),
                ],

                // Hours-based options
                if (selectedType == VestingType.hours) ...[
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Total Hours',
                      hintText: 'e.g., 2000',
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: totalHours > 0 ? totalHours.toString() : '',
                    ),
                    onChanged: (v) {
                      totalHours = int.tryParse(v) ?? 0;
                    },
                  ),
                ],

                // Milestone-based placeholder
                if (selectedType == VestingType.milestone) ...[
                  const SizedBox(height: 16),
                  InfoBox(
                    message:
                        'Milestone-based vesting requires manual tracking. '
                        'Document milestones in the notes field.',
                  ),
                ],

                // Immediate placeholder
                if (selectedType == VestingType.immediate) ...[
                  const SizedBox(height: 16),
                  InfoBox(
                    message:
                        'Shares will be fully vested immediately upon grant.',
                  ),
                ],

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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final commands = ref.read(
                  vestingScheduleCommandsProvider.notifier,
                );

                if (isEditing) {
                  await commands.updateVestingSchedule(
                    scheduleId: existing.id,
                    name: name,
                    type: selectedType,
                    totalMonths: selectedType == VestingType.timeBased
                        ? totalMonths
                        : null,
                    cliffMonths: selectedType == VestingType.timeBased
                        ? cliffMonths
                        : 0,
                    frequency: selectedType == VestingType.timeBased
                        ? frequency
                        : null,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                } else {
                  await commands.createVestingSchedule(
                    name: name,
                    type: selectedType,
                    totalMonths: selectedType == VestingType.timeBased
                        ? totalMonths
                        : null,
                    cliffMonths: selectedType == VestingType.timeBased
                        ? cliffMonths
                        : 0,
                    frequency: selectedType == VestingType.timeBased
                        ? frequency
                        : null,
                    totalHours: selectedType == VestingType.hours
                        ? totalHours
                        : null,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VestingSchedule schedule,
  ) async {
    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: schedule.name,
    );

    if (confirmed) {
      await ref
          .read(vestingScheduleCommandsProvider.notifier)
          .deleteVestingSchedule(scheduleId: schedule.id);
    }
  }

  String _formatMonthsAsYears(int months) {
    if (months < 12) {
      return '$months mo';
    }
    final years = months ~/ 12;
    final remaining = months % 12;
    if (remaining == 0) {
      return '$years yr${years > 1 ? 's' : ''}';
    }
    return '$years yr $remaining mo';
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case VestingType.timeBased:
        return Colors.blue;
      case VestingType.milestone:
        return Colors.purple;
      case VestingType.hours:
        return Colors.teal;
      case VestingType.immediate:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case VestingType.timeBased:
        return Icons.schedule;
      case VestingType.milestone:
        return Icons.flag;
      case VestingType.hours:
        return Icons.timer;
      case VestingType.immediate:
        return Icons.flash_on;
      default:
        return Icons.schedule;
    }
  }
}
