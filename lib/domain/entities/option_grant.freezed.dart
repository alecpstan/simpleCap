// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'option_grant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OptionGrant _$OptionGrantFromJson(Map<String, dynamic> json) {
  return _OptionGrant.fromJson(json);
}

/// @nodoc
mixin _$OptionGrant {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;

  /// ESOP pool this grant draws from (if applicable).
  String? get esopPoolId => throw _privateConstructorUsedError;
  OptionGrantStatus get status => throw _privateConstructorUsedError;

  /// Total number of options granted.
  int get quantity => throw _privateConstructorUsedError;

  /// Strike price (exercise price) per share.
  double get strikePrice => throw _privateConstructorUsedError;

  /// Date options were granted.
  DateTime get grantDate => throw _privateConstructorUsedError;

  /// Expiry date (typically 10 years from grant).
  DateTime get expiryDate => throw _privateConstructorUsedError;

  /// Number of options already exercised.
  int get exercisedCount => throw _privateConstructorUsedError;

  /// Number of options cancelled/forfeited.
  int get cancelledCount => throw _privateConstructorUsedError;

  /// Vesting schedule ID.
  String? get vestingScheduleId => throw _privateConstructorUsedError;

  /// Round ID this grant is associated with.
  String? get roundId => throw _privateConstructorUsedError;

  /// Whether early exercise is allowed.
  bool get allowsEarlyExercise => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OptionGrant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OptionGrant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OptionGrantCopyWith<OptionGrant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptionGrantCopyWith<$Res> {
  factory $OptionGrantCopyWith(
    OptionGrant value,
    $Res Function(OptionGrant) then,
  ) = _$OptionGrantCopyWithImpl<$Res, OptionGrant>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String stakeholderId,
    String shareClassId,
    String? esopPoolId,
    OptionGrantStatus status,
    int quantity,
    double strikePrice,
    DateTime grantDate,
    DateTime expiryDate,
    int exercisedCount,
    int cancelledCount,
    String? vestingScheduleId,
    String? roundId,
    bool allowsEarlyExercise,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$OptionGrantCopyWithImpl<$Res, $Val extends OptionGrant>
    implements $OptionGrantCopyWith<$Res> {
  _$OptionGrantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OptionGrant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? esopPoolId = freezed,
    Object? status = null,
    Object? quantity = null,
    Object? strikePrice = null,
    Object? grantDate = null,
    Object? expiryDate = null,
    Object? exercisedCount = null,
    Object? cancelledCount = null,
    Object? vestingScheduleId = freezed,
    Object? roundId = freezed,
    Object? allowsEarlyExercise = null,
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
            esopPoolId: freezed == esopPoolId
                ? _value.esopPoolId
                : esopPoolId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OptionGrantStatus,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            strikePrice: null == strikePrice
                ? _value.strikePrice
                : strikePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            grantDate: null == grantDate
                ? _value.grantDate
                : grantDate // ignore: cast_nullable_to_non_nullable
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
            vestingScheduleId: freezed == vestingScheduleId
                ? _value.vestingScheduleId
                : vestingScheduleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            roundId: freezed == roundId
                ? _value.roundId
                : roundId // ignore: cast_nullable_to_non_nullable
                      as String?,
            allowsEarlyExercise: null == allowsEarlyExercise
                ? _value.allowsEarlyExercise
                : allowsEarlyExercise // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$OptionGrantImplCopyWith<$Res>
    implements $OptionGrantCopyWith<$Res> {
  factory _$$OptionGrantImplCopyWith(
    _$OptionGrantImpl value,
    $Res Function(_$OptionGrantImpl) then,
  ) = __$$OptionGrantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String stakeholderId,
    String shareClassId,
    String? esopPoolId,
    OptionGrantStatus status,
    int quantity,
    double strikePrice,
    DateTime grantDate,
    DateTime expiryDate,
    int exercisedCount,
    int cancelledCount,
    String? vestingScheduleId,
    String? roundId,
    bool allowsEarlyExercise,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$OptionGrantImplCopyWithImpl<$Res>
    extends _$OptionGrantCopyWithImpl<$Res, _$OptionGrantImpl>
    implements _$$OptionGrantImplCopyWith<$Res> {
  __$$OptionGrantImplCopyWithImpl(
    _$OptionGrantImpl _value,
    $Res Function(_$OptionGrantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OptionGrant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? esopPoolId = freezed,
    Object? status = null,
    Object? quantity = null,
    Object? strikePrice = null,
    Object? grantDate = null,
    Object? expiryDate = null,
    Object? exercisedCount = null,
    Object? cancelledCount = null,
    Object? vestingScheduleId = freezed,
    Object? roundId = freezed,
    Object? allowsEarlyExercise = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$OptionGrantImpl(
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
        esopPoolId: freezed == esopPoolId
            ? _value.esopPoolId
            : esopPoolId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OptionGrantStatus,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        strikePrice: null == strikePrice
            ? _value.strikePrice
            : strikePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        grantDate: null == grantDate
            ? _value.grantDate
            : grantDate // ignore: cast_nullable_to_non_nullable
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
        vestingScheduleId: freezed == vestingScheduleId
            ? _value.vestingScheduleId
            : vestingScheduleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        roundId: freezed == roundId
            ? _value.roundId
            : roundId // ignore: cast_nullable_to_non_nullable
                  as String?,
        allowsEarlyExercise: null == allowsEarlyExercise
            ? _value.allowsEarlyExercise
            : allowsEarlyExercise // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$OptionGrantImpl extends _OptionGrant {
  const _$OptionGrantImpl({
    required this.id,
    required this.companyId,
    required this.stakeholderId,
    required this.shareClassId,
    this.esopPoolId,
    this.status = OptionGrantStatus.pending,
    required this.quantity,
    required this.strikePrice,
    required this.grantDate,
    required this.expiryDate,
    this.exercisedCount = 0,
    this.cancelledCount = 0,
    this.vestingScheduleId,
    this.roundId,
    this.allowsEarlyExercise = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$OptionGrantImpl.fromJson(Map<String, dynamic> json) =>
      _$$OptionGrantImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String stakeholderId;
  @override
  final String shareClassId;

  /// ESOP pool this grant draws from (if applicable).
  @override
  final String? esopPoolId;
  @override
  @JsonKey()
  final OptionGrantStatus status;

  /// Total number of options granted.
  @override
  final int quantity;

  /// Strike price (exercise price) per share.
  @override
  final double strikePrice;

  /// Date options were granted.
  @override
  final DateTime grantDate;

  /// Expiry date (typically 10 years from grant).
  @override
  final DateTime expiryDate;

  /// Number of options already exercised.
  @override
  @JsonKey()
  final int exercisedCount;

  /// Number of options cancelled/forfeited.
  @override
  @JsonKey()
  final int cancelledCount;

  /// Vesting schedule ID.
  @override
  final String? vestingScheduleId;

  /// Round ID this grant is associated with.
  @override
  final String? roundId;

  /// Whether early exercise is allowed.
  @override
  @JsonKey()
  final bool allowsEarlyExercise;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'OptionGrant(id: $id, companyId: $companyId, stakeholderId: $stakeholderId, shareClassId: $shareClassId, esopPoolId: $esopPoolId, status: $status, quantity: $quantity, strikePrice: $strikePrice, grantDate: $grantDate, expiryDate: $expiryDate, exercisedCount: $exercisedCount, cancelledCount: $cancelledCount, vestingScheduleId: $vestingScheduleId, roundId: $roundId, allowsEarlyExercise: $allowsEarlyExercise, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptionGrantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.esopPoolId, esopPoolId) ||
                other.esopPoolId == esopPoolId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.strikePrice, strikePrice) ||
                other.strikePrice == strikePrice) &&
            (identical(other.grantDate, grantDate) ||
                other.grantDate == grantDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.exercisedCount, exercisedCount) ||
                other.exercisedCount == exercisedCount) &&
            (identical(other.cancelledCount, cancelledCount) ||
                other.cancelledCount == cancelledCount) &&
            (identical(other.vestingScheduleId, vestingScheduleId) ||
                other.vestingScheduleId == vestingScheduleId) &&
            (identical(other.roundId, roundId) || other.roundId == roundId) &&
            (identical(other.allowsEarlyExercise, allowsEarlyExercise) ||
                other.allowsEarlyExercise == allowsEarlyExercise) &&
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
    esopPoolId,
    status,
    quantity,
    strikePrice,
    grantDate,
    expiryDate,
    exercisedCount,
    cancelledCount,
    vestingScheduleId,
    roundId,
    allowsEarlyExercise,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of OptionGrant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OptionGrantImplCopyWith<_$OptionGrantImpl> get copyWith =>
      __$$OptionGrantImplCopyWithImpl<_$OptionGrantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OptionGrantImplToJson(this);
  }
}

abstract class _OptionGrant extends OptionGrant {
  const factory _OptionGrant({
    required final String id,
    required final String companyId,
    required final String stakeholderId,
    required final String shareClassId,
    final String? esopPoolId,
    final OptionGrantStatus status,
    required final int quantity,
    required final double strikePrice,
    required final DateTime grantDate,
    required final DateTime expiryDate,
    final int exercisedCount,
    final int cancelledCount,
    final String? vestingScheduleId,
    final String? roundId,
    final bool allowsEarlyExercise,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$OptionGrantImpl;
  const _OptionGrant._() : super._();

  factory _OptionGrant.fromJson(Map<String, dynamic> json) =
      _$OptionGrantImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get stakeholderId;
  @override
  String get shareClassId;

  /// ESOP pool this grant draws from (if applicable).
  @override
  String? get esopPoolId;
  @override
  OptionGrantStatus get status;

  /// Total number of options granted.
  @override
  int get quantity;

  /// Strike price (exercise price) per share.
  @override
  double get strikePrice;

  /// Date options were granted.
  @override
  DateTime get grantDate;

  /// Expiry date (typically 10 years from grant).
  @override
  DateTime get expiryDate;

  /// Number of options already exercised.
  @override
  int get exercisedCount;

  /// Number of options cancelled/forfeited.
  @override
  int get cancelledCount;

  /// Vesting schedule ID.
  @override
  String? get vestingScheduleId;

  /// Round ID this grant is associated with.
  @override
  String? get roundId;

  /// Whether early exercise is allowed.
  @override
  bool get allowsEarlyExercise;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of OptionGrant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OptionGrantImplCopyWith<_$OptionGrantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
