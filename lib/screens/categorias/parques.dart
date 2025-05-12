import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class ParquesScreen extends StatefulWidget {
  const ParquesScreen({super.key});

  @override
  _ParquesScreenState createState() => _ParquesScreenState();
}

class _ParquesScreenState extends State<ParquesScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<PuntoTuristico>> _parquesFuture;
  final List<String> _imageUrls = [
    'assets/images/Bomboli1.jpg',
    'assets/images/Bomboli2.jpg',
    'assets/images/Bomboli3.jpg',
    'assets/images/Bomboli4.jpg',
    'assets/images/Bomboli5.jpg',
    'assets/images/Bomboli6.jpg',
    'assets/images/Bomboli7.jpg',
    'assets/images/Bomboli8.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _parquesFuture = _apiService.fetchPuntosTuristicosByEtiqueta("Parques");
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
                // Usa el índice para rotar a través de la lista de imágenes
                final imageIndex = index % _imageUrls.length;
                final imageUrl = _imageUrls[imageIndex];

                return CustomCard(
                  imageUrl: imageUrl,
                  title: parque.nombre,
                  subtitle: "Santo Domingo",
                  onTap: () => Navigator.pushNamed(context, '/detalles',
                      arguments: parque),
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
