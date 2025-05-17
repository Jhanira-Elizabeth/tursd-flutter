import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';
import '../detalle_screen.dart'; // Importa tu DetallesScreen

class AtraccionesScreen extends StatefulWidget {
  const AtraccionesScreen({super.key});

  @override
  _AtraccionesScreenState createState() => _AtraccionesScreenState();
}

class _AtraccionesScreenState extends State<AtraccionesScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _atraccionesFuture;
  final List<String> _imageUrls = [
    'assets/images/afiche_publicitario_balneario_ibiza.jpg',
    'assets/images/Elpalmar.jpg',
    'assets/images/Otonga2.jpg',
    'assets/images/DCarlos.jpg',
    'assets/images/Ventura2.jpg',
    'assets/images/ElPulpoPiscina.jpg',
    'assets/images/GorilaPark1.jpg',
    'assets/images/BalnearioEspanola4.jpg',
    'assets/images/BalnearioEspanoles3.jpg',
    'assets/images/VenturaMiniGolf1.jpg',
    'assets/images/Tapir5.jpg',
    'assets/images/Catedral1.jpg',
    'assets/images/Bomboli2.jpg',
    'assets/images/jardin_botanico1.jpg',
    'assets/images/ParqueZaracay2.jpg',
    'assets/images/IndioColorado6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _atraccionesFuture = _fetchAtracciones();
  }

  Future<List<dynamic>> _fetchAtracciones() async {
    // Trae locales con etiquetas
    final locales = await _apiService.fetchLocalesConEtiquetas();
    // Filtra locales con etiqueta id 4
    final localesAtracciones = locales.where(
      (local) => local.etiquetas.any((et) => et.id == 4)
    ).toList();

    // Trae puntos turísticos con etiquetas
    final puntos = await _apiService.fetchPuntosConEtiquetas();
    // Filtra puntos con etiqueta id 4
    final puntosAtracciones = puntos.where(
      (punto) => punto.etiquetas.any((et) => et.id == 4)
    ).toList();

    // Junta ambos en una sola lista
    return [...localesAtracciones, ...puntosAtracciones];
  }

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
      appBar: AppBar(title: const Text('Atracciones Estables')),
      body: FutureBuilder<List<dynamic>>(
        future: _atraccionesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay atracciones estables disponibles.'),
            );
          } else {
            final atracciones = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: atracciones.length,
              itemBuilder: (context, index) {
                final atraccion = atracciones[index];
                final imageIndex = index % _imageUrls.length;
                final imageUrl = _imageUrls[imageIndex];

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalles',
                    arguments: {
                      'item': atraccion,
                      'imageUrl': imageUrl,
                    },
                  ),
                  child: CustomCard(
                    imageUrl: imageUrl,
                    title: atraccion.nombre,
                    subtitle: "Santo Domingo",
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}