import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/punto_turistico.dart';
class ApiService {
  final String baseUrl = 'https://tursd.onrender.com/api/v1'; // URL fija

  // Fetch Puntos Turísticos
  Future<List<PuntoTuristico>> fetchPuntosTuristicos() async {
    final response = await http.get(Uri.parse('$baseUrl/puntos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PuntoTuristico.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load puntos turísticos');
    }
  }

  // Fetch un Punto Turístico por ID
  Future<PuntoTuristico> fetchPuntoTuristicoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos/$id'));

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      return PuntoTuristico.fromJson(jsonData);
    } else {
      throw Exception('Error al cargar el punto turístico con ID: $id');
    }
  }

  // Fetch Locales Turísticos
  Future<List<LocalTuristico>> fetchLocalesTuristicos() async {
    final response = await http.get(Uri.parse('$baseUrl/locales'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => LocalTuristico.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los locales turísticos');
    }
  }

  // Fetch un Local Turístico por ID
  Future<LocalTuristico> fetchLocalTuristicoById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/locales/$id'));

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      return LocalTuristico.fromJson(jsonData);
    } else {
      throw Exception('Error al cargar el local turístico con ID: $id');
    }
  }

  // Fetch Parroquias
  Future<List<Parroquia>> fetchParroquias() async {
    final response = await http.get(Uri.parse('$baseUrl/parroquias'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Parroquia.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las parroquias');
    }
  }

  // Fetch Etiquetas
  Future<List<Etiqueta>> fetchEtiquetas() async {
    final response = await http.get(Uri.parse('$baseUrl/etiquetas'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Etiqueta.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las etiquetas');
    }
  }

  // Fetch Puntos Turísticos por Parroquia
  Future<List<PuntoTuristico>> fetchPuntosByParroquia(int parroquiaId) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos?id_parroquia=$parroquiaId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => PuntoTuristico.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los puntos turísticos de la parroquia');
    }
  }

  // Fetch Puntos Turísticos por Etiqueta
  Future<List<PuntoTuristico>> fetchPuntosByEtiqueta(int etiquetaId) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos?id_etiqueta=$etiquetaId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => PuntoTuristico.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los puntos turísticos con esta etiqueta');
    }
  }

  // Fetch Actividades de un Punto Turístico
  Future<List<Actividad>> fetchActividadesByPunto(int puntoId) async {
    final response = await http.get(Uri.parse('$baseUrl/actividades?id_punto_turistico=$puntoId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Actividad.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las actividades del punto turístico');
    }
  }

  // Búsqueda de Puntos Turísticos por texto
  Future<List<PuntoTuristico>> searchPuntosTuristicos(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/puntos?q=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => PuntoTuristico.fromJson(item)).toList();
    } else {
      throw Exception('Error en la búsqueda de puntos turísticos');
    }
  }
}