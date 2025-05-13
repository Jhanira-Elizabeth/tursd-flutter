import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/punto_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';

class DetallesScreen extends StatefulWidget {
  final dynamic item; // Cambiado a dynamic
  final String? imageUrl;

  const DetallesScreen({Key? key, required this.item, this.imageUrl})
    : super(key: key);

  @override
  _DetallesScreenState createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();

  late Future<List<HorarioAtencion>> _horariosFuture;
  late Future<List<Servicio>> _serviciosFuture;
  late Future<List<Actividad>> _actividadesFuture;

  String? _barrioSector;
  String? _dueno;
  late TabController _tabController;
  String? _localImageUrl;
  dynamic _item; // Declarar _item

  @override
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

  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Ahora accedemos directamente a widget.item
    _item = widget.item;

    if (_item != null) {
      _horariosFuture = _fetchHorarios();
      _serviciosFuture = _fetchServicios();
      _actividadesFuture = _fetchActividades();
    }
    _getBarrioSector();
    _simulateDueno();
  }

  // Métodos para obtener datos (adaptados para usar _item)
  Future<List<HorarioAtencion>> _fetchHorarios() async {
    if (_item is LocalTuristico) {
      final allHorarios = await _apiService.fetchHorariosByLocal(_item.id);
      return allHorarios
          .where((horario) => horario.idLocal == _item.id)
          .toList();
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
    final googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
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
    if (item is LocalTuristico &&
        item.etiquetas != null &&
        item.etiquetas.isNotEmpty) {
      final categoriaEtiqueta = item.etiquetas.firstWhere(
        (etiqueta) => etiqueta.id == 2,
        orElse:
            () =>
                item.etiquetas.isNotEmpty
                    ? item.etiquetas.first
                    : Etiqueta(
                      id: -1,
                      nombre: 'Desconocida',
                      descripcion: '',
                      estado: 'activo',
                    ),
      );
      return categoriaEtiqueta.nombre;
    } else if (item is PuntoTuristico &&
        item.etiquetas != null &&
        item.etiquetas.isNotEmpty) {
      return item.etiquetas.first.nombre ?? 'Punto Turístico';
    }
    return 'Desconocida';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_item.nombre ?? 'Sin nombre')),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contenido de la pestaña Información
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child:
                (_item != null) // Comprobación de null para _item
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Siempre mostrar imagen en la parte superior
                        Image.asset(
                          _localImageUrl ??
                              'assets/images/Bomboli8.jpg', // Usar imagen por defecto solo si la URL es nula
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/Bomboli8.jpg', // Imagen de respaldo si hay error
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _item.nombre ??
                              '', // Usar el nombre calculado, o un valor por defecto
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _item.descripcion ?? 'No hay descripción disponible.',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Más Información',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Dueño: $_dueno'),
                        if (_item is LocalTuristico) ...[
                          if ((_item as LocalTuristico).email != null)
                            Text('Email: ${(_item as LocalTuristico).email}'),
                          if ((_item as LocalTuristico).telefono != null)
                            Text(
                              'Teléfono: ${(_item as LocalTuristico).telefono}',
                            ),
                        ],
                        Text('Ubicación: $_barrioSector'),
                        const SizedBox(height: 16),
                      ],
                    )
                    : const Center(
                      child: Text(
                        'No se han proporcionado detalles del elemento.',
                      ),
                    ),
          ),
          // Contenido de la pestaña Actividades
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child:
                (_item != null) // Comprobación de null para _item
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Siempre mostrar imagen en la parte superior
                        Image.asset(
                          _localImageUrl ??
                              'assets/images/Bomboli8.jpg', // Usar imagen por defecto solo si la URL es nula
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/Bomboli8.jpg', // Imagen de respaldo si hay error
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_item is LocalTuristico) ...[
                          const Text(
                            'Servicios',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Servicio>>(
                            future: _serviciosFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error al cargar servicios: ${snapshot.error}',
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                  'No hay servicios disponibles.',
                                );
                              } else {
                                final serviciosFiltrados =
                                    snapshot.data!
                                        .where(
                                          (servicio) =>
                                              servicio.idLocal == _item.id,
                                        )
                                        .toList();
                                if (serviciosFiltrados.isEmpty) {
                                  return const Text(
                                    'No hay servicios disponibles para este local.',
                                  );
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      serviciosFiltrados.map((servicio) {
                                        return Text('- ${servicio.servicio}');
                                      }).toList(),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Horarios de atención',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<HorarioAtencion>>(
                            future: _horariosFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error al cargar horarios: ${snapshot.error}',
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                  'No hay horarios de atención disponibles.',
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      snapshot.data!.map((horario) {
                                        return Text(
                                          '${horario.diaSemana}: ${horario.horaInicio} - ${horario.horaFin}',
                                        );
                                      }).toList(),
                                );
                              }
                            },
                          ),
                        ] else if (_item is PuntoTuristico) ...[
                          const Text(
                            'Actividades',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Actividad>>(
                            future: _actividadesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error al cargar actividades: ${snapshot.error}',
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text(
                                  'No hay actividades disponibles.',
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      snapshot.data!.map((actividad) {
                                        return Text('- ${actividad.nombre}');
                                      }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    )
                    : const Center(
                      child: Text('No se han proporcionado actividades.'),
                    ),
          ),
          // Contenido de la pestaña Ubicación
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child:
                (_item != null) // Comprobación de null
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Siempre mostrar imagen en la parte superior
                        Image.asset(
                          _localImageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/Bomboli8.jpg', // Imagen de respaldo si hay error
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ubicación en el Mapa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          // Comprobar si latitud y longitud son no nulos
                          child:
                              (_item.latitud != null && _item.longitud != null)
                                  ? GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                        _item.latitud!,
                                        _item.longitud!,
                                      ),
                                      zoom: 15,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: MarkerId(_item.id.toString()),
                                        position: LatLng(
                                          _item.latitud!,
                                          _item.longitud!,
                                        ),
                                        infoWindow: InfoWindow(
                                          title: _item.nombre,
                                        ),
                                        onTap: () {
                                          _openMap(
                                            _item.latitud!,
                                            _item.longitud!,
                                          );
                                        },
                                      ),
                                    },
                                    onTap: (LatLng latLng) {
                                      _openMap(
                                        latLng.latitude,
                                        latLng.longitude,
                                      );
                                    },
                                  )
                                  : const Center(
                                    child: Text('Ubicación no disponible.'),
                                  ),
                        ),
                        if (_item.latitud != null &&
                            _item.longitud != null) // Otra comprobación
                          ElevatedButton(
                            onPressed: () {
                              _openMap(_item.latitud!, _item.longitud!);
                            },
                            child: const Text('Abrir en Google Maps'),
                          ),
                        const SizedBox(height: 16),
                        const Text(
                          'Dirección',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (_item is LocalTuristico)
                              ? (_item as LocalTuristico).direccion ??
                                  'Dirección no disponible.'
                              : 'Dirección no disponible.',
                        ),
                      ],
                    )
                    : const Center(
                      child: Text(
                        'No se han proporcionado detalles del elemento.',
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
