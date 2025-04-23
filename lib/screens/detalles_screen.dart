import 'package:flutter/material.dart';
import '../punto_turistico.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetallesScreen extends StatefulWidget {
  @override
  _DetallesScreenState createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              background: Container(
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
                            ],
                          ),
                        ),
                        
                        // Actividades
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
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
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/mapa');
          }
        },
      ),
    );
  }
  
  Widget _buildScheduleRow(String days, String hours) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              days,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              hours,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityRow(IconData icon, String activity) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 12),
          Text(
            activity,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}