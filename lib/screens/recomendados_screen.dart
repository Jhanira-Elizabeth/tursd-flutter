import 'package:flutter/material.dart';
import '../models/punto_turistico.dart';
import '../widgets/custom_card.dart'; // Importa el CustomCard
import '../widgets/bottom_navigation_bar_turistico.dart'; // Importa la barra de navegación

class RecomendadosScreen extends StatefulWidget {
  const RecomendadosScreen({super.key});

  @override
  _RecomendadosScreenState createState() => _RecomendadosScreenState();
}

class _RecomendadosScreenState extends State<RecomendadosScreen> {
  int _currentIndex =
      0; // Por defecto, podrías querer mostrar 'Inicio' seleccionado

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
    // Recibe los puntos turísticos desde los argumentos
    final puntos =
        ModalRoute.of(context)!.settings.arguments as List<PuntoTuristico>;
    print('Puntos recibidos en recomendados: ${puntos.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendados'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          puntos.isEmpty
              ? const Center(
                child: Text('No hay puntos turísticos disponibles.'),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(
                  16,
                ), // Espaciado alrededor de la cuadrícula
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                      3 / 4, // Relación de aspecto para las tarjetas
                ),
                itemCount: puntos.length,
                itemBuilder: (context, index) {
                  final punto = puntos[index];
                  return CustomCard(
                    imageUrl:
                        punto.imagenUrl ??
                        'https://via.placeholder.com/181x147', // Imagen o placeholder
                    title: punto.nombre,
                    onTap: () {
  Navigator.pushNamed(
    context,
    '/detalles',
    arguments: {
      'item': punto,
      'imageUrl': punto.imagenUrl ?? 'https://via.placeholder.com/181x147',
    },
  );
},
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
