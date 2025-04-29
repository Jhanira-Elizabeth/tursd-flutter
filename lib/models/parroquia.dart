class Parroquia {
  final int id;
  final String nombre;

  Parroquia({required this.id, required this.nombre});

  factory Parroquia.fromJson(Map<String, dynamic> json) {
    return Parroquia(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}