import 'package:flutter/material.dart';

// Primero tu pantalla principal
class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({Key? key}) : super(key: key);

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Etnia Tsáchila', 'imagen': 'assets/images/Mushily1.jpg'},
    {'nombre': 'Parroquias', 'imagen': 'assets/images/ValleHermoso1.jpg'},
    {'nombre': 'Alojamiento', 'imagen': 'assets/images/HotelRefugio1.jpg'},
    {'nombre': 'Alimentación', 'imagen': 'assets/images/OhQueRico1.jpg'},
    {'nombre': 'Parques', 'imagen': 'assets/images/ParqueJuventud1.jpg'},
    {'nombre': 'Ríos', 'imagen': 'assets/images/SanGabriel1.jpg'},
    {'nombre': 'Atractivos', 'imagen': 'assets/images/Atractivo1.jpg'}, // Añade más si es necesario
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: categorias.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Dos columnas
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final categoria = categorias[index];
            return CategoriaCard(
              nombre: categoria['nombre']!,
              imagen: categoria['imagen']!,
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Ahora tu widget CategoriaCard aparte
class CategoriaCard extends StatelessWidget {
  final String nombre;
  final String imagen;

  const CategoriaCard({
    Key? key,
    required this.nombre,
    required this.imagen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagen,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
