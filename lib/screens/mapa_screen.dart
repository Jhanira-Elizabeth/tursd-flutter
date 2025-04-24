import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../api_service.dart';
import '../punto_turistico.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MapaScreen extends StatefulWidget {
  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late Future<List<PuntoTuristico>> _futurePuntos;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _futurePuntos = ApiService().fetchPuntosTuristicos();
    _loadMarkers();
  }

  void _loadMarkers() async {
    try {
      final puntos = await _futurePuntos;
      if (mounted) {
        setState(() {
          _markers = puntos.map((punto) => 
            Marker(
              markerId: MarkerId(punto.id.toString()),
              position: LatLng(punto.latitud, punto.longitud),
              infoWindow: InfoWindow(
                title: punto.nombre,
                snippet: punto.descripcion != null && punto.descripcion.length > 30 
                  ? '${punto.descripcion.substring(0, 30)}...'
                  : punto.descripcion ?? '',
              ),
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/detalles',
                  arguments: punto,
                );
              },
            )
          ).toSet();
        });
      }
    } catch (e) {
      print('Error cargando marcadores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa Turístico'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _futurePuntos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error cargando el mapa: ${snapshot.error}'),
                  if (kIsWeb)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'El mapa puede no funcionar correctamente en modo web de desarrollo. ' +
                        'Asegúrate de haber configurado correctamente la API key de Google Maps.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futurePuntos = ApiService().fetchPuntosTuristicos();
                        _loadMarkers();
                      });
                    },
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          // Solución alternativa si estamos en web y hay problemas con el mapa
          if (kIsWeb && snapshot.hasData) {
            return _buildMapAlternative(snapshot.data!);
          }
          
          // Cálculo de la posición central
          LatLng center = const LatLng(-0.253, -79.175); // Santo Domingo, Ecuador por defecto
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            double sumLat = 0;
            double sumLng = 0;
            
            for (var punto in snapshot.data!) {
              sumLat += punto.latitud;
              sumLng += punto.longitud;
            }
            
            center = LatLng(
              sumLat / snapshot.data!.length,
              sumLng / snapshot.data!.length,
            );
          }
          
          return _buildGoogleMap(center);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Color(0xFF9DAF3A),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/chatbot');
          }
        },
      ),
    );
  }
  
  Widget _buildGoogleMap(LatLng center) {
    try {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 12.0,
        ),
        markers: _markers,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
            _mapReady = true;
          });
        },
      );
    } catch (e) {
      print('Error al crear el mapa: $e');
      return _buildMapAlternative(null);
    }
  }
  
  // Vista alternativa para mostrar cuando el mapa no funciona
  Widget _buildMapAlternative(List<PuntoTuristico>? puntos) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No se pudo cargar el mapa',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          if (puntos != null && puntos.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: puntos.length,
                itemBuilder: (context, index) {
                  final punto = puntos[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.location_on, color: Color(0xFF9DAF3A)),
                      title: Text(punto.nombre),
                      subtitle: Text(
                        'Lat: ${punto.latitud.toStringAsFixed(4)}, Lng: ${punto.longitud.toStringAsFixed(4)}',
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context, 
                          '/detalles',
                          arguments: punto,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          if (puntos == null || puntos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('No hay puntos turísticos disponibles'),
            ),
        ],
      ),
    );
  }
}