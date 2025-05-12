import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/punto_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';

class DetallesScreen extends StatefulWidget {
  final dynamic item;

  const DetallesScreen({Key? key, required this.item}) : super(key: key);

  @override
  _DetallesScreenState createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<HorarioAtencion>> _horariosFuture;
  late Future<List<Servicio>> _serviciosFuture;
  late Future<List<Actividad>> _actividadesFuture; // Para puntos turísticos
  String? _barrioSector;
  String? _dueno;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _horariosFuture = _fetchHorarios();
    _serviciosFuture = _fetchServicios();
    _actividadesFuture = _fetchActividades();
    _getBarrioSector();
    _simulateDueno();
  }

  Future<List<HorarioAtencion>> _fetchHorarios() async {
    if (widget.item is LocalTuristico) {
      final allHorarios = await _apiService.fetchHorariosByLocal(widget.item.id);
      return allHorarios.where((horario) => horario.idLocal == widget.item.id).toList();
    }
    return [];
  }

  Future<List<Servicio>> _fetchServicios() async {
    if (widget.item is LocalTuristico) {
      return _apiService.fetchServiciosByLocal(widget.item.id);
    }
    return [];
  }

  Future<List<Actividad>> _fetchActividades() async {
    if (widget.item is PuntoTuristico) {
      return _apiService.fetchActividadesByPunto(widget.item.id);
    }
    return [];
  }

  Future<void> _getBarrioSector() async {
    // ... (tu lógica para obtener el barrio/sector)
    setState(() {
      _barrioSector = "Barrio Ejemplo";
    });
  }

  void _simulateDueno() {
    setState(() {
      _dueno = "Dueño ${(widget.item.id % 3) + 1}";
    });
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

  _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
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
    if (item is LocalTuristico && item.etiquetas != null && item.etiquetas.isNotEmpty) {
      final categoriaEtiqueta = item.etiquetas.firstWhere(
        (etiqueta) => etiqueta.id == 2, // Busca la etiqueta con ID 2 (Alimentos)
        orElse: () => item.etiquetas.isNotEmpty ? item.etiquetas.first : Etiqueta(id: -1, nombre: 'Desconocida', descripcion: '', estado: 'activo'),
      );
      return categoriaEtiqueta.nombre;
    } else if (item is PuntoTuristico && item.etiquetas != null && item.etiquetas.isNotEmpty) {
      return item.etiquetas.first.nombre ?? 'Punto Turístico';
    }
    return 'Desconocida';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.nombre ?? 'Detalles'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Información'),
            Tab(text: 'Actividades'),
            Tab(text: 'Ubicación'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contenido de la pestaña Información
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aquí es donde intentamos mostrar la imagen
                Image.network(
                  'https://via.placeholder.com/400', // Reemplaza con la URL real de la imagen
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink(); // O muestra un widget de error
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  widget.item.nombre ?? '',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Categoría: ${_getCategoryName(widget.item)}',
                  style: TextStyle(color: Colors.green.shade300, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.item.descripcion ?? 'No hay descripción disponible.'),
                const SizedBox(height: 16),
                const Text(
                  'Más Información',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Dueño: $_dueno'),
                if (widget.item is LocalTuristico) ...[
                  if (widget.item.email != null) Text('Email: ${widget.item.email}'),
                  if (widget.item.telefono != null) Text('Teléfono: ${widget.item.telefono}'),
                ],
                Text('Ubicación: $_barrioSector'),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Contenido de la pestaña Actividades
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aquí también intentamos mostrar la imagen
                Image.network(
                  'https://via.placeholder.com/400', // Reemplaza con la URL real de la imagen
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink(); // O muestra un widget de error
                  },
                ),
                const SizedBox(height: 16),
                if (widget.item is LocalTuristico) ...[
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
                            .where((servicio) => servicio.idLocal == widget.item.id)
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
                ] else if (widget.item is PuntoTuristico) ...[
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
              ],
            ),
          ),
          // Contenido de la pestaña Ubicación
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aquí también intentamos mostrar la imagen
                Image.network(
                  'https://via.placeholder.com/400', // Reemplaza con la URL real de la imagen
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink(); // O muestra un widget de error
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ubicación en el Mapa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: (widget.item.latitud != null && widget.item.longitud != null)
                      ? GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(widget.item.latitud!, widget.item.longitud!),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(widget.item.id.toString()),
                              position: LatLng(widget.item.latitud!, widget.item.longitud!),
                              infoWindow: InfoWindow(title: widget.item.nombre),
                              onTap: () {
                                _openMap(widget.item.latitud!, widget.item.longitud!);
                              },
                            ),
                          },
                          onTap: (LatLng latLng) {
                            _openMap(latLng.latitude, latLng.longitude);
                          },
                        )
                      : const Center(child: Text('Ubicación no disponible.')),
                ),
                if (widget.item.latitud != null && widget.item.longitud != null)
                  ElevatedButton(
                    onPressed: () {
                      _openMap(widget.item.latitud!, widget.item.longitud!);
                    },
                    child: const Text('Abrir en Google Maps'),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Dirección',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (widget.item is LocalTuristico)
                  Text(widget.item.direccion ?? 'Dirección no disponible.')
                else if (widget.item is PuntoTuristico)
                  Text('Dirección no disponible.'),
              ],
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