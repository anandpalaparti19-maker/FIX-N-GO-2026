import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  const PaymentScreen({Key? key, required this.orderId, required this.amount}) : super(key: key);
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedMethod = 'card';

  Future<void> _processPayment() async {
    setState(() {_isLoading = true; _errorMessage = null;});
    try {
      final apiService = ApiService();
      final intentResponse = await apiService.createPaymentIntent(widget.orderId, widget.amount);
      
      if (!mounted) return;
      
      _showSuccessDialog();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('✅ Payment Successful', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF00C853))),
        content: Text('Your payment of ₹${widget.amount} has been processed.', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400)),
        actions: [ElevatedButton(onPressed: () {Navigator.pop(context); Navigator.pop(context);}, child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0C0C0C)), onPressed: () => Navigator.pop(context)), title: Text('Payment', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C)))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order Amount', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9B9B9B))),
                const SizedBox(height: 8),
                Text('₹${widget.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF1A56FF))),
              ])),
              const SizedBox(height: 24),
              Text('Payment Method', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C))),
              const SizedBox(height: 12),
              _buildPaymentOption('card', '💳', 'Credit/Debit Card'),
              _buildPaymentOption('upi', '📱', 'UPI'),
              _buildPaymentOption('wallet', '🏦', 'Digital Wallet'),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFF2D2D).withOpacity(0.1), border: Border.all(color: const Color(0xFFFF2D2D)), borderRadius: BorderRadius.circular(8)), child: Text(_errorMessage!, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFFF2D2D)))),
                const SizedBox(height: 16),
              ],
              if (_selectedMethod == 'card') ...[
                Text('Card Details', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C), letterSpacing: 1.2)),
                const SizedBox(height: 8),
                TextField(decoration: InputDecoration(hintText: '4111 1111 1111 1111', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: TextField(decoration: InputDecoration(hintText: 'MM/YY', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))), const SizedBox(width: 12), Expanded(child: TextField(decoration: InputDecoration(hintText: 'CVV', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))))]),
                const SizedBox(height: 24),
              ],
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _processPayment, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A56FF), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: _isLoading ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2) : Text('Pay ₹${widget.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String icon, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _selectedMethod == value ? const Color(0xFF1A56FF).withOpacity(0.1) : Colors.white,
          border: Border.all(color: _selectedMethod == value ? const Color(0xFF1A56FF) : const Color(0xFFE2E2E2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [Text(icon, style: const TextStyle(fontSize: 20)), const SizedBox(width: 12), Expanded(child: Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0C0C0C)))), Radio(value: value, groupValue: _selectedMethod, onChanged: (val) => setState(() => _selectedMethod = val!))]),
      ),
    );
  }
}
