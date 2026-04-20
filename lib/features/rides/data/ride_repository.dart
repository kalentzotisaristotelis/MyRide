import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/ride_model.dart';

// Provider για να τον βλέπει όλη η εφαρμογή
final rideRepositoryProvider = Provider((ref) => RideRepository());

class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Δημιουργία νέας βόλτας
  Future<void> addRide(Ride ride) async {
    try {
      await _firestore.collection('rides').add(ride.toMap());
    } catch (e) {
      throw 'Failed to create ride: $e';
    }
  }

  // 2. Διάβασμα ΟΛΩΝ των επερχόμενων βόλτων
  Stream<List<Ride>> getRides() {
    return _firestore
        .collection('rides')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Ride.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> toggleParticipation({
    required String rideId,
    required String userId,
    required bool isGoing,
    String? bikeName,
  }) async {
    try {
      final docRef = _firestore.collection('rides').doc(rideId);

      if (isGoing) {
        // Προσθήκη: Στέλνουμε το Map κατευθείαν
        await docRef.update({
          'participants': FieldValue.arrayUnion([
            {'uid': userId, 'bike': bikeName ?? 'Rider'}
          ])
        });
      } else {
        // Αφαίρεση: Διαβάζουμε τη λίστα και φιλτράρουμε χειροκίνητα
        final doc = await docRef.get();
        if (!doc.exists) return;

        // Παίρνουμε τη λίστα και σιγουρευόμαστε ότι το Dart την βλέπει ως List<dynamic>
        List<dynamic> participants = doc.data()?['participants'] ?? [];

        // Βρίσκουμε το Map που θέλουμε να διώξουμε
        // Προσοχή: Εδώ το p['uid'] είναι String, γι' αυτό και δεν πρέπει να χρησιμοποιούμε index
        final entryToRemove = participants.firstWhere(
              (p) => p is Map && p['uid'] == userId,
          orElse: () => null,
        );

        if (entryToRemove != null) {
          await docRef.update({
            'participants': FieldValue.arrayRemove([entryToRemove])
          });
        }
      }
    } catch (e) {
      // Εδώ πετάει το σφάλμα που βλέπεις στο log
      throw 'Failed to update participation: $e';
    }
  }

  // 4. Διαγραφή βόλτας
  Future<void> deleteRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).delete();
    } catch (e) {
      throw 'Failed to delete ride: $e';
    }
  }
}