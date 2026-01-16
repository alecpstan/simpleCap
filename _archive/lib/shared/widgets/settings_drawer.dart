import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/core/models/share_class.dart';
import '../../features/core/providers/core_cap_table_provider.dart';
import '../services/export_import_service.dart';
import 'dialogs.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Consumer<CoreCapTableProvider>(
          builder: (context, provider, child) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.pie_chart,
                        size: 48,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.companyName.isEmpty
                            ? 'Simple Cap'
                            : provider.companyName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (provider.companyName.isNotEmpty)
                        Text(
                          'Simple Cap',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'SETTINGS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Share Classes
                ExpansionTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Share Classes'),
                  subtitle: Text('${provider.shareClasses.length} defined'),
                  children: [
                    if (provider.shareClasses.isEmpty)
                      const ListTile(
                        title: Text('No share classes defined'),
                        dense: true,
                      )
                    else
                      ...provider.shareClasses.map((shareClass) {
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            child: Text(
                              shareClass.name.substring(0, 1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          title: Text(shareClass.name),
                          subtitle: Text(
                            'Vote: ${shareClass.votingRightsMultiplier}x • '
                            'Liq: ${shareClass.liquidationPreference}x'
                            '${shareClass.participating ? ' (Part.)' : ''}'
                            '${shareClass.seniority > 0 ? ' • Sen: ${shareClass.seniority}' : ''}'
                            '${shareClass.dividendRate > 0 ? ' • Div: ${shareClass.dividendRate}%' : ''}',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _showShareClassDialog(
                              context,
                              provider,
                              shareClass: shareClass,
                            ),
                          ),
                        );
                      }),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.add, size: 20),
                      title: const Text('Add Share Class'),
                      onTap: () => _showShareClassDialog(context, provider),
                    ),
                  ],
                ),

                // Company Settings
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Company Name'),
                  subtitle: Text(
                    provider.companyName.isEmpty
                        ? 'Not set'
                        : provider.companyName,
                  ),
                  onTap: () => _showCompanyNameDialog(context, provider),
                ),

                // Theme Mode
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Theme'),
                  trailing: DropdownButton<int>(
                    value: provider.themeModeIndex,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('System')),
                      DropdownMenuItem(value: 1, child: Text('Light')),
                      DropdownMenuItem(value: 2, child: Text('Dark')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        provider.setThemeMode(value);
                      }
                    },
                  ),
                ),

                const Divider(height: 32),

                // Data Management Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'DATA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('Export Data'),
                  subtitle: const Text('Save data to a backup file'),
                  onTap: () => _exportData(context, provider),
                ),

                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('Import Data'),
                  subtitle: const Text('Load data from a backup file'),
                  onTap: () => _importData(context, provider),
                ),

                const Divider(height: 32),

                // Danger Zone
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'DANGER ZONE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Reset All Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'Clear all investors, rounds, and shareholdings',
                  ),
                  onTap: () => _confirmResetData(context, provider),
                ),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showShareClassDialog(
    BuildContext context,
    CoreCapTableProvider provider, {
    ShareClass? shareClass,
  }) async {
    final isEditing = shareClass != null;
    final nameController = TextEditingController(text: shareClass?.name ?? '');
    final votingController = TextEditingController(
      text: shareClass?.votingRightsMultiplier.toString() ?? '1.0',
    );
    final liquidationController = TextEditingController(
      text: shareClass?.liquidationPreference.toString() ?? '1.0',
    );
    final dividendController = TextEditingController(
      text: shareClass?.dividendRate.toString() ?? '0.0',
    );
    final seniorityController = TextEditingController(
      text: shareClass?.seniority.toString() ?? '0',
    );
    var participating = shareClass?.participating ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Share Class' : 'Add Share Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., Preference B Shares',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: votingController,
                        decoration: const InputDecoration(
                          labelText: 'Voting Multiplier',
                          hintText: '1.0 = normal',
                          suffixText: 'x',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: liquidationController,
                        decoration: const InputDecoration(
                          labelText: 'Liq. Preference',
                          hintText: '1.0 = 1x',
                          suffixText: 'x',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: seniorityController,
                        decoration: const InputDecoration(
                          labelText: 'Seniority',
                          hintText: '0 = last, higher = first',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: dividendController,
                        decoration: const InputDecoration(
                          labelText: 'Dividend Rate',
                          hintText: '0 = none',
                          suffixText: '%',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Participating Preferred'),
                  subtitle: const Text('Gets preference AND pro-rata share'),
                  value: participating,
                  onChanged: (value) {
                    setState(() => participating = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final newShareClass = ShareClass(
        id: shareClass?.id,
        name: nameController.text,
        type: shareClass?.type ?? ShareClassType.custom,
        votingRightsMultiplier: double.tryParse(votingController.text) ?? 1.0,
        liquidationPreference:
            double.tryParse(liquidationController.text) ?? 1.0,
        participating: participating,
        dividendRate: double.tryParse(dividendController.text) ?? 0.0,
        seniority: int.tryParse(seniorityController.text) ?? 0,
      );

      if (isEditing) {
        await provider.updateShareClass(newShareClass);
      } else {
        await provider.addShareClass(newShareClass);
      }
    }
  }

  Future<void> _showCompanyNameDialog(
    BuildContext context,
    CoreCapTableProvider provider,
  ) async {
    final controller = TextEditingController(text: provider.companyName);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Company Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Company Name',
            hintText: 'e.g., My Startup Pty Ltd',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await provider.updateCompanyName(controller.text);
    }
  }

  Future<void> _confirmResetData(
    BuildContext context,
    CoreCapTableProvider provider,
  ) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Reset All Data',
      message:
          'Are you sure you want to delete all data? This action cannot be undone.',
      confirmText: 'Reset',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      Navigator.pop(context); // Close drawer
      await provider.resetData();
    }
  }

  Future<void> _exportData(
    BuildContext context,
    CoreCapTableProvider provider,
  ) async {
    final service = ExportImportService();
    final data = provider.exportData();
    final result = await service.exportData(data);

    if (!context.mounted) return;

    switch (result) {
      case DataTransferSuccess(:final fileName):
        Navigator.pop(context); // Close drawer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to: $fileName'),
            duration: const Duration(seconds: 4),
          ),
        );
      case DataTransferCancelled():
        // User cancelled, do nothing
        break;
      case DataTransferError(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<void> _importData(
    BuildContext context,
    CoreCapTableProvider provider,
  ) async {
    final service = ExportImportService();
    final result = await service.pickFileForImport();

    if (!context.mounted) return;

    switch (result) {
      case DataTransferSuccess(:final message):
        if (message == null) return;

        final confirmed = await showConfirmDialog(
          context: context,
          title: 'Import Data',
          message:
              'This will replace all current data with the backup. Continue?',
          confirmText: 'Import',
        );

        if (!confirmed || !context.mounted) return;

        final data = service.parseImportContent(message);
        if (data == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import failed: Invalid JSON format'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await provider.importData(data);

        if (context.mounted) {
          Navigator.pop(context); // Close drawer
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully')),
          );
        }
      case DataTransferCancelled():
        // User cancelled, do nothing
        break;
      case DataTransferError(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }
}
