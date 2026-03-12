import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';

// Provider για να τον βλέπει όλη η εφαρμογή
final userRepositoryProvider = Provider((ref) => UserRepository());

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Δημιουργία ή Ενημέρωση Προφίλ
  Future<void> saveUserProfile(AppUser user) async {
    try {
      // Χρησιμοποιούμε το .set() για να φτιάξει το έγγραφο με το ΣΥΓΚΕΚΡΙΜΕΝΟ ID του χρήστη
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw 'Failed to save profile: $e';
    }
  }

  // 2. Ανάγνωση ενός Προφίλ (βάσει ID)
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch profile: $e';
    }
  }
}