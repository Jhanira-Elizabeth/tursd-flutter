import 'package:flutter/material.dart';
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
    final recomendados =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    print('Recomendados recibidos: ${recomendados.length}');

    String _getImageUrl(dynamic item) {
      if (item == null) return 'assets/images/IndioColorado3.jpg';
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
      return 'assets/images/IndioColorado3.jpg';
    }

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
          recomendados.isEmpty
              ? const Center(child: Text('No hay recomendados disponibles.'))
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
                          'imageUrl': _getImageUrl(
                            item,
                          ),
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
