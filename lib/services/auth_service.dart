import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email & password
  Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Sign in with email & password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send verification email';
    }
  }

  // Reload user to get updated email verification status
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      throw 'Failed to reload user';
    }
  }

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Delete current user account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}
