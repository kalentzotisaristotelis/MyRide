import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/garage_repository.dart';
import '../domain/bike_model.dart';

// Provider για τον έλεγχο των ενεργειών (Add, Update, Delete)
final garageControllerProvider = StateNotifierProvider<GarageController, AsyncValue<void>>((ref) {
  final repository = ref.watch(garageRepositoryProvider);
  return GarageController(repository);
});

// StreamProvider για να βλέπουμε μηχανές οποιουδήποτε χρήστη
final userBikesProvider = StreamProvider.family<List<Bike>, String>((ref, userId) {
  return ref.watch(garageRepositoryProvider).getUserBikes(userId);
});

class GarageController extends StateNotifier<AsyncValue<void>> {
  final GarageRepository _repository;

  GarageController(this._repository) : super(const AsyncValue.data(null));

  // Προσθήκη νέας μηχανής - ΕΝΗΜΕΡΩΜΕΝΟ ΜΕ kmStr
  Future<void> addBike({
    required String userId,
    required String make,
    required String model,
    required String yearStr,
    required String ccStr,
    required String kmStr, // ΝΕΑ ΠΑΡΑΜΕΤΡΟΣ
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();

    try {
      final bike = Bike(
        id: '', // Το Firestore θα δημιουργήσει αυτόματα το ID
        userId: userId,
        make: make,
        model: model,
        year: int.parse(yearStr),
        cc: double.parse(ccStr),
        mileage: int.parse(kmStr), // ΜΕΤΑΤΡΟΠΗ ΣΕ INT
        imageUrl: imageUrl,
      );

      await _repository.addBike(bike);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Διαγραφή μηχανής
  Future<void> deleteBike(String bikeId) async {
    try {
      await _repository.deleteBike(bikeId);
    } catch (e) {
      rethrow;
    }
  }

  // Ενημέρωση υπάρχουσας μηχανής
  Future<void> updateBike({
    required String bikeId,
    required String userId,
    required String make,
    required String model,
    required int year,
    required double cc,
    required int mileage,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();

    try {
      final updatedBike = Bike(
        id: bikeId,
        userId: userId,
        make: make,
        model: model,
        year: year,
        cc: cc,
        mileage: mileage,
        imageUrl: imageUrl,
      );

      await _repository.updateBike(updatedBike);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}