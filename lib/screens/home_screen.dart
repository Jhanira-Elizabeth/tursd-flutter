import 'package:flutter/material.dart';
import '../api_service.dart';
import '../punto_turistico.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PuntoTuristico>> _futurePuntos;
  int _currentIndex = 0;

  final List<Map<String, String>> manualCategorias = [
    {'nombre': 'Etnia Tsachila', 'imagen': 'https://via.placeholder.com/100/FFC107/000000?Text=Tsachila'},
    {'nombre': 'Atracciones', 'imagen': 'https://via.placeholder.com/100/4CAF50/FFFFFF?Text=Atracciones'},
    {'nombre': 'Gastronomía', 'imagen': 'https://via.placeholder.com/100/F44336/FFFFFF?Text=Comida'},
    {'nombre': 'Hoteles', 'imagen': 'https://via.placeholder.com/100/2196F3/FFFFFF?Text=Hotel'},
    {'nombre': 'Parroquias', 'imagen': 'https://via.placeholder.com/100/9C27B0/FFFFFF?Text=Parroquia'},
    {'nombre': 'Parques', 'imagen': 'https://via.placeholder.com/100/009688/FFFFFF?Text=Parque'},
    {'nombre': 'Ríos', 'imagen': 'https://via.placeholder.com/100/3F51B5/FFFFFF?Text=Rio'},
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
        title: Text('Turismo IA'),
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        // Barra de búsqueda
        TextField(
          decoration: InputDecoration(
            hintText: 'Búsqueda',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        SizedBox(height: 20),

        // Sección de Recomendados
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recomendados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9DAF3A),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recomendados');
              },
              child: Text('Ver Todos'),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Lista horizontal de recomendados (desde API)
        Container(
          height: 150,
          child: FutureBuilder<List<PuntoTuristico>>(
            future: _futurePuntos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay puntos turísticos.'));
              }

              final puntos = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: puntos.length > 5 ? 5 : puntos.length, // Limitar a 5 ítems
                itemBuilder: (context, index) {
                  final punto = puntos[index];
                  return Container(
                    width: 150,
                    margin: EdgeInsets.only(right: 10),
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
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Container(
                              height: 100,
                              color: Colors.grey.shade300,
                              child: Center(child: Icon(Icons.image)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              punto.nombre,
                              style: TextStyle(
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
              );
            },
          ),
        ),
        SizedBox(height: 20),

        // Sección de Categorías (Nuevo diseño con scroll horizontal)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
        SizedBox(height: 10),

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
                        child: Image.network(
                          categoria['imagen']!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categoria['nombre']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 20),

        // El GridView de categorías anterior lo puedes eliminar o comentar
        // GridView.count(
        //   crossAxisCount: 2,
        //   crossAxisSpacing: 10,
        //   mainAxisSpacing: 10,
        //   shrinkWrap: true,
        //   physics: NeverScrollableScrollPhysics(),
        //   children: [
        //     _buildCategoryCard('Etnia Tsáchila', Icons.people),
        //     _buildCategoryCard('Atracciones', Icons.attractions),
        //     _buildCategoryCard('Gastronomía', Icons.restaurant),
        //     _buildCategoryCard('Hoteles', Icons.hotel),
        //   ],
        // ),
      ],
    );
  }

  // Widget _buildCategoryCard(String title, IconData icon) {
  //   return Container(
  //     // Tu código del CategoryCard anterior
  //   );
  // }
}