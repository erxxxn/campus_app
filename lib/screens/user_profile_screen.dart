import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import 'useredit_profile_screen.dart';
import 'order_history_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart';
import 'user_fav_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final data = await UserService.getUser(widget.userId);
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Header
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          _userData['avatarUrl'] ?? 'https://via.placeholder.com/150',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userData['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(_userData['email'] ?? 'No email'),
                      Text(_userData['phone'] ?? 'No phone number'),
                      const SizedBox(height: 24),
                    ],
                  ),

                  // Action Buttons
                  _buildProfileButton(
                    context,
                    "My Orders",
                    Icons.shopping_bag,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderHistoryScreen(userId: widget.userId),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileButton(
                    context,
                    "My Reviews",
                    Icons.reviews,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reviews feature coming soon!')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
_buildProfileButton(
  context,
  "My Favorites",
  Icons.favorite,
  () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FavoriteScreen(userId: widget.userId),
    ),
  ),
),

                  const SizedBox(height: 12),
                  _buildProfileButton(
                    context,
                    "Help & Support",
                    Icons.help_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Edit Profile Button
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          userData: _userData,
                          onSave: _loadUserData,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Edit Profile"),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Log Out"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileButton(
    BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.2),
          child: Icon(icon, color: Colors.orange),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}