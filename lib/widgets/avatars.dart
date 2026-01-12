import 'package:flutter/material.dart';
import '../models/investor.dart';
import '../models/investment_round.dart';

/// Avatar for an investor showing their initial
class InvestorAvatar extends StatelessWidget {
  final String name;
  final InvestorType? type;
  final double radius;

  const InvestorAvatar({
    super.key,
    required this.name,
    this.type,
    this.radius = 20,
  });

  Color get backgroundColor {
    if (type == null) return Colors.grey;
    switch (type!) {
      case InvestorType.founder:
        return Colors.purple;
      case InvestorType.angel:
        return Colors.amber.shade700;
      case InvestorType.vcFund:
        return Colors.blue;
      case InvestorType.employee:
        return Colors.green;
      case InvestorType.advisor:
        return Colors.teal;
      case InvestorType.institution:
        return Colors.indigo;
      case InvestorType.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Avatar for an investment round showing its order number
class RoundAvatar extends StatelessWidget {
  final int order;
  final RoundType type;
  final double radius;

  const RoundAvatar({
    super.key,
    required this.order,
    required this.type,
    this.radius = 20,
  });

  Color get backgroundColor {
    switch (type) {
      case RoundType.incorporation:
        return Colors.grey;
      case RoundType.seed:
        return Colors.green;
      case RoundType.seriesA:
        return Colors.blue;
      case RoundType.seriesB:
        return Colors.purple;
      case RoundType.seriesC:
        return Colors.orange;
      case RoundType.seriesD:
        return Colors.red;
      case RoundType.bridge:
        return Colors.amber;
      case RoundType.convertible:
        return Colors.teal;
      case RoundType.esopPool:
        return Colors.indigo;
      case RoundType.secondary:
        return Colors.brown;
      case RoundType.custom:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        '$order',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
