import 'package:flutter/material.dart';
import 'api_service_new.dart';
import 'widgets/common_widgets.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _api = ApiService();
  final _accNameCtrl = TextEditingController();
  final _accNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _api.getProfile();
    if (!mounted) return;
    if (profile != null) {
      final bankDetails = profile['bankDetails'] as Map<String, dynamic>?;
      if (bankDetails != null) {
        setState(() {
          _accNameCtrl.text = bankDetails['accountName'] ?? '';
          _accNumberCtrl.text = bankDetails['accountNumber'] ?? '';
          _ifscCtrl.text = bankDetails['ifscCode'] ?? '';
        });
      }
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _accNameCtrl.dispose();
    _accNumberCtrl.dispose();
    _ifscCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBankDetails() async {
    setState(() => _saving = true);
    final success = await _api.updateBankDetails(
      accountName: _accNameCtrl.text.trim(),
      accountNumber: _accNumberCtrl.text.trim(),
      ifscCode: _ifscCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bank details updated successfully!'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update bank details'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          ),
        ),
        title: const Text('Bank Details'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.red))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_rounded, color: AppColors.red, size: 24),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Provide your bank details to receive your earnings payouts.',
                      style: TextStyle(color: AppColors.red, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const SectionLabel('Account Holder Name'),
            TextField(
              controller: _accNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter account holder name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('Account Number'),
            TextField(
              controller: _accNumberCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter your bank account number',
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('IFSC Code'),
            TextField(
              controller: _ifscCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter IFSC code',
                prefixIcon: Icon(Icons.domain_rounded),
              ),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Save Bank Details',
              isLoading: _saving,
              onTap: _saveBankDetails,
            ),
          ],
        ),
      ),
    );
  }
}
