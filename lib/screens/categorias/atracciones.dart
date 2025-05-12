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
  late Future<List<LocalTuristico>> _atraccionesFuture;
  final List<String> _imageUrls = [
    'assets/images/BalnearioEspanoles1.jpg',
    'assets/images/BalnearioEspanoles2.jpg',
    'assets/images/BalnearioEspanoles3.jpg',
    'assets/images/BalnearioEspanola4.jpg',
    'assets/images/BalnearioEspanola5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _atraccionesFuture = _fetchAtraccionesLocales();
  }

  Future<List<LocalTuristico>> _fetchAtraccionesLocales() async {
    final locales = await _apiService.fetchLocalesTuristicos();
    final localEtiquetas = await _apiService.fetchLocalEtiquetas();

    // Obtener los IDs de los locales que tienen la etiqueta con ID 4 (Atracciones Estables)
    final atraccionesLocalIds = localEtiquetas
        .where((relation) => relation['id_etiqueta'] == 4)
        .map((relation) => relation['id_local'])
        .toSet(); // Usar Set para evitar duplicados

    // Filtrar la lista de locales para incluir solo aquellos cuyo ID está en la lista de atracciones
    return locales.where((local) => atraccionesLocalIds.contains(local.id)).toList();
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
      body: FutureBuilder<List<LocalTuristico>>(
        future: _atraccionesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay atracciones estables disponibles.'));
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
                    '/detalles', // Asegúrate de que esta ruta esté definida en tu MaterialApp
                    arguments: atraccion,
                  ),
                  child: CustomCard(
                    imageUrl: imageUrl,
                    title: atraccion.nombre,
                    subtitle: "Santo Domingo",
                    // Puedes agregar más información aquí si lo deseas
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