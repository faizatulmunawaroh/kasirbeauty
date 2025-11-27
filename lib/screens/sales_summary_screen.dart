import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';

class SalesData {
  final String productName;
  int quantity;
  double revenue;

  SalesData({
    required this.productName,
    required this.quantity,
    required this.revenue,
  });
}

class SalesSummaryScreen extends StatefulWidget {
  const SalesSummaryScreen({super.key});

  @override
  State<SalesSummaryScreen> createState() => _SalesSummaryScreenState();
}

class _SalesSummaryScreenState extends State<SalesSummaryScreen> {
  List<SalesData> _salesData = [];
  double _totalRevenue = 0;
  int _totalTransactions = 0;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSalesData();
    });
  }

  void _loadSalesData([DateTime? start, DateTime? end]) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = start != null && end != null
        ? transactionProvider.getTransactionsByDateRange(start, end)
        : transactionProvider.transactions;

    // Calculate sales data from actual transactions
    final productSales = <String, SalesData>{};

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        final productName = item.product.name;
        if (productSales.containsKey(productName)) {
          productSales[productName]!.quantity += item.quantity;
          productSales[productName]!.revenue += item.totalPrice;
        } else {
          productSales[productName] = SalesData(
            productName: productName,
            quantity: item.quantity,
            revenue: item.totalPrice,
          );
        }
      }
    }

    _salesData = productSales.values.toList();
    _salesData.sort((a, b) => b.revenue.compareTo(a.revenue)); // Sort by revenue descending

    _totalRevenue = transactionProvider.getTotalRevenue(start, end);
    _totalTransactions = transactionProvider.getTransactionCount(start, end);
  }

  void _showDateRangeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Date Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => startDate = date);
                        }
                      },
                      child: Text(startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : 'Start Date'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => endDate = date);
                        }
                      },
                      child: Text(endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : 'End Date'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                });
                _loadSalesData();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                _loadSalesData(startDate, endDate);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareReport() {
    final report = '''
Sales Report - ${DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now())}

Date Range: ${startDate != null && endDate != null ? '${DateFormat('yyyy-MM-dd').format(startDate!)} to ${DateFormat('yyyy-MM-dd').format(endDate!)}' : 'All Time'}

Total Revenue: Rp ${NumberFormat('#,###').format(_totalRevenue)}
Total Transactions: $_totalTransactions

Product Performance:
${_salesData.map((data) => '${data.productName}: ${data.quantity} units - Rp ${NumberFormat('#,###').format(data.revenue)}').join('\n')}

Top Performer: ${_salesData.isNotEmpty ? _salesData.first.productName : 'N/A'}
Average Transaction: Rp ${NumberFormat('#,###').format(_totalTransactions > 0 ? _totalRevenue / _totalTransactions : 0)}
Total Products Sold: ${_salesData.fold(0, (sum, item) => sum + item.quantity)} units
''';
    Share.share(report, subject: 'Sales Summary Report');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Sales Summary'),
        backgroundColor: Colors.pink.shade50,
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
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangeDialog,
            tooltip: 'Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: 'Share Report',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            top: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Revenue',
                      'Rp ${NumberFormat('#,###').format(_totalRevenue)}',
                      Icons.attach_money,
                      Colors.pink.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Transactions',
                      _totalTransactions.toString(),
                      Icons.receipt,
                      Colors.pink.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Date
              Text(
                'Sales Report - ${DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Product Sales List
              const Text(
                'Product Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _salesData.length,
                itemBuilder: (context, index) {
                  final data = _salesData[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.pink.shade100,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.pink.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        data.productName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${data.quantity} units sold'),
                      trailing: Text(
                        'Rp ${NumberFormat('#,###').format(data.revenue)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Performance Insights
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insights, color: Colors.pink.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Performance Insights',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInsightItem(
                        'Top Performer',
                        _salesData.isNotEmpty ? _salesData.first.productName : 'N/A',
                        Colors.pink.shade600,
                      ),
                      _buildInsightItem(
                        'Average Transaction',
                        'Rp ${NumberFormat('#,###').format(_totalTransactions > 0 ? _totalRevenue / _totalTransactions : 0)}',
                        Colors.pink.shade500,
                      ),
                      _buildInsightItem(
                        'Total Products Sold',
                        '${_salesData.fold(0, (sum, item) => sum + item.quantity)} units',
                        Colors.pink.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.8), color],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}