import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class ProfessionalDrawer extends StatelessWidget {
  const ProfessionalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50,
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with User Profile
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.pink.shade600,
                    Colors.pink.shade800,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User Info
                  Text(
                    authProvider.userEmail ?? 'Beauty Manager',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Store Manager',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Store Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade500.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Store Open',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMenuSection('STORE MANAGEMENT'),
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    subtitle: 'Overview & Analytics',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Inventory',
                    subtitle: 'Product Management',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.point_of_sale,
                    title: 'POS Terminal',
                    subtitle: 'Point of Sale',
                    onTap: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 16),
                  _buildMenuSection('REPORTS & ANALYTICS'),
                  _buildMenuItem(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Sales Reports',
                    subtitle: 'Revenue Analytics',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.insights,
                    title: 'Advanced Analytics',
                    subtitle: 'Business Intelligence',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    title: 'Transaction History',
                    subtitle: 'Order Records',
                    onTap: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 16),
                  _buildMenuSection('CUSTOMER MANAGEMENT'),
                  _buildMenuItem(
                    context,
                    icon: Icons.people,
                    title: 'Customer Database',
                    subtitle: 'Client Information',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.loyalty,
                    title: 'Loyalty Program',
                    subtitle: 'Rewards & Points',
                    onTap: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 16),
                  _buildMenuSection('SETTINGS & TOOLS'),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    title: 'Store Settings',
                    subtitle: 'Configuration',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.print,
                    title: 'Printer Settings',
                    subtitle: 'Receipt & Label',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.backup,
                    title: 'Backup & Sync',
                    subtitle: 'Data Management',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'User Guide',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Footer with Logout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: const Text('Sign out of account'),
                    onTap: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 8),

                  // App Version
                  Text(
                    'Beauty POS v2.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.pink.shade600,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}