import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:gym_supplement_store/providers/theme_provider.dart';

class ProfileTap extends StatefulWidget {
  const ProfileTap({super.key});

  @override
  State<ProfileTap> createState() => _ProfileTapState();
}

class _ProfileTapState extends State<ProfileTap> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username from Firestore
                  StreamBuilder<DocumentSnapshot>(
                    stream: user != null
                        ? FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots()
                        : null,
                    builder: (context, snapshot) {
                      String displayName = 'User Name';
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        displayName =
                            data?['username'] ??
                            data?['displayName'] ??
                            user?.displayName ??
                            'User Name';
                      } else if (user?.displayName != null) {
                        displayName = user!.displayName!;
                      }

                      return Text(
                        displayName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings Section
            Card(
              child: Column(
                children: [
                  // Theme Mode Selector
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    title: Text(
                      'Theme Mode',
                      style: theme.textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      'Current: ${themeProvider.getThemeModeName()}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: _buildThemeModeSelector(themeProvider, theme),
                  ),

                  Divider(height: 1, color: theme.dividerColor),

                  // Account Settings
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'Account Settings',
                      style: theme.textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      'Manage your account',
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.iconTheme.color,
                    ),
                    onTap: () {
                      // TODO: Navigate to account settings
                    },
                  ),

                  Divider(height: 1, color: theme.dividerColor),

                  // Help & Support
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    title: Text(
                      'Help & Support',
                      style: theme.textTheme.titleLarge,
                    ),
                    subtitle: Text(
                      'Get help and contact support',
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.iconTheme.color,
                    ),
                    onTap: () {
                      // TODO: Navigate to help & support
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Logout',
                        style: theme.textTheme.headlineSmall,
                      ),
                      content: Text(
                        'Are you sure you want to logout?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancel',
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                          ),
                          child: Text(
                            'Logout',
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  }
                },
                icon: Icon(Icons.logout, color: theme.colorScheme.onError),
                label: Text(
                  'Logout',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onError,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(ThemeProvider themeProvider, ThemeData theme) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            themeProvider,
            theme,
            ThemeMode.light,
            'L',
            Icons.light_mode,
          ),
          _buildThemeOption(
            themeProvider,
            theme,
            ThemeMode.system,
            'S',
            Icons.settings_system_daydream,
          ),
          _buildThemeOption(
            themeProvider,
            theme,
            ThemeMode.dark,
            'D',
            Icons.dark_mode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeProvider themeProvider,
    ThemeData theme,
    ThemeMode mode,
    String label,
    IconData icon,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return GestureDetector(
      onTap: () async {
        await themeProvider.setThemeMode(mode);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Theme changed to ${themeProvider.getThemeModeName()}',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  void _showThemeModeDialog(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Theme Mode', style: theme.textTheme.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) async {
                if (value != null) {
                  await themeProvider.setThemeMode(value);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) async {
                if (value != null) {
                  await themeProvider.setThemeMode(value);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow system theme'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) async {
                if (value != null) {
                  await themeProvider.setThemeMode(value);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}
