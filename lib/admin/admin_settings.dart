import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_supplement_store/auth/login.dart';
import 'package:gym_supplement_store/widgets/splash_screen.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _isLoading = false;
  Map<String, dynamic> _storeSettings = {};

  @override
  void initState() {
    super.initState();
    _loadStoreSettings();
  }

  Future<void> _loadStoreSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('store_settings')
          .doc('main')
          .get();

      if (doc.exists) {
        setState(() {
          _storeSettings = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStoreSettings(Map<String, dynamic> newSettings) async {
    try {
      await FirebaseFirestore.instance
          .collection('store_settings')
          .doc('main')
          .set(newSettings, SetOptions(merge: true));

      setState(() {
        _storeSettings = {..._storeSettings, ...newSettings};
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Admin Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Information (read-only)
                  _buildSectionCard(context, 'Store Information', [
                    _buildReadOnlyTile(
                      context,
                      'Store Name',
                      _storeSettings['storeName'] ?? 'Gym Supplement Store',
                      Icons.store,
                      theme.colorScheme.primary,
                    ),
                    _buildReadOnlyTile(
                      context,
                      'Store Email',
                      _storeSettings['storeEmail'] ?? 'contact@store.com',
                      Icons.email,
                      theme.colorScheme.secondary,
                    ),
                    _buildReadOnlyTile(
                      context,
                      'Store Phone',
                      _storeSettings['storePhone'] ?? '+1 234 567 8900',
                      Icons.phone,
                      theme.colorScheme.tertiary,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Notifications (Order Notifications only, coming soon)
                  _buildSectionCard(context, 'Notifications', [
                    _buildComingSoonSwitchTile(
                      context,
                      'Order Notifications',
                      'Get notified for new orders',
                      Icons.notifications,
                      theme.colorScheme.primary,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Account Actions
                  _buildSectionCard(context, 'Account', [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      title: Text(
                        'Change Password',
                        style: theme.textTheme.titleLarge,
                      ),
                      subtitle: Text(
                        'Update admin password',
                        style: theme.textTheme.bodyMedium,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.iconTheme.color,
                      ),
                      onTap: () {
                        _showChangePasswordDialog(context);
                      },
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
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
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReadOnlyTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: theme.textTheme.titleLarge),
      subtitle: Text(value, style: theme.textTheme.bodyMedium),
      trailing: const Icon(Icons.lock, size: 16, color: Colors.grey),
    );
  }

  Widget _buildComingSoonSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: theme.textTheme.titleLarge),
      subtitle: Text(
        '$subtitle (Coming Soon)',
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
      ),
      trailing: Switch(
        value: false,
        onChanged: null,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password', style: theme.textTheme.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Re-authenticate before changing password
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // Change password
                  await user.updatePassword(newPasswordController.text);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error changing password: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}
