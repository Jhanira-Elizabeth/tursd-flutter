import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../api_service.dart';
import '../models/punto_turistico.dart';

class MapaScreen extends StatefulWidget {
  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController _mapController;
  late Future<List<PuntoTuristico>> _futurePuntos;
  late Future<List<LocalTuristico>> _futureLocales;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _showPuntos = true;
  bool _showLocales = true;
  
  final LatLng _santoDom1ngo = LatLng(-0.254167, -79.175);

  @override
  void initState() {
    super.initState();
    _futurePuntos = ApiService().fetchPuntosTuristicos();
    _futureLocales = ApiService().fetchLocalesTuristicos();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    try {
      final puntos = await _futurePuntos;
      final locales = await _futureLocales;

      setState(() {
        if (_showPuntos) {
          for (var punto in puntos) {
            _markers.add(
              Marker(
                markerId: MarkerId('punto_${punto.id}'),
                position: LatLng(punto.latitud, punto.longitud),
                infoWindow: InfoWindow(
                  title: punto.nombre,
                  snippet: 'Punto Turístico',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalles',
                      arguments: punto,
                    );
                  },
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
            );
          }
        }

        if (_showLocales) {
          for (var local in locales) {
            _markers.add(
              Marker(
                markerId: MarkerId('local_${local.id}'),
                position: LatLng(local.latitud, local.longitud),
                infoWindow: InfoWindow(
                  title: local.nombre,
                  snippet: 'Local: ${local.descripcion.length > 20 ? local.descripcion.substring(0, 20) + '...' : local.descripcion}',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
            );
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando marcadores: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _togglePuntosTuristicos() {
    setState(() {
      _showPuntos = !_showPuntos;
      _markers.clear();
      _loadMarkers();
    });
  }

  void _toggleLocalesTuristicos() {
    setState(() {
      _showLocales = !_showLocales;
      _markers.clear();
      _loadMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa Turístico'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.place,
              color: _showPuntos ? Color(0xFF9DAF3A) : Colors.grey,
            ),
            onPressed: _togglePuntosTuristicos,
            tooltip: 'Mostrar/Ocultar Puntos Turísticos',
          ),
          IconButton(
            icon: Icon(
              Icons.store,
              color: _showLocales ? Color(0xFF9DAF3A) : Colors.grey,
            ),
            onPressed: _toggleLocalesTuristicos,
            tooltip: 'Mostrar/Ocultar Locales',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _santoDom1ngo,
              zoom: 12.0,
            ),
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DAF3A)),
              ),
            ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Puntos Turísticos'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Locales Turísticos'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
}