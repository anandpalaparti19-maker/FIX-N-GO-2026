import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'finding_tech_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final String device;
  final String service;
  final int price;
  final String serviceType;

  const BookingConfirmScreen({
    super.key,
    required this.device,
    required this.service,
    required this.price,
    required this.serviceType,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  String selectedSlot = 'Today, 2:00 PM';
  String selectedPayment = 'Cash on Delivery';
  final TextEditingController _addressController = TextEditingController(
    text: 'Kondapur, Hyderabad - 500084',
  );

  final List<String> timeSlots = [
    'Today, 11:00 AM',
    'Today, 1:00 PM',
    'Today, 2:00 PM',
    'Today, 4:00 PM',
    'Tomorrow, 10:00 AM',
    'Tomorrow, 2:00 PM',
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {'name': 'Cash on Delivery', 'icon': Icons.money_rounded},
    {'name': 'UPI / GPay', 'icon': Icons.qr_code_rounded},
    {'name': 'Credit / Debit Card', 'icon': Icons.credit_card_rounded},
  ];

  @override
  void dispose() {
    _addressController.dispose();
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
        title: Text(
          'Confirm Booking',
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textWhite),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary
                    _SectionCard(
                      title: 'Order Summary',
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Device',
                            value: widget.device,
                            icon: Icons.smartphone_rounded,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            label: 'Service',
                            value: widget.service,
                            icon: Icons.build_rounded,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            label: 'Estimated Price',
                            value: '₹${widget.price}',
                            icon: Icons.receipt_rounded,
                            valueColor: AppColors.brandGreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Address
                    _SectionCard(
                      title: 'Service Address',
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: TextField(
                          controller: _addressController,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on_rounded,
                                color: AppColors.brandBlue, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                            hintText: 'Enter your address',
                            hintStyle: GoogleFonts.poppins(
                                color: AppColors.textMuted, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Time slots
                    _SectionCard(
                      title: 'Choose Time Slot',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: timeSlots.map((slot) {
                          final isSelected = selectedSlot == slot;
                          return GestureDetector(
                            onTap: () => setState(() => selectedSlot = slot),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.brandBlue.withOpacity(0.15)
                                    : AppColors.bgDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.brandBlue
                                      : AppColors.borderColor,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                slot,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.brandBlue
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Payment method
                    _SectionCard(
                      title: 'Payment Method',
                      child: Column(
                        children: paymentMethods.map((method) {
                          final isSelected = selectedPayment == method['name'];
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedPayment = method['name'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.brandBlue.withOpacity(0.1)
                                    : AppColors.bgDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.brandBlue
                                      : AppColors.borderColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(method['icon'] as IconData,
                                      color: isSelected
                                          ? AppColors.brandBlue
                                          : AppColors.textMuted,
                                      size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    method['name'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.textWhite
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: AppColors.brandBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check_rounded,
                                          size: 12, color: Colors.white),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Estimate',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          )),
                      Text('₹${widget.price}',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FindingTechScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm & Find Technician',
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
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
              )),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.brandBlue),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
