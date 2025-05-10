import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/punto_turistico.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';
import '../widgets/custom_card.dart'; // Asegúrate de tener este widget creado

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PuntoTuristico>> _futurePuntos;
  int _currentIndex = 0;

  final List<Map<String, String>> manualCategorias = [
    {'nombre': 'Etnia Tsáchila', 'imagen': 'assets/images/Mushily1.jpg'},
    {'nombre': 'Atracciones', 'imagen': 'assets/images/GorilaPark1.jpg'},
    {'nombre': 'Parroquias', 'imagen': 'assets/images/ValleHermoso1.jpg'},
    {'nombre': 'Alojamiento', 'imagen': 'assets/images/HotelRefugio1.jpg'},
    {'nombre': 'Alimentación', 'imagen': 'assets/images/OhQueRico1.jpg'},
    {'nombre': 'Parques', 'imagen': 'assets/images/ParqueJuventud1.jpg'},
    {'nombre': 'Ríos', 'imagen': 'assets/images/SanGabriel1.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _futurePuntos = ApiService().fetchPuntosTuristicos();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        Navigator.pushNamed(context, '/mapa');
      } else if (index == 2) {
        Navigator.pushNamed(context, '/chatbot');
      }
      // Lógica para el índice 0 (Inicio) si es necesario
    });
  }

 Widget _buildRecomendados(List<PuntoTuristico> puntos) {
    final recomendados = puntos.where((p) => p.esRecomendado).toList();
    return SizedBox(
      height: 181 + 12 + 16, // Ajustar altura para que quepa el contenido del CustomCard
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recomendados.length > 5 ? 5 : recomendados.length,
        itemBuilder: (context, index) {
          final punto = recomendados[index];
          return CustomCard(
            imageUrl: punto.imagenUrl ?? 'https://via.placeholder.com/181x147', // Proporciona una URL por defecto
            title: punto.nombre,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detalles',
                arguments: punto,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategorias() {
    return SizedBox(
      height: 181 + 12 + 16, // Ajustar altura para que quepa el contenido del CustomCard
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: manualCategorias.length,
        itemBuilder: (context, index) {
          final categoria = manualCategorias[index];
          return CustomCard(
            imageUrl: categoria['imagen']!,
            title: categoria['nombre']!,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/${categoria['nombre']!.toLowerCase().replaceAll(' ', '')}',
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Búsqueda',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recomendados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9DAF3A),
                  ),
                ),
                FutureBuilder<List<PuntoTuristico>>(
                  future: _futurePuntos,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/recomendados',
                            arguments: snapshot.data!,
                          );
                        },
                        child: const Text('Ver Todos'),
                      );
                    }
                    return const SizedBox.shrink(); // Evita errores si no hay datos aún
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<PuntoTuristico>>(
              future: _futurePuntos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay puntos turísticos recomendados.'));
                }
                return _buildRecomendados(snapshot.data!);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9DAF3A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/categorias');
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildCategorias(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabTapped,
      ),
    );
  }
}