import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text('Rider Profile', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),

            // Το κουμπί Logout μετακόμισε εδώ
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authRepositoryProvider).logout();
                // Δεν χρειάζεται Navigator, το AuthWrapper θα το δει και θα μας πετάξει έξω!
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}