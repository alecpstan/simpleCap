// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capitalization_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CapitalizationEventImpl _$$CapitalizationEventImplFromJson(
  Map<String, dynamic> json,
) => _$CapitalizationEventImpl(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  eventType: $enumDecode(_$CapEventTypeEnumMap, json['eventType']),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  eventDataJson: json['eventDataJson'] as String,
  roundId: json['roundId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CapitalizationEventImplToJson(
  _$CapitalizationEventImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'eventType': _$CapEventTypeEnumMap[instance.eventType]!,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'eventDataJson': instance.eventDataJson,
  'roundId': instance.roundId,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$CapEventTypeEnumMap = {
  CapEventType.shareIssuance: 'shareIssuance',
  CapEventType.shareTransfer: 'shareTransfer',
  CapEventType.shareCancellation: 'shareCancellation',
  CapEventType.convertibleIssuance: 'convertibleIssuance',
  CapEventType.convertibleConversion: 'convertibleConversion',
  CapEventType.convertibleCancellation: 'convertibleCancellation',
  CapEventType.optionGrant: 'optionGrant',
  CapEventType.optionExercise: 'optionExercise',
  CapEventType.optionCancellation: 'optionCancellation',
  CapEventType.optionForfeiture: 'optionForfeiture',
  CapEventType.warrantIssuance: 'warrantIssuance',
  CapEventType.warrantExercise: 'warrantExercise',
  CapEventType.warrantCancellation: 'warrantCancellation',
  CapEventType.esopPoolCreation: 'esopPoolCreation',
  CapEventType.esopPoolExpansion: 'esopPoolExpansion',
  CapEventType.roundOpened: 'roundOpened',
  CapEventType.roundClosed: 'roundClosed',
};

_$ShareIssuanceDataImpl _$$ShareIssuanceDataImplFromJson(
  Map<String, dynamic> json,
) => _$ShareIssuanceDataImpl(
  stakeholderId: json['stakeholderId'] as String,
  shareClassId: json['shareClassId'] as String,
  shareCount: (json['shareCount'] as num).toInt(),
  pricePerShare: (json['pricePerShare'] as num).toDouble(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  vestingScheduleId: json['vestingScheduleId'] as String?,
);

Map<String, dynamic> _$$ShareIssuanceDataImplToJson(
  _$ShareIssuanceDataImpl instance,
) => <String, dynamic>{
  'stakeholderId': instance.stakeholderId,
  'shareClassId': instance.shareClassId,
  'shareCount': instance.shareCount,
  'pricePerShare': instance.pricePerShare,
  'totalAmount': instance.totalAmount,
  'vestingScheduleId': instance.vestingScheduleId,
};

_$ShareTransferDataImpl _$$ShareTransferDataImplFromJson(
  Map<String, dynamic> json,
) => _$ShareTransferDataImpl(
  fromStakeholderId: json['fromStakeholderId'] as String,
  toStakeholderId: json['toStakeholderId'] as String,
  shareClassId: json['shareClassId'] as String,
  shareCount: (json['shareCount'] as num).toInt(),
  pricePerShare: (json['pricePerShare'] as num).toDouble(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
);

Map<String, dynamic> _$$ShareTransferDataImplToJson(
  _$ShareTransferDataImpl instance,
) => <String, dynamic>{
  'fromStakeholderId': instance.fromStakeholderId,
  'toStakeholderId': instance.toStakeholderId,
  'shareClassId': instance.shareClassId,
  'shareCount': instance.shareCount,
  'pricePerShare': instance.pricePerShare,
  'totalAmount': instance.totalAmount,
};

_$ShareCancellationDataImpl _$$ShareCancellationDataImplFromJson(
  Map<String, dynamic> json,
) => _$ShareCancellationDataImpl(
  stakeholderId: json['stakeholderId'] as String,
  shareClassId: json['shareClassId'] as String,
  shareCount: (json['shareCount'] as num).toInt(),
  repurchasePrice: (json['repurchasePrice'] as num?)?.toDouble(),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$$ShareCancellationDataImplToJson(
  _$ShareCancellationDataImpl instance,
) => <String, dynamic>{
  'stakeholderId': instance.stakeholderId,
  'shareClassId': instance.shareClassId,
  'shareCount': instance.shareCount,
  'repurchasePrice': instance.repurchasePrice,
  'reason': instance.reason,
};

_$ExerciseDataImpl _$$ExerciseDataImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseDataImpl(
      instrumentId: json['instrumentId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      strikePrice: (json['strikePrice'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
    );

Map<String, dynamic> _$$ExerciseDataImplToJson(_$ExerciseDataImpl instance) =>
    <String, dynamic>{
      'instrumentId': instance.instrumentId,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'quantity': instance.quantity,
      'strikePrice': instance.strikePrice,
      'totalCost': instance.totalCost,
    };

_$ConversionDataImpl _$$ConversionDataImplFromJson(Map<String, dynamic> json) =>
    _$ConversionDataImpl(
      convertibleId: json['convertibleId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      sharesIssued: (json['sharesIssued'] as num).toInt(),
      effectivePrice: (json['effectivePrice'] as num).toDouble(),
      principalConverted: (json['principalConverted'] as num).toDouble(),
      interestConverted: (json['interestConverted'] as num).toDouble(),
    );

Map<String, dynamic> _$$ConversionDataImplToJson(
  _$ConversionDataImpl instance,
) => <String, dynamic>{
  'convertibleId': instance.convertibleId,
  'stakeholderId': instance.stakeholderId,
  'shareClassId': instance.shareClassId,
  'sharesIssued': instance.sharesIssued,
  'effectivePrice': instance.effectivePrice,
  'principalConverted': instance.principalConverted,
  'interestConverted': instance.interestConverted,
};
