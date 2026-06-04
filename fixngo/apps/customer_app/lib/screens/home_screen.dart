import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'select_device_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildHeroCard(context),
              _buildServicesSection(context),
              _buildPopularRepairs(context),
              _buildHowItWorks(context),
              _buildReviewsSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandBlue, AppColors.accentCyan],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.build_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fix-N-Go',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  )),
              Text('Doorstep mobile service',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  )),
            ],
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.notifications_outlined,
                      color: AppColors.textSecondary, size: 22),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.statusRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.brandBlue, Color(0xFF1A3A8F)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBlue.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('👋', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  'Hi Rahul',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'What needs fixing?',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Doorstep in under 60 min',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our services',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 14),
          _ServiceCard(
            icon: Icons.smartphone_rounded,
            title: 'Mobile Repair',
            subtitle: 'Screen · Battery · Port',
            color: AppColors.brandBlue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SelectDeviceScreen(serviceType: 'repair'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ServiceCard(
            icon: Icons.shield_rounded,
            title: 'Screen Guard',
            subtitle: 'Tempered · Anti-spy',
            color: AppColors.brandGreen,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SelectDeviceScreen(serviceType: 'guard'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRepairs(BuildContext context) {
    final repairs = [
      {'icon': Icons.broken_image_rounded, 'label': 'Screen\nRepair', 'price': '₹999'},
      {'icon': Icons.battery_charging_full_rounded, 'label': 'Battery\nReplace', 'price': '₹599'},
      {'icon': Icons.usb_rounded, 'label': 'Charging\nPort', 'price': '₹499'},
      {'icon': Icons.volume_up_rounded, 'label': 'Speaker\nFix', 'price': '₹399'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Repairs',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: repairs.map((r) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectDeviceScreen(serviceType: 'repair'),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(right: repairs.indexOf(r) < 3 ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(r['icon'] as IconData,
                            color: AppColors.brandBlue, size: 26),
                        const SizedBox(height: 8),
                        Text(
                          r['label'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'From ${r['price']}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.brandGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final steps = [
      {'icon': Icons.phone_android_rounded, 'title': 'Choose Service', 'desc': 'Select your device & issue'},
      {'icon': Icons.location_on_rounded, 'title': 'Enter Location', 'desc': 'We come to your doorstep'},
      {'icon': Icons.check_circle_rounded, 'title': 'Done!', 'desc': 'Fixed under 60 minutes'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: steps.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.brandBlue.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.brandBlue.withOpacity(0.3)),
                              ),
                              child: Icon(s['icon'] as IconData,
                                  color: AppColors.brandBlue, size: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              s['title'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              s['desc'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < steps.length - 1)
                        const Icon(Icons.arrow_forward_ios,
                            size: 12, color: AppColors.textMuted),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Customer Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star, color: AppColors.starYellow, size: 16),
              const SizedBox(width: 4),
              Text('4.9 (2.4k)',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: const [
                _ReviewCard(
                  name: 'Arjun S.',
                  review: 'Super fast! Screen replaced in 40 mins at my office.',
                  rating: 5,
                ),
                _ReviewCard(
                  name: 'Priya M.',
                  review: 'Technician was professional and the price was fair.',
                  rating: 5,
                ),
                _ReviewCard(
                  name: 'Kiran R.',
                  review: 'Battery replaced perfectly. Will use again!',
                  rating: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String review;
  final int rating;

  const _ReviewCard({
    required this.name,
    required this.review,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.brandBlue.withOpacity(0.2),
                child: Text(name[0],
                    style: GoogleFonts.poppins(
                        color: AppColors.brandBlue, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text(name,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) => Icon(
              Icons.star,
              size: 13,
              color: i < rating ? AppColors.starYellow : AppColors.borderColor,
            )),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              review,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
