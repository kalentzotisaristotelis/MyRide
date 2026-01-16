import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/login_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyRide Dashboard'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          // Κουμπί Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 1. Καλούμε τη συνάρτηση logout από το Repository
              await ref.read(authRepositoryProvider).logout();

              // 2. Μόλις τελειώσει, γυρνάμε πίσω στο Login
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Welcome Rider!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('You are logged in.'),
          ],
        ),
      ),
    );
  }
}