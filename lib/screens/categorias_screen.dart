import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa Provider
import '../widgets/custom_card.dart'; // Importa el CustomCard widget
import '../widgets/bottom_navigation_bar_turistico.dart'; // Importa el widget
import '../providers/theme_provider.dart'; // Importa tu ThemeProvider

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key}); // Usa const si no hay estado inicial

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  int _currentIndex = 0; // Por defecto, seleccionamos 'Inicio'

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
      'route': 'assets/images/ParroquiaNuevo.jpg', // Este es el que debe corregirse al navegar
    },
    {
      'nombre': 'Alojamiento',
      'imagen': 'assets/images/HotelRefugio1.jpg',
      'route': '/alojamiento',
    },
    {
      'nombre': 'Alimentos',
      'imagen': 'assets/images/OhQueRico1.jpg',
      'route': '/alimentacion',
    },
    {
      'nombre': 'Parques',
      'imagen': 'assets/images/ParqueJuventud1.jpg',
      'route': '/parques',
    },
    {
      'nombre': 'Rios',
      'imagen': 'assets/images/SanGabriel1.jpg',
      'route': '/rios',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Determinar el currentIndex basado en la ruta actual si es necesario.
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == '/home') {
      _currentIndex = 0;
    } else if (currentRoute == '/mapa') {
      _currentIndex = 1;
    } else if (currentRoute == '/favoritos') {
      _currentIndex = 2;
    } else if (currentRoute == '/chatbot') {
      _currentIndex = 3;
    } else if (currentRoute == '/categorias') {
      _currentIndex = 0; // Si esta pantalla no es una pestaña principal, puede apuntar a 'Home'
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // Accede al ThemeProvider

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Usa el color de fondo del tema
      appBar: AppBar(
        title: Text(
          'Categorías',
          style: theme.appBarTheme.titleTextStyle, // Usa el estilo de texto del AppBar del tema
        ),
        backgroundColor: theme.appBarTheme.backgroundColor, // Usa el color de fondo del AppBar del tema
        foregroundColor: theme.appBarTheme.foregroundColor, // Usa el color de primer plano del AppBar del tema
        elevation: theme.appBarTheme.elevation, // Usa la elevación del AppBar del tema
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.iconTheme?.color, // Usa el color de icono del AppBar del tema
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón para cambiar el tema
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark ? Icons.wb_sunny : Icons.nightlight_round,
              color: theme.appBarTheme.iconTheme?.color, // Usa el color de icono del AppBar del tema
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 4,
        ),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          return CustomCard(
            imageUrl: categoria['imagen'],
            title: categoria['nombre'],
            onTap: () {
              // Corrección para la ruta de Parroquias si era un error y debe ser una ruta
              if (categoria['route'] == 'assets/images/ParroquiaNuevo.jpg') {
                Navigator.pushNamed(context, '/parroquias'); // Asume que '/parroquias' es la ruta correcta
              } else {
                Navigator.pushNamed(context, categoria['route']);
              }
            },
            item: categoria,
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