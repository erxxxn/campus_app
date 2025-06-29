import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/FP_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

Future<Widget> _getInitialScreen() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final role = prefs.getString('role');
  final userId = prefs.getString('userId');

  if (token != null && role != null && userId != null) {
    return MainNavScreen (role: role, userId: userId);
  }
  return const LoginScreen();
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SharePlus',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

      routes: {
        '/profile': (ctx) {
          final userId = ModalRoute.of(ctx)!.settings.arguments as String;
          return ProfileScreen(userId: userId);
        },
      },
    );
  }
}
