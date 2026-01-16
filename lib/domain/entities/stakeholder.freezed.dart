// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stakeholder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Stakeholder _$StakeholderFromJson(Map<String, dynamic> json) {
  return _Stakeholder.fromJson(json);
}

/// @nodoc
mixin _$Stakeholder {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  StakeholderType get type => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  bool get hasProRataRights => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Stakeholder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Stakeholder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StakeholderCopyWith<Stakeholder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StakeholderCopyWith<$Res> {
  factory $StakeholderCopyWith(
    Stakeholder value,
    $Res Function(Stakeholder) then,
  ) = _$StakeholderCopyWithImpl<$Res, Stakeholder>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    StakeholderType type,
    String? email,
    String? phone,
    String? company,
    bool hasProRataRights,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$StakeholderCopyWithImpl<$Res, $Val extends Stakeholder>
    implements $StakeholderCopyWith<$Res> {
  _$StakeholderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Stakeholder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? type = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? company = freezed,
    Object? hasProRataRights = null,
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
                      as StakeholderType,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            company: freezed == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasProRataRights: null == hasProRataRights
                ? _value.hasProRataRights
                : hasProRataRights // ignore: cast_nullable_to_non_nullable
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
abstract class _$$StakeholderImplCopyWith<$Res>
    implements $StakeholderCopyWith<$Res> {
  factory _$$StakeholderImplCopyWith(
    _$StakeholderImpl value,
    $Res Function(_$StakeholderImpl) then,
  ) = __$$StakeholderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String name,
    StakeholderType type,
    String? email,
    String? phone,
    String? company,
    bool hasProRataRights,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$StakeholderImplCopyWithImpl<$Res>
    extends _$StakeholderCopyWithImpl<$Res, _$StakeholderImpl>
    implements _$$StakeholderImplCopyWith<$Res> {
  __$$StakeholderImplCopyWithImpl(
    _$StakeholderImpl _value,
    $Res Function(_$StakeholderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Stakeholder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? name = null,
    Object? type = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? company = freezed,
    Object? hasProRataRights = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$StakeholderImpl(
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
                  as StakeholderType,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        company: freezed == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasProRataRights: null == hasProRataRights
            ? _value.hasProRataRights
            : hasProRataRights // ignore: cast_nullable_to_non_nullable
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
class _$StakeholderImpl extends _Stakeholder {
  const _$StakeholderImpl({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    this.email,
    this.phone,
    this.company,
    this.hasProRataRights = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$StakeholderImpl.fromJson(Map<String, dynamic> json) =>
      _$$StakeholderImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String name;
  @override
  final StakeholderType type;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? company;
  @override
  @JsonKey()
  final bool hasProRataRights;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Stakeholder(id: $id, companyId: $companyId, name: $name, type: $type, email: $email, phone: $phone, company: $company, hasProRataRights: $hasProRataRights, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StakeholderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.hasProRataRights, hasProRataRights) ||
                other.hasProRataRights == hasProRataRights) &&
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
    email,
    phone,
    company,
    hasProRataRights,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Stakeholder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StakeholderImplCopyWith<_$StakeholderImpl> get copyWith =>
      __$$StakeholderImplCopyWithImpl<_$StakeholderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StakeholderImplToJson(this);
  }
}

abstract class _Stakeholder extends Stakeholder {
  const factory _Stakeholder({
    required final String id,
    required final String companyId,
    required final String name,
    required final StakeholderType type,
    final String? email,
    final String? phone,
    final String? company,
    final bool hasProRataRights,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$StakeholderImpl;
  const _Stakeholder._() : super._();

  factory _Stakeholder.fromJson(Map<String, dynamic> json) =
      _$StakeholderImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get name;
  @override
  StakeholderType get type;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get company;
  @override
  bool get hasProRataRights;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Stakeholder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StakeholderImplCopyWith<_$StakeholderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
