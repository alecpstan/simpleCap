import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/providers.dart';
import '../components/settings_drawer.dart';
import '../pages/pages.dart';

/// The main app shell with bottom navigation.
///
/// This is the root navigation structure with 5 main tabs:
/// - Overview (Dashboard)
/// - Stakeholders (formerly Investors)
/// - Rounds
/// - Value
/// - Ownership (formerly Cap Table)
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _hasCheckedForCompanies = false;

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Overview',
    ),
    _NavDestination(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: 'Stakeholder',
    ),
    _NavDestination(
      icon: Icons.layers_outlined,
      selectedIcon: Icons.layers,
      label: 'Rounds',
    ),
    _NavDestination(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: 'Value',
    ),
    _NavDestination(
      icon: Icons.table_chart_outlined,
      selectedIcon: Icons.table_chart,
      label: 'Ownership',
    ),
  ];

  // The actual page widgets for each tab
  static const List<Widget> _pages = [
    OverviewPage(),
    StakeholdersPage(),
    RoundsPage(),
    ValuePage(),
    OwnershipPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedForCompanies) {
      _hasCheckedForCompanies = true;
      // Check for companies after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForCompanies();
      });
    }
  }

  Future<void> _checkForCompanies() async {
    final db = ref.read(databaseProvider);
    final companies = await db.getAllCompanies();

    if (companies.isEmpty && mounted) {
      _showCreateCompanyDialog();
    }
  }

  void _showCreateCompanyDialog() {
    final nameController = TextEditingController();
    final errorNotifier = ValueNotifier<String?>(null);

    showDialog(
      context: context,
      barrierDismissible: false, // Force user to create a company
      builder: (dialogContext) => AlertDialog(
        title: const Text('Welcome to Simple Cap'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create your first company to get started.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                hintText: 'e.g., Acme Pty Ltd',
              ),
              autofocus: true,
              onSubmitted: (_) => _createCompany(dialogContext, nameController, errorNotifier),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String?>(
              valueListenable: errorNotifier,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    error,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => _createCompany(dialogContext, nameController, errorNotifier),
            child: const Text('Create Company'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCompany(
    BuildContext dialogContext,
    TextEditingController controller,
    ValueNotifier<String?> errorNotifier,
  ) async {
    final name = controller.text.trim();
    if (name.isEmpty) {
      errorNotifier.value = 'Please enter a company name';
      return;
    }

    errorNotifier.value = null; // Clear previous error

    try {
      debugPrint('Creating company: $name');
      final companyId = await ref
          .read(companyCommandsProvider.notifier)
          .createCompany(name: name);
      debugPrint('Company created with id: $companyId');

      // Select the newly created company
      await ref.read(currentCompanyIdProvider.notifier).setCompany(companyId);
      debugPrint('Company set as current');

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Company "$name" created successfully!')),
        );
      }
    } catch (e, st) {
      debugPrint('Error creating company: $e');
      debugPrint('Stack trace: $st');
      errorNotifier.value = 'Error: $e';
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onDestinationSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside input fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Settings & Tools',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text('Simple Cap'),
          centerTitle: true,
        ),
        drawer: const SettingsDrawer(),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: _destinations
              .map(
                (d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Internal helper class for navigation destinations.
class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
