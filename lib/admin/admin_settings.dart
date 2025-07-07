import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_supplement_store/auth/login.dart';
import 'package:gym_supplement_store/main.dart';

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
                  // Store Information
                  _buildSectionCard(context, 'Store Information', [
                    _buildSettingTile(
                      context,
                      'Store Name',
                      _storeSettings['storeName'] ?? 'Gym Supplement Store',
                      Icons.store,
                      theme.colorScheme.primary,
                      (value) => _updateStoreSettings({'storeName': value}),
                    ),
                    _buildSettingTile(
                      context,
                      'Store Email',
                      _storeSettings['storeEmail'] ?? 'contact@store.com',
                      Icons.email,
                      theme.colorScheme.secondary,
                      (value) => _updateStoreSettings({'storeEmail': value}),
                    ),
                    _buildSettingTile(
                      context,
                      'Store Phone',
                      _storeSettings['storePhone'] ?? '+1 234 567 8900',
                      Icons.phone,
                      theme.colorScheme.tertiary,
                      (value) => _updateStoreSettings({'storePhone': value}),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Security Settings
                  _buildSectionCard(context, 'Security', [
                    _buildSwitchTile(
                      context,
                      'Two-Factor Authentication',
                      'Require 2FA for admin access',
                      Icons.security,
                      theme.colorScheme.error,
                      _storeSettings['require2FA'] ?? false,
                      (value) => _updateStoreSettings({'require2FA': value}),
                    ),
                    _buildSwitchTile(
                      context,
                      'Session Timeout',
                      'Auto-logout after inactivity',
                      Icons.timer,
                      theme.colorScheme.tertiary,
                      _storeSettings['sessionTimeout'] ?? true,
                      (value) =>
                          _updateStoreSettings({'sessionTimeout': value}),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Notification Settings
                  _buildSectionCard(context, 'Notifications', [
                    _buildSwitchTile(
                      context,
                      'Order Notifications',
                      'Get notified for new orders',
                      Icons.notifications,
                      theme.colorScheme.primary,
                      _storeSettings['orderNotifications'] ?? true,
                      (value) =>
                          _updateStoreSettings({'orderNotifications': value}),
                    ),
                    _buildSwitchTile(
                      context,
                      'Low Stock Alerts',
                      'Get notified for low stock items',
                      Icons.inventory,
                      theme.colorScheme.secondary,
                      _storeSettings['lowStockAlerts'] ?? true,
                      (value) =>
                          _updateStoreSettings({'lowStockAlerts': value}),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Data Management
                  _buildSectionCard(context, 'Data Management', [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.backup,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        'Backup Data',
                        style: theme.textTheme.titleLarge,
                      ),
                      subtitle: Text(
                        'Create a backup of all data',
                        style: theme.textTheme.bodyMedium,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.iconTheme.color,
                      ),
                      onTap: () {
                        _showBackupDialog(context);
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.restore,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: Text(
                        'Restore Data',
                        style: theme.textTheme.titleLarge,
                      ),
                      subtitle: Text(
                        'Restore from backup',
                        style: theme.textTheme.bodyMedium,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.iconTheme.color,
                      ),
                      onTap: () {
                        _showRestoreDialog(context);
                      },
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

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    Function(String) onUpdate,
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
      trailing: Icon(Icons.edit, size: 16, color: theme.iconTheme.color),
      onTap: () {
        _showEditSettingDialog(context, title, value, onUpdate);
      },
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
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
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  void _showEditSettingDialog(
    BuildContext context,
    String title,
    String currentValue,
    Function(String) onUpdate,
  ) {
    final controller = TextEditingController(text: currentValue);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title', style: theme.textTheme.headlineSmall),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onUpdate(controller.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
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

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
          'This will create a backup of all your data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup feature coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('This will restore data from backup. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restore feature coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
