# --- Utilidad para quitar tildes ---
# --- 1. Importaciones ---
import os
import sys
import subprocess
try:
    import googleapiclient.discovery
    import googleapiclient.errors
    import google.auth.transport.requests
    from google.oauth2.credentials import Credentials
except ImportError:
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'google-api-python-client', 'google-auth'])
    import googleapiclient.discovery
    import googleapiclient.errors
    import google.auth.transport.requests
    from google.oauth2.credentials import Credentials
import psycopg2
import unicodedata
import traceback
from flask import Flask, request, jsonify
from dotenv import load_dotenv
from datetime import datetime, timedelta
import re

# --- 2. Cargar Variables de Entorno desde .env ---
load_dotenv()

# --- 3. Configuración de Variables Globales para Conexiones ---
conn = None

# --- 4. Función para Inicializar Conexión a la base de datos ---
def initialize_connections():
    global conn
    # Conexión a PostgreSQL
    try:
        db_host = os.getenv("DB_HOST")
        db_port = os.getenv("DB_PORT")
        db_name = os.getenv("DB_NAME")
        db_user = os.getenv("DB_USER")
        db_pass = os.getenv("DB_PASS")

        if all([db_host, db_port, db_name, db_user, db_pass]):
            DATABASE_URL = f"postgresql://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}?sslmode=require"
            print(f"DEBUG: Construyendo DATABASE_URL: {DATABASE_URL}")
            conn = psycopg2.connect(DATABASE_URL)
            conn.autocommit = True
            print("Conexión a PostgreSQL establecida correctamente.")
        else:
            print("Faltan variables de entorno para PostgreSQL (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS). Conexión no establecida.")
            conn = None
    except Exception as e:
        print(f"ERROR: Fallo al conectar a PostgreSQL: {e}")
        traceback.print_exc()
        conn = None

# --- Llama a la función de inicialización al inicio ---
initialize_connections()

# Inicializar Flask
app = Flask(__name__)

# --- Función para truncar descripción ---
def truncar_descripcion(descripcion, max_palabras=10):
    """Trunca la descripción a un máximo de palabras y agrega '...' si es necesario"""
    if not descripcion:
        return ""
    
    palabras = descripcion.split()
    if len(palabras) <= max_palabras:
        return descripcion
    
    return " ".join(palabras[:max_palabras]) + "..."

def quitar_tildes(texto):
    if not isinstance(texto, str):
        return texto
    return ''.join(
        c for c in unicodedata.normalize('NFD', texto)
        if unicodedata.category(c) != 'Mn'
    )

# --- Nueva función para verificar si un lugar es un local turístico ---
def es_local_turistico(nombre_lugar):
    """Verifica si el lugar especificado es un local turístico o un punto turístico"""
    print(f"[DEBUG] Verificando tipo de lugar para: {nombre_lugar}")
    if conn is None:
        print("[DEBUG] Conexion a DB no establecida (conn is None)")
        return False
    
    try:
        with conn.cursor() as cur:
            # Buscar en locales_turisticos
            query_locales = '''
                SELECT COUNT(*)
                FROM locales_turisticos lt
                WHERE LOWER(lt.nombre) = LOWER(%s) AND lt.estado = 'activo'
            '''
            cur.execute(query_locales, (nombre_lugar,))
            count_local = cur.fetchone()[0]
            
            return count_local > 0
            
    except Exception as e:
        print(f"ERROR: Fallo al verificar tipo de lugar: {e}")
        traceback.print_exc()
        return False

# --- Función para obtener horarios de un local ---
def obtener_horarios_local(nombre_local):
    """Obtiene los horarios de atención de un local turístico"""
    print(f"[DEBUG] Buscando horarios para: {nombre_local}")
    if conn is None:
        print("[DEBUG] Conexion a DB no establecida (conn is None)")
        return None
    
    try:
        with conn.cursor() as cur:
            query_horarios = '''
                SELECT ha.dia_semana, ha.hora_inicio, ha.hora_fin
                FROM horarios_atencion ha
                LEFT JOIN locales_turisticos lt ON ha.id_local = lt.id
                WHERE LOWER(lt.nombre) = LOWER(%s) AND lt.estado = 'activo' AND ha.estado = 'activo'
                ORDER BY 
                    CASE ha.dia_semana
                        WHEN 'Lunes' THEN 1
                        WHEN 'Martes' THEN 2
                        WHEN 'Miércoles' THEN 3
                        WHEN 'Jueves' THEN 4
                        WHEN 'Viernes' THEN 5
                        WHEN 'Sábado' THEN 6
                        WHEN 'Domingo' THEN 7
                        ELSE 8
                    END;
            '''
            cur.execute(query_horarios, (nombre_local,))
            horarios = cur.fetchall()
            
            return horarios
            
    except Exception as e:
        print(f"ERROR: Fallo al obtener horarios del local: {e}")
        traceback.print_exc()
        return None

# --- Función para obtener servicios de un local ---
def obtener_servicios_local(nombre_local):
    """Obtiene los servicios ofrecidos por un local turístico"""
    print(f"[DEBUG] Buscando servicios para: {nombre_local}")
    if conn is None:
        print("[DEBUG] Conexion a DB no establecida (conn is None)")
        return None
    
    try:
        with conn.cursor() as cur:
            query_servicios = '''
                SELECT sl.servicio
                FROM servicios_locales sl
                LEFT JOIN locales_turisticos lt ON sl.id_local = lt.id
                WHERE LOWER(lt.nombre) = LOWER(%s) AND lt.estado = 'activo'
                ORDER BY sl.servicio;
            '''
            cur.execute(query_servicios, (nombre_local,))
            servicios = cur.fetchall()
            
            return servicios
            
    except Exception as e:
        print(f"ERROR: Fallo al obtener servicios del local: {e}")
        traceback.print_exc()
        return None

