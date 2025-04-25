import 'package:flutter/material.dart';

class CategoriasScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Etnia Tsáchila', 'imagen': 'https://ruta.com/etnia.jpg'},
    {'nombre': 'Parroquias', 'imagen': 'https://ruta.com/parroquias.jpg'},
    {'nombre': 'Alojamiento', 'imagen': 'https://ruta.com/alojamiento.jpg'},
    {'nombre': 'Alimentación', 'imagen': 'https://ruta.com/alimentacion.jpg'},
    {'nombre': 'Parques', 'imagen': 'https://ruta.com/parques.jpg'},
    {'nombre': 'Ríos', 'imagen': 'https://ruta.com/rios.jpg'},
  ];

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categorías'), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1,
        ),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final ruta = '/${categoria['nombre'].toLowerCase().replaceAll(' ', '')}';

          return InkWell(
            onTap: () {
              // Ruta según categoría
              Navigator.pushNamed(context, ruta);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(categoria['imagen'], fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.4)),
                  Center(
                    child: Text(
                      categoria['nombre'],
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
