import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../garage/controller/garage_controller.dart';

// 1. Το κάνουμε ConsumerWidget για να "ακούμε" τα δεδομένα
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Συνδεόμαστε στον ΙΔΙΟ σωλήνα που χρησιμοποιεί και το Garage!
    final bikesAsyncValue = ref.watch(userBikesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyRide Dashboard'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 3. Ελέγχουμε τα δεδομένα
            bikesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (bikes) {
                // 4. Υπολογισμοί (Business Logic στο UI για απλότητα τώρα)
                final totalBikes = bikes.length;

                // Υπολογισμός συνόλου κυβικών (fold είναι σαν loop που αθροίζει)
                final totalCC = bikes.fold(0.0, (sum, bike) => sum + bike.cc);

                return Column(
                  children: [
                    // Κάρτα 1: Σύνολο Μηχανών
                    _StatCard(
                      title: 'Total Bikes',
                      value: totalBikes.toString(),
                      icon: Icons.two_wheeler,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),

                    // Κάρτα 2: Σύνολο Κυβικών
                    _StatCard(
                      title: 'Total Power',
                      value: '${totalCC.toInt()} cc',
                      icon: Icons.speed,
                      color: Colors.deepOrange,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Ένα μικρό βοηθητικό Widget για να μην γράφουμε τον ίδιο κώδικα 2 φορές
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Στρογγυλό εικονίδιο
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), // Απαλό χρώμα φόντου
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),

            // Κείμενα
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}