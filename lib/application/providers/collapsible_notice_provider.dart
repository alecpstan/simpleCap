import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'collapsible_notice_provider.g.dart';

const _collapsedKeyPrefix = 'collapsible_notice_collapsed_';

/// Provider that manages the collapsed state of notices with persist keys.
///
/// This allows the collapsed/expanded state of [CollapsibleNotice] widgets
/// to persist between page changes and app restarts.
@riverpod
class CollapsedNoticeState extends _$CollapsedNoticeState {
  @override
  Future<Map<String, bool>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> states = {};

    // Load all collapsed states from preferences
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_collapsedKeyPrefix)) {
        final persistKey = key.substring(_collapsedKeyPrefix.length);
        states[persistKey] = prefs.getBool(key) ?? false;
      }
    }

    return states;
  }

  /// Get the collapsed state for a specific persist key.
  bool isCollapsed(String persistKey) {
    return state.valueOrNull?[persistKey] ?? false;
  }

  /// Set the collapsed state for a specific persist key.
  Future<void> setCollapsed(String persistKey, bool collapsed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_collapsedKeyPrefix$persistKey', collapsed);

    final currentStates = state.valueOrNull ?? {};
    state = AsyncData({...currentStates, persistKey: collapsed});
  }

  /// Toggle the collapsed state for a specific persist key.
  Future<void> toggle(String persistKey) async {
    final currentValue = isCollapsed(persistKey);
    await setCollapsed(persistKey, !currentValue);
  }
}

/// Convenience provider to get the collapsed state for a specific key.
@riverpod
bool noticeIsCollapsed(Ref ref, String persistKey) {
  final states = ref.watch(collapsedNoticeStateProvider);
  return states.valueOrNull?[persistKey] ?? false;
}
