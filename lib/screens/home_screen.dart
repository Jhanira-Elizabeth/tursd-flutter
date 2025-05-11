import 'package:flutter/material.dart';
import '../models/punto_turistico.dart';
import '../widgets/custom_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Example data - replace with your actual data source
  final List<PuntoTuristico> puntosRecomendados = [];
  final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Alojamiento', 'imagen': 'https://via.placeholder.com/200x150'},
    {'nombre': 'Atracciones', 'imagen': 'https://via.placeholder.com/200x150'},
    // Add more categories as needed
  ];

  @override
  void initState() {
    super.initState();
    // Here you would typically load your data
    _cargarPuntosTuristicos();
  }

  void _cargarPuntosTuristicos() {
  // Mock data for demonstration
  setState(() {
    puntosRecomendados.addAll([
      PuntoTuristico(
        id: 1, // Los IDs deberían ser enteros, no Strings
        nombre: 'Hotel Cariamanga',
        imagenUrl: 'https://via.placeholder.com/181x147',
        descripcion: 'Un cómodo hotel en Cariamanga.', // Añade la descripción
        latitud: -4.7833, // Ejemplo de latitud
        longitud: -79.6167, // Ejemplo de longitud
        idParroquia: 1, // Ejemplo de idParroquia
        estado: 'activo', // Ejemplo de estado
        esRecomendado: true,
      ),
      PuntoTuristico(
        id: 2,
        nombre: 'Balneario Turístico Apcaolii',
        imagenUrl: 'https://via.placeholder.com/181x147',
        descripcion: 'Un hermoso balneario turístico.', // Añade la descripción
        latitud: -4.8000, // Ejemplo de latitud
        longitud: -79.6500, // Ejemplo de longitud
        idParroquia: 1, // Ejemplo de idParroquia
        estado: 'activo', // Ejemplo de estado
        esRecomendado: true,
      ),
      PuntoTuristico(
        id: 3,
        nombre: 'La Piedra del Gorila',
        imagenUrl: 'https://via.placeholder.com/181x147',
        descripcion: 'Una formación rocosa única.', // Añade la descripción
        latitud: -4.7500, // Ejemplo de latitud
        longitud: -79.5833, // Ejemplo de longitud
        idParroquia: 1, // Ejemplo de idParroquia
        estado: 'activo', // Ejemplo de estado
        esRecomendado: false,
      ),
      // Add more points as needed, asegurándote de incluir 'descripcion' y 'longitud'
    ]);
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
  height: 48,
  decoration: BoxDecoration(
    color: Colors.grey.shade100, // Fondo más claro
    borderRadius: BorderRadius.circular(24),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    children: [
      Icon(Icons.search, color: Colors.grey.shade400), // Ícono más claro
      const SizedBox(width: 8),
      Text(
        'Búsqueda',
        style: TextStyle(
          color: Colors.grey.shade400, // Texto más claro
          fontSize: 16,
        ),
      ),
    ],
  ),
),

              const SizedBox(height: 24),

              // Recommended section with "Ver Todos" button
              _buildSectionHeader(
                'Recomendados',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/recomendados',
                    arguments: puntosRecomendados,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Recommended cards (horizontal scrolling)
              SizedBox(
                height: 220,
                child:
                    puntosRecomendados.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: puntosRecomendados.length.clamp(0, 5),
                          itemExtent: 160,
                          itemBuilder: (context, index) {
                            final punto = puntosRecomendados[index];
                            return Row(
                              // Wrap each card with a Row to add spacing
                              children: [
                                CustomCard(
                                  imageUrl:
                                      punto.imagenUrl ??
                                      'https://via.placeholder.com/181x147',
                                  title: punto.nombre,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/detalles',
                                      arguments: punto,
                                    );
                                  },
                                ),
                                if (index < puntosRecomendados.length - 1)
                                  const SizedBox(
                                    width: 12,
                                  ), // Add spacing between cards
                              ],
                            );
                          },
                        ),
              ),

              const SizedBox(height: 24),

              // Categories section with "Ver todos" button
              _buildSectionHeader(
                'Categorías',
                onPressed: () {
                  // Navigate to categories screen
                  Navigator.pushNamed(context, '/categorias');
                },
              ),

              const SizedBox(height: 16),

              // Categories grid (2 columns)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 3 / 2, // Width to height ratio
                ),
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final categoria = categorias[index];
                  return _buildCategoryCard(
                    categoria['nombre'],
                    categoria['imagen'],
                    () {
                      // Navigate to specific category
                      Navigator.pushNamed(
                        context,
                        '/categoria',
                        arguments: categoria['nombre'],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home selected
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'ChatBot'),
        ],
        onTap: (index) {
          // Handle navigation to different screens
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, '/mapa');
              break;
            case 2:
              Navigator.pushNamed(context, '/chatbot');
              break;
          }
        },
      ),
    );
  }

  // Helper method to build section headers with "Ver todos" button
  Widget _buildSectionHeader(String title, {required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFA3CF3D), // Green color from your design
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            title == 'Categorías' ? 'Ver todos' : 'Ver Todos',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // Helper method to build category cards
  Widget _buildCategoryCard(String title, String imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
