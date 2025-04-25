import 'package:flutter/material.dart';
import '../punto_turistico.dart';

class ParquesScreen extends StatelessWidget {
  final List<PuntoTuristico> parques;

  ParquesScreen({required this.parques});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Parques')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
        ),
        itemCount: parques.length,
        itemBuilder: (context, index) {
          final parque = parques[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, '/detalles', arguments: parque),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(parque.imagenUrl ?? '', fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  parque.nombre,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9DAF3A)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
