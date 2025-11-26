import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/product.dart';
import 'receipt_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchController = TextEditingController();
  final _customerController = TextEditingController();
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = productProvider.products
          .where((product) =>
              product.name.toLowerCase().contains(query) ||
              product.barcode.contains(query))
          .toList();
    });
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (result != null) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final product = productProvider.products.firstWhere(
        (p) => p.barcode == result,
        orElse: () => throw Exception('Product not found'),
      );
      _addToCart(product);
    }
  }

  void _addToCart(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product);

    // Show animated snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade400),
            const SizedBox(width: 8),
            Text('${product.name} added to cart'),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Add haptic feedback simulation (visual bounce effect)
    setState(() {});
  }

  void _removeFromCart(String productId) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeItem(productId);
  }

  void _updateQuantity(String productId, int quantity) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.updateQuantity(productId, quantity);
  }

  void _showDiscountDialog(BuildContext context) {
    final discountController = TextEditingController();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    discountController.text = cartProvider.discountPercentage.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: discountController,
              decoration: const InputDecoration(
                labelText: 'Discount Percentage (%)',
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'Current subtotal: \$${cartProvider.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final discount = double.tryParse(discountController.text) ?? 0;
              cartProvider.setDiscount(discount);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Discount of ${discount}% applied'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    if (cartProvider.items.isEmpty) return;

    // Show checkout dialog with customer name and payment method
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customerController,
              decoration: const InputDecoration(
                labelText: 'Customer Name (Optional)',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Payment Method:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Cash'),
                  value: 'Cash',
                  groupValue: null,
                  onChanged: (value) => Navigator.pop(context, {'payment': value!, 'customer': _customerController.text}),
                ),
                RadioListTile<String>(
                  title: const Text('Card'),
                  value: 'Card',
                  groupValue: null,
                  onChanged: (value) => Navigator.pop(context, {'payment': value!, 'customer': _customerController.text}),
                ),
                RadioListTile<String>(
                  title: const Text('QR Code'),
                  value: 'QR',
                  groupValue: null,
                  onChanged: (value) => Navigator.pop(context, {'payment': value!, 'customer': _customerController.text}),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      final paymentMethod = result['payment']!;
      final customerName = result['customer']!.isEmpty ? null : result['customer'];

      // Save transaction
      final transaction = await transactionProvider.createTransactionFromCart(
        items: cartProvider.items,
        subtotal: cartProvider.subtotal,
        discountAmount: cartProvider.discountAmount,
        totalAmount: cartProvider.totalAmount,
        paymentMethod: paymentMethod,
        customerName: customerName,
      );

      // Clear cart and customer name
      cartProvider.clearCart();
      _customerController.clear();

      // Navigate to receipt screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(transaction: transaction),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: Colors.green.shade800,
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
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
            tooltip: 'Scan Product',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
              Colors.grey.shade700,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.point_of_sale,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Point of Sale',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                        onPressed: _scanBarcode,
                        tooltip: 'Scan Barcode',
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _searchProducts();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: Row(
                  children: [
                    // Product List
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(left: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Products (${_searchResults.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _searchResults.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.inventory_2_outlined,
                                            size: 64,
                                            color: Colors.grey.shade300,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No products found',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: _searchResults.length,
                                      itemBuilder: (context, index) {
                                        final product = _searchResults[index];
                                        return Card(
                                          elevation: 2,
                                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.all(12),
                                            leading: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    _getCategoryColor(product.category).withOpacity(0.8),
                                                    _getCategoryColor(product.category),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                _getCategoryIcon(product.category),
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            title: Text(
                                              product.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Rp ${product.price.toStringAsFixed(0)}'),
                                                Text(
                                                  'Stock: ${product.stock}',
                                                  style: TextStyle(
                                                    color: product.stock < 10 ? Colors.red : Colors.green,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade600,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.add, color: Colors.white),
                                                onPressed: () => _addToCart(product),
                                                tooltip: 'Add to Cart',
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Cart
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_cart, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cart (${cartProvider.items.length})',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Cart Items
                            Expanded(
                              child: cartProvider.items.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 64,
                                            color: Colors.grey.shade300,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Cart is empty',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: cartProvider.items.length,
                                      itemBuilder: (context, index) {
                                        final item = cartProvider.items[index];
                                        return Card(
                                          elevation: 1,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.product.name,
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        'Rp ${item.product.price.toStringAsFixed(0)} each',
                                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.remove, size: 20),
                                                      onPressed: () => _updateQuantity(item.product.id, item.quantity - 1),
                                                      color: Colors.red.shade400,
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.shade50,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        '${item.quantity}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.blue.shade600,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.add, size: 20),
                                                      onPressed: () => _updateQuantity(item.product.id, item.quantity + 1),
                                                      color: Colors.green.shade600,
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, size: 20),
                                                  onPressed: () => _removeFromCart(item.product.id),
                                                  color: Colors.red.shade600,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),

                            // Cart Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Subtotal
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Subtotal:', style: TextStyle(color: Colors.grey.shade700)),
                                      Text(
                                        'Rp ${cartProvider.subtotal.toStringAsFixed(0)}',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),

                                  // Discount
                                  if (cartProvider.discountPercentage > 0) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Discount (${cartProvider.discountPercentage}%):',
                                          style: TextStyle(color: Colors.orange.shade700),
                                        ),
                                        Text(
                                          '-Rp ${cartProvider.discountAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.red.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  const Divider(),

                                  // Total
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'TOTAL:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${cartProvider.totalAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showDiscountDialog(context),
                                          icon: const Icon(Icons.discount),
                                          label: const Text('Discount'),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.orange.shade600),
                                            foregroundColor: Colors.orange.shade600,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: cartProvider.items.isEmpty ? null : _checkout,
                                          icon: const Icon(Icons.payment),
                                          label: const Text('Checkout'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade600,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            disabledBackgroundColor: Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makeup':
        return Colors.pink.shade600;
      case 'skincare':
        return Colors.teal.shade600;
      case 'fashion':
        return Colors.purple.shade600;
      case 'accessories':
        return Colors.amber.shade600;
      case 'hair care':
        return Colors.orange.shade600;
      case 'fragrance':
        return Colors.indigo.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makeup':
        return Icons.face;
      case 'skincare':
        return Icons.spa;
      case 'fashion':
        return Icons.checkroom;
      case 'accessories':
        return Icons.diamond;
      case 'hair care':
        return Icons.brush;
      case 'fragrance':
        return Icons.air;
      default:
        return Icons.inventory;
    }
  }
}

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            Navigator.pop(context, barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}