import 'package:uuid/uuid.dart';

enum SaleType {
  secondary, // Sale to another investor
  buyback, // Company buys back shares
  exit, // Full exit (acquisition, IPO)
  partial, // Partial sale
}

class ShareSale {
  final String id;
  String investorId;
  String? buyerInvestorId; // If sold to another investor in the cap table
  String shareClassId;
  String? roundId; // The round before which this sale occurred (optional)
  int numberOfShares;
  double pricePerShare;
  double totalProceeds;
  DateTime saleDate;
  SaleType type;
  String? notes;

  ShareSale({
    String? id,
    required this.investorId,
    this.buyerInvestorId,
    required this.shareClassId,
    this.roundId,
    required this.numberOfShares,
    required this.pricePerShare,
    double? totalProceeds,
    DateTime? saleDate,
    this.type = SaleType.secondary,
    this.notes,
  }) : id = id ?? const Uuid().v4(),
       totalProceeds = totalProceeds ?? (numberOfShares * pricePerShare),
       saleDate = saleDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'investorId': investorId,
    'buyerInvestorId': buyerInvestorId,
    'shareClassId': shareClassId,
    'roundId': roundId,
    'numberOfShares': numberOfShares,
    'pricePerShare': pricePerShare,
    'totalProceeds': totalProceeds,
    'saleDate': saleDate.toIso8601String(),
    'type': type.index,
    'notes': notes,
  };

  factory ShareSale.fromJson(Map<String, dynamic> json) => ShareSale(
    id: json['id'],
    investorId: json['investorId'],
    buyerInvestorId: json['buyerInvestorId'],
    shareClassId: json['shareClassId'],
    roundId: json['roundId'],
    numberOfShares: json['numberOfShares'],
    pricePerShare: (json['pricePerShare'] ?? 0).toDouble(),
    totalProceeds: (json['totalProceeds'] ?? 0).toDouble(),
    saleDate: DateTime.parse(json['saleDate']),
    type: SaleType.values[json['type'] ?? 0],
    notes: json['notes'],
  );

  ShareSale copyWith({
    String? investorId,
    String? buyerInvestorId,
    String? shareClassId,
    String? roundId,
    int? numberOfShares,
    double? pricePerShare,
    double? totalProceeds,
    DateTime? saleDate,
    SaleType? type,
    String? notes,
  }) {
    return ShareSale(
      id: id,
      investorId: investorId ?? this.investorId,
      buyerInvestorId: buyerInvestorId ?? this.buyerInvestorId,
      shareClassId: shareClassId ?? this.shareClassId,
      roundId: roundId ?? this.roundId,
      numberOfShares: numberOfShares ?? this.numberOfShares,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      totalProceeds: totalProceeds ?? this.totalProceeds,
      saleDate: saleDate ?? this.saleDate,
      type: type ?? this.type,
      notes: notes ?? this.notes,
    );
  }
}
