import 'package:flutter/material.dart';
import 'api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    bool success = await _apiService.login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed. Check credentials.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.build_circle, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 16),
              const Text(
                'Fix-N-Go Tech', 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to your technician account',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController, 
                decoration: const InputDecoration(
                  labelText: 'Email', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                )
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController, 
                decoration: const InputDecoration(
                  labelText: 'Password', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ), 
                obscureText: true
              ),
              const SizedBox(height: 32),
              _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _login, 
                      child: const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
