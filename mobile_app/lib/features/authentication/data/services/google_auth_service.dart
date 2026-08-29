import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Signs in with Google through Firebase and returns a Firebase ID token.
/// A null result is a user-initiated cancellation, not an application error.
class GoogleAuthService {
  GoogleAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _initialization;

  Future<String?> signIn() async {
    await (_initialization ??= _googleSignIn.initialize());

    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        throw StateError('Google sign-in is not supported on this device.');
      }

      final googleUser = await _googleSignIn.authenticate();
      final googleAuthentication = googleUser.authentication;
      final googleIdToken = googleAuthentication.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw StateError('Google did not return an ID token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseIdToken = await userCredential.user?.getIdToken(true);
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw StateError('Firebase did not return an ID token.');
      }
      return firebaseIdToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw StateError(error.message ?? 'Google sign-in failed.');
    }
  }
}
