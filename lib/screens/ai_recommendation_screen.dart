import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final _categoryController = TextEditingController();
  List<Product> _recommendations = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendations() async {
    if (_categoryController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.example.com/ai/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'category': _categoryController.text}),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _recommendations = data.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to get recommendations');
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

  void _addToCart(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Enter category or product description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getRecommendations,
              child: const Text('Get Recommendations'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendations.isEmpty
                      ? const Center(child: Text('No recommendations yet'))
                      : ListView.builder(
                          itemCount: _recommendations.length,
                          itemBuilder: (context, index) {
                            final product = _recommendations[index];
                            return Card(
                              child: ListTile(
                                title: Text(product.name),
                                subtitle: Text('\$${product.price} | ${product.category}'),
                                trailing: ElevatedButton(
                                  onPressed: () => _addToCart(product),
                                  child: const Text('Add to Cart'),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}