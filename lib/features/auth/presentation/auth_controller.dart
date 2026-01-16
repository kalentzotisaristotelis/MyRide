import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

// 1. Αυτός είναι ο Provider που θα χρησιμοποιεί το UI για να μιλάει με τον Controller
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

// 2. Η κλάση του Controller
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncValue.data(null)); // Αρχική κατάσταση: Όλα ήρεμα

  Future<void> login({required String email, required String password}) async {
    // Κατάσταση 1: Φόρτωση (Loading)
    state = const AsyncValue.loading();

    // Κατάσταση 2: Προσπάθεια σύνδεσης
    state = await AsyncValue.guard(() => _authRepository.login(
      email: email,
      password: password,
    ));
  }
}