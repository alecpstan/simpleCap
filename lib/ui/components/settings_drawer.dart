import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/providers.dart';
import '../../infrastructure/database/database.dart';
import '../pages/share_classes_page.dart';
import '../pages/stakeholder_types_page.dart';
import '../pages/vesting_schedules_page.dart';

/// Settings drawer accessible from the main screen.
class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyAsync = ref.watch(currentCompanyProvider);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context, companyAsync),
            const Divider(),
            _buildCompanySection(context, ref, companyAsync),
            const Divider(),
            _buildTemplatesSection(context),
            const Divider(),
            _buildPreferencesSection(context, ref),
            const Divider(),
            _buildDataSection(context, ref),
            const Divider(),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<Company?> companyAsync) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.pie_chart,
            size: 48,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const Spacer(),
          Text(
            'Simple Cap',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          companyAsync.when(
            data: (company) => Text(
              company?.name ?? 'No company selected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Company?> companyAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'COMPANY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.business),
          title: const Text('Company Details'),
          subtitle: companyAsync.when(
            data: (c) => Text(c?.name ?? 'Not set'),
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Error'),
          ),
          onTap: () =>
              _showCompanyDetailsDialog(context, ref, companyAsync.value),
        ),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: const Text('Switch Company'),
          subtitle: const Text('Manage multiple companies'),
          onTap: () => _showCompanySwitcher(context, ref),
        ),
      ],
    );
  }

  Widget _buildTemplatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'TEMPLATES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Stakeholder Types'),
          subtitle: const Text('Founder, Investor, Employee...'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pop(context); // Close drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StakeholderTypesPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Share Classes'),
          subtitle: const Text('Ordinary, Preference, ESOP...'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pop(context); // Close drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShareClassesPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Vesting Schedules'),
          subtitle: const Text('4yr cliff, milestone-based...'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pop(context); // Close drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VestingSchedulesPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context, WidgetRef ref) {
    final isDarkAsync = ref.watch(themeModeNotifierProvider);
    final isDark = isDarkAsync.valueOrNull ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'PREFERENCES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('Currency'),
          subtitle: const Text('AUD (Australian Dollar)'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Currency settings coming soon')),
            );
          },
        ),
        SwitchListTile(
          secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          title: const Text('Dark Mode'),
          subtitle: Text(isDark ? 'Dark theme enabled' : 'Light theme enabled'),
          value: isDark,
          onChanged: (value) {
            ref.read(themeModeNotifierProvider.notifier).setDarkMode(value);
          },
        ),
        Builder(
          builder: (context) {
            final deleteEnabledAsync = ref.watch(deleteEnabledProvider);
            final deleteEnabled = deleteEnabledAsync.valueOrNull ?? false;
            return SwitchListTile(
              secondary: Icon(
                Icons.delete_forever,
                color: deleteEnabled ? Colors.red : null,
              ),
              title: const Text('Enable Delete'),
              subtitle: Text(
                deleteEnabled
                    ? 'Delete buttons visible'
                    : 'Delete buttons hidden',
              ),
              value: deleteEnabled,
              activeColor: Colors.red,
              onChanged: (value) {
                ref.read(deleteEnabledProvider.notifier).setEnabled(value);
              },
            );
          },
        ),
        Builder(
          builder: (context) {
            final showDraftAsync = ref.watch(showDraftProvider);
            final showDraft = showDraftAsync.valueOrNull ?? true;
            return SwitchListTile(
              secondary: Icon(
                Icons.edit_note,
                color: showDraft ? Colors.grey : null,
              ),
              title: const Text('Show Draft Items'),
              subtitle: Text(
                showDraft
                    ? 'Draft items included in calculations'
                    : 'Draft items hidden from calculations',
              ),
              value: showDraft,
              onChanged: (value) {
                ref.read(showDraftProvider.notifier).setEnabled(value);
              },
            );
          },
        ),
        Builder(
          builder: (context) {
            final premiumEnabledAsync = ref.watch(premiumNotifierProvider);
            final premiumEnabled = premiumEnabledAsync.valueOrNull ?? false;
            return SwitchListTile(
              secondary: Icon(
                Icons.workspace_premium,
                color: premiumEnabled ? Colors.amber : null,
              ),
              title: const Text('Enable Premium'),
              subtitle: Text(
                premiumEnabled
                    ? 'All features unlocked'
                    : 'Some features are locked',
              ),
              value: premiumEnabled,
              activeColor: Colors.amber,
              onChanged: (value) {
                ref.read(premiumNotifierProvider.notifier).setEnabled(value);
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.format_list_numbered),
          title: const Text('Number Format'),
          subtitle: const Text('1,234.56'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Number format settings coming soon'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'DATA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.file_download),
          title: const Text('Export Data'),
          subtitle: const Text('CSV or PDF'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showExportOptions(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.file_upload),
          title: const Text('Import Data'),
          subtitle: const Text('From CSV'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import feature coming soon')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.folder_special),
          title: const Text('Load Example'),
          subtitle: const Text('Try sample data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showExampleScenarios(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.cleaning_services),
          title: const Text('Clean Up Orphan Holdings'),
          subtitle: const Text('Fix data integrity'),
          onTap: () => _confirmCleanOrphanHoldings(context, ref),
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Reset All Data',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: const Text('Delete everything'),
          onTap: () => _confirmResetData(context, ref),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'ABOUT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Documentation'),
          onTap: () => _showHelpDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About Simple Cap'),
          onTap: () => _showAboutDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.feedback_outlined),
          title: const Text('Send Feedback'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback form coming soon')),
            );
          },
        ),
      ],
    );
  }

  void _showCompanyDetailsDialog(
    BuildContext context,
    WidgetRef ref,
    Company? company,
  ) {
    if (company == null) return;

    final nameController = TextEditingController(text: company.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Company Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
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
              final db = ref.read(databaseProvider);
              await (db.update(
                db.companies,
              )..where((c) => c.id.equals(company.id))).write(
                CompaniesCompanion(
                  name: drift.Value(nameController.text),
                  updatedAt: drift.Value(DateTime.now()),
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCompanySwitcher(BuildContext context, WidgetRef ref) {
    final parentContext = context; // Store parent context before it's shadowed
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Switch Company'),
            subtitle: Text('Select a company or create a new one'),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.add)),
            title: const Text('Create New Company'),
            onTap: () {
              Navigator.pop(sheetContext);
              _showCreateCompanyDialog(parentContext, ref);
            },
          ),
          // TODO: List existing companies
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showCreateCompanyDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Company'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Company Name',
            hintText: 'e.g., Acme Pty Ltd',
          ),
          autofocus: true,
          onSubmitted: (_) async {
            if (nameController.text.isEmpty) return;
            try {
              debugPrint(
                'Creating company from settings: ${nameController.text}',
              );
              final companyId = await ref
                  .read(companyCommandsProvider.notifier)
                  .createCompany(name: nameController.text);
              debugPrint('Company created: $companyId');
              // Initialize default share classes and vesting schedules
              await ref
                  .read(companyCommandsProvider.notifier)
                  .initializeCompanyDefaults(companyId: companyId);
              debugPrint('Company defaults initialized');
              // Select the newly created company
              await ref
                  .read(currentCompanyIdProvider.notifier)
                  .setCompany(companyId);
              debugPrint('Company set as current');
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            } catch (e, st) {
              debugPrint('Error creating company: $e');
              debugPrint('Stack trace: $st');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              try {
                debugPrint(
                  'Creating company from settings button: ${nameController.text}',
                );
                final companyId = await ref
                    .read(companyCommandsProvider.notifier)
                    .createCompany(name: nameController.text);
                debugPrint('Company created: $companyId');
                // Initialize default share classes and vesting schedules
                await ref
                    .read(companyCommandsProvider.notifier)
                    .initializeCompanyDefaults(companyId: companyId);
                debugPrint('Company defaults initialized');
                // Select the newly created company
                await ref
                    .read(currentCompanyIdProvider.notifier)
                    .setCompany(companyId);
                debugPrint('Company set as current');
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (e, st) {
                debugPrint('Error creating company: $e');
                debugPrint('Stack trace: $st');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Export Data'),
            subtitle: Text('Choose a format'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export as CSV'),
            subtitle: const Text('Spreadsheet format'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV export coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export as PDF'),
            subtitle: const Text('Printable report'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF export coming soon')),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showExampleScenarios(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Load Example Scenario'),
            subtitle: Text('Try sample data for common startup types'),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.cloud)),
            title: const Text('SaaS Startup'),
            subtitle: const Text('Small - Seed stage'),
            onTap: () {
              Navigator.pop(context);
              _loadExample(context, ref, 'saas_small');
            },
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.cloud)),
            title: const Text('SaaS Startup'),
            subtitle: const Text('Mid - Series A'),
            onTap: () {
              Navigator.pop(context);
              _loadExample(context, ref, 'saas_mid');
            },
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.memory)),
            title: const Text('Hardware Startup'),
            subtitle: const Text('Small - Pre-seed'),
            onTap: () {
              Navigator.pop(context);
              _loadExample(context, ref, 'hardware_small');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _loadExample(
    BuildContext context,
    WidgetRef ref,
    String scenario,
  ) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Loading $scenario example...')));
    // TODO: Implement example loading from assets/example_scenarios/
  }

  void _confirmCleanOrphanHoldings(BuildContext context, WidgetRef ref) {
    final companyId = ref.read(currentCompanyIdProvider);
    if (companyId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No company selected')));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clean Up Orphan Holdings?'),
        content: const Text(
          'This will delete holdings that are not associated with any round. '
          'This can happen if rounds were deleted improperly. '
          'Holdings created through rounds will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // TODO: Implement deleteOrphanHoldings in HoldingCommands
              // This operation is not yet supported in the event-sourcing architecture.
              // For now, show a message that this feature is coming soon.
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This feature is coming soon')),
                );
              }
            },
            child: const Text('Clean Up'),
          ),
        ],
      ),
    );
  }

  void _confirmResetData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all companies, stakeholders, rounds, and other data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              try {
                final db = ref.read(databaseProvider);
                await db.resetAllData();

                // Clear current company selection
                await ref
                    .read(currentCompanyIdProvider.notifier)
                    .clearCompany();

                // Invalidate providers to force refresh
                ref.invalidate(eventsStreamProvider);
                ref.invalidate(capTableStateProvider);

                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context); // Close drawer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data has been erased'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error resetting data: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Documentation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                'Getting Started',
                'Add stakeholders (founders, investors, employees), create share classes, and record funding rounds.',
              ),
              _buildHelpSection(
                'Ownership Tab',
                'View who owns what percentage of the company. Toggle between issued shares and fully diluted view.',
              ),
              _buildHelpSection(
                'Rounds Tab',
                'Track funding rounds including seed, Series A, etc. Each round can have multiple investors.',
              ),
              _buildHelpSection(
                'Convertibles',
                'SAFEs, convertible notes, and other instruments that convert to equity.',
              ),
              _buildHelpSection(
                'Options & Warrants',
                'Employee stock options and warrants issued to investors or advisors.',
              ),
              _buildHelpSection(
                'Scenarios',
                'Model dilution from future rounds and calculate exit waterfalls.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Simple Cap',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(Icons.pie_chart, size: 48),
      applicationLegalese:
          '© 2026 Simple Cap\n\nCap table management for Australian Pty Ltd companies.',
      children: [
        const SizedBox(height: 16),
        const Text('Built with Flutter and ❤️', textAlign: TextAlign.center),
      ],
    );
  }
}
