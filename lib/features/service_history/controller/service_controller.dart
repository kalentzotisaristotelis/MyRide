import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/service_repository.dart';
import '../domain/service_model.dart';

// ΝΕΟ: Χρησιμοποιούμε .family για να περνάμε το bikeId σαν παράμετρο!
final bikeServicesProvider = StreamProvider.family<List<ServiceRecord>, String>((ref, bikeId) {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.getBikeServices(bikeId);
});

final serviceControllerProvider = StateNotifierProvider<ServiceController, AsyncValue<void>>((ref) {
  final repository = ref.watch(serviceRepositoryProvider);
  return ServiceController(repository);
});

final totalMaintenanceCostProvider = StreamProvider<double>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(0.0);

  return FirebaseFirestore.instance
      .collection('services')
      .where('userId', isEqualTo: user.uid) // Φέρε όλα τα service ΜΟΥ
      .snapshots()
      .map((snapshot) {
    double totalCost = 0.0;
    for (var doc in snapshot.docs) {
      totalCost += (doc.data()['cost'] as num?)?.toDouble() ?? 0.0;
    }
    return totalCost; // Επιστρέφει το τελικό άθροισμα!
  });
});


class ServiceController extends StateNotifier<AsyncValue<void>> {
  final ServiceRepository _repository;

  ServiceController(this._repository) : super(const AsyncValue.data(null));

  Future<void> addService({
    required String bikeId,
    required String userId,
    required String title,
    required DateTime date,
    required int mileage,
    required String notes,
    required double cost, // ΝΕΟ
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = ServiceRecord(
        id: '', // Το βάζει το Firebase
        bikeId: bikeId,
        userId: userId,
        title: title,
        date: date,
        mileage: mileage,
        notes: notes,
        cost: cost,
      );

      await _repository.addService(service);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _repository.deleteService(serviceId);
    } catch (e) {
      rethrow;
    }
  }
}