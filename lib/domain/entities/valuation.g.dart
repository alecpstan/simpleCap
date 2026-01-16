// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ValuationImpl _$$ValuationImplFromJson(Map<String, dynamic> json) =>
    _$ValuationImpl(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      date: DateTime.parse(json['date'] as String),
      preMoneyValue: (json['preMoneyValue'] as num).toDouble(),
      method: $enumDecode(_$ValuationMethodEnumMap, json['method']),
      methodParamsJson: json['methodParamsJson'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ValuationImplToJson(_$ValuationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyId': instance.companyId,
      'date': instance.date.toIso8601String(),
      'preMoneyValue': instance.preMoneyValue,
      'method': _$ValuationMethodEnumMap[instance.method]!,
      'methodParamsJson': instance.methodParamsJson,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ValuationMethodEnumMap = {
  ValuationMethod.manual: 'manual',
  ValuationMethod.revenueMultiple: 'revenueMultiple',
  ValuationMethod.comparables: 'comparables',
  ValuationMethod.dcf: 'dcf',
  ValuationMethod.scorecard: 'scorecard',
  ValuationMethod.berkus: 'berkus',
};
