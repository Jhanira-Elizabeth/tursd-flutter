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
    {
      'nombre': 'Etnia Tsáchila',
      'imagen': 'assets/images/Mushily1.jpg',
      'route': '/etniatsachila', // <--- Usa la ruta correcta SIN tilde
    },
    {
      'nombre': 'Atracciones',
      'imagen': 'assets/images/GorilaPark1.jpg',
      'route': '/atracciones',
    },
    {
      'nombre': 'Parroquias',
      'imagen': 'assets/images/ValleHermoso1.jpg',
      'route': '/parroquias',
    },
    
    {
      'nombre': 'Alojamiento',
      'imagen': 'assets/images/HotelRefugio1.jpg',
      'route': '/alojamiento',
    },
    {
      'nombre': 'Alimentos',
      'imagen': 'assets/images/OhQueRico1.jpg',
      'route': '/alimentacion',
    },
    {
      'nombre': 'Parques',
      'imagen': 'assets/images/ParqueJuventud1.jpg',
      'route': '/parques',
    },
    {
      'nombre': 'Rios',
      'imagen': 'assets/images/SanGabriel1.jpg',
      'route': '/rios',
    },
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
      case 2: // Favoritos
        Navigator.pushReplacementNamed(context, '/favoritos');
        break;
      case 3:
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
                // Generamos un ID único basado en el nombre de la categoría
                final categoriaId = categoria['nombre'].toString().toLowerCase().replaceAll(' ', '');

                return CustomCard(
                  imageUrl: categoria['imagen'],
                  title: categoria['nombre'],
                  onTap: () {
                    Navigator.pushNamed(context, categoria['route']);
                  },
                  puntoTuristicoId: categoriaId.hashCode, // Usamos el hashCode del string como ID (solo para esta pantalla)
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
