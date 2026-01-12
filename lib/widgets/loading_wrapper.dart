import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cap_table_provider.dart';

/// Wrapper that handles loading state
class LoadingWrapper extends StatelessWidget {
  final Widget child;

  const LoadingWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return child;
      },
    );
  }
}

/// A page scaffold with loading state and optional FAB
class PageScaffold extends StatelessWidget {
  final Widget body;
  final Widget? emptyState;
  final bool isEmpty;
  final FloatingActionButton? floatingActionButton;

  const PageScaffold({
    super.key,
    required this.body,
    this.emptyState,
    this.isEmpty = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: isEmpty && emptyState != null ? emptyState! : body,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
