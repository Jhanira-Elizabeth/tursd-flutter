import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/punto_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';

class DetallesScreen extends StatefulWidget {
  final Map<String, dynamic>? itemData;
  final String? imageUrl;

  const DetallesScreen({Key? key, this.itemData, this.imageUrl}) : super(key: key);

  @override
  _DetallesScreenState createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  dynamic _item;
  late String _imageUrl;
  final ApiService _apiService = ApiService();
  late Future<List<HorarioAtencion>> _horariosFuture;
  late Future<List<Servicio>> _serviciosFuture;
  late Future<List<Actividad>> _actividadesFuture;
  String? _barrioSector;
  String? _dueno;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _item = widget.itemData?['item'];
    _imageUrl = widget.itemData?['imageUrl'] ?? 'assets/images/Bomboli8.jpg';

    if (_item != null) {
      _horariosFuture = _fetchHorarios();
      _serviciosFuture = _fetchServicios();
      _actividadesFuture = _fetchActividades();
    } else {
      _horariosFuture = Future.value([]);
      _serviciosFuture = Future.value([]);
      _actividadesFuture = Future.value([]);
    }
    _getBarrioSector();
    _simulateDueno();
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

  Future<List<HorarioAtencion>> _fetchHorarios() async {
    if (_item is LocalTuristico) {
      final allHorarios = await _apiService.fetchHorariosByLocal(_item.id);
      return allHorarios.where((horario) => horario.idLocal == _item.id).toList();
    }
    return [];
  }

  Future<List<Servicio>> _fetchServicios() async {
    if (_item is LocalTuristico) {
      return _apiService.fetchServiciosByLocal(_item.id);
    }
    return [];
  }

  Future<List<Actividad>> _fetchActividades() async {
    if (_item is PuntoTuristico) {
      return _apiService.fetchActividadesByPunto(_item.id);
    }
    return [];
  }

  Future<void> _getBarrioSector() async {
    setState(() {
      _barrioSector = "Barrio Ejemplo";
    });
  }

  void _simulateDueno() {
    String duenoNombre = "Dueño Desconocido";
    if (_item is LocalTuristico || _item is PuntoTuristico) {
      duenoNombre = "Dueño ${(_item.id % 3) + 1}";
    }
    setState(() {
      _dueno = duenoNombre;
    });
  }

