import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../api_service.dart';
import '../punto_turistico.dart';

class MapaScreen extends StatefulWidget {
  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late Future<List<PuntoTuristico>> _futurePuntos;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _futurePuntos = ApiService().fetchPuntosTuristicos();
    _futurePuntos.then((puntos) {
      setState(() {
        _markers = puntos.map((punto) => 
          Marker(
            markerId: MarkerId(punto.id.toString()),
            position: LatLng(punto.latitud, punto.longitud),
            infoWindow: InfoWindow(
              title: punto.nombre,
              snippet: punto.descripcion.length > 30 
                ? '${punto.descripcion.substring(0, 30)}...'
                : punto.descripcion,
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/detalles',
                  arguments: punto,
                );
              },
            ),
          )
        ).toSet();
      });
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
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _futurePuntos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          // Calcular posición central si hay datos
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
          
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: center,
              zoom: 12.0,
            ),
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          );
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
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}