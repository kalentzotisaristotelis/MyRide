import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_ride/features/garage/view/garage_screen.dart';
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
// Πρέπει να εισάγεις και το FirebaseAuth αν δεν το έχεις κάνει
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bikesAsyncValue = ref.watch(userBikesProvider(uid));    final costAsyncValue = ref.watch(totalMaintenanceCostProvider);
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
      // Βρες το body: bikesAsyncValue.when(...)
      body: bikesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (bikes) {
          final int totalBikes = bikes.length;
          final double totalCc = bikes.fold(0, (sum, bike) => sum + bike.cc);

          // ΠΡΟΣΘΗΚΗ: SingleChildScrollView για να μπορείς να σκρολάρεις προς τα κάτω
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Garage Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Total Bikes Card
                  _StatCard(
                    title: 'Total Bikes',
                    value: totalBikes.toString(),
                    icon: Icons.two_wheeler,
                    color: Colors.deepOrange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const GarageScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Total CC Card
                  _StatCard(
                    title: 'Total CC Power',
                    value: '${totalCc.toInt()} cc',
                    icon: Icons.speed,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Maintenance Cost Card
                  costAsyncValue.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                    data: (totalCost) => _StatCard(
                      title: 'Total Maintenance Cost',
                      value: '€${totalCost.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Community Rides Card
                  ridesAsyncValue.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                    data: (rides) => _StatCard(
                      title: 'Community Rides',
                      value: rides.length.toString(),
                      icon: Icons.map,
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RidesScreen()),
                        );
                      },
                    ),
                  ),

                  // Μια μικρή απόσταση στο τέλος για να μην κολλάει η τελευταία κάρτα κάτω
                  const SizedBox(height: 30),
                ],
              ),
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