# --- Función para obtener actividades de un punto turístico ---
def obtener_actividades_punto(nombre_punto):
    """Obtiene las actividades disponibles en un punto turístico"""
    print(f"[DEBUG] Buscando actividades para: {nombre_punto}")
    if conn is None:
        print("[DEBUG] Conexion a DB no establecida (conn is None)")
        return None
    
    try:
        with conn.cursor() as cur:
            query_actividades = '''
                SELECT apt.actividad, apt.precio
                FROM actividad_punto_turistico apt
                LEFT JOIN puntos_turisticos pt ON apt.id_punto_turistico = pt.id
                WHERE LOWER(pt.nombre) = LOWER(%s) AND pt.estado = 'activo' AND apt.estado = 'activo'
                ORDER BY apt.actividad;
            '''
            cur.execute(query_actividades, (nombre_punto,))
            actividades = cur.fetchall()
            
            return actividades
            
    except Exception as e:
        print(f"ERROR: Fallo al obtener actividades del punto turístico: {e}")
        traceback.print_exc()
        return None

# --- Funciones para el agendamiento de visitas ---

def obtener_dias_disponibles(nombre_lugar):
    """Obtiene los días que está abierto un local turístico"""
    print(f"[DEBUG] Obteniendo días disponibles para: {nombre_lugar}")
    if conn is None:
        print("[DEBUG] Conexion a DB no establecida (conn is None)")
        return None
    
    try:
        with conn.cursor() as cur:
            query_dias = '''
                SELECT ha.dia_semana, ha.hora_inicio, ha.hora_fin
                FROM horarios_atencion ha
                LEFT JOIN locales_turisticos lt ON ha.id_local = lt.id
                WHERE LOWER(lt.nombre) = LOWER(%s) AND lt.estado = 'activo' AND ha.estado = 'activo'
                GROUP BY ha.dia_semana, ha.hora_inicio, ha.hora_fin
                ORDER BY 
                    CASE ha.dia_semana
                        WHEN 'Lunes' THEN 1
                        WHEN 'Martes' THEN 2
                        WHEN 'Miércoles' THEN 3
                        WHEN 'Jueves' THEN 4
                        WHEN 'Viernes' THEN 5
                        WHEN 'Sábado' THEN 6
                        WHEN 'Domingo' THEN 7
                        ELSE 8
                    END
            '''
            cur.execute(query_dias, (nombre_lugar,))
            dias_horarios = cur.fetchall()
            return dias_horarios
    except Exception as e:
        print(f"ERROR: Fallo al obtener días disponibles: {e}")
        traceback.print_exc()
        return None

def validar_dia_disponible(nombre_lugar, dia_semana):
    """Valida si un día específico está disponible para visita"""
    print(f"[DEBUG] Validando día {dia_semana} para: {nombre_lugar}")
    dias_disponibles = obtener_dias_disponibles(nombre_lugar)
    
    if not dias_disponibles:
        return False, None, None
    
    for dia, hora_inicio, hora_fin in dias_disponibles:
        if dia.lower() == dia_semana.lower():
            return True, hora_inicio, hora_fin
    
    return False, None, None

def obtener_dia_semana_espanol(fecha_str):
    """Convierte una fecha en formato DD/MM/YYYY al día de la semana en español"""
    try:
        fecha = datetime.strptime(fecha_str, "%d/%m/%Y")
        dias_semana = {
            0: "Lunes",
            1: "Martes", 
            2: "Miércoles",
            3: "Jueves",
            4: "Viernes",
            5: "Sábado",
            6: "Domingo"
        }
        return dias_semana[fecha.weekday()]
    except:
        return None

def calcular_tiempo_viaje(distancia_km):
    """Calcula el tiempo estimado de viaje basado en la distancia"""
    # Velocidad promedio urbana: 30 km/h, carretera: 60 km/h
    if distancia_km <= 10:
        velocidad_promedio = 30  # km/h para trayectos urbanos
    else:
        velocidad_promedio = 50  # km/h para trayectos más largos
    
    tiempo_horas = distancia_km / velocidad_promedio
    tiempo_minutos = int(tiempo_horas * 60)
    
    return tiempo_minutos

def calcular_hora_llegada(hora_salida_str, tiempo_viaje_minutos):
    """Calcula la hora estimada de llegada"""
    try:
        hora_salida = datetime.strptime(hora_salida_str, "%H:%M")
        hora_llegada = hora_salida + timedelta(minutes=tiempo_viaje_minutos)
        return hora_llegada.strftime("%H:%M")
    except:
        return None

def obtener_distancia_lugar(nombre_lugar, lat_usuario, lon_usuario):
    """Obtiene la distancia desde la ubicación del usuario hasta el lugar"""
    print(f"[DEBUG] Calculando distancia a {nombre_lugar} desde ({lat_usuario}, {lon_usuario})")
    if conn is None:
        return None
    
    try:
        with conn.cursor() as cur:
            # Buscar primero en locales_turisticos
            query_local = '''
                SELECT lt.latitud, lt.longitud,
                       6371 * acos(
                           cos(radians(%s)) * cos(radians(lt.latitud)) * 
                           cos(radians(lt.longitud) - radians(%s)) +
                           sin(radians(%s)) * sin(radians(lt.latitud))
                       ) AS distance_km
                FROM locales_turisticos lt
                WHERE LOWER(lt.nombre) = LOWER(%s) AND lt.estado = 'activo'
                LIMIT 1;
            '''
            cur.execute(query_local, (lat_usuario, lon_usuario, lat_usuario, nombre_lugar))
            resultado = cur.fetchone()
            
            if resultado:
                return resultado[2]  # distancia en km
            
            # Si no es local, buscar en puntos_turisticos
            query_punto = '''
                SELECT pt.latitud, pt.longitud,
                       6371 * acos(
                           cos(radians(%s)) * cos(radians(pt.latitud)) * 
                           cos(radians(pt.longitud) - radians(%s)) +
                           sin(radians(%s)) * sin(radians(pt.latitud))
                       ) AS distance_km
                FROM puntos_turisticos pt
                WHERE LOWER(pt.nombre) = LOWER(%s) AND pt.estado = 'activo'
                LIMIT 1;
            '''
            cur.execute(query_punto, (lat_usuario, lon_usuario, lat_usuario, nombre_lugar))
            resultado = cur.fetchone()
            
            if resultado:
                return resultado[2]  # distancia en km
            
            return None
            
    except Exception as e:
        print(f"ERROR: Fallo al calcular distancia: {e}")
        traceback.print_exc()
        return None

