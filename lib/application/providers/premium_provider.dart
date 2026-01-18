import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'premium_provider.g.dart';

const _premiumEnabledKey = 'premium_enabled';

/// Provides whether premium features are enabled.
///
/// Persists the user's preference to SharedPreferences.
/// Defaults to false (premium disabled) if no preference is stored.
@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumEnabledKey) ?? false;
  }

  /// Toggle premium mode.
  Future<void> toggle() async {
    final currentValue = state.valueOrNull ?? false;
    final newValue = !currentValue;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumEnabledKey, newValue);

    state = AsyncData(newValue);
  }

  /// Set premium mode explicitly.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumEnabledKey, enabled);

    state = AsyncData(enabled);
  }
}

/// Convenient provider that returns true if premium is enabled.
@riverpod
bool isPremiumEnabled(IsPremiumEnabledRef ref) {
  final premiumAsync = ref.watch(premiumNotifierProvider);
  return premiumAsync.valueOrNull ?? false;
}

/// Premium feature identifiers for checking specific feature locks.
enum PremiumFeature {
  scenarios,
  valuations,
  options,
  esopPools,
  warrants,
  convertibles,
}

/// Provider to check if a specific feature is locked (not available without premium).
@riverpod
bool isFeatureLocked(IsFeatureLockedRef ref, PremiumFeature feature) {
  final isPremium = ref.watch(isPremiumEnabledProvider);

  // These features require premium
  const lockedFeatures = {
    PremiumFeature.scenarios,
    PremiumFeature.options,
    PremiumFeature.esopPools,
    PremiumFeature.warrants,
    PremiumFeature.convertibles,
  };

  // If premium is enabled, nothing is locked
  if (isPremium) return false;

  // Otherwise, check if this feature requires premium
  return lockedFeatures.contains(feature);
}
