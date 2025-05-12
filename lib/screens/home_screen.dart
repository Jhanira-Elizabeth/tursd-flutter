import 'package:flutter/material.dart';
import '../models/punto_turistico.dart';
import '../widgets/custom_card.dart';
import '../widgets/bottom_navigation_bar_turistico.dart'; // Import the widget
import 'categorias/parques.dart'; // Import the ParquesScreen
import 'categorias/atracciones.dart';
import 'categorias/etnia_tsachila.dart';
import 'categorias/parroquias.dart';
import 'categorias/alojamientos.dart';
import 'categorias/alimentos.dart';
import 'categorias/rios.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Inicio está seleccionado
  // Example data - replace with your actual data source
  final List<PuntoTuristico> puntosRecomendados = [];
  final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Etnia Tsáchila', 'imagen': 'assets/images/Mushily1.jpg', 'route': '/etniatsachila'}, // Use correct route
    {'nombre': 'Atracciones', 'imagen': 'assets/images/GorilaPark1.jpg', 'route': '/atracciones'},
    {'nombre': 'Parroquias', 'imagen': 'assets/images/ValleHermoso1.jpg', 'route': '/parroquias'},
    {'nombre': 'Alojamiento', 'imagen': 'assets/images/HotelRefugio1.jpg', 'route': '/alojamiento'},
    {'nombre': 'Alimentación', 'imagen': 'assets/images/OhQueRico1.jpg', 'route': '/alimentacion'},
    {'nombre': 'Parques', 'imagen': 'assets/images/ParqueJuventud1.jpg', 'route': '/parques'}, // Añadido
    {'nombre': 'Ríos', 'imagen': 'assets/images/SanGabriel1.jpg', 'route': '/rios'},
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
          id: 1,
          nombre: 'Hotel Cariamanga',
          imagenUrl: 'assets/images/Hotel1.jpg',
          descripcion: 'Un cómodo hotel en Cariamanga.',
          latitud: -4.7833,
          longitud: -79.6167,
          idParroquia: 1,
          estado: 'activo',
          esRecomendado: true,
        ),
        PuntoTuristico(
          id: 2,
          nombre: 'Balneario Turístico Apcaolii',
          imagenUrl: 'assets/images/Balneario1.jpg', //  imageUrl from assets
          descripcion: 'Un hermoso balneario turístico.',
          latitud: -4.8000,
          longitud: -79.6500,
          idParroquia: 1,
          estado: 'activo',
          esRecomendado: true,
        ),
        PuntoTuristico(
          id: 3,
          nombre: 'La Piedra del Gorila',
          imagenUrl: 'assets/images/GorilaPark2.jpg',
          descripcion: 'Una formación rocosa única.',
          latitud: -4.7500,
          longitud: -79.5833,
          idParroquia: 1,
          estado: 'activo',
          esRecomendado: false,
        ),
        // Add more points as needed, asegurándote de incluir 'descripcion' y 'longitud'
      ]);
    });
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          // Ya estamos en Inicio
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      'Búsqueda',
                      style: TextStyle(
                        color: Colors.grey.shade400,
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
                child: puntosRecomendados.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: puntosRecomendados.length.clamp(0, 5),
                        itemBuilder: (context, index) {
                          final punto = puntosRecomendados[index];
                          return Padding(
                            padding: EdgeInsets.only(
                                right: index < puntosRecomendados.length - 1
                                    ? 12.0
                                    : 0.0), // Add right padding except the last item
                            child: SizedBox(
                              width: 160, // Set the width of the card
                              child: CustomCard(
                                imageUrl: _getImageUrl(punto.imagenUrl),
                                title: punto.nombre,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/detalles',
                                    arguments: punto,
                                  );
                                },
                              ),
                            ),
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
              // Categories as a horizontal list of CustomCards
              SizedBox(
                height: 220, // Adjust as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    final categoria = categorias[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 160, // Width of each card
                        child: CustomCard(
                          imageUrl: categoria['imagen'],
                          title: categoria['nombre'],
                          onTap: () {
                            // Handle category selection
                            print('Selected category: ${categoria['nombre']}');
                            Navigator.pushNamed(context, categoria['route']);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
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

  // Helper function to handle null or empty image URLs
  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'assets/images/IndioColorado3.jpg'; // Default asset image
    }
    // Check if it is an asset path
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }
    //  handle web URLs if needed.
    return imageUrl;
  }
}

