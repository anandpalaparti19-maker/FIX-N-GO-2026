import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 140,
    this.paddingScale = 0.14,
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
              ? const [Color(0xFF12213A), Color(0xFF0B1526)]
              : const [Color(0xFFFFFFFF), Color(0xFFEAF2FF)],
        ),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: isDark ? 0.9 : 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGlow.withValues(alpha: isDark ? 0.28 : 0.2),
            blurRadius: size * 0.22,
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
