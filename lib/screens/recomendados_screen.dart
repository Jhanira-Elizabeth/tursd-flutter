import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa Provider
import '../widgets/custom_card.dart'; // Importa el CustomCard
import '../models/punto_turistico.dart'; // Importa el modelo
import '../widgets/bottom_navigation_bar_turistico.dart'; // Importa la barra de navegación
import '../providers/theme_provider.dart'; // Importa tu ThemeProvider

class RecomendadosScreen extends StatefulWidget {
  const RecomendadosScreen({super.key});

  @override
  _RecomendadosScreenState createState() => _RecomendadosScreenState();
}

class _RecomendadosScreenState extends State<RecomendadosScreen> {
  int _currentIndex = 0; // Por defecto, podrías querer mostrar 'Inicio' seleccionado

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Determinar el currentIndex basado en la ruta actual si es necesario,
    // o asegúrate de que la navegación pushReplacementNamed maneje el estado de la barra.
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == '/home') {
      _currentIndex = 0;
    } else if (currentRoute == '/mapa') {
      _currentIndex = 1;
    } else if (currentRoute == '/favoritos') {
      _currentIndex = 2;
    } else if (currentRoute == '/chatbot') {
      _currentIndex = 3;
    } else if (currentRoute == '/recomendados') {
      _currentIndex = 0; // Ajusta este índice si 'Recomendados' tiene una posición específica
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

  String _getImageUrl(dynamic item) {
    if (item == null) return 'assets/images/default_placeholder.jpg';
    String key = '';
    if (item.runtimeType.toString().contains('PuntoTuristico')) {
      key = 'punto_${item.id}';
    } else if (item.runtimeType.toString().contains('LocalTuristico')) {
      key = 'local_${item.id}';
    }
    final imagenesRecomendados = {
      'punto_3': 'assets/images/congoma1.jpg',
      'punto_5': 'assets/images/Tapir5.jpg',
      'local_3': 'assets/images/cascadas_diablo.jpg',
      'local_4': 'assets/images/afiche_publicitario_balneario_ibiza.jpg',
      'local_16': 'assets/images/VenturaMiniGolf1.jpg',
    };
    if (imagenesRecomendados.containsKey(key)) {
      return imagenesRecomendados[key]!;
    }
    if (item.imagenUrl != null && item.imagenUrl.isNotEmpty) {
      return item.imagenUrl;
    }
    return 'assets/images/default_placeholder.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final recomendados =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    print('Recomendados recibidos: ${recomendados.length}');

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Recomendados',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón para cambiar el tema
          IconButton(
            icon: Icon(
              // ¡CAMBIO CLAVE AQUÍ! Usar themeMode para determinar el icono
              themeProvider.themeMode == ThemeMode.dark ? Icons.wb_sunny : Icons.nightlight_round,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: recomendados.isEmpty
          ? Center(
              child: Text(
                'No hay recomendados disponibles.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: recomendados.length,
              itemBuilder: (context, index) {
                final item = recomendados[index];
                return CustomCard(
                  imageUrl: _getImageUrl(item),
                  title: item.nombre,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalles',
                      arguments: {
                        'item': item,
                      },
                    );
                  },
                  item: item,
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