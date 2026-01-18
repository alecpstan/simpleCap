import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../domain/constants/constants.dart';
import '../../infrastructure/database/database.dart';
import '../components/components.dart';

/// Page for managing share class templates.
///
/// Allows users to create, edit, and delete share classes
/// that can be used when recording holdings.
class ShareClassesPage extends ConsumerWidget {
  const ShareClassesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareClassesAsync = ref.watch(shareClassesStreamProvider);
    final companyId = ref.watch(currentCompanyIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Share Classes')),
      body: companyId == null
          ? const EmptyState(
              icon: Icons.business,
              title: 'No company selected',
              message: 'Please create or select a company first.',
            )
          : shareClassesAsync.when(
              data: (shareClasses) {
                if (shareClasses.isEmpty) {
                  return EmptyState.noItems(
                    itemType: 'share class',
                    onAdd: () => _showShareClassDialog(context, ref, companyId),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shareClasses.length + 1, // +1 for bottom padding
                  itemBuilder: (context, index) {
                    if (index == shareClasses.length) {
                      return const SizedBox(height: 80);
                    }
                    return _buildShareClassCard(
                      context,
                      ref,
                      shareClasses[index],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState.error(
                message: e.toString(),
                onRetry: () => ref.invalidate(shareClassesStreamProvider),
              ),
            ),
      floatingActionButton: companyId != null
          ? FloatingActionButton(
              onPressed: () => _showShareClassDialog(context, ref, companyId),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildShareClassCard(
    BuildContext context,
    WidgetRef ref,
    ShareClassesData shareClass,
  ) {
    final deleteEnabled = ref.watch(deleteEnabledProvider).valueOrNull ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getShareClassColor(
            shareClass.type,
          ).withOpacity(0.2),
          child: Icon(
            _getShareClassIcon(shareClass.type),
            color: _getShareClassColor(shareClass.type),
          ),
        ),
        title: Text(
          shareClass.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatType(shareClass.type)),
            if (shareClass.notes?.isNotEmpty == true)
              Text(
                shareClass.notes!,
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
            _buildRightsBadges(context, shareClass),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) {
                if (action == 'edit') {
                  _showShareClassDialog(
                    context,
                    ref,
                    shareClass.companyId,
                    existing: shareClass,
                  );
                } else if (action == 'delete') {
                  _confirmDelete(context, ref, shareClass);
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
                if (deleteEnabled)
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
        isThreeLine: shareClass.notes?.isNotEmpty == true,
      ),
    );
  }

  Widget _buildRightsBadges(BuildContext context, ShareClassesData shareClass) {
    final badges = <Widget>[];

    if (shareClass.votingMultiplier == 0) {
      badges.add(_buildBadge(context, 'Non-voting', Colors.grey));
    } else if (shareClass.votingMultiplier != 1.0) {
      badges.add(
        _buildBadge(
          context,
          '${shareClass.votingMultiplier}x vote',
          Colors.blue,
        ),
      );
    }

    if (shareClass.liquidationPreference != 1.0) {
      badges.add(
        _buildBadge(
          context,
          '${shareClass.liquidationPreference}x pref',
          Colors.orange,
        ),
      );
    }

    if (shareClass.isParticipating) {
      badges.add(_buildBadge(context, 'Part.', Colors.purple));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Wrap(spacing: 4, children: badges),
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  void _showShareClassDialog(
    BuildContext context,
    WidgetRef ref,
    String companyId, {
    ShareClassesData? existing,
  }) {
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name);
    final notesController = TextEditingController(text: existing?.notes);

    String selectedType = existing?.type ?? 'ordinary';
    double votingMultiplier = existing?.votingMultiplier ?? 1.0;
    double liquidationPreference = existing?.liquidationPreference ?? 1.0;
    bool isParticipating = existing?.isParticipating ?? false;
    double dividendRate = existing?.dividendRate ?? 0.0;
    int seniority = existing?.seniority ?? 0;
    String antiDilutionType =
        existing?.antiDilutionType ?? AntiDilutionType.none;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Share Class' : 'Add Share Class'),
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
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'ordinary',
                      child: Text('Ordinary'),
                    ),
                    DropdownMenuItem(
                      value: 'preferenceA',
                      child: Text('Preference A'),
                    ),
                    DropdownMenuItem(
                      value: 'preferenceB',
                      child: Text('Preference B'),
                    ),
                    DropdownMenuItem(
                      value: 'preferenceC',
                      child: Text('Preference C'),
                    ),
                    DropdownMenuItem(value: 'esop', child: Text('ESOP')),
                    DropdownMenuItem(value: 'options', child: Text('Options')),
                    DropdownMenuItem(
                      value: 'performanceRights',
                      child: Text('Performance Rights'),
                    ),
                  ],
                  onChanged: (v) {
                    setDialogState(() => selectedType = v ?? 'ordinary');
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Rights & Preferences',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voting Multiplier',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Slider(
                            value: votingMultiplier,
                            min: 0,
                            max: 10,
                            divisions: 20,
                            label: votingMultiplier == 0
                                ? 'Non-voting'
                                : '${votingMultiplier}x',
                            onChanged: (v) {
                              setDialogState(() => votingMultiplier = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        votingMultiplier == 0
                            ? 'None'
                            : '${votingMultiplier.toStringAsFixed(1)}x',
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
                            'Liquidation Preference',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Slider(
                            value: liquidationPreference,
                            min: 0,
                            max: 3,
                            divisions: 30,
                            label: '${liquidationPreference}x',
                            onChanged: (v) {
                              setDialogState(() => liquidationPreference = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${liquidationPreference.toStringAsFixed(1)}x',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Participating'),
                  subtitle: const Text('Share in remaining proceeds'),
                  value: isParticipating,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) {
                    setDialogState(() => isParticipating = v);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dividend Rate (%)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Slider(
                            value: dividendRate,
                            min: 0,
                            max: 20,
                            divisions: 40,
                            label: '${dividendRate.toStringAsFixed(1)}%',
                            onChanged: (v) {
                              setDialogState(() => dividendRate = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${dividendRate.toStringAsFixed(1)}%',
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
                            'Seniority (payment order)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Slider(
                            value: seniority.toDouble(),
                            min: 0,
                            max: 10,
                            divisions: 10,
                            label: seniority.toString(),
                            onChanged: (v) {
                              setDialogState(() => seniority = v.toInt());
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        seniority.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: antiDilutionType,
                  decoration: const InputDecoration(
                    labelText: 'Anti-Dilution Protection',
                    helperText: 'Protects investors in down rounds',
                  ),
                  items: AntiDilutionType.all
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(AntiDilutionType.displayName(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setDialogState(
                      () => antiDilutionType = v ?? AntiDilutionType.none,
                    );
                  },
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final commands = ref.read(shareClassCommandsProvider.notifier);

                if (isEditing) {
                  // Update existing using command handler
                  await commands.updateShareClass(
                    shareClassId: existing.id,
                    name: name,
                    type: selectedType,
                    votingMultiplier: votingMultiplier,
                    liquidationPreference: liquidationPreference,
                    isParticipating: isParticipating,
                    dividendRate: dividendRate,
                    seniority: seniority,
                    antiDilutionType: antiDilutionType,
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );
                } else {
                  await commands.createShareClass(
                    name: name,
                    type: selectedType,
                    votingMultiplier: votingMultiplier,
                    liquidationPreference: liquidationPreference,
                    isParticipating: isParticipating,
                    dividendRate: dividendRate,
                    seniority: seniority,
                    antiDilutionType: antiDilutionType,
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
    ShareClassesData shareClass,
  ) async {
    // Preview cascade impact
    final cascadeImpact = await ref
        .read(eventLedgerProvider.notifier)
        .previewCascadeDelete(
          entityId: shareClass.id,
          entityType: EntityType.shareClass,
        );

    final impactLines = <String>[];
    cascadeImpact.forEach((type, count) {
      if (count > 0) {
        impactLines.add('• $count ${type.name}(s)');
      }
    });

    final message = impactLines.isEmpty
        ? 'Are you sure you want to permanently delete "${shareClass.name}"? This cannot be undone.'
        : 'This will permanently delete:\n${impactLines.join('\n')}\n\nThis cannot be undone.';

    final confirmed = await ConfirmDialog.showDelete(
      context: context,
      itemName: shareClass.name,
      customMessage: message,
    );

    if (confirmed) {
      try {
        await ref
            .read(shareClassCommandsProvider.notifier)
            .deleteShareClass(shareClassId: shareClass.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${shareClass.name} deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting share class: $e')),
          );
        }
      }
    }
  }

  Color _getShareClassColor(String type) {
    switch (type) {
      case 'ordinary':
        return Colors.blue;
      case 'preferenceA':
      case 'preferenceB':
      case 'preferenceC':
        return Colors.purple;
      case 'esop':
        return Colors.teal;
      case 'options':
        return Colors.green;
      case 'performanceRights':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getShareClassIcon(String type) {
    switch (type) {
      case 'ordinary':
        return Icons.grid_view;
      case 'preferenceA':
      case 'preferenceB':
      case 'preferenceC':
        return Icons.star;
      case 'esop':
        return Icons.people;
      case 'options':
        return Icons.trending_up;
      case 'performanceRights':
        return Icons.emoji_events;
      default:
        return Icons.category;
    }
  }

  String _formatType(String type) {
    switch (type) {
      case 'ordinary':
        return 'Ordinary';
      case 'preferenceA':
        return 'Preference A';
      case 'preferenceB':
        return 'Preference B';
      case 'preferenceC':
        return 'Preference C';
      case 'esop':
        return 'ESOP';
      case 'options':
        return 'Options';
      case 'performanceRights':
        return 'Performance Rights';
      default:
        return type;
    }
  }
}
