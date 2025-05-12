import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class AlimentosScreen extends StatefulWidget {
  const AlimentosScreen({super.key});

  @override
  _AlimentosScreenState createState() => _AlimentosScreenState();
}

class _AlimentosScreenState extends State<AlimentosScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<LocalTuristico>> _alimentosFuture;
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
    _alimentosFuture = _fetchAlimentosLocales();
  }

  Future<List<LocalTuristico>> _fetchAlimentosLocales() async {
    final locales = await _apiService.fetchLocalesTuristicos();
    final localEtiquetas = await _apiService.fetchLocalEtiquetas();

    // Obtener los IDs de los locales que tienen la etiqueta con ID 2 (Alimentos)
    final alimentosLocalIds =
        localEtiquetas
            .where((relation) => relation['id_etiqueta'] == 2)
            .map((relation) => relation['id_local'])
            .toSet(); // Usar Set para evitar duplicados

    // Filtrar la lista de locales para incluir solo aquellos cuyo ID está en la lista de alimentos
    return locales
        .where((local) => alimentosLocalIds.contains(local.id))
        .toList();
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
      appBar: AppBar(title: const Text('Alimentos')),
      body: FutureBuilder<List<LocalTuristico>>(
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

                return CustomCard(
                  imageUrl: imageUrl,
                  title: alimento.nombre,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/detalles_local',
                        arguments: alimento,
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
