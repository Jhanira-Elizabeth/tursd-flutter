import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa Provider
import '../widgets/bottom_navigation_bar_turistico.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';
import '../models/punto_turistico.dart';
import '../widgets/custom_card.dart';
import '../providers/theme_provider.dart'; // Importa tu ThemeProvider

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _currentIndex = 2;
  final FavoriteService _favoriteService = FavoriteService();
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _favoriteItemsFuture;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteItems();
  }

  // Se asegura de que la lista de favoritos se recargue cuando la pantalla se vuelve a enfocar
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Podemos agregar un listener al Route para recargar cuando volvemos
    // o simplemente llamar a _fetchFavoriteItems en un initState o didChangeDependencies
    // si sabemos que el estado puede haber cambiado.
    // La lógica de .then((_) { _fetchFavoriteItems(); }); en onTap ya ayuda mucho.
  }

  Future<void> _fetchFavoriteItems() async {
    setState(() {
      _favoriteItemsFuture = _getAndProcessFavoriteItems();
    });
  }

  Future<List<dynamic>> _getAndProcessFavoriteItems() async {
    print('--- Inciando _getAndProcessFavoriteItems ---');

    // 1. Obtener los IDs de favoritos almacenados localmente
    final favoritePuntoIds = await _favoriteService.getFavoritePuntoIds();
    final favoriteLocalIds = await _favoriteService.getFavoriteLocalIds();

    print('IDs de Puntos Favoritos: $favoritePuntoIds');
    print('IDs de Locales Favoritos: $favoriteLocalIds');

    // 2. Obtener TODOS los puntos y locales de la API (con etiquetas)
    final allPuntos = await _apiService.fetchPuntosConEtiquetas();
    final allLocales = await _apiService.fetchLocalesConEtiquetas();

    print('Total de Puntos de la API: ${allPuntos.length}');
    print('Total de Locales de la API: ${allLocales.length}');

    // 3. Filtrar los puntos turísticos que son favoritos
    final favoritePuntos = allPuntos
        .where((punto) => favoritePuntoIds.contains(punto.id))
        .toList();
    print('Puntos Favoritos filtrados: ${favoritePuntos.map((p) => p.nombre).toList()}');

    // 4. Filtrar los locales turísticos que son favoritos
    final favoriteLocales = allLocales
        .where((local) => favoriteLocalIds.contains(local.id))
        .toList();
    print('Locales Favoritos filtrados: ${favoriteLocales.map((l) => l.nombre).toList()}');

    // Combina ambas listas.
    final combinedList = [...favoritePuntos, ...favoriteLocales];
    print('Lista combinada final (Puntos y Locales): ${combinedList.map((item) {
          if (item is PuntoTuristico) {
              return item.nombre;
          } else if (item is LocalTuristico) {
              return item.nombre;
          }
          return 'Unknown Type';
      }).toList()}');
    print('--- Fin _getAndProcessFavoriteItems ---');

    return combinedList;
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
          // Si ya estamos en favoritos, no navegamos de nuevo
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
          'Favoritos',
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
      body: FutureBuilder<List<dynamic>>(
        future: _favoriteItemsFuture,
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
                'Error al cargar favoritos: ${snapshot.error}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error, // Color para mensajes de error
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: theme.colorScheme.onBackground.withOpacity(0.5), // Color del icono adaptable
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no tienes favoritos.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7), // Color del texto adaptable
                    ),
                  ),
                  Text(
                    'Marca el corazón en tus puntos o locales turísticos preferidos.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6), // Color del texto adaptable
                    ),
                  ),
                ],
              ),
            );
          } else {
            final List<dynamic> favoriteItems = snapshot.data!;
            print('--- Items recibidos por GridView.builder ---');
            print('Cantidad de items en GridView: ${favoriteItems.length}');
            favoriteItems.forEach((item) {
              if (item is PuntoTuristico) {
                print('GV Item (Punto): ${item.nombre} (ID: ${item.id})');
              } else if (item is LocalTuristico) {
                print('GV Item (Local): ${item.nombre} (ID: ${item.id})');
              } else {
                print('GV Item (Desconocido): $item');
              }
            });
            print('------------------------------------------');

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];

                return CustomCard(
                  // Para imageUrl y title, ya estás usando propiedades que deberían venir en ambos tipos
                  imageUrl: (item.imagenUrl != null && item.imagenUrl.isNotEmpty) ? item.imagenUrl : 'assets/images/default_placeholder.jpg',
                  title: item.nombre,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalles',
                      arguments: {
                        'item': item,
                        'type': (item is PuntoTuristico ? 'punto' : 'local'),
                      },
                    ).then((_) {
                      // Vuelve a cargar los favoritos cuando regreses de la pantalla de detalles,
                      // en caso de que el usuario haya marcado/desmarcado un favorito.
                      _fetchFavoriteItems();
                    });
                  },
                  item: item,
                );
              },
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