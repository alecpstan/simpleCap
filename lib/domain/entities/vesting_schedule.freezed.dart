// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vesting_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VestingSchedule _$VestingScheduleFromJson(Map<String, dynamic> json) {
  return _VestingSchedule.fromJson(json);
}

/// @nodoc
mixin _$VestingSchedule {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  VestingType get type => throw _privateConstructorUsedError;

  /// Total vesting period in months.
  int? get totalMonths => throw _privateConstructorUsedError;

  /// Cliff period in months (no vesting until cliff).
  int get cliffMonths => throw _privateConstructorUsedError;

  /// How often tranches vest after cliff.
  VestingFrequency? get frequency => throw _privateConstructorUsedError;

  /// For milestone vesting: JSON description of milestones.
  String? get milestonesJson => throw _privateConstructorUsedError;

  /// For hours vesting: total hours required.
  int? get totalHours => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VestingSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VestingSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VestingScheduleCopyWith<VestingSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VestingScheduleCopyWith<$Res> {
  factory $VestingScheduleCopyWith(
    VestingSchedule value,
    $Res Function(VestingSchedule) then,
  ) = _$VestingScheduleCopyWithImpl<$Res, VestingSchedule>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    VestingType type,
    int? totalMonths,
    int cliffMonths,
    VestingFrequency? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$VestingScheduleCopyWithImpl<$Res, $Val extends VestingSchedule>
    implements $VestingScheduleCopyWith<$Res> {
  _$VestingScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VestingSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? type = null,
    Object? totalMonths = freezed,
    Object? cliffMonths = null,
    Object? frequency = freezed,
    Object? milestonesJson = freezed,
    Object? totalHours = freezed,
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
                      as VestingType,
            totalMonths: freezed == totalMonths
                ? _value.totalMonths
                : totalMonths // ignore: cast_nullable_to_non_nullable
                      as int?,
            cliffMonths: null == cliffMonths
                ? _value.cliffMonths
                : cliffMonths // ignore: cast_nullable_to_non_nullable
                      as int,
            frequency: freezed == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as VestingFrequency?,
            milestonesJson: freezed == milestonesJson
                ? _value.milestonesJson
                : milestonesJson // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalHours: freezed == totalHours
                ? _value.totalHours
                : totalHours // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$VestingScheduleImplCopyWith<$Res>
    implements $VestingScheduleCopyWith<$Res> {
  factory _$$VestingScheduleImplCopyWith(
    _$VestingScheduleImpl value,
    $Res Function(_$VestingScheduleImpl) then,
  ) = __$$VestingScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    VestingType type,
    int? totalMonths,
    int cliffMonths,
    VestingFrequency? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$VestingScheduleImplCopyWithImpl<$Res>
    extends _$VestingScheduleCopyWithImpl<$Res, _$VestingScheduleImpl>
    implements _$$VestingScheduleImplCopyWith<$Res> {
  __$$VestingScheduleImplCopyWithImpl(
    _$VestingScheduleImpl _value,
    $Res Function(_$VestingScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VestingSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? type = null,
    Object? totalMonths = freezed,
    Object? cliffMonths = null,
    Object? frequency = freezed,
    Object? milestonesJson = freezed,
    Object? totalHours = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$VestingScheduleImpl(
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
                  as VestingType,
        totalMonths: freezed == totalMonths
            ? _value.totalMonths
            : totalMonths // ignore: cast_nullable_to_non_nullable
                  as int?,
        cliffMonths: null == cliffMonths
            ? _value.cliffMonths
            : cliffMonths // ignore: cast_nullable_to_non_nullable
                  as int,
        frequency: freezed == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as VestingFrequency?,
        milestonesJson: freezed == milestonesJson
            ? _value.milestonesJson
            : milestonesJson // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalHours: freezed == totalHours
            ? _value.totalHours
            : totalHours // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$VestingScheduleImpl extends _VestingSchedule {
  const _$VestingScheduleImpl({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    this.totalMonths,
    this.cliffMonths = 0,
    this.frequency,
    this.milestonesJson,
    this.totalHours,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$VestingScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$VestingScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String name;
  @override
  final VestingType type;

  /// Total vesting period in months.
  @override
  final int? totalMonths;

  /// Cliff period in months (no vesting until cliff).
  @override
  @JsonKey()
  final int cliffMonths;

  /// How often tranches vest after cliff.
  @override
  final VestingFrequency? frequency;

  /// For milestone vesting: JSON description of milestones.
  @override
  final String? milestonesJson;

  /// For hours vesting: total hours required.
  @override
  final int? totalHours;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'VestingSchedule(id: $id, companyId: $companyId, name: $name, type: $type, totalMonths: $totalMonths, cliffMonths: $cliffMonths, frequency: $frequency, milestonesJson: $milestonesJson, totalHours: $totalHours, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VestingScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.totalMonths, totalMonths) ||
                other.totalMonths == totalMonths) &&
            (identical(other.cliffMonths, cliffMonths) ||
                other.cliffMonths == cliffMonths) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.milestonesJson, milestonesJson) ||
                other.milestonesJson == milestonesJson) &&
            (identical(other.totalHours, totalHours) ||
                other.totalHours == totalHours) &&
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
    totalMonths,
    cliffMonths,
    frequency,
    milestonesJson,
    totalHours,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of VestingSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VestingScheduleImplCopyWith<_$VestingScheduleImpl> get copyWith =>
      __$$VestingScheduleImplCopyWithImpl<_$VestingScheduleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VestingScheduleImplToJson(this);
  }
}

abstract class _VestingSchedule extends VestingSchedule {
  const factory _VestingSchedule({
    required final String id,
    required final String companyId,
    required final String name,
    required final VestingType type,
    final int? totalMonths,
    final int cliffMonths,
    final VestingFrequency? frequency,
    final String? milestonesJson,
    final int? totalHours,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$VestingScheduleImpl;
  const _VestingSchedule._() : super._();

  factory _VestingSchedule.fromJson(Map<String, dynamic> json) =
      _$VestingScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get name;
  @override
  VestingType get type;

  /// Total vesting period in months.
  @override
  int? get totalMonths;

  /// Cliff period in months (no vesting until cliff).
  @override
  int get cliffMonths;

  /// How often tranches vest after cliff.
  @override
  VestingFrequency? get frequency;

  /// For milestone vesting: JSON description of milestones.
  @override
  String? get milestonesJson;

  /// For hours vesting: total hours required.
  @override
  int? get totalHours;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of VestingSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VestingScheduleImplCopyWith<_$VestingScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
