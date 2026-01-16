// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'convertible.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConvertibleImpl _$$ConvertibleImplFromJson(Map<String, dynamic> json) =>
    _$ConvertibleImpl(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      type: $enumDecode(_$ConvertibleTypeEnumMap, json['type']),
      status:
          $enumDecodeNullable(_$ConvertibleStatusEnumMap, json['status']) ??
          ConvertibleStatus.outstanding,
      principal: (json['principal'] as num).toDouble(),
      valuationCap: (json['valuationCap'] as num?)?.toDouble(),
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      maturityDate: json['maturityDate'] == null
          ? null
          : DateTime.parse(json['maturityDate'] as String),
      issueDate: DateTime.parse(json['issueDate'] as String),
      hasMfn: json['hasMfn'] as bool? ?? false,
      hasProRata: json['hasProRata'] as bool? ?? false,
      conversionEventId: json['conversionEventId'] as String?,
      convertedToShareClassId: json['convertedToShareClassId'] as String?,
      sharesReceived: (json['sharesReceived'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ConvertibleImplToJson(_$ConvertibleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'stakeholderId': instance.stakeholderId,
      'type': _$ConvertibleTypeEnumMap[instance.type]!,
      'status': _$ConvertibleStatusEnumMap[instance.status]!,
      'principal': instance.principal,
      'valuationCap': instance.valuationCap,
      'discountPercent': instance.discountPercent,
      'interestRate': instance.interestRate,
      'maturityDate': instance.maturityDate?.toIso8601String(),
      'issueDate': instance.issueDate.toIso8601String(),
      'hasMfn': instance.hasMfn,
      'hasProRata': instance.hasProRata,
      'conversionEventId': instance.conversionEventId,
      'convertedToShareClassId': instance.convertedToShareClassId,
      'sharesReceived': instance.sharesReceived,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ConvertibleTypeEnumMap = {
  ConvertibleType.safe: 'safe',
  ConvertibleType.convertibleNote: 'convertibleNote',
};

const _$ConvertibleStatusEnumMap = {
  ConvertibleStatus.outstanding: 'outstanding',
  ConvertibleStatus.converted: 'converted',
  ConvertibleStatus.cancelled: 'cancelled',
};
