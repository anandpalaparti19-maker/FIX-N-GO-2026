import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';

enum _PayMethod { online, cash }
enum _PayState { idle, loading, success, failure }

Future<bool> showPaymentSheet(
  BuildContext context, {
  required String orderId,
  required String paymentId,
  required String paymentSessionId,
  required String cashfreeOrderId,
  required num amount,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentSheet(
      orderId: orderId,
      paymentId: paymentId,
      paymentSessionId: paymentSessionId,
      cashfreeOrderId: cashfreeOrderId,
      amount: amount,
    ),
  );
  return result ?? false;
}

class _PaymentSheet extends StatefulWidget {
  final String orderId;
  final String paymentId;
  final String paymentSessionId;
  final String cashfreeOrderId;
  final num amount;

  const _PaymentSheet({
    required this.orderId,
    required this.paymentId,
    required this.paymentSessionId,
    required this.cashfreeOrderId,
    required this.amount,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> with SingleTickerProviderStateMixin {
  _PayMethod _method = _PayMethod.online;
  _PayState _state = _PayState.idle;
  final PaymentService _paymentService = PaymentService();

  late final AnimationController _successController;
  late final Animation<double> _successAnim;
  
  var cfPaymentGatewayService = CFPaymentGatewayService();

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _successAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
  }

  void verifyPayment(String orderId) async {
    setState(() => _state = _PayState.loading);
    try {
      await _paymentService.confirmPayment(
        cashfreeOrderId: widget.cashfreeOrderId,
        paymentId: widget.paymentId,
        orderId: widget.orderId,
      );
      setState(() => _state = _PayState.success);
      _successController.forward();
      await Future.delayed(Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _state = _PayState.failure);
    }
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    debugPrint("Cashfree Error: \${errorResponse.getMessage()}");
    setState(() => _state = _PayState.failure);
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_method == _PayMethod.cash) {
      setState(() => _state = _PayState.loading);
      try {
        await _paymentService.confirmCashPayment(
          paymentId: widget.paymentId,
          orderId: widget.orderId,
        );
        setState(() => _state = _PayState.success);
        _successController.forward();
        await Future.delayed(Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        setState(() => _state = _PayState.failure);
      }
    } else {
      // Online Payment via Cashfree
      try {
        var session = CFSessionBuilder()
            .setEnvironment(CFEnvironment.SANDBOX) // Always using SANDBOX for now
            .setOrderId(widget.cashfreeOrderId)
            .setPaymentSessionId(widget.paymentSessionId)
            .build();
            
        var theme = CFThemeBuilder()
            .setNavigationBarBackgroundColorColor("#1C1C1E")
            .setPrimaryFont("Inter")
            .setSecondaryFont("Inter")
            .build();
            
        var cfWebCheckout = CFWebCheckoutPaymentBuilder()
            .setSession(session!)
            .build();
            
        cfPaymentGatewayService.doPayment(cfWebCheckout);
      } on CFException catch (e) {
        debugPrint(e.message);
        setState(() => _state = _PayState.failure);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),

          if (_state == _PayState.success)
            _buildSuccess()
          else if (_state == _PayState.failure)
            _buildFailure()
          else ...[
            _buildHeader(),
            SizedBox(height: 20),
            _buildMethodTabs(),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _state == _PayState.loading ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _state == _PayState.loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Pay ₹\${widget.amount}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        ScaleTransition(
          scale: _successAnim,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle,
                color: AppColors.brandGreen, size: 48),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Payment Successful!',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFailure() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.error, color: Colors.red, size: 48),
        ),
        SizedBox(height: 16),
        Text(
          'Payment Failed',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _state = _PayState.idle),
          child: Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Payment',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '₹\${widget.amount}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.brandBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodTabs() {
    return Row(
      children: [
        Expanded(
          child: _MethodTab(
            icon: Icons.payment,
            label: 'Pay Online',
            isSelected: _method == _PayMethod.online,
            onTap: () => setState(() => _method = _PayMethod.online),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MethodTab(
            icon: Icons.money,
            label: 'Cash',
            isSelected: _method == _PayMethod.cash,
            onTap: () => setState(() => _method = _PayMethod.cash),
          ),
        ),
      ],
    );
  }
}

class _MethodTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandBlue.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.brandBlue : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.brandBlue
                  : Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.brandBlue
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
