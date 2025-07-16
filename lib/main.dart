import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/auth_service.dart';
import 'models/punto_turistico.dart';
import 'services/api_service.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/recomendados_screen.dart';
import 'screens/chatbot_screen.dart' as chatbot;
import 'screens/mapa_screen.dart';
import '../widgets/custom_card.dart'; // Aunque CustomCard no necesita estar aquí, no molesta.
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
import 'screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'dart:io';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/favorites_screen.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Carga las variables de entorno
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider( // Envuelve toda la app con ThemeProvider
      create: (context) => ThemeProvider(),
      child: const AppRoot(), // Cambia a un nuevo widget raíz que contendrá MaterialApp
    ),
  );
}

// Nuevo widget AppRoot que ahora contendrá el MaterialApp
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
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
    // Ahora, este context SIEMPRE tendrá disponible ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Turismo IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme(), // Usa el tema claro definido
      darkTheme: ThemeProvider.darkTheme(), // Usa el tema oscuro definido
      themeMode: themeProvider.themeMode, // Controla el tema actual
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
        '/recomendados': (context) => const RecomendadosScreen(),
        '/mapa': (context) => const MapaScreen(),
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

// Mantenemos MyApp como estaba para simplificar, renombrándola a AppRoot
// y las otras clases (MapaPage, RecomendadosPage) no necesitan cambios ya que
// obtendrán el tema del contexto de su padre (MaterialApp).

// Tu MapaPage y RecomendadosPage (u otras clases) no necesitan cambios aquí.
// Simplemente se asegura que el tema esté disponible en el árbol de widgets.

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
    // Aquí puedes acceder al tema sin problemas
    final theme = Theme.of(context); //
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Turístico'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface, // Adapta al tema
        foregroundColor: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface, // Adapta al tema
        elevation: 0,
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _puntosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)); // Adapta al tema
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error))); // Adapta al tema
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No hay puntos turísticos disponibles', style: TextStyle(color: theme.colorScheme.onBackground)), // Adapta al tema
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
                        },
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
                      color: theme.colorScheme.surface, // Adapta al tema
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.1), // Adapta al tema
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar en el mapa',
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)), // Adapta al tema
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.8)), // Adapta al tema
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      style: TextStyle(color: theme.colorScheme.onSurface), // Adapta al tema
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      // No necesitas el BottomNavigationBar aquí si MapaScreen ya es la página con su propio BottomNavigationBar
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
    final theme = Theme.of(context); //
    final List<dynamic> puntos =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendados'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface, // Adapta al tema
        foregroundColor: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface, // Adapta al tema
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: puntos.isEmpty
          ? Center(
              child: Text('No hay puntos turísticos disponibles.', style: TextStyle(color: theme.colorScheme.onBackground)), // Adapta al tema
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
                final item = puntos[index];
                String imageUrl = 'https://via.placeholder.com/181x147';
                String title = 'Desconocido';
                String subtitle = '';

                if (item is PuntoTuristico) {
                  imageUrl = item.imagenUrl ?? 'https://via.placeholder.com/181x147';
                  title = item.nombre;
                  subtitle = item.parroquia?.nombre ?? 'Santo Domingo';
                } else if (item is LocalTuristico) {
                  imageUrl = item.imagenUrl ?? 'https://via.placeholder.com/181x147';
                  title = item.nombre;
                  subtitle = item.direccion ?? 'Santo Domingo';
                } else {
                  print('Tipo de item desconocido en RecomendadosPage: ${item.runtimeType}');
                }

                return CustomCard(
                  imageUrl: imageUrl,
                  title: title,
                  subtitle: subtitle,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalles',
                      arguments: {
                        'item': item,
                      },
                    );
                  },
                  item: item, // ¡Aquí pasamos el objeto completo!
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