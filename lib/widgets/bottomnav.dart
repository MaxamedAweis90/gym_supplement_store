import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gym_supplement_store/pages/screens/cart/cart.dart';
import 'package:gym_supplement_store/pages/screens/home/home.dart';
import 'package:gym_supplement_store/pages/screens/favorite/favorite.dart';
import 'package:gym_supplement_store/pages/screens/profile/profile.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  int currentTabIndex = 0;

  // List of pages to be displayed in the BottomNav.
  // They are instantiated once and their state will be preserved.
  final List<Widget> _pages = [
    HomeTap(),
    FavoriteTap(),
    CartTap(),
    ProfileTap(),
  ];

  // Data for the navigation bar items for cleaner code.
  final List<({String label, IconData icon})> _navItems = [
    (label: 'Home', icon: Icons.home_outlined),
    (label: 'Favorites', icon: Icons.favorite_outline),
    (label: 'Cart', icon: Icons.shopping_cart_outlined),
    (label: 'Profile', icon: Icons.person_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: currentTabIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.25)
                    : theme.shadowColor.withOpacity(0.12),
                blurRadius: theme.brightness == Brightness.dark ? 24 : 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: CurvedNavigationBar(
            height: 70,
            backgroundColor: Colors.transparent, // Let shadow show
            color: theme.brightness == Brightness.dark
                ? Colors.grey[900]!
                : theme.colorScheme.surface,
            animationDuration: const Duration(milliseconds: 350),
            index: currentTabIndex,
            onTap: (int index) {
              setState(() {
                currentTabIndex = index;
              });
            },
            items: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = currentTabIndex == index;
              return Tooltip(
                message: item.label,
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  size: 30.0,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
