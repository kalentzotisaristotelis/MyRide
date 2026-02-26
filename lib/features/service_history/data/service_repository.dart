import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/service_model.dart';

final serviceRepositoryProvider = Provider((ref) => ServiceRepository());

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Προσθήκη νέου Service
  Future<void> addService(ServiceRecord service) async {
    try {
      await _firestore.collection('services').add(service.toMap());
    } catch (e) {
      throw 'Failed to add service: $e';
    }
  }

  // Διάβασμα των Services ΜΙΑΣ ΣΥΓΚΕΚΡΙΜΕΝΗΣ μηχανής (με βάση το bikeId)
  Stream<List<ServiceRecord>> getBikeServices(String bikeId) {
    return _firestore
        .collection('services')
        .where('bikeId', isEqualTo: bikeId) // Φέρε μόνο τα δικά της
        .snapshots()
        .map((snapshot) {

      // 1. Μετατρέπουμε τα έγγραφα σε λίστα από ServiceRecord
      List<ServiceRecord> services = snapshot.docs.map((doc) {
        return ServiceRecord.fromMap(doc.data(), doc.id);
      }).toList();

      // 2. Τα ταξινομούμε ώστε το πιο πρόσφατο να είναι πάντα πάνω-πάνω
      services.sort((a, b) => b.date.compareTo(a.date));

      return services;
    });
  }

  // Διαγραφή Service
  Future<void> deleteService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).delete();
    } catch (e) {
      throw 'Failed to delete service: $e';
    }
  }
} 