// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShareClass _$ShareClassFromJson(Map<String, dynamic> json) {
  return _ShareClass.fromJson(json);
}

/// @nodoc
mixin _$ShareClass {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ShareClassType get type => throw _privateConstructorUsedError;

  /// Voting power multiplier (1.0 = normal, 0 = non-voting, 10 = 10x).
  double get votingMultiplier => throw _privateConstructorUsedError;

  /// Liquidation preference multiplier (1.0 = 1x, 2.0 = 2x participating).
  double get liquidationPreference => throw _privateConstructorUsedError;

  /// Whether holders participate in remaining proceeds after preference.
  bool get isParticipating => throw _privateConstructorUsedError;

  /// Annual dividend rate as a percentage (0-100).
  double get dividendRate => throw _privateConstructorUsedError;

  /// Payment priority in liquidation (higher = paid first).
  int get seniority => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ShareClass to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareClass
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareClassCopyWith<ShareClass> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareClassCopyWith<$Res> {
  factory $ShareClassCopyWith(
    ShareClass value,
    $Res Function(ShareClass) then,
  ) = _$ShareClassCopyWithImpl<$Res, ShareClass>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    ShareClassType type,
    double votingMultiplier,
    double liquidationPreference,
    bool isParticipating,
    double dividendRate,
    int seniority,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ShareClassCopyWithImpl<$Res, $Val extends ShareClass>
    implements $ShareClassCopyWith<$Res> {
  _$ShareClassCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareClass
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? type = null,
    Object? votingMultiplier = null,
    Object? liquidationPreference = null,
    Object? isParticipating = null,
    Object? dividendRate = null,
    Object? seniority = null,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ShareClassType,
            votingMultiplier: null == votingMultiplier
                ? _value.votingMultiplier
                : votingMultiplier // ignore: cast_nullable_to_non_nullable
                      as double,
            liquidationPreference: null == liquidationPreference
                ? _value.liquidationPreference
                : liquidationPreference // ignore: cast_nullable_to_non_nullable
                      as double,
            isParticipating: null == isParticipating
                ? _value.isParticipating
                : isParticipating // ignore: cast_nullable_to_non_nullable
                      as bool,
            dividendRate: null == dividendRate
                ? _value.dividendRate
                : dividendRate // ignore: cast_nullable_to_non_nullable
                      as double,
            seniority: null == seniority
                ? _value.seniority
                : seniority // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ShareClassImplCopyWith<$Res>
    implements $ShareClassCopyWith<$Res> {
  factory _$$ShareClassImplCopyWith(
    _$ShareClassImpl value,
    $Res Function(_$ShareClassImpl) then,
  ) = __$$ShareClassImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    ShareClassType type,
    double votingMultiplier,
    double liquidationPreference,
    bool isParticipating,
    double dividendRate,
    int seniority,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ShareClassImplCopyWithImpl<$Res>
    extends _$ShareClassCopyWithImpl<$Res, _$ShareClassImpl>
    implements _$$ShareClassImplCopyWith<$Res> {
  __$$ShareClassImplCopyWithImpl(
    _$ShareClassImpl _value,
    $Res Function(_$ShareClassImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShareClass
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? type = null,
    Object? votingMultiplier = null,
    Object? liquidationPreference = null,
    Object? isParticipating = null,
    Object? dividendRate = null,
    Object? seniority = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ShareClassImpl(
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
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ShareClassType,
        votingMultiplier: null == votingMultiplier
            ? _value.votingMultiplier
            : votingMultiplier // ignore: cast_nullable_to_non_nullable
                  as double,
        liquidationPreference: null == liquidationPreference
            ? _value.liquidationPreference
            : liquidationPreference // ignore: cast_nullable_to_non_nullable
                  as double,
        isParticipating: null == isParticipating
            ? _value.isParticipating
            : isParticipating // ignore: cast_nullable_to_non_nullable
                  as bool,
        dividendRate: null == dividendRate
            ? _value.dividendRate
            : dividendRate // ignore: cast_nullable_to_non_nullable
                  as double,
        seniority: null == seniority
            ? _value.seniority
            : seniority // ignore: cast_nullable_to_non_nullable
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
class _$ShareClassImpl extends _ShareClass {
  const _$ShareClassImpl({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    this.votingMultiplier = 1.0,
    this.liquidationPreference = 1.0,
    this.isParticipating = false,
    this.dividendRate = 0.0,
    this.seniority = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$ShareClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareClassImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String name;
  @override
  final ShareClassType type;

  /// Voting power multiplier (1.0 = normal, 0 = non-voting, 10 = 10x).
  @override
  @JsonKey()
  final double votingMultiplier;

  /// Liquidation preference multiplier (1.0 = 1x, 2.0 = 2x participating).
  @override
  @JsonKey()
  final double liquidationPreference;

  /// Whether holders participate in remaining proceeds after preference.
  @override
  @JsonKey()
  final bool isParticipating;

  /// Annual dividend rate as a percentage (0-100).
  @override
  @JsonKey()
  final double dividendRate;

  /// Payment priority in liquidation (higher = paid first).
  @override
  @JsonKey()
  final int seniority;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ShareClass(id: $id, companyId: $companyId, name: $name, type: $type, votingMultiplier: $votingMultiplier, liquidationPreference: $liquidationPreference, isParticipating: $isParticipating, dividendRate: $dividendRate, seniority: $seniority, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareClassImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.votingMultiplier, votingMultiplier) ||
                other.votingMultiplier == votingMultiplier) &&
            (identical(other.liquidationPreference, liquidationPreference) ||
                other.liquidationPreference == liquidationPreference) &&
            (identical(other.isParticipating, isParticipating) ||
                other.isParticipating == isParticipating) &&
            (identical(other.dividendRate, dividendRate) ||
                other.dividendRate == dividendRate) &&
            (identical(other.seniority, seniority) ||
                other.seniority == seniority) &&
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
    type,
    votingMultiplier,
    liquidationPreference,
    isParticipating,
    dividendRate,
    seniority,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ShareClass
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareClassImplCopyWith<_$ShareClassImpl> get copyWith =>
      __$$ShareClassImplCopyWithImpl<_$ShareClassImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareClassImplToJson(this);
  }
}

abstract class _ShareClass extends ShareClass {
  const factory _ShareClass({
    required final String id,
    required final String companyId,
    required final String name,
    required final ShareClassType type,
    final double votingMultiplier,
    final double liquidationPreference,
    final bool isParticipating,
    final double dividendRate,
    final int seniority,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ShareClassImpl;
  const _ShareClass._() : super._();

  factory _ShareClass.fromJson(Map<String, dynamic> json) =
      _$ShareClassImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get name;
  @override
  ShareClassType get type;

  /// Voting power multiplier (1.0 = normal, 0 = non-voting, 10 = 10x).
  @override
  double get votingMultiplier;

  /// Liquidation preference multiplier (1.0 = 1x, 2.0 = 2x participating).
  @override
  double get liquidationPreference;

  /// Whether holders participate in remaining proceeds after preference.
  @override
  bool get isParticipating;

  /// Annual dividend rate as a percentage (0-100).
  @override
  double get dividendRate;

  /// Payment priority in liquidation (higher = paid first).
  @override
  int get seniority;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of ShareClass
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareClassImplCopyWith<_$ShareClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
