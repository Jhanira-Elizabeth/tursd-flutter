import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  final String _usersCollection = 'users';

  final String _favoritePuntosField = 'favoritePuntosTuristicos';
  final String _favoriteLocalesField = 'favoriteLocalesTuristicos';

  // Obtener puntos favoritos (objetos completos)
  Future<List<Map<String, dynamic>>> getFavoritePuntos() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection(_usersCollection).doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          final favoritos = data[_favoritePuntosField] as List<dynamic>?;
          return favoritos?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
        }
      }
      return [];
    } catch (e) {
      _logger.e('Error al obtener puntos favoritos', error: e);
      return [];
    }
  }

  // Obtener locales favoritos (objetos completos)
  Future<List<Map<String, dynamic>>> getFavoriteLocales() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection(_usersCollection).doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          final favoritos = data[_favoriteLocalesField] as List<dynamic>?;
          return favoritos?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
        }
      }
      return [];
    } catch (e) {
      _logger.e('Error al obtener locales favoritos', error: e);
      return [];
    }
  }

  // Agregar punto turístico (objeto completo)
  Future<void> addPuntoTuristicoToFavorites(Map<String, dynamic> puntoData) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoritePuntosField: FieldValue.arrayUnion([puntoData]),
        });
      }
    } catch (e) {
      _logger.e('Error al añadir punto a favoritos', error: e);
    }
  }

  // Eliminar punto turístico (objeto completo)
  Future<void> removePuntoTuristicoFromFavorites(Map<String, dynamic> puntoData) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoritePuntosField: FieldValue.arrayRemove([puntoData]),
        });
      }
    } catch (e) {
      _logger.e('Error al eliminar punto de favoritos', error: e);
    }
  }

  // Agregar local turístico (objeto completo)
  Future<void> addLocalTuristicoToFavorites(Map<String, dynamic> localData) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoriteLocalesField: FieldValue.arrayUnion([localData]),
        });
      }
    } catch (e) {
      _logger.e('Error al añadir local a favoritos', error: e);
    }
  }

  // Eliminar local turístico (objeto completo)
  Future<void> removeLocalTuristicoFromFavorites(Map<String, dynamic> localData) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoriteLocalesField: FieldValue.arrayRemove([localData]),
        });
      }
    } catch (e) {
      _logger.e('Error al eliminar local de favoritos', error: e);
    }
  }

  // Opcional: Métodos para verificar si un punto o local es favorito,
  // podrías hacerlo buscando si algún favorito tiene el mismo 'id' en la lista.
  Future<bool> isPuntoTuristicoFavorite(int puntoId) async {
    final favoritos = await getFavoritePuntos();
    return favoritos.any((element) => element['id'] == puntoId);
  }

  Future<bool> isLocalTuristicoFavorite(int localId) async {
    final favoritos = await getFavoriteLocales();
    return favoritos.any((element) => element['id'] == localId);
  }
}
