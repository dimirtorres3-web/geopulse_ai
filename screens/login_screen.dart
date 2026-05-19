import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithGoogle();
    if (user == null && mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar sesión con Google')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.alt_route_rounded, size: 80, color: Colors.blueAccent),
                ),
                const SizedBox(height: 24),
                const Text(
                  'GeoPulse AI',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mapeo inteligente y reportes ciudadanos de infraestructura vial con IA.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF5F6368)),
                ),
                const SizedBox(height: 48),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3C4043),
                          minimumSize: const Size(double.infinity, 54),
                          side: const BorderSide(color: Color(0xFFDADCE0)),
                        ),
                        onPressed: _login,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_circle, color: Colors.blue),
                            SizedBox(width: 14),
                            Text('Continuar con Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}