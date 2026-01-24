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
  final Color color; // Αυτό θα είναι το βασικό χρώμα

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Να πιάνει όλο το πλάτος
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradient φόντο από το χρώμα προς το λίγο πιο ανοιχτό
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Λευκά γράμματα
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          // Ένα μεγάλο εικονίδιο με διαφάνεια για στυλ
          Icon(
            icon,
            color: Colors.white.withOpacity(0.3),
            size: 60,
          ),
        ],
      ),
    );
  }
}