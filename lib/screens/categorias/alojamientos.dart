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
  late Future<List<PuntoTuristico>> _alojamientosFuture;
  final List<String> _imageUrls = [
    'assets/images/IndioColorado1.jpg',
    'assets/images/IndioColorado2.jpg',
    'assets/images/IndioColorado3.jpg',
    'assets/images/IndioColorado4.jpg',
    'assets/images/IndioColorado5.jpg',
    'assets/images/IndioColorado6.jpg',
    'assets/images/IndioColorado7.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _alojamientosFuture = _apiService.fetchPuntosTuristicosByEtiqueta("Alojamientos");
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
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _alojamientosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay alojamientos disponibles.'));
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
                // Usa el índice para rotar a través de la lista de imágenes
                final imageIndex = index % _imageUrls.length;
                final imageUrl = _imageUrls[imageIndex];

                return CustomCard(
                  imageUrl: imageUrl,
                  title: alojamiento.nombre,
                  subtitle: "Santo Domingo", // Subtítulo fijo
                  onTap: () => Navigator.pushNamed(context, '/detalles', arguments: alojamiento),
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
