// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoundImpl _$$RoundImplFromJson(Map<String, dynamic> json) => _$RoundImpl(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$RoundTypeEnumMap, json['type']),
  status:
      $enumDecodeNullable(_$RoundStatusEnumMap, json['status']) ??
      RoundStatus.draft,
  date: DateTime.parse(json['date'] as String),
  preMoneyValuation: (json['preMoneyValuation'] as num?)?.toDouble(),
  pricePerShare: (json['pricePerShare'] as num?)?.toDouble(),
  amountRaised: (json['amountRaised'] as num?)?.toDouble() ?? 0,
  leadInvestorId: json['leadInvestorId'] as String?,
  displayOrder: (json['displayOrder'] as num).toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$RoundImplToJson(_$RoundImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'type': _$RoundTypeEnumMap[instance.type]!,
      'status': _$RoundStatusEnumMap[instance.status]!,
      'date': instance.date.toIso8601String(),
      'preMoneyValuation': instance.preMoneyValuation,
      'pricePerShare': instance.pricePerShare,
      'amountRaised': instance.amountRaised,
      'leadInvestorId': instance.leadInvestorId,
      'displayOrder': instance.displayOrder,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RoundTypeEnumMap = {
  RoundType.incorporation: 'incorporation',
  RoundType.seed: 'seed',
  RoundType.seriesA: 'seriesA',
  RoundType.seriesB: 'seriesB',
  RoundType.seriesC: 'seriesC',
  RoundType.seriesD: 'seriesD',
  RoundType.bridge: 'bridge',
  RoundType.convertibleRound: 'convertibleRound',
  RoundType.esopPool: 'esopPool',
  RoundType.secondary: 'secondary',
  RoundType.custom: 'custom',
};

const _$RoundStatusEnumMap = {
  RoundStatus.draft: 'draft',
  RoundStatus.closed: 'closed',
};
