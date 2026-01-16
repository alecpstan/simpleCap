// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capitalization_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CapitalizationEvent _$CapitalizationEventFromJson(Map<String, dynamic> json) {
  return _CapitalizationEvent.fromJson(json);
}

/// @nodoc
mixin _$CapitalizationEvent {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  CapEventType get eventType => throw _privateConstructorUsedError;

  /// Date when this event takes effect.
  DateTime get effectiveDate => throw _privateConstructorUsedError;

  /// JSON payload containing event-specific data.
  String get eventDataJson => throw _privateConstructorUsedError;

  /// Round associated with this event (if any).
  String? get roundId => throw _privateConstructorUsedError;

  /// When this event was recorded.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CapitalizationEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CapitalizationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapitalizationEventCopyWith<CapitalizationEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CapitalizationEventCopyWith<$Res> {
  factory $CapitalizationEventCopyWith(
    CapitalizationEvent value,
    $Res Function(CapitalizationEvent) then,
  ) = _$CapitalizationEventCopyWithImpl<$Res, CapitalizationEvent>;
  @useResult
  $Res call({
    String id,
    String companyId,
    CapEventType eventType,
    DateTime effectiveDate,
    String eventDataJson,
    String? roundId,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CapitalizationEventCopyWithImpl<$Res, $Val extends CapitalizationEvent>
    implements $CapitalizationEventCopyWith<$Res> {
  _$CapitalizationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CapitalizationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? eventType = null,
    Object? effectiveDate = null,
    Object? eventDataJson = null,
    Object? roundId = freezed,
    Object? createdAt = null,
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
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as CapEventType,
            effectiveDate: null == effectiveDate
                ? _value.effectiveDate
                : effectiveDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            eventDataJson: null == eventDataJson
                ? _value.eventDataJson
                : eventDataJson // ignore: cast_nullable_to_non_nullable
                      as String,
            roundId: freezed == roundId
                ? _value.roundId
                : roundId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CapitalizationEventImplCopyWith<$Res>
    implements $CapitalizationEventCopyWith<$Res> {
  factory _$$CapitalizationEventImplCopyWith(
    _$CapitalizationEventImpl value,
    $Res Function(_$CapitalizationEventImpl) then,
  ) = __$$CapitalizationEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    CapEventType eventType,
    DateTime effectiveDate,
    String eventDataJson,
    String? roundId,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CapitalizationEventImplCopyWithImpl<$Res>
    extends _$CapitalizationEventCopyWithImpl<$Res, _$CapitalizationEventImpl>
    implements _$$CapitalizationEventImplCopyWith<$Res> {
  __$$CapitalizationEventImplCopyWithImpl(
    _$CapitalizationEventImpl _value,
    $Res Function(_$CapitalizationEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CapitalizationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? eventType = null,
    Object? effectiveDate = null,
    Object? eventDataJson = null,
    Object? roundId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$CapitalizationEventImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as CapEventType,
        effectiveDate: null == effectiveDate
            ? _value.effectiveDate
            : effectiveDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        eventDataJson: null == eventDataJson
            ? _value.eventDataJson
            : eventDataJson // ignore: cast_nullable_to_non_nullable
                  as String,
        roundId: freezed == roundId
            ? _value.roundId
            : roundId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CapitalizationEventImpl extends _CapitalizationEvent {
  const _$CapitalizationEventImpl({
    required this.id,
    required this.companyId,
    required this.eventType,
    required this.effectiveDate,
    required this.eventDataJson,
    this.roundId,
    required this.createdAt,
  }) : super._();

  factory _$CapitalizationEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$CapitalizationEventImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final CapEventType eventType;

  /// Date when this event takes effect.
  @override
  final DateTime effectiveDate;

  /// JSON payload containing event-specific data.
  @override
  final String eventDataJson;

  /// Round associated with this event (if any).
  @override
  final String? roundId;

  /// When this event was recorded.
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CapitalizationEvent(id: $id, companyId: $companyId, eventType: $eventType, effectiveDate: $effectiveDate, eventDataJson: $eventDataJson, roundId: $roundId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapitalizationEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.effectiveDate, effectiveDate) ||
                other.effectiveDate == effectiveDate) &&
            (identical(other.eventDataJson, eventDataJson) ||
                other.eventDataJson == eventDataJson) &&
            (identical(other.roundId, roundId) || other.roundId == roundId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyId,
    eventType,
    effectiveDate,
    eventDataJson,
    roundId,
    createdAt,
  );

  /// Create a copy of CapitalizationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapitalizationEventImplCopyWith<_$CapitalizationEventImpl> get copyWith =>
      __$$CapitalizationEventImplCopyWithImpl<_$CapitalizationEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CapitalizationEventImplToJson(this);
  }
}

abstract class _CapitalizationEvent extends CapitalizationEvent {
  const factory _CapitalizationEvent({
    required final String id,
    required final String companyId,
    required final CapEventType eventType,
    required final DateTime effectiveDate,
    required final String eventDataJson,
    final String? roundId,
    required final DateTime createdAt,
  }) = _$CapitalizationEventImpl;
  const _CapitalizationEvent._() : super._();

  factory _CapitalizationEvent.fromJson(Map<String, dynamic> json) =
      _$CapitalizationEventImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  CapEventType get eventType;

  /// Date when this event takes effect.
  @override
  DateTime get effectiveDate;

  /// JSON payload containing event-specific data.
  @override
  String get eventDataJson;

  /// Round associated with this event (if any).
  @override
  String? get roundId;

  /// When this event was recorded.
  @override
  DateTime get createdAt;

  /// Create a copy of CapitalizationEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapitalizationEventImplCopyWith<_$CapitalizationEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareIssuanceData _$ShareIssuanceDataFromJson(Map<String, dynamic> json) {
  return _ShareIssuanceData.fromJson(json);
}

/// @nodoc
mixin _$ShareIssuanceData {
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  double get pricePerShare => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String? get vestingScheduleId => throw _privateConstructorUsedError;

  /// Serializes this ShareIssuanceData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareIssuanceData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareIssuanceDataCopyWith<ShareIssuanceData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareIssuanceDataCopyWith<$Res> {
  factory $ShareIssuanceDataCopyWith(
    ShareIssuanceData value,
    $Res Function(ShareIssuanceData) then,
  ) = _$ShareIssuanceDataCopyWithImpl<$Res, ShareIssuanceData>;
  @useResult
  $Res call({
    String stakeholderId,
    String shareClassId,
    int shareCount,
    double pricePerShare,
    double totalAmount,
    String? vestingScheduleId,
  });
}

/// @nodoc
class _$ShareIssuanceDataCopyWithImpl<$Res, $Val extends ShareIssuanceData>
    implements $ShareIssuanceDataCopyWith<$Res> {
  _$ShareIssuanceDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareIssuanceData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? pricePerShare = null,
    Object? totalAmount = null,
    Object? vestingScheduleId = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            pricePerShare: null == pricePerShare
                ? _value.pricePerShare
                : pricePerShare // ignore: cast_nullable_to_non_nullable
                      as double,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ShareIssuanceDataImplCopyWith<$Res>
    implements $ShareIssuanceDataCopyWith<$Res> {
  factory _$$ShareIssuanceDataImplCopyWith(
    _$ShareIssuanceDataImpl value,
    $Res Function(_$ShareIssuanceDataImpl) then,
  ) = __$$ShareIssuanceDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String stakeholderId,
    String shareClassId,
    int shareCount,
    double pricePerShare,
    double totalAmount,
    String? vestingScheduleId,
  });
}

/// @nodoc
class __$$ShareIssuanceDataImplCopyWithImpl<$Res>
    extends _$ShareIssuanceDataCopyWithImpl<$Res, _$ShareIssuanceDataImpl>
    implements _$$ShareIssuanceDataImplCopyWith<$Res> {
  __$$ShareIssuanceDataImplCopyWithImpl(
    _$ShareIssuanceDataImpl _value,
    $Res Function(_$ShareIssuanceDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShareIssuanceData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? pricePerShare = null,
    Object? totalAmount = null,
    Object? vestingScheduleId = freezed,
  }) {
    return _then(
      _$ShareIssuanceDataImpl(
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
        pricePerShare: null == pricePerShare
            ? _value.pricePerShare
            : pricePerShare // ignore: cast_nullable_to_non_nullable
                  as double,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
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
class _$ShareIssuanceDataImpl implements _ShareIssuanceData {
  const _$ShareIssuanceDataImpl({
    required this.stakeholderId,
    required this.shareClassId,
    required this.shareCount,
    required this.pricePerShare,
    required this.totalAmount,
    this.vestingScheduleId,
  });

  factory _$ShareIssuanceDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareIssuanceDataImplFromJson(json);

  @override
  final String stakeholderId;
  @override
  final String shareClassId;
  @override
  final int shareCount;
  @override
  final double pricePerShare;
  @override
  final double totalAmount;
  @override
  final String? vestingScheduleId;

  @override
  String toString() {
    return 'ShareIssuanceData(stakeholderId: $stakeholderId, shareClassId: $shareClassId, shareCount: $shareCount, pricePerShare: $pricePerShare, totalAmount: $totalAmount, vestingScheduleId: $vestingScheduleId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareIssuanceDataImpl &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.pricePerShare, pricePerShare) ||
                other.pricePerShare == pricePerShare) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.vestingScheduleId, vestingScheduleId) ||
                other.vestingScheduleId == vestingScheduleId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stakeholderId,
    shareClassId,
    shareCount,
    pricePerShare,
    totalAmount,
    vestingScheduleId,
  );

  /// Create a copy of ShareIssuanceData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareIssuanceDataImplCopyWith<_$ShareIssuanceDataImpl> get copyWith =>
      __$$ShareIssuanceDataImplCopyWithImpl<_$ShareIssuanceDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareIssuanceDataImplToJson(this);
  }
}

abstract class _ShareIssuanceData implements ShareIssuanceData {
  const factory _ShareIssuanceData({
    required final String stakeholderId,
    required final String shareClassId,
    required final int shareCount,
    required final double pricePerShare,
    required final double totalAmount,
    final String? vestingScheduleId,
  }) = _$ShareIssuanceDataImpl;

  factory _ShareIssuanceData.fromJson(Map<String, dynamic> json) =
      _$ShareIssuanceDataImpl.fromJson;

  @override
  String get stakeholderId;
  @override
  String get shareClassId;
  @override
  int get shareCount;
  @override
  double get pricePerShare;
  @override
  double get totalAmount;
  @override
  String? get vestingScheduleId;

  /// Create a copy of ShareIssuanceData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareIssuanceDataImplCopyWith<_$ShareIssuanceDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareTransferData _$ShareTransferDataFromJson(Map<String, dynamic> json) {
  return _ShareTransferData.fromJson(json);
}

/// @nodoc
mixin _$ShareTransferData {
  String get fromStakeholderId => throw _privateConstructorUsedError;
  String get toStakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  double get pricePerShare => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;

  /// Serializes this ShareTransferData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareTransferData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareTransferDataCopyWith<ShareTransferData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareTransferDataCopyWith<$Res> {
  factory $ShareTransferDataCopyWith(
    ShareTransferData value,
    $Res Function(ShareTransferData) then,
  ) = _$ShareTransferDataCopyWithImpl<$Res, ShareTransferData>;
  @useResult
  $Res call({
    String fromStakeholderId,
    String toStakeholderId,
    String shareClassId,
    int shareCount,
    double pricePerShare,
    double totalAmount,
  });
}

/// @nodoc
class _$ShareTransferDataCopyWithImpl<$Res, $Val extends ShareTransferData>
    implements $ShareTransferDataCopyWith<$Res> {
  _$ShareTransferDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareTransferData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromStakeholderId = null,
    Object? toStakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? pricePerShare = null,
    Object? totalAmount = null,
  }) {
    return _then(
      _value.copyWith(
            fromStakeholderId: null == fromStakeholderId
                ? _value.fromStakeholderId
                : fromStakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            toStakeholderId: null == toStakeholderId
                ? _value.toStakeholderId
                : toStakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            shareClassId: null == shareClassId
                ? _value.shareClassId
                : shareClassId // ignore: cast_nullable_to_non_nullable
                      as String,
            shareCount: null == shareCount
                ? _value.shareCount
                : shareCount // ignore: cast_nullable_to_non_nullable
                      as int,
            pricePerShare: null == pricePerShare
                ? _value.pricePerShare
                : pricePerShare // ignore: cast_nullable_to_non_nullable
                      as double,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShareTransferDataImplCopyWith<$Res>
    implements $ShareTransferDataCopyWith<$Res> {
  factory _$$ShareTransferDataImplCopyWith(
    _$ShareTransferDataImpl value,
    $Res Function(_$ShareTransferDataImpl) then,
  ) = __$$ShareTransferDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fromStakeholderId,
    String toStakeholderId,
    String shareClassId,
    int shareCount,
    double pricePerShare,
    double totalAmount,
  });
}

/// @nodoc
class __$$ShareTransferDataImplCopyWithImpl<$Res>
    extends _$ShareTransferDataCopyWithImpl<$Res, _$ShareTransferDataImpl>
    implements _$$ShareTransferDataImplCopyWith<$Res> {
  __$$ShareTransferDataImplCopyWithImpl(
    _$ShareTransferDataImpl _value,
    $Res Function(_$ShareTransferDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShareTransferData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromStakeholderId = null,
    Object? toStakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? pricePerShare = null,
    Object? totalAmount = null,
  }) {
    return _then(
      _$ShareTransferDataImpl(
        fromStakeholderId: null == fromStakeholderId
            ? _value.fromStakeholderId
            : fromStakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        toStakeholderId: null == toStakeholderId
            ? _value.toStakeholderId
            : toStakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        shareClassId: null == shareClassId
            ? _value.shareClassId
            : shareClassId // ignore: cast_nullable_to_non_nullable
                  as String,
        shareCount: null == shareCount
            ? _value.shareCount
            : shareCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pricePerShare: null == pricePerShare
            ? _value.pricePerShare
            : pricePerShare // ignore: cast_nullable_to_non_nullable
                  as double,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShareTransferDataImpl implements _ShareTransferData {
  const _$ShareTransferDataImpl({
    required this.fromStakeholderId,
    required this.toStakeholderId,
    required this.shareClassId,
    required this.shareCount,
    required this.pricePerShare,
    required this.totalAmount,
  });

  factory _$ShareTransferDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareTransferDataImplFromJson(json);

  @override
  final String fromStakeholderId;
  @override
  final String toStakeholderId;
  @override
  final String shareClassId;
  @override
  final int shareCount;
  @override
  final double pricePerShare;
  @override
  final double totalAmount;

  @override
  String toString() {
    return 'ShareTransferData(fromStakeholderId: $fromStakeholderId, toStakeholderId: $toStakeholderId, shareClassId: $shareClassId, shareCount: $shareCount, pricePerShare: $pricePerShare, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareTransferDataImpl &&
            (identical(other.fromStakeholderId, fromStakeholderId) ||
                other.fromStakeholderId == fromStakeholderId) &&
            (identical(other.toStakeholderId, toStakeholderId) ||
                other.toStakeholderId == toStakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.pricePerShare, pricePerShare) ||
                other.pricePerShare == pricePerShare) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fromStakeholderId,
    toStakeholderId,
    shareClassId,
    shareCount,
    pricePerShare,
    totalAmount,
  );

  /// Create a copy of ShareTransferData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareTransferDataImplCopyWith<_$ShareTransferDataImpl> get copyWith =>
      __$$ShareTransferDataImplCopyWithImpl<_$ShareTransferDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareTransferDataImplToJson(this);
  }
}

abstract class _ShareTransferData implements ShareTransferData {
  const factory _ShareTransferData({
    required final String fromStakeholderId,
    required final String toStakeholderId,
    required final String shareClassId,
    required final int shareCount,
    required final double pricePerShare,
    required final double totalAmount,
  }) = _$ShareTransferDataImpl;

  factory _ShareTransferData.fromJson(Map<String, dynamic> json) =
      _$ShareTransferDataImpl.fromJson;

  @override
  String get fromStakeholderId;
  @override
  String get toStakeholderId;
  @override
  String get shareClassId;
  @override
  int get shareCount;
  @override
  double get pricePerShare;
  @override
  double get totalAmount;

  /// Create a copy of ShareTransferData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareTransferDataImplCopyWith<_$ShareTransferDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareCancellationData _$ShareCancellationDataFromJson(
  Map<String, dynamic> json,
) {
  return _ShareCancellationData.fromJson(json);
}

/// @nodoc
mixin _$ShareCancellationData {
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  double? get repurchasePrice => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this ShareCancellationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareCancellationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareCancellationDataCopyWith<ShareCancellationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareCancellationDataCopyWith<$Res> {
  factory $ShareCancellationDataCopyWith(
    ShareCancellationData value,
    $Res Function(ShareCancellationData) then,
  ) = _$ShareCancellationDataCopyWithImpl<$Res, ShareCancellationData>;
  @useResult
  $Res call({
    String stakeholderId,
    String shareClassId,
    int shareCount,
    double? repurchasePrice,
    String? reason,
  });
}

/// @nodoc
class _$ShareCancellationDataCopyWithImpl<
  $Res,
  $Val extends ShareCancellationData
>
    implements $ShareCancellationDataCopyWith<$Res> {
  _$ShareCancellationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareCancellationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? repurchasePrice = freezed,
    Object? reason = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            repurchasePrice: freezed == repurchasePrice
                ? _value.repurchasePrice
                : repurchasePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShareCancellationDataImplCopyWith<$Res>
    implements $ShareCancellationDataCopyWith<$Res> {
  factory _$$ShareCancellationDataImplCopyWith(
    _$ShareCancellationDataImpl value,
    $Res Function(_$ShareCancellationDataImpl) then,
  ) = __$$ShareCancellationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String stakeholderId,
    String shareClassId,
    int shareCount,
    double? repurchasePrice,
    String? reason,
  });
}

/// @nodoc
class __$$ShareCancellationDataImplCopyWithImpl<$Res>
    extends
        _$ShareCancellationDataCopyWithImpl<$Res, _$ShareCancellationDataImpl>
    implements _$$ShareCancellationDataImplCopyWith<$Res> {
  __$$ShareCancellationDataImplCopyWithImpl(
    _$ShareCancellationDataImpl _value,
    $Res Function(_$ShareCancellationDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShareCancellationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? repurchasePrice = freezed,
    Object? reason = freezed,
  }) {
    return _then(
      _$ShareCancellationDataImpl(
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
        repurchasePrice: freezed == repurchasePrice
            ? _value.repurchasePrice
            : repurchasePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShareCancellationDataImpl implements _ShareCancellationData {
  const _$ShareCancellationDataImpl({
    required this.stakeholderId,
    required this.shareClassId,
    required this.shareCount,
    this.repurchasePrice,
    this.reason,
  });

  factory _$ShareCancellationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareCancellationDataImplFromJson(json);

  @override
  final String stakeholderId;
  @override
  final String shareClassId;
  @override
  final int shareCount;
  @override
  final double? repurchasePrice;
  @override
  final String? reason;

  @override
  String toString() {
    return 'ShareCancellationData(stakeholderId: $stakeholderId, shareClassId: $shareClassId, shareCount: $shareCount, repurchasePrice: $repurchasePrice, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareCancellationDataImpl &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.repurchasePrice, repurchasePrice) ||
                other.repurchasePrice == repurchasePrice) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    stakeholderId,
    shareClassId,
    shareCount,
    repurchasePrice,
    reason,
  );

  /// Create a copy of ShareCancellationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareCancellationDataImplCopyWith<_$ShareCancellationDataImpl>
  get copyWith =>
      __$$ShareCancellationDataImplCopyWithImpl<_$ShareCancellationDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareCancellationDataImplToJson(this);
  }
}

abstract class _ShareCancellationData implements ShareCancellationData {
  const factory _ShareCancellationData({
    required final String stakeholderId,
    required final String shareClassId,
    required final int shareCount,
    final double? repurchasePrice,
    final String? reason,
  }) = _$ShareCancellationDataImpl;

  factory _ShareCancellationData.fromJson(Map<String, dynamic> json) =
      _$ShareCancellationDataImpl.fromJson;

  @override
  String get stakeholderId;
  @override
  String get shareClassId;
  @override
  int get shareCount;
  @override
  double? get repurchasePrice;
  @override
  String? get reason;

  /// Create a copy of ShareCancellationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareCancellationDataImplCopyWith<_$ShareCancellationDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ExerciseData _$ExerciseDataFromJson(Map<String, dynamic> json) {
  return _ExerciseData.fromJson(json);
}

/// @nodoc
mixin _$ExerciseData {
  /// ID of the option grant or warrant being exercised.
  String get instrumentId => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get strikePrice => throw _privateConstructorUsedError;
  double get totalCost => throw _privateConstructorUsedError;

  /// Serializes this ExerciseData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseDataCopyWith<ExerciseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseDataCopyWith<$Res> {
  factory $ExerciseDataCopyWith(
    ExerciseData value,
    $Res Function(ExerciseData) then,
  ) = _$ExerciseDataCopyWithImpl<$Res, ExerciseData>;
  @useResult
  $Res call({
    String instrumentId,
    String stakeholderId,
    String shareClassId,
    int quantity,
    double strikePrice,
    double totalCost,
  });
}

/// @nodoc
class _$ExerciseDataCopyWithImpl<$Res, $Val extends ExerciseData>
    implements $ExerciseDataCopyWith<$Res> {
  _$ExerciseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instrumentId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? quantity = null,
    Object? strikePrice = null,
    Object? totalCost = null,
  }) {
    return _then(
      _value.copyWith(
            instrumentId: null == instrumentId
                ? _value.instrumentId
                : instrumentId // ignore: cast_nullable_to_non_nullable
                      as String,
            stakeholderId: null == stakeholderId
                ? _value.stakeholderId
                : stakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            shareClassId: null == shareClassId
                ? _value.shareClassId
                : shareClassId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            strikePrice: null == strikePrice
                ? _value.strikePrice
                : strikePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            totalCost: null == totalCost
                ? _value.totalCost
                : totalCost // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExerciseDataImplCopyWith<$Res>
    implements $ExerciseDataCopyWith<$Res> {
  factory _$$ExerciseDataImplCopyWith(
    _$ExerciseDataImpl value,
    $Res Function(_$ExerciseDataImpl) then,
  ) = __$$ExerciseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String instrumentId,
    String stakeholderId,
    String shareClassId,
    int quantity,
    double strikePrice,
    double totalCost,
  });
}

/// @nodoc
class __$$ExerciseDataImplCopyWithImpl<$Res>
    extends _$ExerciseDataCopyWithImpl<$Res, _$ExerciseDataImpl>
    implements _$$ExerciseDataImplCopyWith<$Res> {
  __$$ExerciseDataImplCopyWithImpl(
    _$ExerciseDataImpl _value,
    $Res Function(_$ExerciseDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instrumentId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? quantity = null,
    Object? strikePrice = null,
    Object? totalCost = null,
  }) {
    return _then(
      _$ExerciseDataImpl(
        instrumentId: null == instrumentId
            ? _value.instrumentId
            : instrumentId // ignore: cast_nullable_to_non_nullable
                  as String,
        stakeholderId: null == stakeholderId
            ? _value.stakeholderId
            : stakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        shareClassId: null == shareClassId
            ? _value.shareClassId
            : shareClassId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        strikePrice: null == strikePrice
            ? _value.strikePrice
            : strikePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        totalCost: null == totalCost
            ? _value.totalCost
            : totalCost // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseDataImpl implements _ExerciseData {
  const _$ExerciseDataImpl({
    required this.instrumentId,
    required this.stakeholderId,
    required this.shareClassId,
    required this.quantity,
    required this.strikePrice,
    required this.totalCost,
  });

  factory _$ExerciseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseDataImplFromJson(json);

  /// ID of the option grant or warrant being exercised.
  @override
  final String instrumentId;
  @override
  final String stakeholderId;
  @override
  final String shareClassId;
  @override
  final int quantity;
  @override
  final double strikePrice;
  @override
  final double totalCost;

  @override
  String toString() {
    return 'ExerciseData(instrumentId: $instrumentId, stakeholderId: $stakeholderId, shareClassId: $shareClassId, quantity: $quantity, strikePrice: $strikePrice, totalCost: $totalCost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseDataImpl &&
            (identical(other.instrumentId, instrumentId) ||
                other.instrumentId == instrumentId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.strikePrice, strikePrice) ||
                other.strikePrice == strikePrice) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    instrumentId,
    stakeholderId,
    shareClassId,
    quantity,
    strikePrice,
    totalCost,
  );

  /// Create a copy of ExerciseData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseDataImplCopyWith<_$ExerciseDataImpl> get copyWith =>
      __$$ExerciseDataImplCopyWithImpl<_$ExerciseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseDataImplToJson(this);
  }
}

abstract class _ExerciseData implements ExerciseData {
  const factory _ExerciseData({
    required final String instrumentId,
    required final String stakeholderId,
    required final String shareClassId,
    required final int quantity,
    required final double strikePrice,
    required final double totalCost,
  }) = _$ExerciseDataImpl;

  factory _ExerciseData.fromJson(Map<String, dynamic> json) =
      _$ExerciseDataImpl.fromJson;

  /// ID of the option grant or warrant being exercised.
  @override
  String get instrumentId;
  @override
  String get stakeholderId;
  @override
  String get shareClassId;
  @override
  int get quantity;
  @override
  double get strikePrice;
  @override
  double get totalCost;

  /// Create a copy of ExerciseData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseDataImplCopyWith<_$ExerciseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConversionData _$ConversionDataFromJson(Map<String, dynamic> json) {
  return _ConversionData.fromJson(json);
}

/// @nodoc
mixin _$ConversionData {
  String get convertibleId => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  int get sharesIssued => throw _privateConstructorUsedError;
  double get effectivePrice => throw _privateConstructorUsedError;
  double get principalConverted => throw _privateConstructorUsedError;
  double get interestConverted => throw _privateConstructorUsedError;

  /// Serializes this ConversionData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversionDataCopyWith<ConversionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversionDataCopyWith<$Res> {
  factory $ConversionDataCopyWith(
    ConversionData value,
    $Res Function(ConversionData) then,
  ) = _$ConversionDataCopyWithImpl<$Res, ConversionData>;
  @useResult
  $Res call({
    String convertibleId,
    String stakeholderId,
    String shareClassId,
    int sharesIssued,
    double effectivePrice,
    double principalConverted,
    double interestConverted,
  });
}

/// @nodoc
class _$ConversionDataCopyWithImpl<$Res, $Val extends ConversionData>
    implements $ConversionDataCopyWith<$Res> {
  _$ConversionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? convertibleId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? sharesIssued = null,
    Object? effectivePrice = null,
    Object? principalConverted = null,
    Object? interestConverted = null,
  }) {
    return _then(
      _value.copyWith(
            convertibleId: null == convertibleId
                ? _value.convertibleId
                : convertibleId // ignore: cast_nullable_to_non_nullable
                      as String,
            stakeholderId: null == stakeholderId
                ? _value.stakeholderId
                : stakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            shareClassId: null == shareClassId
                ? _value.shareClassId
                : shareClassId // ignore: cast_nullable_to_non_nullable
                      as String,
            sharesIssued: null == sharesIssued
                ? _value.sharesIssued
                : sharesIssued // ignore: cast_nullable_to_non_nullable
                      as int,
            effectivePrice: null == effectivePrice
                ? _value.effectivePrice
                : effectivePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            principalConverted: null == principalConverted
                ? _value.principalConverted
                : principalConverted // ignore: cast_nullable_to_non_nullable
                      as double,
            interestConverted: null == interestConverted
                ? _value.interestConverted
                : interestConverted // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversionDataImplCopyWith<$Res>
    implements $ConversionDataCopyWith<$Res> {
  factory _$$ConversionDataImplCopyWith(
    _$ConversionDataImpl value,
    $Res Function(_$ConversionDataImpl) then,
  ) = __$$ConversionDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String convertibleId,
    String stakeholderId,
    String shareClassId,
    int sharesIssued,
    double effectivePrice,
    double principalConverted,
    double interestConverted,
  });
}

/// @nodoc
class __$$ConversionDataImplCopyWithImpl<$Res>
    extends _$ConversionDataCopyWithImpl<$Res, _$ConversionDataImpl>
    implements _$$ConversionDataImplCopyWith<$Res> {
  __$$ConversionDataImplCopyWithImpl(
    _$ConversionDataImpl _value,
    $Res Function(_$ConversionDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? convertibleId = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? sharesIssued = null,
    Object? effectivePrice = null,
    Object? principalConverted = null,
    Object? interestConverted = null,
  }) {
    return _then(
      _$ConversionDataImpl(
        convertibleId: null == convertibleId
            ? _value.convertibleId
            : convertibleId // ignore: cast_nullable_to_non_nullable
                  as String,
        stakeholderId: null == stakeholderId
            ? _value.stakeholderId
            : stakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        shareClassId: null == shareClassId
            ? _value.shareClassId
            : shareClassId // ignore: cast_nullable_to_non_nullable
                  as String,
        sharesIssued: null == sharesIssued
            ? _value.sharesIssued
            : sharesIssued // ignore: cast_nullable_to_non_nullable
                  as int,
        effectivePrice: null == effectivePrice
            ? _value.effectivePrice
            : effectivePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        principalConverted: null == principalConverted
            ? _value.principalConverted
            : principalConverted // ignore: cast_nullable_to_non_nullable
                  as double,
        interestConverted: null == interestConverted
            ? _value.interestConverted
            : interestConverted // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversionDataImpl implements _ConversionData {
  const _$ConversionDataImpl({
    required this.convertibleId,
    required this.stakeholderId,
    required this.shareClassId,
    required this.sharesIssued,
    required this.effectivePrice,
    required this.principalConverted,
    required this.interestConverted,
  });

  factory _$ConversionDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversionDataImplFromJson(json);

  @override
  final String convertibleId;
  @override
  final String stakeholderId;
  @override
  final String shareClassId;
  @override
  final int sharesIssued;
  @override
  final double effectivePrice;
  @override
  final double principalConverted;
  @override
  final double interestConverted;

  @override
  String toString() {
    return 'ConversionData(convertibleId: $convertibleId, stakeholderId: $stakeholderId, shareClassId: $shareClassId, sharesIssued: $sharesIssued, effectivePrice: $effectivePrice, principalConverted: $principalConverted, interestConverted: $interestConverted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversionDataImpl &&
            (identical(other.convertibleId, convertibleId) ||
                other.convertibleId == convertibleId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.sharesIssued, sharesIssued) ||
                other.sharesIssued == sharesIssued) &&
            (identical(other.effectivePrice, effectivePrice) ||
                other.effectivePrice == effectivePrice) &&
            (identical(other.principalConverted, principalConverted) ||
                other.principalConverted == principalConverted) &&
            (identical(other.interestConverted, interestConverted) ||
                other.interestConverted == interestConverted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    convertibleId,
    stakeholderId,
    shareClassId,
    sharesIssued,
    effectivePrice,
    principalConverted,
    interestConverted,
  );

  /// Create a copy of ConversionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversionDataImplCopyWith<_$ConversionDataImpl> get copyWith =>
      __$$ConversionDataImplCopyWithImpl<_$ConversionDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversionDataImplToJson(this);
  }
}

abstract class _ConversionData implements ConversionData {
  const factory _ConversionData({
    required final String convertibleId,
    required final String stakeholderId,
    required final String shareClassId,
    required final int sharesIssued,
    required final double effectivePrice,
    required final double principalConverted,
    required final double interestConverted,
  }) = _$ConversionDataImpl;

  factory _ConversionData.fromJson(Map<String, dynamic> json) =
      _$ConversionDataImpl.fromJson;

  @override
  String get convertibleId;
  @override
  String get stakeholderId;
  @override
  String get shareClassId;
  @override
  int get sharesIssued;
  @override
  double get effectivePrice;
  @override
  double get principalConverted;
  @override
  double get interestConverted;

  /// Create a copy of ConversionData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversionDataImplCopyWith<_$ConversionDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
