import 'package:flutter/material.dart';
import '../punto_turistico.dart';

class AtraccionesScreen extends StatelessWidget {
  final List<PuntoTuristico> atracciones;

  AtraccionesScreen({required this.atracciones});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Atracciones')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: atracciones.length,
        itemBuilder: (context, index) {
          final punto = atracciones[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Image.network(punto.imagenUrl ?? '', width: 60, height: 60, fit: BoxFit.cover),
              title: Text(punto.nombre),
              subtitle: Text(punto.descripcion ?? ''),
              onTap: () {
                Navigator.pushNamed(context, '/detalles', arguments: punto);
              },
            ),
          );
        },
      ),
    );
  }
}
