class PuntoTuristico {
  final int id;
  final String nombre;
  final String descripcion;
  final int idParroquia;
  final String estado;
  final double latitud; // Añadido para mapas
  final double longitud; // Añadido para mapas
  final String? imagenUrl;
  final String? creadoPor;
  final String? editadoPor;
  final DateTime? fechaCreacion;
  final DateTime? fechaUltimaEdicion;
  final List<Actividad> actividades;
  List<Etiqueta> etiquetas;
  final Parroquia? parroquia;
  final bool esRecomendado;

  PuntoTuristico({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.idParroquia,
    required this.estado,
    required this.latitud,
    required this.longitud,
    this.etiquetas = const [],
    this.imagenUrl,
    this.creadoPor,
    this.editadoPor,
    this.fechaCreacion,
    this.fechaUltimaEdicion,
    this.actividades = const [],
    this.parroquia,
    required this.esRecomendado,
  });

  factory PuntoTuristico.fromJson(Map<String, dynamic> json) {
    List<Actividad> actividades = [];
    if (json['actividades'] != null) {
      actividades = (json['actividades'] as List)
          .map((actividad) => Actividad.fromJson(actividad))
          .toList();
    }

    List<Etiqueta> etiquetas = [];
    if (json['etiquetas'] != null) {
      etiquetas = (json['etiquetas'] as List)
          .map((etiqueta) => Etiqueta.fromJson(etiqueta))
          .toList();
    }

    Parroquia? parroquia;
    if (json['parroquia'] != null) {
      parroquia = Parroquia.fromJson(json['parroquia']);
    }

    String? assetPath; // Ahora puede ser null
    final String? rawImageUrl = json['imagenUrl'] ?? json['imagen_url'];

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      // Si la URL ya empieza con 'assets/', la usamos directamente.
      // De lo contrario, asumimos que es solo el nombre del archivo y construimos la ruta completa.
      if (rawImageUrl.startsWith('assets/')) {
        assetPath = rawImageUrl;
      } else {
        assetPath = 'assets/images/$rawImageUrl';
      }
    }
    // *** ELIMINADO: No hay bloque else aquí. Si rawImageUrl es null o vacío, assetPath se queda como null. ***

    return PuntoTuristico(
      id: json['id'] ?? json['punto_turistico_id'] ?? 0,
      nombre: json['nombre'] ?? json['nombre_punto_turistico'] ?? '',
      descripcion: json['descripcion'] ?? json['descripcion_punto_turistico'] ?? '',
      idParroquia: json['idParroquia'] ?? json['id_parroquia'] ?? 0,
      estado: json['estado'] ?? json['estado_punto_turistico'] ?? 'activo',
      latitud: (json['latitud'] != null)
          ? double.parse(json['latitud'].toString())
          : 0.0,
      longitud: (json['longitud'] != null)
          ? double.parse(json['longitud'].toString())
          : 0.0,
      imagenUrl: assetPath, // Ahora será la ruta completa o null
      creadoPor: json['creadoPor'] ?? json['creado_por'] ?? json['punto_turistico_creado_por'],
      editadoPor: json['editadoPor'] ?? json['editado_por'] ?? json['punto_turistico_editado_por'],
      fechaCreacion: (json['fechaCreacion'] != null && json['fechaCreacion'] is String)
          ? DateTime.parse(json['fechaCreacion'])
          : null,
      fechaUltimaEdicion: (json['fechaUltimaEdicion'] != null && json['fechaUltimaEdicion'] is String)
          ? DateTime.parse(json['fechaUltimaEdicion'])
          : null,
      actividades: actividades,
      etiquetas: etiquetas,
      parroquia: parroquia,
      esRecomendado: json['esRecomendado'] ?? false,
    );
  }

  // Método para convertir PuntoTuristico a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'idParroquia': idParroquia,
      'estado': estado,
      'latitud': latitud,
      'longitud': longitud,
      'imagenUrl': imagenUrl,
      'creadoPor': creadoPor,
      'editadoPor': editadoPor,
      'fechaCreacion': fechaCreacion?.toIso8601String(), // Convierte DateTime a String ISO 8601
      'fechaUltimaEdicion': fechaUltimaEdicion?.toIso8601String(), // Convierte DateTime a String ISO 8601
      // Mapea listas de objetos anidados a sus Mapas correspondientes
      'actividades': actividades.map((a) => a.toMap()).toList(),
      'etiquetas': etiquetas.map((e) => e.toMap()).toList(),
      'parroquia': parroquia?.toMap(), // Mapea el objeto parroquia si no es nulo
      'esRecomendado': esRecomendado,
    };
  }
}

