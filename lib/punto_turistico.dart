class PuntoTuristico {
  final int id;
  final String nombre;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String? imagenUrl;  // Opcional, si tu API proporciona URLs de imágenes

  PuntoTuristico({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    this.imagenUrl,
  });

  factory PuntoTuristico.fromJson(Map<String, dynamic> json) {
    return PuntoTuristico(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      latitud: double.parse(json['latitud']),
      longitud: double.parse(json['longitud']),
      imagenUrl: json['imagen_url'],  // Si está disponible en tu API
    );
  }
}