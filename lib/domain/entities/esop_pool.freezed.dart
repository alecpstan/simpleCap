// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'esop_pool.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EsopPool _$EsopPoolFromJson(Map<String, dynamic> json) {
  return _EsopPool.fromJson(json);
}

/// @nodoc
mixin _$EsopPool {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;

  /// Name of the pool (e.g., "2024 ESOP", "Employee Option Pool").
  String get name => throw _privateConstructorUsedError;

  /// Current status of the pool.
  EsopPoolStatus get status => throw _privateConstructorUsedError;

  /// Total number of shares/options reserved in this pool.
  int get poolSize => throw _privateConstructorUsedError;

  /// Target percentage of fully diluted capital (for reference).
  /// Used for planning; actual % varies with cap table changes.
  double? get targetPercentage => throw _privateConstructorUsedError;

  /// Date the pool was established.
  DateTime get establishedDate => throw _privateConstructorUsedError;

  /// Board/shareholder resolution reference.
  String? get resolutionReference => throw _privateConstructorUsedError;

  /// Associated round (if pool was created as part of a round).
  String? get roundId => throw _privateConstructorUsedError;

  /// Default vesting schedule for grants from this pool.
  String? get defaultVestingScheduleId => throw _privateConstructorUsedError;

  /// Default strike price method.
  /// 'fmv' = Fair Market Value at grant, 'fixed' = use defaultStrikePrice
  String get strikePriceMethod => throw _privateConstructorUsedError;

  /// Fixed strike price (if strikePriceMethod is 'fixed').
  double? get defaultStrikePrice => throw _privateConstructorUsedError;

  /// Default expiry period in years from grant date.
  int get defaultExpiryYears => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this EsopPool to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EsopPool
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EsopPoolCopyWith<EsopPool> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EsopPoolCopyWith<$Res> {
  factory $EsopPoolCopyWith(EsopPool value, $Res Function(EsopPool) then) =
      _$EsopPoolCopyWithImpl<$Res, EsopPool>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    EsopPoolStatus status,
    int poolSize,
    double? targetPercentage,
    DateTime establishedDate,
    String? resolutionReference,
    String? roundId,
    String? defaultVestingScheduleId,
    String strikePriceMethod,
    double? defaultStrikePrice,
    int defaultExpiryYears,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$EsopPoolCopyWithImpl<$Res, $Val extends EsopPool>
    implements $EsopPoolCopyWith<$Res> {
  _$EsopPoolCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EsopPool
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? status = null,
    Object? poolSize = null,
    Object? targetPercentage = freezed,
    Object? establishedDate = null,
    Object? resolutionReference = freezed,
    Object? roundId = freezed,
    Object? defaultVestingScheduleId = freezed,
    Object? strikePriceMethod = null,
    Object? defaultStrikePrice = freezed,
    Object? defaultExpiryYears = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            companyId: null == companyId
                ? _value.companyId
                : companyId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EsopPoolStatus,
            poolSize: null == poolSize
                ? _value.poolSize
                : poolSize // ignore: cast_nullable_to_non_nullable
                      as int,
            targetPercentage: freezed == targetPercentage
                ? _value.targetPercentage
                : targetPercentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            establishedDate: null == establishedDate
                ? _value.establishedDate
                : establishedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            resolutionReference: freezed == resolutionReference
                ? _value.resolutionReference
                : resolutionReference // ignore: cast_nullable_to_non_nullable
                      as String?,
            roundId: freezed == roundId
                ? _value.roundId
                : roundId // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultVestingScheduleId: freezed == defaultVestingScheduleId
                ? _value.defaultVestingScheduleId
                : defaultVestingScheduleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            strikePriceMethod: null == strikePriceMethod
                ? _value.strikePriceMethod
                : strikePriceMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultStrikePrice: freezed == defaultStrikePrice
                ? _value.defaultStrikePrice
                : defaultStrikePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            defaultExpiryYears: null == defaultExpiryYears
                ? _value.defaultExpiryYears
                : defaultExpiryYears // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EsopPoolImplCopyWith<$Res>
    implements $EsopPoolCopyWith<$Res> {
  factory _$$EsopPoolImplCopyWith(
    _$EsopPoolImpl value,
    $Res Function(_$EsopPoolImpl) then,
  ) = __$$EsopPoolImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    EsopPoolStatus status,
    int poolSize,
    double? targetPercentage,
    DateTime establishedDate,
    String? resolutionReference,
    String? roundId,
    String? defaultVestingScheduleId,
    String strikePriceMethod,
    double? defaultStrikePrice,
    int defaultExpiryYears,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$EsopPoolImplCopyWithImpl<$Res>
    extends _$EsopPoolCopyWithImpl<$Res, _$EsopPoolImpl>
    implements _$$EsopPoolImplCopyWith<$Res> {
  __$$EsopPoolImplCopyWithImpl(
    _$EsopPoolImpl _value,
    $Res Function(_$EsopPoolImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EsopPool
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? status = null,
    Object? poolSize = null,
    Object? targetPercentage = freezed,
    Object? establishedDate = null,
    Object? resolutionReference = freezed,
    Object? roundId = freezed,
    Object? defaultVestingScheduleId = freezed,
    Object? strikePriceMethod = null,
    Object? defaultStrikePrice = freezed,
    Object? defaultExpiryYears = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$EsopPoolImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EsopPoolStatus,
        poolSize: null == poolSize
            ? _value.poolSize
            : poolSize // ignore: cast_nullable_to_non_nullable
                  as int,
        targetPercentage: freezed == targetPercentage
            ? _value.targetPercentage
            : targetPercentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        establishedDate: null == establishedDate
            ? _value.establishedDate
            : establishedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        resolutionReference: freezed == resolutionReference
            ? _value.resolutionReference
            : resolutionReference // ignore: cast_nullable_to_non_nullable
                  as String?,
        roundId: freezed == roundId
            ? _value.roundId
            : roundId // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultVestingScheduleId: freezed == defaultVestingScheduleId
            ? _value.defaultVestingScheduleId
            : defaultVestingScheduleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        strikePriceMethod: null == strikePriceMethod
            ? _value.strikePriceMethod
            : strikePriceMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultStrikePrice: freezed == defaultStrikePrice
            ? _value.defaultStrikePrice
            : defaultStrikePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        defaultExpiryYears: null == defaultExpiryYears
            ? _value.defaultExpiryYears
            : defaultExpiryYears // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EsopPoolImpl extends _EsopPool {
  const _$EsopPoolImpl({
    required this.id,
    required this.companyId,
    required this.name,
    this.status = EsopPoolStatus.draft,
    required this.poolSize,
    this.targetPercentage,
    required this.establishedDate,
    this.resolutionReference,
    this.roundId,
    this.defaultVestingScheduleId,
    this.strikePriceMethod = 'fmv',
    this.defaultStrikePrice,
    this.defaultExpiryYears = 10,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$EsopPoolImpl.fromJson(Map<String, dynamic> json) =>
      _$$EsopPoolImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;

  /// Name of the pool (e.g., "2024 ESOP", "Employee Option Pool").
  @override
  final String name;

  /// Current status of the pool.
  @override
  @JsonKey()
  final EsopPoolStatus status;

  /// Total number of shares/options reserved in this pool.
  @override
  final int poolSize;

  /// Target percentage of fully diluted capital (for reference).
  /// Used for planning; actual % varies with cap table changes.
  @override
  final double? targetPercentage;

  /// Date the pool was established.
  @override
  final DateTime establishedDate;

  /// Board/shareholder resolution reference.
  @override
  final String? resolutionReference;

  /// Associated round (if pool was created as part of a round).
  @override
  final String? roundId;

  /// Default vesting schedule for grants from this pool.
  @override
  final String? defaultVestingScheduleId;

  /// Default strike price method.
  /// 'fmv' = Fair Market Value at grant, 'fixed' = use defaultStrikePrice
  @override
  @JsonKey()
  final String strikePriceMethod;

  /// Fixed strike price (if strikePriceMethod is 'fixed').
  @override
  final double? defaultStrikePrice;

  /// Default expiry period in years from grant date.
  @override
  @JsonKey()
  final int defaultExpiryYears;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'EsopPool(id: $id, companyId: $companyId, name: $name, status: $status, poolSize: $poolSize, targetPercentage: $targetPercentage, establishedDate: $establishedDate, resolutionReference: $resolutionReference, roundId: $roundId, defaultVestingScheduleId: $defaultVestingScheduleId, strikePriceMethod: $strikePriceMethod, defaultStrikePrice: $defaultStrikePrice, defaultExpiryYears: $defaultExpiryYears, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EsopPoolImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.poolSize, poolSize) ||
                other.poolSize == poolSize) &&
            (identical(other.targetPercentage, targetPercentage) ||
                other.targetPercentage == targetPercentage) &&
            (identical(other.establishedDate, establishedDate) ||
                other.establishedDate == establishedDate) &&
            (identical(other.resolutionReference, resolutionReference) ||
                other.resolutionReference == resolutionReference) &&
            (identical(other.roundId, roundId) || other.roundId == roundId) &&
            (identical(
                  other.defaultVestingScheduleId,
                  defaultVestingScheduleId,
                ) ||
                other.defaultVestingScheduleId == defaultVestingScheduleId) &&
            (identical(other.strikePriceMethod, strikePriceMethod) ||
                other.strikePriceMethod == strikePriceMethod) &&
            (identical(other.defaultStrikePrice, defaultStrikePrice) ||
                other.defaultStrikePrice == defaultStrikePrice) &&
            (identical(other.defaultExpiryYears, defaultExpiryYears) ||
                other.defaultExpiryYears == defaultExpiryYears) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyId,
    name,
    status,
    poolSize,
    targetPercentage,
    establishedDate,
    resolutionReference,
    roundId,
    defaultVestingScheduleId,
    strikePriceMethod,
    defaultStrikePrice,
    defaultExpiryYears,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of EsopPool
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EsopPoolImplCopyWith<_$EsopPoolImpl> get copyWith =>
      __$$EsopPoolImplCopyWithImpl<_$EsopPoolImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EsopPoolImplToJson(this);
  }
}

abstract class _EsopPool extends EsopPool {
  const factory _EsopPool({
    required final String id,
    required final String companyId,
    required final String name,
    final EsopPoolStatus status,
    required final int poolSize,
    final double? targetPercentage,
    required final DateTime establishedDate,
    final String? resolutionReference,
    final String? roundId,
    final String? defaultVestingScheduleId,
    final String strikePriceMethod,
    final double? defaultStrikePrice,
    final int defaultExpiryYears,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$EsopPoolImpl;
  const _EsopPool._() : super._();

  factory _EsopPool.fromJson(Map<String, dynamic> json) =
      _$EsopPoolImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;

  /// Name of the pool (e.g., "2024 ESOP", "Employee Option Pool").
  @override
  String get name;

  /// Current status of the pool.
  @override
  EsopPoolStatus get status;

  /// Total number of shares/options reserved in this pool.
  @override
  int get poolSize;

  /// Target percentage of fully diluted capital (for reference).
  /// Used for planning; actual % varies with cap table changes.
  @override
  double? get targetPercentage;

  /// Date the pool was established.
  @override
  DateTime get establishedDate;

  /// Board/shareholder resolution reference.
  @override
  String? get resolutionReference;

  /// Associated round (if pool was created as part of a round).
  @override
  String? get roundId;

  /// Default vesting schedule for grants from this pool.
  @override
  String? get defaultVestingScheduleId;

  /// Default strike price method.
  /// 'fmv' = Fair Market Value at grant, 'fixed' = use defaultStrikePrice
  @override
  String get strikePriceMethod;

  /// Fixed strike price (if strikePriceMethod is 'fixed').
  @override
  double? get defaultStrikePrice;

  /// Default expiry period in years from grant date.
  @override
  int get defaultExpiryYears;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of EsopPool
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EsopPoolImplCopyWith<_$EsopPoolImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EsopPoolCreationData _$EsopPoolCreationDataFromJson(Map<String, dynamic> json) {
  return _EsopPoolCreationData.fromJson(json);
}

/// @nodoc
mixin _$EsopPoolCreationData {
  String get poolId => throw _privateConstructorUsedError;
  int get poolSize => throw _privateConstructorUsedError;
  double? get targetPercentage => throw _privateConstructorUsedError;
  String? get resolutionReference => throw _privateConstructorUsedError;

  /// Serializes this EsopPoolCreationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EsopPoolCreationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EsopPoolCreationDataCopyWith<EsopPoolCreationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EsopPoolCreationDataCopyWith<$Res> {
  factory $EsopPoolCreationDataCopyWith(
    EsopPoolCreationData value,
    $Res Function(EsopPoolCreationData) then,
  ) = _$EsopPoolCreationDataCopyWithImpl<$Res, EsopPoolCreationData>;
  @useResult
  $Res call({
    String poolId,
    int poolSize,
    double? targetPercentage,
    String? resolutionReference,
  });
}

/// @nodoc
class _$EsopPoolCreationDataCopyWithImpl<
  $Res,
  $Val extends EsopPoolCreationData
>
    implements $EsopPoolCreationDataCopyWith<$Res> {
  _$EsopPoolCreationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EsopPoolCreationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poolId = null,
    Object? poolSize = null,
    Object? targetPercentage = freezed,
    Object? resolutionReference = freezed,
  }) {
    return _then(
      _value.copyWith(
            poolId: null == poolId
                ? _value.poolId
                : poolId // ignore: cast_nullable_to_non_nullable
                      as String,
            poolSize: null == poolSize
                ? _value.poolSize
                : poolSize // ignore: cast_nullable_to_non_nullable
                      as int,
            targetPercentage: freezed == targetPercentage
                ? _value.targetPercentage
                : targetPercentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            resolutionReference: freezed == resolutionReference
                ? _value.resolutionReference
                : resolutionReference // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EsopPoolCreationDataImplCopyWith<$Res>
    implements $EsopPoolCreationDataCopyWith<$Res> {
  factory _$$EsopPoolCreationDataImplCopyWith(
    _$EsopPoolCreationDataImpl value,
    $Res Function(_$EsopPoolCreationDataImpl) then,
  ) = __$$EsopPoolCreationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String poolId,
    int poolSize,
    double? targetPercentage,
    String? resolutionReference,
  });
}

/// @nodoc
class __$$EsopPoolCreationDataImplCopyWithImpl<$Res>
    extends _$EsopPoolCreationDataCopyWithImpl<$Res, _$EsopPoolCreationDataImpl>
    implements _$$EsopPoolCreationDataImplCopyWith<$Res> {
  __$$EsopPoolCreationDataImplCopyWithImpl(
    _$EsopPoolCreationDataImpl _value,
    $Res Function(_$EsopPoolCreationDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EsopPoolCreationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poolId = null,
    Object? poolSize = null,
    Object? targetPercentage = freezed,
    Object? resolutionReference = freezed,
  }) {
    return _then(
      _$EsopPoolCreationDataImpl(
        poolId: null == poolId
            ? _value.poolId
            : poolId // ignore: cast_nullable_to_non_nullable
                  as String,
        poolSize: null == poolSize
            ? _value.poolSize
            : poolSize // ignore: cast_nullable_to_non_nullable
                  as int,
        targetPercentage: freezed == targetPercentage
            ? _value.targetPercentage
            : targetPercentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        resolutionReference: freezed == resolutionReference
            ? _value.resolutionReference
            : resolutionReference // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EsopPoolCreationDataImpl implements _EsopPoolCreationData {
  const _$EsopPoolCreationDataImpl({
    required this.poolId,
    required this.poolSize,
    this.targetPercentage,
    this.resolutionReference,
  });

  factory _$EsopPoolCreationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EsopPoolCreationDataImplFromJson(json);

  @override
  final String poolId;
  @override
  final int poolSize;
  @override
  final double? targetPercentage;
  @override
  final String? resolutionReference;

  @override
  String toString() {
    return 'EsopPoolCreationData(poolId: $poolId, poolSize: $poolSize, targetPercentage: $targetPercentage, resolutionReference: $resolutionReference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EsopPoolCreationDataImpl &&
            (identical(other.poolId, poolId) || other.poolId == poolId) &&
            (identical(other.poolSize, poolSize) ||
                other.poolSize == poolSize) &&
            (identical(other.targetPercentage, targetPercentage) ||
                other.targetPercentage == targetPercentage) &&
            (identical(other.resolutionReference, resolutionReference) ||
                other.resolutionReference == resolutionReference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    poolId,
    poolSize,
    targetPercentage,
    resolutionReference,
  );

  /// Create a copy of EsopPoolCreationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EsopPoolCreationDataImplCopyWith<_$EsopPoolCreationDataImpl>
  get copyWith =>
      __$$EsopPoolCreationDataImplCopyWithImpl<_$EsopPoolCreationDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EsopPoolCreationDataImplToJson(this);
  }
}

abstract class _EsopPoolCreationData implements EsopPoolCreationData {
  const factory _EsopPoolCreationData({
    required final String poolId,
    required final int poolSize,
    final double? targetPercentage,
    final String? resolutionReference,
  }) = _$EsopPoolCreationDataImpl;

  factory _EsopPoolCreationData.fromJson(Map<String, dynamic> json) =
      _$EsopPoolCreationDataImpl.fromJson;

  @override
  String get poolId;
  @override
  int get poolSize;
  @override
  double? get targetPercentage;
  @override
  String? get resolutionReference;

  /// Create a copy of EsopPoolCreationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EsopPoolCreationDataImplCopyWith<_$EsopPoolCreationDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}

EsopPoolExpansionData _$EsopPoolExpansionDataFromJson(
  Map<String, dynamic> json,
) {
  return _EsopPoolExpansionData.fromJson(json);
}

/// @nodoc
mixin _$EsopPoolExpansionData {
  String get poolId => throw _privateConstructorUsedError;
  int get previousSize => throw _privateConstructorUsedError;
  int get newSize => throw _privateConstructorUsedError;
  int get addedShares => throw _privateConstructorUsedError;
  String? get resolutionReference => throw _privateConstructorUsedError;

  /// Serializes this EsopPoolExpansionData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EsopPoolExpansionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EsopPoolExpansionDataCopyWith<EsopPoolExpansionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EsopPoolExpansionDataCopyWith<$Res> {
  factory $EsopPoolExpansionDataCopyWith(
    EsopPoolExpansionData value,
    $Res Function(EsopPoolExpansionData) then,
  ) = _$EsopPoolExpansionDataCopyWithImpl<$Res, EsopPoolExpansionData>;
  @useResult
  $Res call({
    String poolId,
    int previousSize,
    int newSize,
    int addedShares,
    String? resolutionReference,
  });
}

/// @nodoc
class _$EsopPoolExpansionDataCopyWithImpl<
  $Res,
  $Val extends EsopPoolExpansionData
>
    implements $EsopPoolExpansionDataCopyWith<$Res> {
  _$EsopPoolExpansionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EsopPoolExpansionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poolId = null,
    Object? previousSize = null,
    Object? newSize = null,
    Object? addedShares = null,
    Object? resolutionReference = freezed,
  }) {
    return _then(
      _value.copyWith(
            poolId: null == poolId
                ? _value.poolId
                : poolId // ignore: cast_nullable_to_non_nullable
                      as String,
            previousSize: null == previousSize
                ? _value.previousSize
                : previousSize // ignore: cast_nullable_to_non_nullable
                      as int,
            newSize: null == newSize
                ? _value.newSize
                : newSize // ignore: cast_nullable_to_non_nullable
                      as int,
            addedShares: null == addedShares
                ? _value.addedShares
                : addedShares // ignore: cast_nullable_to_non_nullable
                      as int,
            resolutionReference: freezed == resolutionReference
                ? _value.resolutionReference
                : resolutionReference // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EsopPoolExpansionDataImplCopyWith<$Res>
    implements $EsopPoolExpansionDataCopyWith<$Res> {
  factory _$$EsopPoolExpansionDataImplCopyWith(
    _$EsopPoolExpansionDataImpl value,
    $Res Function(_$EsopPoolExpansionDataImpl) then,
  ) = __$$EsopPoolExpansionDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String poolId,
    int previousSize,
    int newSize,
    int addedShares,
    String? resolutionReference,
  });
}

/// @nodoc
class __$$EsopPoolExpansionDataImplCopyWithImpl<$Res>
    extends
        _$EsopPoolExpansionDataCopyWithImpl<$Res, _$EsopPoolExpansionDataImpl>
    implements _$$EsopPoolExpansionDataImplCopyWith<$Res> {
  __$$EsopPoolExpansionDataImplCopyWithImpl(
    _$EsopPoolExpansionDataImpl _value,
    $Res Function(_$EsopPoolExpansionDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EsopPoolExpansionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poolId = null,
    Object? previousSize = null,
    Object? newSize = null,
    Object? addedShares = null,
    Object? resolutionReference = freezed,
  }) {
    return _then(
      _$EsopPoolExpansionDataImpl(
        poolId: null == poolId
            ? _value.poolId
            : poolId // ignore: cast_nullable_to_non_nullable
                  as String,
        previousSize: null == previousSize
            ? _value.previousSize
            : previousSize // ignore: cast_nullable_to_non_nullable
                  as int,
        newSize: null == newSize
            ? _value.newSize
            : newSize // ignore: cast_nullable_to_non_nullable
                  as int,
        addedShares: null == addedShares
            ? _value.addedShares
            : addedShares // ignore: cast_nullable_to_non_nullable
                  as int,
        resolutionReference: freezed == resolutionReference
            ? _value.resolutionReference
            : resolutionReference // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EsopPoolExpansionDataImpl implements _EsopPoolExpansionData {
  const _$EsopPoolExpansionDataImpl({
    required this.poolId,
    required this.previousSize,
    required this.newSize,
    required this.addedShares,
    this.resolutionReference,
  });

  factory _$EsopPoolExpansionDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$EsopPoolExpansionDataImplFromJson(json);

  @override
  final String poolId;
  @override
  final int previousSize;
  @override
  final int newSize;
  @override
  final int addedShares;
  @override
  final String? resolutionReference;

  @override
  String toString() {
    return 'EsopPoolExpansionData(poolId: $poolId, previousSize: $previousSize, newSize: $newSize, addedShares: $addedShares, resolutionReference: $resolutionReference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EsopPoolExpansionDataImpl &&
            (identical(other.poolId, poolId) || other.poolId == poolId) &&
            (identical(other.previousSize, previousSize) ||
                other.previousSize == previousSize) &&
            (identical(other.newSize, newSize) || other.newSize == newSize) &&
            (identical(other.addedShares, addedShares) ||
                other.addedShares == addedShares) &&
            (identical(other.resolutionReference, resolutionReference) ||
                other.resolutionReference == resolutionReference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    poolId,
    previousSize,
    newSize,
    addedShares,
    resolutionReference,
  );

  /// Create a copy of EsopPoolExpansionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EsopPoolExpansionDataImplCopyWith<_$EsopPoolExpansionDataImpl>
  get copyWith =>
      __$$EsopPoolExpansionDataImplCopyWithImpl<_$EsopPoolExpansionDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EsopPoolExpansionDataImplToJson(this);
  }
}

abstract class _EsopPoolExpansionData implements EsopPoolExpansionData {
  const factory _EsopPoolExpansionData({
    required final String poolId,
    required final int previousSize,
    required final int newSize,
    required final int addedShares,
    final String? resolutionReference,
  }) = _$EsopPoolExpansionDataImpl;

  factory _EsopPoolExpansionData.fromJson(Map<String, dynamic> json) =
      _$EsopPoolExpansionDataImpl.fromJson;

  @override
  String get poolId;
  @override
  int get previousSize;
  @override
  int get newSize;
  @override
  int get addedShares;
  @override
  String? get resolutionReference;

  /// Create a copy of EsopPoolExpansionData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EsopPoolExpansionDataImplCopyWith<_$EsopPoolExpansionDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OptionGrantData _$OptionGrantDataFromJson(Map<String, dynamic> json) {
  return _OptionGrantData.fromJson(json);
}

/// @nodoc
mixin _$OptionGrantData {
  String get grantId => throw _privateConstructorUsedError;
  String get poolId => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get strikePrice => throw _privateConstructorUsedError;
  String? get vestingScheduleId => throw _privateConstructorUsedError;

  /// Serializes this OptionGrantData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OptionGrantData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OptionGrantDataCopyWith<OptionGrantData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptionGrantDataCopyWith<$Res> {
  factory $OptionGrantDataCopyWith(
    OptionGrantData value,
    $Res Function(OptionGrantData) then,
  ) = _$OptionGrantDataCopyWithImpl<$Res, OptionGrantData>;
  @useResult
  $Res call({
    String grantId,
    String poolId,
    String stakeholderId,
    int quantity,
    double strikePrice,
    String? vestingScheduleId,
  });
}

/// @nodoc
class _$OptionGrantDataCopyWithImpl<$Res, $Val extends OptionGrantData>
    implements $OptionGrantDataCopyWith<$Res> {
  _$OptionGrantDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OptionGrantData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grantId = null,
    Object? poolId = null,
    Object? stakeholderId = null,
    Object? quantity = null,
    Object? strikePrice = null,
    Object? vestingScheduleId = freezed,
  }) {
    return _then(
      _value.copyWith(
            grantId: null == grantId
                ? _value.grantId
                : grantId // ignore: cast_nullable_to_non_nullable
                      as String,
            poolId: null == poolId
                ? _value.poolId
                : poolId // ignore: cast_nullable_to_non_nullable
                      as String,
            stakeholderId: null == stakeholderId
                ? _value.stakeholderId
                : stakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            strikePrice: null == strikePrice
                ? _value.strikePrice
                : strikePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            vestingScheduleId: freezed == vestingScheduleId
                ? _value.vestingScheduleId
                : vestingScheduleId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OptionGrantDataImplCopyWith<$Res>
    implements $OptionGrantDataCopyWith<$Res> {
  factory _$$OptionGrantDataImplCopyWith(
    _$OptionGrantDataImpl value,
    $Res Function(_$OptionGrantDataImpl) then,
  ) = __$$OptionGrantDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String grantId,
    String poolId,
    String stakeholderId,
    int quantity,
    double strikePrice,
    String? vestingScheduleId,
  });
}

/// @nodoc
class __$$OptionGrantDataImplCopyWithImpl<$Res>
    extends _$OptionGrantDataCopyWithImpl<$Res, _$OptionGrantDataImpl>
    implements _$$OptionGrantDataImplCopyWith<$Res> {
  __$$OptionGrantDataImplCopyWithImpl(
    _$OptionGrantDataImpl _value,
    $Res Function(_$OptionGrantDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OptionGrantData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grantId = null,
    Object? poolId = null,
    Object? stakeholderId = null,
    Object? quantity = null,
    Object? strikePrice = null,
    Object? vestingScheduleId = freezed,
  }) {
    return _then(
      _$OptionGrantDataImpl(
        grantId: null == grantId
            ? _value.grantId
            : grantId // ignore: cast_nullable_to_non_nullable
                  as String,
        poolId: null == poolId
            ? _value.poolId
            : poolId // ignore: cast_nullable_to_non_nullable
                  as String,
        stakeholderId: null == stakeholderId
            ? _value.stakeholderId
            : stakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        strikePrice: null == strikePrice
            ? _value.strikePrice
            : strikePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        vestingScheduleId: freezed == vestingScheduleId
            ? _value.vestingScheduleId
            : vestingScheduleId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OptionGrantDataImpl implements _OptionGrantData {
  const _$OptionGrantDataImpl({
    required this.grantId,
    required this.poolId,
    required this.stakeholderId,
    required this.quantity,
    required this.strikePrice,
    this.vestingScheduleId,
  });

  factory _$OptionGrantDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$OptionGrantDataImplFromJson(json);

  @override
  final String grantId;
  @override
  final String poolId;
  @override
  final String stakeholderId;
  @override
  final int quantity;
  @override
  final double strikePrice;
  @override
  final String? vestingScheduleId;

  @override
  String toString() {
    return 'OptionGrantData(grantId: $grantId, poolId: $poolId, stakeholderId: $stakeholderId, quantity: $quantity, strikePrice: $strikePrice, vestingScheduleId: $vestingScheduleId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptionGrantDataImpl &&
            (identical(other.grantId, grantId) || other.grantId == grantId) &&
            (identical(other.poolId, poolId) || other.poolId == poolId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.strikePrice, strikePrice) ||
                other.strikePrice == strikePrice) &&
            (identical(other.vestingScheduleId, vestingScheduleId) ||
                other.vestingScheduleId == vestingScheduleId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    grantId,
    poolId,
    stakeholderId,
    quantity,
    strikePrice,
    vestingScheduleId,
  );

  /// Create a copy of OptionGrantData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OptionGrantDataImplCopyWith<_$OptionGrantDataImpl> get copyWith =>
      __$$OptionGrantDataImplCopyWithImpl<_$OptionGrantDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OptionGrantDataImplToJson(this);
  }
}

abstract class _OptionGrantData implements OptionGrantData {
  const factory _OptionGrantData({
    required final String grantId,
    required final String poolId,
    required final String stakeholderId,
    required final int quantity,
    required final double strikePrice,
    final String? vestingScheduleId,
  }) = _$OptionGrantDataImpl;

  factory _OptionGrantData.fromJson(Map<String, dynamic> json) =
      _$OptionGrantDataImpl.fromJson;

  @override
  String get grantId;
  @override
  String get poolId;
  @override
  String get stakeholderId;
  @override
  int get quantity;
  @override
  double get strikePrice;
  @override
  String? get vestingScheduleId;

  /// Create a copy of OptionGrantData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OptionGrantDataImplCopyWith<_$OptionGrantDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
