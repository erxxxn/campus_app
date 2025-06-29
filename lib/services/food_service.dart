import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FoodService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<dynamic>> fetchList() async {
    final response = await http.get(Uri.parse('$baseUrl/api/foods'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load food list');
    }
  }

  static Future<void> addFood({
    required String userId,
    required String title,
    required String description,
    required String price,
    required String quantity,
    required DateTime expiryDate,
    File? imageFile,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/foods'));
    request.fields['userId'] = userId;
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['quantity'] = quantity;
    request.fields['expiryDate'] = expiryDate.toIso8601String();

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      final respStr = await response.stream.bytesToString();
      throw Exception('Failed to add food: $respStr');
    }
  }
}
