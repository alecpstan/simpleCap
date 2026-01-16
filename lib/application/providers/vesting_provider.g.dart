// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vesting_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vestingSchedulesStreamHash() =>
    r'1ed7472478491820a3985107f57d942037b4bc01';

/// Watches all vesting schedules for the current company.
///
/// Copied from [vestingSchedulesStream].
@ProviderFor(vestingSchedulesStream)
final vestingSchedulesStreamProvider =
    AutoDisposeStreamProvider<List<VestingSchedule>>.internal(
      vestingSchedulesStream,
      name: r'vestingSchedulesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vestingSchedulesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VestingSchedulesStreamRef =
    AutoDisposeStreamProviderRef<List<VestingSchedule>>;
String _$vestingScheduleHash() => r'56f49848a8f9b12d998ab075093c3e161ebc7532';

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

/// Gets a specific vesting schedule by ID.
///
/// Copied from [vestingSchedule].
@ProviderFor(vestingSchedule)
const vestingScheduleProvider = VestingScheduleFamily();

/// Gets a specific vesting schedule by ID.
///
/// Copied from [vestingSchedule].
class VestingScheduleFamily extends Family<VestingSchedule?> {
  /// Gets a specific vesting schedule by ID.
  ///
  /// Copied from [vestingSchedule].
  const VestingScheduleFamily();

  /// Gets a specific vesting schedule by ID.
  ///
  /// Copied from [vestingSchedule].
  VestingScheduleProvider call(String? scheduleId) {
    return VestingScheduleProvider(scheduleId);
  }

  @override
  VestingScheduleProvider getProviderOverride(
    covariant VestingScheduleProvider provider,
  ) {
    return call(provider.scheduleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vestingScheduleProvider';
}

/// Gets a specific vesting schedule by ID.
///
/// Copied from [vestingSchedule].
class VestingScheduleProvider extends AutoDisposeProvider<VestingSchedule?> {
  /// Gets a specific vesting schedule by ID.
  ///
  /// Copied from [vestingSchedule].
  VestingScheduleProvider(String? scheduleId)
    : this._internal(
        (ref) => vestingSchedule(ref as VestingScheduleRef, scheduleId),
        from: vestingScheduleProvider,
        name: r'vestingScheduleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vestingScheduleHash,
        dependencies: VestingScheduleFamily._dependencies,
        allTransitiveDependencies:
            VestingScheduleFamily._allTransitiveDependencies,
        scheduleId: scheduleId,
      );

  VestingScheduleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scheduleId,
  }) : super.internal();

  final String? scheduleId;

  @override
  Override overrideWith(
    VestingSchedule? Function(VestingScheduleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VestingScheduleProvider._internal(
        (ref) => create(ref as VestingScheduleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scheduleId: scheduleId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<VestingSchedule?> createElement() {
    return _VestingScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VestingScheduleProvider && other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scheduleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VestingScheduleRef on AutoDisposeProviderRef<VestingSchedule?> {
  /// The parameter `scheduleId` of this provider.
  String? get scheduleId;
}

class _VestingScheduleProviderElement
    extends AutoDisposeProviderElement<VestingSchedule?>
    with VestingScheduleRef {
  _VestingScheduleProviderElement(super.provider);

  @override
  String? get scheduleId => (origin as VestingScheduleProvider).scheduleId;
}

String _$calculateVestingStatusHash() =>
    r'e860bf9e3b026c1b16a2639cc4d8d33cd1bc752f';

/// Calculates vesting status for an option grant.
///
/// Copied from [calculateVestingStatus].
@ProviderFor(calculateVestingStatus)
const calculateVestingStatusProvider = CalculateVestingStatusFamily();

/// Calculates vesting status for an option grant.
///
/// Copied from [calculateVestingStatus].
class CalculateVestingStatusFamily extends Family<VestingStatus> {
  /// Calculates vesting status for an option grant.
  ///
  /// Copied from [calculateVestingStatus].
  const CalculateVestingStatusFamily();

  /// Calculates vesting status for an option grant.
  ///
  /// Copied from [calculateVestingStatus].
  CalculateVestingStatusProvider call({
    required int totalQuantity,
    required DateTime grantDate,
    required String? vestingScheduleId,
    DateTime? asOfDate,
  }) {
    return CalculateVestingStatusProvider(
      totalQuantity: totalQuantity,
      grantDate: grantDate,
      vestingScheduleId: vestingScheduleId,
      asOfDate: asOfDate,
    );
  }

  @override
  CalculateVestingStatusProvider getProviderOverride(
    covariant CalculateVestingStatusProvider provider,
  ) {
    return call(
      totalQuantity: provider.totalQuantity,
      grantDate: provider.grantDate,
      vestingScheduleId: provider.vestingScheduleId,
      asOfDate: provider.asOfDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calculateVestingStatusProvider';
}

/// Calculates vesting status for an option grant.
///
/// Copied from [calculateVestingStatus].
class CalculateVestingStatusProvider
    extends AutoDisposeProvider<VestingStatus> {
  /// Calculates vesting status for an option grant.
  ///
  /// Copied from [calculateVestingStatus].
  CalculateVestingStatusProvider({
    required int totalQuantity,
    required DateTime grantDate,
    required String? vestingScheduleId,
    DateTime? asOfDate,
  }) : this._internal(
         (ref) => calculateVestingStatus(
           ref as CalculateVestingStatusRef,
           totalQuantity: totalQuantity,
           grantDate: grantDate,
           vestingScheduleId: vestingScheduleId,
           asOfDate: asOfDate,
         ),
         from: calculateVestingStatusProvider,
         name: r'calculateVestingStatusProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$calculateVestingStatusHash,
         dependencies: CalculateVestingStatusFamily._dependencies,
         allTransitiveDependencies:
             CalculateVestingStatusFamily._allTransitiveDependencies,
         totalQuantity: totalQuantity,
         grantDate: grantDate,
         vestingScheduleId: vestingScheduleId,
         asOfDate: asOfDate,
       );

  CalculateVestingStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.totalQuantity,
    required this.grantDate,
    required this.vestingScheduleId,
    required this.asOfDate,
  }) : super.internal();

  final int totalQuantity;
  final DateTime grantDate;
  final String? vestingScheduleId;
  final DateTime? asOfDate;

  @override
  Override overrideWith(
    VestingStatus Function(CalculateVestingStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalculateVestingStatusProvider._internal(
        (ref) => create(ref as CalculateVestingStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        totalQuantity: totalQuantity,
        grantDate: grantDate,
        vestingScheduleId: vestingScheduleId,
        asOfDate: asOfDate,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<VestingStatus> createElement() {
    return _CalculateVestingStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalculateVestingStatusProvider &&
        other.totalQuantity == totalQuantity &&
        other.grantDate == grantDate &&
        other.vestingScheduleId == vestingScheduleId &&
        other.asOfDate == asOfDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, totalQuantity.hashCode);
    hash = _SystemHash.combine(hash, grantDate.hashCode);
    hash = _SystemHash.combine(hash, vestingScheduleId.hashCode);
    hash = _SystemHash.combine(hash, asOfDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalculateVestingStatusRef on AutoDisposeProviderRef<VestingStatus> {
  /// The parameter `totalQuantity` of this provider.
  int get totalQuantity;

  /// The parameter `grantDate` of this provider.
  DateTime get grantDate;

  /// The parameter `vestingScheduleId` of this provider.
  String? get vestingScheduleId;

  /// The parameter `asOfDate` of this provider.
  DateTime? get asOfDate;
}

class _CalculateVestingStatusProviderElement
    extends AutoDisposeProviderElement<VestingStatus>
    with CalculateVestingStatusRef {
  _CalculateVestingStatusProviderElement(super.provider);

  @override
  int get totalQuantity =>
      (origin as CalculateVestingStatusProvider).totalQuantity;
  @override
  DateTime get grantDate =>
      (origin as CalculateVestingStatusProvider).grantDate;
  @override
  String? get vestingScheduleId =>
      (origin as CalculateVestingStatusProvider).vestingScheduleId;
  @override
  DateTime? get asOfDate => (origin as CalculateVestingStatusProvider).asOfDate;
}

String _$vestingScheduleMutationsHash() =>
    r'df23227c35603ea2b45e068f7675c7f879a681f9';

/// Notifier for vesting schedule mutations.
///
/// Copied from [VestingScheduleMutations].
@ProviderFor(VestingScheduleMutations)
final vestingScheduleMutationsProvider =
    AutoDisposeAsyncNotifierProvider<VestingScheduleMutations, void>.internal(
      VestingScheduleMutations.new,
      name: r'vestingScheduleMutationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vestingScheduleMutationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VestingScheduleMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
