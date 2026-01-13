import 'package:uuid/uuid.dart';

/// Represents all types of share movements in the cap table.
/// This unified model allows chronological tracking of share ownership,
/// correctly handling scenarios like: buy -> sell (exit) -> buy again.
enum TransactionType {
  /// Shares acquired through an investment round
  purchase,

  /// Shares sold via secondary sale (to another investor in the cap table)
  secondarySale,

  /// Shares bought back by the company
  buyback,

  /// Shares received via transfer from another investor (secondary purchase)
  secondaryPurchase,

  /// Founder/initial shares issued
  grant,

  /// ESOP/option exercise
  optionExercise,
}

class Transaction {
  final String id;

  /// The investor this transaction affects
  final String investorId;

  /// The share class involved
  final String shareClassId;

  /// The investment round (for purchases) or null for secondary transactions
  final String? roundId;

  /// Type of transaction
  final TransactionType type;

  /// Number of shares (always positive - type determines add/subtract)
  final int numberOfShares;

  /// Price per share at time of transaction
  final double pricePerShare;

  /// Total amount (shares * price)
  final double totalAmount;

  /// Date of transaction - critical for chronological ordering
  final DateTime date;

  /// For secondary sales: the investor buying the shares
  /// For secondary purchases: the investor selling the shares
  final String? counterpartyInvestorId;

  /// Reference to related transaction (e.g., sale links to purchase by buyer)
  final String? relatedTransactionId;

  /// Optional notes
  final String? notes;

  Transaction({
    String? id,
    required this.investorId,
    required this.shareClassId,
    this.roundId,
    required this.type,
    required this.numberOfShares,
    required this.pricePerShare,
    double? totalAmount,
    required this.date,
    this.counterpartyInvestorId,
    this.relatedTransactionId,
    this.notes,
  }) : id = id ?? const Uuid().v4(),
       totalAmount = totalAmount ?? (numberOfShares * pricePerShare);

  /// Whether this transaction adds shares to the investor's holdings
  bool get isAcquisition =>
      type == TransactionType.purchase ||
      type == TransactionType.secondaryPurchase ||
      type == TransactionType.grant ||
      type == TransactionType.optionExercise;

  /// Whether this transaction removes shares from the investor's holdings
  bool get isDisposal =>
      type == TransactionType.secondarySale || type == TransactionType.buyback;

  /// The net effect on share count (positive for acquisitions, negative for disposals)
  int get sharesDelta => isAcquisition ? numberOfShares : -numberOfShares;

  Map<String, dynamic> toJson() => {
    'id': id,
    'investorId': investorId,
    'shareClassId': shareClassId,
    'roundId': roundId,
    'type': type.index,
    'numberOfShares': numberOfShares,
    'pricePerShare': pricePerShare,
    'totalAmount': totalAmount,
    'date': date.toIso8601String(),
    'counterpartyInvestorId': counterpartyInvestorId,
    'relatedTransactionId': relatedTransactionId,
    'notes': notes,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    investorId: json['investorId'],
    shareClassId: json['shareClassId'],
    roundId: json['roundId'],
    type: TransactionType.values[json['type']],
    numberOfShares: json['numberOfShares'],
    pricePerShare: (json['pricePerShare'] ?? 0).toDouble(),
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    date: DateTime.parse(json['date']),
    counterpartyInvestorId: json['counterpartyInvestorId'],
    relatedTransactionId: json['relatedTransactionId'],
    notes: json['notes'],
  );

  Transaction copyWith({
    String? investorId,
    String? shareClassId,
    String? roundId,
    TransactionType? type,
    int? numberOfShares,
    double? pricePerShare,
    double? totalAmount,
    DateTime? date,
    String? counterpartyInvestorId,
    String? relatedTransactionId,
    String? notes,
  }) {
    return Transaction(
      id: id,
      investorId: investorId ?? this.investorId,
      shareClassId: shareClassId ?? this.shareClassId,
      roundId: roundId ?? this.roundId,
      type: type ?? this.type,
      numberOfShares: numberOfShares ?? this.numberOfShares,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      counterpartyInvestorId:
          counterpartyInvestorId ?? this.counterpartyInvestorId,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      notes: notes ?? this.notes,
    );
  }

  /// Creates a purchase transaction from an investment round
  factory Transaction.fromPurchase({
    required String investorId,
    required String shareClassId,
    required String roundId,
    required int numberOfShares,
    required double pricePerShare,
    required DateTime date,
    String? notes,
  }) {
    return Transaction(
      investorId: investorId,
      shareClassId: shareClassId,
      roundId: roundId,
      type: TransactionType.purchase,
      numberOfShares: numberOfShares,
      pricePerShare: pricePerShare,
      date: date,
      notes: notes,
    );
  }

  /// Creates a pair of transactions for a secondary sale (seller -> buyer)
  static List<Transaction> createSecondarySale({
    required String sellerId,
    required String buyerId,
    required String shareClassId,
    required int numberOfShares,
    required double pricePerShare,
    required DateTime date,
    String? notes,
  }) {
    final saleId = const Uuid().v4();
    final purchaseId = const Uuid().v4();

    final sale = Transaction(
      id: saleId,
      investorId: sellerId,
      shareClassId: shareClassId,
      type: TransactionType.secondarySale,
      numberOfShares: numberOfShares,
      pricePerShare: pricePerShare,
      date: date,
      counterpartyInvestorId: buyerId,
      relatedTransactionId: purchaseId,
      notes: notes,
    );

    final purchase = Transaction(
      id: purchaseId,
      investorId: buyerId,
      shareClassId: shareClassId,
      type: TransactionType.secondaryPurchase,
      numberOfShares: numberOfShares,
      pricePerShare: pricePerShare,
      date: date,
      counterpartyInvestorId: sellerId,
      relatedTransactionId: saleId,
      notes: notes,
    );

    return [sale, purchase];
  }

  /// Creates a buyback transaction (shares returned to company)
  factory Transaction.fromBuyback({
    required String investorId,
    required String shareClassId,
    required int numberOfShares,
    required double pricePerShare,
    required DateTime date,
    String? notes,
  }) {
    return Transaction(
      investorId: investorId,
      shareClassId: shareClassId,
      type: TransactionType.buyback,
      numberOfShares: numberOfShares,
      pricePerShare: pricePerShare,
      date: date,
      notes: notes,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.purchase:
        return 'Investment';
      case TransactionType.secondarySale:
        return 'Secondary Sale';
      case TransactionType.buyback:
        return 'Buyback';
      case TransactionType.secondaryPurchase:
        return 'Secondary Purchase';
      case TransactionType.grant:
        return 'Share Grant';
      case TransactionType.optionExercise:
        return 'Option Exercise';
    }
  }
}
