// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_grant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OptionGrantImpl _$$OptionGrantImplFromJson(Map<String, dynamic> json) =>
    _$OptionGrantImpl(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      esopPoolId: json['esopPoolId'] as String?,
      status:
          $enumDecodeNullable(_$OptionGrantStatusEnumMap, json['status']) ??
          OptionGrantStatus.pending,
      quantity: (json['quantity'] as num).toInt(),
      strikePrice: (json['strikePrice'] as num).toDouble(),
      grantDate: DateTime.parse(json['grantDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      exercisedCount: (json['exercisedCount'] as num?)?.toInt() ?? 0,
      cancelledCount: (json['cancelledCount'] as num?)?.toInt() ?? 0,
      vestingScheduleId: json['vestingScheduleId'] as String?,
      roundId: json['roundId'] as String?,
      allowsEarlyExercise: json['allowsEarlyExercise'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$OptionGrantImplToJson(_$OptionGrantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'esopPoolId': instance.esopPoolId,
      'status': _$OptionGrantStatusEnumMap[instance.status]!,
      'quantity': instance.quantity,
      'strikePrice': instance.strikePrice,
      'grantDate': instance.grantDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'exercisedCount': instance.exercisedCount,
      'cancelledCount': instance.cancelledCount,
      'vestingScheduleId': instance.vestingScheduleId,
      'roundId': instance.roundId,
      'allowsEarlyExercise': instance.allowsEarlyExercise,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$OptionGrantStatusEnumMap = {
  OptionGrantStatus.pending: 'pending',
  OptionGrantStatus.active: 'active',
  OptionGrantStatus.partiallyExercised: 'partiallyExercised',
  OptionGrantStatus.fullyExercised: 'fullyExercised',
  OptionGrantStatus.expired: 'expired',
  OptionGrantStatus.cancelled: 'cancelled',
  OptionGrantStatus.forfeited: 'forfeited',
};
