// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cap_table_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CapTableState _$CapTableStateFromJson(Map<String, dynamic> json) {
  return _CapTableState.fromJson(json);
}

/// @nodoc
mixin _$CapTableState {
  String get companyId => throw _privateConstructorUsedError;
  String get companyName => throw _privateConstructorUsedError;
  DateTime get companyCreatedAt => throw _privateConstructorUsedError;
  Map<String, StakeholderState> get stakeholders =>
      throw _privateConstructorUsedError;
  Map<String, ShareClassState> get shareClasses =>
      throw _privateConstructorUsedError;
  Map<String, RoundState> get rounds => throw _privateConstructorUsedError;
  Map<String, HoldingState> get holdings => throw _privateConstructorUsedError;
  Map<String, ConvertibleState> get convertibles =>
      throw _privateConstructorUsedError;
  Map<String, EsopPoolState> get esopPools =>
      throw _privateConstructorUsedError;
  Map<String, OptionGrantState> get optionGrants =>
      throw _privateConstructorUsedError;
  Map<String, WarrantState> get warrants => throw _privateConstructorUsedError;
  Map<String, VestingScheduleState> get vestingSchedules =>
      throw _privateConstructorUsedError;
  Map<String, ValuationState> get valuations =>
      throw _privateConstructorUsedError;
  Map<String, TransferState> get transfers =>
      throw _privateConstructorUsedError;
  Map<String, ScenarioState> get scenarios =>
      throw _privateConstructorUsedError;
  int get lastSequenceNumber => throw _privateConstructorUsedError;

  /// Serializes this CapTableState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CapTableState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CapTableStateCopyWith<CapTableState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CapTableStateCopyWith<$Res> {
  factory $CapTableStateCopyWith(
    CapTableState value,
    $Res Function(CapTableState) then,
  ) = _$CapTableStateCopyWithImpl<$Res, CapTableState>;
  @useResult
  $Res call({
    String companyId,
    String companyName,
    DateTime companyCreatedAt,
    Map<String, StakeholderState> stakeholders,
    Map<String, ShareClassState> shareClasses,
    Map<String, RoundState> rounds,
    Map<String, HoldingState> holdings,
    Map<String, ConvertibleState> convertibles,
    Map<String, EsopPoolState> esopPools,
    Map<String, OptionGrantState> optionGrants,
    Map<String, WarrantState> warrants,
    Map<String, VestingScheduleState> vestingSchedules,
    Map<String, ValuationState> valuations,
    Map<String, TransferState> transfers,
    Map<String, ScenarioState> scenarios,
    int lastSequenceNumber,
  });
}

/// @nodoc
class _$CapTableStateCopyWithImpl<$Res, $Val extends CapTableState>
    implements $CapTableStateCopyWith<$Res> {
  _$CapTableStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CapTableState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyId = null,
    Object? companyName = null,
    Object? companyCreatedAt = null,
    Object? stakeholders = null,
    Object? shareClasses = null,
    Object? rounds = null,
    Object? holdings = null,
    Object? convertibles = null,
    Object? esopPools = null,
    Object? optionGrants = null,
    Object? warrants = null,
    Object? vestingSchedules = null,
    Object? valuations = null,
    Object? transfers = null,
    Object? scenarios = null,
    Object? lastSequenceNumber = null,
  }) {
    return _then(
      _value.copyWith(
            companyId: null == companyId
                ? _value.companyId
                : companyId // ignore: cast_nullable_to_non_nullable
                      as String,
            companyName: null == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String,
            companyCreatedAt: null == companyCreatedAt
                ? _value.companyCreatedAt
                : companyCreatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            stakeholders: null == stakeholders
                ? _value.stakeholders
                : stakeholders // ignore: cast_nullable_to_non_nullable
                      as Map<String, StakeholderState>,
            shareClasses: null == shareClasses
                ? _value.shareClasses
                : shareClasses // ignore: cast_nullable_to_non_nullable
                      as Map<String, ShareClassState>,
            rounds: null == rounds
                ? _value.rounds
                : rounds // ignore: cast_nullable_to_non_nullable
                      as Map<String, RoundState>,
            holdings: null == holdings
                ? _value.holdings
                : holdings // ignore: cast_nullable_to_non_nullable
                      as Map<String, HoldingState>,
            convertibles: null == convertibles
                ? _value.convertibles
                : convertibles // ignore: cast_nullable_to_non_nullable
                      as Map<String, ConvertibleState>,
            esopPools: null == esopPools
                ? _value.esopPools
                : esopPools // ignore: cast_nullable_to_non_nullable
                      as Map<String, EsopPoolState>,
            optionGrants: null == optionGrants
                ? _value.optionGrants
                : optionGrants // ignore: cast_nullable_to_non_nullable
                      as Map<String, OptionGrantState>,
            warrants: null == warrants
                ? _value.warrants
                : warrants // ignore: cast_nullable_to_non_nullable
                      as Map<String, WarrantState>,
            vestingSchedules: null == vestingSchedules
                ? _value.vestingSchedules
                : vestingSchedules // ignore: cast_nullable_to_non_nullable
                      as Map<String, VestingScheduleState>,
            valuations: null == valuations
                ? _value.valuations
                : valuations // ignore: cast_nullable_to_non_nullable
                      as Map<String, ValuationState>,
            transfers: null == transfers
                ? _value.transfers
                : transfers // ignore: cast_nullable_to_non_nullable
                      as Map<String, TransferState>,
            scenarios: null == scenarios
                ? _value.scenarios
                : scenarios // ignore: cast_nullable_to_non_nullable
                      as Map<String, ScenarioState>,
            lastSequenceNumber: null == lastSequenceNumber
                ? _value.lastSequenceNumber
                : lastSequenceNumber // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CapTableStateImplCopyWith<$Res>
    implements $CapTableStateCopyWith<$Res> {
  factory _$$CapTableStateImplCopyWith(
    _$CapTableStateImpl value,
    $Res Function(_$CapTableStateImpl) then,
  ) = __$$CapTableStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String companyId,
    String companyName,
    DateTime companyCreatedAt,
    Map<String, StakeholderState> stakeholders,
    Map<String, ShareClassState> shareClasses,
    Map<String, RoundState> rounds,
    Map<String, HoldingState> holdings,
    Map<String, ConvertibleState> convertibles,
    Map<String, EsopPoolState> esopPools,
    Map<String, OptionGrantState> optionGrants,
    Map<String, WarrantState> warrants,
    Map<String, VestingScheduleState> vestingSchedules,
    Map<String, ValuationState> valuations,
    Map<String, TransferState> transfers,
    Map<String, ScenarioState> scenarios,
    int lastSequenceNumber,
  });
}

/// @nodoc
class __$$CapTableStateImplCopyWithImpl<$Res>
    extends _$CapTableStateCopyWithImpl<$Res, _$CapTableStateImpl>
    implements _$$CapTableStateImplCopyWith<$Res> {
  __$$CapTableStateImplCopyWithImpl(
    _$CapTableStateImpl _value,
    $Res Function(_$CapTableStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CapTableState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyId = null,
    Object? companyName = null,
    Object? companyCreatedAt = null,
    Object? stakeholders = null,
    Object? shareClasses = null,
    Object? rounds = null,
    Object? holdings = null,
    Object? convertibles = null,
    Object? esopPools = null,
    Object? optionGrants = null,
    Object? warrants = null,
    Object? vestingSchedules = null,
    Object? valuations = null,
    Object? transfers = null,
    Object? scenarios = null,
    Object? lastSequenceNumber = null,
  }) {
    return _then(
      _$CapTableStateImpl(
        companyId: null == companyId
            ? _value.companyId
            : companyId // ignore: cast_nullable_to_non_nullable
                  as String,
        companyName: null == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String,
        companyCreatedAt: null == companyCreatedAt
            ? _value.companyCreatedAt
            : companyCreatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        stakeholders: null == stakeholders
            ? _value._stakeholders
            : stakeholders // ignore: cast_nullable_to_non_nullable
                  as Map<String, StakeholderState>,
        shareClasses: null == shareClasses
            ? _value._shareClasses
            : shareClasses // ignore: cast_nullable_to_non_nullable
                  as Map<String, ShareClassState>,
        rounds: null == rounds
            ? _value._rounds
            : rounds // ignore: cast_nullable_to_non_nullable
                  as Map<String, RoundState>,
        holdings: null == holdings
            ? _value._holdings
            : holdings // ignore: cast_nullable_to_non_nullable
                  as Map<String, HoldingState>,
        convertibles: null == convertibles
            ? _value._convertibles
            : convertibles // ignore: cast_nullable_to_non_nullable
                  as Map<String, ConvertibleState>,
        esopPools: null == esopPools
            ? _value._esopPools
            : esopPools // ignore: cast_nullable_to_non_nullable
                  as Map<String, EsopPoolState>,
        optionGrants: null == optionGrants
            ? _value._optionGrants
            : optionGrants // ignore: cast_nullable_to_non_nullable
                  as Map<String, OptionGrantState>,
        warrants: null == warrants
            ? _value._warrants
            : warrants // ignore: cast_nullable_to_non_nullable
                  as Map<String, WarrantState>,
        vestingSchedules: null == vestingSchedules
            ? _value._vestingSchedules
            : vestingSchedules // ignore: cast_nullable_to_non_nullable
                  as Map<String, VestingScheduleState>,
        valuations: null == valuations
            ? _value._valuations
            : valuations // ignore: cast_nullable_to_non_nullable
                  as Map<String, ValuationState>,
        transfers: null == transfers
            ? _value._transfers
            : transfers // ignore: cast_nullable_to_non_nullable
                  as Map<String, TransferState>,
        scenarios: null == scenarios
            ? _value._scenarios
            : scenarios // ignore: cast_nullable_to_non_nullable
                  as Map<String, ScenarioState>,
        lastSequenceNumber: null == lastSequenceNumber
            ? _value.lastSequenceNumber
            : lastSequenceNumber // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CapTableStateImpl extends _CapTableState {
  const _$CapTableStateImpl({
    required this.companyId,
    required this.companyName,
    required this.companyCreatedAt,
    final Map<String, StakeholderState> stakeholders = const {},
    final Map<String, ShareClassState> shareClasses = const {},
    final Map<String, RoundState> rounds = const {},
    final Map<String, HoldingState> holdings = const {},
    final Map<String, ConvertibleState> convertibles = const {},
    final Map<String, EsopPoolState> esopPools = const {},
    final Map<String, OptionGrantState> optionGrants = const {},
    final Map<String, WarrantState> warrants = const {},
    final Map<String, VestingScheduleState> vestingSchedules = const {},
    final Map<String, ValuationState> valuations = const {},
    final Map<String, TransferState> transfers = const {},
    final Map<String, ScenarioState> scenarios = const {},
    this.lastSequenceNumber = 0,
  }) : _stakeholders = stakeholders,
       _shareClasses = shareClasses,
       _rounds = rounds,
       _holdings = holdings,
       _convertibles = convertibles,
       _esopPools = esopPools,
       _optionGrants = optionGrants,
       _warrants = warrants,
       _vestingSchedules = vestingSchedules,
       _valuations = valuations,
       _transfers = transfers,
       _scenarios = scenarios,
       super._();

  factory _$CapTableStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CapTableStateImplFromJson(json);

  @override
  final String companyId;
  @override
  final String companyName;
  @override
  final DateTime companyCreatedAt;
  final Map<String, StakeholderState> _stakeholders;
  @override
  @JsonKey()
  Map<String, StakeholderState> get stakeholders {
    if (_stakeholders is EqualUnmodifiableMapView) return _stakeholders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stakeholders);
  }

  final Map<String, ShareClassState> _shareClasses;
  @override
  @JsonKey()
  Map<String, ShareClassState> get shareClasses {
    if (_shareClasses is EqualUnmodifiableMapView) return _shareClasses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_shareClasses);
  }

  final Map<String, RoundState> _rounds;
  @override
  @JsonKey()
  Map<String, RoundState> get rounds {
    if (_rounds is EqualUnmodifiableMapView) return _rounds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rounds);
  }

  final Map<String, HoldingState> _holdings;
  @override
  @JsonKey()
  Map<String, HoldingState> get holdings {
    if (_holdings is EqualUnmodifiableMapView) return _holdings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_holdings);
  }

  final Map<String, ConvertibleState> _convertibles;
  @override
  @JsonKey()
  Map<String, ConvertibleState> get convertibles {
    if (_convertibles is EqualUnmodifiableMapView) return _convertibles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_convertibles);
  }

  final Map<String, EsopPoolState> _esopPools;
  @override
  @JsonKey()
  Map<String, EsopPoolState> get esopPools {
    if (_esopPools is EqualUnmodifiableMapView) return _esopPools;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_esopPools);
  }

  final Map<String, OptionGrantState> _optionGrants;
  @override
  @JsonKey()
  Map<String, OptionGrantState> get optionGrants {
    if (_optionGrants is EqualUnmodifiableMapView) return _optionGrants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_optionGrants);
  }

  final Map<String, WarrantState> _warrants;
  @override
  @JsonKey()
  Map<String, WarrantState> get warrants {
    if (_warrants is EqualUnmodifiableMapView) return _warrants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_warrants);
  }

  final Map<String, VestingScheduleState> _vestingSchedules;
  @override
  @JsonKey()
  Map<String, VestingScheduleState> get vestingSchedules {
    if (_vestingSchedules is EqualUnmodifiableMapView) return _vestingSchedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_vestingSchedules);
  }

  final Map<String, ValuationState> _valuations;
  @override
  @JsonKey()
  Map<String, ValuationState> get valuations {
    if (_valuations is EqualUnmodifiableMapView) return _valuations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_valuations);
  }

  final Map<String, TransferState> _transfers;
  @override
  @JsonKey()
  Map<String, TransferState> get transfers {
    if (_transfers is EqualUnmodifiableMapView) return _transfers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_transfers);
  }

  final Map<String, ScenarioState> _scenarios;
  @override
  @JsonKey()
  Map<String, ScenarioState> get scenarios {
    if (_scenarios is EqualUnmodifiableMapView) return _scenarios;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scenarios);
  }

  @override
  @JsonKey()
  final int lastSequenceNumber;

  @override
  String toString() {
    return 'CapTableState(companyId: $companyId, companyName: $companyName, companyCreatedAt: $companyCreatedAt, stakeholders: $stakeholders, shareClasses: $shareClasses, rounds: $rounds, holdings: $holdings, convertibles: $convertibles, esopPools: $esopPools, optionGrants: $optionGrants, warrants: $warrants, vestingSchedules: $vestingSchedules, valuations: $valuations, transfers: $transfers, scenarios: $scenarios, lastSequenceNumber: $lastSequenceNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CapTableStateImpl &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.companyCreatedAt, companyCreatedAt) ||
                other.companyCreatedAt == companyCreatedAt) &&
            const DeepCollectionEquality().equals(
              other._stakeholders,
              _stakeholders,
            ) &&
            const DeepCollectionEquality().equals(
              other._shareClasses,
              _shareClasses,
            ) &&
            const DeepCollectionEquality().equals(other._rounds, _rounds) &&
            const DeepCollectionEquality().equals(other._holdings, _holdings) &&
            const DeepCollectionEquality().equals(
              other._convertibles,
              _convertibles,
            ) &&
            const DeepCollectionEquality().equals(
              other._esopPools,
              _esopPools,
            ) &&
            const DeepCollectionEquality().equals(
              other._optionGrants,
              _optionGrants,
            ) &&
            const DeepCollectionEquality().equals(other._warrants, _warrants) &&
            const DeepCollectionEquality().equals(
              other._vestingSchedules,
              _vestingSchedules,
            ) &&
            const DeepCollectionEquality().equals(
              other._valuations,
              _valuations,
            ) &&
            const DeepCollectionEquality().equals(
              other._transfers,
              _transfers,
            ) &&
            const DeepCollectionEquality().equals(
              other._scenarios,
              _scenarios,
            ) &&
            (identical(other.lastSequenceNumber, lastSequenceNumber) ||
                other.lastSequenceNumber == lastSequenceNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    companyId,
    companyName,
    companyCreatedAt,
    const DeepCollectionEquality().hash(_stakeholders),
    const DeepCollectionEquality().hash(_shareClasses),
    const DeepCollectionEquality().hash(_rounds),
    const DeepCollectionEquality().hash(_holdings),
    const DeepCollectionEquality().hash(_convertibles),
    const DeepCollectionEquality().hash(_esopPools),
    const DeepCollectionEquality().hash(_optionGrants),
    const DeepCollectionEquality().hash(_warrants),
    const DeepCollectionEquality().hash(_vestingSchedules),
    const DeepCollectionEquality().hash(_valuations),
    const DeepCollectionEquality().hash(_transfers),
    const DeepCollectionEquality().hash(_scenarios),
    lastSequenceNumber,
  );

  /// Create a copy of CapTableState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CapTableStateImplCopyWith<_$CapTableStateImpl> get copyWith =>
      __$$CapTableStateImplCopyWithImpl<_$CapTableStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CapTableStateImplToJson(this);
  }
}

