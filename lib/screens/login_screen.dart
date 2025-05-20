import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Turismo Santo Domingo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 80, 18, 215),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Image.asset(
                'assets/images/logo_provisional.png', // Asegúrate de tener este asset
                height: 24,
              ),
              label: const Text('Continuar con Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                final user = await _auth.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}