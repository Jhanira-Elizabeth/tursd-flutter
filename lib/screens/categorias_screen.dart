import 'package:flutter/material.dart';
import '../widgets/custom_card.dart'; // Importa el CustomCard widget
import '../widgets/bottom_navigation_bar_turistico.dart'; // Importa el widget

class CategoriasScreen extends StatefulWidget {
  CategoriasScreen({super.key});

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  int _currentIndex = 0; // Por defecto, seleccionamos 'Inicio'

  final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Etnia Tsáchila', 'imagen': 'assets/images/Mushily1.jpg'},
    {'nombre': 'Parroquias', 'imagen': 'assets/images/ValleHermoso1.jpg'},
    {'nombre': 'Atracciones', 'imagen': 'assets/images/GorilaPark1.jpg'},
    {'nombre': 'Alojamiento', 'imagen': 'assets/images/HotelRefugio1.jpg'},
    {'nombre': 'Alimentación', 'imagen': 'assets/images/OhQueRico1.jpg'},
    {'nombre': 'Parques', 'imagen': 'assets/images/ParqueJuventud1.jpg'},
    {'nombre': 'Ríos', 'imagen': 'assets/images/SanGabriel1.jpg'},
  ];

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/mapa');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/chatbot');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 4, // Use the same aspect ratio
        ),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final ruta =
              '/${categoria['nombre'].toString().toLowerCase().replaceAll(' ', '')}';

          return CustomCard(
            imageUrl: categoria['imagen'],
            title: categoria['nombre'],
            onTap: () {
              Navigator.pushNamed(context, ruta);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