abstract class _CapTableState extends CapTableState {
  const factory _CapTableState({
    required final String companyId,
    required final String companyName,
    required final DateTime companyCreatedAt,
    final Map<String, StakeholderState> stakeholders,
    final Map<String, ShareClassState> shareClasses,
    final Map<String, RoundState> rounds,
    final Map<String, HoldingState> holdings,
    final Map<String, ConvertibleState> convertibles,
    final Map<String, EsopPoolState> esopPools,
    final Map<String, OptionGrantState> optionGrants,
    final Map<String, WarrantState> warrants,
    final Map<String, VestingScheduleState> vestingSchedules,
    final Map<String, ValuationState> valuations,
    final Map<String, TransferState> transfers,
    final Map<String, ScenarioState> scenarios,
    final int lastSequenceNumber,
  }) = _$CapTableStateImpl;
  const _CapTableState._() : super._();

  factory _CapTableState.fromJson(Map<String, dynamic> json) =
      _$CapTableStateImpl.fromJson;

  @override
  String get companyId;
  @override
  String get companyName;
  @override
  DateTime get companyCreatedAt;
  @override
  Map<String, StakeholderState> get stakeholders;
  @override
  Map<String, ShareClassState> get shareClasses;
  @override
  Map<String, RoundState> get rounds;
  @override
  Map<String, HoldingState> get holdings;
  @override
  Map<String, ConvertibleState> get convertibles;
  @override
  Map<String, EsopPoolState> get esopPools;
  @override
  Map<String, OptionGrantState> get optionGrants;
  @override
  Map<String, WarrantState> get warrants;
  @override
  Map<String, VestingScheduleState> get vestingSchedules;
  @override
  Map<String, ValuationState> get valuations;
  @override
  Map<String, TransferState> get transfers;
  @override
  Map<String, ScenarioState> get scenarios;
  @override
  int get lastSequenceNumber;

  /// Create a copy of CapTableState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CapTableStateImplCopyWith<_$CapTableStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StakeholderState _$StakeholderStateFromJson(Map<String, dynamic> json) {
  return _StakeholderState.fromJson(json);
}

