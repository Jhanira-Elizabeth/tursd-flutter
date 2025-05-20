import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Añadido

  // Corregido: Usamos User de Firebase Auth correctamente
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Nombre de la colección de usuarios
  final String _usersCollection = 'users'; // Añadido aquí, importante!

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Corregido: Usamos OAuthProvider en lugar de GoogleAuthProvider
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Llamamos al método para crear el documento del usuario
      if (user != null) { //Verificamos que el usuario no sea nulo
        await createUserDocumentIfNotExists(user);
      }
      return user;
    } catch (e) {
      _logger.e('Error en Google Sign-In', error: e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Nuevo método para crear el documento del usuario si no existe
  Future<void> createUserDocumentIfNotExists(User user) async {
    final userRef = _firestore.collection(_usersCollection).doc(user.uid);
    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'favoritePuntosTuristicos': [], // Inicializar campo vacío para favoritos
        'email': user.email,
        'name': user.displayName,
        // Agrega otros campos si deseas, como fotoURL
        'photoURL': user.photoURL,
      });
      _logger.i('Documento de usuario creado para ${user.uid}');
    } else {
      _logger.i('Documento de usuario ya existe para ${user.uid}');
    }
  }
}