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
      actividades =
          (json['actividades'] as List)
              .map((actividad) => Actividad.fromJson(actividad))
              .toList();
    }

    List<Etiqueta> etiquetas = [];
    if (json['etiquetas'] != null) {
      etiquetas =
          (json['etiquetas'] as List)
              .map((etiqueta) => Etiqueta.fromJson(etiqueta))
              .toList();
    }

    Parroquia? parroquia;
    if (json['parroquia'] != null) {
      parroquia = Parroquia.fromJson(json['parroquia']);
    }

    String? assetPath;
    final String? rawImageUrl = json['imagen_url'] as String?; // Esto debería ser el nombre del archivo

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
        // Asegúrate de que no haya prefijos de URL real accidentalmente.
        // Si el valor es una URL COMPLETA, necesitas extraer solo el nombre del archivo.
        // Si es SOLO el nombre del archivo (ej. "Bomboli8.jpg"), esta es la forma.
        
        // Vamos a asumir que 'imagen_url' viene como el nombre del archivo (ej. "Bomboli8.jpg")
        assetPath = 'assets/images/$rawImageUrl';

        // SI POR ALGÚN CASO SIGUE VINIENDO UNA URL COMPLETA, usa esto:
        // try {
        //   Uri uri = Uri.parse(rawImageUrl);
        //   String fileName = uri.pathSegments.last;
        //   if (fileName.isNotEmpty) {
        //     assetPath = 'assets/images/$fileName';
        //   } else {
        //     assetPath = 'assets/images/default_placeholder.jpg'; // O un asset por defecto si no hay nombre
        //   }
        // } catch (e) {
        //   // No es una URL válida, tratar como un simple nombre de archivo o default
        //   assetPath = 'assets/images/$rawImageUrl';
        //   // Si no funciona, usa default
        //   if (assetPath == 'assets/images/') assetPath = 'assets/images/default_placeholder.jpg';
        // }

    } else {
      assetPath = 'assets/images/default_placeholder.jpg'; // Imagen por defecto si no hay imagen en la API
    }


    return PuntoTuristico(
      id: json['id'] ?? json['punto_turistico_id'],
      nombre: json['nombre'] ?? json['nombre_punto_turistico'],
      descripcion:
          json['descripcion'] ?? json['descripcion_punto_turistico'] ?? '',
      idParroquia: json['id_parroquia'] ?? 0,
      estado: json['estado'] ?? json['estado_punto_turistico'] ?? 'activo',
      latitud:
          json['latitud'] != null
              ? double.parse(json['latitud'].toString())
              : 0.0,
      longitud:
          json['longitud'] != null
              ? double.parse(json['longitud'].toString())
              : 0.0,
      imagenUrl: assetPath,
      creadoPor: json['creado_por'] ?? json['punto_turistico_creado_por'],
      editadoPor: json['editado_por'] ?? json['punto_turistico_editado_por'],
      fechaCreacion:
          json['fecha_creacion'] != null
              ? DateTime.parse(json['fecha_creacion'])
              : null,
      fechaUltimaEdicion:
          json['fecha_ultima_edicion'] != null
              ? DateTime.parse(json['fecha_ultima_edicion'])
              : null,
      actividades: actividades,
      etiquetas: etiquetas,
      parroquia: parroquia,
      esRecomendado: json['esRecomendado'] ?? false,
    );
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
      idPuntoTuristico:
          json['id_punto_turistico'] ?? json['apt_id_punto_turistico'] ?? 0,
      precio:
          json['precio'] != null
              ? double.parse(json['precio'].toString())
              : 0.0,
      estado: json['estado'] ?? json['estado_actividad'] ?? '',
      creadoPor: json['creado_por'] ?? json['actividad_creado_por'],
      editadoPor: json['editado_por'] ?? json['actividad_editado_por'],
      fechaCreacion:
          json['fecha_creacion'] != null
              ? DateTime.parse(json['fecha_creacion'])
              : null,
      fechaUltimaEdicion:
          json['fecha_ultima_edicion'] != null
              ? DateTime.parse(json['fecha_ultima_edicion'])
              : null,
    );
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
      descripcion:
          json['descripcion'] ?? json['descripcion_etiqueta_turistica'] ?? '',
      estado: json['estado'] ?? json['estado_etiqueta_turistica'] ?? 'activo',
    );
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
    if (json['temperatura_promedio'] != null) {
      final tempString = json['temperatura_promedio'].toString().replaceAll(
        '°C',
        '',
      );
      temperatura =
          double.tryParse(tempString) ??
          0.0; // Intenta parsear, si falla usa 0.0
    }

    String? assetPath;
    final String? rawImageUrl = json['imagen_url'] as String?; // Esto debería ser el nombre del archivo

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
        assetPath = 'assets/images/$rawImageUrl';
    } else {
      assetPath = 'assets/images/default_placeholder.jpg'; // O un asset por defecto
    }

    return Parroquia(
      id: json['id'] ?? json['parroquia_id'] ?? 0,
      nombre: json['nombre'] ?? json['nombre_parroquia'] ?? '',
      descripcion: json['descripcion'] ?? json['descripcion_parroquia'] ?? '',
      poblacion: json['poblacion'] != null ? int.parse(json['poblacion'].toString()) : 0,
      temperaturaPromedio: temperatura,
      estado: json['estado'] ?? json['estado_parroquia'] ?? 'activo',
      imagenUrl: assetPath,
    );
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
      horarios =
          (json['horarios'] as List)
              .map((horario) => HorarioAtencion.fromJson(horario))
              .toList();
    }

    List<Etiqueta> etiquetas = [];
    if (json['etiquetas'] != null) {
      etiquetas =
          (json['etiquetas'] as List)
              .map((etiqueta) => Etiqueta.fromJson(etiqueta))
              .toList();
    }

    List<Servicio> servicios = [];
    if (json['servicios'] != null) {
      servicios =
          (json['servicios'] as List)
              .map((servicio) => Servicio.fromJson(servicio))
              .toList();
    }

    String? assetPath;
    final String? rawImageUrl = json['imagen_url'] as String?; // Esto debería ser el nombre del archivo

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
        assetPath = 'assets/images/$rawImageUrl';
    } else {
      assetPath = 'assets/images/default_placeholder.jpg'; // O un asset por defecto
    }

    return LocalTuristico(
      id: json['id'] ?? json['local_turistico_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      direccion: json['direccion'] ?? '',
      latitud:
          json['latitud'] != null
              ? double.parse(json['latitud'].toString())
              : 0.0,
      longitud:
          json['longitud'] != null
              ? double.parse(json['longitud'].toString())
              : 0.0,
      telefono: json['telefono'],
      email: json['email'],
      sitioweb: json['sitioweb'],
      estado: json['estado'] ?? json['estado_parroquia'] ?? 'activo',
      imagenUrl: assetPath,
      horarios: horarios,
      etiquetas: etiquetas,
      servicios: servicios,
    );
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
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      diaSemana: json['dia_semana'] ?? '',
      idLocal: json['id_local'] ?? 0,
      estado: json['estado'] ?? json['estado_horario'] ?? 'activo',
    );
  }
}

class Servicio {
  final int id;
  final int idLocal;
  final String servicio;

  Servicio({required this.id, required this.idLocal, required this.servicio});

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'] ?? json['servicio_local_id'] ?? 0,
      idLocal: json['id_local'] ?? 0,
      servicio: json['servicio'] ?? '',
    );
  }
}
