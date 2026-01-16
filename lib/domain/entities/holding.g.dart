// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HoldingImpl _$$HoldingImplFromJson(Map<String, dynamic> json) =>
    _$HoldingImpl(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      shareCount: (json['shareCount'] as num).toInt(),
      costBasis: (json['costBasis'] as num).toDouble(),
      acquiredDate: DateTime.parse(json['acquiredDate'] as String),
      vestingScheduleId: json['vestingScheduleId'] as String?,
      vestedCount: (json['vestedCount'] as num?)?.toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$HoldingImplToJson(_$HoldingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'shareCount': instance.shareCount,
      'costBasis': instance.costBasis,
      'acquiredDate': instance.acquiredDate.toIso8601String(),
      'vestingScheduleId': instance.vestingScheduleId,
      'vestedCount': instance.vestedCount,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
