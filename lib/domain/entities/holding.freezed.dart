// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'holding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Holding _$HoldingFromJson(Map<String, dynamic> json) {
  return _Holding.fromJson(json);
}

/// @nodoc
mixin _$Holding {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;

  /// Number of shares held.
  int get shareCount => throw _privateConstructorUsedError;

  /// Total cost basis (amount paid for these shares).
  double get costBasis => throw _privateConstructorUsedError;

  /// Date shares were acquired.
  DateTime get acquiredDate => throw _privateConstructorUsedError;

  /// Vesting schedule ID (if shares are subject to vesting).
  String? get vestingScheduleId => throw _privateConstructorUsedError;

  /// Number of shares currently vested (null = all vested).
  int? get vestedCount => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Holding to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Holding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HoldingCopyWith<Holding> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HoldingCopyWith<$Res> {
  factory $HoldingCopyWith(Holding value, $Res Function(Holding) then) =
      _$HoldingCopyWithImpl<$Res, Holding>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String stakeholderId,
    String shareClassId,
    int shareCount,
    double costBasis,
    DateTime acquiredDate,
    String? vestingScheduleId,
    int? vestedCount,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$HoldingCopyWithImpl<$Res, $Val extends Holding>
    implements $HoldingCopyWith<$Res> {
  _$HoldingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Holding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? costBasis = null,
    Object? acquiredDate = null,
    Object? vestingScheduleId = freezed,
    Object? vestedCount = freezed,
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
            stakeholderId: null == stakeholderId
                ? _value.stakeholderId
                : stakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            shareClassId: null == shareClassId
                ? _value.shareClassId
                : shareClassId // ignore: cast_nullable_to_non_nullable
                      as String,
            shareCount: null == shareCount
                ? _value.shareCount
                : shareCount // ignore: cast_nullable_to_non_nullable
                      as int,
            costBasis: null == costBasis
                ? _value.costBasis
                : costBasis // ignore: cast_nullable_to_non_nullable
                      as double,
            acquiredDate: null == acquiredDate
                ? _value.acquiredDate
                : acquiredDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            vestingScheduleId: freezed == vestingScheduleId
                ? _value.vestingScheduleId
                : vestingScheduleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            vestedCount: freezed == vestedCount
                ? _value.vestedCount
                : vestedCount // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$HoldingImplCopyWith<$Res> implements $HoldingCopyWith<$Res> {
  factory _$$HoldingImplCopyWith(
    _$HoldingImpl value,
    $Res Function(_$HoldingImpl) then,
  ) = __$$HoldingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String stakeholderId,
    String shareClassId,
    int shareCount,
    double costBasis,
    DateTime acquiredDate,
    String? vestingScheduleId,
    int? vestedCount,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$HoldingImplCopyWithImpl<$Res>
    extends _$HoldingCopyWithImpl<$Res, _$HoldingImpl>
    implements _$$HoldingImplCopyWith<$Res> {
  __$$HoldingImplCopyWithImpl(
    _$HoldingImpl _value,
    $Res Function(_$HoldingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Holding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? costBasis = null,
    Object? acquiredDate = null,
    Object? vestingScheduleId = freezed,
    Object? vestedCount = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _$HoldingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        stakeholderId: null == stakeholderId
            ? _value.stakeholderId
            : stakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        shareClassId: null == shareClassId
            ? _value.shareClassId
            : shareClassId // ignore: cast_nullable_to_non_nullable
                  as String,
        shareCount: null == shareCount
            ? _value.shareCount
            : shareCount // ignore: cast_nullable_to_non_nullable
                  as int,
        costBasis: null == costBasis
            ? _value.costBasis
            : costBasis // ignore: cast_nullable_to_non_nullable
                  as double,
        acquiredDate: null == acquiredDate
            ? _value.acquiredDate
            : acquiredDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        vestingScheduleId: freezed == vestingScheduleId
            ? _value.vestingScheduleId
            : vestingScheduleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        vestedCount: freezed == vestedCount
            ? _value.vestedCount
            : vestedCount // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$HoldingImpl extends _Holding {
  const _$HoldingImpl({
    required this.id,
    required this.companyId,
    required this.stakeholderId,
    required this.shareClassId,
    required this.shareCount,
    required this.costBasis,
    required this.acquiredDate,
    this.vestingScheduleId,
    this.vestedCount,
    required this.updatedAt,
  }) : super._();

  factory _$HoldingImpl.fromJson(Map<String, dynamic> json) =>
      _$$HoldingImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String stakeholderId;
  @override
  final String shareClassId;

  /// Number of shares held.
  @override
  final int shareCount;

  /// Total cost basis (amount paid for these shares).
  @override
  final double costBasis;

  /// Date shares were acquired.
  @override
  final DateTime acquiredDate;

  /// Vesting schedule ID (if shares are subject to vesting).
  @override
  final String? vestingScheduleId;

  /// Number of shares currently vested (null = all vested).
  @override
  final int? vestedCount;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Holding(id: $id, companyId: $companyId, stakeholderId: $stakeholderId, shareClassId: $shareClassId, shareCount: $shareCount, costBasis: $costBasis, acquiredDate: $acquiredDate, vestingScheduleId: $vestingScheduleId, vestedCount: $vestedCount, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HoldingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.costBasis, costBasis) ||
                other.costBasis == costBasis) &&
            (identical(other.acquiredDate, acquiredDate) ||
                other.acquiredDate == acquiredDate) &&
            (identical(other.vestingScheduleId, vestingScheduleId) ||
                other.vestingScheduleId == vestingScheduleId) &&
            (identical(other.vestedCount, vestedCount) ||
                other.vestedCount == vestedCount) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyId,
    stakeholderId,
    shareClassId,
    shareCount,
    costBasis,
    acquiredDate,
    vestingScheduleId,
    vestedCount,
    updatedAt,
  );

  /// Create a copy of Holding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HoldingImplCopyWith<_$HoldingImpl> get copyWith =>
      __$$HoldingImplCopyWithImpl<_$HoldingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HoldingImplToJson(this);
  }
}

abstract class _Holding extends Holding {
  const factory _Holding({
    required final String id,
    required final String companyId,
    required final String stakeholderId,
    required final String shareClassId,
    required final int shareCount,
    required final double costBasis,
    required final DateTime acquiredDate,
    final String? vestingScheduleId,
    final int? vestedCount,
    required final DateTime updatedAt,
  }) = _$HoldingImpl;
  const _Holding._() : super._();

  factory _Holding.fromJson(Map<String, dynamic> json) = _$HoldingImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get stakeholderId;
  @override
  String get shareClassId;

  /// Number of shares held.
  @override
  int get shareCount;

  /// Total cost basis (amount paid for these shares).
  @override
  double get costBasis;

  /// Date shares were acquired.
  @override
  DateTime get acquiredDate;

  /// Vesting schedule ID (if shares are subject to vesting).
  @override
  String? get vestingScheduleId;

  /// Number of shares currently vested (null = all vested).
  @override
  int? get vestedCount;
  @override
  DateTime get updatedAt;

  /// Create a copy of Holding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HoldingImplCopyWith<_$HoldingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
