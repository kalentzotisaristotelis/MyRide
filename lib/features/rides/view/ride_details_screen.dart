import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/ride_model.dart';
import '../controller/ride_controller.dart';

class RideDetailsScreen extends ConsumerWidget {
  final Ride ride; // Η αρχική βόλτα που μας ήρθε από την προηγούμενη οθόνη

  const RideDetailsScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Παίρνουμε τη ζωντανή λίστα με τις βόλτες
    final ridesList = ref.watch(ridesStreamProvider).valueOrNull ?? [];

    // 2. Βρίσκουμε την ΤΩΡΙΝΗ μορφή της δικής μας βόλτας!
    final currentRide = ridesList.firstWhere(
          (r) => r.id == ride.id,
      orElse: () => ride, // Αν δεν τη βρει (π.χ. φορτώνει), δείξε την αρχική
    );

    final user = FirebaseAuth.instance.currentUser;
    // 3. Ελέγχουμε αν είμαστε στους συμμετέχοντες της ΤΩΡΙΝΗΣ βόλτας
    final isGoing = user != null && currentRide.participants.contains(user.uid);

    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(currentRide.date);
    final timeStr = DateFormat('HH:mm').format(currentRide.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Τίτλος
            Text(
              currentRide.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Πληροφορίες (Ημερομηνία, Ώρα, Σημείο)
            _InfoRow(icon: Icons.calendar_today, text: dateStr, color: Colors.indigo),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.access_time, text: timeStr, color: Colors.orange),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.location_on, text: currentRide.meetingPoint, color: Colors.redAccent),
            const SizedBox(height: 24),

            // Περιγραφή
            const Text(
              'About this ride',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              currentRide.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Συμμετέχοντες (Με τον ζωντανό αριθμό!)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.indigo, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    '${currentRide.participants.length} riders are going',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Το κουμπί Συμμετοχής καρφιτσωμένο κάτω-κάτω
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              if (user == null) return;

              // Εδώ χρησιμοποιούμε το id της currentRide
              ref.read(rideControllerProvider.notifier).toggleParticipation(
                rideId: currentRide.id,
                userId: user.uid,
                isGoing: !isGoing,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isGoing ? Colors.redAccent : Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isGoing ? "CANCEL MY SPOT" : "I'M GOING!",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// Ένα μικρό βοηθητικό widget για να μη γράφουμε τον ίδιο κώδικα
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}