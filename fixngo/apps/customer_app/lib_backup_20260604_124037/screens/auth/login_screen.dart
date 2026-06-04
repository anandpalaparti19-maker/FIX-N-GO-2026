import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  bool _showOtp = false;
  bool _loading = false;
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (_phoneController.text.length < 10) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() { _loading = false; _showOtp = true; });
    _animController.reset();
    _animController.forward();
    Future.delayed(const Duration(milliseconds: 100), () => _otpFocusNodes[0].requestFocus());
  }

  void _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _loading = false);
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D1828), AppTheme.bgDark],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.build_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text('Fix-N-Go', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 48),
                    SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _animController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _showOtp ? 'Enter OTP' : 'Welcome back! 👋',
                              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _showOtp
                                  ? 'We sent a 6-digit code to +91 ${_phoneController.text}'
                                  : 'Sign in with your phone number to continue',
                              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 40),
                            if (!_showOtp) ...[
                              _buildPhoneField(),
                            ] else ...[
                              _buildOtpField(),
                            ],
                            const SizedBox(height: 28),
                            PrimaryButton(
                              text: _showOtp ? 'Verify & Login' : 'Send OTP',
                              onPressed: _showOtp ? _verifyOtp : _sendOtp,
                              isLoading: _loading,
                            ),
                            if (_showOtp) ...[
                              const SizedBox(height: 20),
                              Center(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _showOtp = false;
                                    for (final c in _otpControllers) c.clear();
                                  }),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary),
                                      children: [
                                        const TextSpan(text: "Didn't receive it? "),
                                        TextSpan(text: 'Resend OTP', style: const TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Text('+91', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter mobile number',
                hintStyle: GoogleFonts.poppins(fontSize: 15, color: AppTheme.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: _otpControllers[i],
            focusNode: _otpFocusNodes[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppTheme.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentBlue, width: 2),
              ),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < 5) _otpFocusNodes[i + 1].requestFocus();
              if (val.isEmpty && i > 0) _otpFocusNodes[i - 1].requestFocus();
            },
          ),
        );
      }),
    );
  }
}