class Actividad {
  final int id;
  final String nombre;
  final int idPuntoTuristico;
  final double precio;
  final String estado;
  final String? creadoPor;
  final String? editadoPor;
  final DateTime? fechaCreacion;
  final DateTime? fechaUltimaEdicion;

  Actividad({
    required this.id,
    required this.nombre,
    required this.idPuntoTuristico,
    required this.precio,
    required this.estado,
    this.creadoPor,
    this.editadoPor,
    this.fechaCreacion,
    this.fechaUltimaEdicion,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'] ?? json['actividad_punto_turistico_id'] ?? 0,
      nombre: json['actividad'] ?? json['nombre_actividad'] ?? '',
      idPuntoTuristico: json['idPuntoTuristico'] ?? json['id_punto_turistico'] ?? json['apt_id_punto_turistico'] ?? 0,
      precio: (json['precio'] != null)
          ? double.parse(json['precio'].toString())
          : 0.0,
      estado: json['estado'] ?? json['estado_actividad'] ?? '',
      creadoPor: json['creadoPor'] ?? json['creado_por'] ?? json['actividad_creado_por'],
      editadoPor: json['editadoPor'] ?? json['editado_por'] ?? json['actividad_editado_por'],
      fechaCreacion: (json['fechaCreacion'] != null && json['fechaCreacion'] is String)
          ? DateTime.parse(json['fechaCreacion'])
          : null,
      fechaUltimaEdicion: (json['fechaUltimaEdicion'] != null && json['fechaUltimaEdicion'] is String)
          ? DateTime.parse(json['fechaUltimaEdicion'])
          : null,
    );
  }

  // Método para convertir Actividad a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'idPuntoTuristico': idPuntoTuristico,
      'precio': precio,
      'estado': estado,
      'creadoPor': creadoPor,
      'editadoPor': editadoPor,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaUltimaEdicion': fechaUltimaEdicion?.toIso8601String(),
    };
  }
}

class Etiqueta {
  final int id;
  final String nombre;
  final String descripcion;
  final String estado;

  Etiqueta({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
  });

  factory Etiqueta.fromJson(Map<String, dynamic> json) {
    return Etiqueta(
      id: json['id'] ?? json['etiqueta_turistica_id'] ?? 0,
      nombre: json['nombre'] ?? json['nombre_etiqueta_turistica'] ?? '',
      descripcion: json['descripcion'] ?? json['descripcion_etiqueta_turistica'] ?? '',
      estado: json['estado'] ?? json['estado_etiqueta_turistica'] ?? 'activo',
    );
  }

  // Método para convertir Etiqueta a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
    };
  }
}

class Parroquia {
  final int id;
  final String nombre;
  final String descripcion;
  final int poblacion;
  final double temperaturaPromedio;
  final String estado;
  final String? imagenUrl;

  Parroquia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.poblacion,
    required this.temperaturaPromedio,
    required this.estado,
    this.imagenUrl,
  });

  factory Parroquia.fromJson(Map<String, dynamic> json) {
    double temperatura = 0.0;
    if (json['temperaturaPromedio'] != null) {
      final tempString = json['temperaturaPromedio'].toString().replaceAll('°C', '');
      temperatura = double.tryParse(tempString) ?? 0.0;
    } else if (json['temperatura_promedio'] != null) {
      final tempString = json['temperatura_promedio'].toString().replaceAll('°C', '');
      temperatura = double.tryParse(tempString) ?? 0.0;
    }

    String? assetPath; // Ahora puede ser null
    final String? rawImageUrl = json['imagenUrl'] ?? json['imagen_url'];

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('assets/')) {
        assetPath = rawImageUrl;
      } else {
        assetPath = 'assets/images/$rawImageUrl';
      }
    }
    // *** ELIMINADO: No hay bloque else aquí. Si rawImageUrl es null o vacío, assetPath se queda como null. ***

    return Parroquia(
      id: json['id'] ?? json['parroquia_id'] ?? 0,
      nombre: json['nombre'] ?? json['nombre_parroquia'] ?? '',
      descripcion: json['descripcion'] ?? json['descripcion_parroquia'] ?? '',
      poblacion: (json['poblacion'] != null) ? int.parse(json['poblacion'].toString()) : 0,
      temperaturaPromedio: temperatura,
      estado: json['estado'] ?? json['estado_parroquia'] ?? 'activo',
      imagenUrl: assetPath, // Ahora será la ruta completa o null
    );
  }

  // Método para convertir Parroquia a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'poblacion': poblacion,
      'temperaturaPromedio': temperaturaPromedio,
      'estado': estado,
      'imagenUrl': imagenUrl,
    };
  }
}

class LocalTuristico {
  final int id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final double latitud;
  final double longitud;
  final String? telefono;
  final String? email;
  final String? sitioweb;
  final String estado;
  final List<HorarioAtencion> horarios;
  List<Etiqueta> etiquetas;
  final List<Servicio> servicios;
  final String? imagenUrl;

