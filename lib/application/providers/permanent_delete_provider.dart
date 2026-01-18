import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'permanent_delete_provider.g.dart';

const _deleteEnabledKey = 'delete_enabled';
const _showDraftKey = 'show_draft';

/// Provides the "Enable Delete" toggle.
///
/// When enabled, delete buttons are shown in the UI allowing permanent removal
/// of records and all their downstream events. When disabled, only cancel
/// operations are available (where applicable).
@riverpod
class DeleteEnabled extends _$DeleteEnabled {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deleteEnabledKey) ?? false;
  }

  /// Toggle delete enabled mode.
  Future<void> toggle() async {
    final currentValue = state.valueOrNull ?? false;
    final newValue = !currentValue;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deleteEnabledKey, newValue);

    state = AsyncData(newValue);
  }

  /// Set delete enabled mode explicitly.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deleteEnabledKey, enabled);

    state = AsyncData(enabled);
  }
}

/// Provides the "Show Draft" toggle.
///
/// When enabled, draft items (linked to draft rounds) are shown in the UI
/// and included in ownership/value calculations. When disabled, draft items
/// are hidden and excluded from calculations.
@riverpod
class ShowDraft extends _$ShowDraft {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showDraftKey) ?? true; // Default to showing drafts
  }

  /// Toggle show draft mode.
  Future<void> toggle() async {
    final currentValue = state.valueOrNull ?? true;
    final newValue = !currentValue;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showDraftKey, newValue);

    state = AsyncData(newValue);
  }

  /// Set show draft mode explicitly.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showDraftKey, enabled);

    state = AsyncData(enabled);
  }
}
