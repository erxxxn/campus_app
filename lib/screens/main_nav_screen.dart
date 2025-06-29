import 'package:flutter/material.dart';
import 'package:campus_app/screens/food_browsing_screen.dart';
import 'package:campus_app/screens/order_history_screen.dart';
import 'package:campus_app/screens/user_profile_screen.dart';
import 'package:campus_app/screens/FP_profile_screen.dart';
import 'package:campus_app/screens/user_cart_screen.dart'; // Add this import

class MainNavScreen extends StatefulWidget {
  final String role;
  final String userId;

  const MainNavScreen({
    Key? key,
    required this.role,
    required this.userId,
  }) : super(key: key);

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens based on user role
    _screens = widget.role == 'user'
        ? [
            FoodBrowsingScreen(userId: widget.userId),
            OrderHistoryScreen(userId: widget.userId),
            CartScreen(userId: widget.userId), // Added Cart Screen
            UserProfileScreen(userId: widget.userId),
          ]
        : [
            // For providers (food partners)
            ProfileScreen(userId: widget.userId),
          ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: widget.role == 'user'
          ? BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.fastfood),
                  label: 'Browse',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
            )
          : null, // No bottom nav for providers
    );
  }
}