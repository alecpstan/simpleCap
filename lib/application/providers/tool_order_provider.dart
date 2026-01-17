import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'tool_order_provider.g.dart';

const _toolOrderKey = 'dashboard_tool_order';

/// Default tool order (by tool id).
const List<String> defaultToolOrder = [
  'valuations',
  'scenarios',
  'options',
  'esop_pools',
  'vesting',
  'convertibles',
  'warrants',
  'transfers',
  'timeline',
];

/// Provides the user's preferred tool order for the dashboard.
///
/// Persists the order to SharedPreferences.
@riverpod
class ToolOrderNotifier extends _$ToolOrderNotifier {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final orderJson = prefs.getString(_toolOrderKey);
    if (orderJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(orderJson);
        final order = decoded.cast<String>();
        // Ensure all default tools are present (in case new tools were added)
        final missingTools = defaultToolOrder
            .where((t) => !order.contains(t))
            .toList();
        return [...order, ...missingTools];
      } catch (_) {
        return defaultToolOrder;
      }
    }
    return defaultToolOrder;
  }

  /// Update the tool order.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentOrder = List<String>.from(
      state.valueOrNull ?? defaultToolOrder,
    );

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = currentOrder.removeAt(oldIndex);
    currentOrder.insert(newIndex, item);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_toolOrderKey, jsonEncode(currentOrder));

    state = AsyncData(currentOrder);
  }

  /// Reset to default order.
  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_toolOrderKey);
    state = AsyncData(defaultToolOrder);
  }
}
