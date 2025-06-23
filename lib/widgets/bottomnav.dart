import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gym_supplement_store/pages/screens/cart.dart';
import 'package:gym_supplement_store/pages/screens/home.dart';
import 'package:gym_supplement_store/pages/screens/favorite.dart';
import 'package:gym_supplement_store/pages/screens/profile.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  late List<Widget> pages;

  late HomeTap hometap;
  late FavoriteTap favoritetap;
  late CartTap carttap;
  late ProfileTap profiletap;

  int currentTabIndex = 0;

  @override
  void initState() {
    hometap = HomeTap();
    favoritetap = FavoriteTap();
    carttap = CartTap();
    profiletap = ProfileTap();
    pages = [hometap, favoritetap, carttap, profiletap];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        extendBody: true, // For shadow and floating effect
        body: pages[currentTabIndex],
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
            items: [
              Tooltip(
                message: 'Home',
                child: Icon(
                  Icons.home_outlined,
                  color: currentTabIndex == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  size: 30.0,
                ),
              ),
              Tooltip(
                message: 'Favorites',
                child: Icon(
                  Icons.favorite_outline,
                  color: currentTabIndex == 1
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  size: 30.0,
                ),
              ),
              Tooltip(
                message: 'Cart',
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: currentTabIndex == 2
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  size: 30.0,
                ),
              ),
              Tooltip(
                message: 'Profile',
                child: Icon(
                  Icons.person_outlined,
                  color: currentTabIndex == 3
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  size: 30.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
