// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isPremiumEnabledHash() => r'6865238acc44f6202542aa168f99b2d61cb33d87';

/// Convenient provider that returns true if premium is enabled.
///
/// Copied from [isPremiumEnabled].
@ProviderFor(isPremiumEnabled)
final isPremiumEnabledProvider = AutoDisposeProvider<bool>.internal(
  isPremiumEnabled,
  name: r'isPremiumEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isPremiumEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPremiumEnabledRef = AutoDisposeProviderRef<bool>;
String _$isFeatureLockedHash() => r'2a0d9cd08c8e6d6af68831b0a577a6b190015b62';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider to check if a specific feature is locked (not available without premium).
///
/// Copied from [isFeatureLocked].
@ProviderFor(isFeatureLocked)
const isFeatureLockedProvider = IsFeatureLockedFamily();

/// Provider to check if a specific feature is locked (not available without premium).
///
/// Copied from [isFeatureLocked].
class IsFeatureLockedFamily extends Family<bool> {
  /// Provider to check if a specific feature is locked (not available without premium).
  ///
  /// Copied from [isFeatureLocked].
  const IsFeatureLockedFamily();

  /// Provider to check if a specific feature is locked (not available without premium).
  ///
  /// Copied from [isFeatureLocked].
  IsFeatureLockedProvider call(PremiumFeature feature) {
    return IsFeatureLockedProvider(feature);
  }

  @override
  IsFeatureLockedProvider getProviderOverride(
    covariant IsFeatureLockedProvider provider,
  ) {
    return call(provider.feature);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isFeatureLockedProvider';
}

/// Provider to check if a specific feature is locked (not available without premium).
///
/// Copied from [isFeatureLocked].
class IsFeatureLockedProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if a specific feature is locked (not available without premium).
  ///
  /// Copied from [isFeatureLocked].
  IsFeatureLockedProvider(PremiumFeature feature)
    : this._internal(
        (ref) => isFeatureLocked(ref as IsFeatureLockedRef, feature),
        from: isFeatureLockedProvider,
        name: r'isFeatureLockedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isFeatureLockedHash,
        dependencies: IsFeatureLockedFamily._dependencies,
        allTransitiveDependencies:
            IsFeatureLockedFamily._allTransitiveDependencies,
        feature: feature,
      );

  IsFeatureLockedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feature,
  }) : super.internal();

  final PremiumFeature feature;

  @override
  Override overrideWith(bool Function(IsFeatureLockedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsFeatureLockedProvider._internal(
        (ref) => create(ref as IsFeatureLockedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feature: feature,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsFeatureLockedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFeatureLockedProvider && other.feature == feature;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feature.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsFeatureLockedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `feature` of this provider.
  PremiumFeature get feature;
}

class _IsFeatureLockedProviderElement extends AutoDisposeProviderElement<bool>
    with IsFeatureLockedRef {
  _IsFeatureLockedProviderElement(super.provider);

  @override
  PremiumFeature get feature => (origin as IsFeatureLockedProvider).feature;
}

String _$premiumNotifierHash() => r'53cf1bdef501efca091430183997e40f3157f947';

/// Provides whether premium features are enabled.
///
/// Persists the user's preference to SharedPreferences.
/// Defaults to false (premium disabled) if no preference is stored.
///
/// Copied from [PremiumNotifier].
@ProviderFor(PremiumNotifier)
final premiumNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PremiumNotifier, bool>.internal(
      PremiumNotifier.new,
      name: r'premiumNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$premiumNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PremiumNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
