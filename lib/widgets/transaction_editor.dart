import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/investor.dart';
import '../models/investment_round.dart';
import '../models/convertible_instrument.dart';
import '../providers/cap_table_provider.dart';
import '../utils/helpers.dart';
import 'avatars.dart';
import 'dialogs.dart';

/// Centralized transaction editing service
///
/// This provides a single entry point for editing any transaction type,
/// routing to the appropriate dialog based on transaction type.
///
/// Usage:
/// ```dart
/// final result = await TransactionEditor.edit(
///   context: context,
///   transaction: transaction,
///   provider: provider,
/// );
/// if (result == true) {
///   setState(() {}); // Refresh
/// }
/// ```
class TransactionEditor {
  /// Edit a transaction using the appropriate dialog for its type
  ///
  /// Returns true if the transaction was modified/deleted, false if cancelled
  static Future<bool> edit({
    required BuildContext context,
    required Transaction transaction,
    required CapTableProvider provider,
    Investor? investor,
    InvestmentRound? round,
  }) async {
    // Get investor if not provided
    investor ??= provider.getInvestorById(transaction.investorId);

    switch (transaction.type) {
      case TransactionType.conversion:
        return await _showUndoConversionDialog(
          context: context,
          transaction: transaction,
          provider: provider,
          investor: investor,
        );

      case TransactionType.secondarySale:
      case TransactionType.buyback:
        return await _showSellTransactionDialog(
          context: context,
          transaction: transaction,
          provider: provider,
          investor: investor,
        );

      case TransactionType.purchase:
        if (round != null) {
          return await _showRoundInvestmentDialog(
            context: context,
            transaction: transaction,
            provider: provider,
            round: round,
          );
        }
        return await _showGenericEditDialog(
          context: context,
          transaction: transaction,
          provider: provider,
        );

      case TransactionType.secondaryPurchase:
      case TransactionType.optionExercise:
      case TransactionType.reequitization:
      default:
        return await _showGenericEditDialog(
          context: context,
          transaction: transaction,
          provider: provider,
        );
    }
  }

  /// Show the undo conversion dialog for conversion transactions
  static Future<bool> _showUndoConversionDialog({
    required BuildContext context,
    required Transaction transaction,
    required CapTableProvider provider,
    Investor? investor,
  }) async {
    final shareClass = provider.getShareClassById(transaction.shareClassId);

    // Find the convertible that was converted
    final convertible = provider.convertibles
        .where(
          (c) =>
              c.status == ConvertibleStatus.converted &&
              c.investorId == transaction.investorId &&
              c.conversionRoundId == transaction.roundId &&
              c.conversionShares == transaction.numberOfShares,
        )
        .firstOrNull;

    if (convertible == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not find the original convertible instrument'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _UndoConversionDialog(
        transaction: transaction,
        convertible: convertible,
        provider: provider,
        investor: investor,
        shareClass: shareClass,
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversion undone successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    return result ?? false;
  }

  /// Show the sell shares dialog for secondary sales and buybacks
  static Future<bool> _showSellTransactionDialog({
    required BuildContext context,
    required Transaction transaction,
    required CapTableProvider provider,
    Investor? investor,
  }) async {
    if (investor == null) return false;

    final currentShares = provider.getCurrentSharesByInvestor(investor.id);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SellSharesDialog(
        investor: investor,
        provider: provider,
        maxShares:
            currentShares +
            transaction.numberOfShares, // Add back the sold shares
        existingTransaction: transaction,
      ),
    );

    return result ?? false;
  }

  /// Show generic edit dialog for purchases and other transactions
  static Future<bool> _showGenericEditDialog({
    required BuildContext context,
    required Transaction transaction,
    required CapTableProvider provider,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => GenericTransactionEditDialog(
        transaction: transaction,
        provider: provider,
      ),
    );

    return result ?? false;
  }

  /// Show round investment edit dialog
  static Future<bool> _showRoundInvestmentDialog({
    required BuildContext context,
    required Transaction transaction,
    required CapTableProvider provider,
    required InvestmentRound round,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RoundInvestmentEditDialog(
        transaction: transaction,
        round: round,
        provider: provider,
      ),
    );

    return result ?? false;
  }
}

/// Dialog for undoing a conversion
class _UndoConversionDialog extends StatelessWidget {
  final Transaction transaction;
  final ConvertibleInstrument convertible;
  final CapTableProvider provider;
  final Investor? investor;
  final dynamic shareClass;

