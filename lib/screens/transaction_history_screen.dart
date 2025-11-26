import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final DateTime date;
  final double total;
  final List<String> products;

  Transaction({
    required this.id,
    required this.date,
    required this.total,
    required this.products,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      total: json['total'].toDouble(),
      products: List<String>.from(json['products']),
    );
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://api.example.com/transactions'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _transactions = data.map((json) => Transaction.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTransactionDetail(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(transaction.date)}'),
            Text('Total: \$${transaction.total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...transaction.products.map((product) => Text('• $product')),
          ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return ListTile(
                      title: Text(DateFormat('yyyy-MM-dd HH:mm').format(transaction.date)),
                      subtitle: Text('${transaction.products.length} items'),
                      trailing: Text('\$${transaction.total.toStringAsFixed(2)}'),
                      onTap: () => _showTransactionDetail(transaction),
                    );
                  },
                ),
    );
  }
}