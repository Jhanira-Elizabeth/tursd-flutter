import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Nombre de la colección de usuarios (ajústalo si es diferente)
  final String _usersCollection = 'users';
  // Nombre del campo donde guardaremos los IDs de los favoritos
  final String _favoritesField = 'favoritePuntosTuristicos';

  Future<List<int>> getFavoritePuntosTuristicos() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc =
            await _firestore.collection(_usersCollection).doc(user.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          final favorites = data[_favoritesField] as List<dynamic>?;
          return favorites?.map((item) => item as int).toList() ?? [];
        }
      }
      return [];
    } catch (e) {
      _logger.e('Error al obtener favoritos', error: e);
      return [];
    }
  }

  Future<bool> isPuntoTuristicoFavorite(int puntoTuristicoId) async {
    final favorites = await getFavoritePuntosTuristicos();
    return favorites.contains(puntoTuristicoId);
  }

  Future<void> addPuntoTuristicoToFavorites(int puntoTuristicoId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoritesField: FieldValue.arrayUnion([puntoTuristicoId]),
        });
      }
    } catch (e) {
      _logger.e('Error al añadir a favoritos', error: e);
    }
  }

  Future<void> removePuntoTuristicoFromFavorites(int puntoTuristicoId) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userRef = _firestore.collection(_usersCollection).doc(user.uid);
        await userRef.update({
          _favoritesField: FieldValue.arrayRemove([puntoTuristicoId]),
        });
      }
    } catch (e) {
      _logger.e('Error al eliminar de favoritos', error: e);
    }
  }
}