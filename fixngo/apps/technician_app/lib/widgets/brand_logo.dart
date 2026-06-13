import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 140,
    this.paddingScale = 0.12,
  });

  final double size;
  final double paddingScale;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(size * 0.28);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * paddingScale),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1F1712), Color(0xFF130E0B)]
              : const [Color(0xFFFFFFFF), Color(0xFFFFECE6)],
        ),
        border: Border.all(
          color: AppColors.border.withValues(alpha: isDark ? 0.95 : 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: isDark ? 0.24 : 0.18),
            blurRadius: size * 0.24,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
