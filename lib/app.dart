import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'ui/shell/app_shell.dart';

/// Root application widget.
class SimpleCap extends StatelessWidget {
  const SimpleCap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Cap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
