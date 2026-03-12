import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ride_repository.dart';
import '../domain/ride_model.dart';

// 1. Αυτός ο Provider "ακούει" συνεχώς για νέες βόλτες
final ridesStreamProvider = StreamProvider<List<Ride>>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.getRides();
});

// 2. Ο Provider για τον Controller (που κάνει τις πράξεις)
final rideControllerProvider = StateNotifierProvider<RideController, AsyncValue<void>>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return RideController(repository);
});

class RideController extends StateNotifier<AsyncValue<void>> {
  final RideRepository _repository;

  RideController(this._repository) : super(const AsyncValue.data(null));

  // Συνάρτηση για προσθήκη Βόλτας
  Future<void> addRide({
    required String creatorId,
    required String title,
    required String description,
    required DateTime date,
    required String meetingPoint,
  }) async {
    state = const AsyncValue.loading();

    try {
      final newRide = Ride(
        id: '', // Το βάζει το Firebase αυτόματα
        creatorId: creatorId,
        title: title,
        description: description,
        date: date,
        meetingPoint: meetingPoint,
        // ΛΟΓΙΚΗ: Αυτός που δημιουργεί τη βόλτα, μπαίνει αυτόματα στους συμμετέχοντες!
        participants: [creatorId],
      );

      await _repository.addRide(newRide);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}