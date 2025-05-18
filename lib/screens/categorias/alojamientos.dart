import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class AlojamientosScreen extends StatefulWidget {
  const AlojamientosScreen({super.key});

  @override
  _AlojamientosScreenState createState() => _AlojamientosScreenState();
}

class _AlojamientosScreenState extends State<AlojamientosScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<LocalTuristico>> _alojamientosFuture;
  final List<String> _imageUrls = [
    'assets/images/Cucardas2.jpg',
    'assets/images/DCarlos.jpg',
    'assets/images/BalnearioEspanoles3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _alojamientosFuture = _fetchAlojamientosLocales();
  }

  Future<List<LocalTuristico>> _fetchAlojamientosLocales() async {
    final locales = await _apiService.fetchLocalesConEtiquetas();
    // Filtra locales con etiqueta id 3 (Alojamientos)
    return locales.where(
      (local) => local.etiquetas.any((et) => et.id == 3)
    ).toList();
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
      appBar: AppBar(title: const Text('Alojamientos')),
      body: FutureBuilder<List<LocalTuristico>>(
        future: _alojamientosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay alojamientos disponibles.'),
            );
          } else {
            final alojamientos = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: alojamientos.length,
              itemBuilder: (context, index) {
                final alojamiento = alojamientos[index];
                final imageIndex = index % _imageUrls.length;
                final imageUrl = _imageUrls[imageIndex];

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalles',
                    arguments: {
                      'item': alojamiento,
                      'imageUrl': imageUrl,
                    },
                  ),
                  child: CustomCard(
                    imageUrl: imageUrl,
                    title: alojamiento.nombre,
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