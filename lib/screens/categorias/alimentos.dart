import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';
import '../../models/punto_turistico.dart';

class AlimentosScreen extends StatefulWidget {
  const AlimentosScreen({super.key});

  @override
  _AlimentosScreenState createState() => _AlimentosScreenState();
}

class _AlimentosScreenState extends State<AlimentosScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _alimentosFuture; // Cambia a dynamic
  final List<String> _imageUrls = [
    'assets/images/Marias2.jpg',
    'assets/images/afiche_publicitario_balneario_ibiza.jpg',
    'assets/images/Elpalmar.jpg',
    'assets/images/Cucardas4.jpg',
    'assets/images/Otonga2.jpg',
    'assets/images/DCarlos3.jpg',
    'assets/images/Ventura5.jpg',
    'assets/images/ElPulpo3.jpg',
    'assets/images/GorilaPark1.jpg',
    'assets/images/BalnearioEspanola5.jpg',
    'assets/images/SantaRosa1.jpg',
    'assets/images/Agachaditos2.jpg',
    'assets/images/CasaHornado1.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _alimentosFuture = _fetchAlimentos();
  }

  Future<List<dynamic>> _fetchAlimentos() async {
    // Trae locales con etiquetas
    final locales = await _apiService.fetchLocalesConEtiquetas();
    // Filtra locales con etiqueta id 2
    final localesAlimentos = locales
        .where((local) => local.etiquetas.any((et) => et.id == 2))
        .toList();

    // Trae puntos turísticos con etiquetas
    final puntos = await _apiService.fetchPuntosConEtiquetas();
    // Filtra puntos con etiqueta id 2
    final puntosAlimentos = puntos
        .where((punto) => punto.etiquetas.any((et) => et.id == 2))
        .toList();

    // Junta ambos en una sola lista
    return [...localesAlimentos, ...puntosAlimentos];
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
      case 2: // Favoritos
        Navigator.pushReplacementNamed(context, '/favoritos');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/chatbot');
        break;
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alimentos')),
      body: FutureBuilder<List<dynamic>>(
        future: _alimentosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay establecimientos de alimentos disponibles.'),
            );
          } else {
            final alimentos = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: alimentos.length,
              itemBuilder: (context, index) {
                final alimento = alimentos[index];
                final imageIndex = index % _imageUrls.length;
                final imageUrl = _imageUrls[imageIndex];
                int itemId;
                String nombre;
                String? descripcion;

                if (alimento is PuntoTuristico) {
                  itemId = alimento.id;
                  nombre = alimento.nombre;
                  descripcion = alimento.descripcion;
                } else if (alimento is LocalTuristico) {
                  itemId = alimento.id;
                  nombre = alimento.nombre;
                  descripcion = alimento.descripcion;
                } else {
                  // Manejar caso inesperado, aunque no debería ocurrir
                  itemId = -1; // O algún valor por defecto
                  nombre = 'Error';
                  descripcion = 'Tipo de alimento desconocido';
                }

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalles',
                    arguments: {
                      'item': alimento,
                      'imageUrl': imageUrl,
                    },
                  ),
                  child: CustomCard(
                    imageUrl: imageUrl,
                    title: nombre,
                    subtitle: descripcion,
                    puntoTuristicoId: itemId, // <--- Pasamos el ID aquí
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
