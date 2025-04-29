class Actividad {
  final int id;
  final String nombre;

  Actividad({required this.id, required this.nombre});

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}