  const _UndoConversionDialog({
    required this.transaction,
    required this.convertible,
    required this.provider,
    this.investor,
    this.shareClass,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Undo Conversion'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InvestorAvatar(
                        name: investor?.name ?? '?',
                        type: investor?.type,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        investor?.name ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Type: ${convertible.typeDisplayName}'),
                  Text(
                    'Principal: ${Formatters.currency(convertible.principalAmount)}',
                  ),
                  Text(
                    'Shares: ${Formatters.number(transaction.numberOfShares)}',
                  ),
                  Text('Class: ${shareClass?.name ?? "Unknown"}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Undoing will remove the conversion transaction and restore this instrument to outstanding status.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () async {
            final success = await provider.undoConversion(convertible.id);
            if (context.mounted) {
              Navigator.pop(context, success);
            }
          },
          icon: const Icon(Icons.undo),
          label: const Text('Undo Conversion'),
        ),
      ],
    );
  }
}

/// Public dialog for selling shares (can be used for create or edit)
class SellSharesDialog extends StatefulWidget {
  final Investor investor;
  final CapTableProvider provider;
  final int maxShares;
  final Transaction? existingTransaction;

  const SellSharesDialog({
    super.key,
    required this.investor,
    required this.provider,
    required this.maxShares,
    this.existingTransaction,
  });

  @override
  State<SellSharesDialog> createState() => _SellSharesDialogState();
}

/// Sale type options
enum SaleType { secondary, buyback, exit, partial }

