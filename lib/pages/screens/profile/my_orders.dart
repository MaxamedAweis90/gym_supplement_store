import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_supplement_store/pages/screens/profile/order_status_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: user == null
          ? Center(
              child: Text('Not logged in', style: theme.textTheme.bodyLarge),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, activeSnapshot) {
                if (activeSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }
                final activeOrders = activeSnapshot.data?.docs ?? [];
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('archive_orders')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, completedSnapshot) {
                    if (completedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      );
                    }
                    final completedOrders = completedSnapshot.data?.docs ?? [];
                    if (activeOrders.isEmpty && completedOrders.isEmpty) {
                      return Center(
                        child: Text(
                          'No orders found',
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (activeOrders.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Active Orders',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ...activeOrders.map(
                          (doc) => _OrderListTile(order: doc, theme: theme),
                        ),
                        if (completedOrders.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 8),
                            child: Text(
                              'Completed Orders',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ...completedOrders.map(
                          (doc) => _OrderListTile(order: doc, theme: theme),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final QueryDocumentSnapshot order;
  final ThemeData theme;
  const _OrderListTile({required this.order, required this.theme});

  @override
  Widget build(BuildContext context) {
    final data = order.data() as Map<String, dynamic>;
    final status = (data['status'] ?? 'pending').toString();
    final total = data['total'] ?? 0.0;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderStatusScreen(order: order)),
          );
        },
        leading: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
        title: Text(
          'Order #${order.id.substring(0, 6)}',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (createdAt != null)
              Text(
                'Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            Text(
              'Total: 24${total.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: _StatusBadge(status: status, theme: theme),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final ThemeData theme;
  const _StatusBadge({required this.status, required this.theme});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label = status[0].toUpperCase() + status.substring(1);
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.green;
        break;
      case 'delivered':
      case 'arrived':
      case 'complete':
      case 'completed':
        color = Colors.blue;
        label = 'Delivered';
        break;
      default:
        color = theme.colorScheme.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
