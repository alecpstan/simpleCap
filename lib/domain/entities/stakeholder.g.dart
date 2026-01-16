// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stakeholder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StakeholderImpl _$$StakeholderImplFromJson(Map<String, dynamic> json) =>
    _$StakeholderImpl(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$StakeholderTypeEnumMap, json['type']),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      hasProRataRights: json['hasProRataRights'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StakeholderImplToJson(_$StakeholderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'name': instance.name,
      'type': _$StakeholderTypeEnumMap[instance.type]!,
      'email': instance.email,
      'phone': instance.phone,
      'company': instance.company,
      'hasProRataRights': instance.hasProRataRights,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$StakeholderTypeEnumMap = {
  StakeholderType.founder: 'founder',
  StakeholderType.employee: 'employee',
  StakeholderType.advisor: 'advisor',
  StakeholderType.investor: 'investor',
  StakeholderType.angel: 'angel',
  StakeholderType.vcFund: 'vcFund',
  StakeholderType.institution: 'institution',
  StakeholderType.company: 'company',
  StakeholderType.other: 'other',
};
