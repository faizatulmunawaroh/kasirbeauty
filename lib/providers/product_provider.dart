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
      // Mock data for women's products and needs
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      _products = [
        // Makeup & Cosmetics
        Product(id: '1', name: 'Lipstick Ruby Red', barcode: '123456789', price: 85000, stock: 45, category: 'Makeup'),
        Product(id: '2', name: 'Foundation Natural Beige', barcode: '987654321', price: 125000, stock: 30, category: 'Makeup'),
        Product(id: '3', name: 'Mascara Volume Plus', barcode: '456789123', price: 95000, stock: 60, category: 'Makeup'),
        Product(id: '4', name: 'Eyeshadow Palette Glam', barcode: '789123456', price: 165000, stock: 25, category: 'Makeup'),

        // Skincare
        Product(id: '5', name: 'Facial Cleanser Gentle', barcode: '321654987', price: 75000, stock: 80, category: 'Skincare'),
        Product(id: '6', name: 'Moisturizer Hydrating', barcode: '654987321', price: 120000, stock: 40, category: 'Skincare'),
        Product(id: '7', name: 'Sunscreen SPF 50', barcode: '147258369', price: 95000, stock: 55, category: 'Skincare'),
        Product(id: '8', name: 'Face Mask Collagen', barcode: '963852741', price: 25000, stock: 120, category: 'Skincare'),

        // Fashion & Clothing
        Product(id: '9', name: 'Blouse Chiffon Elegance', barcode: '852741963', price: 185000, stock: 20, category: 'Fashion'),
        Product(id: '10', name: 'Dress Maxi Floral', barcode: '741963852', price: 285000, stock: 15, category: 'Fashion'),
        Product(id: '11', name: 'Skirt Pencil Black', barcode: '369258147', price: 165000, stock: 35, category: 'Fashion'),
        Product(id: '12', name: 'Cardigan Cashmere Soft', barcode: '258147369', price: 225000, stock: 18, category: 'Fashion'),

        // Accessories
        Product(id: '13', name: 'Necklace Crystal Heart', barcode: '159357486', price: 125000, stock: 28, category: 'Accessories'),
        Product(id: '14', name: 'Earrings Pearl Drop', barcode: '486159357', price: 85000, stock: 42, category: 'Accessories'),
        Product(id: '15', name: 'Handbag Leather Classic', barcode: '357486159', price: 450000, stock: 12, category: 'Accessories'),
        Product(id: '16', name: 'Scarf Silk Luxury', barcode: '951753468', price: 135000, stock: 30, category: 'Accessories'),

        // Hair Care
        Product(id: '17', name: 'Shampoo Nourishing', barcode: '468951753', price: 65000, stock: 75, category: 'Hair Care'),
        Product(id: '18', name: 'Hair Mask Repair', barcode: '753468951', price: 85000, stock: 50, category: 'Hair Care'),
        Product(id: '19', name: 'Hair Dryer Professional', barcode: '246813579', price: 285000, stock: 8, category: 'Hair Care'),

        // Fragrance
        Product(id: '20', name: 'Perfume Floral Essence', barcode: '579246813', price: 195000, stock: 22, category: 'Fragrance'),
        Product(id: '21', name: 'Body Mist Refreshing', barcode: '813579246', price: 75000, stock: 65, category: 'Fragrance'),
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