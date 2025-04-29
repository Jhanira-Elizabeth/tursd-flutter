import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/punto_turistico.dart';
import 'dart:math' as math;

class RecomendadosScreen extends StatefulWidget {
  @override
  _RecomendadosScreenState createState() => _RecomendadosScreenState();
}

class _RecomendadosScreenState extends State<RecomendadosScreen> {
  late Future<List<PuntoTuristico>> _futurePuntos;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _futurePuntos = _fetchData();
  }

  Future<List<PuntoTuristico>> _fetchData() async {
    try {
      // Obtén todos los puntos turísticos
      final puntos = await ApiService().fetchPuntosTuristicos();

      // Filtra los puntos turísticos que son recomendados
      return puntos.where((punto) => punto.esRecomendado).toList();
    } catch (e) {
      print('Error fetching data: $e');
      if (!mounted) return [];

      // Muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar datos: ${e.toString().substring(0, math.min(50, e.toString().length))}...',
          ),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: _refreshData,
          ),
        ),
      );
      return [];
    }
  }

  void _refreshData() {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _futurePuntos = _fetchData().whenComplete(() {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<PuntoTuristico>>(
        future: _futurePuntos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar datos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 60, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'No hay puntos turísticos disponibles',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final puntos = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
              // Wait for the refresh to complete
              await _futurePuntos;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: puntos.length,
              itemBuilder: (context, index) {
                final punto = puntos[index];
                return PuntoTuristicoCard(punto: punto);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: const Color(0xFF9DAF3A),
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/mapa');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/chatbot');
          }
        },
      ),
    );
  }
}

// Extracted card widget for better maintainability
class PuntoTuristicoCard extends StatelessWidget {
  final PuntoTuristico punto;

  const PuntoTuristicoCard({Key? key, required this.punto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detalles',
          arguments: punto,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  child: punto.imagenUrl != null && punto.imagenUrl!.isNotEmpty
                      ? Image.network(
                          punto.imagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 50),
                        ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        punto.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF9DAF3A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (punto.descripcion != null && punto.descripcion!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            punto.descripcion!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}