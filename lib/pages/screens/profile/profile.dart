import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:gym_supplement_store/providers/theme_provider.dart';
import 'package:gym_supplement_store/providers/user_provider.dart';
import 'package:gym_supplement_store/auth/login.dart';
import 'package:gym_supplement_store/widgets/user_avatar_picker.dart';
import 'package:gym_supplement_store/widgets/splash_screen.dart';
import 'package:gym_supplement_store/pages/screens/profile/my_orders.dart';

class ProfileTap extends StatefulWidget {
  const ProfileTap({super.key});

  @override
  State<ProfileTap> createState() => _ProfileTapState();
}

class _ProfileTapState extends State<ProfileTap> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserProvider>(context, listen: false).initializeUserData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user found')));
    }

    // Show loading indicator if data is being loaded
    if (userProvider.isLoading && userProvider.userData == null) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading profile...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Clean Header with Profile Image
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.surface,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Profile Image Section
                        Builder(
                          builder: (context) {
                            final avatarKey =
                                GlobalKey<UserAvatarPickerState>();
                            return SizedBox(
                              width: 150, // Increased to allow floating button
                              height: 150,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 130,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theme.colorScheme.primary,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.15,
                                            ),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: UserAvatarPicker(
                                          key: avatarKey,
                                          initialImageUrl:
                                              userProvider.avatarUrl,
                                          userId: user.uid,
                                          size: 120,
                                          showEditButton:
                                              false, // Hide internal button
                                          showDeleteButton: false,
                                          onImageChanged:
                                              (String? newAvatarUrl) async {
                                                await userProvider
                                                    .updateAvatarUrl(
                                                      newAvatarUrl,
                                                    );
                                              },
                                          onEditPressed: () async {}, // No-op
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Floating edit button
                                  Positioned(
                                    bottom: -10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () async {
                                        showModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                          ),
                                          builder: (context) {
                                            return SafeArea(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 24,
                                                      horizontal: 16,
                                                    ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.edit_rounded,
                                                      ),
                                                      title: const Text(
                                                        'Update Image',
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        (avatarKey.currentState
                                                                as UserAvatarPickerState)
                                                            .pickImage();
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                      ),
                                                      title: const Text(
                                                        'Delete Image',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        final confirm = await showDialog<bool>(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text(
                                                              'Delete Profile Image',
                                                            ),
                                                            content: const Text(
                                                              'Are you sure you want to delete your profile image?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'Cancel',
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop(true),
                                                                child: const Text(
                                                                  'Delete',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        if (confirm == true) {
                                                          (avatarKey.currentState
                                                                  as UserAvatarPickerState)
                                                              .removeImage();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.surface,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.18,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.edit_rounded,
                                          color: theme.colorScheme.onPrimary,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // User Info
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            String displayName =
                                userProvider.username ??
                                user.displayName ??
                                'User Name';

                            return Column(
                              children: [
                                Text(
                                  displayName,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 26,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userProvider.email ??
                                      user.email ??
                                      'user@example.com',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Stats Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              context,
                              'Orders',
                              userProvider.orderCount?.toString() ?? '0',
                              Icons.shopping_bag_outlined,
                              theme.colorScheme.primary,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              context,
                              'Favorites',
                              userProvider.favoriteCount?.toString() ?? '0',
                              Icons.favorite_outline,
                              theme.colorScheme.secondary,
                            ),
                          ),
                          if ((userProvider.badgeRank ?? 0) > 0) ...[
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                            Expanded(
                              child: _buildBadgeStatItem(
                                context,
                                userProvider.badgeRank!,
                                theme,
                              ),
                            ),
                          ],
                        ],
                      ),
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
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeStatItem(
    BuildContext context,
    int badgeRank,
    ThemeData theme,
  ) {
    IconData icon;
    Color color;
    String label;
    switch (badgeRank) {
      case 1:
        icon = Icons.emoji_events_rounded;
        color = Colors.amber;
        label = '#1 Most Ordered';
        break;
      case 2:
        icon = Icons.emoji_events_rounded;
        color = Colors.grey;
        label = '#2 Most Ordered';
        break;
      case 3:
        icon = Icons.emoji_events_rounded;
        color = Colors.brown;
        label = '#3 Most Ordered';
        break;
      default:
        icon = Icons.emoji_events_outlined;
        color = theme.colorScheme.outline;
        label = '';
    }
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Badge',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildSettingTile(
                context,
                'Theme Mode',
                'Current: ${themeProvider.getThemeModeName()}',
                Icons.palette_outlined,
                theme.colorScheme.secondary,
                trailing: _buildThemeModeSelector(themeProvider, theme),
              ),
              _buildDivider(theme),
              _buildSettingTile(
                context,
                'My Orders',
                'View your order history',
                Icons.receipt_long_outlined,
                theme.colorScheme.primary,
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => MyOrdersScreen()));
                },
              ),
              _buildDivider(theme),
              _buildSettingTile(
                context,
                'Account Settings',
                'Manage your account preferences',
                Icons.settings_outlined,
                theme.colorScheme.primary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account settings coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildDivider(theme),
              _buildSettingTile(
                context,
                'Help & Support',
                'Get help and contact support',
                Icons.help_outline,
                theme.colorScheme.tertiary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help & support coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildDivider(theme),
              _buildSettingTile(
                context,
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip_outlined,
                theme.colorScheme.primary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy coming soon!'),
                      duration: Duration(seconds: 2),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 20),
      child: Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
    );
  }

  Widget _buildThemeModeSelector(ThemeProvider themeProvider, ThemeData theme) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
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

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.error.withOpacity(0.2),
            blurRadius: 8,
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
                fontSize: 16,
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
      // Clear user data from provider
      Provider.of<UserProvider>(context, listen: false).clearUserData();

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SplashScreen(
              duration: const Duration(seconds: 4),
              nextScreen: const LoginPage(),
            ),
          ),
          (route) => false,
        );

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
