// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenarios_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calculateDilutionHash() => r'e46609ce20095aaa53726f662343babd87d2aec3';

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

/// Provider for dilution calculations.
///
/// Copied from [calculateDilution].
@ProviderFor(calculateDilution)
const calculateDilutionProvider = CalculateDilutionFamily();

/// Provider for dilution calculations.
///
/// Copied from [calculateDilution].
class CalculateDilutionFamily extends Family<AsyncValue<DilutionSummary?>> {
  /// Provider for dilution calculations.
  ///
  /// Copied from [calculateDilution].
  const CalculateDilutionFamily();

  /// Provider for dilution calculations.
  ///
  /// Copied from [calculateDilution].
  CalculateDilutionProvider call(DilutionScenario scenario) {
    return CalculateDilutionProvider(scenario);
  }

  @override
  CalculateDilutionProvider getProviderOverride(
    covariant CalculateDilutionProvider provider,
  ) {
    return call(provider.scenario);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calculateDilutionProvider';
}

/// Provider for dilution calculations.
///
/// Copied from [calculateDilution].
class CalculateDilutionProvider
    extends AutoDisposeFutureProvider<DilutionSummary?> {
  /// Provider for dilution calculations.
  ///
  /// Copied from [calculateDilution].
  CalculateDilutionProvider(DilutionScenario scenario)
    : this._internal(
        (ref) => calculateDilution(ref as CalculateDilutionRef, scenario),
        from: calculateDilutionProvider,
        name: r'calculateDilutionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$calculateDilutionHash,
        dependencies: CalculateDilutionFamily._dependencies,
        allTransitiveDependencies:
            CalculateDilutionFamily._allTransitiveDependencies,
        scenario: scenario,
      );

  CalculateDilutionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scenario,
  }) : super.internal();

  final DilutionScenario scenario;

  @override
  Override overrideWith(
    FutureOr<DilutionSummary?> Function(CalculateDilutionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalculateDilutionProvider._internal(
        (ref) => create(ref as CalculateDilutionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scenario: scenario,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DilutionSummary?> createElement() {
    return _CalculateDilutionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalculateDilutionProvider && other.scenario == scenario;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scenario.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalculateDilutionRef on AutoDisposeFutureProviderRef<DilutionSummary?> {
  /// The parameter `scenario` of this provider.
  DilutionScenario get scenario;
}

class _CalculateDilutionProviderElement
    extends AutoDisposeFutureProviderElement<DilutionSummary?>
    with CalculateDilutionRef {
  _CalculateDilutionProviderElement(super.provider);

  @override
  DilutionScenario get scenario =>
      (origin as CalculateDilutionProvider).scenario;
}

String _$calculateWaterfallHash() =>
    r'b530dd76f081d219635db03a92b5cf2f671647ae';

/// Provider for exit waterfall calculations.
///
/// Copied from [calculateWaterfall].
@ProviderFor(calculateWaterfall)
const calculateWaterfallProvider = CalculateWaterfallFamily();

/// Provider for exit waterfall calculations.
///
/// Copied from [calculateWaterfall].
class CalculateWaterfallFamily extends Family<AsyncValue<WaterfallSummary?>> {
  /// Provider for exit waterfall calculations.
  ///
  /// Copied from [calculateWaterfall].
  const CalculateWaterfallFamily();

  /// Provider for exit waterfall calculations.
  ///
  /// Copied from [calculateWaterfall].
  CalculateWaterfallProvider call(ExitScenario scenario) {
    return CalculateWaterfallProvider(scenario);
  }

  @override
  CalculateWaterfallProvider getProviderOverride(
    covariant CalculateWaterfallProvider provider,
  ) {
    return call(provider.scenario);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calculateWaterfallProvider';
}

/// Provider for exit waterfall calculations.
///
/// Copied from [calculateWaterfall].
class CalculateWaterfallProvider
    extends AutoDisposeFutureProvider<WaterfallSummary?> {
  /// Provider for exit waterfall calculations.
  ///
  /// Copied from [calculateWaterfall].
  CalculateWaterfallProvider(ExitScenario scenario)
    : this._internal(
        (ref) => calculateWaterfall(ref as CalculateWaterfallRef, scenario),
        from: calculateWaterfallProvider,
        name: r'calculateWaterfallProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$calculateWaterfallHash,
        dependencies: CalculateWaterfallFamily._dependencies,
        allTransitiveDependencies:
            CalculateWaterfallFamily._allTransitiveDependencies,
        scenario: scenario,
      );

  CalculateWaterfallProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scenario,
  }) : super.internal();

  final ExitScenario scenario;

  @override
  Override overrideWith(
    FutureOr<WaterfallSummary?> Function(CalculateWaterfallRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalculateWaterfallProvider._internal(
        (ref) => create(ref as CalculateWaterfallRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scenario: scenario,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WaterfallSummary?> createElement() {
    return _CalculateWaterfallProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalculateWaterfallProvider && other.scenario == scenario;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scenario.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalculateWaterfallRef on AutoDisposeFutureProviderRef<WaterfallSummary?> {
  /// The parameter `scenario` of this provider.
  ExitScenario get scenario;
}

class _CalculateWaterfallProviderElement
    extends AutoDisposeFutureProviderElement<WaterfallSummary?>
    with CalculateWaterfallRef {
  _CalculateWaterfallProviderElement(super.provider);

  @override
  ExitScenario get scenario => (origin as CalculateWaterfallProvider).scenario;
}

String _$savedScenariosStreamHash() =>
    r'14ac7b6a106be29d8b73e2354db6f00c7d86f6ea';

/// Stream of saved scenarios for the current company.
///
/// Copied from [savedScenariosStream].
@ProviderFor(savedScenariosStream)
final savedScenariosStreamProvider =
    AutoDisposeStreamProvider<List<SavedScenario>>.internal(
      savedScenariosStream,
      name: r'savedScenariosStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$savedScenariosStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavedScenariosStreamRef =
    AutoDisposeStreamProviderRef<List<SavedScenario>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
