import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart'; // Asegúrate de que Parroquia esté aquí
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';

class DetallesParroquiaScreen extends StatefulWidget {
  final Parroquia parroquia;

  const DetallesParroquiaScreen({Key? key, required this.parroquia}) : super(key: key);

  @override
  _DetallesParroquiaScreenState createState() => _DetallesParroquiaScreenState();
}

class _DetallesParroquiaScreenState extends State<DetallesParroquiaScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0; // Para el BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Una sola pestaña para la información básica
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
        case 2:
          Navigator.pushReplacementNamed(context, '/chatbot');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parroquia.nombre ?? 'Detalles de la Parroquia'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Información'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contenido de la pestaña Información
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/Bomboli8.jpg', // Imagen por defecto
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink(); // O muestra un widget de error
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  widget.parroquia.nombre ?? '',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                const SizedBox(height: 16),
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.parroquia.descripcion ?? 'No hay descripción disponible.'),
                const SizedBox(height: 16),
                const Text(
                  'Más Información',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Población: ${widget.parroquia.poblacion}',
                  style: TextStyle(color: Colors.blue.shade300, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Temperatura Promedio: ${widget.parroquia.temperaturaPromedio}°C',
                  style: TextStyle(color: Colors.orange.shade300, fontWeight: FontWeight.bold),
                ),
                // Puedes agregar aquí más información de la parroquia que quieras mostrar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}