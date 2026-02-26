import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/garage_repository.dart';
import '../domain/bike_model.dart';

final garageControllerProvider = StateNotifierProvider<GarageController, AsyncValue<void>>((ref) {
  final repository = ref.watch(garageRepositoryProvider);
  return GarageController(repository);
});

// Αυτός ο Provider "ακούει" συνεχώς τη βάση
final userBikesProvider = StreamProvider<List<Bike>>((ref) {
  final user = FirebaseAuth.instance.currentUser;

  // Αν δεν υπάρχει χρήστης, επέστρεψε κενή λίστα
  if (user == null) return Stream.value([]);

  // Ζήτα από το Repository τις μηχανές του συγκεκριμένου χρήστη
  return ref.watch(garageRepositoryProvider).getUserBikes(user.uid);
});

class GarageController extends StateNotifier<AsyncValue<void>> {
  final GarageRepository _repository;

  GarageController(this._repository) : super(const AsyncValue.data(null));

  Future<void> addBike({
    required String userId,
    required String make,
    required String model,
    required String yearStr,
    required String ccStr,
  }) async {
    state = const AsyncValue.loading();

    try {
      final bike = Bike(
        id: '', // Το ID θα το βάλει το Firebase αυτόματα
        userId: userId,
        make: make,
        model: model,
        year: int.parse(yearStr),
        cc: double.parse(ccStr),
      );

      await _repository.addBike(bike);
      state = const AsyncValue.data(null); // Όλα καλά
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> deleteBike(String bikeId) async {
    try {
      await _repository.deleteBike(bikeId);
      // Δεν χρειάζεται να αλλάξουμε το state manually,
      // επειδή το StreamProvider "ακούει" τη βάση και θα ενημερωθεί μόνο του!
    } catch (e) {
      // Εδώ θα μπορούσαμε να δείξουμε κάποιο λάθος
      rethrow;
    }
  }
  // Σωστή μέθοδος για τον Controller
  Future<void> updateBike({
    required String bikeId,
    required String userId,
    required String make,
    required String model,
    required int year,
    required double cc,
    required int mileage,
  }) async {
    state = const AsyncValue.loading(); // Δείχνουμε ότι φορτώνει

    try {
      // 1. Φτιάχνουμε το αντικείμενο Bike με τα νέα στοιχεία
      final updatedBike = Bike(
        id: bikeId,
        userId: userId,
        make: make,
        model: model,
        year: year,
        cc: cc,
        mileage: mileage,
      );

      // 2. Ζητάμε από τον REPOSITORY να το στείλει στη βάση
      await _repository.updateBike(updatedBike);

      state = const AsyncValue.data(null); // Όλα καλά
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Αν γίνει λάθος
    }
  }
}