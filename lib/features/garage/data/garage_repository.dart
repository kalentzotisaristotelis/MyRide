import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/bike_model.dart';

final garageRepositoryProvider = Provider((ref) => GarageRepository());

class GarageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Προσθήκη νέας μηχανής
  Future<void> addBike(Bike bike) async {
    try {
      // Δημιουργούμε μια συλλογή 'bikes' στη βάση
      await _firestore.collection('bikes').add(bike.toMap());
    } catch (e) {
      throw 'Failed to add bike: $e';
    }
  }

  // Διαγραφή μηχανής με βάση το ID της
  Future<void> deleteBike(String bikeId) async {
    try {
      await _firestore.collection('bikes').doc(bikeId).delete();
    } catch (e) {
      throw 'Failed to delete bike: $e';
    }
  }

  // Διάβασμα των μηχανών του χρήστη (θα το χρειαστούμε μετά)
  Stream<List<Bike>> getUserBikes(String userId) {
    return _firestore
        .collection('bikes')
        .where('userId', isEqualTo: userId) // Φέρε μόνο τις δικές μου
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Bike.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}