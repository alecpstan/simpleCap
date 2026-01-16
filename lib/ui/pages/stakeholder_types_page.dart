import 'package:flutter/material.dart';

/// Page for viewing stakeholder type templates.
///
/// Shows the available stakeholder types with their default
/// configurations and typical use cases.
class StakeholderTypesPage extends StatelessWidget {
  const StakeholderTypesPage({super.key});

  static const List<_StakeholderTypeInfo> _defaultTypes = [
    _StakeholderTypeInfo(
      id: 'founder',
      name: 'Founder',
      icon: Icons.star,
      color: Colors.indigo,
      description: 'Company founders and co-founders',
      typicalRights: ['Voting rights', 'Board seat', 'Vesting schedule'],
    ),
    _StakeholderTypeInfo(
      id: 'employee',
      name: 'Employee',
      icon: Icons.badge,
      color: Colors.teal,
      description: 'Full-time and part-time employees',
      typicalRights: ['Option grants', 'Vesting schedule', 'Exercise rights'],
    ),
    _StakeholderTypeInfo(
      id: 'investor',
      name: 'Investor',
      icon: Icons.account_balance,
      color: Colors.green,
      description: 'General investor category',
      typicalRights: ['Equity ownership', 'Dividends', 'Information rights'],
    ),
    _StakeholderTypeInfo(
      id: 'angel',
      name: 'Angel Investor',
      icon: Icons.account_balance,
      color: Colors.green,
      description: 'Individual early-stage investors',
      typicalRights: ['Equity/SAFE', 'Pro-rata rights', 'Information rights'],
    ),
    _StakeholderTypeInfo(
      id: 'vcFund',
      name: 'VC Fund',
      icon: Icons.business_center,
      color: Colors.blue,
      description: 'Venture capital funds and institutional investors',
      typicalRights: [
        'Board seat',
        'Pro-rata rights',
        'Anti-dilution',
        'Liquidation preference',
      ],
    ),
    _StakeholderTypeInfo(
      id: 'institution',
      name: 'Institution',
      icon: Icons.apartment,
      color: Colors.deepPurple,
      description: 'Banks, superannuation funds, and other institutions',
      typicalRights: [
        'Preferred shares',
        'Liquidation preference',
        'Information rights',
      ],
    ),
    _StakeholderTypeInfo(
      id: 'advisor',
      name: 'Advisor',
      icon: Icons.lightbulb,
      color: Colors.orange,
      description: 'Strategic advisors and consultants',
      typicalRights: ['Advisory shares', 'Vesting schedule', 'Option grants'],
    ),
    _StakeholderTypeInfo(
      id: 'company',
      name: 'Company',
      icon: Icons.business,
      color: Colors.blueGrey,
      description: 'Corporate entities and strategic partners',
      typicalRights: ['Equity ownership', 'Strategic partnership rights'],
    ),
    _StakeholderTypeInfo(
      id: 'other',
      name: 'Other',
      icon: Icons.person,
      color: Colors.grey,
      description: 'Other stakeholder types not covered above',
      typicalRights: ['Varies by arrangement'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stakeholder Types')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _defaultTypes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Default stakeholder types and their typical rights. '
                'Use these when adding stakeholders to categorize them appropriately.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            );
          }
          return _buildTypeCard(context, _defaultTypes[index - 1]);
        },
      ),
    );
  }

  Widget _buildTypeCard(BuildContext context, _StakeholderTypeInfo type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: type.color.withValues(alpha: 0.2),
          child: Icon(type.icon, color: type.color),
        ),
        title: Text(
          type.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(type.description),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Typical Rights & Benefits',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: type.typicalRights
                      .map((right) => Chip(
                            label: Text(right),
                            backgroundColor: type.color.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              color: type.color,
                              fontSize: 12,
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StakeholderTypeInfo {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> typicalRights;

  const _StakeholderTypeInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.typicalRights,
  });
}
