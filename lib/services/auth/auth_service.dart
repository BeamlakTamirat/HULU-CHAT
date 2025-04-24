import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String> getCurrentUserDisplayName() async {
    User? user = _auth.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user?.uid).get();
      if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['displayName'] != null) {
          return userData['displayName'] as String;
        }
      }
    } catch (e) {
      print("Error fetching display name: $e");
    }

    return "";
  }

  Future<String?> getCurrentUserPhotoURL() async {
    User? user = _auth.currentUser;
    if (user != null && user.photoURL != null) {
      return user.photoURL;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user?.uid).get();
      if (userDoc.exists && userDoc.data() is Map<String, dynamic>) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['photoURL'] != null) {
          return userData['photoURL'] as String;
        }
      }
    } catch (e) {
      print("Error fetching photo URL: $e");
    }

    return null;
  }

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user info if it doesn't already exist
      _firestore.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    try {
      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user info in a separate collection
      _firestore.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<void> updateDisplayName(String displayName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Update in Firebase Auth
      await user.updateDisplayName(displayName);

      // Update in Firestore
      await _firestore.collection("users").doc(user.uid).update({
        'displayName': displayName,
      });
    }
  }

  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Delete user document from Firestore
      await _firestore.collection("users").doc(user.uid).delete();

      // Delete user authentication
      await user.delete();
    }
  }
}
