import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../models/cart_item.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getStringList('transactions') ?? [];

      _transactions = transactionsJson
          .map((json) => Transaction.fromJson(jsonDecode(json)))
          .toList();

      // Sort by date (newest first)
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.insert(0, transaction); // Add to beginning for newest first

    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = _transactions
          .map((t) => jsonEncode(t.toJson()))
          .toList();

      await prefs.setStringList('transactions', transactionsJson);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving transaction: $e');
      // Remove from list if save failed
      _transactions.removeAt(0);
    }
  }

  Future<Transaction> createTransactionFromCart({
    required List<CartItem> items,
    required double subtotal,
    required double discountAmount,
    required double totalAmount,
    required String paymentMethod,
    String? customerName,
  }) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: List.from(items), // Create a copy
      subtotal: subtotal,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      customerName: customerName,
    );

    await addTransaction(transaction);
    return transaction;
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(start.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalRevenue([DateTime? startDate, DateTime? endDate]) {
    final filteredTransactions = startDate != null && endDate != null
        ? getTransactionsByDateRange(startDate, endDate)
        : _transactions;

    return filteredTransactions.fold(0.0, (sum, transaction) => sum + transaction.totalAmount);
  }

  int getTransactionCount([DateTime? startDate, DateTime? endDate]) {
    final filteredTransactions = startDate != null && endDate != null
        ? getTransactionsByDateRange(startDate, endDate)
        : _transactions;

    return filteredTransactions.length;
  }

  Map<String, double> getRevenueByPaymentMethod([DateTime? startDate, DateTime? endDate]) {
    final filteredTransactions = startDate != null && endDate != null
        ? getTransactionsByDateRange(startDate, endDate)
        : _transactions;

    final revenueByMethod = <String, double>{};

    for (final transaction in filteredTransactions) {
      revenueByMethod[transaction.paymentMethod] =
          (revenueByMethod[transaction.paymentMethod] ?? 0) + transaction.totalAmount;
    }

    return revenueByMethod;
  }

  Future<void> clearAllTransactions() async {
    _transactions.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('transactions');
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing transactions: $e');
    }
  }
}