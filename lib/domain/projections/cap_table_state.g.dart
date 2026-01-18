// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cap_table_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CapTableStateImpl _$$CapTableStateImplFromJson(
  Map<String, dynamic> json,
) => _$CapTableStateImpl(
  companyId: json['companyId'] as String,
  companyName: json['companyName'] as String,
  companyCreatedAt: DateTime.parse(json['companyCreatedAt'] as String),
  stakeholders:
      (json['stakeholders'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, StakeholderState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  shareClasses:
      (json['shareClasses'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ShareClassState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  rounds:
      (json['rounds'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, RoundState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  holdings:
      (json['holdings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, HoldingState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  convertibles:
      (json['convertibles'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ConvertibleState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  esopPools:
      (json['esopPools'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, EsopPoolState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  optionGrants:
      (json['optionGrants'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, OptionGrantState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  warrants:
      (json['warrants'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, WarrantState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  vestingSchedules:
      (json['vestingSchedules'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          VestingScheduleState.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  valuations:
      (json['valuations'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ValuationState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  transfers:
      (json['transfers'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, TransferState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  scenarios:
      (json['scenarios'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ScenarioState.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  lastSequenceNumber: (json['lastSequenceNumber'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$CapTableStateImplToJson(_$CapTableStateImpl instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'companyName': instance.companyName,
      'companyCreatedAt': instance.companyCreatedAt.toIso8601String(),
      'stakeholders': instance.stakeholders,
      'shareClasses': instance.shareClasses,
      'rounds': instance.rounds,
      'holdings': instance.holdings,
      'convertibles': instance.convertibles,
      'esopPools': instance.esopPools,
      'optionGrants': instance.optionGrants,
      'warrants': instance.warrants,
      'vestingSchedules': instance.vestingSchedules,
      'valuations': instance.valuations,
      'transfers': instance.transfers,
      'scenarios': instance.scenarios,
      'lastSequenceNumber': instance.lastSequenceNumber,
    };

_$StakeholderStateImpl _$$StakeholderStateImplFromJson(
  Map<String, dynamic> json,
) => _$StakeholderStateImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  company: json['company'] as String?,
  hasProRataRights: json['hasProRataRights'] as bool? ?? false,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$StakeholderStateImplToJson(
  _$StakeholderStateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'email': instance.email,
  'phone': instance.phone,
  'company': instance.company,
  'hasProRataRights': instance.hasProRataRights,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$ShareClassStateImpl _$$ShareClassStateImplFromJson(
  Map<String, dynamic> json,
) => _$ShareClassStateImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  votingMultiplier: (json['votingMultiplier'] as num?)?.toDouble() ?? 1.0,
  liquidationPreference:
      (json['liquidationPreference'] as num?)?.toDouble() ?? 1.0,
  isParticipating: json['isParticipating'] as bool? ?? false,
  dividendRate: (json['dividendRate'] as num?)?.toDouble() ?? 0.0,
  seniority: (json['seniority'] as num?)?.toInt() ?? 0,
  antiDilutionType: json['antiDilutionType'] as String? ?? 'none',
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ShareClassStateImplToJson(
  _$ShareClassStateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'votingMultiplier': instance.votingMultiplier,
  'liquidationPreference': instance.liquidationPreference,
  'isParticipating': instance.isParticipating,
  'dividendRate': instance.dividendRate,
  'seniority': instance.seniority,
  'antiDilutionType': instance.antiDilutionType,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$RoundStateImpl _$$RoundStateImplFromJson(Map<String, dynamic> json) =>
    _$RoundStateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      date: DateTime.parse(json['date'] as String),
      preMoneyValuation: (json['preMoneyValuation'] as num?)?.toDouble(),
      pricePerShare: (json['pricePerShare'] as num?)?.toDouble(),
      amountRaised: (json['amountRaised'] as num?)?.toDouble() ?? 0,
      leadInvestorId: json['leadInvestorId'] as String?,
      displayOrder: (json['displayOrder'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RoundStateImplToJson(_$RoundStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'status': instance.status,
      'date': instance.date.toIso8601String(),
      'preMoneyValuation': instance.preMoneyValuation,
      'pricePerShare': instance.pricePerShare,
      'amountRaised': instance.amountRaised,
      'leadInvestorId': instance.leadInvestorId,
      'displayOrder': instance.displayOrder,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$HoldingStateImpl _$$HoldingStateImplFromJson(Map<String, dynamic> json) =>
    _$HoldingStateImpl(
      id: json['id'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      shareCount: (json['shareCount'] as num).toInt(),
      costBasis: (json['costBasis'] as num).toDouble(),
      acquiredDate: DateTime.parse(json['acquiredDate'] as String),
      roundId: json['roundId'] as String?,
      vestingScheduleId: json['vestingScheduleId'] as String?,
      vestedCount: (json['vestedCount'] as num?)?.toInt(),
      sourceOptionGrantId: json['sourceOptionGrantId'] as String?,
      sourceWarrantId: json['sourceWarrantId'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$HoldingStateImplToJson(_$HoldingStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'shareCount': instance.shareCount,
      'costBasis': instance.costBasis,
      'acquiredDate': instance.acquiredDate.toIso8601String(),
      'roundId': instance.roundId,
      'vestingScheduleId': instance.vestingScheduleId,
      'vestedCount': instance.vestedCount,
      'sourceOptionGrantId': instance.sourceOptionGrantId,
      'sourceWarrantId': instance.sourceWarrantId,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$ConvertibleStateImpl _$$ConvertibleStateImplFromJson(
  Map<String, dynamic> json,
) => _$ConvertibleStateImpl(
  id: json['id'] as String,
  stakeholderId: json['stakeholderId'] as String,
  type: json['type'] as String,
  status: json['status'] as String,
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
  conversionRoundId: json['conversionRoundId'] as String?,
  convertedToShareClassId: json['convertedToShareClassId'] as String?,
  sharesReceived: (json['sharesReceived'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  maturityBehavior: json['maturityBehavior'] as String?,
  allowsVoluntaryConversion:
      json['allowsVoluntaryConversion'] as bool? ?? false,
  liquidityEventBehavior: json['liquidityEventBehavior'] as String?,
  liquidityPayoutMultiple: (json['liquidityPayoutMultiple'] as num?)
      ?.toDouble(),
  dissolutionBehavior: json['dissolutionBehavior'] as String?,
  preferredShareClassId: json['preferredShareClassId'] as String?,
  qualifiedFinancingThreshold: (json['qualifiedFinancingThreshold'] as num?)
      ?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ConvertibleStateImplToJson(
  _$ConvertibleStateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'stakeholderId': instance.stakeholderId,
  'type': instance.type,
  'status': instance.status,
  'principal': instance.principal,
  'valuationCap': instance.valuationCap,
  'discountPercent': instance.discountPercent,
  'interestRate': instance.interestRate,
  'maturityDate': instance.maturityDate?.toIso8601String(),
  'issueDate': instance.issueDate.toIso8601String(),
  'hasMfn': instance.hasMfn,
  'hasProRata': instance.hasProRata,
  'roundId': instance.roundId,
  'conversionRoundId': instance.conversionRoundId,
  'convertedToShareClassId': instance.convertedToShareClassId,
  'sharesReceived': instance.sharesReceived,
  'notes': instance.notes,
  'maturityBehavior': instance.maturityBehavior,
  'allowsVoluntaryConversion': instance.allowsVoluntaryConversion,
  'liquidityEventBehavior': instance.liquidityEventBehavior,
  'liquidityPayoutMultiple': instance.liquidityPayoutMultiple,
  'dissolutionBehavior': instance.dissolutionBehavior,
  'preferredShareClassId': instance.preferredShareClassId,
  'qualifiedFinancingThreshold': instance.qualifiedFinancingThreshold,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$EsopPoolStateImpl _$$EsopPoolStateImplFromJson(Map<String, dynamic> json) =>
    _$EsopPoolStateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
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

Map<String, dynamic> _$$EsopPoolStateImplToJson(_$EsopPoolStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
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

_$OptionGrantStateImpl _$$OptionGrantStateImplFromJson(
  Map<String, dynamic> json,
) => _$OptionGrantStateImpl(
  id: json['id'] as String,
  stakeholderId: json['stakeholderId'] as String,
  shareClassId: json['shareClassId'] as String,
  esopPoolId: json['esopPoolId'] as String?,
  status: json['status'] as String,
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

Map<String, dynamic> _$$OptionGrantStateImplToJson(
  _$OptionGrantStateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'stakeholderId': instance.stakeholderId,
  'shareClassId': instance.shareClassId,
  'esopPoolId': instance.esopPoolId,
  'status': instance.status,
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

_$WarrantStateImpl _$$WarrantStateImplFromJson(Map<String, dynamic> json) =>
    _$WarrantStateImpl(
      id: json['id'] as String,
      stakeholderId: json['stakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      status: json['status'] as String,
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

Map<String, dynamic> _$$WarrantStateImplToJson(_$WarrantStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stakeholderId': instance.stakeholderId,
      'shareClassId': instance.shareClassId,
      'status': instance.status,
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

_$VestingScheduleStateImpl _$$VestingScheduleStateImplFromJson(
  Map<String, dynamic> json,
) => _$VestingScheduleStateImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  totalMonths: (json['totalMonths'] as num?)?.toInt(),
  cliffMonths: (json['cliffMonths'] as num?)?.toInt() ?? 0,
  frequency: json['frequency'] as String?,
  milestonesJson: json['milestonesJson'] as String?,
  totalHours: (json['totalHours'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$VestingScheduleStateImplToJson(
  _$VestingScheduleStateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'totalMonths': instance.totalMonths,
  'cliffMonths': instance.cliffMonths,
  'frequency': instance.frequency,
  'milestonesJson': instance.milestonesJson,
  'totalHours': instance.totalHours,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$ValuationStateImpl _$$ValuationStateImplFromJson(Map<String, dynamic> json) =>
    _$ValuationStateImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      preMoneyValue: (json['preMoneyValue'] as num).toDouble(),
      method: json['method'] as String,
      methodParamsJson: json['methodParamsJson'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ValuationStateImplToJson(
  _$ValuationStateImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'preMoneyValue': instance.preMoneyValue,
  'method': instance.method,
  'methodParamsJson': instance.methodParamsJson,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$TransferStateImpl _$$TransferStateImplFromJson(Map<String, dynamic> json) =>
    _$TransferStateImpl(
      id: json['id'] as String,
      sellerStakeholderId: json['sellerStakeholderId'] as String,
      buyerStakeholderId: json['buyerStakeholderId'] as String,
      shareClassId: json['shareClassId'] as String,
      shareCount: (json['shareCount'] as num).toInt(),
      pricePerShare: (json['pricePerShare'] as num).toDouble(),
      fairMarketValue: (json['fairMarketValue'] as num?)?.toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      type: json['type'] as String,
      status: json['status'] as String,
      requiresRofr: json['requiresRofr'] as bool? ?? false,
      rofrWaived: json['rofrWaived'] as bool? ?? false,
      sourceHoldingId: json['sourceHoldingId'] as String?,
      resultingHoldingId: json['resultingHoldingId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TransferStateImplToJson(_$TransferStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sellerStakeholderId': instance.sellerStakeholderId,
      'buyerStakeholderId': instance.buyerStakeholderId,
      'shareClassId': instance.shareClassId,
      'shareCount': instance.shareCount,
      'pricePerShare': instance.pricePerShare,
      'fairMarketValue': instance.fairMarketValue,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'type': instance.type,
      'status': instance.status,
      'requiresRofr': instance.requiresRofr,
      'rofrWaived': instance.rofrWaived,
      'sourceHoldingId': instance.sourceHoldingId,
      'resultingHoldingId': instance.resultingHoldingId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$ScenarioStateImpl _$$ScenarioStateImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioStateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      parametersJson: json['parametersJson'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ScenarioStateImplToJson(_$ScenarioStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'parametersJson': instance.parametersJson,
      'createdAt': instance.createdAt.toIso8601String(),
    };
