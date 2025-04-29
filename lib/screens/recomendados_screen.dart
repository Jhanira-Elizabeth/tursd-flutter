import 'package:flutter/material.dart';
import '../models/punto_turistico.dart';
import '../widgets/custom_card.dart'; // Importa el CustomCard

class RecomendadosScreen extends StatefulWidget {
  @override
  _RecomendadosScreenState createState() => _RecomendadosScreenState();
}

class _RecomendadosScreenState extends State<RecomendadosScreen> {
  @override
  Widget build(BuildContext context) {
    // Recibe los puntos turísticos desde los argumentos
    final puntos = ModalRoute.of(context)!.settings.arguments as List<PuntoTuristico>;
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
      body: puntos.isEmpty
          ? const Center(child: Text('No hay puntos turísticos disponibles.'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4, // Relación de aspecto para las tarjetas
              ),
              itemCount: puntos.length,
              itemBuilder: (context, index) {
                final punto = puntos[index];
                return CustomCard(
                  imageUrl: punto.imagenUrl ?? 'https://via.placeholder.com/181x147', // URL de la imagen
                  title: punto.nombre, // Nombre del punto turístico
                  subtitle: punto.descripcion, // Descripción opcional
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detalles',
                      arguments: punto,
                    );
                  },
                );
              },
            ),
    );
  }
}