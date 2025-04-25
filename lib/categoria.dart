class Categoria {
  final String nombre;
  final String descripcion;

  Categoria({required this.nombre, required this.descripcion});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }
}
