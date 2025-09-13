import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Authentication result wrapper class
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String message;

  AuthResult._({required this.isSuccess, this.user, required this.message});

  factory AuthResult.success(User? user, String message) {
    return AuthResult._(isSuccess: true, user: user, message: message);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, user: null, message: message);
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "816258150287-4s5bcmu3timfvm2mbcas7kke36ojj7d9.apps.googleusercontent.com",
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enhanced Sign Up with better error handling
  Future<AuthResult> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
        return AuthResult.success(
            userCredential.user, "Account created successfully!");
      }
      return AuthResult.failure("Failed to create account");
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure("An unexpected error occurred");
    }
  }

  // Enhanced Sign In with better error handling
  Future<AuthResult> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return AuthResult.success(userCredential.user, "Welcome back!");
      }
      return AuthResult.failure("Failed to sign in");
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure("An unexpected error occurred");
    }
  }

  // Enhanced Google Sign In with better error handling
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure("Sign-in cancelled");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return AuthResult.failure("Failed to get authentication tokens");
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
        return AuthResult.success(user, "Welcome to MindMate!");
      }

      return AuthResult.failure("Failed to complete sign-in");
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure("Google sign-in failed. Please try again.");
    }
  }

  // Convert Firebase Auth error codes to user-friendly messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'The provided credentials are invalid or have expired.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  // ✅ Save user info to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    final userDoc = _firestore.collection("users").doc(user.uid);

    final userData = {
      "uid": user.uid,
      "name": user.displayName ?? "No Name",
      "email": user.email ?? "No Email",
      "photoURL": user.photoURL ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    };

    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set(userData);
      print("User saved to Firestore");
    } else {
      print("User already exists in Firestore");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
