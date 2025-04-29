import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/punto_turistico.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late Future<List<PuntoTuristico>> _futurePuntos;

  @override
  void initState() {
    super.initState();
    _futurePuntos = ApiService().fetchPuntosTuristicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Puntos Turísticos'),
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _futurePuntos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay puntos turísticos disponibles.'),
            );
          }

          final puntos = snapshot.data!;
          return ListView.builder(
            itemCount: puntos.length,
            itemBuilder: (context, index) {
              final punto = puntos[index];
              return ListTile(
                leading: punto.imagenUrl != null
                    ? Image.network(
                        punto.imagenUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      )
                    : const Icon(Icons.image),
                title: Text(punto.nombre),
                subtitle: Text(punto.descripcion),
              );
            },
          );
        },
      ),
    );
  }
}