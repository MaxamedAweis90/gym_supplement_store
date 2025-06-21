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

    // If no user is authenticated, this shouldn't happen due to AuthWrapper
    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user found')));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Profile Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onPrimary,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.surface,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Username from Firestore
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String displayName = 'User Name';
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            displayName =
                                data?['username'] ??
                                data?['displayName'] ??
                                user.displayName ??
                                'User Name';
                          } else if (user.displayName != null) {
                            displayName = user.displayName!;
                          }

                          return Text(
                            displayName,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'user@example.com',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Quick Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Orders',
                          '12',
                          Icons.shopping_bag_outlined,
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Favorites',
                          '8',
                          Icons.favorite_outline,
                          theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Reviews',
                          '5',
                          Icons.star_outline,
                          theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSettingsSection(context, themeProvider, theme),

                  const SizedBox(height: 24),

                  // Logout Button
                  _buildLogoutButton(context, theme),
                ],
              ),
            ),
          ),
        ],
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Theme Mode
              _buildSettingTile(
                context,
                'Theme Mode',
                'Current: ${themeProvider.getThemeModeName()}',
                Icons.palette_outlined,
                theme.colorScheme.secondary,
                trailing: _buildThemeModeSelector(themeProvider, theme),
              ),
              _buildDivider(theme),
              // Account Settings
              _buildSettingTile(
                context,
                'Account Settings',
                'Manage your account',
                Icons.settings_outlined,
                theme.colorScheme.primary,
                onTap: () {
                  // TODO: Navigate to account settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account settings coming soon!'),
                    ),
                  );
                },
              ),
              _buildDivider(theme),
              // Help & Support
              _buildSettingTile(
                context,
                'Help & Support',
                'Get help and contact support',
                Icons.help_outline,
                theme.colorScheme.tertiary,
                onTap: () {
                  // TODO: Navigate to help & support
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help & support coming soon!'),
                    ),
                  );
                },
              ),
              _buildDivider(theme),
              // Privacy Policy
              _buildSettingTile(
                context,
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip_outlined,
                theme.colorScheme.primary,
                onTap: () {
                  // TODO: Navigate to privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 20),
      child: Divider(height: 1, color: theme.dividerColor.withOpacity(0.3)),
    );
  }

  Widget _buildThemeModeSelector(ThemeProvider themeProvider, ThemeData theme) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
            Icons.light_mode,
          ),
          _buildThemeOption(
            themeProvider,
            theme,
            ThemeMode.system,
            Icons.settings_system_daydream,
          ),
          _buildThemeOption(
            themeProvider,
            theme,
            ThemeMode.dark,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.error,
            theme.colorScheme.error.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.error.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context, theme),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: theme.colorScheme.onError, size: 20),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onError,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performLogout(context, theme);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text(
              'Logout',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context, ThemeData theme) async {
    try {
      await FirebaseAuth.instance.signOut();
      // The AuthWrapper will automatically handle the navigation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Successfully logged out'),
              ],
            ),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }
}
