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
  // --- Asegúrate que esta imagen exista y esté en pubspec.yaml ---
  final List<String> _defaultImageUrls = [
    'assets/images/congoma1.jpg',
    'assets/images/otonga3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Cambia el 5 por el ID real de la etiqueta "Parques" si es diferente
    _etniaDataFuture = _apiService.fetchPuntosByEtiqueta(1);
    _etniaDataFuture = _apiService.fetchPuntosConEtiquetas().then(
    (puntos) => puntos.where(
      (p) => p.etiquetas.any((et) => et.id == 1)
    ).toList(),
  );
  }

  Future<List<dynamic>> _fetchEtniaData() async {
  try {
    final puntos = await _apiService.fetchPuntosTuristicos();
    final locales = await _apiService.fetchLocalesTuristicos();

    // Filtra por ID directamente, sin depender de etiquetas
    final puntoTsachila = puntos.firstWhere(
      (p) => p.id == 3,
      orElse: () => PuntoTuristico(
        id: 0,
        nombre: 'No encontrado',
        descripcion: '',
        latitud: 0,
        longitud: 0,
        idParroquia: 0,
        estado: 'inactivo',
        esRecomendado: false,
      ),
    );


    List<dynamic> results = [];
    if (puntoTsachila.id != 0) results.add(puntoTsachila);

    return results;
  } catch (e, stacktrace) {
    print("Error fetching data in EtniaTsachilaScreen: $e");
    print("Stacktrace: $stacktrace");
    return [];
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
    print("EtniaTsachilaScreen: build method ejecutado");
    return Scaffold(
      appBar: AppBar(title: const Text('Étnia Tsáchila')), // Título descriptivo
      body: FutureBuilder<List<dynamic>>(
        future: _etniaDataFuture,
        builder: (context, snapshot) {
          print(
            "EtniaTsachilaScreen: FutureBuilder builder - ConnectionState: ${snapshot.connectionState}",
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            print(
              "EtniaTsachilaScreen: FutureBuilder - Mostrando CircularProgressIndicator",
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(
              "EtniaTsachilaScreen: FutureBuilder - Error: ${snapshot.error}",
            );
            return Center(
              child: Text('Error al cargar datos: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print(
              "EtniaTsachilaScreen: FutureBuilder - No hay datos o lista vacía",
            );
            return const Center(
              child: Text('No se encontraron opciones disponibles.'),
            );
          } else {
            final data = snapshot.data!;
            print(
              "EtniaTsachilaScreen: FutureBuilder - Datos recibidos, mostrando GridView con ${data.length} items",
            );
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Ajusta si es necesario
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final imageUrl =
                    _defaultImageUrls[index % _defaultImageUrls.length];

                String title = 'Desconocido';
                String subtitle = 'Santo Domingo';
                VoidCallback? onTap;
                int? puntoId; // Variable para almacenar el ID

                if (item is PuntoTuristico) {
                  title = item.nombre;
                  puntoId = item.id; // Asigna el ID del PuntoTuristico
                  onTap = () {
                    Navigator.pushNamed(
                      context,
                      '/detalles',
                      arguments: {
                        'item': item,
                        'imageUrl': imageUrl,
                        'categoria': 'Étnia Tsáchila',
                      },
                    );
                  };
                } else if (item is LocalTuristico) {
                  title = item.nombre;
                  puntoId = item.id; // Asigna el ID del LocalTuristico
                  onTap = () {
                    Navigator.pushNamed(
                      context,
                      '/detalles',
                      arguments: {
                        'item': item,
                        'imageUrl': imageUrl,
                        'categoria': 'Étnia Tsáchila',
                      },
                    );
                  };
                } else {
                  return Card(
                    child: Center(
                      child: Text("Dato inválido: ${item.runtimeType}"),
                    ),
                  );
                }

                return CustomCard(
                  imageUrl: imageUrl,
                  title: title,
                  subtitle: subtitle,
                  onTap: onTap,
                  item: item, // Pasamos el ID, asegurándonos que no sea nulo
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
