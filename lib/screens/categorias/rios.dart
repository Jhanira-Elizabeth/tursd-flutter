import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';
import '../detalle_screen.dart'; // Importa tu DetallesScreen

class RiosScreen extends StatefulWidget {
  const RiosScreen({super.key});

  @override
  _RiosScreenState createState() => _RiosScreenState();
}

class _RiosScreenState extends State<RiosScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _riosFuture;
  final List<String> _defaultImageUrls = [
    'assets/images/cascadas_diablo.jpg',
    'assets/images/Rio3.jpg',
    'assets/images/Cascadas1.jpg',
    'assets/images/Ventura1.jpg',
    'assets/images/elPulpo4.jpg',
    'assets/images/GorilaPark1.jpg',
    'assets/images/Rio2.jpg',
    'assets/images/LuzAmerica5.jpg',
    'assets/images/Esfuerzo.jpg',
    'assets/images/Damas.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _riosFuture = _fetchRios();
  }

  Future<List<dynamic>> _fetchRios() async {
    final locales = await _apiService.fetchLocalesConEtiquetas();
    final localesRios = locales.where(
      (local) => local.etiquetas.any((et) => et.id == 6)
    ).toList();

    final puntos = await _apiService.fetchPuntosConEtiquetas();
    final puntosRios = puntos.where(
      (punto) => punto.etiquetas.any((et) => et.id == 6)
    ).toList();

    return [...localesRios, ...puntosRios];
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
      appBar: AppBar(title: const Text('Ríos')),
      body: FutureBuilder<List<dynamic>>(
        future: _riosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron establecimientos relacionados con ríos.',
              ),
            );
          } else {
            final rios = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: rios.length,
              itemBuilder: (context, index) {
                final rio = rios[index];
                final imageIndex = index % _defaultImageUrls.length;
                final imageUrl = _defaultImageUrls[imageIndex];

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalles',
                    arguments: {'item': rio, 'imageUrl': imageUrl},
                  ),
                  child: CustomCard(
                    imageUrl: imageUrl,
                    title: rio.nombre,
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