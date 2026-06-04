import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'screen_guard_screen.dart';
import 'repair_issue_screen.dart';

class SelectDeviceScreen extends StatefulWidget {
  final String serviceType;
  const SelectDeviceScreen({super.key, required this.serviceType});

  @override
  State<SelectDeviceScreen> createState() => _SelectDeviceScreenState();
}

class _SelectDeviceScreenState extends State<SelectDeviceScreen> {
  String? selectedBrand = 'Samsung';
  String selectedModel = 'Samsung Galaxy S24';

  final List<String> brands = ['Samsung', 'iPhone', 'OnePlus', 'Vivo', 'Realme', 'Oppo'];

  final Map<String, List<String>> models = {
    'Samsung': ['Samsung Galaxy S24', 'Samsung Galaxy S23', 'Samsung Galaxy A54', 'Samsung Galaxy M34'],
    'iPhone': ['iPhone 15 Pro', 'iPhone 15', 'iPhone 14 Pro', 'iPhone 14', 'iPhone 13'],
    'OnePlus': ['OnePlus 12', 'OnePlus 11', 'OnePlus Nord 3', 'OnePlus Nord CE 3'],
    'Vivo': ['Vivo V29 Pro', 'Vivo V27', 'Vivo Y100', 'Vivo T2 Pro'],
    'Realme': ['Realme 12 Pro+', 'Realme 11 Pro', 'Realme Narzo 60'],
    'Oppo': ['Oppo Reno 11 Pro', 'Oppo F23', 'Oppo A78'],
  };

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
          'Select your phone',
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
              Text('Brand',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: brands.map((brand) {
                  final isSelected = selectedBrand == brand;
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedBrand = brand;
                      selectedModel = models[brand]!.first;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.brandBlue : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.brandBlue : AppColors.borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(
                                color: AppColors.brandBlue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Text(
                        brand,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              Text('Model',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: DropdownButton<String>(
                  value: selectedModel,
                  isExpanded: true,
                  dropdownColor: AppColors.bgCardLight,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                  items: (models[selectedBrand] ?? []).map((model) {
                    return DropdownMenuItem(value: model, child: Text(model));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedModel = val!),
                ),
              ),
              const Spacer(),
              // Phone preview
              Center(
                child: Container(
                  width: 120,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderColor, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selectedBrand == 'iPhone'
                            ? Icons.phone_iphone_rounded
                            : Icons.smartphone_rounded,
                        size: 60,
                        color: AppColors.brandBlue.withOpacity(0.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedBrand ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.serviceType == 'guard') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScreenGuardScreen(device: selectedModel),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RepairIssueScreen(device: selectedModel),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
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
}