  _openMap(double latitude, double longitude) async {
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(googleUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el mapa.')),
      );
    }
  }

  String _getCategoryName(dynamic item) {
  if (item is LocalTuristico && item.etiquetas.isNotEmpty) {
    final categoria = item.etiquetas.firstWhere(
      (e) =>
        e.nombre.toLowerCase().contains('alojamiento') ||
        e.nombre.toLowerCase().contains('río') ||
        e.nombre.toLowerCase().contains('etnia') ||
        e.nombre.toLowerCase().contains('alimento') ||
        e.nombre.toLowerCase().contains('atracción'),
      orElse: () => item.etiquetas.first,
    );
    return categoria.nombre;
  } else if (item is PuntoTuristico && item.etiquetas.isNotEmpty) {
    final categoria = item.etiquetas.firstWhere(
      (e) =>
        e.nombre.toLowerCase().contains('alojamiento') ||
        e.nombre.toLowerCase().contains('río') ||
        e.nombre.toLowerCase().contains('etnia') ||
        e.nombre.toLowerCase().contains('alimento') ||
        e.nombre.toLowerCase().contains('atracción'),
      orElse: () => item.etiquetas.first,
    );
    return categoria.nombre;
  }
  return 'Desconocida';
}

  @override
  Widget build(BuildContext context) {
    String nombre = (_item != null && _item.nombre != null) ? _item.nombre : 'Detalles';

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Cabecera con imagen y título
          SizedBox(
  width: double.infinity,
  height: 250,
  child: Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        _imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      ),
      Positioned(
        left: 20,
        bottom: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre principal con borde blanco
            Text(
              nombre,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.7),
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            // Subcategoría (por ejemplo, "Tsáchila")
            if (_getCategoryName(_item) != 'Desconocida')
              Text(
                _getCategoryName(_item),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black.withOpacity(0.6),
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      // Botón de regreso
      Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    ],
  ),
),
          // Contenido desplazable sobre la imagen
          DraggableScrollableSheet(
  initialChildSize: 0.7,
  minChildSize: 0.7,
  maxChildSize: 0.95,
  builder: (context, scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
                child: Column(
                  children: [
                    // Título y tabs
                    Padding(
  padding: const EdgeInsets.only(top: 16.0, left: 20, right: 20),
  child: TabBar(
    controller: _tabController,
    labelColor: Colors.green,
    unselectedLabelColor: Colors.black54,
    indicatorColor: Colors.green,
    tabs: const [
      Tab(text: 'Información'),
      Tab(text: 'Actividades'),
      Tab(text: 'Ubicación'),
    ],
  ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Información
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Categoría: ${_getCategoryName(_item)}',
                                    style: TextStyle(
                                      color: Colors.green.shade300,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Descripción',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_item?.descripcion ?? 'No hay descripción disponible.'),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Más Información',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Dueño: $_dueno'),
                                  if (_item is LocalTuristico) ...[
                                    if ((_item as LocalTuristico).email != null)
                                      Text('Email: ${(_item as LocalTuristico).email}'),
                                    if ((_item as LocalTuristico).telefono != null)
                                      Text('Teléfono: ${(_item as LocalTuristico).telefono}'),
                                    if ((_item as LocalTuristico).direccion != null)
                                      Text('Dirección: ${(_item as LocalTuristico).direccion}'),
                                  ],
                                  Text('Ubicación: $_barrioSector'),
                                ],
                              ),
                            ),
                          ),
                          // Actividades / Servicios / Horarios
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_item is LocalTuristico) ...[
                                    const Text(
                                      'Servicios',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<Servicio>>(
                                      future: _serviciosFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar servicios: ${snapshot.error}');
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('No hay servicios disponibles.');
                                        } else {
                                          final serviciosFiltrados = snapshot.data!
                                              .where((servicio) => servicio.idLocal == _item.id)
                                              .toList();
                                          if (serviciosFiltrados.isEmpty) {
                                            return const Text('No hay servicios disponibles para este local.');
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: serviciosFiltrados.map((servicio) {
                                              return Text('- ${servicio.servicio}');
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Horarios de atención',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<HorarioAtencion>>(
                                      future: _horariosFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar horarios: ${snapshot.error}');
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('No hay horarios de atención disponibles.');
                                        } else {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: snapshot.data!.map((horario) {
                                              return Text('${horario.diaSemana}: ${horario.horaInicio} - ${horario.horaFin}');
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ] else if (_item is PuntoTuristico) ...[
                                    const Text(
                                      'Actividades',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    FutureBuilder<List<Actividad>>(
                                      future: _actividadesFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error al cargar actividades: ${snapshot.error}');
                                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('No hay actividades disponibles.');
                                        } else {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: snapshot.data!.map((actividad) {
                                              return Text('- ${actividad.nombre} ${actividad.precio != null ? '(${actividad.precio} USD)' : ''}');
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                  if (_item is! LocalTuristico && _item is! PuntoTuristico)
                                    const Center(child: Text('No hay información de actividades disponible.')),
                                ],
                              ),
                            ),
                          ),
                          // Ubicación
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ubicación en el Mapa',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_item?.latitud != null && _item?.longitud != null)
                                    SizedBox(
                                      height: 200,
                                      width: double.infinity,
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(_item.latitud, _item.longitud),
                                          zoom: 15,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: MarkerId(_item.id.toString()),
                                            position: LatLng(_item.latitud, _item.longitud),
                                            infoWindow: InfoWindow(title: nombre),
                                            onTap: () {
                                              _openMap(_item.latitud, _item.longitud);
                                            },
                                          ),
                                        },
                                        onTap: (LatLng latLng) {
                                          _openMap(latLng.latitude, latLng.longitude);
                                        },
                                      ),
                                    )
                                  else
                                    const Text('Ubicación no disponible.'),
                                  if (_item?.latitud != null && _item?.longitud != null)
                                    ElevatedButton(
                                      onPressed: () {
                                        _openMap(_item.latitud, _item.longitud);
                                      },
                                      child: const Text('Abrir en Google Maps'),
                                    ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Dirección',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    (_item is LocalTuristico)
                                        ? (_item as LocalTuristico).direccion ?? 'Dirección no disponible.'
                                        : 'Dirección no disponible.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Botón de regreso
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.4),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}