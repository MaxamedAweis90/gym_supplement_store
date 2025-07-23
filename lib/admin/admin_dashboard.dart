import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_supplement_store/admin/admin_bottom_nav.dart';
import 'package:gym_supplement_store/admin/admin_products.dart';
import 'package:gym_supplement_store/admin/admin_settings.dart';
import 'package:gym_supplement_store/auth/login.dart';
import 'package:gym_supplement_store/widgets/splash_screen.dart';
import 'package:gym_supplement_store/admin/admin_orders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_supplement_store/admin/admin_archive_orders.dart';
import 'package:gym_supplement_store/admin/manage_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _adminPages = [
    const AdminHomeTab(),
    const AdminProductsPage(),
    const AdminSettingsPage(),
  ];

  Future<bool> _onWillPop() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'You are about to log out from the admin dashboard. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SplashScreen(
            duration: const Duration(seconds: 2),
            nextScreen: const LoginPage(),
          ),
        ),
        (route) => false,
      );
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: _adminPages[_currentIndex],
        bottomNavigationBar: AdminBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

// Admin Home Tab
class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  Future<int> _getTotalProducts() async {
    final snap = await FirebaseFirestore.instance.collection('products').get();
    return snap.size;
  }

  Future<int> _getTotalOrders() async {
    final snap = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', isNotEqualTo: 'delivered')
        .get();
    return snap.size;
  }

  Future<double> _getRevenue() async {
    final snap = await FirebaseFirestore.instance
        .collection('archive_orders')
        .get();
    double total = 0.0;
    for (var doc in snap.docs) {
      final data = doc.data();
      if (data.containsKey('total')) {
        total += (data['total'] as num).toDouble();
      }
    }
    return total;
  }

  Future<int> _getTotalUsers() async {
    final snap = await FirebaseFirestore.instance.collection('users').get();
    return snap.size;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.1),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 35,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, Admin!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'admin@example.com',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Quick Stats',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getTotalProducts(),
                    builder: (context, snapshot) => _buildStatCard(
                      context,
                      'Total Products',
                      snapshot.hasData ? snapshot.data.toString() : '...',
                      Icons.inventory,
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getTotalOrders(),
                    builder: (context, snapshot) => _buildStatCard(
                      context,
                      'Total Orders',
                      snapshot.hasData ? snapshot.data.toString() : '...',
                      Icons.shopping_cart,
                      theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FutureBuilder<double>(
                    future: _getRevenue(),
                    builder: (context, snapshot) => _buildStatCard(
                      context,
                      'Revenue',
                      snapshot.hasData
                          ? '\$${snapshot.data!.toStringAsFixed(2)}'
                          : '...',
                      Icons.attach_money,
                      theme.colorScheme.tertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getTotalUsers(),
                    builder: (context, snapshot) => _buildStatCard(
                      context,
                      'Users',
                      snapshot.hasData ? snapshot.data.toString() : '...',
                      Icons.people,
                      theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildQuickActionCard(
              context,
              'View Orders',
              'Check and manage customer orders',
              Icons.receipt_long,
              theme.colorScheme.secondary,
              () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => AdminOrdersScreen()));
              },
            ),

            const SizedBox(height: 12),

            _buildQuickActionCard(
              context,
              'Manage Users',
              'View and manage user accounts',
              Icons.people_outline,
              theme.colorScheme.tertiary,
              () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => ManageUsersScreen()));
              },
            ),

            const SizedBox(height: 12),

            _buildQuickActionCard(
              context,
              'View Archive',
              'See all delivered (archived) orders',
              Icons.archive,
              theme.colorScheme.tertiary,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AdminArchiveOrdersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
