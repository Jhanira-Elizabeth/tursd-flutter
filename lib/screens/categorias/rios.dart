import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class RiosScreen extends StatefulWidget {
  const RiosScreen({super.key});

  @override
  _RiosScreenState createState() => _RiosScreenState();
}

class _RiosScreenState extends State<RiosScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<LocalTuristico>> _riosFuture;
  final List<String> _defaultImageUrls = [
    'assets/images/ValleHermoso1.jpg', // Imagen por defecto para los ríos
  ];

  @override
  void initState() {
    super.initState();
    _riosFuture = _fetchRiosLocales();
  }

  Future<List<LocalTuristico>> _fetchRiosLocales() async {
    final locales = await _apiService.fetchLocalesTuristicos();
    final localEtiquetas = await _apiService.fetchLocalEtiquetas();

    // Obtener los IDs de los locales que tienen la etiqueta con ID 6 (Rios)
    final riosLocalIds = localEtiquetas
        .where((relation) => relation['id_etiqueta'] == 6)
        .map((relation) => relation['id_local'])
        .toSet(); // Usar Set para evitar duplicados

    // Filtrar la lista de locales para incluir solo aquellos cuyo ID está en la lista de ríos
    return locales.where((local) => riosLocalIds.contains(local.id)).toList();
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
      body: FutureBuilder<List<LocalTuristico>>(
        future: _riosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron establecimientos relacionados con ríos.'));
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

                return CustomCard(
                  imageUrl: imageUrl,
                  title: rio.nombre,
                  subtitle: "Santo Domingo",
                  onTap: () => Navigator.pushNamed(context, '/detalles_local', arguments: rio),
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