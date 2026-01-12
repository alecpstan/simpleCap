import 'package:uuid/uuid.dart';

enum InvestorType {
  founder,
  angel,
  vcFund,
  employee,
  advisor,
  institution,
  other,
}

class Investor {
  final String id;
  String name;
  InvestorType type;
  String? email;
  String? phone;
  String? company;
  bool hasProRataRights;
  String? notes;
  DateTime createdAt;

  Investor({
    String? id,
    required this.name,
    required this.type,
    this.email,
    this.phone,
    this.company,
    this.hasProRataRights = false,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'email': email,
    'phone': phone,
    'company': company,
    'hasProRataRights': hasProRataRights,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Investor.fromJson(Map<String, dynamic> json) => Investor(
    id: json['id'],
    name: json['name'],
    type: InvestorType.values[json['type']],
    email: json['email'],
    phone: json['phone'],
    company: json['company'],
    hasProRataRights: json['hasProRataRights'] ?? false,
    notes: json['notes'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  String get typeDisplayName {
    switch (type) {
      case InvestorType.founder:
        return 'Founder';
      case InvestorType.angel:
        return 'Angel Investor';
      case InvestorType.vcFund:
        return 'VC Fund';
      case InvestorType.employee:
        return 'Employee';
      case InvestorType.advisor:
        return 'Advisor';
      case InvestorType.institution:
        return 'Institution';
      case InvestorType.other:
        return 'Other';
    }
  }

  Investor copyWith({
    String? name,
    InvestorType? type,
    String? email,
    String? phone,
    String? company,
    bool? hasProRataRights,
    String? notes,
  }) {
    return Investor(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      hasProRataRights: hasProRataRights ?? this.hasProRataRights,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
