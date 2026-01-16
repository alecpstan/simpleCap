import 'package:uuid/uuid.dart';

enum RoundType {
  incorporation,
  seed,
  seriesA,
  seriesB,
  seriesC,
  seriesD,
  bridge,
  convertible,
  esopPool,
  secondary,
  custom,
}

class InvestmentRound {
  final String id;
  String name;
  RoundType type;
  DateTime date;
  double preMoneyValuation; // In AUD
  double amountRaised; // In AUD
  double? pricePerShare;
  String? leadInvestor;
  String? notes;
  bool isClosed;
  int order; // For sorting rounds chronologically

  InvestmentRound({
    String? id,
    required this.name,
    required this.type,
    required this.date,
    this.preMoneyValuation = 0,
    this.amountRaised = 0,
    this.pricePerShare,
    this.leadInvestor,
    this.notes,
    this.isClosed = false,
    this.order = 0,
  }) : id = id ?? const Uuid().v4();

  double get postMoneyValuation => preMoneyValuation + amountRaised;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'date': date.toIso8601String(),
    'preMoneyValuation': preMoneyValuation,
    'amountRaised': amountRaised,
    'pricePerShare': pricePerShare,
    'leadInvestor': leadInvestor,
    'notes': notes,
    'isClosed': isClosed,
    'order': order,
  };

  factory InvestmentRound.fromJson(Map<String, dynamic> json) =>
      InvestmentRound(
        id: json['id'],
        name: json['name'],
        type: RoundType.values[json['type']],
        date: DateTime.parse(json['date']),
        preMoneyValuation: (json['preMoneyValuation'] ?? 0).toDouble(),
        amountRaised: (json['amountRaised'] ?? 0).toDouble(),
        pricePerShare: json['pricePerShare']?.toDouble(),
        leadInvestor: json['leadInvestor'],
        notes: json['notes'],
        isClosed: json['isClosed'] ?? false,
        order: json['order'] ?? 0,
      );

  String get typeDisplayName {
    switch (type) {
      case RoundType.incorporation:
        return 'Incorporation';
      case RoundType.seed:
        return 'Seed';
      case RoundType.seriesA:
        return 'Series A';
      case RoundType.seriesB:
        return 'Series B';
      case RoundType.seriesC:
        return 'Series C';
      case RoundType.seriesD:
        return 'Series D';
      case RoundType.bridge:
        return 'Bridge';
      case RoundType.convertible:
        return 'Convertible Note';
      case RoundType.esopPool:
        return 'ESOP Pool';
      case RoundType.secondary:
        return 'Secondary';
      case RoundType.custom:
        return 'Custom';
    }
  }

  InvestmentRound copyWith({
    String? name,
    RoundType? type,
    DateTime? date,
    double? preMoneyValuation,
    double? amountRaised,
    double? pricePerShare,
    String? leadInvestor,
    String? notes,
    bool? isClosed,
    int? order,
  }) {
    return InvestmentRound(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      preMoneyValuation: preMoneyValuation ?? this.preMoneyValuation,
      amountRaised: amountRaised ?? this.amountRaised,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      leadInvestor: leadInvestor ?? this.leadInvestor,
      notes: notes ?? this.notes,
      isClosed: isClosed ?? this.isClosed,
      order: order ?? this.order,
    );
  }
}
