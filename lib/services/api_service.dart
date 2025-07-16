import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/punto_turistico.dart';

class ApiService {
  // URL base de la API
  final String baseUrl =
      'https://tursd-grhzehh6hta4e9en.eastus-01.azurewebsites.net/api/v1';

  // Maneja la respuesta de la API para un solo objeto
  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) {
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      return Future.value(fromJson(jsonData));
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

  // Maneja la respuesta de la API para una lista de objetos
  Future<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(dynamic) fromJsonList,
  ) {
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return Future.value(data.map((json) => fromJsonList(json)).toList());
    } else {
      throw Exception(
        'Error al cargar la lista de datos: ${response.statusCode}',
      );
    }
  }

  // =======================
  // PUNTOS TURÍSTICOS
  // =======================

  // Obtiene todos los puntos turísticos
  Future<List<PuntoTuristico>> fetchPuntosTuristicos() async {
    final response = await http.get(Uri.parse('$baseUrl/puntos'));
    return _handleListResponse(
      response,
      (json) => PuntoTuristico.fromJson(json),
    );
  }

  // Obtiene un punto turístico por su ID
  Future<PuntoTuristico> fetchPuntoTuristicoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos/$id'));
    return _handleResponse(response, (json) => PuntoTuristico.fromJson(json));
  }

  // Obtiene puntos turísticos por parroquia
  Future<List<PuntoTuristico>> fetchPuntosByParroquia(int parroquiaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/puntos?id_parroquia=$parroquiaId'),
    );
    return _handleListResponse(
      response,
      (json) => PuntoTuristico.fromJson(json),
    );
  }

  // Obtiene puntos turísticos por ID de etiqueta
  Future<List<PuntoTuristico>> fetchPuntosByEtiqueta(int etiquetaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/puntos?id_etiqueta=$etiquetaId'),
    );
    return _handleListResponse(
      response,
      (json) => PuntoTuristico.fromJson(json),
    );
  }

  // Obtiene puntos turísticos por nombre de etiqueta
  Future<List<PuntoTuristico>> fetchPuntosTuristicosByEtiqueta(
    String etiquetaNombre,
  ) async {
    // Busca el ID de la etiqueta por su nombre
    final etiquetaId = await _getEtiquetaIdByName(etiquetaNombre);
    if (etiquetaId == null) {
      return []; // Si no existe, retorna lista vacía
    }
    // Usa el ID para obtener los puntos turísticos
    return fetchPuntosByEtiqueta(etiquetaId);
  }

  // Busca el ID de una etiqueta por su nombre
  Future<int?> _getEtiquetaIdByName(String etiquetaNombre) async {
    final response = await http.get(Uri.parse('$baseUrl/etiquetas'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      for (var item in data) {
        if (item['nombre'] == etiquetaNombre) {
          return item['id'];
        }
      }
      return null; // Si no encuentra la etiqueta
    } else {
      throw Exception('Error al cargar etiquetas: ${response.statusCode}');
    }
  }

  // Busca puntos turísticos por texto (búsqueda)
  Future<List<PuntoTuristico>> searchPuntosTuristicos(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos?q=$query'));
    return _handleListResponse(
      response,
      (json) => PuntoTuristico.fromJson(json),
    );
  }

  // Obtiene actividades de un punto turístico
  Future<List<Actividad>> fetchActividadesByPunto(int puntoId) async {
  final response = await http.get(Uri.parse('$baseUrl/actividades'));
  
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map((json) => Actividad.fromJson(json))
        .where((actividad) => actividad.idPuntoTuristico == puntoId)
        .toList();
  } else {
    throw Exception('Error al cargar actividades: ${response.statusCode}');
  }
}

  // =======================
  // LOCALES TURÍSTICOS
  // =======================

  // Obtiene todos los locales turísticos
  Future<List<LocalTuristico>> fetchLocalesTuristicos() async {
    final response = await http.get(Uri.parse('$baseUrl/locales'));
    return _handleListResponse(
      response,
      (json) => LocalTuristico.fromJson(json),
    );
  }

  // Obtiene un local turístico por su ID
  Future<LocalTuristico> fetchLocalTuristicoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/locales/$id'));
    return _handleResponse(response, (json) => LocalTuristico.fromJson(json));
  }

  // =======================
  // PARROQUIAS
  // =======================

  // Obtiene todas las parroquias
  Future<List<Parroquia>> fetchParroquias() async {
    final response = await http.get(Uri.parse('$baseUrl/parroquias'));
    return _handleListResponse(response, (json) => Parroquia.fromJson(json));
  }

  // =======================
  // ETIQUETAS
  // =======================

  // Obtiene todas las etiquetas
  Future<List<Etiqueta>> fetchEtiquetas() async {
    final response = await http.get(Uri.parse('$baseUrl/etiquetas'));
    return _handleListResponse(response, (json) => Etiqueta.fromJson(json));
  }

  // =======================
  // RELACIÓN LOCAL-ETIQUETA
  // =======================

  // Obtiene la relación entre locales y etiquetas
  Future<List<Map<String, dynamic>>> fetchLocalEtiquetas() async {
    final response = await http.get(Uri.parse('$baseUrl/local-etiqueta'));
    if (response.statusCode == 200) {
      return Future.value(
        (json.decode(response.body) as List).cast<Map<String, dynamic>>(),
      );
    } else {
      throw Exception('Error al cargar las relaciones local-etiqueta');
    }
  }

  // =======================
  // SERVICIOS
  // =======================

  // Obtiene todos los servicios
  Future<List<Servicio>> fetchServicios() async {
    final response = await http.get(Uri.parse('$baseUrl/servicios'));
    return _handleListResponse(response, (json) => Servicio.fromJson(json));
  }

  // Obtiene servicios por local
  Future<List<Servicio>> fetchServiciosByLocal(int localId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicios?id_local=$localId'),
    );
    return _handleListResponse(response, (json) => Servicio.fromJson(json));
  }
  

  // =======================
  // HORARIOS DE ATENCIÓN
  // =======================

  // Obtiene todos los horarios
  Future<List<HorarioAtencion>> fetchHorarios() async {
    final response = await http.get(Uri.parse('$baseUrl/horarios'));
    return _handleListResponse(
      response,
      (json) => HorarioAtencion.fromJson(json),
    );
  }

  // Obtiene horarios por local
  Future<List<HorarioAtencion>> fetchHorariosByLocal(int localId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/horarios?id_local=$localId'),
    );
    return _handleListResponse(
      response,
      (json) => HorarioAtencion.fromJson(json),
    );
  }

  // =======================
  // LOCALES CON ETIQUETAS
  // =======================

  // Obtiene los locales turísticos con sus etiquetas asociadas
  Future<List<LocalTuristico>> fetchLocalesConEtiquetas() async {
    final locales = await fetchLocalesTuristicos();
    final relaciones = await fetchLocalEtiquetas();
    final etiquetas = await fetchEtiquetas();

    for (var local in locales) {
      final etiquetasIds =
          relaciones
              .where((rel) => rel['id_local'] == local.id)
              .map((rel) => rel['id_etiqueta'])
              .toList();

      final etiquetasLocal =
          etiquetas.where((et) => etiquetasIds.contains(et.id)).toList();

      local.etiquetas = etiquetasLocal;
    }

    return locales;
  }

  // =======================
  // RELACIÓN PUNTO-ETIQUETA
  // =======================

  // Obtiene la relación entre puntos turísticos y etiquetas


