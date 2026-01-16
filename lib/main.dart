import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'features/core/providers/core_cap_table_provider.dart';
import 'features/esop/providers/esop_provider.dart';
import 'features/convertibles/providers/convertibles_provider.dart';
import 'features/valuations/providers/valuations_provider.dart';
import 'features/scenarios/providers/scenarios_provider.dart';
import 'features/core/pages/dashboard_page.dart';
import 'features/core/pages/investors_page.dart';
import 'features/core/pages/rounds_page.dart';
import 'features/core/pages/share_value_page.dart';
import 'features/core/pages/cap_table_page.dart';
import 'shared/widgets/settings_drawer.dart';
import 'shared/widgets/help_icon.dart';

void main() async {
  // Ensure Flutter bindings are initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // Load help content
  await HelpContentService.instance.load();

  // Catch any errors during startup
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('Flutter error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    }
  };

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CoreCapTableProvider()..loadData(),
        ),
        ChangeNotifierProxyProvider<CoreCapTableProvider, EsopProvider>(
          create: (_) => EsopProvider(),
          update: (_, core, esop) {
            final provider = esop ?? EsopProvider();
            provider.updateFromCore(
              optionGrants: core.optionGrants,
              warrants: core.warrants,
              esopPoolChanges: core.esopPoolChanges,
              esopDilutionMethod: core.esopDilutionMethod,
              esopPoolPercent: core.esopPoolPercent,
              onSave: () => core.syncEsopData(
                optionGrants: provider.optionGrants,
                warrants: provider.warrants,
                esopPoolChanges: provider.esopPoolChanges,
                esopDilutionMethod: provider.esopDilutionMethod,
                esopPoolPercent: provider.esopPoolPercent,
              ),
              onAddTransaction: core.addTransaction,
              onDeleteTransaction: core.deleteTransactionById,
              getVestingSchedule: core.getVestingScheduleById,
              onDeleteVestingSchedule: (id) => core.deleteVestingSchedule(id),
              getLatestSharePrice: () => core.latestSharePrice,
            );
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<CoreCapTableProvider, ConvertiblesProvider>(
          create: (_) => ConvertiblesProvider(),
          update: (_, core, convertibles) {
            final provider = convertibles ?? ConvertiblesProvider();
            provider.updateFromCore(
              convertibles: core.convertibles,
              onSave: () => core.syncConvertiblesData(
                convertibles: provider.convertibles,
              ),
              onAddTransaction: core.addTransaction,
            );
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<CoreCapTableProvider, ValuationsProvider>(
          create: (_) => ValuationsProvider(),
          update: (_, core, valuations) {
            final provider = valuations ?? ValuationsProvider();
            provider.updateFromCore(
              valuations: core.valuations,
              onSave: () =>
                  core.syncValuationsData(valuations: provider.valuations),
            );
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<CoreCapTableProvider, ScenariosProvider>(
          create: (_) => ScenariosProvider(),
          update: (_, core, scenarios) {
            final provider = scenarios ?? ScenariosProvider();
            provider.updateCoreProvider(core);
            provider.loadSavedScenarios(core.savedScenarios);
            return provider;
          },
        ),
      ],
      child: Consumer<CoreCapTableProvider>(
        builder: (context, provider, _) {
          // Convert theme mode index to ThemeMode
          final themeMode = switch (provider.themeModeIndex) {
            1 => ThemeMode.light,
            2 => ThemeMode.dark,
            _ => ThemeMode.system,
          };

          return MaterialApp(
            title: 'Simple Cap',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              inputDecorationTheme: const InputDecorationTheme(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              inputDecorationTheme: const InputDecorationTheme(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            themeMode: themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    DashboardPage(),
    InvestorsPage(),
    RoundsPage(),
    ShareValuePage(),
    CapTablePage(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Overview',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outlined),
      selectedIcon: Icon(Icons.people),
      label: 'Investors',
    ),
    NavigationDestination(
      icon: Icon(Icons.layers_outlined),
      selectedIcon: Icon(Icons.layers),
      label: 'Rounds',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: 'Value',
    ),
    NavigationDestination(
      icon: Icon(Icons.table_chart_outlined),
      selectedIcon: Icon(Icons.table_chart),
      label: 'Cap Table',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
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
          elevation: 0,
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
          destinations: _destinations,
        ),
      ),
    );
  }
}
