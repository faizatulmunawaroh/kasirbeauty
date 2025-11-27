import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as tx;
import '../models/cart_item.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<tx.Transaction> _transactions = [];
  bool _isLoading = false;

  List<tx.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('transactions').orderBy('date', descending: true).get();
      _transactions = snapshot.docs.map((doc) => tx.Transaction.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(tx.Transaction transaction) async {
    try {
      await _firestore.collection('transactions').add(transaction.toJson());
      _transactions.insert(0, transaction); // Add to beginning for newest first
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving transaction: $e');
    }
  }

  Future<tx.Transaction> createTransactionFromCart({
    required List<CartItem> items,
    required double subtotal,
    required double discountAmount,
    required double totalAmount,
    required String paymentMethod,
    String? customerName,
  }) async {
    final transaction = tx.Transaction(
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

  List<tx.Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
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
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection('transactions').get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _transactions.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing transactions: $e');
    }
  }
}