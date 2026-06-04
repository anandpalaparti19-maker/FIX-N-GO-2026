import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> activeOrders = [
    {
      'id': '#FNG-2025',
      'service': 'Screen Repair',
      'device': 'Samsung Galaxy S24',
      'tech': 'Ravi Kumar',
      'status': 'On the Way',
      'statusColor': AppColors.brandBlue,
      'price': 999,
      'time': '~8 min',
      'icon': Icons.broken_image_rounded,
    },
  ];

  final List<Map<String, dynamic>> completedOrders = [
    {
      'id': '#FNG-2021',
      'service': 'Battery Replacement',
      'device': 'iPhone 14',
      'tech': 'Arjun R.',
      'status': 'Completed',
      'statusColor': AppColors.brandGreen,
      'price': 599,
      'time': 'May 18',
      'icon': Icons.battery_charging_full_rounded,
    },
    {
      'id': '#FNG-2019',
      'service': 'Tempered Glass',
      'device': 'OnePlus 12',
      'tech': 'Suresh K.',
      'status': 'Completed',
      'statusColor': AppColors.brandGreen,
      'price': 199,
      'time': 'May 10',
      'icon': Icons.shield_rounded,
    },
    {
      'id': '#FNG-2014',
      'service': 'Charging Port Fix',
      'device': 'Samsung Galaxy A54',
      'tech': 'Kiran M.',
      'status': 'Completed',
      'statusColor': AppColors.brandGreen,
      'price': 499,
      'time': 'Apr 28',
      'icon': Icons.usb_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'My Orders',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textWhite,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    GoogleFonts.poppins(fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(activeOrders, isActive: true),
                  _buildOrdersList(completedOrders),
                  _buildEmptyState('No cancelled orders'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders,
      {bool isActive = false}) {
    if (orders.isEmpty) {
      return _buildEmptyState('No orders yet');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final order = orders[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.brandBlue.withOpacity(0.3) : AppColors.borderColor,
            ),
            boxShadow: isActive
                ? [BoxShadow(
                    color: AppColors.brandBlue.withOpacity(0.08),
                    blurRadius: 16)]
                : [],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: (order['statusColor'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(order['icon'] as IconData,
                        color: order['statusColor'] as Color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order['service'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            )),
                        Text(order['device'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            )),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${order['price']}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          )),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (order['statusColor'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order['status'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: order['statusColor'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person_rounded,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(order['tech'] as String,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMuted)),
                  const Spacer(),
                  Text(order['id'] as String,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time_rounded,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text(order['time'] as String,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text('Track Technician →',
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 36, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(message,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
