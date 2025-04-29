import 'package:flutter/material.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({Key? key}) : super(key: key);

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Etnia Tsáchila', 'imagen': 'assets/images/Mushily1.jpg'},
    {'nombre': 'Atracciones', 'imagen': 'assets/images/GorilaPark1.jpg'},
    {'nombre': 'Parroquias', 'imagen': 'assets/images/ValleHermoso1.jpg'},
    {'nombre': 'Alojamiento', 'imagen': 'assets/images/HotelRefugio1.jpg'},
    {'nombre': 'Alimentación', 'imagen': 'assets/images/OhQueRico1.jpg'},
    {'nombre': 'Parques', 'imagen': 'assets/images/ParqueJuventud1.jpg'},
    {'nombre': 'Ríos', 'imagen': 'assets/images/SanGabriel1.jpg'},
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: categorias.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Dos columnas
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 4, // Relación de aspecto para las tarjetas
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

// Widget para las tarjetas de categorías
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
    return InkWell(
      onTap: () {
        // Navegación o acción al hacer clic en la tarjeta
        Navigator.pushNamed(
          context,
          '/${nombre.toLowerCase().replaceAll(' ', '')}',
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    imagen,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF9DAF3A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}