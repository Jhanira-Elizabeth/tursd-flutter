import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/punto_turistico.dart'; // Importación correcta

class ApiService {
  final String baseUrl = 'https://tursd-grhzehh6hta4e9en.eastus-01.azurewebsites.net/api/v1'; // URL de tu API

  // Función genérica para manejar la respuesta de la API para un solo objeto
  Future<T> _handleResponse<T>(http.Response response, T Function(dynamic) fromJson) {
    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      return Future.value(fromJson(jsonData));
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

  // Función genérica para manejar la respuesta de la API para una lista de objetos
  Future<List<T>> _handleListResponse<T>(http.Response response, T Function(dynamic) fromJsonList) {
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return Future.value(data.map((json) => fromJsonList(json)).toList());
    } else {
      throw Exception('Error al cargar la lista de datos: ${response.statusCode}');
    }
  }

  // 1. Puntos Turísticos
  Future<List<PuntoTuristico>> fetchPuntosTuristicos() async {
    final response = await http.get(Uri.parse('$baseUrl/puntos'));
    return _handleListResponse(response, (json) => PuntoTuristico.fromJson(json));
  }

  Future<PuntoTuristico> fetchPuntoTuristicoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos/$id'));
    return _handleResponse(response, (json) => PuntoTuristico.fromJson(json));
  }

  Future<List<PuntoTuristico>> fetchPuntosByParroquia(int parroquiaId) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos?id_parroquia=$parroquiaId'));
    return _handleListResponse(response, (json) => PuntoTuristico.fromJson(json));
  }

  Future<List<PuntoTuristico>> fetchPuntosByEtiqueta(int etiquetaId) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos?id_etiqueta=$etiquetaId'));
    return _handleListResponse(response, (json) => PuntoTuristico.fromJson(json));
  }

  Future<List<PuntoTuristico>> searchPuntosTuristicos(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos?q=$query'));
    return _handleListResponse(response, (json) => PuntoTuristico.fromJson(json));
  }

  Future<List<Actividad>> fetchActividadesByPunto(int puntoId) async {
    final response = await http.get(Uri.parse('$baseUrl/actividades?id_punto_turistico=$puntoId'));
    return _handleListResponse(response, (json) => Actividad.fromJson(json));
  }

  // 2. Locales Turísticos
  Future<List<LocalTuristico>> fetchLocalesTuristicos() async {
    final response = await http.get(Uri.parse('$baseUrl/locales'));
    return _handleListResponse(response, (json) => LocalTuristico.fromJson(json));
  }

  Future<LocalTuristico> fetchLocalTuristicoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/locales/$id'));
    return _handleResponse(response, (json) => LocalTuristico.fromJson(json));
  }

  // 3. Parroquias
  Future<List<Parroquia>> fetchParroquias() async {
    final response = await http.get(Uri.parse('$baseUrl/parroquias'));
    return _handleListResponse(response, (json) => Parroquia.fromJson(json));
  }

  // 4. Etiquetas
  Future<List<Etiqueta>> fetchEtiquetas() async {
    final response = await http.get(Uri.parse('$baseUrl/etiquetas'));
    return _handleListResponse(response, (json) => Etiqueta.fromJson(json));
  }

  // 5. Local-Etiqueta (Relaciones entre locales y etiquetas)
  // Devuelve una lista de mapas, donde cada mapa tiene 'id_local' e 'id_etiqueta'
  Future<List<Map<String, dynamic>>> fetchLocalEtiquetas() async {
    final response = await http.get(Uri.parse('$baseUrl/local-etiqueta'));
    if (response.statusCode == 200) {
      return Future.value((json.decode(response.body) as List).cast<Map<String, dynamic>>());
    } else {
      throw Exception('Error al cargar las relaciones local-etiqueta');
    }
  }

  // 6. Servicios
  Future<List<Servicio>> fetchServicios() async {
    final response = await http.get(Uri.parse('$baseUrl/servicios'));
    return _handleListResponse(response, (json) => Servicio.fromJson(json));
  }

  Future<List<Servicio>> fetchServiciosByLocal(int localId) async {
    final response = await http.get(Uri.parse('$baseUrl/servicios?id_local=$localId'));
    return _handleListResponse(response, (json) => Servicio.fromJson(json));
  }

  // 7. Horarios
  Future<List<HorarioAtencion>> fetchHorarios() async {
    final response = await http.get(Uri.parse('$baseUrl/horarios'));
    return _handleListResponse(response, (json) => HorarioAtencion.fromJson(json));
  }

  Future<List<HorarioAtencion>> fetchHorariosByLocal(int localId) async {
    final response = await http.get(Uri.parse('$baseUrl/horarios?id_local=$localId'));
    return _handleListResponse(response, (json) => HorarioAtencion.fromJson(json));
  }
}