import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'finding_tech_screen.dart';

class ScreenGuardScreen extends StatefulWidget {
  final String device;
  const ScreenGuardScreen({super.key, required this.device});

  @override
  State<ScreenGuardScreen> createState() => _ScreenGuardScreenState();
}

class _ScreenGuardScreenState extends State<ScreenGuardScreen> {
  String selectedGuard = 'Tempered Glass';

  final List<Map<String, dynamic>> guardTypes = [
    {
      'name': 'Tempered Glass',
      'price': 199,
      'icon': Icons.shield_rounded,
      'color': AppColors.brandGreen,
      'popular': true,
      'desc': 'Maximum protection',
    },
    {
      'name': 'Anti-Spy',
      'price': 299,
      'icon': Icons.visibility_off_rounded,
      'color': AppColors.accentCyan,
      'popular': false,
      'desc': 'Privacy screen',
    },
    {
      'name': 'Matte Guard',
      'price': 249,
      'icon': Icons.texture_rounded,
      'color': AppColors.accentOrange,
      'popular': false,
      'desc': 'Anti-glare finish',
    },
    {
      'name': 'Premium UV',
      'price': 399,
      'icon': Icons.star_rounded,
      'color': const Color(0xFFD946EF),
      'popular': false,
      'desc': 'Best quality',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selected = guardTypes.firstWhere((g) => g['name'] == selectedGuard);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Choose guard type',
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textWhite),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Text(
                  widget.device,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: guardTypes.length,
                  itemBuilder: (context, i) {
                    final g = guardTypes[i];
                    final isSelected = selectedGuard == g['name'];
                    return GestureDetector(
                      onTap: () => setState(() => selectedGuard = g['name'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (g['color'] as Color).withOpacity(0.15)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? (g['color'] as Color)
                                : AppColors.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(
                                  color: (g['color'] as Color).withOpacity(0.2),
                                  blurRadius: 12)]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: (g['color'] as Color).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(g['icon'] as IconData,
                                      color: g['color'] as Color, size: 20),
                                ),
                                const Spacer(),
                                if (g['popular'] as bool)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('Best',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color: AppColors.brandGreen,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              g['name'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textWhite,
                              ),
                            ),
                            Text(
                              g['desc'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${g['price']}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: g['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brandGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.brandGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ Includes professional fitting',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandGreen,
                            ),
                          ),
                          Text(
                            'Bubble-free installation at your door',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FindingTechScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Book Installation — ₹${selected['price']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
