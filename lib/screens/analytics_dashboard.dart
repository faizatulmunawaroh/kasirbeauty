import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/transaction_provider.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _exportReport() {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = transactionProvider.transactions;

    final totalRevenue = transactionProvider.getTotalRevenue();
    final totalTransactions = transactionProvider.getTransactionCount();
    final averageTransaction = totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;
    final revenueByMethod = transactionProvider.getRevenueByPaymentMethod();

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentTransactions = transactions.where((t) => t.date.isAfter(weekAgo)).toList();
    final weeklyRevenue = recentTransactions.fold(0.0, (sum, t) => sum + t.totalAmount);

    final report = '''
Analytics Report - ${DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now())}

Key Metrics:
- Total Revenue: Rp ${NumberFormat('#,###').format(totalRevenue)}
- Total Transactions: $totalTransactions
- Average Transaction: Rp ${NumberFormat('#,###').format(averageTransaction)}
- Weekly Revenue: Rp ${NumberFormat('#,###').format(weeklyRevenue)}

Revenue by Payment Method:
${revenueByMethod.entries.map((e) => '- ${e.key}: Rp ${NumberFormat('#,###').format(e.value)}').join('\n')}

Recent Performance:
- Today: Rp ${NumberFormat('#,###').format(_calculateDailyRevenue(DateTime.now()))}
- Yesterday: Rp ${NumberFormat('#,###').format(_calculateDailyRevenue(DateTime.now().subtract(const Duration(days: 1))))}
- This Week: Rp ${NumberFormat('#,###').format(weeklyRevenue)}
- This Month: Rp ${NumberFormat('#,###').format(_calculateMonthlyRevenue())}
''';
    Share.share(report, subject: 'Analytics Report');
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    // Calculate analytics
    final totalRevenue = transactionProvider.getTotalRevenue();
    final totalTransactions = transactionProvider.getTransactionCount();
    final averageTransaction = totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0;

    // Revenue by payment method
    final revenueByMethod = transactionProvider.getRevenueByPaymentMethod();

    // Recent transactions (last 7 days)
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentTransactions = transactions.where((t) => t.date.isAfter(weekAgo)).toList();
    final weeklyRevenue = recentTransactions.fold(0.0, (sum, t) => sum + t.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
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
            icon: const Icon(Icons.refresh),
            onPressed: () => transactionProvider.loadTransactions(),
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.pink.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.analytics,
                            color: Colors.pink.shade600,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Business Analytics',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade800,
                                ),
                              ),
                              Text(
                                'Advanced insights & performance metrics',
                                style: TextStyle(
                                  color: Colors.pink.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Key Metrics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Total Revenue',
                        'Rp ${NumberFormat('#,###').format(totalRevenue)}',
                        Icons.attach_money,
                        Colors.pink.shade800,
                        '+12.5%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Transactions',
                        totalTransactions.toString(),
                        Icons.receipt,
                        Colors.pink.shade700,
                        '+8.2%',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Avg Transaction',
                        'Rp ${NumberFormat('#,###').format(averageTransaction)}',
                        Icons.trending_up,
                        Colors.pink.shade600,
                        '+5.7%',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Weekly Revenue',
                        'Rp ${NumberFormat('#,###').format(weeklyRevenue)}',
                        Icons.calendar_view_week,
                        Colors.pink.shade500,
                        '+15.3%',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Revenue Breakdown
                const Text(
                  'Revenue by Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: revenueByMethod.entries.map((entry) {
                        final percentage = totalRevenue > 0 ? (entry.value / totalRevenue) * 100 : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getPaymentMethodColor(entry.key),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Rp ${NumberFormat('#,###').format(entry.value)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Recent Performance
                const Text(
                  'Recent Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildPerformanceItem(
                          'Today',
                          _calculateDailyRevenue(DateTime.now()),
                          Icons.today,
                          Colors.pink.shade400,
                        ),
                        const Divider(),
                        _buildPerformanceItem(
                          'Yesterday',
                          _calculateDailyRevenue(DateTime.now().subtract(const Duration(days: 1))),
                          Icons.calendar_today,
                          Colors.pink.shade300,
                        ),
                        const Divider(),
                        _buildPerformanceItem(
                          'This Week',
                          weeklyRevenue,
                          Icons.date_range,
                          Colors.pink.shade500,
                        ),
                        const Divider(),
                        _buildPerformanceItem(
                          'This Month',
                          _calculateMonthlyRevenue(),
                          Icons.calendar_month,
                          Colors.pink.shade600,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Top Products (placeholder for now)
                const Text(
                  'Top Performing Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTopProductItem('Lipstick Ruby Red', 45, Colors.pink.shade300),
                        const SizedBox(height: 12),
                        _buildTopProductItem('Foundation Natural Beige', 32, Colors.pink.shade400),
                        const SizedBox(height: 12),
                        _buildTopProductItem('Mascara Volume Plus', 28, Colors.pink.shade500),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String period, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            period,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          'Rp ${NumberFormat('#,###').format(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductItem(String name, int sales, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$sales sold',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.pink.shade600;
      case 'card':
        return Colors.pink.shade500;
      case 'qr':
        return Colors.pink.shade400;
      default:
        return Colors.grey;
    }
  }

  double _calculateDailyRevenue(DateTime date) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return transactionProvider.getTotalRevenue(startOfDay, endOfDay);
  }

  double _calculateMonthlyRevenue() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    return transactionProvider.getTotalRevenue(startOfMonth, endOfMonth);
  }
}