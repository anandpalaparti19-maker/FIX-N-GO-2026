import 'package:flutter/material.dart';
import 'api_service.dart';

class EarningsScreen extends StatefulWidget {
  @override
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final stats = await _apiService.getStats();
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings & Stats'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _stats == null 
          ? const Center(child: Text('Failed to load stats. Check connection.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: const Text('Wallet Balance'),
                      trailing: Text('\$${_stats?['walletBalance'] ?? 0}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Total Earnings'),
                      trailing: Text('\$${_stats?['totalEarnings'] ?? 0}', style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Completed Jobs'),
                      trailing: Text('${_stats?['completedOrdersCount'] ?? 0}', style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal requested successfully!')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                    child: const Text('REQUEST WITHDRAWAL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 32)
                ],
              ),
            ),
    );
  }
}
