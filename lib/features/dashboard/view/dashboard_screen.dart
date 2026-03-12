import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../garage/controller/garage_controller.dart';
import '../../profile/controller/user_controller.dart';
import '../../profile/view/edit_profile_screen.dart';
import '../../rides/controller/ride_controller.dart';
import '../../rides/view/add_ride_screen.dart';
import '../../rides/view/rides_screen.dart';
import '../../service_history/controller/service_controller.dart';

// ΠΡΟΣΟΧΗ: Το κάναμε ConsumerWidget για να μπορεί να "ακούει"
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Παρακολουθούμε ζωντανά (stream) τις μηχανές του χρήστη
    final bikesAsyncValue = ref.watch(userBikesProvider);
    final costAsyncValue = ref.watch(totalMaintenanceCostProvider);
    final ridesAsyncValue = ref.watch(ridesStreamProvider);
    final profileAsyncValue = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          // Κουμπάκι για το Προφίλ!
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              // Διαβάζουμε το τωρινό μας προφίλ πριν ανοίξουμε την οθόνη
              final currentProfile = profileAsyncValue.valueOrNull;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(existingProfile: currentProfile),
                ),
              );
            },
          ),
        ],
      ),

      // 2. Ελέγχουμε την κατάσταση των δεδομένων (Loading, Error, Data)
      body: bikesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (bikes) {

          // --- ΥΠΟΛΟΓΙΣΜΟΣ ΠΡΑΓΜΑΤΙΚΩΝ ΣΤΑΤΙΣΤΙΚΩΝ ---

          // Α. Πόσες μηχανές έχουμε;
          final int totalBikes = bikes.length;

          // Β. Πόσα είναι τα συνολικά κυβικά; (Προσθέτει τα CC όλων των μηχανών)
          final double totalCc = bikes.fold(0, (sum, bike) => sum + bike.cc);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Garage Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Η κάρτα με το σύνολο των μηχανών
                _StatCard(
                  title: 'Total Bikes',
                  value: totalBikes.toString(),
                  icon: Icons.two_wheeler,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 16),

                // Η κάρτα με τη συνολική δύναμη σε κυβικά (CC)
                _StatCard(
                  title: 'Total CC Power',
                  value: '${totalCc.toInt()} cc',
                  icon: Icons.speed,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                // Η νέα κάρτα για τα Λεφτά!
                costAsyncValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('Error loading cost: $e'),
                  data: (totalCost) {
                    return _StatCard(
                      title: 'Total Maintenance Cost',
                      value: '€${totalCost.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.green, // Πράσινο για τα λεφτά!
                    );
                  },
                ),
                const SizedBox(height: 16),
                ridesAsyncValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('Error loading rides: $e'),
                  data: (rides) {
                    return _StatCard(
                      title: 'Community Rides', // Ο τίτλος της κάρτας
                      value: rides.length.toString(), // Πόσες βόλτες υπάρχουν;
                      icon: Icons.map, // Ωραίο εικονίδιο χάρτη/βόλτας
                      color: Colors.indigo, // Το χρώμα της κοινότητας
                      onTap: () {
                        // Όταν την πατάς, σε πάει στην οθόνη με τις βόλτες!
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RidesScreen()),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Αυτό είναι το ίδιο όμορφο widget που φτιάξαμε την προηγούμενη φορά
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
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
                    color: Colors.white,
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
            Icon(
              icon,
              color: Colors.white.withOpacity(0.3),
              size: 60,
            ),
          ],
        ),
      ),
    );
  }
}