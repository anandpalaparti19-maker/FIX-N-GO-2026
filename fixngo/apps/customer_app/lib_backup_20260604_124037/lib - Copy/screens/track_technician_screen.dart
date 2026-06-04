import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TrackTechnicianScreen extends StatefulWidget {
  const TrackTechnicianScreen({super.key});

  @override
  State<TrackTechnicianScreen> createState() => _TrackTechnicianScreenState();
}

class _TrackTechnicianScreenState extends State<TrackTechnicianScreen>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  int _etaMinutes = 12;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Countdown ETA
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _etaMinutes = 9);
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _etaMinutes = 6);
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Track Technician',
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.phone_rounded,
                  color: AppColors.brandGreen, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Live map
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _TrackMapPainter(),
                        size: Size.infinite,
                      ),
                      // Route line
                      CustomPaint(
                        painter: _RoutePainter(),
                        size: Size.infinite,
                      ),
                      // Moving technician icon
                      AnimatedBuilder(
                        animation: _moveController,
                        builder: (_, __) {
                          final t = _moveController.value;
                          final x = 0.2 + (0.3 * t);
                          final y = 0.2 + (0.3 * t);
                          return Positioned(
                            left: MediaQuery.of(context).size.width * x - 50,
                            top: 300 * y - 10,
                            child: Transform.scale(
                              scale: _pulseAnim.value,
                              child: Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.brandBlue,
                                          AppColors.accentCyan
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              AppColors.brandBlue.withOpacity(0.5),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.person_rounded,
                                        color: Colors.white, size: 22),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('Ravi',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Destination marker
                      Positioned(
                        right: 50,
                        bottom: 80,
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.statusRed,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.statusRed.withOpacity(0.4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.home_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.statusRed,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('You',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      // ETA badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.brandGreen),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_rounded,
                                  color: AppColors.brandGreen, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$_etaMinutes min away',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Info cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Technician info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.brandBlue, AppColors.accentCyan],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ravi Kumar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textWhite,
                                  )),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.starYellow, size: 14),
                                  const SizedBox(width: 3),
                                  Text('4.9',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Text(' · 230 repairs',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _ActionButton(
                              icon: Icons.chat_bubble_rounded,
                              color: AppColors.brandBlue,
                              onTap: () {},
                            ),
                            const SizedBox(width: 10),
                            _ActionButton(
                              icon: Icons.phone_rounded,
                              color: AppColors.brandGreen,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress steps
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            )),
                        const SizedBox(height: 12),
                        _StatusStep(
                            label: 'Booking Confirmed',
                            isDone: true,
                            icon: Icons.check_circle_rounded),
                        _StatusStep(
                            label: 'Technician On the Way',
                            isDone: true,
                            isActive: true,
                            icon: Icons.directions_bike_rounded),
                        _StatusStep(
                            label: 'Repair In Progress',
                            isDone: false,
                            icon: Icons.build_rounded),
                        _StatusStep(
                            label: 'Completed',
                            isDone: false,
                            isLast: true,
                            icon: Icons.verified_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isActive;
  final bool isLast;
  final IconData icon;

  const _StatusStep({
    required this.label,
    required this.isDone,
    this.isActive = false,
    this.isLast = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? (isActive ? AppColors.brandBlue : AppColors.brandGreen)
        : AppColors.borderColor;

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? color.withOpacity(0.2) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            if (!isLast)
              Container(width: 2, height: 20, color: color.withOpacity(0.4)),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isDone ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0D1926);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF1A2A40).withOpacity(0.5)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFF1E3A5A)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.4, 0),
        Offset(size.width * 0.4, size.height),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.7, 0),
        Offset(size.width * 0.7, size.height),
        roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandBlue.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.75,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
