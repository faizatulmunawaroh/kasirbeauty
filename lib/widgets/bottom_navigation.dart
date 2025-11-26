import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/pos_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/sales_summary_screen.dart';
import '../screens/analytics_dashboard.dart';
import 'professional_drawer.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductListScreen(),
    const PosScreen(),
    const TransactionHistoryScreen(),
    const SalesSummaryScreen(),
    const AnalyticsDashboard(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      activeIcon: Icon(Icons.dashboard, size: 28),
      label: 'Dashboard',
      tooltip: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.inventory_2),
      activeIcon: Icon(Icons.inventory_2, size: 28),
      label: 'Products',
      tooltip: 'Product Management',
    ),
    BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.point_of_sale,
          color: Colors.white,
          size: 20,
        ),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade300.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.point_of_sale,
          color: Colors.white,
          size: 24,
        ),
      ),
      label: 'POS',
      tooltip: 'Point of Sale',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.history),
      activeIcon: Icon(Icons.history, size: 28),
      label: 'History',
      tooltip: 'Transaction History',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart),
      activeIcon: Icon(Icons.bar_chart, size: 28),
      label: 'Reports',
      tooltip: 'Sales Reports',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.insights),
      activeIcon: Icon(Icons.insights, size: 28),
      label: 'Analytics',
      tooltip: 'Advanced Analytics',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfessionalDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.pink.shade600,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showUnselectedLabels: true,
          selectedIconTheme: IconThemeData(
            color: Colors.pink.shade600,
            size: 24,
          ),
          unselectedIconTheme: IconThemeData(
            color: Colors.grey.shade500,
            size: 20,
          ),
        ),
      ),
    );
  }
}