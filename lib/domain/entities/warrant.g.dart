// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warrant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WarrantImpl _$$WarrantImplFromJson(Map<String, dynamic> json) =>
    _$WarrantImpl(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      status:
          $enumDecodeNullable(_$WarrantStatusEnumMap, json['status']) ??
          WarrantStatus.pending,
      quantity: (json['quantity'] as num).toInt(),
      strikePrice: (json['strikePrice'] as num).toDouble(),
      issueDate: DateTime.parse(json['issueDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      exercisedCount: (json['exercisedCount'] as num?)?.toInt() ?? 0,
      cancelledCount: (json['cancelledCount'] as num?)?.toInt() ?? 0,
      sourceConvertibleId: json['sourceConvertibleId'] as String?,
      roundId: json['roundId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WarrantImplToJson(_$WarrantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'status': _$WarrantStatusEnumMap[instance.status]!,
      'quantity': instance.quantity,
      'strikePrice': instance.strikePrice,
      'issueDate': instance.issueDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'exercisedCount': instance.exercisedCount,
      'cancelledCount': instance.cancelledCount,
      'sourceConvertibleId': instance.sourceConvertibleId,
      'roundId': instance.roundId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$WarrantStatusEnumMap = {
  WarrantStatus.pending: 'pending',
  WarrantStatus.active: 'active',
  WarrantStatus.partiallyExercised: 'partiallyExercised',
  WarrantStatus.fullyExercised: 'fullyExercised',
  WarrantStatus.expired: 'expired',
  WarrantStatus.cancelled: 'cancelled',
};
