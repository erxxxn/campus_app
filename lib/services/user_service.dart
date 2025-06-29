// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _baseUrl = 'http://172.20.10.4:5000/api/users';

  // GET user profile
  static Future<Map<String, dynamic>> getUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    
    final response = await http.get(
      Uri.parse('$_baseUrl/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'id': data['_id'] ?? userId,
        'name': data['name'] ?? 'No Name',
        'email': data['email'] ?? 'No Email',
        'phone': data['phone'] ?? '',
        'dob': data['dob'] ?? '',
        'avatarUrl': data['avatarUrl'] ?? 'https://via.placeholder.com/150',
      };
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  // PUT update user profile
  static Future<void> updateUser({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? dob,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse('$_baseUrl/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (dob != null) 'dob': dob,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }
}