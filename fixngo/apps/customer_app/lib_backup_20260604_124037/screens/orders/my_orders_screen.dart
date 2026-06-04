import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getOrders();
      final orders = List<Map<String, dynamic>>.from(response['data'] ?? []);
      return orders;
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0C0C0C)), onPressed: () => Navigator.pop(context)),
        title: Text('My Orders', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C))),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📦', style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No orders yet', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C))),
                  const SizedBox(height: 8),
                  Text('Book a service to get started', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9B9B9B))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/order-details', arguments: order['_id']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${order['brand']} ${order['model']}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              order['status'].toString().toUpperCase(),
                              style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: _getStatusColor(order['status'])),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Issues: ${order['issues']?.join(', ') ?? 'N/A'}', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0xFF9B9B9B))),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${order['total']}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1A56FF))),
                          Text(order['technician'] ?? 'Not assigned', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0xFF9B9B9B))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFC107);
      case 'assigned':
        return const Color(0xFF1A56FF);
      case 'in_progress':
        return const Color(0xFF1A56FF);
      case 'completed':
        return const Color(0xFF00C853);
      default:
        return const Color(0xFF9B9B9B);
    }
  }
}
