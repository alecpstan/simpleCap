import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/share_class.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/dialogs.dart';
import '../widgets/valuation_wizard.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Consumer<CapTableProvider>(
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

                // Tools Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'TOOLS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: const Text('Valuation Wizard'),
                  subtitle: const Text('Help determine pre-money valuation'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    ValuationWizard.show(context);
                  },
                ),

                // Placeholder for future tools
                ListTile(
                  leading: Icon(
                    Icons.timeline,
                    color: theme.colorScheme.outline,
                  ),
                  title: Text(
                    'Funding Timeline',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                  subtitle: Text(
                    'Coming soon',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                  enabled: false,
                ),

                ListTile(
                  leading: Icon(
                    Icons.file_download,
                    color: theme.colorScheme.outline,
                  ),
                  title: Text(
                    'Export Cap Table',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                  subtitle: Text(
                    'Coming soon',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                  enabled: false,
                ),

                const Divider(height: 32),

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
                            'Voting: ${shareClass.votingRightsMultiplier}x • '
                            'Liq: ${shareClass.liquidationPreference}x'
                            '${shareClass.participating ? ' (Part.)' : ''}',
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

                ListTile(
                  leading: const Icon(Icons.numbers),
                  title: const Text('Authorised Shares'),
                  subtitle: Text(
                    provider.totalAuthorisedShares > 0
                        ? '${provider.totalAuthorisedShares} shares'
                        : 'Not set',
                  ),
                  onTap: () => _showAuthorisedSharesDialog(context, provider),
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
    CapTableProvider provider, {
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
                TextField(
                  controller: votingController,
                  decoration: const InputDecoration(
                    labelText: 'Voting Rights Multiplier',
                    hintText: '1.0 = normal, 0 = non-voting',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: liquidationController,
                  decoration: const InputDecoration(
                    labelText: 'Liquidation Preference',
                    hintText: '1.0 = 1x, 2.0 = 2x',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Participating Preferred'),
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
    CapTableProvider provider,
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

  Future<void> _showAuthorisedSharesDialog(
    BuildContext context,
    CapTableProvider provider,
  ) async {
    final controller = TextEditingController(
      text: provider.totalAuthorisedShares > 0
          ? provider.totalAuthorisedShares.toString()
          : '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authorised Shares'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Total Authorised Shares',
            hintText: 'e.g., 10000000',
          ),
          keyboardType: TextInputType.number,
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
      final shares = int.tryParse(controller.text) ?? 0;
      await provider.updateTotalAuthorisedShares(shares);
    }
  }

  Future<void> _confirmResetData(
    BuildContext context,
    CapTableProvider provider,
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
}
