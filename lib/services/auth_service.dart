import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://172.20.10.4:5000';
  static String? token;

static Future<String> signup(String fullName, String email, String phone, 
                            String password, String dob, String role) async {
  final res = await http.post(
    Uri.parse('$baseUrl/signup'),  // Remove /api/
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'dob': dob,
      'role': role
    }),
  );

  if (res.statusCode == 201) {
    return 'Success'; // Backend only returns msg
  } else {
    throw Exception('Signup failed: ${res.body}');
  }
}

static Future<Map<String, dynamic>> login(String email, String password) async {
  final res = await http.post(
    Uri.parse('$baseUrl/login'),  // Remove /api/
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body); // Now returns {token, role, userId}
  } else {
    throw Exception('Login failed: ${res.body}');
  }
}

static Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load profile: ${response.body}');
  }

  static Future<bool> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String dob,
    File? profilePicture,
  }) async {
    var request = http.MultipartRequest(
      'PUT', 
      Uri.parse('$baseUrl/users/$userId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    
    if (profilePicture != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profilePicture', profilePicture.path),
      );
    }
    
    request.fields.addAll({
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
    });

    var response = await request.send();
    if (response.statusCode == 200) return true;
    throw Exception('Update failed: ${await response.stream.bytesToString()}');
  }

}