class _SellSharesDialogState extends State<SellSharesDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sharesController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  SaleType _saleType = SaleType.secondary;
  late DateTime _saleDate;
  String? _buyerInvestorId;
  String? _selectedShareClassId;

  bool get isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingTransaction;
    if (existing != null) {
      // Editing mode - populate from existing transaction
      _sharesController.text = existing.numberOfShares.toString();
      _priceController.text = existing.pricePerShare.toStringAsFixed(2);
      _notesController.text = existing.notes ?? '';
      _saleDate = existing.date;
      _selectedShareClassId = existing.shareClassId;

      // Determine sale type from transaction type
      if (existing.type == TransactionType.secondarySale) {
        _saleType = SaleType.secondary;
        // Find the buyer from related transaction
        if (existing.relatedTransactionId != null) {
          final relatedTxn = widget.provider.getTransactionById(
            existing.relatedTransactionId!,
          );
          if (relatedTxn != null) {
            _buyerInvestorId = relatedTxn.investorId;
          }
        }
      } else if (existing.type == TransactionType.buyback) {
        _saleType = SaleType.buyback;
      }
    } else {
      // Creating new - default to latest share price
      _priceController.text = widget.provider.latestSharePrice.toStringAsFixed(
        2,
      );

      // Get available share classes from holdings
      final acquisitions = widget.provider.getAcquisitionsByInvestor(
        widget.investor.id,
      );
      if (acquisitions.isNotEmpty) {
        _selectedShareClassId = acquisitions.first.shareClassId;
      }

      // Default sale date to today or latest transaction date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final latestTxnDate = _getLatestTransactionDate();
      _saleDate = latestTxnDate != null && latestTxnDate.isAfter(today)
          ? latestTxnDate
          : today;
    }
  }

  DateTime? _getLatestTransactionDate() {
    final acquisitions = widget.provider.getAcquisitionsByInvestor(
      widget.investor.id,
    );
    if (acquisitions.isEmpty) return null;
    final latest = acquisitions
        .map((t) => t.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return DateTime(latest.year, latest.month, latest.day);
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _availableSharesAtDate {
    if (_selectedShareClassId == null) {
      return widget.provider.getSharesAtDate(widget.investor.id, _saleDate);
    }
    return widget.provider.getSharesAtDateByClass(
      widget.investor.id,
      _selectedShareClassId!,
      _saleDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final acquisitions = widget.provider.getAcquisitionsByInvestor(
      widget.investor.id,
    );
    final shareClassIds = acquisitions.map((t) => t.shareClassId).toSet();
    final otherInvestors = widget.provider.investors
        .where((i) => i.id != widget.investor.id)
        .toList();

    return AlertDialog(
      title: Text(
        isEditing
            ? 'Edit Sale - ${widget.investor.name}'
            : 'Sell Shares - ${widget.investor.name}',
      ),
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
                          _sharesController.text = _availableSharesAtDate
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
                        'Available: ${Formatters.number(_availableSharesAtDate)}',
                    suffixIcon: TextButton(
                      onPressed: () {
                        _sharesController.text = _availableSharesAtDate
                            .toString();
                      },
                      child: const Text('All'),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final shares = int.tryParse(value);
                    if (shares == null || shares <= 0) return 'Invalid number';
                    if (shares > _availableSharesAtDate) {
                      return 'Exceeds available shares';
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
                        'Current: ${Formatters.currency(widget.provider.latestSharePrice)}/share',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) return 'Invalid price';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sale Date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _saleDate,
                      firstDate: DateTime(1950),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _saleDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Sale Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(Formatters.date(_saleDate)),
                  ),
                ),

                // Buyer (for secondary sales)
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
                              'No other investors available.',
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
                      onChanged: (value) =>
                          setState(() => _buyerInvestorId = value),
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
        if (isEditing)
          TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        FilledButton(
          onPressed: _save,
          child: Text(isEditing ? 'Save Changes' : 'Record Sale'),
        ),
      ],
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedShareClassId == null) return;

    if (_saleType == SaleType.secondary && _buyerInvestorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a buyer')));
      return;
    }

    final shares = int.parse(_sharesController.text);
    final price = double.parse(_priceController.text);
    final notes = _notesController.text.isEmpty ? null : _notesController.text;

    if (isEditing) {
      await widget.provider.deleteTransaction(widget.existingTransaction!.id);
    }

    if (_saleType == SaleType.secondary && _buyerInvestorId != null) {
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
      widget.provider.recordBuyback(
        investorId: widget.investor.id,
        shareClassId: _selectedShareClassId!,
        numberOfShares: shares,
        pricePerShare: price,
        date: _saleDate,
        notes: notes,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Sale updated' : 'Sale recorded')),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Sale',
      message: 'Are you sure you want to delete this sale?',
    );

    if (confirmed && widget.existingTransaction != null) {
      await widget.provider.deleteTransaction(widget.existingTransaction!.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sale deleted')));
      }
    }
  }
}

/// Generic transaction edit dialog for simple transactions
class GenericTransactionEditDialog extends StatefulWidget {
  final Transaction transaction;
  final CapTableProvider provider;

  const GenericTransactionEditDialog({
    super.key,
    required this.transaction,
    required this.provider,
  });

  @override
  State<GenericTransactionEditDialog> createState() =>
      _GenericTransactionEditDialogState();
}

class _GenericTransactionEditDialogState
    extends State<GenericTransactionEditDialog> {
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

                TextFormField(
                  controller: _sharesController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Shares',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final shares = int.tryParse(value);
                    if (shares == null || shares <= 0) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                    if (value == null || value.isEmpty) return 'Required';
                    final price = double.tryParse(value);
                    if (price == null || price < 0) return 'Invalid price';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (widget.transaction.roundId == null) ...[
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
                ] else ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(Formatters.date(_date)),
                    trailing: Tooltip(
                      message: 'Date is set by the investment round',
                      child: Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

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
        TextButton(
          onPressed: _delete,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
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

    final updated = widget.transaction.copyWith(
      numberOfShares: shares,
      pricePerShare: price,
      totalAmount: shares * price,
      date: _date,
      notes: notes,
    );

    await widget.provider.deleteTransaction(widget.transaction.id);
    await widget.provider.addTransaction(updated);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction updated')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Transaction',
      message:
          'Are you sure you want to delete this ${widget.transaction.typeDisplayName.toLowerCase()}?',
    );

    if (confirmed) {
      await widget.provider.deleteTransaction(widget.transaction.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      }
    }
  }
}

/// Dialog for editing investments in a round
class RoundInvestmentEditDialog extends StatefulWidget {
  final Transaction transaction;
  final InvestmentRound round;
  final CapTableProvider provider;

  const RoundInvestmentEditDialog({
    super.key,
    required this.transaction,
    required this.round,
    required this.provider,
  });

  @override
  State<RoundInvestmentEditDialog> createState() =>
      _RoundInvestmentEditDialogState();
}

class _RoundInvestmentEditDialogState extends State<RoundInvestmentEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sharesController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;

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
    final investor = widget.provider.getInvestorById(
      widget.transaction.investorId,
    );

    return AlertDialog(
      title: Text('Edit Investment - ${investor?.name ?? "Unknown"}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business_center, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.round.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _sharesController,
                decoration: const InputDecoration(
                  labelText: 'Number of Shares',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final shares = int.tryParse(value);
                  if (shares == null || shares <= 0) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

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
                  if (value == null || value.isEmpty) return 'Required';
                  final price = double.tryParse(value);
                  if (price == null || price < 0) return 'Invalid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),

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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _delete,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
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

    final updated = widget.transaction.copyWith(
      numberOfShares: shares,
      pricePerShare: price,
      totalAmount: shares * price,
      notes: notes,
    );

    await widget.provider.deleteTransaction(widget.transaction.id);
    await widget.provider.addTransaction(updated);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Investment updated')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Investment',
      message: 'Are you sure you want to delete this investment?',
    );

    if (confirmed) {
      await widget.provider.deleteTransaction(widget.transaction.id);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Investment deleted')));
      }
    }
  }
}
