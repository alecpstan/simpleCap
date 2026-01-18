// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esop_pool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EsopPoolImpl _$$EsopPoolImplFromJson(Map<String, dynamic> json) =>
    _$EsopPoolImpl(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      name: json['name'] as String,
      status:
          $enumDecodeNullable(_$EsopPoolStatusEnumMap, json['status']) ??
          EsopPoolStatus.draft,
      poolSize: (json['poolSize'] as num).toInt(),
      targetPercentage: (json['targetPercentage'] as num?)?.toDouble(),
      establishedDate: DateTime.parse(json['establishedDate'] as String),
      resolutionReference: json['resolutionReference'] as String?,
      roundId: json['roundId'] as String?,
      defaultVestingScheduleId: json['defaultVestingScheduleId'] as String?,
      strikePriceMethod: json['strikePriceMethod'] as String? ?? 'fmv',
      defaultStrikePrice: (json['defaultStrikePrice'] as num?)?.toDouble(),
      defaultExpiryYears: (json['defaultExpiryYears'] as num?)?.toInt() ?? 10,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$EsopPoolImplToJson(_$EsopPoolImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'status': _$EsopPoolStatusEnumMap[instance.status]!,
      'poolSize': instance.poolSize,
      'targetPercentage': instance.targetPercentage,
      'establishedDate': instance.establishedDate.toIso8601String(),
      'resolutionReference': instance.resolutionReference,
      'roundId': instance.roundId,
      'defaultVestingScheduleId': instance.defaultVestingScheduleId,
      'strikePriceMethod': instance.strikePriceMethod,
      'defaultStrikePrice': instance.defaultStrikePrice,
      'defaultExpiryYears': instance.defaultExpiryYears,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$EsopPoolStatusEnumMap = {
  EsopPoolStatus.draft: 'draft',
  EsopPoolStatus.active: 'active',
  EsopPoolStatus.fullyAllocated: 'fullyAllocated',
  EsopPoolStatus.closed: 'closed',
};

_$EsopPoolCreationDataImpl _$$EsopPoolCreationDataImplFromJson(
  Map<String, dynamic> json,
) => _$EsopPoolCreationDataImpl(
  poolId: json['poolId'] as String,
  poolSize: (json['poolSize'] as num).toInt(),
  targetPercentage: (json['targetPercentage'] as num?)?.toDouble(),
  resolutionReference: json['resolutionReference'] as String?,
);

Map<String, dynamic> _$$EsopPoolCreationDataImplToJson(
  _$EsopPoolCreationDataImpl instance,
) => <String, dynamic>{
  'poolId': instance.poolId,
  'poolSize': instance.poolSize,
  'targetPercentage': instance.targetPercentage,
  'resolutionReference': instance.resolutionReference,
};

_$EsopPoolExpansionDataImpl _$$EsopPoolExpansionDataImplFromJson(
  Map<String, dynamic> json,
) => _$EsopPoolExpansionDataImpl(
  poolId: json['poolId'] as String,
  previousSize: (json['previousSize'] as num).toInt(),
  newSize: (json['newSize'] as num).toInt(),
  addedShares: (json['addedShares'] as num).toInt(),
  resolutionReference: json['resolutionReference'] as String?,
);

Map<String, dynamic> _$$EsopPoolExpansionDataImplToJson(
  _$EsopPoolExpansionDataImpl instance,
) => <String, dynamic>{
  'poolId': instance.poolId,
  'previousSize': instance.previousSize,
  'newSize': instance.newSize,
  'addedShares': instance.addedShares,
  'resolutionReference': instance.resolutionReference,
};

_$OptionGrantDataImpl _$$OptionGrantDataImplFromJson(
  Map<String, dynamic> json,
) => _$OptionGrantDataImpl(
  grantId: json['grantId'] as String,
  poolId: json['poolId'] as String,
  stakeholderId: json['stakeholderId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  strikePrice: (json['strikePrice'] as num).toDouble(),
  vestingScheduleId: json['vestingScheduleId'] as String?,
);

Map<String, dynamic> _$$OptionGrantDataImplToJson(
  _$OptionGrantDataImpl instance,
) => <String, dynamic>{
  'grantId': instance.grantId,
  'poolId': instance.poolId,
  'stakeholderId': instance.stakeholderId,
  'quantity': instance.quantity,
  'strikePrice': instance.strikePrice,
  'vestingScheduleId': instance.vestingScheduleId,
};
