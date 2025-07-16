import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack( // Usamos Stack para superponer widgets
          alignment: Alignment.center, // Alinea los hijos al centro del Stack
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100), // Espacio para que la imagen quede encima
                const Text(
                  'Turismo Santo Domingo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 46, 152, 152),
                  ),
                  textAlign: TextAlign.center, // Centra el texto
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/logo_google.png', // Asegúrate de tener este asset
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
            Positioned( // Posicionamos la imagen encima
              top: 160, // Ajusta este valor para mover la imagen verticalmente
              child: Image.asset(
                'assets/images/logo_provisional.png',
                height: 150, // Ajusta el tamaño de la imagen según necesites
              ),
            ),
          ],
        ),
      ),
    );
  }
}