  LocalTuristico({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.telefono,
    this.email,
    this.sitioweb,
    required this.estado,
    this.horarios = const [],
    this.etiquetas = const [],
    this.servicios = const [],
    this.imagenUrl,
  });

  factory LocalTuristico.fromJson(Map<String, dynamic> json) {
    List<HorarioAtencion> horarios = [];
    if (json['horarios'] != null) {
      horarios = (json['horarios'] as List)
          .map((horario) => HorarioAtencion.fromJson(horario))
          .toList();
    }

    List<Etiqueta> etiquetas = [];
    if (json['etiquetas'] != null) {
      etiquetas = (json['etiquetas'] as List)
          .map((etiqueta) => Etiqueta.fromJson(etiqueta))
          .toList();
    }

    List<Servicio> servicios = [];
    if (json['servicios'] != null) {
      servicios = (json['servicios'] as List)
          .map((servicio) => Servicio.fromJson(servicio))
          .toList();
    }

    String? assetPath; // Ahora puede ser null
    final String? rawImageUrl = json['imagenUrl'] ?? json['imagen_url'];

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('assets/')) {
        assetPath = rawImageUrl;
      } else {
        assetPath = 'assets/images/$rawImageUrl';
      }
    }
    // *** ELIMINADO: No hay bloque else aquí. Si rawImageUrl es null o vacío, assetPath se queda como null. ***

    return LocalTuristico(
      id: json['id'] ?? json['local_turistico_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      direccion: json['direccion'] ?? '',
      latitud: (json['latitud'] != null)
          ? double.parse(json['latitud'].toString())
          : 0.0,
      longitud: (json['longitud'] != null)
          ? double.parse(json['longitud'].toString())
          : 0.0,
      telefono: json['telefono'],
      email: json['email'],
      sitioweb: json['sitioweb'],
      estado: json['estado'] ?? json['estado_parroquia'] ?? 'activo',
      imagenUrl: assetPath, // Ahora será la ruta completa o null
      horarios: horarios,
      etiquetas: etiquetas,
      servicios: servicios,
    );
  }

  // Método para convertir LocalTuristico a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'telefono': telefono,
      'email': email,
      'sitioweb': sitioweb,
      'estado': estado,
      'imagenUrl': imagenUrl,
      // Mapea listas de objetos anidados a sus Mapas correspondientes
      'horarios': horarios.map((h) => h.toMap()).toList(),
      'etiquetas': etiquetas.map((e) => e.toMap()).toList(),
      'servicios': servicios.map((s) => s.toMap()).toList(),
    };
  }
}

class HorarioAtencion {
  final int id;
  final String horaInicio;
  final String horaFin;
  final String diaSemana;
  final int idLocal;
  final String estado;

  HorarioAtencion({
    required this.id,
    required this.horaInicio,
    required this.horaFin,
    required this.diaSemana,
    required this.idLocal,
    required this.estado,
  });

  factory HorarioAtencion.fromJson(Map<String, dynamic> json) {
    return HorarioAtencion(
      id: json['id'] ?? json['horario_id'] ?? 0,
      horaInicio: json['horaInicio'] ?? json['hora_inicio'] ?? '',
      horaFin: json['horaFin'] ?? json['hora_fin'] ?? '',
      diaSemana: json['diaSemana'] ?? json['dia_semana'] ?? '',
      idLocal: json['idLocal'] ?? json['id_local'] ?? 0,
      estado: json['estado'] ?? json['estado_horario'] ?? 'activo',
    );
  }

  // Método para convertir HorarioAtencion a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'diaSemana': diaSemana,
      'idLocal': idLocal,
      'estado': estado,
    };
  }
}

class Servicio {
  final int id;
  final int idLocal;
  final String servicioNombre; // Renombrado para mayor claridad
  final double precio; // Cambiado a double para manejo numérico

  Servicio({
    required this.id,
    required this.idLocal,
    required this.servicioNombre,
    required this.precio, // Ahora es requerido
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    // Asegurarse de que 'precio' se parsee a double, incluso si es String
    final double parsedPrecio = (json['precio'] != null)
        ? double.tryParse(json['precio'].toString()) ?? 0.0
        : 0.0;

    return Servicio(
      id: json['id'] ?? json['servicio_local_id'] ?? 0,
      idLocal: json['id_local'] ?? 0, // Usamos 'id_local' directamente del JSON
      servicioNombre: json['servicio'] ?? '', // Mapeamos 'servicio' del JSON
      precio: parsedPrecio,
    );
  }

  // Método para convertir Servicio a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idLocal': idLocal,
      'servicioNombre': servicioNombre,
      'precio': precio,
    };
  }
}