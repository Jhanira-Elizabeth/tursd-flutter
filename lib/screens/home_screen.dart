import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa provider
import '../providers/theme_provider.dart'; // Importa tu ThemeProvider
import '../models/punto_turistico.dart';
import '../widgets/custom_card.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';
// Si usas CarouselSlider en Home, asegúrate de tenerlo importado y añadido a pubspec.yaml
// import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  // Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();

  // Listas originales y filtradas
  final List<PuntoTuristico> puntosRecomendados = [];
  final List<LocalTuristico> localesRecomendados = [];
  List<dynamic> _resultadosBusqueda = [];
  bool _buscando = false;

  // IDs recomendados para cada tipo (No los usamos directamente, pero los mantengo si los necesitas para otra cosa)
  final List<int> idsPuntosRecomendados = [3, 5];
  final List<int> idsLocalesRecomendados = [3, 6];

  // Mapa de imágenes personalizadas por tipo y ID
  final Map<String, String> imagenesRecomendados = {
    'punto_3': 'assets/images/congoma1.jpg',
    'punto_5': 'assets/images/Tapir5.jpg',
    'local_3': 'assets/images/cascadas_diablo.jpg',
    'local_4': 'assets/images/afiche_publicitario_balneario_ibiza.jpg',
    'local_16': 'assets/images/VenturaMiniGolf1.jpg',
  };

  final List<Map<String, dynamic>> categorias = [
    {
      'nombre': 'Etnia Tsáchila',
      'imagen': 'assets/images/Mushily1.jpg',
      'route': '/etniatsachila',
    },
    {
      'nombre': 'Atracciones',
      'imagen': 'assets/images/GorilaPark1.jpg',
      'route': '/atracciones',
    },
    {
      'nombre': 'Parroquias',
      'imagen': 'assets/images/ValleHermoso1.jpg',
      'route': '/parroquias',
    },
    {
      'nombre': 'Alojamiento',
      'imagen': 'assets/images/HotelRefugio1.jpg',
      'route': '/alojamiento',
    },
    {
      'nombre': 'Alimentación',
      'imagen': 'assets/images/OhQueRico1.jpg',
      'route': '/alimentacion',
    },
    {
      'nombre': 'Parques',
      'imagen': 'assets/images/ParqueJuventud1.jpg',
      'route': '/parques',
    },
    {
      'nombre': 'Ríos',
      'imagen': 'assets/images/SanGabriel1.jpg',
      'route': '/rios',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarPuntosTuristicos();
    _cargarLocalesRecomendados();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarPuntosTuristicos() {
    setState(() {
      puntosRecomendados.addAll([
        PuntoTuristico(
          id: 3,
          nombre: 'Comuna Tsáchila Congoma',
          imagenUrl: 'assets/images/congoma1.jpg',
          descripcion:
              'Comunidad ancestral Tsáchila que conserva tradiciones culturales únicas, con actividades interactivas para los visitantes.',
          latitud: -0.390846,
          longitud: -79.351443,
          idParroquia: 39,
          estado: 'activo',
          esRecomendado: true,
        ),
        PuntoTuristico(
          id: 5,
          nombre: 'Zoológico La Isla del Tapir',
          imagenUrl: 'assets/images/Tapir5.jpg',
          descripcion:
              'Es un lugar ecológico y recreativo.\nproyectado a la conservación de la Flora y Fauna.',
          latitud: -0.117760,
          longitud: -79.258118,
          idParroquia: 37,
          estado: 'activo',
          esRecomendado: true,
        ),
      ]);
    });
  }

  void _cargarLocalesRecomendados() {
    setState(() {
      localesRecomendados.addAll([
        LocalTuristico(
          id: 3,
          nombre: 'Cascadas del Diablo',
          imagenUrl: 'assets/images/cascadas_diablo.jpg',
          descripcion:
              'Se debe escalar una montaña de senderos angostos. La ruta se inicia en el kilómetro 38 de la vía Santo Domingo - Quito.',
          direccion:
              'Ubicado el recinto Unión del Toachi, kilometro 38 de la vía Santo Domingo - Quito.',
          latitud: -0.328215,
          longitud: -78.948441,
          estado: 'activo',
        ),
        LocalTuristico(
          id: 4,
          nombre: 'Balneario Ibiza',
          imagenUrl: 'assets/images/afiche_publicitario_balneario_ibiza.jpg',
          descripcion:
              'Lugar ideal para disfrutar de la naturaleza con piscina, jacuzzi, eventos y karaoke.',
          direccion: 'Parroquia Alluriquín, km 23 vía Santo Domingo - Quito',
          latitud: -0.310870,
          longitud: -79.030298,
          estado: 'activo',
        ),
        LocalTuristico(
          id: 16,
          nombre: 'Aventure mini Golf',
          imagenUrl: 'assets/images/VenturaMiniGolf1.jpg',
          descripcion:
              'Este centro de entretenimiento, impulsado por la empresa privada, ofrece opciones como una cancha de pádel, campos de minigolf y un mirador con vistas al río Toachi, promoviendo el disfrute y el desarrollo turístico en la región.',
          direccion: 'Santo Domingo',
          latitud: -0.253312,
          longitud: -79.134135,
          estado: 'activo',
        ),
      ]);
      print('Locales cargados: ${localesRecomendados.length}');
      localesRecomendados.forEach((local) {
        print('Local: ${local.nombre}, tipo: ${local.runtimeType}');
      });
    });
  }

  // Función para normalizar texto (quitar acentos y convertir a minúsculas)
  String _normalizarTexto(String texto) {
    final Map<String, String> reemplazos = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U',
      'ü': 'u', 'Ü': 'U', 'ñ': 'n', 'Ñ': 'N',
    };

    String resultado = texto.toLowerCase();

    reemplazos.forEach((key, value) {
      resultado = resultado.replaceAll(key, value);
    });

    return resultado;
  }

  // Función para realizar la búsqueda
  void _buscar(String query) {
    if (query.isEmpty) {
      setState(() {
        _buscando = false;
        _resultadosBusqueda = [];
      });
      return;
    }

    final String queryNormalizado = _normalizarTexto(query);

    final List<PuntoTuristico> puntosFiltrados = puntosRecomendados.where((punto) {
      final String nombreNormalizado = _normalizarTexto(punto.nombre);
      return nombreNormalizado.contains(queryNormalizado);
    }).toList();

    final List<LocalTuristico> localesFiltrados = localesRecomendados.where((local) {
      final String nombreNormalizado = _normalizarTexto(local.nombre);
      return nombreNormalizado.contains(queryNormalizado);
    }).toList();

    final List<dynamic> resultadosCombinados = [...puntosFiltrados, ...localesFiltrados];

    print('Búsqueda: $query');
    print('Puntos encontrados: ${puntosFiltrados.length}');
    print('Locales encontrados: ${localesFiltrados.length}');
    print('Total resultados: ${resultadosCombinados.length}');

    setState(() {
      _buscando = true;
      _resultadosBusqueda = resultadosCombinados;
    });
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          // Ya estamos en Home
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

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final List<dynamic> recomendados = [
      ...puntosRecomendados,
      ...localesRecomendados,
    ];

    // Accede al ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inicio',
          // El color del título del AppBar se manejará por theme.appBarTheme.foregroundColor
        ),
        // La configuración de backgroundColor y foregroundColor ahora se toma de theme.appBarTheme
        elevation: 0,
        actions: [
          // Botón de alternar tema (sol/luna)
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.wb_sunny // Sol
                  : Icons.dark_mode, // Luna
              // El color del icono se tomará de theme.appBarTheme.foregroundColor
            ),
            onPressed: () {
              themeProvider.toggleTheme(); // Llama al método para cambiar el tema
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.pushNamed(context, '/categorias');
            },
          ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleSignOut,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de búsqueda funcional
              Container(
                height: 48,
                decoration: BoxDecoration(
                  // Usa el color de la superficie del tema
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Color del texto de entrada
                  decoration: InputDecoration(
                    hintText: 'Búsqueda',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), // Color del hint
                      fontSize: 16,
                    ),
                    icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 10),
                  ),
                  onChanged: _buscar,
                ),
              ),
              const SizedBox(height: 24),

              // Mostrar resultados de búsqueda o contenido normal
              if (_buscando) ...[
                Text(
                  'Resultados de búsqueda',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        // El color se toma de textTheme.headlineSmall o de colorScheme.onBackground
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                const SizedBox(height: 16),
                _resultadosBusqueda.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron resultados',
                          style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _resultadosBusqueda.length,
                        itemBuilder: (context, index) {
                          final item = _resultadosBusqueda[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              color: Theme.of(context).colorScheme.surface, // Color de la tarjeta
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    _getImageUrl(item),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  item.nombre,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Color del texto
                                ),
                                subtitle: Text(
                                  item is PuntoTuristico
                                      ? 'Punto Turístico'
                                      : 'Local Turístico',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), // Color del subtítulo
                                ),
                                onTap: () {
                                  String? detalleImagenUrl;
                                  String key = '';
                                  if (item is PuntoTuristico) {
                                    key = 'punto_${item.id}';
                                  } else if (item is LocalTuristico) {
                                    key = 'local_${item.id}';
                                  }

                                  if (imagenesRecomendados.containsKey(key)) {
                                    detalleImagenUrl = imagenesRecomendados[key];
                                  } else {
                                    detalleImagenUrl = item.imagenUrl;
                                  }

                                  Navigator.pushNamed(
                                    context,
                                    '/detalles',
                                    arguments: {
                                      'item': item,
                                      'imageUrl': detalleImagenUrl,
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ] else ...[
                // Contenido original cuando no hay búsqueda
                _buildSectionHeader(
                  'Recomendados',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/recomendados',
                      arguments: [...puntosRecomendados, ...localesRecomendados],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: recomendados.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recomendados.length.clamp(0, 5),
                          itemBuilder: (context, index) {
                            final item = recomendados[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < recomendados.length - 1 ? 12.0 : 0.0,
                              ),
                              child: SizedBox(
                                width: 160,
                                child: CustomCard(
                                  imageUrl: _getImageUrl(item),
                                  title: item.nombre,
                                  // Asumiendo que PuntoTuristico tiene parroquia y LocalTuristico tiene direccion
                                  subtitle: item is PuntoTuristico
                                      ? item.parroquia?.nombre ?? 'Santo Domingo'
                                      : (item is LocalTuristico ? item.direccion ?? 'Santo Domingo' : ''),
                                  onTap: () {
                                    String? detalleImagenUrl;
                                    String key = '';
                                    if (item is PuntoTuristico) {
                                      key = 'punto_${item.id}';
                                    } else if (item is LocalTuristico) {
                                      key = 'local_${item.id}';
                                    }
                                    if (imagenesRecomendados.containsKey(key)) {
                                      detalleImagenUrl = imagenesRecomendados[key];
                                    } else {
                                      detalleImagenUrl = item.imagenUrl;
                                    }

                                    Navigator.pushNamed(
                                      context,
                                      '/detalles',
                                      arguments: {
                                        'item': item,
                                        'imageUrl': detalleImagenUrl,
                                      },
                                    );
                                  },
                                  item: item,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Categorías',
                  onPressed: () {
                    Navigator.pushNamed(context, '/categorias');
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: SizedBox(
                          width: 160,
                          child: CustomCard(
                            imageUrl: categoria['imagen'],
                            title: categoria['nombre'],
                            onTap: () {
                              Navigator.pushNamed(context, categoria['route']);
                            },
                            item: categoria,
                            // Si tu CustomCard espera un 'subtitle' para las categorías,
                            // podrías añadirlo aquí, o modificar CustomCard para ser más flexible.
                            // Por ahora, lo omitimos si no es necesario para categorías.
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
        // El color del BottomNavigationBar se tomará de theme.bottomNavigationBarTheme
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onPressed}) {
    // El color del texto del encabezado se tomará de textTheme o colorScheme.onBackground
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground, // Color del texto
              ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            title == 'Categorías' ? 'Ver todos' : 'Ver Todos',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), fontSize: 14), // Color del texto del botón
          ),
        ),
      ],
    );
  }

  String _getImageUrl(dynamic item) {
    if (item == null) return 'assets/images/IndioColorado3.jpg';

    String key = '';
    // Usa `is` para verificar el tipo, es más seguro que `runtimeType.toString().contains`
    if (item is PuntoTuristico) {
      key = 'punto_${item.id}';
    } else if (item is LocalTuristico) {
      key = 'local_${item.id}';
    } else if (item is Map<String, dynamic> && item.containsKey('imagen')) {
      // Manejar el caso de las categorías
      return item['imagen'] as String;
    }


    if (imagenesRecomendados.containsKey(key)) {
      return imagenesRecomendados[key]!;
    }
    // Asegúrate de que item.imagenUrl exista y sea un String antes de usarlo
    if ((item is PuntoTuristico && item.imagenUrl != null && item.imagenUrl!.isNotEmpty) ||
        (item is LocalTuristico && item.imagenUrl != null && item.imagenUrl!.isNotEmpty)) {
      return item.imagenUrl!;
    }
    return 'assets/images/IndioColorado3.jpg';
  }
}