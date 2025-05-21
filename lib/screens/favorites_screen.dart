import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';
import '../services/favorite_service.dart';
import '../services/api_service.dart';
import '../models/punto_turistico.dart';
import '../widgets/custom_card.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _favoriteItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar favoritos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aún no tienes favoritos.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Marca el corazón en tus puntos o locales turísticos preferidos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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

                // Las impresiones de depuración pueden mantenerse o eliminarse según se necesite
                print('Renderizando CustomCard para item: ${item.runtimeType}');

                // ¡Aquí está el cambio clave!
                // Pasamos el 'item' completo a CustomCard, sin usar 'puntoTuristicoId'.
                // CustomCard determinará si es PuntoTuristico o LocalTuristico internamente.
                return CustomCard(
                  imageUrl: (item is PuntoTuristico ? item.imagenUrl : item.imagenUrl) ?? 'assets/images/default_placeholder.jpg',
                  title: (item is PuntoTuristico ? item.nombre : item.nombre),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalles',
                      arguments: {
                        'item': item, // Pasamos el item completo
                        'type': (item is PuntoTuristico ? 'punto' : 'local'), // Indicamos el tipo
                      },
                    ).then((_) {
                      // Vuelve a cargar los favoritos cuando regreses de la pantalla de detalles,
                      // en caso de que el usuario haya marcado/desmarcado un favorito.
                      _fetchFavoriteItems();
                    });
                  },
                  item: item, // <--- ESTE ES EL CAMBIO PRINCIPAL: PASA EL OBJETO COMPLETO
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