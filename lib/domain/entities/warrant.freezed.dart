// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warrant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Warrant _$WarrantFromJson(Map<String, dynamic> json) {
  return _Warrant.fromJson(json);
}

/// @nodoc
mixin _$Warrant {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  WarrantStatus get status => throw _privateConstructorUsedError;

  /// Number of shares the warrant allows purchasing.
  int get quantity => throw _privateConstructorUsedError;

  /// Strike/exercise price per share.
  double get strikePrice => throw _privateConstructorUsedError;

  /// Date warrant was issued.
  DateTime get issueDate => throw _privateConstructorUsedError;

  /// Expiry date (typically 5-10 years).
  DateTime get expiryDate => throw _privateConstructorUsedError;

  /// Number already exercised.
  int get exercisedCount => throw _privateConstructorUsedError;

  /// Number cancelled.
  int get cancelledCount => throw _privateConstructorUsedError;

  /// If this warrant came from warrant coverage on a convertible.
  String? get sourceConvertibleId => throw _privateConstructorUsedError;

  /// Round ID this warrant is associated with.
  String? get roundId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Warrant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Warrant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WarrantCopyWith<Warrant> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WarrantCopyWith<$Res> {
  factory $WarrantCopyWith(Warrant value, $Res Function(Warrant) then) =
      _$WarrantCopyWithImpl<$Res, Warrant>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String stakeholderId,
    String shareClassId,
    WarrantStatus status,
    int quantity,
    double strikePrice,
    DateTime issueDate,
    DateTime expiryDate,
    int exercisedCount,
    int cancelledCount,
    String? sourceConvertibleId,
    String? roundId,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$WarrantCopyWithImpl<$Res, $Val extends Warrant>
    implements $WarrantCopyWith<$Res> {
  _$WarrantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Warrant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? status = null,
    Object? quantity = null,
    Object? strikePrice = null,
    Object? issueDate = null,
    Object? expiryDate = null,
    Object? exercisedCount = null,
    Object? cancelledCount = null,
    Object? sourceConvertibleId = freezed,
    Object? roundId = freezed,
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
            stakeholderId: null == stakeholderId
                ? _value.stakeholderId
                : stakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            shareClassId: null == shareClassId
                ? _value.shareClassId
                : shareClassId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as WarrantStatus,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            strikePrice: null == strikePrice
                ? _value.strikePrice
                : strikePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            issueDate: null == issueDate
                ? _value.issueDate
                : issueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiryDate: null == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            exercisedCount: null == exercisedCount
                ? _value.exercisedCount
                : exercisedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            cancelledCount: null == cancelledCount
                ? _value.cancelledCount
                : cancelledCount // ignore: cast_nullable_to_non_nullable
                      as int,
            sourceConvertibleId: freezed == sourceConvertibleId
                ? _value.sourceConvertibleId
                : sourceConvertibleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            roundId: freezed == roundId
                ? _value.roundId
                : roundId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$WarrantImplCopyWith<$Res> implements $WarrantCopyWith<$Res> {
  factory _$$WarrantImplCopyWith(
    _$WarrantImpl value,
    $Res Function(_$WarrantImpl) then,
  ) = __$$WarrantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String stakeholderId,
    String shareClassId,
    WarrantStatus status,
    int quantity,
    double strikePrice,
    DateTime issueDate,
    DateTime expiryDate,
    int exercisedCount,
    int cancelledCount,
    String? sourceConvertibleId,
    String? roundId,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$WarrantImplCopyWithImpl<$Res>
    extends _$WarrantCopyWithImpl<$Res, _$WarrantImpl>
    implements _$$WarrantImplCopyWith<$Res> {
  __$$WarrantImplCopyWithImpl(
    _$WarrantImpl _value,
    $Res Function(_$WarrantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Warrant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? status = null,
    Object? quantity = null,
    Object? strikePrice = null,
    Object? issueDate = null,
    Object? expiryDate = null,
    Object? exercisedCount = null,
    Object? cancelledCount = null,
    Object? sourceConvertibleId = freezed,
    Object? roundId = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$WarrantImpl(
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as WarrantStatus,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        strikePrice: null == strikePrice
            ? _value.strikePrice
            : strikePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        issueDate: null == issueDate
            ? _value.issueDate
            : issueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiryDate: null == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        exercisedCount: null == exercisedCount
            ? _value.exercisedCount
            : exercisedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        cancelledCount: null == cancelledCount
            ? _value.cancelledCount
            : cancelledCount // ignore: cast_nullable_to_non_nullable
                  as int,
        sourceConvertibleId: freezed == sourceConvertibleId
            ? _value.sourceConvertibleId
            : sourceConvertibleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        roundId: freezed == roundId
            ? _value.roundId
            : roundId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$WarrantImpl extends _Warrant {
  const _$WarrantImpl({
    required this.id,
    required this.companyId,
    required this.stakeholderId,
    required this.shareClassId,
    this.status = WarrantStatus.pending,
    required this.quantity,
    required this.strikePrice,
    required this.issueDate,
    required this.expiryDate,
    this.exercisedCount = 0,
    this.cancelledCount = 0,
    this.sourceConvertibleId,
    this.roundId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$WarrantImpl.fromJson(Map<String, dynamic> json) =>
      _$$WarrantImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String stakeholderId;
  @override
  final String shareClassId;
  @override
  @JsonKey()
  final WarrantStatus status;

  /// Number of shares the warrant allows purchasing.
  @override
  final int quantity;

  /// Strike/exercise price per share.
  @override
  final double strikePrice;

  /// Date warrant was issued.
  @override
  final DateTime issueDate;

  /// Expiry date (typically 5-10 years).
  @override
  final DateTime expiryDate;

  /// Number already exercised.
  @override
  @JsonKey()
  final int exercisedCount;

  /// Number cancelled.
  @override
  @JsonKey()
  final int cancelledCount;

  /// If this warrant came from warrant coverage on a convertible.
  @override
  final String? sourceConvertibleId;

  /// Round ID this warrant is associated with.
  @override
  final String? roundId;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Warrant(id: $id, companyId: $companyId, stakeholderId: $stakeholderId, shareClassId: $shareClassId, status: $status, quantity: $quantity, strikePrice: $strikePrice, issueDate: $issueDate, expiryDate: $expiryDate, exercisedCount: $exercisedCount, cancelledCount: $cancelledCount, sourceConvertibleId: $sourceConvertibleId, roundId: $roundId, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WarrantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.strikePrice, strikePrice) ||
                other.strikePrice == strikePrice) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.exercisedCount, exercisedCount) ||
                other.exercisedCount == exercisedCount) &&
            (identical(other.cancelledCount, cancelledCount) ||
                other.cancelledCount == cancelledCount) &&
            (identical(other.sourceConvertibleId, sourceConvertibleId) ||
                other.sourceConvertibleId == sourceConvertibleId) &&
            (identical(other.roundId, roundId) || other.roundId == roundId) &&
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
    stakeholderId,
    shareClassId,
    status,
    quantity,
    strikePrice,
    issueDate,
    expiryDate,
    exercisedCount,
    cancelledCount,
    sourceConvertibleId,
    roundId,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Warrant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WarrantImplCopyWith<_$WarrantImpl> get copyWith =>
      __$$WarrantImplCopyWithImpl<_$WarrantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WarrantImplToJson(this);
  }
}

abstract class _Warrant extends Warrant {
  const factory _Warrant({
    required final String id,
    required final String companyId,
    required final String stakeholderId,
    required final String shareClassId,
    final WarrantStatus status,
    required final int quantity,
    required final double strikePrice,
    required final DateTime issueDate,
    required final DateTime expiryDate,
    final int exercisedCount,
    final int cancelledCount,
    final String? sourceConvertibleId,
    final String? roundId,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$WarrantImpl;
  const _Warrant._() : super._();

  factory _Warrant.fromJson(Map<String, dynamic> json) = _$WarrantImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get stakeholderId;
  @override
  String get shareClassId;
  @override
  WarrantStatus get status;

  /// Number of shares the warrant allows purchasing.
  @override
  int get quantity;

  /// Strike/exercise price per share.
  @override
  double get strikePrice;

  /// Date warrant was issued.
  @override
  DateTime get issueDate;

  /// Expiry date (typically 5-10 years).
  @override
  DateTime get expiryDate;

  /// Number already exercised.
  @override
  int get exercisedCount;

  /// Number cancelled.
  @override
  int get cancelledCount;

  /// If this warrant came from warrant coverage on a convertible.
  @override
  String? get sourceConvertibleId;

  /// Round ID this warrant is associated with.
  @override
  String? get roundId;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Warrant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WarrantImplCopyWith<_$WarrantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
