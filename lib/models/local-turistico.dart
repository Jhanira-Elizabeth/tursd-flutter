class LocalTuristico {
  final int id;
  final String nombre;

  LocalTuristico({required this.id, required this.nombre});

  factory LocalTuristico.fromJson(Map<String, dynamic> json) {
    return LocalTuristico(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}