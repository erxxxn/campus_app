import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  final String userId;

  const OrderHistoryScreen({super.key, required this.userId});

@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 3, // Number of tabs
    child: Scaffold(
      backgroundColor: Colors.white, // 👈 Set scaffold background color here
      appBar: AppBar(
        backgroundColor: Colors.orange, // Optional: app bar color
        title: const Text('My Orders'),
        bottom: const TabBar(
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          _OrderTab(),
          Center(child: Text('No completed orders')),
          Center(child: Text('No cancelled orders')),
        ],
      ),
    ),
  );
}
}

class _OrderTab extends StatelessWidget {
  const _OrderTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Image.asset('assets/shake.png', width: 60, fit: BoxFit.cover),
            title: const Text('Strawberry shake'),
            subtitle: const Text('2 items'),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('\$20.00'),
                SizedBox(height: 4),
                Text('29 Nov, 01:20 pm', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        )
      ],
    );
  }
}
