import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa Provider
import '../../models/punto_turistico.dart'; // Asegúrate de que Parroquia esté definido aquí
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../providers/theme_provider.dart'; // Importa tu ThemeProvider

class DetallesParroquiaScreen extends StatefulWidget {
  const DetallesParroquiaScreen({Key? key}) : super(key: key);

  @override
  _DetallesParroquiaScreenState createState() =>
      _DetallesParroquiaScreenState();
}

class _DetallesParroquiaScreenState extends State<DetallesParroquiaScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0; // Para la BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Importante: liberar el controlador del TabBar
    super.dispose();
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

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final Parroquia parroquia = args['parroquia'];
    final String imageUrl = args['imageUrl'];

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Usa el color de fondo del tema
      body: Stack(
        children: [
          // Imagen de cabecera
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Puedes mostrar un placeholder adaptado al tema aquí también
                return Container(
                  color: theme.colorScheme.surfaceVariant, // Color de placeholder
                  child: Center(
                    child: Icon(Icons.broken_image, color: theme.colorScheme.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
          // Botón de regreso
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface.withOpacity(0.6), // Color de fondo del tema con opacidad
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface), // Color del icono del tema
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Contenido desplazable sobre la imagen
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface, // Usa el color de superficie del tema
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Título y tabs
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parroquia.nombre,
                            style: theme.textTheme.headlineMedium?.copyWith( // Usa el estilo de texto del tema
                              color: theme.colorScheme.onSurface, // Color de texto que contrasta con la superficie
                            ),
                          ),
                          const SizedBox(height: 8),
                          TabBar(
                            controller: _tabController,
                            labelColor: theme.colorScheme.primary, // Color principal del tema
                            unselectedLabelColor: theme.colorScheme.onSurfaceVariant, // Color para etiquetas no seleccionadas
                            indicatorColor: theme.colorScheme.primary, // Color del indicador del tema
                            tabs: const [
                              Tab(text: 'Información'),
                              Tab(text: 'Ubicación'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Información
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Descripción',
                                    style: theme.textTheme.titleLarge?.copyWith( // Usa estilo de título grande
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    parroquia.descripcion,
                                    style: theme.textTheme.bodyLarge?.copyWith( // Usa estilo de cuerpo grande
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Más Información',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Población: ${parroquia.poblacion}',
                                    style: theme.textTheme.bodyMedium?.copyWith( // Usa estilo de cuerpo medio
                                      color: theme.colorScheme.onSurface, // El mismo color que el texto principal
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Temperatura Promedio: ${parroquia.temperaturaPromedio}°C',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Ubicación
                          Center(
                            child: Text(
                              'Aquí puedes mostrar un mapa o la dirección de la parroquia.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
        // El BottomNavigationBarTuristico debería adaptarse por sí mismo si está bien diseñado.
        // Si no lo hace, necesitarías pasarle las propiedades de color de tu tema.
      ),
    );
  }
}