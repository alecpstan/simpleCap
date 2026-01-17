// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cap_table_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompanyCreatedImpl _$$CompanyCreatedImplFromJson(Map<String, dynamic> json) =>
    _$CompanyCreatedImpl(
      companyId: json['companyId'] as String,
      name: json['name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$CompanyCreatedImplToJson(
  _$CompanyCreatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'name': instance.name,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$CompanyRenamedImpl _$$CompanyRenamedImplFromJson(Map<String, dynamic> json) =>
    _$CompanyRenamedImpl(
      companyId: json['companyId'] as String,
      previousName: json['previousName'] as String,
      newName: json['newName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$CompanyRenamedImplToJson(
  _$CompanyRenamedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'previousName': instance.previousName,
  'newName': instance.newName,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$StakeholderAddedImpl _$$StakeholderAddedImplFromJson(
  Map<String, dynamic> json,
) => _$StakeholderAddedImpl(
  companyId: json['companyId'] as String,
  stakeholderId: json['stakeholderId'] as String,
  name: json['name'] as String,
  stakeholderType: json['stakeholderType'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  company: json['company'] as String?,
  hasProRataRights: json['hasProRataRights'] as bool? ?? false,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$StakeholderAddedImplToJson(
  _$StakeholderAddedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'stakeholderId': instance.stakeholderId,
  'name': instance.name,
  'stakeholderType': instance.stakeholderType,
  'email': instance.email,
  'phone': instance.phone,
  'company': instance.company,
  'hasProRataRights': instance.hasProRataRights,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$StakeholderUpdatedImpl _$$StakeholderUpdatedImplFromJson(
  Map<String, dynamic> json,
) => _$StakeholderUpdatedImpl(
  companyId: json['companyId'] as String,
  stakeholderId: json['stakeholderId'] as String,
  name: json['name'] as String?,
  stakeholderType: json['stakeholderType'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  company: json['company'] as String?,
  hasProRataRights: json['hasProRataRights'] as bool?,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$StakeholderUpdatedImplToJson(
  _$StakeholderUpdatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'stakeholderId': instance.stakeholderId,
  'name': instance.name,
  'stakeholderType': instance.stakeholderType,
  'email': instance.email,
  'phone': instance.phone,
  'company': instance.company,
  'hasProRataRights': instance.hasProRataRights,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$StakeholderRemovedImpl _$$StakeholderRemovedImplFromJson(
  Map<String, dynamic> json,
) => _$StakeholderRemovedImpl(
  companyId: json['companyId'] as String,
  stakeholderId: json['stakeholderId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$StakeholderRemovedImplToJson(
  _$StakeholderRemovedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'stakeholderId': instance.stakeholderId,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$ShareClassCreatedImpl _$$ShareClassCreatedImplFromJson(
  Map<String, dynamic> json,
) => _$ShareClassCreatedImpl(
  companyId: json['companyId'] as String,
  shareClassId: json['shareClassId'] as String,
  name: json['name'] as String,
  shareClassType: json['shareClassType'] as String,
  votingMultiplier: (json['votingMultiplier'] as num?)?.toDouble() ?? 1.0,
  liquidationPreference:
      (json['liquidationPreference'] as num?)?.toDouble() ?? 1.0,
  isParticipating: json['isParticipating'] as bool? ?? false,
  dividendRate: (json['dividendRate'] as num?)?.toDouble() ?? 0.0,
  seniority: (json['seniority'] as num?)?.toInt() ?? 0,
  antiDilutionType: json['antiDilutionType'] as String? ?? 'none',
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$ShareClassCreatedImplToJson(
  _$ShareClassCreatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'shareClassId': instance.shareClassId,
  'name': instance.name,
  'shareClassType': instance.shareClassType,
  'votingMultiplier': instance.votingMultiplier,
  'liquidationPreference': instance.liquidationPreference,
  'isParticipating': instance.isParticipating,
  'dividendRate': instance.dividendRate,
  'seniority': instance.seniority,
  'antiDilutionType': instance.antiDilutionType,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$ShareClassUpdatedImpl _$$ShareClassUpdatedImplFromJson(
  Map<String, dynamic> json,
) => _$ShareClassUpdatedImpl(
  companyId: json['companyId'] as String,
  shareClassId: json['shareClassId'] as String,
  name: json['name'] as String?,
  shareClassType: json['shareClassType'] as String?,
  votingMultiplier: (json['votingMultiplier'] as num?)?.toDouble(),
  liquidationPreference: (json['liquidationPreference'] as num?)?.toDouble(),
  isParticipating: json['isParticipating'] as bool?,
  dividendRate: (json['dividendRate'] as num?)?.toDouble(),
  seniority: (json['seniority'] as num?)?.toInt(),
  antiDilutionType: json['antiDilutionType'] as String?,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$ShareClassUpdatedImplToJson(
  _$ShareClassUpdatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'shareClassId': instance.shareClassId,
  'name': instance.name,
  'shareClassType': instance.shareClassType,
  'votingMultiplier': instance.votingMultiplier,
  'liquidationPreference': instance.liquidationPreference,
  'isParticipating': instance.isParticipating,
  'dividendRate': instance.dividendRate,
  'seniority': instance.seniority,
  'antiDilutionType': instance.antiDilutionType,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$RoundOpenedImpl _$$RoundOpenedImplFromJson(Map<String, dynamic> json) =>
    _$RoundOpenedImpl(
      companyId: json['companyId'] as String,
      roundId: json['roundId'] as String,
      name: json['name'] as String,
      roundType: json['roundType'] as String,
      date: DateTime.parse(json['date'] as String),
      preMoneyValuation: (json['preMoneyValuation'] as num?)?.toDouble(),
      pricePerShare: (json['pricePerShare'] as num?)?.toDouble(),
      leadInvestorId: json['leadInvestorId'] as String?,
      displayOrder: (json['displayOrder'] as num).toInt(),
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$RoundOpenedImplToJson(_$RoundOpenedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'roundId': instance.roundId,
      'name': instance.name,
      'roundType': instance.roundType,
      'date': instance.date.toIso8601String(),
      'preMoneyValuation': instance.preMoneyValuation,
      'pricePerShare': instance.pricePerShare,
      'leadInvestorId': instance.leadInvestorId,
      'displayOrder': instance.displayOrder,
      'notes': instance.notes,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$RoundClosedImpl _$$RoundClosedImplFromJson(Map<String, dynamic> json) =>
    _$RoundClosedImpl(
      companyId: json['companyId'] as String,
      roundId: json['roundId'] as String,
      amountRaised: (json['amountRaised'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$RoundClosedImplToJson(_$RoundClosedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'roundId': instance.roundId,
      'amountRaised': instance.amountRaised,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$RoundAmendedImpl _$$RoundAmendedImplFromJson(Map<String, dynamic> json) =>
    _$RoundAmendedImpl(
      companyId: json['companyId'] as String,
      roundId: json['roundId'] as String,
      name: json['name'] as String?,
      roundType: json['roundType'] as String?,
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      preMoneyValuation: (json['preMoneyValuation'] as num?)?.toDouble(),
      pricePerShare: (json['pricePerShare'] as num?)?.toDouble(),
      leadInvestorId: json['leadInvestorId'] as String?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$RoundAmendedImplToJson(_$RoundAmendedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'roundId': instance.roundId,
      'name': instance.name,
      'roundType': instance.roundType,
      'date': instance.date?.toIso8601String(),
      'preMoneyValuation': instance.preMoneyValuation,
      'pricePerShare': instance.pricePerShare,
      'leadInvestorId': instance.leadInvestorId,
      'notes': instance.notes,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$RoundReopenedImpl _$$RoundReopenedImplFromJson(Map<String, dynamic> json) =>
    _$RoundReopenedImpl(
      companyId: json['companyId'] as String,
      roundId: json['roundId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$RoundReopenedImplToJson(_$RoundReopenedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'roundId': instance.roundId,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$RoundDeletedImpl _$$RoundDeletedImplFromJson(Map<String, dynamic> json) =>
    _$RoundDeletedImpl(
      companyId: json['companyId'] as String,
      roundId: json['roundId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$RoundDeletedImplToJson(_$RoundDeletedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'roundId': instance.roundId,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$SharesIssuedImpl _$$SharesIssuedImplFromJson(Map<String, dynamic> json) =>
    _$SharesIssuedImpl(
      companyId: json['companyId'] as String,
      holdingId: json['holdingId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      shareCount: (json['shareCount'] as num).toInt(),
      costBasis: (json['costBasis'] as num).toDouble(),
      acquiredDate: DateTime.parse(json['acquiredDate'] as String),
      roundId: json['roundId'] as String?,
      vestingScheduleId: json['vestingScheduleId'] as String?,
      sourceOptionGrantId: json['sourceOptionGrantId'] as String?,
      sourceWarrantId: json['sourceWarrantId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$SharesIssuedImplToJson(_$SharesIssuedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'holdingId': instance.holdingId,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'shareCount': instance.shareCount,
      'costBasis': instance.costBasis,
      'acquiredDate': instance.acquiredDate.toIso8601String(),
      'roundId': instance.roundId,
      'vestingScheduleId': instance.vestingScheduleId,
      'sourceOptionGrantId': instance.sourceOptionGrantId,
      'sourceWarrantId': instance.sourceWarrantId,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$SharesTransferredImpl _$$SharesTransferredImplFromJson(
  Map<String, dynamic> json,
) => _$SharesTransferredImpl(
  companyId: json['companyId'] as String,
  transferId: json['transferId'] as String,
  sellerStakeholderId: json['sellerStakeholderId'] as String,
  buyerStakeholderId: json['buyerStakeholderId'] as String,
  shareClassId: json['shareClassId'] as String,
  shareCount: (json['shareCount'] as num).toInt(),
  pricePerShare: (json['pricePerShare'] as num).toDouble(),
  fairMarketValue: (json['fairMarketValue'] as num?)?.toDouble(),
  transactionDate: DateTime.parse(json['transactionDate'] as String),
  transferType: json['transferType'] as String,
  sourceHoldingId: json['sourceHoldingId'] as String?,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$SharesTransferredImplToJson(
  _$SharesTransferredImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'transferId': instance.transferId,
  'sellerStakeholderId': instance.sellerStakeholderId,
  'buyerStakeholderId': instance.buyerStakeholderId,
  'shareClassId': instance.shareClassId,
  'shareCount': instance.shareCount,
  'pricePerShare': instance.pricePerShare,
  'fairMarketValue': instance.fairMarketValue,
  'transactionDate': instance.transactionDate.toIso8601String(),
  'transferType': instance.transferType,
  'sourceHoldingId': instance.sourceHoldingId,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$SharesRepurchasedImpl _$$SharesRepurchasedImplFromJson(
  Map<String, dynamic> json,
) => _$SharesRepurchasedImpl(
  companyId: json['companyId'] as String,
  stakeholderId: json['stakeholderId'] as String,
  shareClassId: json['shareClassId'] as String,
  shareCount: (json['shareCount'] as num).toInt(),
  pricePerShare: (json['pricePerShare'] as num).toDouble(),
  repurchaseDate: DateTime.parse(json['repurchaseDate'] as String),
  holdingId: json['holdingId'] as String?,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$SharesRepurchasedImplToJson(
  _$SharesRepurchasedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'stakeholderId': instance.stakeholderId,
  'shareClassId': instance.shareClassId,
  'shareCount': instance.shareCount,
  'pricePerShare': instance.pricePerShare,
  'repurchaseDate': instance.repurchaseDate.toIso8601String(),
  'holdingId': instance.holdingId,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$HoldingVestingUpdatedImpl _$$HoldingVestingUpdatedImplFromJson(
  Map<String, dynamic> json,
) => _$HoldingVestingUpdatedImpl(
  companyId: json['companyId'] as String,
  holdingId: json['holdingId'] as String,
  vestedCount: (json['vestedCount'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$HoldingVestingUpdatedImplToJson(
  _$HoldingVestingUpdatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'holdingId': instance.holdingId,
  'vestedCount': instance.vestedCount,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$ConvertibleIssuedImpl _$$ConvertibleIssuedImplFromJson(
  Map<String, dynamic> json,
) => _$ConvertibleIssuedImpl(
  companyId: json['companyId'] as String,
  convertibleId: json['convertibleId'] as String,
  stakeholderId: json['stakeholderId'] as String,
  convertibleType: json['convertibleType'] as String,
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
  roundId: json['roundId'] as String?,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$ConvertibleIssuedImplToJson(
  _$ConvertibleIssuedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'convertibleId': instance.convertibleId,
  'stakeholderId': instance.stakeholderId,
  'convertibleType': instance.convertibleType,
  'principal': instance.principal,
  'valuationCap': instance.valuationCap,
  'discountPercent': instance.discountPercent,
  'interestRate': instance.interestRate,
  'maturityDate': instance.maturityDate?.toIso8601String(),
  'issueDate': instance.issueDate.toIso8601String(),
  'hasMfn': instance.hasMfn,
  'hasProRata': instance.hasProRata,
  'roundId': instance.roundId,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$MfnUpgradeAppliedImpl _$$MfnUpgradeAppliedImplFromJson(
  Map<String, dynamic> json,
) => _$MfnUpgradeAppliedImpl(
  companyId: json['companyId'] as String,
  upgradeId: json['upgradeId'] as String,
  targetConvertibleId: json['targetConvertibleId'] as String,
  sourceConvertibleId: json['sourceConvertibleId'] as String,
  previousDiscountPercent: (json['previousDiscountPercent'] as num?)
      ?.toDouble(),
  previousValuationCap: (json['previousValuationCap'] as num?)?.toDouble(),
  previousHasProRata: json['previousHasProRata'] as bool? ?? false,
  newDiscountPercent: (json['newDiscountPercent'] as num?)?.toDouble(),
  newValuationCap: (json['newValuationCap'] as num?)?.toDouble(),
  newHasProRata: json['newHasProRata'] as bool? ?? false,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$MfnUpgradeAppliedImplToJson(
  _$MfnUpgradeAppliedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'upgradeId': instance.upgradeId,
  'targetConvertibleId': instance.targetConvertibleId,
  'sourceConvertibleId': instance.sourceConvertibleId,
  'previousDiscountPercent': instance.previousDiscountPercent,
  'previousValuationCap': instance.previousValuationCap,
  'previousHasProRata': instance.previousHasProRata,
  'newDiscountPercent': instance.newDiscountPercent,
  'newValuationCap': instance.newValuationCap,
  'newHasProRata': instance.newHasProRata,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$ConvertibleConvertedImpl _$$ConvertibleConvertedImplFromJson(
  Map<String, dynamic> json,
) => _$ConvertibleConvertedImpl(
  companyId: json['companyId'] as String,
  convertibleId: json['convertibleId'] as String,
  roundId: json['roundId'] as String,
  toShareClassId: json['toShareClassId'] as String,
  sharesReceived: (json['sharesReceived'] as num).toInt(),
  conversionPrice: (json['conversionPrice'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$ConvertibleConvertedImplToJson(
  _$ConvertibleConvertedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'convertibleId': instance.convertibleId,
  'roundId': instance.roundId,
  'toShareClassId': instance.toShareClassId,
  'sharesReceived': instance.sharesReceived,
  'conversionPrice': instance.conversionPrice,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$ConvertibleCancelledImpl _$$ConvertibleCancelledImplFromJson(
  Map<String, dynamic> json,
) => _$ConvertibleCancelledImpl(
  companyId: json['companyId'] as String,
  convertibleId: json['convertibleId'] as String,
  reason: json['reason'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$ConvertibleCancelledImplToJson(
  _$ConvertibleCancelledImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'convertibleId': instance.convertibleId,
  'reason': instance.reason,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$EsopPoolCreatedImpl _$$EsopPoolCreatedImplFromJson(
  Map<String, dynamic> json,
) => _$EsopPoolCreatedImpl(
  companyId: json['companyId'] as String,
  poolId: json['poolId'] as String,
  name: json['name'] as String,
  shareClassId: json['shareClassId'] as String,
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
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$EsopPoolCreatedImplToJson(
  _$EsopPoolCreatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'poolId': instance.poolId,
  'name': instance.name,
  'shareClassId': instance.shareClassId,
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
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$EsopPoolExpandedImpl _$$EsopPoolExpandedImplFromJson(
  Map<String, dynamic> json,
) => _$EsopPoolExpandedImpl(
  companyId: json['companyId'] as String,
  expansionId: json['expansionId'] as String,
  poolId: json['poolId'] as String,
  previousSize: (json['previousSize'] as num).toInt(),
  newSize: (json['newSize'] as num).toInt(),
  sharesAdded: (json['sharesAdded'] as num).toInt(),
  reason: json['reason'] as String,
  resolutionReference: json['resolutionReference'] as String?,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$EsopPoolExpandedImplToJson(
  _$EsopPoolExpandedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'expansionId': instance.expansionId,
  'poolId': instance.poolId,
  'previousSize': instance.previousSize,
  'newSize': instance.newSize,
  'sharesAdded': instance.sharesAdded,
  'reason': instance.reason,
  'resolutionReference': instance.resolutionReference,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$EsopPoolActivatedImpl _$$EsopPoolActivatedImplFromJson(
  Map<String, dynamic> json,
) => _$EsopPoolActivatedImpl(
  companyId: json['companyId'] as String,
  poolId: json['poolId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$EsopPoolActivatedImplToJson(
  _$EsopPoolActivatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'poolId': instance.poolId,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$OptionGrantedImpl _$$OptionGrantedImplFromJson(Map<String, dynamic> json) =>
    _$OptionGrantedImpl(
      companyId: json['companyId'] as String,
      grantId: json['grantId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      esopPoolId: json['esopPoolId'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      strikePrice: (json['strikePrice'] as num).toDouble(),
      grantDate: DateTime.parse(json['grantDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      vestingScheduleId: json['vestingScheduleId'] as String?,
      roundId: json['roundId'] as String?,
      allowsEarlyExercise: json['allowsEarlyExercise'] as bool? ?? false,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$OptionGrantedImplToJson(_$OptionGrantedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'grantId': instance.grantId,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'esopPoolId': instance.esopPoolId,
      'quantity': instance.quantity,
      'strikePrice': instance.strikePrice,
      'grantDate': instance.grantDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'vestingScheduleId': instance.vestingScheduleId,
      'roundId': instance.roundId,
      'allowsEarlyExercise': instance.allowsEarlyExercise,
      'notes': instance.notes,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$OptionsVestedImpl _$$OptionsVestedImplFromJson(Map<String, dynamic> json) =>
    _$OptionsVestedImpl(
      companyId: json['companyId'] as String,
      grantId: json['grantId'] as String,
      vestedCount: (json['vestedCount'] as num).toInt(),
      vestingDate: DateTime.parse(json['vestingDate'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$OptionsVestedImplToJson(_$OptionsVestedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'grantId': instance.grantId,
      'vestedCount': instance.vestedCount,
      'vestingDate': instance.vestingDate.toIso8601String(),
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$OptionsExercisedImpl _$$OptionsExercisedImplFromJson(
  Map<String, dynamic> json,
) => _$OptionsExercisedImpl(
  companyId: json['companyId'] as String,
  grantId: json['grantId'] as String,
  exercisedCount: (json['exercisedCount'] as num).toInt(),
  exercisePrice: (json['exercisePrice'] as num).toDouble(),
  resultingHoldingId: json['resultingHoldingId'] as String,
  exerciseDate: DateTime.parse(json['exerciseDate'] as String),
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$OptionsExercisedImplToJson(
  _$OptionsExercisedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'grantId': instance.grantId,
  'exercisedCount': instance.exercisedCount,
  'exercisePrice': instance.exercisePrice,
  'resultingHoldingId': instance.resultingHoldingId,
  'exerciseDate': instance.exerciseDate.toIso8601String(),
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$OptionsCancelledImpl _$$OptionsCancelledImplFromJson(
  Map<String, dynamic> json,
) => _$OptionsCancelledImpl(
  companyId: json['companyId'] as String,
  grantId: json['grantId'] as String,
  cancelledCount: (json['cancelledCount'] as num).toInt(),
  reason: json['reason'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$OptionsCancelledImplToJson(
  _$OptionsCancelledImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'grantId': instance.grantId,
  'cancelledCount': instance.cancelledCount,
  'reason': instance.reason,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$OptionGrantStatusChangedImpl _$$OptionGrantStatusChangedImplFromJson(
  Map<String, dynamic> json,
) => _$OptionGrantStatusChangedImpl(
  companyId: json['companyId'] as String,
  grantId: json['grantId'] as String,
  previousStatus: json['previousStatus'] as String,
  newStatus: json['newStatus'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$OptionGrantStatusChangedImplToJson(
  _$OptionGrantStatusChangedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'grantId': instance.grantId,
  'previousStatus': instance.previousStatus,
  'newStatus': instance.newStatus,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$WarrantIssuedImpl _$$WarrantIssuedImplFromJson(Map<String, dynamic> json) =>
    _$WarrantIssuedImpl(
      companyId: json['companyId'] as String,
      warrantId: json['warrantId'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      strikePrice: (json['strikePrice'] as num).toDouble(),
      issueDate: DateTime.parse(json['issueDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      sourceConvertibleId: json['sourceConvertibleId'] as String?,
      roundId: json['roundId'] as String?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$WarrantIssuedImplToJson(_$WarrantIssuedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'warrantId': instance.warrantId,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'quantity': instance.quantity,
      'strikePrice': instance.strikePrice,
      'issueDate': instance.issueDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'sourceConvertibleId': instance.sourceConvertibleId,
      'roundId': instance.roundId,
      'notes': instance.notes,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$WarrantExercisedImpl _$$WarrantExercisedImplFromJson(
  Map<String, dynamic> json,
) => _$WarrantExercisedImpl(
  companyId: json['companyId'] as String,
  warrantId: json['warrantId'] as String,
  exercisedCount: (json['exercisedCount'] as num).toInt(),
  exercisePrice: (json['exercisePrice'] as num).toDouble(),
  resultingHoldingId: json['resultingHoldingId'] as String,
  exerciseDate: DateTime.parse(json['exerciseDate'] as String),
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$WarrantExercisedImplToJson(
  _$WarrantExercisedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'warrantId': instance.warrantId,
  'exercisedCount': instance.exercisedCount,
  'exercisePrice': instance.exercisePrice,
  'resultingHoldingId': instance.resultingHoldingId,
  'exerciseDate': instance.exerciseDate.toIso8601String(),
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$WarrantCancelledImpl _$$WarrantCancelledImplFromJson(
  Map<String, dynamic> json,
) => _$WarrantCancelledImpl(
  companyId: json['companyId'] as String,
  warrantId: json['warrantId'] as String,
  cancelledCount: (json['cancelledCount'] as num).toInt(),
  reason: json['reason'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$WarrantCancelledImplToJson(
  _$WarrantCancelledImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'warrantId': instance.warrantId,
  'cancelledCount': instance.cancelledCount,
  'reason': instance.reason,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$WarrantUpdatedImpl _$$WarrantUpdatedImplFromJson(Map<String, dynamic> json) =>
    _$WarrantUpdatedImpl(
      companyId: json['companyId'] as String,
      warrantId: json['warrantId'] as String,
      shareClassId: json['shareClassId'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      strikePrice: (json['strikePrice'] as num?)?.toDouble(),
      issueDate: json['issueDate'] == null
          ? null
          : DateTime.parse(json['issueDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      roundId: json['roundId'] as String?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$WarrantUpdatedImplToJson(
  _$WarrantUpdatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'warrantId': instance.warrantId,
  'shareClassId': instance.shareClassId,
  'quantity': instance.quantity,
  'strikePrice': instance.strikePrice,
  'issueDate': instance.issueDate?.toIso8601String(),
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'roundId': instance.roundId,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$WarrantUnexercisedImpl _$$WarrantUnexercisedImplFromJson(
  Map<String, dynamic> json,
) => _$WarrantUnexercisedImpl(
  companyId: json['companyId'] as String,
  warrantId: json['warrantId'] as String,
  unexercisedCount: (json['unexercisedCount'] as num).toInt(),
  reason: json['reason'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$WarrantUnexercisedImplToJson(
  _$WarrantUnexercisedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'warrantId': instance.warrantId,
  'unexercisedCount': instance.unexercisedCount,
  'reason': instance.reason,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$WarrantStatusChangedImpl _$$WarrantStatusChangedImplFromJson(
  Map<String, dynamic> json,
) => _$WarrantStatusChangedImpl(
  companyId: json['companyId'] as String,
  warrantId: json['warrantId'] as String,
  previousStatus: json['previousStatus'] as String,
  newStatus: json['newStatus'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$WarrantStatusChangedImplToJson(
  _$WarrantStatusChangedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'warrantId': instance.warrantId,
  'previousStatus': instance.previousStatus,
  'newStatus': instance.newStatus,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$VestingScheduleCreatedImpl _$$VestingScheduleCreatedImplFromJson(
  Map<String, dynamic> json,
) => _$VestingScheduleCreatedImpl(
  companyId: json['companyId'] as String,
  scheduleId: json['scheduleId'] as String,
  name: json['name'] as String,
  scheduleType: json['scheduleType'] as String,
  totalMonths: (json['totalMonths'] as num?)?.toInt(),
  cliffMonths: (json['cliffMonths'] as num?)?.toInt() ?? 0,
  frequency: json['frequency'] as String?,
  milestonesJson: json['milestonesJson'] as String?,
  totalHours: (json['totalHours'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VestingScheduleCreatedImplToJson(
  _$VestingScheduleCreatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'scheduleId': instance.scheduleId,
  'name': instance.name,
  'scheduleType': instance.scheduleType,
  'totalMonths': instance.totalMonths,
  'cliffMonths': instance.cliffMonths,
  'frequency': instance.frequency,
  'milestonesJson': instance.milestonesJson,
  'totalHours': instance.totalHours,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$VestingScheduleUpdatedImpl _$$VestingScheduleUpdatedImplFromJson(
  Map<String, dynamic> json,
) => _$VestingScheduleUpdatedImpl(
  companyId: json['companyId'] as String,
  scheduleId: json['scheduleId'] as String,
  name: json['name'] as String?,
  scheduleType: json['scheduleType'] as String?,
  totalMonths: (json['totalMonths'] as num?)?.toInt(),
  cliffMonths: (json['cliffMonths'] as num?)?.toInt(),
  frequency: json['frequency'] as String?,
  milestonesJson: json['milestonesJson'] as String?,
  totalHours: (json['totalHours'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VestingScheduleUpdatedImplToJson(
  _$VestingScheduleUpdatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'scheduleId': instance.scheduleId,
  'name': instance.name,
  'scheduleType': instance.scheduleType,
  'totalMonths': instance.totalMonths,
  'cliffMonths': instance.cliffMonths,
  'frequency': instance.frequency,
  'milestonesJson': instance.milestonesJson,
  'totalHours': instance.totalHours,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$VestingScheduleDeletedImpl _$$VestingScheduleDeletedImplFromJson(
  Map<String, dynamic> json,
) => _$VestingScheduleDeletedImpl(
  companyId: json['companyId'] as String,
  scheduleId: json['scheduleId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$VestingScheduleDeletedImplToJson(
  _$VestingScheduleDeletedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'scheduleId': instance.scheduleId,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$ValuationRecordedImpl _$$ValuationRecordedImplFromJson(
  Map<String, dynamic> json,
) => _$ValuationRecordedImpl(
  companyId: json['companyId'] as String,
  valuationId: json['valuationId'] as String,
  date: DateTime.parse(json['date'] as String),
  preMoneyValue: (json['preMoneyValue'] as num).toDouble(),
  method: json['method'] as String,
  methodParamsJson: json['methodParamsJson'] as String?,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$ValuationRecordedImplToJson(
  _$ValuationRecordedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'valuationId': instance.valuationId,
  'date': instance.date.toIso8601String(),
  'preMoneyValue': instance.preMoneyValue,
  'method': instance.method,
  'methodParamsJson': instance.methodParamsJson,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$ValuationDeletedImpl _$$ValuationDeletedImplFromJson(
  Map<String, dynamic> json,
) => _$ValuationDeletedImpl(
  companyId: json['companyId'] as String,
  valuationId: json['valuationId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$ValuationDeletedImplToJson(
  _$ValuationDeletedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'valuationId': instance.valuationId,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$TransferInitiatedImpl _$$TransferInitiatedImplFromJson(
  Map<String, dynamic> json,
) => _$TransferInitiatedImpl(
  companyId: json['companyId'] as String,
  transferId: json['transferId'] as String,
  sellerStakeholderId: json['sellerStakeholderId'] as String,
  buyerStakeholderId: json['buyerStakeholderId'] as String,
  shareClassId: json['shareClassId'] as String,
  shareCount: (json['shareCount'] as num).toInt(),
  pricePerShare: (json['pricePerShare'] as num).toDouble(),
  fairMarketValue: (json['fairMarketValue'] as num?)?.toDouble(),
  transactionDate: DateTime.parse(json['transactionDate'] as String),
  transferType: json['transferType'] as String,
  requiresRofr: json['requiresRofr'] as bool? ?? false,
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$TransferInitiatedImplToJson(
  _$TransferInitiatedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'transferId': instance.transferId,
  'sellerStakeholderId': instance.sellerStakeholderId,
  'buyerStakeholderId': instance.buyerStakeholderId,
  'shareClassId': instance.shareClassId,
  'shareCount': instance.shareCount,
  'pricePerShare': instance.pricePerShare,
  'fairMarketValue': instance.fairMarketValue,
  'transactionDate': instance.transactionDate.toIso8601String(),
  'transferType': instance.transferType,
  'requiresRofr': instance.requiresRofr,
  'notes': instance.notes,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$TransferRofrWaivedImpl _$$TransferRofrWaivedImplFromJson(
  Map<String, dynamic> json,
) => _$TransferRofrWaivedImpl(
  companyId: json['companyId'] as String,
  transferId: json['transferId'] as String,
  waivedBy: json['waivedBy'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$TransferRofrWaivedImplToJson(
  _$TransferRofrWaivedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'transferId': instance.transferId,
  'waivedBy': instance.waivedBy,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$TransferExecutedImpl _$$TransferExecutedImplFromJson(
  Map<String, dynamic> json,
) => _$TransferExecutedImpl(
  companyId: json['companyId'] as String,
  transferId: json['transferId'] as String,
  resultingHoldingId: json['resultingHoldingId'] as String,
  executionDate: DateTime.parse(json['executionDate'] as String),
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$TransferExecutedImplToJson(
  _$TransferExecutedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'transferId': instance.transferId,
  'resultingHoldingId': instance.resultingHoldingId,
  'executionDate': instance.executionDate.toIso8601String(),
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$TransferCancelledImpl _$$TransferCancelledImplFromJson(
  Map<String, dynamic> json,
) => _$TransferCancelledImpl(
  companyId: json['companyId'] as String,
  transferId: json['transferId'] as String,
  reason: json['reason'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$TransferCancelledImplToJson(
  _$TransferCancelledImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'transferId': instance.transferId,
  'reason': instance.reason,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$MfnUpgradeRevertedImpl _$$MfnUpgradeRevertedImplFromJson(
  Map<String, dynamic> json,
) => _$MfnUpgradeRevertedImpl(
  companyId: json['companyId'] as String,
  upgradeId: json['upgradeId'] as String,
  targetConvertibleId: json['targetConvertibleId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$MfnUpgradeRevertedImplToJson(
  _$MfnUpgradeRevertedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'upgradeId': instance.upgradeId,
  'targetConvertibleId': instance.targetConvertibleId,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};

_$ScenarioSavedImpl _$$ScenarioSavedImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioSavedImpl(
      companyId: json['companyId'] as String,
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      scenarioType: json['scenarioType'] as String,
      parametersJson: json['parametersJson'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actorId: json['actorId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$ScenarioSavedImplToJson(_$ScenarioSavedImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'scenarioId': instance.scenarioId,
      'name': instance.name,
      'scenarioType': instance.scenarioType,
      'parametersJson': instance.parametersJson,
      'timestamp': instance.timestamp.toIso8601String(),
      'actorId': instance.actorId,
      'type': instance.$type,
    };

_$ScenarioDeletedImpl _$$ScenarioDeletedImplFromJson(
  Map<String, dynamic> json,
) => _$ScenarioDeletedImpl(
  companyId: json['companyId'] as String,
  scenarioId: json['scenarioId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  actorId: json['actorId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$$ScenarioDeletedImplToJson(
  _$ScenarioDeletedImpl instance,
) => <String, dynamic>{
  'companyId': instance.companyId,
  'scenarioId': instance.scenarioId,
  'timestamp': instance.timestamp.toIso8601String(),
  'actorId': instance.actorId,
  'type': instance.$type,
};
