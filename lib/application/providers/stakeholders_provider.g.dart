// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stakeholders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stakeholdersStreamHash() =>
    r'98b2159f93887b769495f5a2c91906c2cc2add77';

/// Watches all stakeholders for the current company.
///
/// Copied from [stakeholdersStream].
@ProviderFor(stakeholdersStream)
final stakeholdersStreamProvider =
    AutoDisposeStreamProvider<List<Stakeholder>>.internal(
      stakeholdersStream,
      name: r'stakeholdersStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stakeholdersStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StakeholdersStreamRef = AutoDisposeStreamProviderRef<List<Stakeholder>>;
String _$stakeholdersByTypeHash() =>
    r'50e9e1cfb60abd3dab993b7b3a325b5111e3627b';

/// Gets stakeholders grouped by type.
///
/// Copied from [stakeholdersByType].
@ProviderFor(stakeholdersByType)
final stakeholdersByTypeProvider =
    AutoDisposeFutureProvider<Map<String, List<Stakeholder>>>.internal(
      stakeholdersByType,
      name: r'stakeholdersByTypeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stakeholdersByTypeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StakeholdersByTypeRef =
    AutoDisposeFutureProviderRef<Map<String, List<Stakeholder>>>;
String _$stakeholderHash() => r'a8baf44a68c41f98ffe9564934619503f7e2a766';

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

/// Gets a single stakeholder by ID.
///
/// Copied from [stakeholder].
@ProviderFor(stakeholder)
const stakeholderProvider = StakeholderFamily();

/// Gets a single stakeholder by ID.
///
/// Copied from [stakeholder].
class StakeholderFamily extends Family<AsyncValue<Stakeholder?>> {
  /// Gets a single stakeholder by ID.
  ///
  /// Copied from [stakeholder].
  const StakeholderFamily();

  /// Gets a single stakeholder by ID.
  ///
  /// Copied from [stakeholder].
  StakeholderProvider call(String id) {
    return StakeholderProvider(id);
  }

  @override
  StakeholderProvider getProviderOverride(
    covariant StakeholderProvider provider,
  ) {
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
  String? get name => r'stakeholderProvider';
}

/// Gets a single stakeholder by ID.
///
/// Copied from [stakeholder].
class StakeholderProvider extends AutoDisposeFutureProvider<Stakeholder?> {
  /// Gets a single stakeholder by ID.
  ///
  /// Copied from [stakeholder].
  StakeholderProvider(String id)
    : this._internal(
        (ref) => stakeholder(ref as StakeholderRef, id),
        from: stakeholderProvider,
        name: r'stakeholderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$stakeholderHash,
        dependencies: StakeholderFamily._dependencies,
        allTransitiveDependencies: StakeholderFamily._allTransitiveDependencies,
        id: id,
      );

  StakeholderProvider._internal(
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
  Override overrideWith(
    FutureOr<Stakeholder?> Function(StakeholderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StakeholderProvider._internal(
        (ref) => create(ref as StakeholderRef),
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
  AutoDisposeFutureProviderElement<Stakeholder?> createElement() {
    return _StakeholderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StakeholderProvider && other.id == id;
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
mixin StakeholderRef on AutoDisposeFutureProviderRef<Stakeholder?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _StakeholderProviderElement
    extends AutoDisposeFutureProviderElement<Stakeholder?>
    with StakeholderRef {
  _StakeholderProviderElement(super.provider);

  @override
  String get id => (origin as StakeholderProvider).id;
}

String _$stakeholderMutationsHash() =>
    r'd19c04d214eea4714d038306d9fc9f9585020eec';

/// Notifier for stakeholder mutations.
///
/// Copied from [StakeholderMutations].
@ProviderFor(StakeholderMutations)
final stakeholderMutationsProvider =
    AutoDisposeAsyncNotifierProvider<StakeholderMutations, void>.internal(
      StakeholderMutations.new,
      name: r'stakeholderMutationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stakeholderMutationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StakeholderMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
