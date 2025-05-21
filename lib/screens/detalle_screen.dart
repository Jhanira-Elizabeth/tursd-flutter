import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/punto_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/favorite_service.dart'; // Import FavoriteService

class DetallesScreen extends StatefulWidget {
  final Map<String, dynamic>? itemData;
  final String? imageUrl;

  const DetallesScreen({Key? key, this.itemData, this.imageUrl})
      : super(key: key);

  @override
  _DetallesScreenState createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  dynamic _item;
  late String _imageUrl;
  final ApiService _apiService = ApiService();
  final FavoriteService _favoriteService = FavoriteService(); // Initialize FavoriteService
  late Future<List<HorarioAtencion>> _horariosFuture;
  late Future<List<Servicio>> _serviciosFuture;
  late Future<List<Actividad>> _actividadesFuture;
  String? _barrioSector;
  String? _dueno;
  bool _isFavorite = false; // New state variable for favorite status

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
      _checkFavoriteStatus(); // Check favorite status on init
    } else {
      _horariosFuture = Future.value([]);
      _serviciosFuture = Future.value([]);
      _actividadesFuture = Future.value([]);
    }
    _getBarrioSector();
    _simulateDueno();
  }

  // Method to check if the item is a favorite
  void _checkFavoriteStatus() async {
    if (_item == null) return;

    bool favorite = false;
    if (_item is PuntoTuristico) {
      favorite = await _favoriteService.isPuntoTuristicoFavorite(_item.id);
    } else if (_item is LocalTuristico) {
      favorite = await _favoriteService.isLocalTuristicoFavorite(_item.id);
    }

    setState(() {
      _isFavorite = favorite;
    });
  }

  // Method to toggle favorite status
  void _toggleFavorite() async {
    if (_item == null) return;

    bool success = false;
    if (_item is PuntoTuristico) {
      if (_isFavorite) {
        await _favoriteService.removePuntoTuristicoFromFavorites(_item.id);
      } else {
        await _favoriteService.addPuntoTuristicoToFavorites(_item.id);
      }
      success = true; // Assuming the operations are always successful for now
    } else if (_item is LocalTuristico) {
      if (_isFavorite) {
        await _favoriteService.removeLocalTuristicoFromFavorites(_item.id);
      } else {
        await _favoriteService.addLocalTuristicoToFavorites(_item.id);
      }
      success = true; // Assuming the operations are always successful for now
    }

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? 'Añadido a favoritos'
              : 'Eliminado de favoritos'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar el estado de favoritos.'),
        ),
      );
    }
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
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final categoriaManual = args['categoria'] as String?;
    String categoriaMostrar = _getCategoryName(_item);
    if (categoriaMostrar == 'Desconocida' &&
        categoriaManual != null &&
        categoriaManual.isNotEmpty) {
      categoriaMostrar = categoriaManual;
    }
    String nombre =
        (_item != null && _item.nombre != null) ? _item.nombre : 'Detalles';

    // Obtener la altura total de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    // Calcular la altura exacta para que ocupe la mitad de la pantalla
    final imageHeight = screenHeight * 0.5;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[200];
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final dragIndicatorColor = isDarkMode ? Colors.grey[600] : Colors.grey[300];
    final tabColor = isDarkMode ? Colors.greenAccent : Colors.green;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Cabecera con imagen y título
          SizedBox(
            width: double.infinity,
            height:
                imageHeight, // Usar la altura calculada en lugar de valor fijo
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
                // Añadir un gradiente para mejorar la visibilidad del texto sobre la imagen
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.5, 0.7, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre principal con borde blanco
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.85, // Limita el ancho al 85% de la pantalla
                        child: Text(
                          nombre,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.7),
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          maxLines: 2, // Permite hasta 2 líneas
                          overflow: TextOverflow
                              .ellipsis, // Agrega "..." si el texto es más largo
                        ),
                      ),
                      // Subcategoría (por ejemplo, "Tsáchila")
                      if (categoriaMostrar != 'Desconocida')
                        Text(
                          categoriaMostrar,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(1, 1),
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
                // Botón de Favoritos
                Positioned(
                  top: MediaQuery.of(context).padding.top + 30,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.redAccent : Colors.white,
                      ),
                      onPressed: _toggleFavorite, // Call the toggle method
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenido desplazable sobre la imagen
          DraggableScrollableSheet(
            initialChildSize: 0.5, // Iniciar en la mitad de la pantalla
            minChildSize: 0.5, // Mínimo ocupará el 50%
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)), // Añadir bordes redondeados
                ),
                child: Column(
                  children: [
                    // Indicador visual de arrastre
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: dragIndicatorColor,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    // Título y tabs
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: tabColor,
                        unselectedLabelColor: secondaryTextColor,
                        indicatorColor: tabColor,
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
                                    'Categoría: $categoriaMostrar',
                                    style: TextStyle(
                                      color:
                                          textColor, // Use textColor here for consistency with dark mode
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Descripción',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _item?.descripcion ??
                                        'No hay descripción disponible.',
                                    style: TextStyle(color: textColor),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Más Información',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Dueño: $_dueno',
                                      style: TextStyle(color: textColor)),
                                  if (_item is LocalTuristico) ...[
                                    if ((_item as LocalTuristico).email != null)
                                      Text(
                                        'Email: ${(_item as LocalTuristico).email}',
                                        style: TextStyle(color: textColor),
                                      ),
                                    if ((_item as LocalTuristico).telefono !=
                                        null)
                                      Text(
                                        'Teléfono: ${(_item as LocalTuristico).telefono}',
                                        style: TextStyle(color: textColor),
                                      ),
                                    if ((_item as LocalTuristico).direccion !=
                                        null)
                                      Text(
                                        'Dirección: ${(_item as LocalTuristico).direccion}',
                                        style: TextStyle(color: textColor),
                                      ),
                                  ],
                                  Text('Ubicación: $_barrioSector',
                                      style: TextStyle(color: textColor)),
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
                                    Text(
                                      'Servicios',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
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
                                            style: TextStyle(color: textColor),
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Text(
                                            'No hay servicios disponibles.',
                                            style: TextStyle(color: textColor),
                                          );
                                        } else {
                                          final serviciosFiltrados = snapshot
                                              .data!
                                              .where((servicio) =>
                                                  servicio.idLocal == _item.id)
                                              .toList();
                                          if (serviciosFiltrados.isEmpty) {
                                            return Text(
                                              'No hay servicios disponibles para este local.',
                                              style:
                                                  TextStyle(color: textColor),
                                            );
                                          }
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: serviciosFiltrados
                                                .map((servicio) {
                                              return Text(
                                                '- ${servicio.servicio}',
                                                style:
                                                    TextStyle(color: textColor),
                                              );
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Horarios de atención',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
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
                                            style: TextStyle(color: textColor),
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Text(
                                            'No hay horarios de atención disponibles.',
                                            style: TextStyle(color: textColor),
                                          );
                                        } else {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children:
                                                snapshot.data!.map((horario) {
                                              return Text(
                                                '${horario.diaSemana}: ${horario.horaInicio} - ${horario.horaFin}',
                                                style:
                                                    TextStyle(color: textColor),
                                              );
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ] else if (_item is PuntoTuristico) ...[
                                    Text(
                                      'Actividades',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
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
                                            style: TextStyle(color: textColor),
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Text(
                                            'No hay actividades disponibles.',
                                            style: TextStyle(color: textColor),
                                          );
                                        } else {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: snapshot.data!
                                                .map((actividad) {
                                              return Text(
                                                '- ${actividad.nombre} ${actividad.precio != null ? '(${actividad.precio} USD)' : ''}',
                                                style:
                                                    TextStyle(color: textColor),
                                              );
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                  if (_item is! LocalTuristico &&
                                      _item is! PuntoTuristico)
                                    Center(
                                      child: Text(
                                        'No hay información de actividades disponible.',
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
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
                                  Text(
                                    'Ubicación en el Mapa',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (_item?.latitud != null &&
                                      _item?.longitud != null)
                                    SizedBox(
                                      height: 200,
                                      width: double.infinity,
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                            _item.latitud,
                                            _item.longitud,
                                          ),
                                          zoom: 15,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId: MarkerId(
                                              _item.id.toString(),
                                            ),
                                            position: LatLng(
                                              _item.latitud,
                                              _item.longitud,
                                            ),
                                            infoWindow: InfoWindow(
                                              title: nombre,
                                            ),
                                            onTap: () {
                                              _openMap(
                                                _item.latitud,
                                                _item.longitud,
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
                                      ),
                                    )
                                  else
                                    Text('Ubicación no disponible.',
                                        style: TextStyle(color: textColor)),
                                  if (_item?.latitud != null &&
                                      _item?.longitud != null)
                                    ElevatedButton(
                                      onPressed: () {
                                        _openMap(_item.latitud, _item.longitud);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            tabColor, // Color del botón
                                        foregroundColor: Colors
                                            .white, // Color del texto del botón
                                      ),
                                      child: const Text('Abrir en Google Maps'),
                                    ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Dirección',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    (_item is LocalTuristico)
                                        ? (_item as LocalTuristico).direccion ??
                                            'Dirección no disponible.'
                                        : 'Dirección no disponible.',
                                    style: TextStyle(color: textColor),
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
        ],
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
        // Asegúrate de que BottomNavigationBarTuristico también se adapte al modo oscuro
        // Si es un widget personalizado, necesitarás pasarle los colores adecuados o hacer que
        // consulte el tema de forma interna.
      ),
    );
  }
}