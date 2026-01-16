// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rounds_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roundsStreamHash() => r'ec72e7a2f972691bab75aa7edf9aa3e66ca4826d';

/// Watches all rounds for the current company.
///
/// Copied from [roundsStream].
@ProviderFor(roundsStream)
final roundsStreamProvider = AutoDisposeStreamProvider<List<Round>>.internal(
  roundsStream,
  name: r'roundsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roundsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RoundsStreamRef = AutoDisposeStreamProviderRef<List<Round>>;
String _$roundsByStatusHash() => r'7ac3fc40b41079220d8a4e8c5da92a10b834f135';

/// Gets rounds grouped by status.
///
/// Copied from [roundsByStatus].
@ProviderFor(roundsByStatus)
final roundsByStatusProvider =
    AutoDisposeFutureProvider<Map<String, List<Round>>>.internal(
      roundsByStatus,
      name: r'roundsByStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$roundsByStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RoundsByStatusRef =
    AutoDisposeFutureProviderRef<Map<String, List<Round>>>;
String _$roundHash() => r'3ef934e6c0331e6f3e94a364251ee2d668cecc8c';

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

/// Gets a single round by ID.
///
/// Copied from [round].
@ProviderFor(round)
const roundProvider = RoundFamily();

/// Gets a single round by ID.
///
/// Copied from [round].
class RoundFamily extends Family<AsyncValue<Round?>> {
  /// Gets a single round by ID.
  ///
  /// Copied from [round].
  const RoundFamily();

  /// Gets a single round by ID.
  ///
  /// Copied from [round].
  RoundProvider call(String id) {
    return RoundProvider(id);
  }

  @override
  RoundProvider getProviderOverride(covariant RoundProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'roundProvider';
}

/// Gets a single round by ID.
///
/// Copied from [round].
class RoundProvider extends AutoDisposeFutureProvider<Round?> {
  /// Gets a single round by ID.
  ///
  /// Copied from [round].
  RoundProvider(String id)
    : this._internal(
        (ref) => round(ref as RoundRef, id),
        from: roundProvider,
        name: r'roundProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$roundHash,
        dependencies: RoundFamily._dependencies,
        allTransitiveDependencies: RoundFamily._allTransitiveDependencies,
        id: id,
      );

  RoundProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(FutureOr<Round?> Function(RoundRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: RoundProvider._internal(
        (ref) => create(ref as RoundRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Round?> createElement() {
    return _RoundProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoundProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoundRef on AutoDisposeFutureProviderRef<Round?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _RoundProviderElement extends AutoDisposeFutureProviderElement<Round?>
    with RoundRef {
  _RoundProviderElement(super.provider);

  @override
  String get id => (origin as RoundProvider).id;
}

String _$roundsSummaryHash() => r'3318b269d60e89d11ed3c4d4eb77a8cb5a5d7970';

/// Calculates summary stats for all rounds.
///
/// Copied from [roundsSummary].
@ProviderFor(roundsSummary)
final roundsSummaryProvider = AutoDisposeFutureProvider<RoundsSummary>.internal(
  roundsSummary,
  name: r'roundsSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roundsSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RoundsSummaryRef = AutoDisposeFutureProviderRef<RoundsSummary>;
String _$roundMutationsHash() => r'545e29cabf7639c8c8d4097d49ee921d727edf9a';

/// Notifier for round mutations.
///
/// Copied from [RoundMutations].
@ProviderFor(RoundMutations)
final roundMutationsProvider =
    AutoDisposeAsyncNotifierProvider<RoundMutations, void>.internal(
      RoundMutations.new,
      name: r'roundMutationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$roundMutationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RoundMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
