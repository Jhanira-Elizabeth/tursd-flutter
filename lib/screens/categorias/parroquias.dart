import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart'; // Contiene el modelo Parroquia
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class ParroquiasScreen extends StatefulWidget {
  const ParroquiasScreen({super.key});

  @override
  _ParroquiasScreenState createState() => _ParroquiasScreenState();
}

class _ParroquiasScreenState extends State<ParroquiasScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<Parroquia>> _parroquiasFuture;
  final List<String> _defaultImageUrls = [
    'assets/images/Alluriquin.jpg',
    'assets/images/ElEsfuerzo.jpg',
    'assets/images/ValleHermoso1.jpg',
    'assets/images/SantaMaria2.jpg',
    'assets/images/SanJacinto.jpg',
    'assets/images/LuzDeAmerica.jpg',
    'assets/images/Bomboli8.jpg', // Imagen por defecto para las tarjetas
  ];

  @override
  void initState() {
    super.initState();
    _parroquiasFuture =
        _apiService
            .fetchParroquias(); // Llama a la función para obtener todas las parroquias
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
      appBar: AppBar(title: const Text('Parroquias')),
      body: FutureBuilder<List<Parroquia>>(
        future: _parroquiasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay parroquias disponibles.'));
          } else {
            final parroquias = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: parroquias.length,
              itemBuilder: (context, index) {
                final parroquia = parroquias[index];
                final imageUrl =
                    _defaultImageUrls[index % _defaultImageUrls.length];

                return GestureDetector(
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/detalles_parroquia',
                        arguments: {
                          'parroquia': parroquia,
                          'imageUrl': imageUrl,
                        },
                      ),
                  child: CustomCard(
                    imageUrl: imageUrl,
                    title: parroquia.nombre,
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
