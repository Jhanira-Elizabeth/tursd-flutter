import 'package:flutter/material.dart';
import '../models/punto_turistico.dart';
import '../widgets/custom_card.dart';
import '../widgets/bottom_navigation_bar_turistico.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // IDs recomendados para cada tipo
  final List<int> idsPuntosRecomendados = [3, 5];
  final List<int> idsLocalesRecomendados = [3, 6];

  // Mapa de imágenes personalizadas por tipo y ID
  final Map<String, String> imagenesRecomendados = {
  'punto_3': 'assets/images/congoma1.jpg',           // Ejemplo, cambia el nombre si tienes la imagen real
  'punto_5': 'assets/images/Tapir5.jpg',         // Ejemplo, cambia el nombre si tienes la imagen real
  'local_3': 'assets/images/cascadas_diablo.jpg',    // Ejemplo, cambia el nombre si tienes la imagen real
  'local_4': 'assets/images/afiche_publicitario_balneario_ibiza.jpg',    // Ejemplo, cambia el nombre si tienes la imagen real
  'local_16': 'assets/images/VenturaMiniGolf1.jpg', // Ejemplo, cambia el nombre si tienes la imagen real
};

  // Datos de ejemplo
  final List<PuntoTuristico> puntosRecomendados = [];
  final List<LocalTuristico> localesRecomendados = [];

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

  void _cargarPuntosTuristicos() {
  setState(() {
    puntosRecomendados.addAll([
      PuntoTuristico(
        id: 3,
        nombre: 'Comuna Tsáchila Congoma',
        imagenUrl: 'assets/images/congoma1.jpg', // Usa el nombre real de tu imagen
        descripcion: 'Comunidad ancestral Tsáchila que conserva tradiciones culturales únicas, con actividades interactivas para los visitantes.',
        latitud: -0.390846,
        longitud: -79.351443,
        idParroquia: 39,
        estado: 'activo',
        esRecomendado: true,
      ),
      PuntoTuristico(
        id: 5,
        nombre: 'Zoológico La Isla del Tapir',
        imagenUrl: 'assets/images/tapir5.jpg', // Usa el nombre real de tu imagen
        descripcion: 'Es un lugar ecológico y recreativo.\nproyectado a la conservación de la Flora y Fauna.',
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
        imagenUrl: 'assets/images/cascadas_diablo.jpg', // Usa el nombre real de tu imagen
        descripcion: 'Se debe escalar una montaña de senderos angostos. La ruta se inicia en el kilómetro 38 de la vía Santo Domingo - Quito.',
        direccion: 'Ubicado el recinto Unión del Toachi, kilometro 38 de la vía Santo Domingo - Quito.',
        latitud: -0.328215,
        longitud: -78.948441,
        estado: 'activo',
      ),
      LocalTuristico(
        id: 4,
        nombre: 'Balneario Ibiza',
        imagenUrl: 'assets/images/afiche_publicitario_balneario_ibiza.jpg', // Usa el nombre real de tu imagen
        descripcion: 'Lugar ideal para disfrutar de la naturaleza con piscina, jacuzzi, eventos y karaoke.',
        direccion: 'Parroquia Alluriquín, km 23 vía Santo Domingo - Quito',
        latitud: -0.310870,
        longitud: -79.030298,
        estado: 'activo',
      ),
      LocalTuristico(
        id: 16,
        nombre: 'Aventure mini Golf',
        imagenUrl: 'assets/images/VenturaMiniGolf1.jpg', // Usa el nombre real de tu imagen
        descripcion: 'Este centro de entretenimiento, impulsado por la empresa privada, ofrece opciones como una cancha de pádel, campos de minigolf y un mirador con vistas al río Toachi, promoviendo el disfrute y el desarrollo turístico en la región.',
        direccion: 'Santo Domingo',
        latitud: -0.253312,
        longitud: -79.134135,
        estado: 'activo',
      ),
    ]);
  });
}

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          // Ya estamos en Inicio
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

  @override
  Widget build(BuildContext context) {
final List<dynamic> recomendados = [
  ...puntosRecomendados,
  ...localesRecomendados,
];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de búsqueda (solo visual)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      'Búsqueda',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sección de recomendados
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
              // Carrusel de recomendados
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
      // Puedes pasar información adicional si es necesario
    },
  );
},
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              // Sección de categorías
              _buildSectionHeader(
                'Categorías',
                onPressed: () {
                  Navigator.pushNamed(context, '/categorias');
                },
              ),
              const SizedBox(height: 16),
              // Carrusel de categorías
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }

  // Construye el header de cada sección con botón "Ver todos"
  Widget _buildSectionHeader(String title, {required VoidCallback onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            title == 'Categorías' ? 'Ver todos' : 'Ver Todos',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // Devuelve la imagen personalizada por tipo y ID, o la del modelo, o una por defecto
  String _getImageUrl(dynamic item) {
    if (item == null) return 'assets/images/IndioColorado3.jpg';

    String key = '';
    if (item.runtimeType.toString().contains('PuntoTuristico')) {
      key = 'punto_${item.id}';
    } else if (item.runtimeType.toString().contains('LocalTuristico')) {
      key = 'local_${item.id}';
    }

    if (imagenesRecomendados.containsKey(key)) {
      return imagenesRecomendados[key]!;
    }
    if (item.imagenUrl != null && item.imagenUrl.isNotEmpty) {
      return item.imagenUrl;
    }
    return 'assets/images/IndioColorado3.jpg';
  }
}