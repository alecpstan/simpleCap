// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'valuation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Valuation _$ValuationFromJson(Map<String, dynamic> json) {
  return _Valuation.fromJson(json);
}

/// @nodoc
mixin _$Valuation {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Pre-money valuation in AUD.
  double get preMoneyValue => throw _privateConstructorUsedError;

  /// Method used to calculate.
  ValuationMethod get method => throw _privateConstructorUsedError;

  /// Parameters used for calculation (JSON).
  /// Structure depends on method.
  String? get methodParamsJson => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Valuation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Valuation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValuationCopyWith<Valuation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValuationCopyWith<$Res> {
  factory $ValuationCopyWith(Valuation value, $Res Function(Valuation) then) =
      _$ValuationCopyWithImpl<$Res, Valuation>;
  @useResult
  $Res call({
    String id,
    String companyId,
    DateTime date,
    double preMoneyValue,
    ValuationMethod method,
    String? methodParamsJson,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ValuationCopyWithImpl<$Res, $Val extends Valuation>
    implements $ValuationCopyWith<$Res> {
  _$ValuationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Valuation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? date = null,
    Object? preMoneyValue = null,
    Object? method = null,
    Object? methodParamsJson = freezed,
    Object? notes = freezed,
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
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            preMoneyValue: null == preMoneyValue
                ? _value.preMoneyValue
                : preMoneyValue // ignore: cast_nullable_to_non_nullable
                      as double,
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as ValuationMethod,
            methodParamsJson: freezed == methodParamsJson
                ? _value.methodParamsJson
                : methodParamsJson // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ValuationImplCopyWith<$Res>
    implements $ValuationCopyWith<$Res> {
  factory _$$ValuationImplCopyWith(
    _$ValuationImpl value,
    $Res Function(_$ValuationImpl) then,
  ) = __$$ValuationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    DateTime date,
    double preMoneyValue,
    ValuationMethod method,
    String? methodParamsJson,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ValuationImplCopyWithImpl<$Res>
    extends _$ValuationCopyWithImpl<$Res, _$ValuationImpl>
    implements _$$ValuationImplCopyWith<$Res> {
  __$$ValuationImplCopyWithImpl(
    _$ValuationImpl _value,
    $Res Function(_$ValuationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Valuation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? date = null,
    Object? preMoneyValue = null,
    Object? method = null,
    Object? methodParamsJson = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ValuationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        preMoneyValue: null == preMoneyValue
            ? _value.preMoneyValue
            : preMoneyValue // ignore: cast_nullable_to_non_nullable
                  as double,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as ValuationMethod,
        methodParamsJson: freezed == methodParamsJson
            ? _value.methodParamsJson
            : methodParamsJson // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
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
class _$ValuationImpl extends _Valuation {
  const _$ValuationImpl({
    required this.id,
    required this.companyId,
    required this.date,
    required this.preMoneyValue,
    required this.method,
    this.methodParamsJson,
    this.notes,
    required this.createdAt,
  }) : super._();

  factory _$ValuationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValuationImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final DateTime date;

  /// Pre-money valuation in AUD.
  @override
  final double preMoneyValue;

  /// Method used to calculate.
  @override
  final ValuationMethod method;

  /// Parameters used for calculation (JSON).
  /// Structure depends on method.
  @override
  final String? methodParamsJson;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Valuation(id: $id, companyId: $companyId, date: $date, preMoneyValue: $preMoneyValue, method: $method, methodParamsJson: $methodParamsJson, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValuationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.preMoneyValue, preMoneyValue) ||
                other.preMoneyValue == preMoneyValue) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.methodParamsJson, methodParamsJson) ||
                other.methodParamsJson == methodParamsJson) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyId,
    date,
    preMoneyValue,
    method,
    methodParamsJson,
    notes,
    createdAt,
  );

  /// Create a copy of Valuation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValuationImplCopyWith<_$ValuationImpl> get copyWith =>
      __$$ValuationImplCopyWithImpl<_$ValuationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValuationImplToJson(this);
  }
}

abstract class _Valuation extends Valuation {
  const factory _Valuation({
    required final String id,
    required final String companyId,
    required final DateTime date,
    required final double preMoneyValue,
    required final ValuationMethod method,
    final String? methodParamsJson,
    final String? notes,
    required final DateTime createdAt,
  }) = _$ValuationImpl;
  const _Valuation._() : super._();

  factory _Valuation.fromJson(Map<String, dynamic> json) =
      _$ValuationImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  DateTime get date;

  /// Pre-money valuation in AUD.
  @override
  double get preMoneyValue;

  /// Method used to calculate.
  @override
  ValuationMethod get method;

  /// Parameters used for calculation (JSON).
  /// Structure depends on method.
  @override
  String? get methodParamsJson;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of Valuation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValuationImplCopyWith<_$ValuationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
