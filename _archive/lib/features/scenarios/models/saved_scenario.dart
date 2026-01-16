import '../../../shared/utils/helpers.dart';

/// Types of scenarios that can be saved
enum ScenarioType {
  dilution,
  exitWaterfall,
  newRound,
}

extension ScenarioTypeExtension on ScenarioType {
  String get displayName {
    switch (this) {
      case ScenarioType.dilution:
        return 'Dilution Calculator';
      case ScenarioType.exitWaterfall:
        return 'Exit Waterfall';
      case ScenarioType.newRound:
        return 'New Round Simulator';
    }
  }

  String get shortName {
    switch (this) {
      case ScenarioType.dilution:
        return 'Dilution';
      case ScenarioType.exitWaterfall:
        return 'Exit';
      case ScenarioType.newRound:
        return 'Round';
    }
  }
}

/// A saved scenario with all its input parameters
class SavedScenario {
  final String? id;
  final String name;
  final ScenarioType type;
  final Map<String, dynamic> parameters;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedScenario({
    this.id,
    required this.name,
    required this.type,
    required this.parameters,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  SavedScenario copyWith({
    String? id,
    String? name,
    ScenarioType? type,
    Map<String, dynamic>? parameters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedScenario(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parameters: parameters ?? Map.from(this.parameters),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'parameters': parameters,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavedScenario.fromJson(Map<String, dynamic> json) {
    return SavedScenario(
      id: json['id'] as String?,
      name: json['name'] as String,
      type: ScenarioType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScenarioType.dilution,
      ),
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Get a summary description based on scenario type and parameters
  String get summary {
    switch (type) {
      case ScenarioType.dilution:
        final newShares = parameters['newShares'];
        final investment = parameters['investment'];
        final preMoney = parameters['preMoney'];
        if (preMoney != null && investment != null) {
          return 'Pre-money: ${Formatters.compactCurrencyString(_toDouble(preMoney))}, Investment: ${Formatters.compactCurrencyString(_toDouble(investment))}';
        } else if (newShares != null) {
          return 'New shares: ${Formatters.compactNumberString(_toDouble(newShares))}';
        }
        return 'Dilution scenario';

      case ScenarioType.exitWaterfall:
        final exitValuation = parameters['exitValuation'];
        if (exitValuation != null) {
          return 'Exit: ${Formatters.compactCurrencyString(_toDouble(exitValuation))}';
        }
        return 'Exit waterfall scenario';

      case ScenarioType.newRound:
        final roundName = parameters['roundName'] as String?;
        final raiseAmount = parameters['raiseAmount'];
        final preMoney = parameters['preMoney'];
        final parts = <String>[];
        if (roundName != null && roundName.isNotEmpty) {
          parts.add(roundName);
        }
        if (raiseAmount != null) {
          parts.add('Raise: ${Formatters.compactCurrencyString(_toDouble(raiseAmount))}');
        }
        if (preMoney != null) {
          parts.add('Pre: ${Formatters.compactCurrencyString(_toDouble(preMoney))}');
        }
        return parts.isEmpty ? 'New round scenario' : parts.join(', ');
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
