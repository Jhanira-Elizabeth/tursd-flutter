import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart'; // Importa Provider
import '../models/punto_turistico.dart';
import '../services/api_service.dart';
import '../widgets/bottom_navigation_bar_turistico.dart'; // Importa el widget de la barra de navegación
import '../providers/theme_provider.dart'; // Importa tu ThemeProvider

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PuntoTuristico>> _puntosFuture;
  int _currentIndex = 1; // Inicialmente en el índice 1 (Mapa)

  @override
  void initState() {
    super.initState();
    _puntosFuture = _apiService.fetchPuntosTuristicos();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtén el tema actual
    final themeProvider = Provider.of<ThemeProvider>(context); // Para acceder al toggleTheme

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Usa el color de fondo del tema
      appBar: AppBar(
        title: Text(
          'Mapa Turístico',
          style: theme.appBarTheme.titleTextStyle, // Usa el estilo de texto del AppBarTheme
        ),
        backgroundColor: theme.appBarTheme.backgroundColor, // Usa el color de fondo del AppBarTheme
        foregroundColor: theme.appBarTheme.foregroundColor, // Color de los iconos/texto del AppBarTheme
        elevation: theme.appBarTheme.elevation, // O un valor que prefieras para la elevación
        actions: [
          // Botón para cambiar el tema (opcional, pero útil para pruebas)
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark ? Icons.wb_sunny : Icons.nightlight_round,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _puntosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary, // Color del indicador de carga
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error, // Color para mensajes de error
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay puntos turísticos disponibles',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground, // Color del texto
                ),
              ),
            );
          } else {
            final puntos = snapshot.data!;

            // Calculate center position based on all points
            double sumLat = 0;
            double sumLng = 0;

            for (var punto in puntos) {
              sumLat += punto.latitud;
              sumLng += punto.longitud;
            }

            final centerLat = sumLat / puntos.length;
            final centerLng = sumLng / puntos.length;

            final Set<Marker> markers = {};

            for (var punto in puntos) {
              markers.add(
                Marker(
                  markerId: MarkerId(punto.id.toString()),
                  position: LatLng(punto.latitud, punto.longitud),
                  infoWindow: InfoWindow(
                    title: punto.nombre,
                    snippet:
                        punto.descripcion.length > 50
                            ? '${punto.descripcion.substring(0, 47)}...'
                            : punto.descripcion,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detalles',
                        arguments: punto,
                      );
                    },
                  ),
                ),
              );
            }

            // Google Maps ofrece una opción para estilos personalizados del mapa.
            // Para el modo oscuro, puedes cargar un JSON de estilo oscuro.
            // Esto es más avanzado y requeriría un archivo JSON de estilo de mapa.
            // Por ahora, el mapa base de Google se adaptará automáticamente a la configuración del sistema
            // si el dispositivo tiene activado el modo oscuro (en Android 10+).
            // Si quieres un control más fino, tendrías que usar mapStyle.
            // Por ejemplo:
            // String _mapStyle = themeProvider.themeMode == ThemeMode.dark ? darkMapStyleJson : '';
            // (Donde darkMapStyleJson es el contenido de un JSON de estilo de mapa oscuro)

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(centerLat, centerLng),
                    zoom: 12,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  // Puedes añadir un estilo de mapa personalizado aquí para el modo oscuro
                  // mapStyle: _mapStyle, // Si implementas estilos JSON
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface, // Color de la superficie (tarjeta)
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.onSurface.withOpacity(0.1), // Sombra con color adaptable
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar en el mapa',
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)), // Color del texto de sugerencia
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant), // Color del icono
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      style: TextStyle(color: theme.colorScheme.onSurface), // Color del texto de entrada
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}