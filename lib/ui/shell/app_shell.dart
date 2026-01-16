import 'package:flutter/material.dart';
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
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

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
