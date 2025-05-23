import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/favorite_service.dart';
import '../../widgets/custom_card.dart';
import '../../models/punto_turistico.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _currentIndex = 2; // Favoritos tab
  final FavoriteService _favoriteService = FavoriteService();
  late Future<List<dynamic>> _favoritesFuture;
  
  // Lista de imágenes por defecto para cuando no hay imagen específica
  final List<String> _defaultImageUrls = [
    'assets/images/Marias2.jpg',
    'assets/images/afiche_publicitario_balneario_ibiza.jpg',
    'assets/images/Elpalmar.jpg',
    'assets/images/Cucardas4.jpg',
    'assets/images/Otonga2.jpg',
    'assets/images/DCarlos3.jpg',
    'assets/images/Ventura5.jpg',
    'assets/images/ElPulpo3.jpg',
    'assets/images/GorilaPark1.jpg',
    'assets/images/BalnearioEspanola5.jpg',
    'assets/images/SantaRosa1.jpg',
    'assets/images/Agachaditos2.jpg',
    'assets/images/CasaHornado1.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavorites();
  }

  Future<List<dynamic>> _fetchFavorites() async {
    try {
      // Obtener puntos turísticos favoritos como maps
      final favoritePuntosRaw = await _favoriteService.getFavoritePuntos();
      print('Puntos favoritos raw: $favoritePuntosRaw');
      
      // Obtener locales turísticos favoritos como maps
      final favoriteLocalesRaw = await _favoriteService.getFavoriteLocales();
      print('Locales favoritos raw: $favoriteLocalesRaw');

      // Crear una lista mixta que incluya tanto los objetos como información de tipo
      List<dynamic> allFavorites = [];
      
      // Agregar puntos turísticos
      for (var puntoMap in favoritePuntosRaw) {
        try {
          final punto = PuntoTuristico.fromJson(puntoMap);
          allFavorites.add(punto);
        } catch (e) {
          print('Error al parsear punto turístico: $e');
          // Si hay error al parsear, agregamos el map raw con un tipo identificador
          puntoMap['_tipo'] = 'PuntoTuristico';
          allFavorites.add(puntoMap);
        }
      }
      
      // Agregar locales turísticos
      for (var localMap in favoriteLocalesRaw) {
        try {
          final local = LocalTuristico.fromJson(localMap);
          allFavorites.add(local);
        } catch (e) {
          print('Error al parsear local turístico: $e');
          // Si hay error al parsear, agregamos el map raw con un tipo identificador
          localMap['_tipo'] = 'LocalTuristico';
          allFavorites.add(localMap);
        }
      }

      print('Total de favoritos: ${allFavorites.length}');
      return allFavorites;
    } catch (e) {
      print('Error al cargar favoritos: $e');
      return [];
    }
  }

  String _getImageUrl(dynamic item, int index) {
    String? imageUrl;
    
    // Manejar diferentes tipos de items
    if (item is PuntoTuristico) {
      imageUrl = item.imagenUrl;
    } else if (item is LocalTuristico) {
      imageUrl = item.imagenUrl;
    } else if (item is Map<String, dynamic>) {
      // Si es un map raw, intentar obtener la imagen directamente
      imageUrl = item['imagenUrl'] as String?;
    }
    
    // Debug: Imprimir para verificar qué imagen se está obteniendo
    String itemName = '';
    if (item is PuntoTuristico) {
      itemName = item.nombre;
    } else if (item is LocalTuristico) {
      itemName = item.nombre;
    } else if (item is Map<String, dynamic>) {
      itemName = item['nombre'] as String? ?? 'Sin nombre';
    }
    
    print('Item: $itemName');
    print('ImageUrl obtenida: $imageUrl');
    
    // Si no hay imagen específica o es null, usar una imagen por defecto
    if (imageUrl == null || imageUrl.isEmpty || imageUrl == 'null') {
      final imageIndex = index % _defaultImageUrls.length;
      final defaultImage = _defaultImageUrls[imageIndex];
      print('Usando imagen por defecto: $defaultImage');
      return defaultImage;
    }
    
    print('Usando imagen específica: $imageUrl');
    return imageUrl;
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
        case 2: // Favoritos - ya estamos aquí
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/chatbot');
          break;
      }
    });
  }

  // Método para refrescar la lista de favoritos
  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFavorites,
            tooltip: 'Actualizar favoritos',
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar favoritos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshFavorites,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes favoritos aún',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explora lugares y añádelos a tus favoritos',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text('Explorar lugares'),
                  ),
                ],
              ),
            );
          } else {
            final favorites = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshFavorites,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final favorite = favorites[index];
                  final imageUrl = _getImageUrl(favorite, index);
                  
                  String nombre;
                  String? descripcion;
                  
                  if (favorite is PuntoTuristico) {
                    nombre = favorite.nombre;
                    descripcion = favorite.descripcion;
                  } else if (favorite is LocalTuristico) {
                    nombre = favorite.nombre;
                    descripcion = favorite.descripcion;
                  } else if (favorite is Map<String, dynamic>) {
                    // Manejar maps raw
                    nombre = favorite['nombre'] as String? ?? 'Sin nombre';
                    descripcion = favorite['descripcion'] as String?;
                  } else {
                    nombre = 'Elemento desconocido';
                    descripcion = null;
                  }

                  return CustomCard(
                    imageUrl: imageUrl,
                    title: nombre,
                    subtitle: descripcion != null && descripcion.length > 50
                        ? '${descripcion.substring(0, 50)}...'
                        : descripcion,
                    item: favorite,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detalles',
                        arguments: {
                          'item': favorite,
                          'imageUrl': imageUrl,
                        },
                      );
                    },
                  );
                },
              ),
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