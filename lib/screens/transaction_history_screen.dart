import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'receipt_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
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
        backgroundColor: Colors.teal.shade800,
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
            onPressed: () {},
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
            tooltip: 'Export',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: transactionProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : transactionProvider.transactions.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactionProvider.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactionProvider.transactions[index];
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
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.receipt, color: Colors.blue.shade600),
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