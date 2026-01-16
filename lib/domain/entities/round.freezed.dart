// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'round.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Round _$RoundFromJson(Map<String, dynamic> json) {
  return _Round.fromJson(json);
}

/// @nodoc
mixin _$Round {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  RoundType get type => throw _privateConstructorUsedError;
  RoundStatus get status => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Pre-money valuation in AUD.
  double? get preMoneyValuation => throw _privateConstructorUsedError;

  /// Price per share for this round.
  double? get pricePerShare => throw _privateConstructorUsedError;

  /// Total amount raised in this round.
  double get amountRaised => throw _privateConstructorUsedError;

  /// Lead investor stakeholder ID (if any).
  String? get leadInvestorId => throw _privateConstructorUsedError;

  /// Display order for chronological sorting.
  int get displayOrder => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Round to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Round
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoundCopyWith<Round> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoundCopyWith<$Res> {
  factory $RoundCopyWith(Round value, $Res Function(Round) then) =
      _$RoundCopyWithImpl<$Res, Round>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    RoundType type,
    RoundStatus status,
    DateTime date,
    double? preMoneyValuation,
    double? pricePerShare,
    double amountRaised,
    String? leadInvestorId,
    int displayOrder,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$RoundCopyWithImpl<$Res, $Val extends Round>
    implements $RoundCopyWith<$Res> {
  _$RoundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Round
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? date = null,
    Object? preMoneyValuation = freezed,
    Object? pricePerShare = freezed,
    Object? amountRaised = null,
    Object? leadInvestorId = freezed,
    Object? displayOrder = null,
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
                      as RoundType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RoundStatus,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            preMoneyValuation: freezed == preMoneyValuation
                ? _value.preMoneyValuation
                : preMoneyValuation // ignore: cast_nullable_to_non_nullable
                      as double?,
            pricePerShare: freezed == pricePerShare
                ? _value.pricePerShare
                : pricePerShare // ignore: cast_nullable_to_non_nullable
                      as double?,
            amountRaised: null == amountRaised
                ? _value.amountRaised
                : amountRaised // ignore: cast_nullable_to_non_nullable
                      as double,
            leadInvestorId: freezed == leadInvestorId
                ? _value.leadInvestorId
                : leadInvestorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
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
abstract class _$$RoundImplCopyWith<$Res> implements $RoundCopyWith<$Res> {
  factory _$$RoundImplCopyWith(
    _$RoundImpl value,
    $Res Function(_$RoundImpl) then,
  ) = __$$RoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    RoundType type,
    RoundStatus status,
    DateTime date,
    double? preMoneyValuation,
    double? pricePerShare,
    double amountRaised,
    String? leadInvestorId,
    int displayOrder,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$RoundImplCopyWithImpl<$Res>
    extends _$RoundCopyWithImpl<$Res, _$RoundImpl>
    implements _$$RoundImplCopyWith<$Res> {
  __$$RoundImplCopyWithImpl(
    _$RoundImpl _value,
    $Res Function(_$RoundImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Round
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? date = null,
    Object? preMoneyValuation = freezed,
    Object? pricePerShare = freezed,
    Object? amountRaised = null,
    Object? leadInvestorId = freezed,
    Object? displayOrder = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$RoundImpl(
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
                  as RoundType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RoundStatus,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        preMoneyValuation: freezed == preMoneyValuation
            ? _value.preMoneyValuation
            : preMoneyValuation // ignore: cast_nullable_to_non_nullable
                  as double?,
        pricePerShare: freezed == pricePerShare
            ? _value.pricePerShare
            : pricePerShare // ignore: cast_nullable_to_non_nullable
                  as double?,
        amountRaised: null == amountRaised
            ? _value.amountRaised
            : amountRaised // ignore: cast_nullable_to_non_nullable
                  as double,
        leadInvestorId: freezed == leadInvestorId
            ? _value.leadInvestorId
            : leadInvestorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
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
class _$RoundImpl extends _Round {
  const _$RoundImpl({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    this.status = RoundStatus.draft,
    required this.date,
    this.preMoneyValuation,
    this.pricePerShare,
    this.amountRaised = 0,
    this.leadInvestorId,
    required this.displayOrder,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$RoundImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoundImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String name;
  @override
  final RoundType type;
  @override
  @JsonKey()
  final RoundStatus status;
  @override
  final DateTime date;

  /// Pre-money valuation in AUD.
  @override
  final double? preMoneyValuation;

  /// Price per share for this round.
  @override
  final double? pricePerShare;

  /// Total amount raised in this round.
  @override
  @JsonKey()
  final double amountRaised;

  /// Lead investor stakeholder ID (if any).
  @override
  final String? leadInvestorId;

  /// Display order for chronological sorting.
  @override
  final int displayOrder;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Round(id: $id, companyId: $companyId, name: $name, type: $type, status: $status, date: $date, preMoneyValuation: $preMoneyValuation, pricePerShare: $pricePerShare, amountRaised: $amountRaised, leadInvestorId: $leadInvestorId, displayOrder: $displayOrder, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoundImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.preMoneyValuation, preMoneyValuation) ||
                other.preMoneyValuation == preMoneyValuation) &&
            (identical(other.pricePerShare, pricePerShare) ||
                other.pricePerShare == pricePerShare) &&
            (identical(other.amountRaised, amountRaised) ||
                other.amountRaised == amountRaised) &&
            (identical(other.leadInvestorId, leadInvestorId) ||
                other.leadInvestorId == leadInvestorId) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
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
    status,
    date,
    preMoneyValuation,
    pricePerShare,
    amountRaised,
    leadInvestorId,
    displayOrder,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Round
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoundImplCopyWith<_$RoundImpl> get copyWith =>
      __$$RoundImplCopyWithImpl<_$RoundImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoundImplToJson(this);
  }
}

abstract class _Round extends Round {
  const factory _Round({
    required final String id,
    required final String companyId,
    required final String name,
    required final RoundType type,
    final RoundStatus status,
    required final DateTime date,
    final double? preMoneyValuation,
    final double? pricePerShare,
    final double amountRaised,
    final String? leadInvestorId,
    required final int displayOrder,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$RoundImpl;
  const _Round._() : super._();

  factory _Round.fromJson(Map<String, dynamic> json) = _$RoundImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get name;
  @override
  RoundType get type;
  @override
  RoundStatus get status;
  @override
  DateTime get date;

  /// Pre-money valuation in AUD.
  @override
  double? get preMoneyValuation;

  /// Price per share for this round.
  @override
  double? get pricePerShare;

  /// Total amount raised in this round.
  @override
  double get amountRaised;

  /// Lead investor stakeholder ID (if any).
  @override
  String? get leadInvestorId;

  /// Display order for chronological sorting.
  @override
  int get displayOrder;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Round
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoundImplCopyWith<_$RoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
