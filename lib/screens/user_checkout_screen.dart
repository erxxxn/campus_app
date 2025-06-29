import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'user_paymentgateway_screen.dart';
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  final double totalPrice;
  const CheckoutScreen({super.key, required this.totalPrice});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isProcessing = false;

  Future<void> _submitOrder() async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PaymentGatewayScreen(
        amount: widget.totalPrice,
        onSuccess: () async {
          // Your existing backend code
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? '';
          
          final response = await http.post(
            Uri.parse('http://172.20.10.4:5000/api/orders'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({'total': widget.totalPrice}),
          );
          
          if (response.statusCode == 200) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        onRetry: () => _submitOrder(), // Retries the same flow
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Checkout'), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Total Amount: RM ${widget.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
  onPressed: _submitOrder,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    minimumSize: const Size.fromHeight(50),
  ),
  child: const Text('CONFIRM & PLACE ORDER'),
),
          ],
        ),
      ),
    );
  }
}
