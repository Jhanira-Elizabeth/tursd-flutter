import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class EtniaTsachilaScreen extends StatefulWidget {
  const EtniaTsachilaScreen({super.key});

  @override
  _EtniaTsachilaScreenState createState() => _EtniaTsachilaScreenState();
}

class _EtniaTsachilaScreenState extends State<EtniaTsachilaScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _etniaDataFuture;
  final List<String> _defaultImageUrls = ['assets/images/IndioColorado1.jpg'];

  @override
  void initState() {
    super.initState();
    _etniaDataFuture = _fetchEtniaData();
  }

  Future<List<dynamic>> _fetchEtniaData() async {
    try {
      final puntos = await _apiService.fetchPuntosTuristicos();
      final locales = await _apiService.fetchLocalesTuristicos();

      final puntoTsachila = puntos.firstWhere(
        (p) => p.id == 3,
        orElse:
            () => PuntoTuristico(
              id: 0,
              nombre: 'No se encontró Comuna Tsáchila',
              descripcion: '',
              latitud: 0,
              longitud: 0,
              idParroquia: 0,
              estado: 'inactivo',
              esRecomendado: false,
            ),
      );
      final localOtonga = locales.firstWhere(
        (l) => l.id == 5,
        orElse:
            () => LocalTuristico(
              id: 0,
              nombre: 'No se encontró Balneario Otonga Café',
              descripcion: '',
              direccion: '',
              latitud: 0,
              longitud: 0,
              estado: 'inactivo',
            ),
      );

      List<dynamic> results = [];
      if (puntoTsachila.id != 0) {
        results.add(puntoTsachila);
      }
      if (localOtonga.id != 0) {
        results.add(localOtonga);
      }
      return results;
    } catch (e) {
      print("Error fetching data: $e");
      return ["Error al obtener datos. Por favor, intente de nuevo más tarde."];
    }
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
      appBar: AppBar(title: const Text('Étnia Tsáchila y Otonga Café')),
      body: FutureBuilder<List<dynamic>>(
        future: _etniaDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos disponibles.'));
          } else {
            final data = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                String imageUrl =
                    _defaultImageUrls[index % _defaultImageUrls.length];
                String title = '';
                String subtitle = 'Santo Domingo';
                VoidCallback? onTap;

                if (item is PuntoTuristico) {
                  title = item.nombre;
                  onTap =
                      () => Navigator.pushNamed(
                        context,
                        '/detalles_punto',
                        arguments: item,
                      );
                } else if (item is LocalTuristico) {
                  title = item.nombre;
                  onTap =
                      () => Navigator.pushNamed(
                        context,
                        '/detalles_local',
                        arguments: item,
                      );
                } else {
                  return const Center(child: Text("Tipo de dato no válido"));
                }

                return CustomCard(
                  imageUrl: imageUrl,
                  title: title,
                  subtitle: subtitle,
                  onTap: onTap,
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
