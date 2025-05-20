import 'package:flutter/material.dart';
import '../models/punto_turistico.dart';
import '../services/api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetalleCard extends StatefulWidget {
  final PuntoTuristico puntoTuristico;

  const DetalleCard({super.key, required this.puntoTuristico});

  @override
  _DetalleCardState createState() => _DetalleCardState();
}

class _DetalleCardState extends State<DetalleCard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Actividad>> _futureActividades;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _futureActividades = _apiService.fetchActividadesByPunto(widget.puntoTuristico.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PuntoTuristico punto = widget.puntoTuristico;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            punto.nombre,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        SizedBox(
          height: 150.0,
          width: double.infinity,
          child: punto.imagenUrl != null && punto.imagenUrl!.isNotEmpty
              ? Image.asset(
                  punto.imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade400,
                    child: Center(child: Icon(Icons.image, size: 30, color: Colors.white)),
                  ),
                )
              : Container(
                  color: Colors.grey.shade400,
                  child: Center(child: Icon(Icons.image, size: 30, color: Colors.white)),
                ),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (punto.etiquetas.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: punto.etiquetas
                        .map((etiqueta) => Chip(
                              label: Text(etiqueta.nombre),
                              backgroundColor: Color(0xFFE0E6B8),
                              labelStyle: TextStyle(color: Color(0xFF9DAF3A)),
                            ))
                        .toList(),
                  ),
                ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF9DAF3A),
                tabs: [
                  Tab(text: 'Info'),
                  Tab(text: 'Actividades'),
                  Tab(text: 'Ubicación'),
                ],
              ),
              Expanded( // Aquí envuelves el SizedBox
                child: SizedBox(
                  // Ya no necesitas la altura fija aquí
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Información
                      Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          punto.descripcion,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      // Actividades
                      Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: FutureBuilder<List<Actividad>>(
                          future: _futureActividades,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text('No hay actividades disponibles.');
                            } else {
                              final actividades = snapshot.data!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: actividades
                                    .map((actividad) => ListTile(
                                          title: Text(actividad.nombre),
                                          subtitle: actividad.precio > 0
                                              ? Text('\$${actividad.precio.toStringAsFixed(2)}')
                                              : Text('Gratis'),
                                        ))
                                    .toList(),
                              );
                            }
                          },
                        ),
                      ),
                      // Ubicación
                      Container(
                        padding: EdgeInsets.only(top: 16.0),
                        child: SizedBox(
                          height: 200, // Puedes mantener una altura inicial o dejar que se ajuste
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(punto.latitud, punto.longitud),
                              zoom: 14.0,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(punto.id.toString()),
                                position: LatLng(punto.latitud, punto.longitud),
                                infoWindow: InfoWindow(title: punto.nombre),
                              ),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}