/// @nodoc
mixin _$StakeholderState {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  bool get hasProRataRights => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StakeholderState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StakeholderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StakeholderStateCopyWith<StakeholderState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StakeholderStateCopyWith<$Res> {
  factory $StakeholderStateCopyWith(
    StakeholderState value,
    $Res Function(StakeholderState) then,
  ) = _$StakeholderStateCopyWithImpl<$Res, StakeholderState>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
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
class _$StakeholderStateCopyWithImpl<$Res, $Val extends StakeholderState>
    implements $StakeholderStateCopyWith<$Res> {
  _$StakeholderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StakeholderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$StakeholderStateImplCopyWith<$Res>
    implements $StakeholderStateCopyWith<$Res> {
  factory _$$StakeholderStateImplCopyWith(
    _$StakeholderStateImpl value,
    $Res Function(_$StakeholderStateImpl) then,
  ) = __$$StakeholderStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
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
class __$$StakeholderStateImplCopyWithImpl<$Res>
    extends _$StakeholderStateCopyWithImpl<$Res, _$StakeholderStateImpl>
    implements _$$StakeholderStateImplCopyWith<$Res> {
  __$$StakeholderStateImplCopyWithImpl(
    _$StakeholderStateImpl _value,
    $Res Function(_$StakeholderStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StakeholderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
      _$StakeholderStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$StakeholderStateImpl implements _StakeholderState {
  const _$StakeholderStateImpl({
    required this.id,
    required this.name,
    required this.type,
    this.email,
    this.phone,
    this.company,
    this.hasProRataRights = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$StakeholderStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$StakeholderStateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
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
    return 'StakeholderState(id: $id, name: $name, type: $type, email: $email, phone: $phone, company: $company, hasProRataRights: $hasProRataRights, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StakeholderStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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

  /// Create a copy of StakeholderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StakeholderStateImplCopyWith<_$StakeholderStateImpl> get copyWith =>
      __$$StakeholderStateImplCopyWithImpl<_$StakeholderStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StakeholderStateImplToJson(this);
  }
}

abstract class _StakeholderState implements StakeholderState {
  const factory _StakeholderState({
    required final String id,
    required final String name,
    required final String type,
    final String? email,
    final String? phone,
    final String? company,
    final bool hasProRataRights,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$StakeholderStateImpl;

  factory _StakeholderState.fromJson(Map<String, dynamic> json) =
      _$StakeholderStateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
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

  /// Create a copy of StakeholderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StakeholderStateImplCopyWith<_$StakeholderStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShareClassState _$ShareClassStateFromJson(Map<String, dynamic> json) {
  return _ShareClassState.fromJson(json);
}

/// @nodoc
mixin _$ShareClassState {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  double get votingMultiplier => throw _privateConstructorUsedError;
  double get liquidationPreference => throw _privateConstructorUsedError;
  bool get isParticipating => throw _privateConstructorUsedError;
  double get dividendRate => throw _privateConstructorUsedError;
  int get seniority => throw _privateConstructorUsedError;
  String get antiDilutionType => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ShareClassState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareClassState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareClassStateCopyWith<ShareClassState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareClassStateCopyWith<$Res> {
  factory $ShareClassStateCopyWith(
    ShareClassState value,
    $Res Function(ShareClassState) then,
  ) = _$ShareClassStateCopyWithImpl<$Res, ShareClassState>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    double votingMultiplier,
    double liquidationPreference,
    bool isParticipating,
    double dividendRate,
    int seniority,
    String antiDilutionType,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ShareClassStateCopyWithImpl<$Res, $Val extends ShareClassState>
    implements $ShareClassStateCopyWith<$Res> {
  _$ShareClassStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareClassState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? votingMultiplier = null,
    Object? liquidationPreference = null,
    Object? isParticipating = null,
    Object? dividendRate = null,
    Object? seniority = null,
    Object? antiDilutionType = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
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
            antiDilutionType: null == antiDilutionType
                ? _value.antiDilutionType
                : antiDilutionType // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$ShareClassStateImplCopyWith<$Res>
    implements $ShareClassStateCopyWith<$Res> {
  factory _$$ShareClassStateImplCopyWith(
    _$ShareClassStateImpl value,
    $Res Function(_$ShareClassStateImpl) then,
  ) = __$$ShareClassStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    double votingMultiplier,
    double liquidationPreference,
    bool isParticipating,
    double dividendRate,
    int seniority,
    String antiDilutionType,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ShareClassStateImplCopyWithImpl<$Res>
    extends _$ShareClassStateCopyWithImpl<$Res, _$ShareClassStateImpl>
    implements _$$ShareClassStateImplCopyWith<$Res> {
  __$$ShareClassStateImplCopyWithImpl(
    _$ShareClassStateImpl _value,
    $Res Function(_$ShareClassStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShareClassState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? votingMultiplier = null,
    Object? liquidationPreference = null,
    Object? isParticipating = null,
    Object? dividendRate = null,
    Object? seniority = null,
    Object? antiDilutionType = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ShareClassStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
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
        antiDilutionType: null == antiDilutionType
            ? _value.antiDilutionType
            : antiDilutionType // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$ShareClassStateImpl implements _ShareClassState {
  const _$ShareClassStateImpl({
    required this.id,
    required this.name,
    required this.type,
    this.votingMultiplier = 1.0,
    this.liquidationPreference = 1.0,
    this.isParticipating = false,
    this.dividendRate = 0.0,
    this.seniority = 0,
    this.antiDilutionType = 'none',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ShareClassStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareClassStateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  @JsonKey()
  final double votingMultiplier;
  @override
  @JsonKey()
  final double liquidationPreference;
  @override
  @JsonKey()
  final bool isParticipating;
  @override
  @JsonKey()
  final double dividendRate;
  @override
  @JsonKey()
  final int seniority;
  @override
  @JsonKey()
  final String antiDilutionType;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ShareClassState(id: $id, name: $name, type: $type, votingMultiplier: $votingMultiplier, liquidationPreference: $liquidationPreference, isParticipating: $isParticipating, dividendRate: $dividendRate, seniority: $seniority, antiDilutionType: $antiDilutionType, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareClassStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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
            (identical(other.antiDilutionType, antiDilutionType) ||
                other.antiDilutionType == antiDilutionType) &&
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
    name,
    type,
    votingMultiplier,
    liquidationPreference,
    isParticipating,
    dividendRate,
    seniority,
    antiDilutionType,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ShareClassState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareClassStateImplCopyWith<_$ShareClassStateImpl> get copyWith =>
      __$$ShareClassStateImplCopyWithImpl<_$ShareClassStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareClassStateImplToJson(this);
  }
}

abstract class _ShareClassState implements ShareClassState {
  const factory _ShareClassState({
    required final String id,
    required final String name,
    required final String type,
    final double votingMultiplier,
    final double liquidationPreference,
    final bool isParticipating,
    final double dividendRate,
    final int seniority,
    final String antiDilutionType,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ShareClassStateImpl;

  factory _ShareClassState.fromJson(Map<String, dynamic> json) =
      _$ShareClassStateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  double get votingMultiplier;
  @override
  double get liquidationPreference;
  @override
  bool get isParticipating;
  @override
  double get dividendRate;
  @override
  int get seniority;
  @override
  String get antiDilutionType;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of ShareClassState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareClassStateImplCopyWith<_$ShareClassStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoundState _$RoundStateFromJson(Map<String, dynamic> json) {
  return _RoundState.fromJson(json);
}

/// @nodoc
mixin _$RoundState {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double? get preMoneyValuation => throw _privateConstructorUsedError;
  double? get pricePerShare => throw _privateConstructorUsedError;
  double get amountRaised => throw _privateConstructorUsedError;
  String? get leadInvestorId => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RoundState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoundStateCopyWith<RoundState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoundStateCopyWith<$Res> {
  factory $RoundStateCopyWith(
    RoundState value,
    $Res Function(RoundState) then,
  ) = _$RoundStateCopyWithImpl<$Res, RoundState>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String status,
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
class _$RoundStateCopyWithImpl<$Res, $Val extends RoundState>
    implements $RoundStateCopyWith<$Res> {
  _$RoundStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$RoundStateImplCopyWith<$Res>
    implements $RoundStateCopyWith<$Res> {
  factory _$$RoundStateImplCopyWith(
    _$RoundStateImpl value,
    $Res Function(_$RoundStateImpl) then,
  ) = __$$RoundStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String status,
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
class __$$RoundStateImplCopyWithImpl<$Res>
    extends _$RoundStateCopyWithImpl<$Res, _$RoundStateImpl>
    implements _$$RoundStateImplCopyWith<$Res> {
  __$$RoundStateImplCopyWithImpl(
    _$RoundStateImpl _value,
    $Res Function(_$RoundStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
      _$RoundStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$RoundStateImpl implements _RoundState {
  const _$RoundStateImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.date,
    this.preMoneyValuation,
    this.pricePerShare,
    this.amountRaised = 0,
    this.leadInvestorId,
    required this.displayOrder,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$RoundStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoundStateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String status;
  @override
  final DateTime date;
  @override
  final double? preMoneyValuation;
  @override
  final double? pricePerShare;
  @override
  @JsonKey()
  final double amountRaised;
  @override
  final String? leadInvestorId;
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
    return 'RoundState(id: $id, name: $name, type: $type, status: $status, date: $date, preMoneyValuation: $preMoneyValuation, pricePerShare: $pricePerShare, amountRaised: $amountRaised, leadInvestorId: $leadInvestorId, displayOrder: $displayOrder, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoundStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoundStateImplCopyWith<_$RoundStateImpl> get copyWith =>
      __$$RoundStateImplCopyWithImpl<_$RoundStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoundStateImplToJson(this);
  }
}

abstract class _RoundState implements RoundState {
  const factory _RoundState({
    required final String id,
    required final String name,
    required final String type,
    required final String status,
    required final DateTime date,
    final double? preMoneyValuation,
    final double? pricePerShare,
    final double amountRaised,
    final String? leadInvestorId,
    required final int displayOrder,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$RoundStateImpl;

  factory _RoundState.fromJson(Map<String, dynamic> json) =
      _$RoundStateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  String get status;
  @override
  DateTime get date;
  @override
  double? get preMoneyValuation;
  @override
  double? get pricePerShare;
  @override
  double get amountRaised;
  @override
  String? get leadInvestorId;
  @override
  int get displayOrder;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of RoundState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoundStateImplCopyWith<_$RoundStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HoldingState _$HoldingStateFromJson(Map<String, dynamic> json) {
  return _HoldingState.fromJson(json);
}

/// @nodoc
mixin _$HoldingState {
  String get id => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  double get costBasis => throw _privateConstructorUsedError;
  DateTime get acquiredDate => throw _privateConstructorUsedError;
  String? get roundId => throw _privateConstructorUsedError;
  String? get vestingScheduleId => throw _privateConstructorUsedError;
  int? get vestedCount => throw _privateConstructorUsedError;
  String? get sourceOptionGrantId => throw _privateConstructorUsedError;
  String? get sourceWarrantId => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this HoldingState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HoldingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HoldingStateCopyWith<HoldingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HoldingStateCopyWith<$Res> {
  factory $HoldingStateCopyWith(
    HoldingState value,
    $Res Function(HoldingState) then,
  ) = _$HoldingStateCopyWithImpl<$Res, HoldingState>;
  @useResult
  $Res call({
    String id,
    String stakeholderId,
    String shareClassId,
    int shareCount,
    double costBasis,
    DateTime acquiredDate,
    String? roundId,
    String? vestingScheduleId,
    int? vestedCount,
    String? sourceOptionGrantId,
    String? sourceWarrantId,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$HoldingStateCopyWithImpl<$Res, $Val extends HoldingState>
    implements $HoldingStateCopyWith<$Res> {
  _$HoldingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HoldingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? costBasis = null,
    Object? acquiredDate = null,
    Object? roundId = freezed,
    Object? vestingScheduleId = freezed,
    Object? vestedCount = freezed,
    Object? sourceOptionGrantId = freezed,
    Object? sourceWarrantId = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
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
            roundId: freezed == roundId
                ? _value.roundId
                : roundId // ignore: cast_nullable_to_non_nullable
                      as String?,
            vestingScheduleId: freezed == vestingScheduleId
                ? _value.vestingScheduleId
                : vestingScheduleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            vestedCount: freezed == vestedCount
                ? _value.vestedCount
                : vestedCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            sourceOptionGrantId: freezed == sourceOptionGrantId
                ? _value.sourceOptionGrantId
                : sourceOptionGrantId // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceWarrantId: freezed == sourceWarrantId
                ? _value.sourceWarrantId
                : sourceWarrantId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$HoldingStateImplCopyWith<$Res>
    implements $HoldingStateCopyWith<$Res> {
  factory _$$HoldingStateImplCopyWith(
    _$HoldingStateImpl value,
    $Res Function(_$HoldingStateImpl) then,
  ) = __$$HoldingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stakeholderId,
    String shareClassId,
    int shareCount,
    double costBasis,
    DateTime acquiredDate,
    String? roundId,
    String? vestingScheduleId,
    int? vestedCount,
    String? sourceOptionGrantId,
    String? sourceWarrantId,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$HoldingStateImplCopyWithImpl<$Res>
    extends _$HoldingStateCopyWithImpl<$Res, _$HoldingStateImpl>
    implements _$$HoldingStateImplCopyWith<$Res> {
  __$$HoldingStateImplCopyWithImpl(
    _$HoldingStateImpl _value,
    $Res Function(_$HoldingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HoldingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? costBasis = null,
    Object? acquiredDate = null,
    Object? roundId = freezed,
    Object? vestingScheduleId = freezed,
    Object? vestedCount = freezed,
    Object? sourceOptionGrantId = freezed,
    Object? sourceWarrantId = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _$HoldingStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
        roundId: freezed == roundId
            ? _value.roundId
            : roundId // ignore: cast_nullable_to_non_nullable
                  as String?,
        vestingScheduleId: freezed == vestingScheduleId
            ? _value.vestingScheduleId
            : vestingScheduleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        vestedCount: freezed == vestedCount
            ? _value.vestedCount
            : vestedCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        sourceOptionGrantId: freezed == sourceOptionGrantId
            ? _value.sourceOptionGrantId
            : sourceOptionGrantId // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceWarrantId: freezed == sourceWarrantId
            ? _value.sourceWarrantId
            : sourceWarrantId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$HoldingStateImpl implements _HoldingState {
  const _$HoldingStateImpl({
    required this.id,
    required this.stakeholderId,
    required this.shareClassId,
    required this.shareCount,
    required this.costBasis,
    required this.acquiredDate,
    this.roundId,
    this.vestingScheduleId,
    this.vestedCount,
    this.sourceOptionGrantId,
    this.sourceWarrantId,
    required this.updatedAt,
  });

  factory _$HoldingStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$HoldingStateImplFromJson(json);

  @override
  final String id;
  @override
  final String stakeholderId;
  @override
  final String shareClassId;
  @override
  final int shareCount;
  @override
  final double costBasis;
  @override
  final DateTime acquiredDate;
  @override
  final String? roundId;
  @override
  final String? vestingScheduleId;
  @override
  final int? vestedCount;
  @override
  final String? sourceOptionGrantId;
  @override
  final String? sourceWarrantId;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'HoldingState(id: $id, stakeholderId: $stakeholderId, shareClassId: $shareClassId, shareCount: $shareCount, costBasis: $costBasis, acquiredDate: $acquiredDate, roundId: $roundId, vestingScheduleId: $vestingScheduleId, vestedCount: $vestedCount, sourceOptionGrantId: $sourceOptionGrantId, sourceWarrantId: $sourceWarrantId, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HoldingStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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
            (identical(other.roundId, roundId) || other.roundId == roundId) &&
            (identical(other.vestingScheduleId, vestingScheduleId) ||
                other.vestingScheduleId == vestingScheduleId) &&
            (identical(other.vestedCount, vestedCount) ||
                other.vestedCount == vestedCount) &&
            (identical(other.sourceOptionGrantId, sourceOptionGrantId) ||
                other.sourceOptionGrantId == sourceOptionGrantId) &&
            (identical(other.sourceWarrantId, sourceWarrantId) ||
                other.sourceWarrantId == sourceWarrantId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    stakeholderId,
    shareClassId,
    shareCount,
    costBasis,
    acquiredDate,
    roundId,
    vestingScheduleId,
    vestedCount,
    sourceOptionGrantId,
    sourceWarrantId,
    updatedAt,
  );

  /// Create a copy of HoldingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HoldingStateImplCopyWith<_$HoldingStateImpl> get copyWith =>
      __$$HoldingStateImplCopyWithImpl<_$HoldingStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HoldingStateImplToJson(this);
  }
}

abstract class _HoldingState implements HoldingState {
  const factory _HoldingState({
    required final String id,
    required final String stakeholderId,
    required final String shareClassId,
    required final int shareCount,
    required final double costBasis,
    required final DateTime acquiredDate,
    final String? roundId,
    final String? vestingScheduleId,
    final int? vestedCount,
    final String? sourceOptionGrantId,
    final String? sourceWarrantId,
    required final DateTime updatedAt,
  }) = _$HoldingStateImpl;

  factory _HoldingState.fromJson(Map<String, dynamic> json) =
      _$HoldingStateImpl.fromJson;

  @override
  String get id;
  @override
  String get stakeholderId;
  @override
  String get shareClassId;
  @override
  int get shareCount;
  @override
  double get costBasis;
  @override
  DateTime get acquiredDate;
  @override
  String? get roundId;
  @override
  String? get vestingScheduleId;
  @override
  int? get vestedCount;
  @override
  String? get sourceOptionGrantId;
  @override
  String? get sourceWarrantId;
  @override
  DateTime get updatedAt;

  /// Create a copy of HoldingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HoldingStateImplCopyWith<_$HoldingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConvertibleState _$ConvertibleStateFromJson(Map<String, dynamic> json) {
  return _ConvertibleState.fromJson(json);
}

/// @nodoc
mixin _$ConvertibleState {
  String get id => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double get principal => throw _privateConstructorUsedError;
  double? get valuationCap => throw _privateConstructorUsedError;
  double? get discountPercent => throw _privateConstructorUsedError;
  double? get interestRate => throw _privateConstructorUsedError;
  DateTime? get maturityDate => throw _privateConstructorUsedError;
  DateTime get issueDate => throw _privateConstructorUsedError;
  bool get hasMfn => throw _privateConstructorUsedError;
  bool get hasProRata => throw _privateConstructorUsedError;
  String? get roundId => throw _privateConstructorUsedError;
  String? get conversionRoundId => throw _privateConstructorUsedError;
  String? get convertedToShareClassId => throw _privateConstructorUsedError;
  int? get sharesReceived => throw _privateConstructorUsedError;
  String? get notes =>
      throw _privateConstructorUsedError; // Advanced conversion terms
  String? get maturityBehavior => throw _privateConstructorUsedError;
  bool get allowsVoluntaryConversion => throw _privateConstructorUsedError;
  String? get liquidityEventBehavior => throw _privateConstructorUsedError;
  double? get liquidityPayoutMultiple => throw _privateConstructorUsedError;
  String? get dissolutionBehavior => throw _privateConstructorUsedError;
  String? get preferredShareClassId => throw _privateConstructorUsedError;
  double? get qualifiedFinancingThreshold => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ConvertibleState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConvertibleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConvertibleStateCopyWith<ConvertibleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConvertibleStateCopyWith<$Res> {
  factory $ConvertibleStateCopyWith(
    ConvertibleState value,
    $Res Function(ConvertibleState) then,
  ) = _$ConvertibleStateCopyWithImpl<$Res, ConvertibleState>;
  @useResult
  $Res call({
    String id,
    String stakeholderId,
    String type,
    String status,
    double principal,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? maturityDate,
    DateTime issueDate,
    bool hasMfn,
    bool hasProRata,
    String? roundId,
    String? conversionRoundId,
    String? convertedToShareClassId,
    int? sharesReceived,
    String? notes,
    String? maturityBehavior,
    bool allowsVoluntaryConversion,
    String? liquidityEventBehavior,
    double? liquidityPayoutMultiple,
    String? dissolutionBehavior,
    String? preferredShareClassId,
    double? qualifiedFinancingThreshold,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ConvertibleStateCopyWithImpl<$Res, $Val extends ConvertibleState>
    implements $ConvertibleStateCopyWith<$Res> {
  _$ConvertibleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConvertibleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
    Object? roundId = freezed,
    Object? conversionRoundId = freezed,
    Object? convertedToShareClassId = freezed,
    Object? sharesReceived = freezed,
    Object? notes = freezed,
    Object? maturityBehavior = freezed,
    Object? allowsVoluntaryConversion = null,
    Object? liquidityEventBehavior = freezed,
    Object? liquidityPayoutMultiple = freezed,
    Object? dissolutionBehavior = freezed,
    Object? preferredShareClassId = freezed,
    Object? qualifiedFinancingThreshold = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            stakeholderId: null == stakeholderId
                ? _value.stakeholderId
                : stakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
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
            roundId: freezed == roundId
                ? _value.roundId
                : roundId // ignore: cast_nullable_to_non_nullable
                      as String?,
            conversionRoundId: freezed == conversionRoundId
                ? _value.conversionRoundId
                : conversionRoundId // ignore: cast_nullable_to_non_nullable
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
            maturityBehavior: freezed == maturityBehavior
                ? _value.maturityBehavior
                : maturityBehavior // ignore: cast_nullable_to_non_nullable
                      as String?,
            allowsVoluntaryConversion: null == allowsVoluntaryConversion
                ? _value.allowsVoluntaryConversion
                : allowsVoluntaryConversion // ignore: cast_nullable_to_non_nullable
                      as bool,
            liquidityEventBehavior: freezed == liquidityEventBehavior
                ? _value.liquidityEventBehavior
                : liquidityEventBehavior // ignore: cast_nullable_to_non_nullable
                      as String?,
            liquidityPayoutMultiple: freezed == liquidityPayoutMultiple
                ? _value.liquidityPayoutMultiple
                : liquidityPayoutMultiple // ignore: cast_nullable_to_non_nullable
                      as double?,
            dissolutionBehavior: freezed == dissolutionBehavior
                ? _value.dissolutionBehavior
                : dissolutionBehavior // ignore: cast_nullable_to_non_nullable
                      as String?,
            preferredShareClassId: freezed == preferredShareClassId
                ? _value.preferredShareClassId
                : preferredShareClassId // ignore: cast_nullable_to_non_nullable
                      as String?,
            qualifiedFinancingThreshold: freezed == qualifiedFinancingThreshold
                ? _value.qualifiedFinancingThreshold
                : qualifiedFinancingThreshold // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$ConvertibleStateImplCopyWith<$Res>
    implements $ConvertibleStateCopyWith<$Res> {
  factory _$$ConvertibleStateImplCopyWith(
    _$ConvertibleStateImpl value,
    $Res Function(_$ConvertibleStateImpl) then,
  ) = __$$ConvertibleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stakeholderId,
    String type,
    String status,
    double principal,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? maturityDate,
    DateTime issueDate,
    bool hasMfn,
    bool hasProRata,
    String? roundId,
    String? conversionRoundId,
    String? convertedToShareClassId,
    int? sharesReceived,
    String? notes,
    String? maturityBehavior,
    bool allowsVoluntaryConversion,
    String? liquidityEventBehavior,
    double? liquidityPayoutMultiple,
    String? dissolutionBehavior,
    String? preferredShareClassId,
    double? qualifiedFinancingThreshold,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ConvertibleStateImplCopyWithImpl<$Res>
    extends _$ConvertibleStateCopyWithImpl<$Res, _$ConvertibleStateImpl>
    implements _$$ConvertibleStateImplCopyWith<$Res> {
  __$$ConvertibleStateImplCopyWithImpl(
    _$ConvertibleStateImpl _value,
    $Res Function(_$ConvertibleStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConvertibleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
    Object? roundId = freezed,
    Object? conversionRoundId = freezed,
    Object? convertedToShareClassId = freezed,
    Object? sharesReceived = freezed,
    Object? notes = freezed,
    Object? maturityBehavior = freezed,
    Object? allowsVoluntaryConversion = null,
    Object? liquidityEventBehavior = freezed,
    Object? liquidityPayoutMultiple = freezed,
    Object? dissolutionBehavior = freezed,
    Object? preferredShareClassId = freezed,
    Object? qualifiedFinancingThreshold = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ConvertibleStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        stakeholderId: null == stakeholderId
            ? _value.stakeholderId
            : stakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
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
        roundId: freezed == roundId
            ? _value.roundId
            : roundId // ignore: cast_nullable_to_non_nullable
                  as String?,
        conversionRoundId: freezed == conversionRoundId
            ? _value.conversionRoundId
            : conversionRoundId // ignore: cast_nullable_to_non_nullable
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
        maturityBehavior: freezed == maturityBehavior
            ? _value.maturityBehavior
            : maturityBehavior // ignore: cast_nullable_to_non_nullable
                  as String?,
        allowsVoluntaryConversion: null == allowsVoluntaryConversion
            ? _value.allowsVoluntaryConversion
            : allowsVoluntaryConversion // ignore: cast_nullable_to_non_nullable
                  as bool,
        liquidityEventBehavior: freezed == liquidityEventBehavior
            ? _value.liquidityEventBehavior
            : liquidityEventBehavior // ignore: cast_nullable_to_non_nullable
                  as String?,
        liquidityPayoutMultiple: freezed == liquidityPayoutMultiple
            ? _value.liquidityPayoutMultiple
            : liquidityPayoutMultiple // ignore: cast_nullable_to_non_nullable
                  as double?,
        dissolutionBehavior: freezed == dissolutionBehavior
            ? _value.dissolutionBehavior
            : dissolutionBehavior // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferredShareClassId: freezed == preferredShareClassId
            ? _value.preferredShareClassId
            : preferredShareClassId // ignore: cast_nullable_to_non_nullable
                  as String?,
        qualifiedFinancingThreshold: freezed == qualifiedFinancingThreshold
            ? _value.qualifiedFinancingThreshold
            : qualifiedFinancingThreshold // ignore: cast_nullable_to_non_nullable
                  as double?,
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
class _$ConvertibleStateImpl implements _ConvertibleState {
  const _$ConvertibleStateImpl({
    required this.id,
    required this.stakeholderId,
    required this.type,
    required this.status,
    required this.principal,
    this.valuationCap,
    this.discountPercent,
    this.interestRate,
    this.maturityDate,
    required this.issueDate,
    this.hasMfn = false,
    this.hasProRata = false,
    this.roundId,
    this.conversionRoundId,
    this.convertedToShareClassId,
    this.sharesReceived,
    this.notes,
    this.maturityBehavior,
    this.allowsVoluntaryConversion = false,
    this.liquidityEventBehavior,
    this.liquidityPayoutMultiple,
    this.dissolutionBehavior,
    this.preferredShareClassId,
    this.qualifiedFinancingThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ConvertibleStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConvertibleStateImplFromJson(json);

  @override
  final String id;
  @override
  final String stakeholderId;
  @override
  final String type;
  @override
  final String status;
  @override
  final double principal;
  @override
  final double? valuationCap;
  @override
  final double? discountPercent;
  @override
  final double? interestRate;
  @override
  final DateTime? maturityDate;
  @override
  final DateTime issueDate;
  @override
  @JsonKey()
  final bool hasMfn;
  @override
  @JsonKey()
  final bool hasProRata;
  @override
  final String? roundId;
  @override
  final String? conversionRoundId;
  @override
  final String? convertedToShareClassId;
  @override
  final int? sharesReceived;
  @override
  final String? notes;
  // Advanced conversion terms
  @override
  final String? maturityBehavior;
  @override
  @JsonKey()
  final bool allowsVoluntaryConversion;
  @override
  final String? liquidityEventBehavior;
  @override
  final double? liquidityPayoutMultiple;
  @override
  final String? dissolutionBehavior;
  @override
  final String? preferredShareClassId;
  @override
  final double? qualifiedFinancingThreshold;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ConvertibleState(id: $id, stakeholderId: $stakeholderId, type: $type, status: $status, principal: $principal, valuationCap: $valuationCap, discountPercent: $discountPercent, interestRate: $interestRate, maturityDate: $maturityDate, issueDate: $issueDate, hasMfn: $hasMfn, hasProRata: $hasProRata, roundId: $roundId, conversionRoundId: $conversionRoundId, convertedToShareClassId: $convertedToShareClassId, sharesReceived: $sharesReceived, notes: $notes, maturityBehavior: $maturityBehavior, allowsVoluntaryConversion: $allowsVoluntaryConversion, liquidityEventBehavior: $liquidityEventBehavior, liquidityPayoutMultiple: $liquidityPayoutMultiple, dissolutionBehavior: $dissolutionBehavior, preferredShareClassId: $preferredShareClassId, qualifiedFinancingThreshold: $qualifiedFinancingThreshold, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConvertibleStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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
            (identical(other.roundId, roundId) || other.roundId == roundId) &&
            (identical(other.conversionRoundId, conversionRoundId) ||
                other.conversionRoundId == conversionRoundId) &&
            (identical(
                  other.convertedToShareClassId,
                  convertedToShareClassId,
                ) ||
                other.convertedToShareClassId == convertedToShareClassId) &&
            (identical(other.sharesReceived, sharesReceived) ||
                other.sharesReceived == sharesReceived) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.maturityBehavior, maturityBehavior) ||
                other.maturityBehavior == maturityBehavior) &&
            (identical(
                  other.allowsVoluntaryConversion,
                  allowsVoluntaryConversion,
                ) ||
                other.allowsVoluntaryConversion == allowsVoluntaryConversion) &&
            (identical(other.liquidityEventBehavior, liquidityEventBehavior) ||
                other.liquidityEventBehavior == liquidityEventBehavior) &&
            (identical(
                  other.liquidityPayoutMultiple,
                  liquidityPayoutMultiple,
                ) ||
                other.liquidityPayoutMultiple == liquidityPayoutMultiple) &&
            (identical(other.dissolutionBehavior, dissolutionBehavior) ||
                other.dissolutionBehavior == dissolutionBehavior) &&
            (identical(other.preferredShareClassId, preferredShareClassId) ||
                other.preferredShareClassId == preferredShareClassId) &&
            (identical(
                  other.qualifiedFinancingThreshold,
                  qualifiedFinancingThreshold,
                ) ||
                other.qualifiedFinancingThreshold ==
                    qualifiedFinancingThreshold) &&
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
    roundId,
    conversionRoundId,
    convertedToShareClassId,
    sharesReceived,
    notes,
    maturityBehavior,
    allowsVoluntaryConversion,
    liquidityEventBehavior,
    liquidityPayoutMultiple,
    dissolutionBehavior,
    preferredShareClassId,
    qualifiedFinancingThreshold,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of ConvertibleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConvertibleStateImplCopyWith<_$ConvertibleStateImpl> get copyWith =>
      __$$ConvertibleStateImplCopyWithImpl<_$ConvertibleStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConvertibleStateImplToJson(this);
  }
}

abstract class _ConvertibleState implements ConvertibleState {
  const factory _ConvertibleState({
    required final String id,
    required final String stakeholderId,
    required final String type,
    required final String status,
    required final double principal,
    final double? valuationCap,
    final double? discountPercent,
    final double? interestRate,
    final DateTime? maturityDate,
    required final DateTime issueDate,
    final bool hasMfn,
    final bool hasProRata,
    final String? roundId,
    final String? conversionRoundId,
    final String? convertedToShareClassId,
    final int? sharesReceived,
    final String? notes,
    final String? maturityBehavior,
    final bool allowsVoluntaryConversion,
    final String? liquidityEventBehavior,
    final double? liquidityPayoutMultiple,
    final String? dissolutionBehavior,
    final String? preferredShareClassId,
    final double? qualifiedFinancingThreshold,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ConvertibleStateImpl;

  factory _ConvertibleState.fromJson(Map<String, dynamic> json) =
      _$ConvertibleStateImpl.fromJson;

  @override
  String get id;
  @override
  String get stakeholderId;
  @override
  String get type;
  @override
  String get status;
  @override
  double get principal;
  @override
  double? get valuationCap;
  @override
  double? get discountPercent;
  @override
  double? get interestRate;
  @override
  DateTime? get maturityDate;
  @override
  DateTime get issueDate;
  @override
  bool get hasMfn;
  @override
  bool get hasProRata;
  @override
  String? get roundId;
  @override
  String? get conversionRoundId;
  @override
  String? get convertedToShareClassId;
  @override
  int? get sharesReceived;
  @override
  String? get notes; // Advanced conversion terms
  @override
  String? get maturityBehavior;
  @override
  bool get allowsVoluntaryConversion;
  @override
  String? get liquidityEventBehavior;
  @override
  double? get liquidityPayoutMultiple;
  @override
  String? get dissolutionBehavior;
  @override
  String? get preferredShareClassId;
  @override
  double? get qualifiedFinancingThreshold;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of ConvertibleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConvertibleStateImplCopyWith<_$ConvertibleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EsopPoolState _$EsopPoolStateFromJson(Map<String, dynamic> json) {
  return _EsopPoolState.fromJson(json);
}

/// @nodoc
mixin _$EsopPoolState {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get poolSize => throw _privateConstructorUsedError;
  double? get targetPercentage => throw _privateConstructorUsedError;
  DateTime get establishedDate => throw _privateConstructorUsedError;
  String? get resolutionReference => throw _privateConstructorUsedError;
  String? get roundId => throw _privateConstructorUsedError;
  String? get defaultVestingScheduleId => throw _privateConstructorUsedError;
  String get strikePriceMethod => throw _privateConstructorUsedError;
  double? get defaultStrikePrice => throw _privateConstructorUsedError;
  int get defaultExpiryYears => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this EsopPoolState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EsopPoolState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EsopPoolStateCopyWith<EsopPoolState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EsopPoolStateCopyWith<$Res> {
  factory $EsopPoolStateCopyWith(
    EsopPoolState value,
    $Res Function(EsopPoolState) then,
  ) = _$EsopPoolStateCopyWithImpl<$Res, EsopPoolState>;
  @useResult
  $Res call({
    String id,
    String name,
    String status,
    int poolSize,
    double? targetPercentage,
    DateTime establishedDate,
    String? resolutionReference,
    String? roundId,
    String? defaultVestingScheduleId,
    String strikePriceMethod,
    double? defaultStrikePrice,
    int defaultExpiryYears,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$EsopPoolStateCopyWithImpl<$Res, $Val extends EsopPoolState>
    implements $EsopPoolStateCopyWith<$Res> {
  _$EsopPoolStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EsopPoolState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? poolSize = null,
    Object? targetPercentage = freezed,
    Object? establishedDate = null,
    Object? resolutionReference = freezed,
    Object? roundId = freezed,
    Object? defaultVestingScheduleId = freezed,
    Object? strikePriceMethod = null,
    Object? defaultStrikePrice = freezed,
    Object? defaultExpiryYears = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            poolSize: null == poolSize
                ? _value.poolSize
                : poolSize // ignore: cast_nullable_to_non_nullable
                      as int,
            targetPercentage: freezed == targetPercentage
                ? _value.targetPercentage
                : targetPercentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            establishedDate: null == establishedDate
                ? _value.establishedDate
                : establishedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            resolutionReference: freezed == resolutionReference
                ? _value.resolutionReference
                : resolutionReference // ignore: cast_nullable_to_non_nullable
                      as String?,
            roundId: freezed == roundId
                ? _value.roundId
                : roundId // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultVestingScheduleId: freezed == defaultVestingScheduleId
                ? _value.defaultVestingScheduleId
                : defaultVestingScheduleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            strikePriceMethod: null == strikePriceMethod
                ? _value.strikePriceMethod
                : strikePriceMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultStrikePrice: freezed == defaultStrikePrice
                ? _value.defaultStrikePrice
                : defaultStrikePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            defaultExpiryYears: null == defaultExpiryYears
                ? _value.defaultExpiryYears
                : defaultExpiryYears // ignore: cast_nullable_to_non_nullable
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
abstract class _$$EsopPoolStateImplCopyWith<$Res>
    implements $EsopPoolStateCopyWith<$Res> {
  factory _$$EsopPoolStateImplCopyWith(
    _$EsopPoolStateImpl value,
    $Res Function(_$EsopPoolStateImpl) then,
  ) = __$$EsopPoolStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String status,
    int poolSize,
    double? targetPercentage,
    DateTime establishedDate,
    String? resolutionReference,
    String? roundId,
    String? defaultVestingScheduleId,
    String strikePriceMethod,
    double? defaultStrikePrice,
    int defaultExpiryYears,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$EsopPoolStateImplCopyWithImpl<$Res>
    extends _$EsopPoolStateCopyWithImpl<$Res, _$EsopPoolStateImpl>
    implements _$$EsopPoolStateImplCopyWith<$Res> {
  __$$EsopPoolStateImplCopyWithImpl(
    _$EsopPoolStateImpl _value,
    $Res Function(_$EsopPoolStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EsopPoolState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? status = null,
    Object? poolSize = null,
    Object? targetPercentage = freezed,
    Object? establishedDate = null,
    Object? resolutionReference = freezed,
    Object? roundId = freezed,
    Object? defaultVestingScheduleId = freezed,
    Object? strikePriceMethod = null,
    Object? defaultStrikePrice = freezed,
    Object? defaultExpiryYears = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$EsopPoolStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        poolSize: null == poolSize
            ? _value.poolSize
            : poolSize // ignore: cast_nullable_to_non_nullable
                  as int,
        targetPercentage: freezed == targetPercentage
            ? _value.targetPercentage
            : targetPercentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        establishedDate: null == establishedDate
            ? _value.establishedDate
            : establishedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        resolutionReference: freezed == resolutionReference
            ? _value.resolutionReference
            : resolutionReference // ignore: cast_nullable_to_non_nullable
                  as String?,
        roundId: freezed == roundId
            ? _value.roundId
            : roundId // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultVestingScheduleId: freezed == defaultVestingScheduleId
            ? _value.defaultVestingScheduleId
            : defaultVestingScheduleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        strikePriceMethod: null == strikePriceMethod
            ? _value.strikePriceMethod
            : strikePriceMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultStrikePrice: freezed == defaultStrikePrice
            ? _value.defaultStrikePrice
            : defaultStrikePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        defaultExpiryYears: null == defaultExpiryYears
            ? _value.defaultExpiryYears
            : defaultExpiryYears // ignore: cast_nullable_to_non_nullable
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
class _$EsopPoolStateImpl implements _EsopPoolState {
  const _$EsopPoolStateImpl({
    required this.id,
    required this.name,
    required this.status,
    required this.poolSize,
    this.targetPercentage,
    required this.establishedDate,
    this.resolutionReference,
    this.roundId,
    this.defaultVestingScheduleId,
    this.strikePriceMethod = 'fmv',
    this.defaultStrikePrice,
    this.defaultExpiryYears = 10,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$EsopPoolStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$EsopPoolStateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String status;
  @override
  final int poolSize;
  @override
  final double? targetPercentage;
  @override
  final DateTime establishedDate;
  @override
  final String? resolutionReference;
  @override
  final String? roundId;
  @override
  final String? defaultVestingScheduleId;
  @override
  @JsonKey()
  final String strikePriceMethod;
  @override
  final double? defaultStrikePrice;
  @override
  @JsonKey()
  final int defaultExpiryYears;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'EsopPoolState(id: $id, name: $name, status: $status, poolSize: $poolSize, targetPercentage: $targetPercentage, establishedDate: $establishedDate, resolutionReference: $resolutionReference, roundId: $roundId, defaultVestingScheduleId: $defaultVestingScheduleId, strikePriceMethod: $strikePriceMethod, defaultStrikePrice: $defaultStrikePrice, defaultExpiryYears: $defaultExpiryYears, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EsopPoolStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.poolSize, poolSize) ||
                other.poolSize == poolSize) &&
            (identical(other.targetPercentage, targetPercentage) ||
                other.targetPercentage == targetPercentage) &&
            (identical(other.establishedDate, establishedDate) ||
                other.establishedDate == establishedDate) &&
            (identical(other.resolutionReference, resolutionReference) ||
                other.resolutionReference == resolutionReference) &&
            (identical(other.roundId, roundId) || other.roundId == roundId) &&
            (identical(
                  other.defaultVestingScheduleId,
                  defaultVestingScheduleId,
                ) ||
                other.defaultVestingScheduleId == defaultVestingScheduleId) &&
            (identical(other.strikePriceMethod, strikePriceMethod) ||
                other.strikePriceMethod == strikePriceMethod) &&
            (identical(other.defaultStrikePrice, defaultStrikePrice) ||
                other.defaultStrikePrice == defaultStrikePrice) &&
            (identical(other.defaultExpiryYears, defaultExpiryYears) ||
                other.defaultExpiryYears == defaultExpiryYears) &&
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
    name,
    status,
    poolSize,
    targetPercentage,
    establishedDate,
    resolutionReference,
    roundId,
    defaultVestingScheduleId,
    strikePriceMethod,
    defaultStrikePrice,
    defaultExpiryYears,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of EsopPoolState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EsopPoolStateImplCopyWith<_$EsopPoolStateImpl> get copyWith =>
      __$$EsopPoolStateImplCopyWithImpl<_$EsopPoolStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EsopPoolStateImplToJson(this);
  }
}

abstract class _EsopPoolState implements EsopPoolState {
  const factory _EsopPoolState({
    required final String id,
    required final String name,
    required final String status,
    required final int poolSize,
    final double? targetPercentage,
    required final DateTime establishedDate,
    final String? resolutionReference,
    final String? roundId,
    final String? defaultVestingScheduleId,
    final String strikePriceMethod,
    final double? defaultStrikePrice,
    final int defaultExpiryYears,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$EsopPoolStateImpl;

  factory _EsopPoolState.fromJson(Map<String, dynamic> json) =
      _$EsopPoolStateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get status;
  @override
  int get poolSize;
  @override
  double? get targetPercentage;
  @override
  DateTime get establishedDate;
  @override
  String? get resolutionReference;
  @override
  String? get roundId;
  @override
  String? get defaultVestingScheduleId;
  @override
  String get strikePriceMethod;
  @override
  double? get defaultStrikePrice;
  @override
  int get defaultExpiryYears;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of EsopPoolState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EsopPoolStateImplCopyWith<_$EsopPoolStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OptionGrantState _$OptionGrantStateFromJson(Map<String, dynamic> json) {
  return _OptionGrantState.fromJson(json);
}

/// @nodoc
mixin _$OptionGrantState {
  String get id => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  String? get esopPoolId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get strikePrice => throw _privateConstructorUsedError;
  DateTime get grantDate => throw _privateConstructorUsedError;
  DateTime get expiryDate => throw _privateConstructorUsedError;
  int get exercisedCount => throw _privateConstructorUsedError;
  int get cancelledCount => throw _privateConstructorUsedError;
  String? get vestingScheduleId => throw _privateConstructorUsedError;
  String? get roundId => throw _privateConstructorUsedError;
  bool get allowsEarlyExercise => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OptionGrantState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OptionGrantState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OptionGrantStateCopyWith<OptionGrantState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptionGrantStateCopyWith<$Res> {
  factory $OptionGrantStateCopyWith(
    OptionGrantState value,
    $Res Function(OptionGrantState) then,
  ) = _$OptionGrantStateCopyWithImpl<$Res, OptionGrantState>;
  @useResult
  $Res call({
    String id,
    String stakeholderId,
    String shareClassId,
    String? esopPoolId,
    String status,
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
class _$OptionGrantStateCopyWithImpl<$Res, $Val extends OptionGrantState>
    implements $OptionGrantStateCopyWith<$Res> {
  _$OptionGrantStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OptionGrantState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
                      as String,
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
abstract class _$$OptionGrantStateImplCopyWith<$Res>
    implements $OptionGrantStateCopyWith<$Res> {
  factory _$$OptionGrantStateImplCopyWith(
    _$OptionGrantStateImpl value,
    $Res Function(_$OptionGrantStateImpl) then,
  ) = __$$OptionGrantStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stakeholderId,
    String shareClassId,
    String? esopPoolId,
    String status,
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
class __$$OptionGrantStateImplCopyWithImpl<$Res>
    extends _$OptionGrantStateCopyWithImpl<$Res, _$OptionGrantStateImpl>
    implements _$$OptionGrantStateImplCopyWith<$Res> {
  __$$OptionGrantStateImplCopyWithImpl(
    _$OptionGrantStateImpl _value,
    $Res Function(_$OptionGrantStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OptionGrantState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
      _$OptionGrantStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
                  as String,
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
class _$OptionGrantStateImpl implements _OptionGrantState {
  const _$OptionGrantStateImpl({
    required this.id,
    required this.stakeholderId,
    required this.shareClassId,
    this.esopPoolId,
    required this.status,
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
  });

  factory _$OptionGrantStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$OptionGrantStateImplFromJson(json);

  @override
  final String id;
  @override
  final String stakeholderId;
  @override
  final String shareClassId;
  @override
  final String? esopPoolId;
  @override
  final String status;
  @override
  final int quantity;
  @override
  final double strikePrice;
  @override
  final DateTime grantDate;
  @override
  final DateTime expiryDate;
  @override
  @JsonKey()
  final int exercisedCount;
  @override
  @JsonKey()
  final int cancelledCount;
  @override
  final String? vestingScheduleId;
  @override
  final String? roundId;
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
    return 'OptionGrantState(id: $id, stakeholderId: $stakeholderId, shareClassId: $shareClassId, esopPoolId: $esopPoolId, status: $status, quantity: $quantity, strikePrice: $strikePrice, grantDate: $grantDate, expiryDate: $expiryDate, exercisedCount: $exercisedCount, cancelledCount: $cancelledCount, vestingScheduleId: $vestingScheduleId, roundId: $roundId, allowsEarlyExercise: $allowsEarlyExercise, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptionGrantStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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

  /// Create a copy of OptionGrantState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OptionGrantStateImplCopyWith<_$OptionGrantStateImpl> get copyWith =>
      __$$OptionGrantStateImplCopyWithImpl<_$OptionGrantStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OptionGrantStateImplToJson(this);
  }
}

abstract class _OptionGrantState implements OptionGrantState {
  const factory _OptionGrantState({
    required final String id,
    required final String stakeholderId,
    required final String shareClassId,
    final String? esopPoolId,
    required final String status,
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
  }) = _$OptionGrantStateImpl;

  factory _OptionGrantState.fromJson(Map<String, dynamic> json) =
      _$OptionGrantStateImpl.fromJson;

  @override
  String get id;
  @override
  String get stakeholderId;
  @override
  String get shareClassId;
  @override
  String? get esopPoolId;
  @override
  String get status;
  @override
  int get quantity;
  @override
  double get strikePrice;
  @override
  DateTime get grantDate;
  @override
  DateTime get expiryDate;
  @override
  int get exercisedCount;
  @override
  int get cancelledCount;
  @override
  String? get vestingScheduleId;
  @override
  String? get roundId;
  @override
  bool get allowsEarlyExercise;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of OptionGrantState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OptionGrantStateImplCopyWith<_$OptionGrantStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WarrantState _$WarrantStateFromJson(Map<String, dynamic> json) {
  return _WarrantState.fromJson(json);
}

/// @nodoc
mixin _$WarrantState {
  String get id => throw _privateConstructorUsedError;
  String get stakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get strikePrice => throw _privateConstructorUsedError;
  DateTime get issueDate => throw _privateConstructorUsedError;
  DateTime get expiryDate => throw _privateConstructorUsedError;
  int get exercisedCount => throw _privateConstructorUsedError;
  int get cancelledCount => throw _privateConstructorUsedError;
  String? get sourceConvertibleId => throw _privateConstructorUsedError;
  String? get roundId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WarrantState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WarrantState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WarrantStateCopyWith<WarrantState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WarrantStateCopyWith<$Res> {
  factory $WarrantStateCopyWith(
    WarrantState value,
    $Res Function(WarrantState) then,
  ) = _$WarrantStateCopyWithImpl<$Res, WarrantState>;
  @useResult
  $Res call({
    String id,
    String stakeholderId,
    String shareClassId,
    String status,
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
class _$WarrantStateCopyWithImpl<$Res, $Val extends WarrantState>
    implements $WarrantStateCopyWith<$Res> {
  _$WarrantStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WarrantState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
                      as String,
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
abstract class _$$WarrantStateImplCopyWith<$Res>
    implements $WarrantStateCopyWith<$Res> {
  factory _$$WarrantStateImplCopyWith(
    _$WarrantStateImpl value,
    $Res Function(_$WarrantStateImpl) then,
  ) = __$$WarrantStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stakeholderId,
    String shareClassId,
    String status,
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
class __$$WarrantStateImplCopyWithImpl<$Res>
    extends _$WarrantStateCopyWithImpl<$Res, _$WarrantStateImpl>
    implements _$$WarrantStateImplCopyWith<$Res> {
  __$$WarrantStateImplCopyWithImpl(
    _$WarrantStateImpl _value,
    $Res Function(_$WarrantStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WarrantState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
      _$WarrantStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
                  as String,
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
class _$WarrantStateImpl implements _WarrantState {
  const _$WarrantStateImpl({
    required this.id,
    required this.stakeholderId,
    required this.shareClassId,
    required this.status,
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
  });

  factory _$WarrantStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WarrantStateImplFromJson(json);

  @override
  final String id;
  @override
  final String stakeholderId;
  @override
  final String shareClassId;
  @override
  final String status;
  @override
  final int quantity;
  @override
  final double strikePrice;
  @override
  final DateTime issueDate;
  @override
  final DateTime expiryDate;
  @override
  @JsonKey()
  final int exercisedCount;
  @override
  @JsonKey()
  final int cancelledCount;
  @override
  final String? sourceConvertibleId;
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
    return 'WarrantState(id: $id, stakeholderId: $stakeholderId, shareClassId: $shareClassId, status: $status, quantity: $quantity, strikePrice: $strikePrice, issueDate: $issueDate, expiryDate: $expiryDate, exercisedCount: $exercisedCount, cancelledCount: $cancelledCount, sourceConvertibleId: $sourceConvertibleId, roundId: $roundId, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WarrantStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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

  /// Create a copy of WarrantState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WarrantStateImplCopyWith<_$WarrantStateImpl> get copyWith =>
      __$$WarrantStateImplCopyWithImpl<_$WarrantStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WarrantStateImplToJson(this);
  }
}

abstract class _WarrantState implements WarrantState {
  const factory _WarrantState({
    required final String id,
    required final String stakeholderId,
    required final String shareClassId,
    required final String status,
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
  }) = _$WarrantStateImpl;

  factory _WarrantState.fromJson(Map<String, dynamic> json) =
      _$WarrantStateImpl.fromJson;

  @override
  String get id;
  @override
  String get stakeholderId;
  @override
  String get shareClassId;
  @override
  String get status;
  @override
  int get quantity;
  @override
  double get strikePrice;
  @override
  DateTime get issueDate;
  @override
  DateTime get expiryDate;
  @override
  int get exercisedCount;
  @override
  int get cancelledCount;
  @override
  String? get sourceConvertibleId;
  @override
  String? get roundId;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of WarrantState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WarrantStateImplCopyWith<_$WarrantStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VestingScheduleState _$VestingScheduleStateFromJson(Map<String, dynamic> json) {
  return _VestingScheduleState.fromJson(json);
}

/// @nodoc
mixin _$VestingScheduleState {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int? get totalMonths => throw _privateConstructorUsedError;
  int get cliffMonths => throw _privateConstructorUsedError;
  String? get frequency => throw _privateConstructorUsedError;
  String? get milestonesJson => throw _privateConstructorUsedError;
  int? get totalHours => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VestingScheduleState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VestingScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VestingScheduleStateCopyWith<VestingScheduleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VestingScheduleStateCopyWith<$Res> {
  factory $VestingScheduleStateCopyWith(
    VestingScheduleState value,
    $Res Function(VestingScheduleState) then,
  ) = _$VestingScheduleStateCopyWithImpl<$Res, VestingScheduleState>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    int? totalMonths,
    int cliffMonths,
    String? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$VestingScheduleStateCopyWithImpl<
  $Res,
  $Val extends VestingScheduleState
>
    implements $VestingScheduleStateCopyWith<$Res> {
  _$VestingScheduleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VestingScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
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
                      as String?,
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
abstract class _$$VestingScheduleStateImplCopyWith<$Res>
    implements $VestingScheduleStateCopyWith<$Res> {
  factory _$$VestingScheduleStateImplCopyWith(
    _$VestingScheduleStateImpl value,
    $Res Function(_$VestingScheduleStateImpl) then,
  ) = __$$VestingScheduleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    int? totalMonths,
    int cliffMonths,
    String? frequency,
    String? milestonesJson,
    int? totalHours,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$VestingScheduleStateImplCopyWithImpl<$Res>
    extends _$VestingScheduleStateCopyWithImpl<$Res, _$VestingScheduleStateImpl>
    implements _$$VestingScheduleStateImplCopyWith<$Res> {
  __$$VestingScheduleStateImplCopyWithImpl(
    _$VestingScheduleStateImpl _value,
    $Res Function(_$VestingScheduleStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VestingScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
      _$VestingScheduleStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
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
                  as String?,
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
class _$VestingScheduleStateImpl implements _VestingScheduleState {
  const _$VestingScheduleStateImpl({
    required this.id,
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
  });

  factory _$VestingScheduleStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$VestingScheduleStateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final int? totalMonths;
  @override
  @JsonKey()
  final int cliffMonths;
  @override
  final String? frequency;
  @override
  final String? milestonesJson;
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
    return 'VestingScheduleState(id: $id, name: $name, type: $type, totalMonths: $totalMonths, cliffMonths: $cliffMonths, frequency: $frequency, milestonesJson: $milestonesJson, totalHours: $totalHours, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VestingScheduleStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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

  /// Create a copy of VestingScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VestingScheduleStateImplCopyWith<_$VestingScheduleStateImpl>
  get copyWith =>
      __$$VestingScheduleStateImplCopyWithImpl<_$VestingScheduleStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VestingScheduleStateImplToJson(this);
  }
}

abstract class _VestingScheduleState implements VestingScheduleState {
  const factory _VestingScheduleState({
    required final String id,
    required final String name,
    required final String type,
    final int? totalMonths,
    final int cliffMonths,
    final String? frequency,
    final String? milestonesJson,
    final int? totalHours,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$VestingScheduleStateImpl;

  factory _VestingScheduleState.fromJson(Map<String, dynamic> json) =
      _$VestingScheduleStateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  int? get totalMonths;
  @override
  int get cliffMonths;
  @override
  String? get frequency;
  @override
  String? get milestonesJson;
  @override
  int? get totalHours;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of VestingScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VestingScheduleStateImplCopyWith<_$VestingScheduleStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ValuationState _$ValuationStateFromJson(Map<String, dynamic> json) {
  return _ValuationState.fromJson(json);
}

/// @nodoc
mixin _$ValuationState {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get preMoneyValue => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  String? get methodParamsJson => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ValuationState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValuationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValuationStateCopyWith<ValuationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValuationStateCopyWith<$Res> {
  factory $ValuationStateCopyWith(
    ValuationState value,
    $Res Function(ValuationState) then,
  ) = _$ValuationStateCopyWithImpl<$Res, ValuationState>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    double preMoneyValue,
    String method,
    String? methodParamsJson,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ValuationStateCopyWithImpl<$Res, $Val extends ValuationState>
    implements $ValuationStateCopyWith<$Res> {
  _$ValuationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValuationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
                      as String,
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
abstract class _$$ValuationStateImplCopyWith<$Res>
    implements $ValuationStateCopyWith<$Res> {
  factory _$$ValuationStateImplCopyWith(
    _$ValuationStateImpl value,
    $Res Function(_$ValuationStateImpl) then,
  ) = __$$ValuationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    double preMoneyValue,
    String method,
    String? methodParamsJson,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ValuationStateImplCopyWithImpl<$Res>
    extends _$ValuationStateCopyWithImpl<$Res, _$ValuationStateImpl>
    implements _$$ValuationStateImplCopyWith<$Res> {
  __$$ValuationStateImplCopyWithImpl(
    _$ValuationStateImpl _value,
    $Res Function(_$ValuationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ValuationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? preMoneyValue = null,
    Object? method = null,
    Object? methodParamsJson = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ValuationStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
                  as String,
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
class _$ValuationStateImpl implements _ValuationState {
  const _$ValuationStateImpl({
    required this.id,
    required this.date,
    required this.preMoneyValue,
    required this.method,
    this.methodParamsJson,
    this.notes,
    required this.createdAt,
  });

  factory _$ValuationStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValuationStateImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final double preMoneyValue;
  @override
  final String method;
  @override
  final String? methodParamsJson;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ValuationState(id: $id, date: $date, preMoneyValue: $preMoneyValue, method: $method, methodParamsJson: $methodParamsJson, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValuationStateImpl &&
            (identical(other.id, id) || other.id == id) &&
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
    date,
    preMoneyValue,
    method,
    methodParamsJson,
    notes,
    createdAt,
  );

  /// Create a copy of ValuationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValuationStateImplCopyWith<_$ValuationStateImpl> get copyWith =>
      __$$ValuationStateImplCopyWithImpl<_$ValuationStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ValuationStateImplToJson(this);
  }
}

abstract class _ValuationState implements ValuationState {
  const factory _ValuationState({
    required final String id,
    required final DateTime date,
    required final double preMoneyValue,
    required final String method,
    final String? methodParamsJson,
    final String? notes,
    required final DateTime createdAt,
  }) = _$ValuationStateImpl;

  factory _ValuationState.fromJson(Map<String, dynamic> json) =
      _$ValuationStateImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  double get preMoneyValue;
  @override
  String get method;
  @override
  String? get methodParamsJson;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of ValuationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValuationStateImplCopyWith<_$ValuationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TransferState _$TransferStateFromJson(Map<String, dynamic> json) {
  return _TransferState.fromJson(json);
}

/// @nodoc
mixin _$TransferState {
  String get id => throw _privateConstructorUsedError;
  String get sellerStakeholderId => throw _privateConstructorUsedError;
  String get buyerStakeholderId => throw _privateConstructorUsedError;
  String get shareClassId => throw _privateConstructorUsedError;
  int get shareCount => throw _privateConstructorUsedError;
  double get pricePerShare => throw _privateConstructorUsedError;
  double? get fairMarketValue => throw _privateConstructorUsedError;
  DateTime get transactionDate => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get requiresRofr => throw _privateConstructorUsedError;
  bool get rofrWaived => throw _privateConstructorUsedError;
  String? get sourceHoldingId => throw _privateConstructorUsedError;
  String? get resultingHoldingId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TransferState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransferStateCopyWith<TransferState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferStateCopyWith<$Res> {
  factory $TransferStateCopyWith(
    TransferState value,
    $Res Function(TransferState) then,
  ) = _$TransferStateCopyWithImpl<$Res, TransferState>;
  @useResult
  $Res call({
    String id,
    String sellerStakeholderId,
    String buyerStakeholderId,
    String shareClassId,
    int shareCount,
    double pricePerShare,
    double? fairMarketValue,
    DateTime transactionDate,
    String type,
    String status,
    bool requiresRofr,
    bool rofrWaived,
    String? sourceHoldingId,
    String? resultingHoldingId,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TransferStateCopyWithImpl<$Res, $Val extends TransferState>
    implements $TransferStateCopyWith<$Res> {
  _$TransferStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerStakeholderId = null,
    Object? buyerStakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? pricePerShare = null,
    Object? fairMarketValue = freezed,
    Object? transactionDate = null,
    Object? type = null,
    Object? status = null,
    Object? requiresRofr = null,
    Object? rofrWaived = null,
    Object? sourceHoldingId = freezed,
    Object? resultingHoldingId = freezed,
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
            sellerStakeholderId: null == sellerStakeholderId
                ? _value.sellerStakeholderId
                : sellerStakeholderId // ignore: cast_nullable_to_non_nullable
                      as String,
            buyerStakeholderId: null == buyerStakeholderId
                ? _value.buyerStakeholderId
                : buyerStakeholderId // ignore: cast_nullable_to_non_nullable
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
            fairMarketValue: freezed == fairMarketValue
                ? _value.fairMarketValue
                : fairMarketValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            transactionDate: null == transactionDate
                ? _value.transactionDate
                : transactionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            requiresRofr: null == requiresRofr
                ? _value.requiresRofr
                : requiresRofr // ignore: cast_nullable_to_non_nullable
                      as bool,
            rofrWaived: null == rofrWaived
                ? _value.rofrWaived
                : rofrWaived // ignore: cast_nullable_to_non_nullable
                      as bool,
            sourceHoldingId: freezed == sourceHoldingId
                ? _value.sourceHoldingId
                : sourceHoldingId // ignore: cast_nullable_to_non_nullable
                      as String?,
            resultingHoldingId: freezed == resultingHoldingId
                ? _value.resultingHoldingId
                : resultingHoldingId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TransferStateImplCopyWith<$Res>
    implements $TransferStateCopyWith<$Res> {
  factory _$$TransferStateImplCopyWith(
    _$TransferStateImpl value,
    $Res Function(_$TransferStateImpl) then,
  ) = __$$TransferStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sellerStakeholderId,
    String buyerStakeholderId,
    String shareClassId,
    int shareCount,
    double pricePerShare,
    double? fairMarketValue,
    DateTime transactionDate,
    String type,
    String status,
    bool requiresRofr,
    bool rofrWaived,
    String? sourceHoldingId,
    String? resultingHoldingId,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TransferStateImplCopyWithImpl<$Res>
    extends _$TransferStateCopyWithImpl<$Res, _$TransferStateImpl>
    implements _$$TransferStateImplCopyWith<$Res> {
  __$$TransferStateImplCopyWithImpl(
    _$TransferStateImpl _value,
    $Res Function(_$TransferStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransferState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerStakeholderId = null,
    Object? buyerStakeholderId = null,
    Object? shareClassId = null,
    Object? shareCount = null,
    Object? pricePerShare = null,
    Object? fairMarketValue = freezed,
    Object? transactionDate = null,
    Object? type = null,
    Object? status = null,
    Object? requiresRofr = null,
    Object? rofrWaived = null,
    Object? sourceHoldingId = freezed,
    Object? resultingHoldingId = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TransferStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sellerStakeholderId: null == sellerStakeholderId
            ? _value.sellerStakeholderId
            : sellerStakeholderId // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerStakeholderId: null == buyerStakeholderId
            ? _value.buyerStakeholderId
            : buyerStakeholderId // ignore: cast_nullable_to_non_nullable
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
        fairMarketValue: freezed == fairMarketValue
            ? _value.fairMarketValue
            : fairMarketValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        transactionDate: null == transactionDate
            ? _value.transactionDate
            : transactionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        requiresRofr: null == requiresRofr
            ? _value.requiresRofr
            : requiresRofr // ignore: cast_nullable_to_non_nullable
                  as bool,
        rofrWaived: null == rofrWaived
            ? _value.rofrWaived
            : rofrWaived // ignore: cast_nullable_to_non_nullable
                  as bool,
        sourceHoldingId: freezed == sourceHoldingId
            ? _value.sourceHoldingId
            : sourceHoldingId // ignore: cast_nullable_to_non_nullable
                  as String?,
        resultingHoldingId: freezed == resultingHoldingId
            ? _value.resultingHoldingId
            : resultingHoldingId // ignore: cast_nullable_to_non_nullable
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
class _$TransferStateImpl implements _TransferState {
  const _$TransferStateImpl({
    required this.id,
    required this.sellerStakeholderId,
    required this.buyerStakeholderId,
    required this.shareClassId,
    required this.shareCount,
    required this.pricePerShare,
    this.fairMarketValue,
    required this.transactionDate,
    required this.type,
    required this.status,
    this.requiresRofr = false,
    this.rofrWaived = false,
    this.sourceHoldingId,
    this.resultingHoldingId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$TransferStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferStateImplFromJson(json);

  @override
  final String id;
  @override
  final String sellerStakeholderId;
  @override
  final String buyerStakeholderId;
  @override
  final String shareClassId;
  @override
  final int shareCount;
  @override
  final double pricePerShare;
  @override
  final double? fairMarketValue;
  @override
  final DateTime transactionDate;
  @override
  final String type;
  @override
  final String status;
  @override
  @JsonKey()
  final bool requiresRofr;
  @override
  @JsonKey()
  final bool rofrWaived;
  @override
  final String? sourceHoldingId;
  @override
  final String? resultingHoldingId;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TransferState(id: $id, sellerStakeholderId: $sellerStakeholderId, buyerStakeholderId: $buyerStakeholderId, shareClassId: $shareClassId, shareCount: $shareCount, pricePerShare: $pricePerShare, fairMarketValue: $fairMarketValue, transactionDate: $transactionDate, type: $type, status: $status, requiresRofr: $requiresRofr, rofrWaived: $rofrWaived, sourceHoldingId: $sourceHoldingId, resultingHoldingId: $resultingHoldingId, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sellerStakeholderId, sellerStakeholderId) ||
                other.sellerStakeholderId == sellerStakeholderId) &&
            (identical(other.buyerStakeholderId, buyerStakeholderId) ||
                other.buyerStakeholderId == buyerStakeholderId) &&
            (identical(other.shareClassId, shareClassId) ||
                other.shareClassId == shareClassId) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.pricePerShare, pricePerShare) ||
                other.pricePerShare == pricePerShare) &&
            (identical(other.fairMarketValue, fairMarketValue) ||
                other.fairMarketValue == fairMarketValue) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requiresRofr, requiresRofr) ||
                other.requiresRofr == requiresRofr) &&
            (identical(other.rofrWaived, rofrWaived) ||
                other.rofrWaived == rofrWaived) &&
            (identical(other.sourceHoldingId, sourceHoldingId) ||
                other.sourceHoldingId == sourceHoldingId) &&
            (identical(other.resultingHoldingId, resultingHoldingId) ||
                other.resultingHoldingId == resultingHoldingId) &&
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
    sellerStakeholderId,
    buyerStakeholderId,
    shareClassId,
    shareCount,
    pricePerShare,
    fairMarketValue,
    transactionDate,
    type,
    status,
    requiresRofr,
    rofrWaived,
    sourceHoldingId,
    resultingHoldingId,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of TransferState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferStateImplCopyWith<_$TransferStateImpl> get copyWith =>
      __$$TransferStateImplCopyWithImpl<_$TransferStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferStateImplToJson(this);
  }
}

abstract class _TransferState implements TransferState {
  const factory _TransferState({
    required final String id,
    required final String sellerStakeholderId,
    required final String buyerStakeholderId,
    required final String shareClassId,
    required final int shareCount,
    required final double pricePerShare,
    final double? fairMarketValue,
    required final DateTime transactionDate,
    required final String type,
    required final String status,
    final bool requiresRofr,
    final bool rofrWaived,
    final String? sourceHoldingId,
    final String? resultingHoldingId,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$TransferStateImpl;

  factory _TransferState.fromJson(Map<String, dynamic> json) =
      _$TransferStateImpl.fromJson;

  @override
  String get id;
  @override
  String get sellerStakeholderId;
  @override
  String get buyerStakeholderId;
  @override
  String get shareClassId;
  @override
  int get shareCount;
  @override
  double get pricePerShare;
  @override
  double? get fairMarketValue;
  @override
  DateTime get transactionDate;
  @override
  String get type;
  @override
  String get status;
  @override
  bool get requiresRofr;
  @override
  bool get rofrWaived;
  @override
  String? get sourceHoldingId;
  @override
  String? get resultingHoldingId;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of TransferState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransferStateImplCopyWith<_$TransferStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScenarioState _$ScenarioStateFromJson(Map<String, dynamic> json) {
  return _ScenarioState.fromJson(json);
}

/// @nodoc
mixin _$ScenarioState {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get parametersJson => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ScenarioState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScenarioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScenarioStateCopyWith<ScenarioState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScenarioStateCopyWith<$Res> {
  factory $ScenarioStateCopyWith(
    ScenarioState value,
    $Res Function(ScenarioState) then,
  ) = _$ScenarioStateCopyWithImpl<$Res, ScenarioState>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String parametersJson,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ScenarioStateCopyWithImpl<$Res, $Val extends ScenarioState>
    implements $ScenarioStateCopyWith<$Res> {
  _$ScenarioStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScenarioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? parametersJson = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            parametersJson: null == parametersJson
                ? _value.parametersJson
                : parametersJson // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$ScenarioStateImplCopyWith<$Res>
    implements $ScenarioStateCopyWith<$Res> {
  factory _$$ScenarioStateImplCopyWith(
    _$ScenarioStateImpl value,
    $Res Function(_$ScenarioStateImpl) then,
  ) = __$$ScenarioStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String parametersJson,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ScenarioStateImplCopyWithImpl<$Res>
    extends _$ScenarioStateCopyWithImpl<$Res, _$ScenarioStateImpl>
    implements _$$ScenarioStateImplCopyWith<$Res> {
  __$$ScenarioStateImplCopyWithImpl(
    _$ScenarioStateImpl _value,
    $Res Function(_$ScenarioStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScenarioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? parametersJson = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ScenarioStateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        parametersJson: null == parametersJson
            ? _value.parametersJson
            : parametersJson // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$ScenarioStateImpl implements _ScenarioState {
  const _$ScenarioStateImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.parametersJson,
    required this.createdAt,
  });

  factory _$ScenarioStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScenarioStateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String parametersJson;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ScenarioState(id: $id, name: $name, type: $type, parametersJson: $parametersJson, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScenarioStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.parametersJson, parametersJson) ||
                other.parametersJson == parametersJson) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, type, parametersJson, createdAt);

  /// Create a copy of ScenarioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScenarioStateImplCopyWith<_$ScenarioStateImpl> get copyWith =>
      __$$ScenarioStateImplCopyWithImpl<_$ScenarioStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScenarioStateImplToJson(this);
  }
}

abstract class _ScenarioState implements ScenarioState {
  const factory _ScenarioState({
    required final String id,
    required final String name,
    required final String type,
    required final String parametersJson,
    required final DateTime createdAt,
  }) = _$ScenarioStateImpl;

  factory _ScenarioState.fromJson(Map<String, dynamic> json) =
      _$ScenarioStateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  String get parametersJson;
  @override
  DateTime get createdAt;

  /// Create a copy of ScenarioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScenarioStateImplCopyWith<_$ScenarioStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
