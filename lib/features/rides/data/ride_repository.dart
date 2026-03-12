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
        .orderBy('date', descending: false) // Οι πιο κοντινές ημερομηνίες πρώτα!
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Ride.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
  // 3. Προσθήκη ή αφαίρεση συμμετοχής (RSVP)
  Future<void> toggleParticipation(String rideId, String userId, bool isGoing) async {
    try {
      if (isGoing) {
        // Αν πάει, τον προσθέτουμε στη λίστα (χωρίς να διπλοτυπωθεί)
        await _firestore.collection('rides').doc(rideId).update({
          'participants': FieldValue.arrayUnion([userId])
        });
      } else {
        // Αν το ακυρώσει, τον βγάζουμε από τη λίστα
        await _firestore.collection('rides').doc(rideId).update({
          'participants': FieldValue.arrayRemove([userId])
        });
      }
    } catch (e) {
      throw 'Failed to update participation: $e';
    }
  }
}