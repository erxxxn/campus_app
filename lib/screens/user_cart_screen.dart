import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final String userId;
  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('http://172.20.10.4:5000/api/cart'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          cartItems = json.decode(response.body) ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Cart fetch error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeItem(String foodId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      await http.delete(
        Uri.parse('http://172.20.10.4:5000/api/cart/$foodId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      _fetchCart();
    } catch (e) {
      print('Remove item error: $e');
    }
  }

  double get totalPrice => cartItems.fold(0.0, (sum, item) {
        final price = item['price'] as num? ?? 0;
        final quantity = item['quantity'] as num? ?? 1;
        return sum + (price * quantity);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Cart'), 
        backgroundColor: Colors.orange
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: item['imageUrl'] != null 
                                    ? NetworkImage(item['imageUrl'])
                                    : const AssetImage('assets/default_food.png') as ImageProvider,
                                child: item['imageUrl'] == null ? const Icon(Icons.fastfood) : null,
                              ),
                              title: Text(item['title'] ?? 'Unknown Item'),
                              subtitle: Text(
                                'Qty: ${item['quantity'] ?? 1} • RM ${(item['price'] ?? 0).toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(item['foodId']?.toString() ?? ''),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('RM ${totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(totalPrice: totalPrice),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: const Text("Proceed to Checkout"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}