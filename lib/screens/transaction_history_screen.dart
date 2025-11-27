import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'receipt_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedPaymentMethod;

  List<String> get paymentMethods {
    final methods = Provider.of<TransactionProvider>(context, listen: false).transactions.map((t) => t.paymentMethod).toSet().toList();
    methods.sort();
    return methods;
  }

  List<Transaction> get filteredTransactions {
    var filtered = Provider.of<TransactionProvider>(context).transactions;
    if (startDate != null && endDate != null) {
      filtered = filtered.where((t) => t.date.isAfter(startDate!.subtract(const Duration(days: 1))) && t.date.isBefore(endDate!.add(const Duration(days: 1)))).toList();
    }
    if (selectedPaymentMethod != null && selectedPaymentMethod != 'All') {
      filtered = filtered.where((t) => t.paymentMethod == selectedPaymentMethod).toList();
    }
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => startDate = date);
                        }
                      },
                      child: Text(startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : 'Start Date'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => endDate = date);
                        }
                      },
                      child: Text(endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : 'End Date'),
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: selectedPaymentMethod,
                hint: const Text('Payment Method'),
                items: ['All', ...paymentMethods].map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                onChanged: (value) => setState(() => selectedPaymentMethod = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                  selectedPaymentMethod = null;
                });
                Navigator.pop(context);
                this.setState(() {});
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                this.setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToCsv() async {
    final transactions = filteredTransactions;
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No transactions to export')));
      return;
    }
    final csvData = [
      ['Date', 'Payment Method', 'Customer', 'Subtotal', 'Discount', 'Total', 'Items'],
      ...transactions.map((t) => [
        DateFormat('yyyy-MM-dd HH:mm').format(t.date),
        t.paymentMethod,
        t.customerName ?? '',
        t.subtotal.toString(),
        t.discountAmount.toString(),
        t.totalAmount.toString(),
        t.items.map((i) => '${i.product.name} x${i.quantity}').join('; '),
      ]),
    ];
    final csv = const ListToCsvConverter().convert(csvData);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Transaction History Export');
  }

  void _showTransactionDetail(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Detail'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(transaction.date)}'),
              Text('Payment: ${transaction.paymentMethod}'),
              if (transaction.customerName != null)
                Text('Customer: ${transaction.customerName}'),
              Text('Subtotal: Rp ${NumberFormat('#,###').format(transaction.subtotal)}'),
              if (transaction.discountAmount > 0)
                Text('Discount: -Rp ${NumberFormat('#,###').format(transaction.discountAmount)}'),
              Text(
                'Total: Rp ${NumberFormat('#,###').format(transaction.totalAmount)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...transaction.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.product.name} (x${item.quantity})'),
                    ),
                    Text('Rp ${NumberFormat('#,###').format(item.totalPrice)}'),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.pink.shade100,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCsv,
            tooltip: 'Export',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: transactionProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredTransactions.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(transaction.date),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${transaction.items.length} items • ${transaction.paymentMethod}'),
                              if (transaction.customerName != null)
                                Text('Customer: ${transaction.customerName}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Rp ${NumberFormat('#,###').format(transaction.totalAmount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.pink.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.receipt, color: Colors.pink.shade600),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReceiptScreen(transaction: transaction),
                                    ),
                                  );
                                },
                                tooltip: 'View Receipt',
                              ),
                            ],
                          ),
                          onTap: () => _showTransactionDetail(transaction),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}