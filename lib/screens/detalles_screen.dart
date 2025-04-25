import 'package:flutter/material.dart';
import '../punto_turistico.dart';
import '../api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetallesScreen extends StatefulWidget {
  @override
  _DetallesScreenState createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Actividad>> _futureActividades;
  final ApiService _apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final punto = ModalRoute.of(context)!.settings.arguments as PuntoTuristico;
    _futureActividades = _apiService.fetchActividadesByPunto(punto.id);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final punto = ModalRoute.of(context)!.settings.arguments as PuntoTuristico;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                punto.nombre,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: punto.imagenUrl != null && punto.imagenUrl!.isNotEmpty
                ? Image.network(
                    punto.imagenUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade400,
                      child: Center(child: Icon(Icons.image, size: 50, color: Colors.white)),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade400,
                    child: Center(child: Icon(Icons.image, size: 50, color: Colors.white)),
                  ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiquetas
                  if (punto.etiquetas.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        children: punto.etiquetas.map((etiqueta) => Chip(
                          label: Text(etiqueta.nombre),
                          backgroundColor: Color(0xFFE0E6B8),
                          labelStyle: TextStyle(color: Color(0xFF9DAF3A)),
                        )).toList(),
                      ),
                    ),
                  
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF9DAF3A),
                    tabs: [
                      Tab(text: 'Información'),
                      Tab(text: 'Actividades'),
                      Tab(text: 'Ubicación'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Información
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                punto.descripcion,
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 24),
                              // Información de la Parroquia si está disponible
                              if (punto.parroquia != null) ...[
                                Text(
                                  'Parroquia: ${punto.parroquia!.nombre}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  punto.parroquia!.descripcion,
                                  style: TextStyle(fontSize: 14),
                                ),
                                if (punto.parroquia!.poblacion > 0)
                                  Text(
                                    'Población: ${punto.parroquia!.poblacion} habitantes',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                if (punto.parroquia!.temperaturaPromedio > 0)
                                  Text(
                                    'Temperatura promedio: ${punto.parroquia!.temperaturaPromedio} °C',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                SizedBox(height: 16),
                              ],
                              Text(
                                'Más Información',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              ListTile(
                                leading: Icon(Icons.language),
                                title: Text('info@turismo.ec'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: Icon(Icons.phone),
                                title: Text('+593 96657368'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: Icon(Icons.location_on),
                                title: Text('Av. 9 de Octubre'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                        
                        // Actividades
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: FutureBuilder<List<Actividad>>(
                            future: _futureActividades,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Horarios de atención',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    _buildScheduleRow('Lunes a Viernes', '08:00 a 18:00'),
                                    _buildScheduleRow('Sábados y Domingos', '08:00 a 16:00'),
                                    SizedBox(height: 24),
                                    Text(
                                      'Experiencias',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    _buildActivityRow(Icons.camera_alt, 'Fotografía'),
                                    _buildActivityRow(Icons.hiking, 'Caminatas'),
                                    _buildActivityRow(Icons.spa, 'Artesanías'),
                                    _buildActivityRow(Icons.restaurant, 'Gastronomía local'),
                                  ],
                                );
                              } else {
                                final actividades = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Actividades disponibles',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    ...actividades.map((actividad) => Card(
                                      margin: EdgeInsets.only(bottom: 12),
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              actividad.nombre,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Color(0xFF9DAF3A),
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            if (actividad.precio > 0)
                                              Text(
                                                'Precio: \$${actividad.precio.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    )).toList(),
                                    SizedBox(height: 24),
                                    Text(
                                      'Horarios de atención',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    _buildScheduleRow('Lunes a Viernes', '08:00 a 18:00'),
                                    _buildScheduleRow('Sábados y Domingos', '08:00 a 16:00'),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                        
                        // Ubicación
                        Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
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
                      ],
                    ),
                  ),
                ],
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
        currentIndex: 0,
        selectedItemColor: Color(0xFF9DAF3A),
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/mapa');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/chatbot');
          }
        },
      ),
    );
  }
  
  Widget _buildScheduleRow(String days, String hours) {
    return