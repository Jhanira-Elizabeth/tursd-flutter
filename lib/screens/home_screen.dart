import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/punto_turistico.dart';

class HomeScreen extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turismo IA'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Navigator.pushNamed(context, '/mapa');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<PuntoTuristico>>(
      future: _futurePuntos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay puntos turísticos.'));
        }

        final puntos = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Barra de búsqueda
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

            // Sección de Recomendados
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
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/recomendados',
                      arguments:
                          puntos, // Pasa los puntos turísticos como argumentos
                    );
                  },
                  child: const Text('Ver Todos'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Lista horizontal de recomendados
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    puntos.length > 5 ? 5 : puntos.length, // Limitar a 5 ítems
                itemBuilder: (context, index) {
                  final punto = puntos[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detalles',
                          arguments: punto,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child:
                                punto.imagenUrl != null &&
                                        punto.imagenUrl!.isNotEmpty
                                    ? Image.asset(
                                      punto
                                          .imagenUrl!, // Usa la imagen desde assets
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      height: 100,
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(Icons.image),
                                      ),
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              punto.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Sección de Categorías
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categorías',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            // Lista horizontal de categorías manuales
            SizedBox(
              height: 120, // Ajusta la altura según necesites
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: manualCategorias.length,
                itemBuilder: (context, index) {
                  final categoria = manualCategorias[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/${categoria['nombre']!.toLowerCase().replaceAll(' ', '')}',
                        );
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              categoria['imagen']!, // Usa la imagen desde assets
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categoria['nombre']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
