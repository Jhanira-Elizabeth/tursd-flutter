import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

// Pantalla principal para mostrar los parques turísticos
class ParquesScreen extends StatefulWidget {
  const ParquesScreen({super.key});

  @override
  _ParquesScreenState createState() => _ParquesScreenState();
}

class _ParquesScreenState extends State<ParquesScreen> { 
  int _currentIndex = 0; // Índice de la barra de navegación inferior
  final ApiService _apiService = ApiService(); // Instancia del servicio de API
  late Future<List<PuntoTuristico>> _parquesFuture; // Futuro para cargar los parques

  // Lista de imágenes para mostrar en las tarjetas de los parques
  final List<String> _imageUrls = [
    'assets/images/LuzDeAmerica4.jpg',
    'assets/images/ElEsfuerzo.jpg',
    'assets/images/JelenTenka1.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Cambia el 5 por el ID real de la etiqueta "Parques" si es diferente
    _parquesFuture = _apiService.fetchPuntosByEtiqueta(5);
    _parquesFuture = _apiService.fetchPuntosConEtiquetas().then(
    (puntos) => puntos.where(
      (p) => p.etiquetas.any((et) => et.id == 5)
    ).toList(),
  );
  }

  // Maneja el cambio de pestaña en la barra de navegación inferior
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
      appBar: AppBar(title: const Text('Parques')),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _parquesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay parques disponibles.'));
          } else {
            final parques = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: parques.length,
              itemBuilder: (context, index) {
                final parque = parques[index];
                final imageIndex = index % _imageUrls.length;
                final imageUrl = _imageUrls[imageIndex];

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detalles',
                    arguments: {
                      'item': parque,
                      'imageUrl': imageUrl,
                      'categoria': 'Parques',
                    },
                  ),
                  child: CustomCard(
                    imageUrl: imageUrl,
                    title: parque.nombre,
                    puntoTuristicoId: parque.id,
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