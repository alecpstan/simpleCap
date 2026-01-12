import 'package:uuid/uuid.dart';

class Shareholding {
  final String id;
  String investorId;
  String shareClassId;
  String roundId;
  int numberOfShares;
  double pricePerShare;
  double amountInvested;
  DateTime dateAcquired;
  String? notes;

  Shareholding({
    String? id,
    required this.investorId,
    required this.shareClassId,
    required this.roundId,
    required this.numberOfShares,
    required this.pricePerShare,
    double? amountInvested,
    DateTime? dateAcquired,
    this.notes,
  }) : id = id ?? const Uuid().v4(),
       amountInvested = amountInvested ?? (numberOfShares * pricePerShare),
       dateAcquired = dateAcquired ?? DateTime.now();

  double get currentValue => numberOfShares * pricePerShare;

  Map<String, dynamic> toJson() => {
    'id': id,
    'investorId': investorId,
    'shareClassId': shareClassId,
    'roundId': roundId,
    'numberOfShares': numberOfShares,
    'pricePerShare': pricePerShare,
    'amountInvested': amountInvested,
    'dateAcquired': dateAcquired.toIso8601String(),
    'notes': notes,
  };

  factory Shareholding.fromJson(Map<String, dynamic> json) => Shareholding(
    id: json['id'],
    investorId: json['investorId'],
    shareClassId: json['shareClassId'],
    roundId: json['roundId'],
    numberOfShares: json['numberOfShares'],
    pricePerShare: (json['pricePerShare'] ?? 0).toDouble(),
    amountInvested: (json['amountInvested'] ?? 0).toDouble(),
    dateAcquired: DateTime.parse(json['dateAcquired']),
    notes: json['notes'],
  );

  Shareholding copyWith({
    String? investorId,
    String? shareClassId,
    String? roundId,
    int? numberOfShares,
    double? pricePerShare,
    double? amountInvested,
    DateTime? dateAcquired,
    String? notes,
  }) {
    return Shareholding(
      id: id,
      investorId: investorId ?? this.investorId,
      shareClassId: shareClassId ?? this.shareClassId,
      roundId: roundId ?? this.roundId,
      numberOfShares: numberOfShares ?? this.numberOfShares,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      amountInvested: amountInvested ?? this.amountInvested,
      dateAcquired: dateAcquired ?? this.dateAcquired,
      notes: notes ?? this.notes,
    );
  }
}
