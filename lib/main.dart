import 'package:flutter/material.dart';
import 'api_service.dart';
import 'punto_turistico.dart';

class ListaPuntosPage extends StatefulWidget {
  @override
  _ListaPuntosPageState createState() => _ListaPuntosPageState();
}

class _ListaPuntosPageState extends State<ListaPuntosPage> {
  late Future<List<PuntoTuristico>> _futurePuntos;

  @override
  void initState() {
    super.initState();
    _futurePuntos = ApiService().fetchPuntosTuristicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Puntos Turísticos')),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _futurePuntos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay puntos turísticos.'));
          }

          final puntos = snapshot.data!;

          return ListView.builder(
            itemCount: puntos.length,
            itemBuilder: (context, index) {
              final punto = puntos[index];
              return ListTile(
                title: Text(punto.nombre),
                subtitle: Text(punto.descripcion),
                onTap: () {
                  // Aquí podrías navegar a un detalle o abrir mapa
                },
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tursd App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: ListaPuntosPage(),
    );
  }
}
