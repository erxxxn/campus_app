import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Contact Us'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Contact Us'),
            Tab(text: 'Report'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactUsTab(),
          _buildReportTab(),
        ],
      ),
    );
  }

  Widget _buildContactUsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Get the help you need", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSupportCard("Account And Security", Icons.lock, "Help with account issues and login security."),
        const SizedBox(height: 12),
        _buildSupportCard("Wallet Payment", Icons.account_balance_wallet, "Issues with wallet or payments."),
        const SizedBox(height: 12),
        _buildSupportCard("FAQ", Icons.question_answer, "Frequently Asked Questions", onTap: _showFAQ),
      ],
    );
  }

  Widget _buildReportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildExpandableTile("Customer Service", [
          ListTile(leading: const Icon(Icons.phone), title: const Text("Call us: +60 123456789")),
          ListTile(leading: const Icon(Icons.email), title: const Text("Email: support@example.com")),
        ]),
        const SizedBox(height: 12),
        _buildExpandableTile("Website", [
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text("Visit our website"),
            onTap: () {
              // You can use url_launcher here if needed
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildSupportCard(String title, IconData icon, String subtitle, {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildExpandableTile(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: children,
      ),
    );
  }

  void _showFAQ() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          shrinkWrap: true,
          children: const [
            Text("FAQs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Q1: How do I reset my password?\nA: Go to Settings > Security > Reset Password.\n"),
            Text("Q2: Why is my wallet not working?\nA: Check if your card is linked properly.\n"),
          ],
        ),
      ),
    );
  }
}
