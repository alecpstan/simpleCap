import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/investor.dart';
import '../models/share_sale.dart';
import '../models/transaction.dart';
import '../providers/cap_table_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/avatars.dart';
import '../widgets/info_widgets.dart';
import '../widgets/dialogs.dart';
import '../utils/helpers.dart';

class InvestorsPage extends StatelessWidget {
  const InvestorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CapTableProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: provider.investors.isEmpty
              ? const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No investors yet',
                  subtitle: 'Add your first investor to get started',
                )
              : _buildInvestorsList(context, provider),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showInvestorDialog(context, provider),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Investor'),
          ),
        );
      },
    );
  }

  Widget _buildInvestorsList(BuildContext context, CapTableProvider provider) {
    // Sort by ownership percentage descending
    final sortedInvestors = List<Investor>.from(provider.investors)
      ..sort(
        (a, b) => provider
            .getOwnershipPercentage(b.id)
            .compareTo(provider.getOwnershipPercentage(a.id)),
      );

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedInvestors.length,
      itemBuilder: (context, index) {
        final investor = sortedInvestors[index];
        final currentShares = provider.getCurrentSharesByInvestor(investor.id);
        final originalShares = provider.getSharesByInvestor(investor.id);
        final ownership = provider.getOwnershipPercentage(investor.id);
        final invested = provider.getInvestmentByInvestor(investor.id);
        final hasExited = provider.hasInvestorExited(investor.id);
        final hasSoldSome = currentShares < originalShares && currentShares > 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Stack(
              children: [
                InvestorAvatar(name: investor.name, type: investor.type),
                if (hasExited)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.exit_to_app,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Text(investor.name),
                if (hasExited) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'EXITED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ] else if (hasSoldSome) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PARTIAL SALE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(investor.typeDisplayName),
                const SizedBox(height: 4),
                Row(
                  children: [
                    MiniStat(
                      label: 'Shares',
                      value: Formatters.number(currentShares),
                    ),
                    const SizedBox(width: 16),
                    MiniStat(
                      label: 'Ownership',
                      value: Formatters.percent(ownership),
                    ),
                    const SizedBox(width: 16),
                    MiniStat(
                      label: 'Invested',
                      value: Formatters.compactCurrency(invested),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'holdings',
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text('View Holdings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (currentShares > 0)
                  const PopupMenuItem(
                    value: 'sell',
                    child: ListTile(
                      leading: Icon(Icons.sell_outlined),
                      title: Text('Sell Shares'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showInvestorDialog(context, provider, investor: investor);
                    break;
                  case 'holdings':
                    _showHoldingsDialog(context, provider, investor);
                    break;
                  case 'sell':
                    _showSellSharesDialog(context, provider, investor);
                    break;
                  case 'delete':
                    _confirmDelete(context, provider, investor);
                    break;
                }
              },
            ),
            isThreeLine: true,
            onTap: () =>
                _showInvestorDialog(context, provider, investor: investor),
          ),
        );
      },
    );
  }

  Future<void> _showInvestorDialog(
    BuildContext context,
    CapTableProvider provider, {
    Investor? investor,
  }) async {
    final isEditing = investor != null;
    final nameController = TextEditingController(text: investor?.name ?? '');
    final emailController = TextEditingController(text: investor?.email ?? '');
    final phoneController = TextEditingController(text: investor?.phone ?? '');
    final companyController = TextEditingController(
      text: investor?.company ?? '',
    );
    final notesController = TextEditingController(text: investor?.notes ?? '');
    var selectedType = investor?.type ?? InvestorType.angel;
    var hasProRata = investor?.hasProRataRights ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Investor' : 'Add Investor'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? 500
                  : double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'John Smith',
                      prefixIcon: Icon(Icons.person),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<InvestorType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Investor Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: InvestorType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeDisplayName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'john@example.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: '+61 400 000 000',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: companyController,
                    decoration: const InputDecoration(
                      labelText: 'Company/Fund',
                      hintText: 'Acme Ventures',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Pro-rata Rights'),
                    subtitle: const Text(
                      'Can maintain ownership in future rounds',
                    ),
                    value: hasProRata,
                    onChanged: (value) {
                      setState(() => hasProRata = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Additional information...',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final newInvestor = Investor(
        id: investor?.id,
        name: nameController.text,
        type: selectedType,
        email: emailController.text.isEmpty ? null : emailController.text,
        phone: phoneController.text.isEmpty ? null : phoneController.text,
        company: companyController.text.isEmpty ? null : companyController.text,
        hasProRataRights: hasProRata,
        notes: notesController.text.isEmpty ? null : notesController.text,
        createdAt: investor?.createdAt,
      );

      if (isEditing) {
        await provider.updateInvestor(newInvestor);
      } else {
        await provider.addInvestor(newInvestor);
      }
    }
  }

  String _getTypeDisplayName(InvestorType type) {
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

  Future<void> _showHoldingsDialog(
    BuildContext context,
    CapTableProvider provider,
    Investor investor,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => _HoldingsAndTransactionsDialog(
        investor: investor,
        provider: provider,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CapTableProvider provider,
    Investor investor,
  ) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Investor',
      message:
          'Are you sure you want to delete ${investor.name}? '
          'This will also remove all their shareholdings.',
    );

    if (confirmed) {
      await provider.deleteInvestor(investor.id);
    }
  }

  Future<void> _showSellSharesDialog(
    BuildContext context,
    CapTableProvider provider,
    Investor investor,
  ) async {
    final currentShares = provider.getCurrentSharesByInvestor(investor.id);
    if (currentShares <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This investor has no shares to sell')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => _SellSharesDialog(
        investor: investor,
        provider: provider,
        maxShares: currentShares,
      ),
    );
  }
}

class _SellSharesDialog extends StatefulWidget {
  final Investor investor;
  final CapTableProvider provider;
  final int maxShares;

  const _SellSharesDialog({
    required this.investor,
    required this.provider,
    required this.maxShares,
  });

  @override
  State<_SellSharesDialog> createState() => _SellSharesDialogState();
}

class _SellSharesDialogState extends State<_SellSharesDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sharesController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  SaleType _saleType = SaleType.secondary;
  DateTime _saleDate = DateTime.now();
  String? _buyerInvestorId;
  String? _selectedShareClassId;

  @override
  void initState() {
    super.initState();
    // Default to latest share price
    _priceController.text = widget.provider.latestSharePrice.toStringAsFixed(2);

    // Get available share classes from holdings
    final holdings = widget.provider.getShareholdingsByInvestor(
      widget.investor.id,
    );
    if (holdings.isNotEmpty) {
      _selectedShareClassId = holdings.first.shareClassId;
    }
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _availableSharesForClass {
    if (_selectedShareClassId == null) return widget.maxShares;

    // Use the transaction-based method for accurate share counting
    return widget.provider.getCurrentSharesByInvestorAndClass(
      widget.investor.id,
      _selectedShareClassId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final holdings = widget.provider.getShareholdingsByInvestor(
      widget.investor.id,
    );

    // Get unique share classes from holdings
    final shareClassIds = holdings.map((h) => h.shareClassId).toSet();

    // Get other investors as potential buyers
    final otherInvestors = widget.provider.investors
        .where((i) => i.id != widget.investor.id)
        .toList();

    return AlertDialog(
      title: Text('Sell Shares - ${widget.investor.name}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current holdings summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Current shares: ${Formatters.number(widget.maxShares)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sale Type
                DropdownButtonFormField<SaleType>(
                  initialValue: _saleType,
                  decoration: const InputDecoration(
                    labelText: 'Sale Type',
                    border: OutlineInputBorder(),
                  ),
                  items: SaleType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getSaleTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _saleType = value;
                        if (value == SaleType.exit) {
                          // For full exit, default to all shares
                          _sharesController.text = _availableSharesForClass
                              .toString();
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Share Class
                if (shareClassIds.length > 1) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedShareClassId,
                    decoration: const InputDecoration(
                      labelText: 'Share Class',
                      border: OutlineInputBorder(),
                    ),
                    items: shareClassIds.map((id) {
                      final shareClass = widget.provider.getShareClassById(id);
                      return DropdownMenuItem(
                        value: id,
                        child: Text(shareClass?.name ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedShareClassId = value);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Number of shares
                TextFormField(
                  controller: _sharesController,
                  decoration: InputDecoration(
                    labelText: 'Number of Shares',
                    border: const OutlineInputBorder(),
                    helperText:
                        'Available: ${Formatters.number(_availableSharesForClass)}',
                    suffixIcon: TextButton(
                      onPressed: () {
                        _sharesController.text = _availableSharesForClass
                            .toString();
                      },
                      child: const Text('All'),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter number of shares';
                    }
                    final shares = int.tryParse(value);
                    if (shares == null || shares <= 0) {
                      return 'Enter a valid number';
                    }
                    if (shares > _availableSharesForClass) {
                      return 'Cannot exceed ${Formatters.number(_availableSharesForClass)} shares';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price per share
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price per Share',
                    border: const OutlineInputBorder(),
                    prefixText: '\$ ',
                    helperText:
                        'Current valuation: ${Formatters.currency(widget.provider.latestSharePrice)}/share',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter price per share';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sale Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sale Date'),
                  subtitle: Text(Formatters.date(_saleDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _saleDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _saleDate = date);
                    }
                  },
                ),

                // Buyer (required for secondary sales - must be an existing investor)
                if (_saleType == SaleType.secondary) ...[
                  const SizedBox(height: 16),
                  if (otherInvestors.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_outlined,
                            size: 20,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No other investors available. Add the buyer as an investor first.',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _buyerInvestorId,
                      decoration: const InputDecoration(
                        labelText: 'Buyer',
                        border: OutlineInputBorder(),
                        helperText:
                            'Select the investor purchasing these shares',
                      ),
                      items: otherInvestors.map((i) {
                        return DropdownMenuItem(
                          value: i.id,
                          child: Text(i.name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (_saleType == SaleType.secondary && value == null) {
                          return 'Please select a buyer';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() => _buyerInvestorId = value);
                      },
                    ),
                ],

                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Preview
                _buildPreview(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Record Sale')),
      ],
    );
  }

  Widget _buildPreview() {
    final shares = int.tryParse(_sharesController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = shares * price;

    if (shares <= 0 || price <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    // Calculate profit
    final holdings = widget.provider.getShareholdingsByInvestor(
      widget.investor.id,
    );
    final totalShares = holdings.fold(0, (sum, h) => sum + h.numberOfShares);
    final totalCost = holdings.fold(0.0, (sum, h) => sum + h.amountInvested);
    final avgCost = totalShares > 0 ? totalCost / totalShares : 0.0;
    final costBasis = shares * avgCost;
    final profit = total - costBasis;
    final isPositive = profit >= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sale Preview',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Proceeds:'),
              Text(
                Formatters.currency(total),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cost Basis:'),
              Text(Formatters.currency(costBasis)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profit/Loss:'),
              Text(
                '${isPositive ? '+' : ''}${Formatters.currency(profit)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (shares == _availableSharesForClass) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.exit_to_app,
                    size: 16,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Full Exit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSaleTypeLabel(SaleType type) {
    switch (type) {
      case SaleType.secondary:
        return 'Secondary Sale';
      case SaleType.buyback:
        return 'Company Buyback';
      case SaleType.exit:
        return 'Full Exit';
      case SaleType.partial:
        return 'Partial Sale';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedShareClassId == null) return;

    // For secondary sales, buyer is required
    if (_saleType == SaleType.secondary && _buyerInvestorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a buyer for secondary sale'),
        ),
      );
      return;
    }

    final shares = int.parse(_sharesController.text);
    final price = double.parse(_priceController.text);
    final notes = _notesController.text.isEmpty ? null : _notesController.text;

    // Use the new transaction-based system
    if (_saleType == SaleType.secondary && _buyerInvestorId != null) {
      // Secondary sale: creates both sale and purchase transactions
      widget.provider.recordSecondarySale(
        sellerId: widget.investor.id,
        buyerId: _buyerInvestorId!,
        shareClassId: _selectedShareClassId!,
        numberOfShares: shares,
        pricePerShare: price,
        date: _saleDate,
        notes: notes,
      );
    } else {
      // Buyback or exit: shares leave the cap table
      widget.provider.recordBuyback(
        investorId: widget.investor.id,
        shareClassId: _selectedShareClassId!,
        numberOfShares: shares,
        pricePerShare: price,
        date: _saleDate,
        notes: notes,
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recorded sale of ${Formatters.number(shares)} shares for ${Formatters.currency(shares * price)}',
        ),
      ),
    );
  }
}

/// Dialog showing investor's holdings summary and transaction history
class _HoldingsAndTransactionsDialog extends StatefulWidget {
  final Investor investor;
  final CapTableProvider provider;

  const _HoldingsAndTransactionsDialog({
    required this.investor,
    required this.provider,
  });

  @override
  State<_HoldingsAndTransactionsDialog> createState() =>
      _HoldingsAndTransactionsDialogState();
}

class _HoldingsAndTransactionsDialogState
    extends State<_HoldingsAndTransactionsDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;
    final investor = widget.investor;

    // Get current holdings summary
    final currentShares = provider.getCurrentSharesByInvestor(investor.id);
    final totalAcquired = provider.getSharesByInvestor(investor.id);
    final sharesSold = provider.getSharesSoldByInvestor(investor.id);
    final invested = provider.getInvestmentByInvestor(investor.id);
    final currentValue = currentShares * provider.latestSharePrice;
    final ownership = provider.getOwnershipPercentage(investor.id);

    // Get all transactions sorted by date (oldest first)
    final transactions = provider.getTransactionsByInvestor(investor.id);

    return AlertDialog(
      title: Row(
        children: [
          InvestorAvatar(name: investor.name, type: investor.type, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(investor.name),
                Text(
                  'Holdings & Transactions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width > 600 ? 550 : double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Holdings Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          label: 'Current Shares',
                          value: Formatters.number(currentShares),
                          valueColor: theme.colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Ownership',
                          value: Formatters.percent(ownership),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          label: 'Total Invested',
                          value: Formatters.currency(invested),
                        ),
                      ),
                      Expanded(
                        child: _SummaryItem(
                          label: 'Current Value',
                          value: Formatters.currency(currentValue),
                          valueColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (sharesSold > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            label: 'Total Acquired',
                            value: Formatters.number(totalAcquired),
                          ),
                        ),
                        Expanded(
                          child: _SummaryItem(
                            label: 'Shares Sold',
                            value: Formatters.number(sharesSold),
                            valueColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transaction History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${transactions.length} transactions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Transaction List
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    )
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _TransactionListItem(
                          transaction: transaction,
                          provider: provider,
                          onEdit: () => _editTransaction(transaction),
                          onDelete: () => _deleteTransaction(transaction),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditTransactionDialog(
        transaction: transaction,
        provider: widget.provider,
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh the dialog
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Transaction',
      message:
          'Are you sure you want to delete this ${transaction.typeDisplayName.toLowerCase()}? '
          'This cannot be undone.',
    );

    if (confirmed) {
      await widget.provider.deleteTransaction(transaction.id);
      setState(() {}); // Refresh the dialog
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      }
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final CapTableProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionListItem({
    required this.transaction,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareClass = provider.getShareClassById(transaction.shareClassId);
    final round = transaction.roundId != null
        ? provider.getRoundById(transaction.roundId!)
        : null;

    // Determine icon and color based on transaction type
    IconData icon;
    Color color;
    String sign;

    if (transaction.isAcquisition) {
      icon = Icons.add_circle_outline;
      color = Colors.green;
      sign = '+';
    } else {
      icon = Icons.remove_circle_outline;
      color = Colors.red;
      sign = '-';
    }

    // Get counterparty name for secondary transactions
    String? counterpartyName;
    if (transaction.counterpartyInvestorId != null) {
      final counterparty = provider.getInvestorById(
        transaction.counterpartyInvestorId!,
      );
      counterpartyName = counterparty?.name;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaction.typeDisplayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        Formatters.date(transaction.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sign${Formatters.number(transaction.numberOfShares)} shares @ ${Formatters.currency(transaction.pricePerShare)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${shareClass?.name ?? 'Unknown Class'}${round != null ? ' • ${round.name}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (counterpartyName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      transaction.isAcquisition
                          ? 'From: $counterpartyName'
                          : 'To: $counterpartyName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.outline,
                size: 20,
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outlined, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for editing a transaction
class _EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final CapTableProvider provider;

  const _EditTransactionDialog({
    required this.transaction,
    required this.provider,
  });

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sharesController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _sharesController = TextEditingController(
      text: widget.transaction.numberOfShares.toString(),
    );
    _priceController = TextEditingController(
      text: widget.transaction.pricePerShare.toStringAsFixed(2),
    );
    _notesController = TextEditingController(
      text: widget.transaction.notes ?? '',
    );
    _date = widget.transaction.date;
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Edit ${widget.transaction.typeDisplayName}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction type info (read-only)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.transaction.isAcquisition
                            ? Icons.add_circle_outline
                            : Icons.remove_circle_outline,
                        color: widget.transaction.isAcquisition
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.transaction.typeDisplayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Number of shares
                TextFormField(
                  controller: _sharesController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Shares',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter number of shares';
                    }
                    final shares = int.tryParse(value);
                    if (shares == null || shares <= 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price per share
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price per Share',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter price per share';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(Formatters.date(_date)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _date = date);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final shares = int.parse(_sharesController.text);
    final price = double.parse(_priceController.text);
    final notes = _notesController.text.isEmpty ? null : _notesController.text;

    // Create updated transaction
    final updated = widget.transaction.copyWith(
      numberOfShares: shares,
      pricePerShare: price,
      totalAmount: shares * price,
      date: _date,
      notes: notes,
    );

    // Delete old and add new (since we don't have an update method)
    await widget.provider.deleteTransaction(widget.transaction.id);
    await widget.provider.addTransaction(updated);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction updated')));
    }
  }
}
