
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream for auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      // In a real app, you'd want to handle this error more gracefully
      // For example, by showing a snackbar to the user.
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Sign out from Google
    await _auth.signOut();         // Sign out from Firebase
  }
}
