// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShareClassImpl _$$ShareClassImplFromJson(Map<String, dynamic> json) =>
    _$ShareClassImpl(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ShareClassTypeEnumMap, json['type']),
      votingMultiplier: (json['votingMultiplier'] as num?)?.toDouble() ?? 1.0,
      liquidationPreference:
          (json['liquidationPreference'] as num?)?.toDouble() ?? 1.0,
      isParticipating: json['isParticipating'] as bool? ?? false,
      dividendRate: (json['dividendRate'] as num?)?.toDouble() ?? 0.0,
      seniority: (json['seniority'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ShareClassImplToJson(_$ShareClassImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'type': _$ShareClassTypeEnumMap[instance.type]!,
      'votingMultiplier': instance.votingMultiplier,
      'liquidationPreference': instance.liquidationPreference,
      'isParticipating': instance.isParticipating,
      'dividendRate': instance.dividendRate,
      'seniority': instance.seniority,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ShareClassTypeEnumMap = {
  ShareClassType.ordinary: 'ordinary',
  ShareClassType.preferenceA: 'preferenceA',
  ShareClassType.preferenceB: 'preferenceB',
  ShareClassType.preferenceC: 'preferenceC',
  ShareClassType.esop: 'esop',
  ShareClassType.options: 'options',
  ShareClassType.performanceRights: 'performanceRights',
};
