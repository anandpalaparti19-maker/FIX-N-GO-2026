import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> services = [
    {'icon': '🚰', 'name': 'Plumbing', 'desc': 'Pipes, fixtures, leaks'},
    {'icon': '⚡', 'name': 'Electrical', 'desc': 'Wiring, outlets, switches'},
    {'icon': '🎨', 'name': 'Painting', 'desc': 'Wall, ceiling, doors'},
    {'icon': '🔨', 'name': 'Carpentry', 'desc': 'Wood work, repairs'},
    {'icon': '❄️', 'name': 'AC Service', 'desc': 'Cooling, maintenance'},
    {'icon': '🛠️', 'name': 'Appliance', 'desc': 'All appliances'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Fix-N-Go', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0C0C0C))),
        actions: [IconButton(icon: const Icon(Icons.person, color: Color(0xFF0C0C0C)), onPressed: () => Navigator.pushNamed(context, '/profile'))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1A56FF), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What service do you need?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Book a professional today', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Popular Services', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C))),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/booking-location', arguments: service['name']),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(service['icon'], style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(service['name'], style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C))),
                          Text(service['desc'], textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w400, color: const Color(0xFF9B9B9B))),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Recent Orders', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C))),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/my-orders'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('View all orders', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C))),
                          const SizedBox(height: 4),
                          Text('Track your service requests', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w400, color: const Color(0xFF9B9B9B))),
                        ],
                      ),
                      const Icon(Icons.arrow_forward, color: Color(0xFF1A56FF)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
