import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  double _discountPercentage = 0.0;

  List<CartItem> get items => _items;
  double get discountPercentage => _discountPercentage;

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get totalAmount {
    return subtotal * (1 - _discountPercentage / 100);
  }

  double get discountAmount {
    return subtotal * (_discountPercentage / 100);
  }

  void addItem(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void setDiscount(double percentage) {
    _discountPercentage = percentage.clamp(0, 100);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _discountPercentage = 0.0;
    notifyListeners();
  }
}