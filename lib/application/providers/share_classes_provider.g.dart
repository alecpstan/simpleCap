// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_classes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shareClassesStreamHash() =>
    r'59a770c91c6ee391222ce8084dfae31794d6e568';

/// Watches all share classes for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
///
/// Copied from [shareClassesStream].
@ProviderFor(shareClassesStream)
final shareClassesStreamProvider =
    AutoDisposeStreamProvider<List<ShareClassesData>>.internal(
      shareClassesStream,
      name: r'shareClassesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shareClassesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShareClassesStreamRef =
    AutoDisposeStreamProviderRef<List<ShareClassesData>>;
String _$shareClassHash() => r'3faaeb7626427eac989a5ba73772d77b37c004b9';

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

/// Gets a single share class by ID.
///
/// Copied from [shareClass].
@ProviderFor(shareClass)
const shareClassProvider = ShareClassFamily();

/// Gets a single share class by ID.
///
/// Copied from [shareClass].
class ShareClassFamily extends Family<AsyncValue<ShareClassesData?>> {
  /// Gets a single share class by ID.
  ///
  /// Copied from [shareClass].
  const ShareClassFamily();

  /// Gets a single share class by ID.
  ///
  /// Copied from [shareClass].
  ShareClassProvider call(String id) {
    return ShareClassProvider(id);
  }

  @override
  ShareClassProvider getProviderOverride(
    covariant ShareClassProvider provider,
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
  String? get name => r'shareClassProvider';
}

/// Gets a single share class by ID.
///
/// Copied from [shareClass].
class ShareClassProvider extends AutoDisposeFutureProvider<ShareClassesData?> {
  /// Gets a single share class by ID.
  ///
  /// Copied from [shareClass].
  ShareClassProvider(String id)
    : this._internal(
        (ref) => shareClass(ref as ShareClassRef, id),
        from: shareClassProvider,
        name: r'shareClassProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$shareClassHash,
        dependencies: ShareClassFamily._dependencies,
        allTransitiveDependencies: ShareClassFamily._allTransitiveDependencies,
        id: id,
      );

  ShareClassProvider._internal(
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
    FutureOr<ShareClassesData?> Function(ShareClassRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShareClassProvider._internal(
        (ref) => create(ref as ShareClassRef),
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
  AutoDisposeFutureProviderElement<ShareClassesData?> createElement() {
    return _ShareClassProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShareClassProvider && other.id == id;
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
mixin ShareClassRef on AutoDisposeFutureProviderRef<ShareClassesData?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ShareClassProviderElement
    extends AutoDisposeFutureProviderElement<ShareClassesData?>
    with ShareClassRef {
  _ShareClassProviderElement(super.provider);

  @override
  String get id => (origin as ShareClassProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