// Obtiene la relación entre puntos turísticos y etiquetas
Future<List<Map<String, dynamic>>> fetchPuntoEtiquetas() async {
  final response = await http.get(Uri.parse('$baseUrl/punto-etiqueta'));
  if (response.statusCode == 200) {
    return Future.value(
      (json.decode(response.body) as List).cast<Map<String, dynamic>>(),
    );
  } else {
    throw Exception('Error al cargar las relaciones punto-etiqueta');
  }
}

// Obtiene los puntos turísticos con sus etiquetas asociadas
Future<List<PuntoTuristico>> fetchPuntosConEtiquetas() async {
  final puntos = await fetchPuntosTuristicos();
  final relaciones = await fetchPuntoEtiquetas();
  final etiquetas = await fetchEtiquetas();

  for (var punto in puntos) {
    final etiquetasIds = relaciones
        .where((rel) => rel['id_punto_turistico'] == punto.id)
        .map((rel) => rel['id_etiqueta'])
        .toList();

    final etiquetasPunto =
        etiquetas.where((et) => etiquetasIds.contains(et.id)).toList();

    punto.etiquetas = etiquetasPunto;
  }

  return puntos;
}

Future<List<Actividad>> fetchActividadesByPuntoId(int puntoId) async {
  final response = await http.get(Uri.parse('$baseUrl/actividades'));
  final todas = await _handleListResponse(response, (json) => Actividad.fromJson(json));
  return todas.where((a) => a.idPuntoTuristico == puntoId).toList();
}
}