import 'cart_item.dart';

class Transaction {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String? customerName;

  Transaction({
    required this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    this.customerName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      subtotal: json['subtotal'].toDouble(),
      discountAmount: json['discountAmount'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      paymentMethod: json['paymentMethod'],
      customerName: json['customerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
    };
  }

  List<String> get productNames => items.map((item) => item.product.name).toList();
}