# --- Función para obtener ubicación de un lugar específico ---
def obtener_ubicacion_lugar(nombre_lugar):
    print(f"[DEBUG] Buscando ubicación para: {nombre_lugar}")
    if conn is None:
        print("[DEBUG] Conexion a DB no establecida (conn is None)")
        return None
    
    try:
        with conn.cursor() as cur:
            # Buscar en locales_turisticos
            query_locales = '''
                SELECT lt.nombre, lt.descripcion, p.nombre AS parroquia, lt.latitud, lt.longitud
                FROM locales_turisticos lt
                LEFT JOIN parroquias p ON lt.id_parroquia = p.id
                WHERE LOWER(lt.nombre) = LOWER(%s) AND lt.estado = 'activo'
                LIMIT 1;
            '''
            cur.execute(query_locales, (nombre_lugar,))
            resultado = cur.fetchone()
            
            if resultado:
                return {
                    'nombre': resultado[0],
                    'descripcion': resultado[1],
                    'parroquia': resultado[2],
                    'latitud': resultado[3],
                    'longitud': resultado[4]
                }
            
            # Si no se encuentra en locales, buscar en puntos_turisticos
            query_puntos = '''
                SELECT pt.nombre, pt.descripcion, p.nombre AS parroquia, pt.latitud, pt.longitud
                FROM puntos_turisticos pt
                LEFT JOIN parroquias p ON pt.id_parroquia = p.id
                WHERE LOWER(pt.nombre) = LOWER(%s) AND pt.estado = 'activo'
                LIMIT 1;
            '''
            cur.execute(query_puntos, (nombre_lugar,))
            resultado = cur.fetchone()
            
            if resultado:
                return {
                    'nombre': resultado[0],
                    'descripcion': resultado[1],
                    'parroquia': resultado[2],
                    'latitud': resultado[3],
                    'longitud': resultado[4]
                }
            
            return None
            
    except Exception as e:
        print(f"ERROR: Fallo al obtener ubicación del lugar: {e}")
        traceback.print_exc()
        return None

# --- Funciones principales ---

def obtener_lugares_cercanos(lat, lon, radio_km=30):
    print("[DEBUG] obtener_lugares_cercanos llamada con:")
    print(f"  lat: {lat}, lon: {lon}, radio_km: {radio_km}")
    if conn is None:
        print("[DEBUG] Conexion a DB no establecida (conn is None)")
        return "No se pudo cargar la información de lugares cercanos (conexión DB no establecida)."
    contexto_cercanos = []
    MAX_LUGARES = 10
    try:
        with conn.cursor() as cur:
            # Locales turísticos
            query_locales = '''
                SELECT
                    lt.nombre AS nombre_local, lt.descripcion AS descripcion_local,
                    p.nombre AS nombre_parroquia,
                    STRING_AGG(DISTINCT sl.servicio, ', ') AS servicios_ofrecidos,
                    6371 * acos(
                        cos(radians(%s)) * cos(radians(lt.latitud)) * cos(radians(lt.longitud) - radians(%s)) +
                        sin(radians(%s)) * sin(radians(lt.latitud))
                    ) AS distance_km,
                    lt.latitud, lt.longitud
                FROM locales_turisticos lt
                LEFT JOIN parroquias p ON lt.id_parroquia = p.id
                LEFT JOIN servicios_locales sl ON lt.id = sl.id_local
                WHERE lt.latitud IS NOT NULL AND lt.longitud IS NOT NULL AND lt.estado = 'true'
                GROUP BY lt.id, lt.nombre, lt.descripcion, p.nombre, lt.latitud, lt.longitud
                HAVING 6371 * acos(
                    cos(radians(%s)) * cos(radians(lt.latitud)) * cos(radians(lt.longitud) - radians(%s)) +
                    sin(radians(%s)) * sin(radians(lt.latitud))
                ) < %s
                ORDER BY distance_km
                LIMIT 10;
            '''
            params_locales = (lat, lon, lat, lat, lon, lat, radio_km)
            cur.execute(query_locales, params_locales)
            filas_locales = cur.fetchall()
            for fila in filas_locales:
                servicios_str = fila[3] if fila[3] else 'No especificados'
                contexto_cercanos.append(
                    f"- Local Cercano: {fila[0]} (Lat: {fila[5]}, Lon: {fila[6]})\n"
                    f"  Descripción: {fila[1]}\n"
                    f"  Parroquia: {fila[2]}\n"
                    f"  Servicios: {servicios_str}\n"
                    f"  Distancia: {fila[4]:.2f} km\n"
                )
            # Puntos turísticos
            query_puntos = '''
                SELECT
                    pt.nombre AS nombre_punto, pt.descripcion AS descripcion_punto,
                    p.nombre AS nombre_parroquia,
                    STRING_AGG(DISTINCT apt.actividad, ', ') AS actividades_disponibles,
                    6371 * acos(
                        cos(radians(%s)) * cos(radians(pt.latitud)) * cos(radians(pt.longitud) - radians(%s)) +
                        sin(radians(%s)) * sin(radians(pt.latitud))
                    ) AS distance_km,
                    pt.latitud, pt.longitud
                FROM puntos_turisticos pt
                LEFT JOIN parroquias p ON pt.id_parroquia = p.id
                LEFT JOIN actividad_punto_turistico apt ON pt.id = apt.id_punto_turistico
                WHERE pt.latitud IS NOT NULL AND pt.longitud IS NOT NULL AND pt.estado = 'true'
                GROUP BY pt.id, pt.nombre, pt.descripcion, p.nombre, pt.latitud, pt.longitud
                HAVING 6371 * acos(
                    cos(radians(%s)) * cos(radians(pt.latitud)) * cos(radians(pt.longitud) - radians(%s)) +
                    sin(radians(%s)) * sin(radians(pt.latitud))
                ) < %s
                ORDER BY distance_km
                LIMIT 10;
            '''
            params_puntos = (lat, lon, lat, lat, lon, lat, radio_km)
            cur.execute(query_puntos, params_puntos)
            filas_puntos = cur.fetchall()
            for fila in filas_puntos:
                actividades_str = fila[3] if fila[3] else 'No especificadas'
                contexto_cercanos.append(
                    f"- Punto Turístico Cercano: {fila[0]} (Lat: {fila[5]}, Lon: {fila[6]})\n"
                    f"  Descripción: {fila[1]}\n"
                    f"  Parroquia: {fila[2]}\n"
                    f"  Actividades: {actividades_str}\n"
                    f"  Distancia: {fila[4]:.2f} km\n"
                )
    except Exception as e:
        print(f"ERROR: Fallo al obtener lugares cercanos: {e}")
        traceback.print_exc()
        return "No se pudo cargar la información de lugares cercanos."
    return "\n".join(contexto_cercanos) if contexto_cercanos else "No se encontraron lugares o puntos turísticos cercanos con las coordenadas proporcionadas."

