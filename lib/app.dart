import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'ui/shell/app_shell.dart';

/// Root application widget wrapped in Riverpod ProviderScope.
class SimpleCap extends StatelessWidget {
  const SimpleCap({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Simple Cap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const AppShell(),
      ),
    );
  }
}
