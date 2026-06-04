import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _nameController, _emailController, _phoneController, _passwordController, _confirmController;
  bool _isLoading = false, _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }
    setState(() {_isLoading = true; _errorMessage = null;});
    try {
      final apiService = ApiService();
      final response = await apiService.register(_nameController.text, _emailController.text, _passwordController.text);
      await StorageService.saveToken(response['token']);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0C0C0C)), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF0C0C0C))),
              const SizedBox(height: 8),
              Text('Join Fix-N-Go and book services', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF9B9B9B))),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFF2D2D).withOpacity(0.1), border: Border.all(color: const Color(0xFFFF2D2D)), borderRadius: BorderRadius.circular(8)), child: Text(_errorMessage!, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFFF2D2D)))),
                const SizedBox(height: 16),
              ],
              _buildField('Full Name', _nameController, 'John Doe'),
              _buildField('Email Address', _emailController, 'john@example.com', TextInputType.emailAddress),
              _buildField('Phone Number', _phoneController, '9876543210', TextInputType.phone),
              _buildField('Password', _passwordController, '••••••••', TextInputType.visiblePassword, isPassword: true),
              _buildField('Confirm Password', _confirmController, '••••••••', TextInputType.visiblePassword, isPassword: true),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _register, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A56FF), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: _isLoading ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2) : Text('Create Account', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Already have an account? ', style: GoogleFonts.nunito(fontSize: 12)), GestureDetector(onTap: () => Navigator.pushReplacementNamed(context, '/login'), child: Text('Sign In', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1A56FF))))])
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, [TextInputType? keyboardType, bool isPassword = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0C0C0C), letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          obscureText: isPassword && _obscurePassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: const Color(0xFFCCCCCC)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E2E2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1A56FF))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9B9B9B)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) : null,
          ),
          style: GoogleFonts.nunito(color: const Color(0xFF0C0C0C)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
