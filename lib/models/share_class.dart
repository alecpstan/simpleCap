import 'package:uuid/uuid.dart';

enum ShareClassType {
  ordinary,
  preferenceA,
  preferenceB,
  options,
  esop,
  performanceRights,
  convertibleNote,
  safe,
  custom,
}

class ShareClass {
  final String id;
  String name;
  ShareClassType type;
  double
  votingRightsMultiplier; // 1.0 = normal, 0 = non-voting, 10 = 10x voting
  double liquidationPreference; // 1.0 = 1x, 2.0 = 2x, etc.
  bool participating; // Participating preferred
  double dividendRate; // Annual dividend rate (if any)
  int seniority; // Higher = paid first in liquidation
  String? notes;

  ShareClass({
    String? id,
    required this.name,
    required this.type,
    this.votingRightsMultiplier = 1.0,
    this.liquidationPreference = 1.0,
    this.participating = false,
    this.dividendRate = 0.0,
    this.seniority = 0,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'votingRightsMultiplier': votingRightsMultiplier,
    'liquidationPreference': liquidationPreference,
    'participating': participating,
    'dividendRate': dividendRate,
    'seniority': seniority,
    'notes': notes,
  };

  factory ShareClass.fromJson(Map<String, dynamic> json) => ShareClass(
    id: json['id'],
    name: json['name'],
    type: ShareClassType.values[json['type']],
    votingRightsMultiplier: (json['votingRightsMultiplier'] ?? 1.0).toDouble(),
    liquidationPreference: (json['liquidationPreference'] ?? 1.0).toDouble(),
    participating: json['participating'] ?? false,
    dividendRate: (json['dividendRate'] ?? 0.0).toDouble(),
    seniority: json['seniority'] ?? 0,
    notes: json['notes'],
  );

  String get typeDisplayName {
    switch (type) {
      case ShareClassType.ordinary:
        return 'Ordinary';
      case ShareClassType.preferenceA:
        return 'Preference A';
      case ShareClassType.preferenceB:
        return 'Preference B';
      case ShareClassType.options:
        return 'Options';
      case ShareClassType.esop:
        return 'ESOP';
      case ShareClassType.performanceRights:
        return 'Performance Rights';
      case ShareClassType.convertibleNote:
        return 'Convertible Note';
      case ShareClassType.safe:
        return 'SAFE';
      case ShareClassType.custom:
        return 'Custom';
    }
  }

  ShareClass copyWith({
    String? name,
    ShareClassType? type,
    double? votingRightsMultiplier,
    double? liquidationPreference,
    bool? participating,
    double? dividendRate,
    int? seniority,
    String? notes,
  }) {
    return ShareClass(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      votingRightsMultiplier:
          votingRightsMultiplier ?? this.votingRightsMultiplier,
      liquidationPreference:
          liquidationPreference ?? this.liquidationPreference,
      participating: participating ?? this.participating,
      dividendRate: dividendRate ?? this.dividendRate,
      seniority: seniority ?? this.seniority,
      notes: notes ?? this.notes,
    );
  }
}
