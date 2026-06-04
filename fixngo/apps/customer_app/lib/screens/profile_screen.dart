import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A2A4A), AppColors.bgDark],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            )),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.brandBlue, AppColors.accentCyan],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.bgDark, width: 3),
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: Colors.white, size: 44),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.brandGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.bgDark, width: 2),
                            ),
                            child: const Icon(Icons.verified,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Rahul Sharma',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        )),
                    Text('+91 98765 43210',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 20),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(value: '7', label: 'Repairs'),
                        Container(
                            width: 1, height: 36, color: AppColors.borderColor),
                        _StatItem(value: '₹3,495', label: 'Saved'),
                        Container(
                            width: 1, height: 36, color: AppColors.borderColor),
                        _StatItem(value: '4.9★', label: 'Rating'),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu items
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MenuSection(
                      title: 'Account',
                      items: [
                        _MenuItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Personal Info',
                            onTap: () {}),
                        _MenuItem(
                            icon: Icons.location_on_outlined,
                            label: 'Saved Addresses',
                            badge: '2',
                            onTap: () {}),
                        _MenuItem(
                            icon: Icons.payment_rounded,
                            label: 'Payment Methods',
                            onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _MenuSection(
                      title: 'Support',
                      items: [
                        _MenuItem(
                            icon: Icons.help_outline_rounded,
                            label: 'Help & FAQ',
                            onTap: () {}),
                        _MenuItem(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Chat with Support',
                            onTap: () {}),
                        _MenuItem(
                            icon: Icons.star_outline_rounded,
                            label: 'Rate the App',
                            onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _MenuSection(
                      title: 'Preferences',
                      items: [
                        _MenuItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            trailing: Switch(
                              value: true,
                              onChanged: (_) {},
                              activeColor: AppColors.brandBlue,
                            ),
                            onTap: () {}),
                        _MenuItem(
                            icon: Icons.language_rounded,
                            label: 'Language',
                            badge: 'EN',
                            onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Logout button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.statusRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.statusRed.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: AppColors.statusRed, size: 20),
                          const SizedBox(width: 10),
                          Text('Log Out',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.statusRed,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text('Fix-N-Go v1.0.0',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
            )),
        Text(label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            )),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            )),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (i < items.length - 1)
                    Container(
                      margin: const EdgeInsets.only(left: 56),
                      height: 1,
                      color: AppColors.borderColor,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Icon(icon, size: 18, color: AppColors.brandBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  )),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandBlue,
                    )),
              ),
            if (trailing != null) trailing!,
            if (badge == null && trailing == null)
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
