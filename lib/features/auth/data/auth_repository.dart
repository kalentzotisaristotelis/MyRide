import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Ορίζουμε τον Provider για να μπορούμε να καλούμε αυτό το αρχείο από παντού
final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  // Παίρνουμε το εργαλείο της Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Η συνάρτηση για Login
  Future<void> login({required String email, required String password}) async {
    try {
      // Προσπάθησε να κάνεις login
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Αν γίνει λάθος (π.χ. λάθος κωδικός), πέταξε ένα μήνυμα
      throw e.message ?? 'Something went wrong!';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Η συνάρτηση για Logout (θα τη χρειαστούμε μετά)
  Future<void> logout() async {
    await _auth.signOut();
  }
}