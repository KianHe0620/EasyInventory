// lib/controllers/auth.controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // scopes can be adjusted; optional
    scopes: <String>['email'],
  );

  // Email/password sign in
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthException(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Email/password register
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthException(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Cancelled by user';
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthException(e);
    } catch (e) {
      return 'Google sign-in failed: $e';
    }
  }

  // Password reset
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthException(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      // sign out from Firebase
      await _auth.signOut();
      // disconnect GoogleSignIn too
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    } catch (_) {}
  }

  // Helpers
  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password too weak (min 6 chars).';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method.';
      default:
        return e.message ?? 'Authentication error: ${e.code}';
    }
  }
}
