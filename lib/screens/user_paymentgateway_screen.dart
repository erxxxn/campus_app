import 'dart:math';
import 'package:flutter/material.dart';

class PaymentGatewayScreen extends StatelessWidget {
  final double amount;
  final VoidCallback onSuccess;
  final VoidCallback onRetry;

  const PaymentGatewayScreen({
    super.key,
    required this.amount,
    required this.onSuccess,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PaymentProcessingWidget(
        amount: amount,
        onSuccess: onSuccess,
        onRetry: onRetry,
      ),
    );
  }
}

class PaymentProcessingWidget extends StatefulWidget {
  final double amount;
  final VoidCallback onSuccess;
  final VoidCallback onRetry;

  const PaymentProcessingWidget({
    super.key,
    required this.amount,
    required this.onSuccess,
    required this.onRetry,
  });

  @override
  State<PaymentProcessingWidget> createState() => _PaymentProcessingWidgetState();
}

class _PaymentProcessingWidgetState extends State<PaymentProcessingWidget> {
  bool _isProcessing = true;
  String _selectedMethod = 'Credit Card';
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _simulatePayment();
  }

  Future<void> _simulatePayment() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // 80% success rate for demo
    final isSuccess = _random.nextDouble() < 0.8;

    if (mounted) {
      if (isSuccess) {
        widget.onSuccess(); // Proceed to real backend submission
      } else {
        setState(() => _isProcessing = false); // Show retry UI
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('PAYMENT SUMMARY',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:',
                          style: TextStyle(color: Colors.grey)),
                      Text('RM ${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Payment Processing Content
          Expanded(
            child: _isProcessing 
                ? _buildProcessingUI() 
                : _buildRetryUI(),
          ),

          // Pay Now Button (visible only in retry mode)
          if (!_isProcessing) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _isProcessing = true);
                  _simulatePayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('TRY AGAIN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessingUI() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Processing Payment...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.orange),
          strokeWidth: 5,
        ),
        const SizedBox(height: 30),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: Colors.orange),
                const SizedBox(width: 15),
                Text(_selectedMethod,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const Spacer(),
        const Text('DEMO MODE',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const Text('No real payment will be processed',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildRetryUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 20),
          const Text('Payment Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            'Demo payment simulation failed\nPlease try again',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}