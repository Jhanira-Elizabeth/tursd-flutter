class Etiqueta {
  final int id;
  final String nombre;

  Etiqueta({required this.id, required this.nombre});

  factory Etiqueta.fromJson(Map<String, dynamic> json) {
    return Etiqueta(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}