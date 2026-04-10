import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';

// 1. Provider που διαβάζει και φέρνει το προφίλ του συνδεδεμένου χρήστη
final currentUserProfileProvider = FutureProvider<AppUser?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserProfile(user.uid);
});

final userProfileProvider = FutureProvider.family<AppUser?, String>((ref, userId) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserProfile(userId);
});

// 2. Controller για την αποθήκευση/αλλαγή των στοιχείων
final userControllerProvider = StateNotifierProvider<UserController, AsyncValue<void>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserController(repository);
});

class UserController extends StateNotifier<AsyncValue<void>> {
  final UserRepository _repository;

  UserController(this._repository) : super(const AsyncValue.data(null));

  // Η συνάρτηση που καλείται όταν πατάμε "Save"
  Future<void> saveProfile({
    required String displayName,
    required String bio,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in!';

      final appUser = AppUser(
        id: user.uid,
        email: user.email ?? '', // Κρατάμε το email από το Auth
        displayName: displayName,
        bio: bio,
      );

      await _repository.saveUserProfile(appUser);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}