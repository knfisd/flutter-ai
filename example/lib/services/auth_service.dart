import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in aborted';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Facebook Sign In
  Future<UserCredential> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        throw 'Facebook sign in failed';
      }

      // Get the access token
      final accessToken = result.accessToken;
      if (accessToken == null) {
        throw 'No access token from Facebook';
      }

      // Debug the access token structure
      print('Access Token Type: ${accessToken.runtimeType}');
      print('Access Token: $accessToken');
      
      // Try to get the token string using reflection
      final tokenString = accessToken.toString().contains('token: ') 
          ? accessToken.toString().split('token: ')[1].split(' ')[0]
          : accessToken.toString();
      
      print('Extracted Token: $tokenString');
      
      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        tokenString,
      );
      
      // Sign in to Firebase with the Facebook credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Facebook authentication failed';
    } catch (e) {
      throw 'An error occurred during Facebook authentication: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
}
