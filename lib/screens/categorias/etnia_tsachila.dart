import 'package:flutter/material.dart';
import '../../models/punto_turistico.dart'; // Necesitas importar el modelo LocalTuristico
import '../../widgets/bottom_navigation_bar_turistico.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';
import '../detalle_screen.dart'; // Importa tu DetallesScreen

class EtniaTsachilaScreen extends StatefulWidget {
  const EtniaTsachilaScreen({super.key});

  @override
  _EtniaTsachilaScreenState createState() => _EtniaTsachilaScreenState();
}

class _EtniaTsachilaScreenState extends State<EtniaTsachilaScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _etniaDataFuture;
  // --- Asegúrate que esta imagen exista y esté en pubspec.yaml ---
  final List<String> _defaultImageUrls = ['assets/images/IndioColorado1.jpg'];

  @override
  void initState() {
    super.initState();
    print("EtniaTsachilaScreen: initState - Llamando a _fetchEtniaData");
    _etniaDataFuture = _fetchEtniaData();
  }

  Future<List<dynamic>> _fetchEtniaData() async {
    print("EtniaTsachilaScreen: _fetchEtniaData - Iniciando fetching...");
    try {
      final puntos = await _apiService.fetchPuntosTuristicos();
      print("EtniaTsachilaScreen: Puntos turísticos obtenidos: ${puntos.length}");
      // Descomenta para ver los datos crudos:
      // puntos.forEach((p) => print(" -> Punto ID: ${p.id}, Nombre: ${p.nombre}"));

      final locales = await _apiService.fetchLocalesTuristicos();
      print("EtniaTsachilaScreen: Locales turísticos obtenidos: ${locales.length}");
      // Descomenta para ver los datos crudos:
      // locales.forEach((l) => print(" -> Local ID: ${l.id}, Nombre: ${l.nombre}"));


      final puntoTsachila = puntos.firstWhere(
        (p) => p.id == 3,
        orElse: () {
          print("EtniaTsachilaScreen: No se encontró PuntoTuristico con ID 3.");
          return PuntoTuristico(
            id: 0, nombre: 'No encontrado', descripcion: '', latitud: 0, longitud: 0, idParroquia: 0, estado: 'inactivo', esRecomendado: false);
        },
      );

      final localOtonga = locales.firstWhere(
        (l) => l.id == 5,
        orElse: () {
          print("EtniaTsachilaScreen: No se encontró LocalTuristico con ID 5.");
          return LocalTuristico( // Asegúrate que el constructor coincida con tu modelo
            id: 0, nombre: 'No encontrado', descripcion: '', direccion: '', latitud: 0, longitud: 0, estado: 'inactivo');
        },
      );

      List<dynamic> results = [];
      if (puntoTsachila.id != 0) {
        print("EtniaTsachilaScreen: Añadiendo PuntoTuristico ID ${puntoTsachila.id}");
        results.add(puntoTsachila);
      }
      if (localOtonga.id != 0) {
         print("EtniaTsachilaScreen: Añadiendo LocalTuristico ID ${localOtonga.id}");
        results.add(localOtonga);
      }

      print("EtniaTsachilaScreen: _fetchEtniaData completado. Results count: ${results.length}");
      return results;
    } catch (e, stacktrace) { // Captura también el stacktrace
      print("Error fetching data in EtniaTsachilaScreen: $e");
      print("Stacktrace: $stacktrace"); // Imprime el stacktrace para más detalles
      // Devolver una lista vacía en caso de error para que FutureBuilder muestre "No hay datos"
      // en lugar de potencialmente fallar con el string de error.
      return [];
      // return ["Error al obtener datos. Por favor, intente de nuevo más tarde."]; // Evita devolver String si esperas una lista de objetos
    }
  }

  void _onTabChange(int index) {
    // ... (tu código de navegación sin cambios)
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
     print("EtniaTsachilaScreen: build method ejecutado");
    return Scaffold(
      appBar: AppBar(title: const Text('Étnia Tsáchila')), // Título descriptivo
      body: FutureBuilder<List<dynamic>>(
        future: _etniaDataFuture,
        builder: (context, snapshot) {
          print("EtniaTsachilaScreen: FutureBuilder builder - ConnectionState: ${snapshot.connectionState}");

          if (snapshot.connectionState == ConnectionState.waiting) {
             print("EtniaTsachilaScreen: FutureBuilder - Mostrando CircularProgressIndicator");
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
             print("EtniaTsachilaScreen: FutureBuilder - Error: ${snapshot.error}");
            // Muestra el error específico en la UI para debugging
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
             print("EtniaTsachilaScreen: FutureBuilder - No hay datos o lista vacía");
            // Mensaje claro si no se encontraron datos o la lista está vacía
            return const Center(child: Text('No se encontraron opciones disponibles.'));
          } else {
            // --- ¡Hay datos! Usamos GridView ---
            final data = snapshot.data!;
            print("EtniaTsachilaScreen: FutureBuilder - Datos recibidos, mostrando GridView con ${data.length} items");
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Ajusta si es necesario
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                // --- Intenta obtener la imagen, si falla usa un placeholder o color ---
                String imageUrl;
                try {
                  // Asegura que el índice no se salga de los límites si hay menos items que imágenes default
                  // aunque aquí sólo tienes una imagen default.
                  imageUrl = _defaultImageUrls[index % _defaultImageUrls.length];
                  // Podrías añadir una verificación de que la imagen existe aquí si fuera necesario
                } catch (e) {
                  print("Error al obtener imagen URL en itemBuilder: $e");
                  imageUrl = ''; // O una URL de imagen placeholder válida
                }

                String title = 'Desconocido';
                String subtitle = 'Santo Domingo';
                VoidCallback? onTap;

                // --- Asignación y Navegación ---
                if (item is PuntoTuristico) {
                  title = item.nombre;
                  onTap = () {
                     print("Navegando a /detalles con PuntoTuristico ID: ${item.id}");
                     Navigator.pushNamed(context, '/detalles', arguments: item);
                  };
                } else if (item is LocalTuristico) {
                  title = item.nombre;
                  onTap = () {
                    print("Navegando a /detalles con LocalTuristico ID: ${item.id}");
                    Navigator.pushNamed(context, '/detalles', arguments: item);
                  };
                } else {
                   print("EtniaTsachilaScreen: itemBuilder - Tipo de dato no válido en índice $index: ${item.runtimeType}");
                   // Muestra algo si el tipo no es el esperado
                   return Card(child: Center(child: Text("Dato inválido: ${item.runtimeType}")));
                }

                // --- Renderiza la tarjeta ---
                // Asegúrate que CustomCard maneje bien una imageUrl vacía si puede ocurrir
                return CustomCard(
                  imageUrl: imageUrl,
                  title: title,
                  subtitle: subtitle,
                  onTap: onTap,
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}