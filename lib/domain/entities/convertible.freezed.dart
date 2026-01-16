// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'convertible.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Convertible _$ConvertibleFromJson(Map<String, dynamic> json) {
  return _Convertible.fromJson(json);
}

/// @nodoc
mixin _$Convertible {
  String get id => throw _privateConstructorUsedError;
  String get companyId => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  ConvertibleType get type => throw _privateConstructorUsedError;
  ConvertibleStatus get status => throw _privateConstructorUsedError;

  /// Principal amount invested.
  double get principal => throw _privateConstructorUsedError;

  /// Valuation cap (if any).
  double? get valuationCap => throw _privateConstructorUsedError;

  /// Discount percentage (0-100).
  double? get discountPercent => throw _privateConstructorUsedError;

  /// Interest rate for notes (annual, 0-100).
  double? get interestRate => throw _privateConstructorUsedError;

  /// Maturity date for notes.
  DateTime? get maturityDate => throw _privateConstructorUsedError;

  /// Date instrument was issued.
  DateTime get issueDate => throw _privateConstructorUsedError;

  /// Whether this has Most Favored Nation clause.
  bool get hasMfn => throw _privateConstructorUsedError;

  /// Whether holder has pro-rata rights in future rounds.
  bool get hasProRata => throw _privateConstructorUsedError;

  /// Transaction ID when converted (if converted).
  String? get conversionEventId => throw _privateConstructorUsedError;

  /// Share class ID received on conversion.
  String? get convertedToShareClassId => throw _privateConstructorUsedError;

  /// Number of shares received on conversion.
  int? get sharesReceived => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Convertible to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Convertible
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConvertibleCopyWith<Convertible> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConvertibleCopyWith<$Res> {
  factory $ConvertibleCopyWith(
    Convertible value,
    $Res Function(Convertible) then,
  ) = _$ConvertibleCopyWithImpl<$Res, Convertible>;
  @useResult
  $Res call({
    String id,
    String companyId,
    String stakeholderId,
    ConvertibleType type,
    ConvertibleStatus status,
    double principal,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? maturityDate,
    DateTime issueDate,
    bool hasMfn,
    bool hasProRata,
    String? conversionEventId,
    String? convertedToShareClassId,
    int? sharesReceived,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ConvertibleCopyWithImpl<$Res, $Val extends Convertible>
    implements $ConvertibleCopyWith<$Res> {
  _$ConvertibleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Convertible
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stakeholderId = null,
    Object? type = null,
    Object? status = null,
    Object? principal = null,
    Object? valuationCap = freezed,
    Object? discountPercent = freezed,
    Object? interestRate = freezed,
    Object? maturityDate = freezed,
    Object? issueDate = null,
    Object? hasMfn = null,
    Object? hasProRata = null,
    Object? conversionEventId = freezed,
    Object? convertedToShareClassId = freezed,
    Object? sharesReceived = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ConvertibleType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ConvertibleStatus,
            principal: null == principal
                ? _value.principal
                : principal // ignore: cast_nullable_to_non_nullable
                      as double,
            valuationCap: freezed == valuationCap
                ? _value.valuationCap
                : valuationCap // ignore: cast_nullable_to_non_nullable
                      as double?,
            discountPercent: freezed == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                      as double?,
            interestRate: freezed == interestRate
                ? _value.interestRate
                : interestRate // ignore: cast_nullable_to_non_nullable
                      as double?,
            maturityDate: freezed == maturityDate
                ? _value.maturityDate
                : maturityDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            issueDate: null == issueDate
                ? _value.issueDate
                : issueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            hasMfn: null == hasMfn
                ? _value.hasMfn
                : hasMfn // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasProRata: null == hasProRata
                ? _value.hasProRata
                : hasProRata // ignore: cast_nullable_to_non_nullable
                      as bool,
            conversionEventId: freezed == conversionEventId
                ? _value.conversionEventId
                : conversionEventId // ignore: cast_nullable_to_non_nullable
                      as String?,
            convertedToShareClassId: freezed == convertedToShareClassId
                ? _value.convertedToShareClassId
                : convertedToShareClassId // ignore: cast_nullable_to_non_nullable
                      as String?,
            sharesReceived: freezed == sharesReceived
                ? _value.sharesReceived
                : sharesReceived // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ConvertibleImplCopyWith<$Res>
    implements $ConvertibleCopyWith<$Res> {
  factory _$$ConvertibleImplCopyWith(
    _$ConvertibleImpl value,
    $Res Function(_$ConvertibleImpl) then,
  ) = __$$ConvertibleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyId,
    String stakeholderId,
    ConvertibleType type,
    ConvertibleStatus status,
    double principal,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? maturityDate,
    DateTime issueDate,
    bool hasMfn,
    bool hasProRata,
    String? conversionEventId,
    String? convertedToShareClassId,
    int? sharesReceived,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ConvertibleImplCopyWithImpl<$Res>
    extends _$ConvertibleCopyWithImpl<$Res, _$ConvertibleImpl>
    implements _$$ConvertibleImplCopyWith<$Res> {
  __$$ConvertibleImplCopyWithImpl(
    _$ConvertibleImpl _value,
    $Res Function(_$ConvertibleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Convertible
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? stakeholderId = null,
    Object? type = null,
    Object? status = null,
    Object? principal = null,
    Object? valuationCap = freezed,
    Object? discountPercent = freezed,
    Object? interestRate = freezed,
    Object? maturityDate = freezed,
    Object? issueDate = null,
    Object? hasMfn = null,
    Object? hasProRata = null,
    Object? conversionEventId = freezed,
    Object? convertedToShareClassId = freezed,
    Object? sharesReceived = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ConvertibleImpl(
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
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ConvertibleType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ConvertibleStatus,
        principal: null == principal
            ? _value.principal
            : principal // ignore: cast_nullable_to_non_nullable
                  as double,
        valuationCap: freezed == valuationCap
            ? _value.valuationCap
            : valuationCap // ignore: cast_nullable_to_non_nullable
                  as double?,
        discountPercent: freezed == discountPercent
            ? _value.discountPercent
            : discountPercent // ignore: cast_nullable_to_non_nullable
                  as double?,
        interestRate: freezed == interestRate
            ? _value.interestRate
            : interestRate // ignore: cast_nullable_to_non_nullable
                  as double?,
        maturityDate: freezed == maturityDate
            ? _value.maturityDate
            : maturityDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        issueDate: null == issueDate
            ? _value.issueDate
            : issueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        hasMfn: null == hasMfn
            ? _value.hasMfn
            : hasMfn // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasProRata: null == hasProRata
            ? _value.hasProRata
            : hasProRata // ignore: cast_nullable_to_non_nullable
                  as bool,
        conversionEventId: freezed == conversionEventId
            ? _value.conversionEventId
            : conversionEventId // ignore: cast_nullable_to_non_nullable
                  as String?,
        convertedToShareClassId: freezed == convertedToShareClassId
            ? _value.convertedToShareClassId
            : convertedToShareClassId // ignore: cast_nullable_to_non_nullable
                  as String?,
        sharesReceived: freezed == sharesReceived
            ? _value.sharesReceived
            : sharesReceived // ignore: cast_nullable_to_non_nullable
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
class _$ConvertibleImpl extends _Convertible {
  const _$ConvertibleImpl({
    required this.id,
    required this.companyId,
    required this.stakeholderId,
    required this.type,
    this.status = ConvertibleStatus.outstanding,
    required this.principal,
    this.valuationCap,
    this.discountPercent,
    this.interestRate,
    this.maturityDate,
    required this.issueDate,
    this.hasMfn = false,
    this.hasProRata = false,
    this.conversionEventId,
    this.convertedToShareClassId,
    this.sharesReceived,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$ConvertibleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConvertibleImplFromJson(json);

  @override
  final String id;
  @override
  final String companyId;
  @override
  final String stakeholderId;
  @override
  final ConvertibleType type;
  @override
  @JsonKey()
  final ConvertibleStatus status;

  /// Principal amount invested.
  @override
  final double principal;

  /// Valuation cap (if any).
  @override
  final double? valuationCap;

  /// Discount percentage (0-100).
  @override
  final double? discountPercent;

  /// Interest rate for notes (annual, 0-100).
  @override
  final double? interestRate;

  /// Maturity date for notes.
  @override
  final DateTime? maturityDate;

  /// Date instrument was issued.
  @override
  final DateTime issueDate;

  /// Whether this has Most Favored Nation clause.
  @override
  @JsonKey()
  final bool hasMfn;

  /// Whether holder has pro-rata rights in future rounds.
  @override
  @JsonKey()
  final bool hasProRata;

  /// Transaction ID when converted (if converted).
  @override
  final String? conversionEventId;

  /// Share class ID received on conversion.
  @override
  final String? convertedToShareClassId;

  /// Number of shares received on conversion.
  @override
  final int? sharesReceived;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Convertible(id: $id, companyId: $companyId, stakeholderId: $stakeholderId, type: $type, status: $status, principal: $principal, valuationCap: $valuationCap, discountPercent: $discountPercent, interestRate: $interestRate, maturityDate: $maturityDate, issueDate: $issueDate, hasMfn: $hasMfn, hasProRata: $hasProRata, conversionEventId: $conversionEventId, convertedToShareClassId: $convertedToShareClassId, sharesReceived: $sharesReceived, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConvertibleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.stakeholderId, stakeholderId) ||
                other.stakeholderId == stakeholderId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.valuationCap, valuationCap) ||
                other.valuationCap == valuationCap) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.interestRate, interestRate) ||
                other.interestRate == interestRate) &&
            (identical(other.maturityDate, maturityDate) ||
                other.maturityDate == maturityDate) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.hasMfn, hasMfn) || other.hasMfn == hasMfn) &&
            (identical(other.hasProRata, hasProRata) ||
                other.hasProRata == hasProRata) &&
            (identical(other.conversionEventId, conversionEventId) ||
                other.conversionEventId == conversionEventId) &&
            (identical(
                  other.convertedToShareClassId,
                  convertedToShareClassId,
                ) ||
                other.convertedToShareClassId == convertedToShareClassId) &&
            (identical(other.sharesReceived, sharesReceived) ||
                other.sharesReceived == sharesReceived) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    companyId,
    stakeholderId,
    type,
    status,
    principal,
    valuationCap,
    discountPercent,
    interestRate,
    maturityDate,
    issueDate,
    hasMfn,
    hasProRata,
    conversionEventId,
    convertedToShareClassId,
    sharesReceived,
    notes,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Convertible
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConvertibleImplCopyWith<_$ConvertibleImpl> get copyWith =>
      __$$ConvertibleImplCopyWithImpl<_$ConvertibleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConvertibleImplToJson(this);
  }
}

abstract class _Convertible extends Convertible {
  const factory _Convertible({
    required final String id,
    required final String companyId,
    required final String stakeholderId,
    required final ConvertibleType type,
    final ConvertibleStatus status,
    required final double principal,
    final double? valuationCap,
    final double? discountPercent,
    final double? interestRate,
    final DateTime? maturityDate,
    required final DateTime issueDate,
    final bool hasMfn,
    final bool hasProRata,
    final String? conversionEventId,
    final String? convertedToShareClassId,
    final int? sharesReceived,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ConvertibleImpl;
  const _Convertible._() : super._();

  factory _Convertible.fromJson(Map<String, dynamic> json) =
      _$ConvertibleImpl.fromJson;

  @override
  String get id;
  @override
  String get companyId;
  @override
  String get stakeholderId;
  @override
  ConvertibleType get type;
  @override
  ConvertibleStatus get status;

  /// Principal amount invested.
  @override
  double get principal;

  /// Valuation cap (if any).
  @override
  double? get valuationCap;

  /// Discount percentage (0-100).
  @override
  double? get discountPercent;

  /// Interest rate for notes (annual, 0-100).
  @override
  double? get interestRate;

  /// Maturity date for notes.
  @override
  DateTime? get maturityDate;

  /// Date instrument was issued.
  @override
  DateTime get issueDate;

  /// Whether this has Most Favored Nation clause.
  @override
  bool get hasMfn;

  /// Whether holder has pro-rata rights in future rounds.
  @override
  bool get hasProRata;

  /// Transaction ID when converted (if converted).
  @override
  String? get conversionEventId;

  /// Share class ID received on conversion.
  @override
  String? get convertedToShareClassId;

  /// Number of shares received on conversion.
  @override
  int? get sharesReceived;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Convertible
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConvertibleImplCopyWith<_$ConvertibleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