# --- Rutas de la API ---

@app.route("/")
def home():
    return "¡Bienvenido al asistente turístico de Ecuador! El servicio de chatbot está disponible en /chat."

@app.route("/chat", methods=["POST"])
def chat():
    MENU_OPCIONES = [
        "Étnia Tsáchila",
        "Alojamientos",
        "Parques",
        "Rios",
        "Atracciones Estables",
        "Alimentos",
        "Balnearios"
    ]
    if conn is None:
        return jsonify({"response": "Lo siento, el servicio de base de datos no está disponible en este momento."}), 503
    
    try:
        data = request.json
        print(f"[DEBUG] Datos recibidos: {data}")  # Debug para ver qué llega
        

        chat_id = data.get("chat_id")
        seleccion = data.get("seleccion")
        lugar_seleccionado = data.get("lugar_seleccionado")
        proceso_agendamiento = data.get("proceso_agendamiento")
        fecha_visita = data.get("fecha_visita")
        hora_salida = data.get("hora_salida")
        lat_usuario = data.get("lat_usuario")
        lon_usuario = data.get("lon_usuario")
        google_access_token = data.get("google_access_token")

        print(f"[DEBUG] proceso_agendamiento: {proceso_agendamiento}")
        print(f"[DEBUG] seleccion: {seleccion}")
        print(f"[DEBUG] lugar_seleccionado: {lugar_seleccionado}")
        
        # Si no hay selección, mostrar menú principal
        if not seleccion:
            saludo = "¡Hola viajero! ¿Qué te gustaría explorar en Santo Domingo de los Tsáchilas? Por favor elige una opción:"
            opciones = "\n".join([f"- {op}" for op in MENU_OPCIONES])
            return jsonify({
                "response": f"{saludo}\n\n{opciones}",
                "menu": MENU_OPCIONES
            })

        # Manejar solicitud de ubicación
        if seleccion == "Ver ubicación" or seleccion == "Ver ubicacion":
            if lugar_seleccionado:
                print(f"[DEBUG] Solicitando ubicación para: {lugar_seleccionado}")
                ubicacion_info = obtener_ubicacion_lugar(lugar_seleccionado)
                if ubicacion_info:
                    # Crear una búsqueda descriptiva para Google Maps sin coordenadas
                    direccion_completa = f"{ubicacion_info['nombre']}, Parroquia {ubicacion_info['parroquia']}, Santo Domingo de los Tsáchilas, Ecuador"
                    
                    # Determinar opciones de menú según el tipo de lugar
                    es_local = es_local_turistico(lugar_seleccionado)
                    if es_local:
                        opciones_menu = ["Agendar visita", "Ver horarios", "Ver servicios", "Volver al inicio"]
                    else:
                        opciones_menu = ["Agendar visita", "Ver actividades", "Volver al inicio"]
                    
                    return jsonify({
                        "response": f"📍 Ubicación de {ubicacion_info['nombre']}\n\n¿Te gustaría agendar una visita a este lugar?",
                        "ubicacion": {
                            "nombre": ubicacion_info['nombre'],
                            "parroquia": ubicacion_info['parroquia'],
                            "direccion": direccion_completa,
                            "latitud": ubicacion_info['latitud'],
                            "longitud": ubicacion_info['longitud']
                        },
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": opciones_menu
                    })
                else:
                    return jsonify({
                        "response": f"No se pudo encontrar la ubicación de {lugar_seleccionado}",
                        "menu": ["Volver al inicio"]
                    })
            else:
                return jsonify({
                    "response": "No se especificó qué lugar quieres ubicar.",
                    "menu": ["Volver al inicio"]
                })

        # === MANEJO DEL PROCESO DE AGENDAMIENTO ===
        
        # Iniciar proceso de agendamiento
        if seleccion == "Agendar visita":
            if lugar_seleccionado:
                # Verificar si es un local turístico (tiene horarios) o punto turístico
                es_local = es_local_turistico(lugar_seleccionado)
                
                if es_local:
                    # Para locales: mostrar días disponibles
                    dias_disponibles = obtener_dias_disponibles(lugar_seleccionado)
                    if dias_disponibles:
                        respuesta = f"📅 Para agendar tu visita a {lugar_seleccionado}, necesito algunos datos.\n\n"
                        respuesta += "Días disponibles:\n"
                        for dia, hora_inicio, hora_fin in dias_disponibles:
                            respuesta += f"• {dia}: {hora_inicio} - {hora_fin}\n"
                        respuesta += "\nPor favor ingresa la fecha de tu visita en formato DD/MM/YYYY (ej: 25/12/2024):"
                        
                        return jsonify({
                            "response": respuesta,
                            "lugar_seleccionado": lugar_seleccionado,
                            "proceso_agendamiento": "esperando_fecha",
                            "menu": ["Volver al inicio"],
                            "input_mode": "date"
                        })
                    else:
                        return jsonify({
                            "response": f"Lo siento, no hay información de horarios disponible para {lugar_seleccionado}",
                            "lugar_seleccionado": lugar_seleccionado,
                            "menu": ["Ver ubicación", "Volver al inicio"]
                        })
                else:
                    # Para puntos turísticos: agendar directamente (están abiertos todos los días)
                    respuesta = f"📅 Para agendar tu visita a {lugar_seleccionado}, necesito algunos datos.\n\n"
                    respuesta += "Este punto turístico está disponible todos los días.\n"
                    respuesta += "Por favor ingresa la fecha de tu visita en formato DD/MM/YYYY (ej: 25/12/2024):"
                    
                    return jsonify({
                        "response": respuesta,
                        "lugar_seleccionado": lugar_seleccionado,
                        "proceso_agendamiento": "esperando_fecha",
                        "menu": ["Volver al inicio"],
                        "input_mode": "date"
                    })
            else:
                return jsonify({
                    "response": "No se especificó qué lugar quieres agendar.",
                    "menu": ["Volver al inicio"]
                })

        # Procesar fecha ingresada (tolerante: si hay lugar_seleccionado y selección es fecha válida, procesar aunque falte proceso_agendamiento)
        fecha_pattern = r'^\d{2}/\d{2}/\d{4}$'
        if ((proceso_agendamiento == "esperando_fecha") or (proceso_agendamiento is None and lugar_seleccionado and re.match(fecha_pattern, str(seleccion)))) and seleccion:
            print(f"[DEBUG] Procesando fecha: {seleccion}")
            if re.match(fecha_pattern, seleccion):
                dia_semana = obtener_dia_semana_espanol(seleccion)
                print(f"[DEBUG] Día de la semana: {dia_semana}")
                if not dia_semana:
                    return jsonify({
                        "response": "Fecha inválida. Por favor ingresa la fecha en formato DD/MM/YYYY:",
                        "lugar_seleccionado": lugar_seleccionado,
                        "proceso_agendamiento": "esperando_fecha",
                        "menu": ["Volver al inicio"],
                        "input_mode": "date"
                    })
                es_local = es_local_turistico(lugar_seleccionado)
                print(f"[DEBUG] Es local turístico: {es_local}")
                if es_local:
                    # Validar si el día está disponible para locales
                    disponible, hora_inicio, hora_fin = validar_dia_disponible(lugar_seleccionado, dia_semana)
                    if not disponible:
                        dias_disponibles = obtener_dias_disponibles(lugar_seleccionado)
                        respuesta = f"❌ Lo siento, {lugar_seleccionado} no está abierto los días {dia_semana}.\n\n"
                        respuesta += "Días disponibles:\n"
                        for dia, hi, hf in dias_disponibles:
                            respuesta += f"• {dia}: {hi} - {hf}\n"
                        respuesta += "\nPor favor elige otra fecha:"
                        return jsonify({
                            "response": respuesta,
                            "lugar_seleccionado": lugar_seleccionado,
                            "proceso_agendamiento": "esperando_fecha",
                            "menu": ["Volver al inicio"],
                            "input_mode": "date"
                        })
                # Fecha válida, pedir hora de salida
                if es_local:
                    respuesta = f"✅ Perfecto! {lugar_seleccionado} está abierto el {dia_semana} de {hora_inicio} a {hora_fin}.\n\n"
                else:
                    respuesta = f"✅ Perfecto! Has seleccionado el {dia_semana} {seleccion} para visitar {lugar_seleccionado}.\n\n"
                respuesta += "Ahora ingresa tu hora de salida en formato HH:MM (ej: 14:30):"
                return jsonify({
                    "response": respuesta,
                    "lugar_seleccionado": lugar_seleccionado,
                    "fecha_visita": seleccion,
                    "proceso_agendamiento": "esperando_hora",
                    "menu": ["Volver al inicio"],
                    "input_mode": "time",
                    "google_access_token": google_access_token
                })
            else:
                return jsonify({
                    "response": "Formato de fecha incorrecto. Por favor usa DD/MM/YYYY (ej: 25/12/2024):",
                    "lugar_seleccionado": lugar_seleccionado,
                    "proceso_agendamiento": "esperando_fecha",
                    "menu": ["Volver al inicio"],
                    "input_mode": "date"
                })

        # Procesar hora de salida
        if proceso_agendamiento == "esperando_hora" and seleccion:
            hora_pattern = r'^\d{1,2}:\d{2}$'
            if re.match(hora_pattern, seleccion):
                # Validar si se proporcionaron las coordenadas del usuario
                if lat_usuario is None or lon_usuario is None:
                    return jsonify({
                        "response": "No se pudo obtener tu ubicación actual. Por favor asegúrate de permitir el acceso a la ubicación.",
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": ["Volver al inicio"]
                    })
                # Recuperar fecha_visita correctamente del request o contexto anterior
                if not fecha_visita:
                    fecha_visita = data.get("fecha_visita") or data.get("fecha")
                if not fecha_visita:
                    fecha_visita = request.json.get("fecha_visita") or request.json.get("fecha")

                # Si después de todo sigue sin fecha, pedirla de nuevo
                if not fecha_visita:
                    return jsonify({
                        "response": "No se pudo recuperar la fecha de tu visita. Por favor ingresa la fecha nuevamente en formato DD/MM/YYYY:",
                        "lugar_seleccionado": lugar_seleccionado,
                        "proceso_agendamiento": "esperando_fecha",
                        "menu": ["Volver al inicio"],
                        "input_mode": "date"
                    })

                # Calcular distancia y tiempo de viaje
                distancia_km = obtener_distancia_lugar(lugar_seleccionado, lat_usuario, lon_usuario)
                if distancia_km is None:
                    return jsonify({
                        "response": "No se pudo calcular la distancia al destino.",
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": ["Volver al inicio"]
                    })
                tiempo_viaje_min = calcular_tiempo_viaje(distancia_km)
                hora_llegada = calcular_hora_llegada(seleccion, tiempo_viaje_min)
                if not hora_llegada:
                    return jsonify({
                        "response": "Formato de hora incorrecto. Por favor usa HH:MM (ej: 14:30):",
                        "lugar_seleccionado": lugar_seleccionado,
                        "fecha_visita": fecha_visita,
                        "proceso_agendamiento": "esperando_hora",
                        "menu": ["Volver al inicio"],
                        "input_mode": "text"
                    })

                # --- AGENDAR EN GOOGLE CALENDAR SI HAY ACCESS TOKEN ---
                evento_agendado = False
                calendar_error = None
                calendar_event_link = None
                manual_calendar_link = None
                if google_access_token:
                    try:
                        creds = Credentials(token=google_access_token)
                        service = googleapiclient.discovery.build('calendar', 'v3', credentials=creds)
                        # Parsear fecha y hora a formato RFC3339
                        fecha_dt = datetime.strptime(fecha_visita, "%d/%m/%Y") if fecha_visita else None
                        hora_dt = datetime.strptime(seleccion, "%H:%M")
                        if fecha_dt:
                            start_dt = datetime.combine(fecha_dt.date(), hora_dt.time())
                            end_dt = start_dt + timedelta(hours=2)
                            start_str = start_dt.isoformat()
                            end_str = end_dt.isoformat()
                            ubicacion_info = obtener_ubicacion_lugar(lugar_seleccionado)
                            event = {
                                'summary': f'Visita a {lugar_seleccionado}',
                                'location': ubicacion_info["nombre"] + ", " + ubicacion_info["parroquia"] + ", Santo Domingo de los Tsáchilas, Ecuador" if ubicacion_info else lugar_seleccionado,
                                'description': f'Visita turística agendada con el asistente. Hora de salida: {seleccion}.',
                                'start': {
                                    'dateTime': start_str,
                                    'timeZone': 'America/Guayaquil',
                                },
                                'end': {
                                    'dateTime': end_str,
                                    'timeZone': 'America/Guayaquil',
                                },
                            }
                            created_event = service.events().insert(calendarId='primary', body=event).execute()
                            evento_agendado = True
                            calendar_event_link = created_event.get('htmlLink')
                    except Exception as e:
                        print(f"[ERROR] Fallo al agendar en Google Calendar: {e}")
                        calendar_error = str(e)
                        # Generar enlace manual de Google Calendar
                        try:
                            # Formato: https://calendar.google.com/calendar/render?action=TEMPLATE&text=...&dates=...&details=...&location=...
                            fecha_dt = datetime.strptime(fecha_visita, "%d/%m/%Y") if fecha_visita else None
                            hora_dt = datetime.strptime(seleccion, "%H:%M")
                            if fecha_dt:
                                start_dt = datetime.combine(fecha_dt.date(), hora_dt.time())
                                end_dt = start_dt + timedelta(hours=2)
                                # Google Calendar expects UTC in YYYYMMDDTHHMMSSZ or local time without Z
                                start_str = start_dt.strftime("%Y%m%dT%H%M%S")
                                end_str = end_dt.strftime("%Y%m%dT%H%M%S")
                                ubicacion_info = obtener_ubicacion_lugar(lugar_seleccionado)
                                location = f"{ubicacion_info['nombre']}, {ubicacion_info['parroquia']}, Santo Domingo de los Tsáchilas, Ecuador" if ubicacion_info else lugar_seleccionado
                                summary = f"Visita a {lugar_seleccionado}"
                                description = f"Visita turística agendada con el asistente. Hora de salida: {seleccion}."
                                import urllib.parse
                                params = {
                                    'action': 'TEMPLATE',
                                    'text': summary,
                                    'dates': f"{start_str}/{end_str}",
                                    'details': description,
                                    'location': location,
                                }
                                manual_calendar_link = "https://calendar.google.com/calendar/render?" + urllib.parse.urlencode(params)
                        except Exception as e2:
                            print(f"[ERROR] Fallo al generar enlace manual de Google Calendar: {e2}")

                respuesta = f"Resumen de tu viaje a {lugar_seleccionado}:\n\n"
                respuesta += f"Fecha: {fecha_visita if fecha_visita else 'No especificada'}\n"
                respuesta += f"Hora de salida: {seleccion}\n"
                respuesta += f"Distancia: {distancia_km:.1f} km\n"
                respuesta += f"Tiempo estimado: {tiempo_viaje_min} minutos\n"
                respuesta += f"Hora estimada de llegada: {hora_llegada}\n\n"
                manual_calendar_url = manual_calendar_link if (google_access_token and calendar_error and manual_calendar_link) else None
                if evento_agendado:
                    respuesta += "✅ ¡Tu visita ha sido agendada en tu Google Calendar!\n"
                    if calendar_event_link:
                        respuesta += f"Puedes ver o editar el evento aquí: {calendar_event_link}\n\n"
                elif google_access_token and calendar_error:
                    respuesta += f"⚠️ No se pudo agendar en Google Calendar automáticamente: {calendar_error}\n"
                    if manual_calendar_link:
                        respuesta += f"Puedes agendarlo manualmente haciendo clic aquí: {manual_calendar_link}\n\n"
                    else:
                        respuesta += "Puedes intentar agendarlo manualmente desde tu Google Calendar.\n\n"
                respuesta += "¿Deseas que genere la ruta de viaje desde tu ubicación actual?"
                response_json = {
                    "response": respuesta,
                    "lugar_seleccionado": lugar_seleccionado,
                    "fecha_visita": fecha_visita,
                    "hora_salida": seleccion,
                    "lat_usuario": lat_usuario,
                    "lon_usuario": lon_usuario,
                    "proceso_agendamiento": "confirmar_ruta",
                    "menu": ["Sí, generar ruta", "No, gracias", "Volver al inicio"]
                }
                if manual_calendar_url:
                    response_json["manual_calendar_url"] = manual_calendar_url
                return jsonify(response_json)
            else:
                return jsonify({
                    "response": "Formato de hora incorrecto. Por favor usa HH:MM (ej: 14:30):",
                    "lugar_seleccionado": lugar_seleccionado,
                    "fecha_visita": fecha_visita,
                    "proceso_agendamiento": "esperando_hora",
                    "menu": ["Volver al inicio"],
                    "input_mode": "time"
                })

        # Confirmar generación de ruta (tolerante: si seleccion es 'Sí, generar ruta' o viene accion: 'generar_ruta', aunque falte proceso_agendamiento)
        if (
            (proceso_agendamiento == "confirmar_ruta") or
            (seleccion and (seleccion.lower().startswith("sí") or seleccion.lower().startswith("si"))) or
            (data.get("accion") == "generar_ruta")
        ):
            if lugar_seleccionado and lat_usuario is not None and lon_usuario is not None:
                ubicacion_info = obtener_ubicacion_lugar(lugar_seleccionado)
                if ubicacion_info:
                    return jsonify({
                        "response": f"¡Listo! Abriendo Google Maps con la ruta desde tu ubicación actual hasta {lugar_seleccionado}. ¡Buen viaje!",
                        "generar_ruta": True,
                        "destino": {
                            "nombre": ubicacion_info["nombre"],
                            "direccion": f"{ubicacion_info['nombre']}, Parroquia {ubicacion_info['parroquia']}, Santo Domingo de los Tsáchilas, Ecuador"
                        }
                    })
            return jsonify({
                "response": "No se pudo generar la ruta porque faltan datos de ubicación.",
                "menu": ["Volver al inicio"]
            })

        # Manejar solicitud de horarios
        if seleccion == "Ver horarios":
            if lugar_seleccionado:
                print(f"[DEBUG] Solicitando horarios para: {lugar_seleccionado}")
                horarios = obtener_horarios_local(lugar_seleccionado)
                if horarios:
                    respuesta = f"🕐 Horarios de atención de {lugar_seleccionado}:\n\n"
                    for dia, hora_inicio, hora_fin in horarios:
                        respuesta += f"• {dia}: {hora_inicio} - {hora_fin}\n"
                    
                    return jsonify({
                        "response": respuesta.strip(),
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": ["Ver ubicación", "Ver servicios", "Volver al inicio"]
                    })
                else:
                    return jsonify({
                        "response": f"No se encontraron horarios para {lugar_seleccionado}",
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": ["Ver ubicación", "Ver servicios", "Volver al inicio"]
                    })
            else:
                return jsonify({
                    "response": "No se especificó de qué local quieres ver los horarios.",
                    "menu": ["Volver al inicio"]
                })

        # Manejar solicitud de servicios
        if seleccion == "Ver servicios":
            if lugar_seleccionado:
                print(f"[DEBUG] Solicitando servicios para: {lugar_seleccionado}")
                servicios = obtener_servicios_local(lugar_seleccionado)
                if servicios and len(servicios) > 0:
                    respuesta = f"🏪 Servicios ofrecidos en {lugar_seleccionado}:\n\n"
                    for servicio in servicios:
                        respuesta += f"• {servicio[0]}\n"
                    
                    return jsonify({
                        "response": respuesta.strip(),
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": ["Ver ubicación", "Ver horarios", "Volver al inicio"]
                    })
                else:
                    return jsonify({
                        "response": f"No se encontraron servicios específicos para {lugar_seleccionado}",
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": ["Ver ubicación", "Ver horarios", "Volver al inicio"]
                    })
            else:
                return jsonify({
                    "response": "No se especificó de qué local quieres ver los servicios.",
                    "menu": ["Volver al inicio"]
                })

        # Manejar solicitud de actividades
        if seleccion == "Ver actividades":
            if lugar_seleccionado:
                print(f"[DEBUG] Solicitando actividades para: {lugar_seleccionado}")
                actividades = obtener_actividades_punto(lugar_seleccionado)
                if actividades and len(actividades) > 0:
                    respuesta = f"🎯 Actividades disponibles en {lugar_seleccionado}:\n\n"
                    for actividad, precio in actividades:
                        if precio:
                            respuesta += f"• {actividad} - Precio: ${precio}\n"
                        else:
                            respuesta += f"• {actividad} - Precio: Consultar\n"
                    
                    return jsonify({
                        "response": respuesta.strip(),
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": ["Ver ubicación", "Volver al inicio"]
                    })
                else:
                    return jsonify({
                        "response": f"No se encontraron actividades específicas para {lugar_seleccionado}",
                        "lugar_seleccionado": lugar_seleccionado,
                        "menu": ["Ver ubicación", "Volver al inicio"]
                    })
            else:
                return jsonify({
                    "response": "No se especificó de qué punto turístico quieres ver las actividades.",
                    "menu": ["Volver al inicio"]
                })

        # Manejar "Volver al inicio"
        if seleccion == "Volver al inicio":
            saludo = "¡Hola viajero! ¿Qué te gustaría explorar en Santo Domingo de los Tsáchilas? Por favor elige una opción:"
            opciones = "\n".join([f"- {op}" for op in MENU_OPCIONES])
            return jsonify({
                "response": f"{saludo}\n\n{opciones}",
                "menu": MENU_OPCIONES
            })

        etiqueta = seleccion.strip()
        etiqueta_normalizada = quitar_tildes(etiqueta).lower()

        # Reconectar si la conexión está cerrada
        try:
            if conn is None or conn.closed != 0:
                print("[DEBUG] Conexión cerrada, intentando reconectar...")
                initialize_connections()
        except Exception as e:
            print(f"[ERROR] Fallo al verificar o reconectar la base de datos: {e}")
            return jsonify({"response": "Error de conexión a la base de datos. Intenta de nuevo más tarde."}), 500

        with conn.cursor() as cur:
            # Buscar en locales_turisticos
            query_locales = '''
                SELECT lt.nombre, lt.descripcion, p.nombre AS parroquia, et.nombre AS etiqueta, lt.latitud, lt.longitud
                FROM locales_turisticos lt
                LEFT JOIN local_etiqueta le ON lt.id = le.id_local
                LEFT JOIN etiquetas_turisticas et ON le.id_etiqueta = et.id
                LEFT JOIN parroquias p ON lt.id_parroquia = p.id
                WHERE lt.estado = 'activo'
                GROUP BY lt.id, lt.nombre, lt.descripcion, p.nombre, et.nombre, lt.latitud, lt.longitud
                LIMIT 100;
            '''
            cur.execute(query_locales)
            resultados_locales = [
                row for row in cur.fetchall()
                if etiqueta_normalizada in quitar_tildes(str(row[0])).lower()
                or etiqueta_normalizada in quitar_tildes(str(row[1])).lower()
                or etiqueta_normalizada in quitar_tildes(str(row[3] or '')).lower()
            ]
            
            # Buscar en puntos_turisticos
            query_puntos = '''
                SELECT pt.nombre, pt.descripcion, p.nombre AS parroquia, et.nombre AS etiqueta, pt.latitud, pt.longitud
                FROM puntos_turisticos pt
                LEFT JOIN puntos_turisticos_etiqueta pte ON pt.id = pte.id_punto_turistico
                LEFT JOIN etiquetas_turisticas et ON pte.id_etiqueta = et.id
                LEFT JOIN parroquias p ON pt.id_parroquia = p.id
                WHERE pt.estado = 'activo'
                GROUP BY pt.id, pt.nombre, pt.descripcion, p.nombre, et.nombre, pt.latitud, pt.longitud
                LIMIT 100;
            '''
            cur.execute(query_puntos)
            resultados_puntos = [
                row for row in cur.fetchall()
                if etiqueta_normalizada in quitar_tildes(str(row[0])).lower()
                or etiqueta_normalizada in quitar_tildes(str(row[1])).lower()
                or etiqueta_normalizada in quitar_tildes(str(row[3] or '')).lower()
            ]

        # Si la selección coincide exactamente con un nombre de lugar, mostrar solo los detalles de ese lugar
        todos_lugares = resultados_locales + resultados_puntos
        seleccion_normalizada = quitar_tildes(etiqueta).lower()

        detalles = None
        for row in todos_lugares:
            if quitar_tildes(str(row[0])).lower() == seleccion_normalizada:
                detalles = row
                break

        # Si el usuario seleccionó un lugar específico, mostrar detalles
        if detalles:
            nombre, descripcion, parroquia = detalles[:3]
            respuesta = f"Detalles de {nombre}:\n{descripcion}\nUbicación: Parroquia {parroquia}\n\n"
            
            # Determinar las opciones del menú según si es local o punto turístico
            es_local = es_local_turistico(nombre)
            if es_local:
                respuesta += "¿Qué información adicional te interesa?"
                opciones_menu = ["Ver ubicación", "Ver horarios", "Ver servicios", "Volver al inicio"]
            else:
                respuesta += "¿Qué información adicional te interesa?"
                opciones_menu = ["Ver ubicación", "Ver actividades", "Volver al inicio"]
            
            return jsonify({
                "response": respuesta.strip(),
                "lugar_seleccionado": nombre,
                "menu": opciones_menu
            })

        # Si no, mostrar la lista de lugares encontrados
        respuesta = f"Resultados para la búsqueda {etiqueta} en Santo Domingo de los Tsáchilas:\n\n"
        if not todos_lugares:
            respuesta += "No se encontraron lugares o puntos turísticos para esta búsqueda."
            return jsonify({
                "response": respuesta.strip(),
                "menu": MENU_OPCIONES
            })
        else:
            for row in todos_lugares:
                nombre, descripcion, parroquia = row[:3]
                descripcion_corta = truncar_descripcion(descripcion, 10)
                respuesta += f"**{nombre}**\n{descripcion_corta}\n\n"
            
            # No agregar la pregunta ni las opciones duplicadas al final del texto
            return jsonify({
                "response": respuesta.strip(), 
                "opciones": [row[0] for row in todos_lugares]
            })
            
    except Exception as e:
        print(f"ERROR en la ruta /chat: {e}")
        traceback.print_exc()
        return jsonify({"response": "Lo siento, ocurrió un error interno al procesar tu solicitud. Por favor intenta de nuevo más tarde."}), 500

# --- Ejecutar la aplicación Flask ---
if __name__ == "__main__":
    PORT = int(os.getenv('PORT', 8000))
    print(f"Iniciando Flask en el puerto {PORT}...")
    app.run(host="0.0.0.0", port=PORT, debug=True)