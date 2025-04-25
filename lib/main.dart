import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'punto_turistico.dart';
import 'api_service.dart';
import 'categoria.dart';
// import 'screens/categorias_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detalles_screen.dart';
import 'screens/recomendados_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/mapa_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  if (kIsWeb) {
    await dotenv.load(fileName: "assets/.env");
  } else {
    await dotenv.load(); // usa el real en raíz
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turismo IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF9DAF3A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF9DAF3A),
          primary: Color(0xFF9DAF3A),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/categorias': (context) => CategoriasScreen(),
        '/recomendados': (context) => RecomendadosScreen(),
        '/detalles': (context) => DetallesScreen(),
        '/mapa': (context) => MapaScreen(),
        '/chatbot': (context) => ChatbotScreen(),
      },
    );
  }
}

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final ApiService _apiService = ApiService();
  late Future<List<PuntoTuristico>> _puntosFuture;
  int _currentIndex = 1; // Inicialmente en el índice 1 (Mapa)

  @override
  void initState() {
    super.initState();
    _puntosFuture = _apiService.fetchPuntosTuristicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Turístico'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _puntosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay puntos turísticos disponibles'));
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
                    snippet: punto.descripcion.length > 50
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
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar en el mapa',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 2) {
            // Implementar navegación al chatbot cuando esté disponible
          }
        },
        items: const [
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
      ),
    );
  }
}

// ¡Asegúrate de que SOLO esta clase CategoriasScreen esté presente en main.dart!
class CategoriasScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Etnia Tsáchila', 'imagen': 'assets/images/Mushily1.jpg'},
    {'nombre': 'Parroquias', 'imagen': 'assets/images/ValleHermoso1.jpg'},
    {'nombre': 'Alojamiento', 'imagen': 'assets/images/HotelRefugio1.jpg'},
    {'nombre': 'Alimentación', 'imagen': 'assets/images/OhQueRico1.jpg'},
    {'nombre': 'Parques', 'imagen': 'assets/images/ParqueJuventud1.jpg'},
    {'nombre': 'Ríos', 'imagen': 'assets/images/SanGabriel1.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías'), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final ruta = '/${categoria['nombre'].toLowerCase().replaceAll(' ', '')}';

          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, ruta);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(categoria['imagen'], fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.4)),
                  Center(
                    child: Text(
                      categoria['nombre'],
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecomendadosPage extends StatefulWidget {
  const RecomendadosPage({super.key});

  @override
  State<RecomendadosPage> createState() => _RecomendadosPageState();
}

class _RecomendadosPageState extends State<RecomendadosPage> {
  final ApiService _apiService = ApiService();
  late Future<List<PuntoTuristico>> _puntosFuture;

  @override
  void initState() {
    super.initState();
    _puntosFuture = _apiService.fetchPuntosTuristicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendados'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _puntosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay puntos turísticos disponibles'));
          } else {
            final puntos = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: puntos.length,
              itemBuilder: (context, index) {
                final punto = puntos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Icon(Icons.image)),
                    ),
                    title: Text(
                      punto.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      punto.descripcion.length > 100
                          ? '${punto.descripcion.substring(0, 97)}...'
                          : punto.descripcion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detalles',
                        arguments: punto,
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Contenido para $title en construcción'),
      ),
    );
  }
}