import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class ReceiptScreen extends StatelessWidget {
  final Transaction transaction;

  const ReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade900,
              Colors.green.shade800,
              Colors.green.shade600,
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Receipt',
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
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.print, color: Colors.white, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Print functionality coming soon!')),
                              );
                            },
                            tooltip: 'Print Receipt',
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Share functionality coming soon!')),
                              );
                            },
                            tooltip: 'Share Receipt',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Receipt Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.grey.shade50],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with Logo
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.shade200.withOpacity(0.5),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.receipt_long,
                                          size: 40,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'KASIR PRO',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              color: Colors.green.shade200.withOpacity(0.5),
                                              blurRadius: 8,
                                              offset: const Offset(1, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Point of Sale Receipt',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),
                                const Divider(thickness: 2),

                                // Transaction Details
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade200.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Receipt #: ${transaction.id.substring(0, 8).toUpperCase()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              DateFormat('dd/MM/yyyy').format(transaction.date),
                                              style: TextStyle(
                                                color: Colors.blue.shade800,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Time: ${DateFormat('HH:mm:ss').format(transaction.date)}',
                                            style: TextStyle(color: Colors.grey.shade600),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getPaymentColor(transaction.paymentMethod).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              transaction.paymentMethod,
                                              style: TextStyle(
                                                color: _getPaymentColor(transaction.paymentMethod),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (transaction.customerName != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Customer: ${transaction.customerName}',
                                              style: TextStyle(color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Items Header
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: const [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Item',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Qty',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Price',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Total',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Items List
                                ...transaction.items.map((item) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item.product.name,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${item.quantity}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            currencyFormat.format(item.product.price),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(color: Colors.grey.shade700),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            currencyFormat.format(item.totalPrice),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF388E3C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                const SizedBox(height: 16),
                                const Divider(thickness: 2),

                                // Totals Section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade200.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                                          Text(
                                            currencyFormat.format(transaction.subtotal),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),

                                      if (transaction.discountAmount > 0) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Discount (${(transaction.discountAmount / transaction.subtotal * 100).toStringAsFixed(0)}%):',
                                              style: TextStyle(color: Colors.orange.shade700, fontSize: 16),
                                            ),
                                            Text(
                                              '-${currencyFormat.format(transaction.discountAmount)}',
                                              style: TextStyle(
                                                color: Colors.red.shade600,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      const SizedBox(height: 12),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'TOTAL:',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade600,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              currencyFormat.format(transaction.totalAmount),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Footer
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Thank you for your business!',
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Generated on ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.arrow_back),
                                        label: const Text('Back'),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFF4CAF50)),
                                          foregroundColor: const Color(0xFF4CAF50),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: Implement email receipt
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Email functionality coming soon!')),
                                          );
                                        },
                                        icon: const Icon(Icons.email),
                                        label: const Text('Email'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4CAF50),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _getPaymentColor(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Colors.green.shade600;
      case 'card':
        return Colors.blue.shade600;
      case 'qr':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}