import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Orders',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Text('Filter:', style: theme.textTheme.bodyMedium),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: statusFilter,
                  borderRadius: BorderRadius.circular(12),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'accepted',
                      child: Text('Accepted'),
                    ),
                    DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => statusFilter = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _ordersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }
                final orders = snapshot.data?.docs ?? [];
                print(
                  'Admin orders in snapshot: ' +
                      orders.map((d) => d.id).toList().toString(),
                );
                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders found',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final order = doc.data() as Map<String, dynamic>;
                    print(
                      'Admin sees order: \u001b[32m${doc.id}\u001b[0m, status: \u001b[34m${order['status']}\u001b[0m',
                    );
                    final items = (order['items'] as List<dynamic>?) ?? [];
                    final status = order['status'] ?? 'pending';
                    final total = order['total'] ?? 0.0;
                    final userEmail = order['userEmail'] ?? 'Unknown';
                    final createdAt = (order['createdAt'] as Timestamp?)
                        ?.toDate();
                    final userId = order['userId'] ?? '';
                    // Fetch the user's FCM token for display
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get(),
                      builder: (context, userSnapshot) {
                        String? fcmToken;
                        if (userSnapshot.hasData && userSnapshot.data != null) {
                          final userData =
                              userSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                          fcmToken =
                              userData != null &&
                                  userData.containsKey('fcmToken')
                              ? userData['fcmToken'] as String?
                              : null;
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(
                                0.08,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status == 'pending'
                                            ? Colors.orange.withOpacity(0.15)
                                            : status == 'accepted'
                                            ? Colors.green.withOpacity(0.15)
                                            : status == 'shipped'
                                            ? Colors.blue.withOpacity(0.15)
                                            : Colors.purple.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status[0].toUpperCase() +
                                            status.substring(1),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: status == 'pending'
                                                  ? Colors.orange
                                                  : status == 'accepted'
                                                  ? Colors.green
                                                  : status == 'shipped'
                                                  ? Colors.blue
                                                  : Colors.purple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (createdAt != null)
                                  Text(
                                    'Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}  ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  'User: $userEmail',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (fcmToken != null &&
                                    fcmToken.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    'FCM Token: $fcmToken',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Copy this token and use it in the Firebase Console to send a push notification to this user.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  'Total: \$${total.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            item['imageUrl'] ?? '',
                                            width: 36,
                                            height: 36,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 20,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.2),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            item['name'] ?? '',
                                            style: theme.textTheme.bodyMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          'x${item['quantity']}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    DropdownButton<String>(
                                      value: status,
                                      borderRadius: BorderRadius.circular(12),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'pending',
                                          child: Text('Pending'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'accepted',
                                          child: Text('Accepted'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'shipped',
                                          child: Text('Shipped'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'delivered',
                                          child: Text('Delivered'),
                                        ),
                                      ],
                                      onChanged: (value) async {
                                        if (value != null && value != status) {
                                          if (value == 'delivered') {
                                            // Move to archive_orders and delete from orders
                                            final orderData =
                                                doc.data()
                                                    as Map<String, dynamic>;
                                            await FirebaseFirestore.instance
                                                .collection('archive_orders')
                                                .doc(doc.id)
                                                .set({
                                                  ...orderData,
                                                  'status': 'delivered',
                                                });
                                            await doc.reference.delete();
                                          } else {
                                            await doc.reference.update({
                                              'status': value,
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _ordersStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'orders',
    );
    if (statusFilter != 'all') {
      query = query.where('status', isEqualTo: statusFilter);
    }
    return query.orderBy('createdAt', descending: true).snapshots();
  }
}
