// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vesting_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VestingScheduleImpl _$$VestingScheduleImplFromJson(
  Map<String, dynamic> json,
) => _$VestingScheduleImpl(
  id: json['id'] as String,
  companyId: json['companyId'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$VestingTypeEnumMap, json['type']),
  totalMonths: (json['totalMonths'] as num?)?.toInt(),
  cliffMonths: (json['cliffMonths'] as num?)?.toInt() ?? 0,
  frequency: $enumDecodeNullable(_$VestingFrequencyEnumMap, json['frequency']),
  milestonesJson: json['milestonesJson'] as String?,
  totalHours: (json['totalHours'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$VestingScheduleImplToJson(
  _$VestingScheduleImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyId': instance.companyId,
  'name': instance.name,
  'type': _$VestingTypeEnumMap[instance.type]!,
  'totalMonths': instance.totalMonths,
  'cliffMonths': instance.cliffMonths,
  'frequency': _$VestingFrequencyEnumMap[instance.frequency],
  'milestonesJson': instance.milestonesJson,
  'totalHours': instance.totalHours,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$VestingTypeEnumMap = {
  VestingType.timeBased: 'timeBased',
  VestingType.milestone: 'milestone',
  VestingType.hours: 'hours',
  VestingType.immediate: 'immediate',
};

const _$VestingFrequencyEnumMap = {
  VestingFrequency.monthly: 'monthly',
  VestingFrequency.quarterly: 'quarterly',
  VestingFrequency.annually: 'annually',
};
