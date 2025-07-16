// import 'package:flutter/material.dart';
// import '../models/punto_turistico.dart';
// import '../widgets/detalle_card.dart'; // Importa el componente que muestra los detalles
// import '../widgets/bottom_navigation_bar_turistico.dart'; // Importa el widget

// class PuntoTuristicoListaScreen extends StatefulWidget {
//   PuntoTuristicoListaScreen({super.key}); // Mantenemos el super.key

//   @override
//   State<PuntoTuristicoListaScreen> createState() => _PuntoTuristicoListaScreenState();
// }

// class _PuntoTuristicoListaScreenState extends State<PuntoTuristicoListaScreen> {
//   int _currentIndex = 0; // Por defecto, seleccionamos 'Inicio'

//   final List<PuntoTuristico> puntosTuristicos = [ // Quitamos const aquí
//     PuntoTuristico(
//       id: 1,
//       nombre: 'Congoma',
//       descripcion: 'Hermoso lugar en la naturaleza...',
//       imagenUrl: 'URL_DE_CONGOMA',
//       latitud: -0.1234,
//       longitud: -78.5678,
//       etiquetas: [Etiqueta(id: 1, nombre: 'Naturaleza', descripcion: '...', estado: 'activo')],
//       parroquia: Parroquia(
//         id: 1,
//         nombre: 'Parroquia Congoma',
//         descripcion: 'Descripción de la parroquia...',
//         poblacion: 1000,
//         temperaturaPromedio: 18.5,
//         estado: 'Activa',
//       ),
//       idParroquia: 1,
//       estado: 'Activo',
//       esRecomendado: false,
//       actividades: [],
//     ),
//     // ... otros puntos turísticos
//   ];

//   void _onTabChange(int index) {
//   setState(() {
//     _currentIndex = index;
//     switch (index) {
//       case 0:
//         Navigator.pushReplacementNamed(context, '/home');
//         break;
//       case 1:
//         Navigator.pushReplacementNamed(context, '/mapa');
//         break;
//       case 2: // Favoritos
//         Navigator.pushReplacementNamed(context, '/favoritos');
//         break;
//       case 3:
//         Navigator.pushReplacementNamed(context, '/chatbot');
//         break;
//     }
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Puntos Turísticos')),
//       body: ListView.builder(
//         itemCount: puntosTuristicos.length,
//         itemBuilder: (context, index) {
//           final punto = puntosTuristicos[index];
//           return Card(
//             margin: const EdgeInsets.all(8.0),
//             child: ListTile(
//               leading: SizedBox(
//                 width: 80,
//                 height: 80,
//                 child: punto.imagenUrl != null && punto.imagenUrl!.isNotEmpty
//                     ? Image.asset(
//                         punto.imagenUrl!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
//                       )
//                     : const Icon(Icons.image),
//               ),
//               title: Text(punto.nombre),
//               subtitle: Text('${punto.descripcion.substring(0, 50)}...'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => DetalleCard(puntoTuristico: punto),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBarTuristico(
//         currentIndex: _currentIndex,
//         onTabChange: _onTabChange,
//       ),
//     );
//   }
// }