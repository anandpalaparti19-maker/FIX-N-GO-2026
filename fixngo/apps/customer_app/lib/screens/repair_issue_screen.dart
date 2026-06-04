import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'finding_tech_screen.dart';

class RepairIssueScreen extends StatefulWidget {
  final String device;
  const RepairIssueScreen({super.key, required this.device});

  @override
  State<RepairIssueScreen> createState() => _RepairIssueScreenState();
}

class _RepairIssueScreenState extends State<RepairIssueScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  bool _isLoading = false;
  final Set<String> selectedIssues = {'Screen broken'};

  final List<Map<String, dynamic>> issues = [
    {
      'name': 'Screen broken',
      'price': 999,
      'icon': Icons.broken_image_rounded,
      'color': AppColors.brandBlue,
    },
    {
      'name': 'Battery issue',
      'price': 599,
      'icon': Icons.battery_alert_rounded,
      'color': AppColors.statusOrange,
    },
    {
      'name': 'Charging port',
      'price': 499,
      'icon': Icons.usb_rounded,
      'color': AppColors.accentCyan,
    },
    {
      'name': 'Speaker / Mic',
      'price': 399,
      'icon': Icons.volume_up_rounded,
      'color': const Color(0xFFD946EF),
    },
    {
      'name': 'Back glass',
      'price': 799,
      'icon': Icons.phone_android_rounded,
      'color': AppColors.brandGreen,
    },
    {
      'name': 'Camera issue',
      'price': 699,
      'icon': Icons.camera_alt_rounded,
      'color': AppColors.statusRed,
    },
    {
      'name': 'Water damage',
      'price': 1299,
      'icon': Icons.water_drop_rounded,
      'color': AppColors.accentCyan,
    },
    {
      'name': 'Software issue',
      'price': 299,
      'icon': Icons.settings_rounded,
      'color': AppColors.textSecondary,
    },
  ];

  int get totalPrice {
    return issues
        .where((i) => selectedIssues.contains(i['name']))
        .fold(0, (sum, i) => sum + (i['price'] as int));
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
        title: Text(
          "What's the issue?",
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
              Row(
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
                  const SizedBox(width: 10),
                  Text(
                    'Select all that apply',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: issues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final issue = issues[i];
                    final isSelected = selectedIssues.contains(issue['name']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            if (selectedIssues.length > 1) {
                              selectedIssues.remove(issue['name']);
                            }
                          } else {
                            selectedIssues.add(issue['name'] as String);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandBlue.withOpacity(0.12)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandBlue
                                : AppColors.borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (issue['color'] as Color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(issue['icon'] as IconData,
                                  color: issue['color'] as Color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    issue['name'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.textWhite
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'From ₹${issue['price']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.brandBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.brandBlue
                                      : AppColors.borderColor,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Continue · ₹$totalPrice est.',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
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

  Future<void> _createOrder() async {
    setState(() => _isLoading = true);
    try {
      final token = await _storageService.getToken();
      _apiService.setToken(token);

      // Simple split for brand and model
      final parts = widget.device.split(' ');
      final brand = parts.isNotEmpty ? parts[0] : 'Generic';
      final model = parts.length > 1 ? parts.sublist(1).join(' ') : 'Device';

      final result = await _apiService.createOrder(
        brand: brand,
        model: model,
        issues: selectedIssues.toList(),
        total: totalPrice,
        serviceAddress: 'Current Location', // Placeholder or get actual location
        city: 'Hyderabad',
      );

      if (mounted) {
        final orderId = result['data']['_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FindingTechScreen(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
