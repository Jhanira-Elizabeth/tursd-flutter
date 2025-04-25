import 'dart:convert';
import 'package:http/http.dart' as http;
import 'punto_turistico.dart';
import 'categoria.dart';

class ApiService {
  final String baseUrl = "https://tursd.onrender.com/api/v1/puntos";
  final String categoriasUrl = "https://tursd.onrender.com/api/v1/categorias";  // URL para categorías

  Future<List<PuntoTuristico>> fetchPuntosTuristicos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => PuntoTuristico.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los puntos turísticos');
    }
  }

  Future<List<Categoria>> fetchCategorias() async {
    final response = await http.get(Uri.parse(categoriasUrl));  // Usa la URL correcta para categorías
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Categoria.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categorias');
    }
  }
}
