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
  late Future<List<PuntoTuristico>> _riosFuture;
  final List<String> _defaultImageUrls = [
    'assets/images/ValleHermoso1.jpg', // Imagen por defecto para los ríos
  ];

  @override
  void initState() {
    super.initState();
    _riosFuture =
        _apiService
            .fetchPuntosTuristicos(); // Obtenemos todos los puntos turísticos
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
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _riosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron ríos.'));
          } else {
            final puntosTuristicos = snapshot.data!;
            // Filtrar los puntos turísticos que contengan "río" en su nombre o descripción
            final rios =
                puntosTuristicos
                    .where(
                      (punto) =>
                          punto.nombre.toLowerCase().contains('rio') ||
                          punto.nombre.toLowerCase().contains('rios') ||
                          punto.descripcion.toLowerCase().contains('rio') ||
                          punto.descripcion.toLowerCase().contains('rios') ||
                          punto.nombre.toLowerCase().contains('rio') ||
                          punto.nombre.toLowerCase().contains('rios') ||
                          punto.descripcion.toLowerCase().contains('rio') ||
                          punto.descripcion.toLowerCase().contains('rios') ||
                          punto.nombre.toLowerCase().contains('río') ||
                          punto.nombre.toLowerCase().contains('rios') ||
                          punto.descripcion.toLowerCase().contains('río') ||
                          punto.descripcion.toLowerCase().contains('rios'),
                    )
                    .toList();

            // Buscar el punto turístico "Santo Domingo"
            PuntoTuristico? santoDomingo;
            final otrosRios = [];
            for (final rio in rios) {
              if (rio.nombre == "Santo Domingo") {
                santoDomingo = rio;
              } else {
                otrosRios.add(rio);
              }
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: otrosRios.length + (santoDomingo != null ? 1 : 0),
              itemBuilder: (context, index) {
                PuntoTuristico punto;
                if (index < otrosRios.length) {
                  punto = otrosRios[index];
                } else {
                  if (santoDomingo != null) {
                    punto = santoDomingo!;
                  } else {
                    return const SizedBox.shrink();
                  }
                }
                final imageUrl =
                    _defaultImageUrls[index % _defaultImageUrls.length];

                return CustomCard(
                  imageUrl: imageUrl,
                  title: punto.nombre,
                  onTap: () {
                    // Navegar a los detalles del río
                    print('${punto.nombre} tocado');
                  },
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
