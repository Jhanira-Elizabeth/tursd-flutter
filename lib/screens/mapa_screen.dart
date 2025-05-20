import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/punto_turistico.dart';
import '../services/api_service.dart';
import '../widgets/bottom_navigation_bar_turistico.dart'; // Importa el widget de la barra de navegación

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PuntoTuristico>> _puntosFuture;
  int _currentIndex = 1; // Inicialmente en el índice 1 (Mapa)

  @override
  void initState() {
    super.initState();
    _puntosFuture = _apiService.fetchPuntosTuristicos();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Turístico'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _puntosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay puntos turísticos disponibles'),
            );
          } else {
            final puntos = snapshot.data!;

            // Calculate center position based on all points
            double sumLat = 0;
            double sumLng = 0;

            for (var punto in puntos) {
              sumLat += punto.latitud;
              sumLng += punto.longitud;
            }

            final centerLat = sumLat / puntos.length;
            final centerLng = sumLng / puntos.length;

            final Set<Marker> markers = {};

            for (var punto in puntos) {
              markers.add(
                Marker(
                  markerId: MarkerId(punto.id.toString()),
                  position: LatLng(punto.latitud, punto.longitud),
                  infoWindow: InfoWindow(
                    title: punto.nombre,
                    snippet:
                        punto.descripcion.length > 50
                            ? '${punto.descripcion.substring(0, 47)}...'
                            : punto.descripcion,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detalles',
                        arguments: punto,
                      );
                    },
                  ),
                ),
              );
            }

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(centerLat, centerLng),
                    zoom: 12,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Usando withOpacity
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar en el mapa',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),
              ],
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