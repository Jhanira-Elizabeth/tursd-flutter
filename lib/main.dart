import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/auth_service.dart'; // Asegúrate de crear este archivo
import 'models/punto_turistico.dart';
import 'services/api_service.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/recomendados_screen.dart';
import 'screens/chatbot_screen.dart' as chatbot;
import 'screens/mapa_screen.dart';
import '../widgets/custom_card.dart';
import 'screens/categorias_screen.dart';
import 'screens/categorias/parques.dart';
import 'screens/categorias/atracciones.dart';
import 'screens/categorias/alojamientos.dart';
import 'screens/categorias/parroquias.dart';
import 'screens/categorias/etnia_tsachila.dart';
import 'screens/categorias/rios.dart';
import 'screens/categorias/alimentos.dart';
import 'screens/detalle_screen.dart';
import 'screens/detalle_parroquia_screen.dart';
import 'screens/login_screen.dart'; // Crea esta pantalla
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'dart:io';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Carga las variables de entorno
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyOpened = prefs.getBool('alreadyOpened') ?? false;
    if (alreadyOpened) {
      setState(() => _showSplash = false);
    } else {
      await prefs.setBool('alreadyOpened', true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSplash = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turismo IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 80, 18, 215),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 80, 18, 215),
          primary: const Color.fromARGB(255, 80, 18, 215),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _showSplash
            ? const SplashScreen()
            : StreamBuilder<User?>(
                stream: _auth.authStateChanges,
                builder: (context, snapshot) {
                  return snapshot.hasData ? const HomeScreen() : LoginScreen();
                },
              ),
        '/home': (context) => const HomeScreen(),
        '/categorias': (context) => CategoriasScreen(),
        '/recomendados': (context) => const RecomendadosScreen(), // Usando la clase existente
        '/mapa': (context) => const MapaScreen(), // Usando la clase existente
        '/chatbot': (context) => chatbot.ChatbotScreen(),
        '/etniatsachila': (context) => const EtniaTsachilaScreen(),
        '/parroquias': (context) => const ParroquiasScreen(),
        '/alojamiento': (context) => const AlojamientosScreen(),
        '/alimentacion': (context) => const AlimentosScreen(),
        '/parques': (context) => const ParquesScreen(),
        '/atracciones': (context) => const AtraccionesScreen(),
        '/rios': (context) => const RiosScreen(),
        '/detalles': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return DetallesScreen(itemData: arguments);
        },
        '/detalles_parroquia': (context) => const DetallesParroquiaScreen(),
        '/favoritos': (context) => const FavoritesScreen(),
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
  int _currentIndex = 1;

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
            return const Center(
              child: Text('No hay puntos turísticos disponibles'),
            );
          } else {
            final puntos = snapshot.data!;

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
                        arguments: {
                          'item': punto,
                        }, // Envuelve el PuntoTuristico en un mapa
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
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/chatbot');
          }
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
  int _currentIndex = 0;

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
  void initState() {
    super.initState();
    _puntosFuture = _apiService.fetchPuntosTuristicos();
  }

  @override
  Widget build(BuildContext context) {
    final List<PuntoTuristico> puntos =
        ModalRoute.of(context)!.settings.arguments as List<PuntoTuristico>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendados'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: puntos.isEmpty
          ? const Center(
              child: Text('No hay puntos turísticos disponibles.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: puntos.length,
              itemBuilder: (context, index) {
  final punto = puntos[index];
  return CustomCard(
    imageUrl:
        punto.imagenUrl ?? 'https://via.placeholder.com/181x147',
    title: punto.nombre,
    onTap: () {
     Navigator.pushNamed(
        context,
        '/detalles',
        arguments: {
          'item': punto,
        }, // Envuelve el PuntoTuristico en un mapa
                    );
                  },
                  puntoTuristicoId: punto.id, // ¡Aquí agregamos el ID!
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
