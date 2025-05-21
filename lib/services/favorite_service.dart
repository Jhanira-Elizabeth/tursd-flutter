import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Nombre de la colección de usuarios (ajústalo si es diferente)
  final String _usersCollection = 'users';

  // Nombres de los campos donde guardaremos los IDs de los favoritos
  final String _favoritePuntosField = 'favoritePuntosTuristicos';
  final String _favoriteLocalesField = 'favoriteLocalesTuristicos'; // <-- Nuevo campo para locales

  // ----------------------------------------------------
  // Métodos para PUNTOS TURÍSTICOS
  // ----------------------------------------------------

  // Renombrado para mayor claridad y para que coincida con FavoritesScreen
  Future<List<int>> getFavoritePuntoIds() async { // <-- Nuevo nombre
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection(_usersCollection).doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          // Usamos el nuevo nombre de campo _favoritePuntosField
          final favorites = data[_favoritePuntosField] as List<dynamic>?;
          return favorites?.map((item) => item as int).toList() ?? [];
        }
      }
      return [];
    } catch (e) {
      _logger.e('Error al obtener IDs de puntos favoritos', error: e);
      return [];
    }
  }

  Future<bool> isPuntoTuristicoFavorite(int puntoTuristicoId) async {
    final favorites = await getFavoritePuntoIds(); // Usamos el nuevo nombre del método
    return favorites.contains(puntoTuristicoId);
  }

  Future<void> addPuntoTuristicoToFavorites(int puntoTuristicoId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoritePuntosField: FieldValue.arrayUnion([puntoTuristicoId]), // Usamos el nuevo nombre de campo
        });
      }
    } catch (e) {
      _logger.e('Error al añadir punto a favoritos', error: e);
    }
  }

  Future<void> removePuntoTuristicoFromFavorites(int puntoTuristicoId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoritePuntosField: FieldValue.arrayRemove([puntoTuristicoId]), // Usamos el nuevo nombre de campo
        });
      }
    } catch (e) {
      _logger.e('Error al eliminar punto de favoritos', error: e);
    }
  }

  // ----------------------------------------------------
  // Métodos para LOCALES TURÍSTICOS (NUEVOS)
  // ----------------------------------------------------

  Future<List<int>> getFavoriteLocalIds() async { // <-- Nuevo método
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection(_usersCollection).doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          // Usamos el nuevo campo _favoriteLocalesField
          final favorites = data[_favoriteLocalesField] as List<dynamic>?;
          return favorites?.map((item) => item as int).toList() ?? [];
        }
      }
      return [];
    } catch (e) {
      _logger.e('Error al obtener IDs de locales favoritos', error: e);
      return [];
    }
  }

  Future<bool> isLocalTuristicoFavorite(int localTuristicoId) async { // <-- Nuevo método
    final favorites = await getFavoriteLocalIds();
    return favorites.contains(localTuristicoId);
  }

  Future<void> addLocalTuristicoToFavorites(int localTuristicoId) async { // <-- Nuevo método
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoriteLocalesField: FieldValue.arrayUnion([localTuristicoId]), // Usamos el nuevo campo
        });
      }
    } catch (e) {
      _logger.e('Error al añadir local a favoritos', error: e);
    }
  }

  Future<void> removeLocalTuristicoFromFavorites(int localTuristicoId) async { // <-- Nuevo método
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoriteLocalesField: FieldValue.arrayRemove([localTuristicoId]), // Usamos el nuevo campo
        });
      }
    } catch (e) {
      _logger.e('Error al eliminar local de favoritos', error: e);
    }
  }
}