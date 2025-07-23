import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUsersScreen extends StatefulWidget {
  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  Set<String> adminUids = {};
  bool loadingAdmins = true;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    final snap = await FirebaseFirestore.instance.collection('admins').get();
    setState(() {
      adminUids = snap.docs.map((doc) => doc.id).toSet();
      loadingAdmins = false;
    });
  }

  void _editUserDialog(DocumentSnapshot userDoc) async {
    final data = userDoc.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: data['name'] ?? '');
    final email = data['email'] ?? '';
    final uid = userDoc.id;
    final isAdmin = adminUids.contains(uid);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              Text('Email: $email'),
              const SizedBox(height: 12),
              Text('UID: $uid'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Update name
                await userDoc.reference.update({
                  'name': nameController.text.trim(),
                });
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Save Name'),
            ),
            TextButton(
              onPressed: () async {
                // Send password reset email
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset email sent to $email'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send reset email')),
                  );
                }
              },
              child: Text('Reset Password'),
            ),
            TextButton(
              onPressed: () async {
                // Promote/demote admin
                if (isAdmin) {
                  await FirebaseFirestore.instance
                      .collection('admins')
                      .doc(uid)
                      .delete();
                  setState(() {
                    adminUids.remove(uid);
                  });
                } else {
                  await FirebaseFirestore.instance
                      .collection('admins')
                      .doc(uid)
                      .set({'promotedAt': FieldValue.serverTimestamp()});
                  setState(() {
                    adminUids.add(uid);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(isAdmin ? 'Remove Admin' : 'Make Admin'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: loadingAdmins
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }
                final users = snapshot.data?.docs ?? [];
                final adminUsers = users
                    .where((doc) => adminUids.contains(doc.id))
                    .toList();
                final normalUsers = users
                    .where((doc) => !adminUids.contains(doc.id))
                    .toList();
                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (adminUsers.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Admins',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...adminUsers.map(
                        (doc) => _buildUserTile(doc, theme, isAdmin: true),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (normalUsers.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Users',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...normalUsers.map(
                        (doc) => _buildUserTile(doc, theme, isAdmin: false),
                      ),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _buildUserTile(
    DocumentSnapshot doc,
    ThemeData theme, {
    required bool isAdmin,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    final name =
        data['username'] ?? data['user name'] ?? data['name'] ?? 'No name';
    final email = data['email'] ?? 'No email';
    final uid = doc.id;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Email: $email', style: theme.textTheme.bodySmall),
            Text('UID: $uid', style: theme.textTheme.bodySmall),
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Admin',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: isAdmin
              ? Colors.green.withOpacity(0.15)
              : theme.colorScheme.primary.withOpacity(0.15),
          child: Icon(
            isAdmin ? Icons.verified_user : Icons.person,
            color: isAdmin ? Colors.green : theme.colorScheme.primary,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: theme.colorScheme.primary),
          onPressed: () => _editUserDialog(doc),
        ),
      ),
    );
  }
}
