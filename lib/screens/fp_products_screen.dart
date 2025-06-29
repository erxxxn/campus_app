import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'fp_updatefood_screen.dart';

class MyProductsScreen extends StatefulWidget {
  final String userId;
  const MyProductsScreen({super.key, required this.userId});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List products = [];
  int _selectedTab = 0; // 0 = Available, 1 = Out of Stock

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

Future<void> fetchMyProducts() async {
  final token = await _getToken();
  print("Fetching products for user: ${widget.userId}"); // Debug log
  
  try {
    final response = await http.get(
      Uri.parse('http://172.20.10.4:5000/api/food/provider/${widget.userId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("Response status: ${response.statusCode}"); // Debug log
    print("Response body: ${response.body}"); // Debug log

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        products = responseData.map((item) {
          // Ensure all required fields exist
          return {
            '_id': item['_id'] ?? '',
            'title': item['title'] ?? 'No Name',
            'description': item['description'] ?? '',
            'price': item['price']?.toDouble() ?? 0.0,
            'quantity': item['quantity'] ?? 0,
            'expiryDate': item['expiryDate'],
          };
        }).toList();
      });
    } else {
      throw Exception('Failed with status ${response.statusCode}');
    }
  } catch (e) {
    print("Error fetching products: $e"); // Debug log
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load products: $e')),
    );
  }
}

  Future<void> deleteProduct(String productId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('http://172.20.10.4:5000/api/food/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      fetchMyProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete product"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToUpdateScreen(Map<String, dynamic> foodItem) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UpdateFoodScreen(
        userId: widget.userId,
        foodItem: foodItem,
        onUpdate: fetchMyProducts, // Refresh list after update
      ),
    ),
  );
}

  @override
  void initState() {
    super.initState();
    fetchMyProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Availability Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Available'),
                    selected: _selectedTab == 0,
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: _selectedTab == 0 ? Colors.white : Colors.black,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedTab = selected ? 0 : _selectedTab);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Out Of Stock'),
                    selected: _selectedTab == 1,
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: _selectedTab == 1 ? Colors.white : Colors.black,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedTab = selected ? 1 : _selectedTab);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return _buildProductCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

Widget _buildProductCard(Map<String, dynamic> item) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image (Placeholder)
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Icon(
                Icons.fastfood,
                size: 50,
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Product Name
          Text(
            item['title'] ?? 'No Name',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Date and Time
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _formatDate(item['expiryDate'] ?? ''),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                '01:20 PM', // Static time for demo
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Price and Quantity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                '${item['quantity'] ?? 0} items available',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Update and Delete Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigateToUpdateScreen(item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Update'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => deleteProduct(item['_id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}