import 'dart:convert';
import 'package:http/http.dart' as http;
import 'punto_turistico.dart';
import 'categoria.dart';

class ApiService {
  final String baseUrl = "https://tursd.onrender.com/api/v1/puntos";

  Future<List<PuntoTuristico>> fetchPuntosTuristicos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => PuntoTuristico.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los puntos turísticos');
    }
  }
}
