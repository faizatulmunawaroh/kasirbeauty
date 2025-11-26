import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock data for demo purposes
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      _products = [
        Product(id: '1', name: 'Nasi Goreng', barcode: '123456789', price: 15000, stock: 50, category: 'Makanan'),
        Product(id: '2', name: 'Ayam Bakar', barcode: '987654321', price: 25000, stock: 30, category: 'Makanan'),
        Product(id: '3', name: 'Es Teh', barcode: '456789123', price: 5000, stock: 100, category: 'Minuman'),
        Product(id: '4', name: 'Kopi Hitam', barcode: '789123456', price: 8000, stock: 80, category: 'Minuman'),
        Product(id: '5', name: 'Bakso', barcode: '321654987', price: 12000, stock: 40, category: 'Makanan'),
        Product(id: '6', name: 'Jus Jeruk', barcode: '654987321', price: 10000, stock: 60, category: 'Minuman'),
        Product(id: '7', name: 'Sate Ayam', barcode: '147258369', price: 20000, stock: 25, category: 'Makanan'),
        Product(id: '8', name: 'Mineral Water', barcode: '963852741', price: 3000, stock: 120, category: 'Minuman'),
      ];
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.example.com/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201) {
        final newProduct = Product.fromJson(jsonDecode(response.body));
        _products.add(newProduct);
        notifyListeners();
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('https://api.example.com/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = product;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('https://api.example.com/products/$id'));

      if (response.statusCode == 200) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      throw e;
    }
  }

  List<Product> searchProducts(String query) {
    return _products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.barcode.contains(query)
    ).toList();
  }
}