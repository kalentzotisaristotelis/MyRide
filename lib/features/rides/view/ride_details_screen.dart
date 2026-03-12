import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/ride_model.dart';
import '../controller/ride_controller.dart';

class RideDetailsScreen extends ConsumerWidget {
  final Ride ride;

  const RideDetailsScreen({super.key, required this.ride});

  // Η συνάρτηση που πετάει το παραθυράκι με τις επιλογές!
  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref, String rideId) async {
    // Δείχνουμε το Dialog και περιμένουμε να δούμε τι θα διαλέξει ο χρήστης
    String? selectedReason = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Λόγος Ακύρωσης', style: TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Καιρός 🌧️'),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Καιρός', style: TextStyle(fontSize: 16)),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Έκτακτα μέτρα 🚧'),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Έκτακτα μέτρα', style: TextStyle(fontSize: 16)),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Άλλο ⚠️'),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Άλλο', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );
      },
    );

    // Αν διάλεξε κάτι (δεν πάτησε απλά κλικ απέξω για να το κλείσει)
    if (selectedReason != null) {
      // 1. Διαγράφουμε τη βόλτα από τη βάση
      await ref.read(rideControllerProvider.notifier).deleteRide(rideId);

      // 2. Κλείνουμε την οθόνη και γυρνάμε στο Feed
      if (context.mounted) {
        Navigator.pop(context);
        // 3. Βγάζουμε το μήνυμα με τον λόγο!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Η βόλτα ακυρώθηκε. Λόγος: $selectedReason'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesList = ref.watch(ridesStreamProvider).valueOrNull ?? [];

    // Βρίσκουμε την τωρινή βόλτα. Αν διαγράφηκε μόλις τώρα, краτάμε την παλιά για να μη σκάσει η οθόνη πριν κλείσει.
    final currentRide = ridesList.firstWhere(
          (r) => r.id == ride.id,
      orElse: () => ride,
    );

    final user = FirebaseAuth.instance.currentUser;
    final isGoing = user != null && currentRide.participants.contains(user.uid);
    // Ελέγχουμε αν αυτός που βλέπει την οθόνη είναι ο δημιουργός
    final isCreator = user != null && user.uid == currentRide.creatorId;

    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(currentRide.date);
    final timeStr = DateFormat('HH:mm').format(currentRide.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Το κουμπί Διαγραφής εμφανίζεται ΜΟΝΟ στον δημιουργό!
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Ακύρωση Βόλτας',
              onPressed: () => _showCancelDialog(context, ref, currentRide.id),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentRide.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _InfoRow(icon: Icons.calendar_today, text: dateStr, color: Colors.indigo),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.access_time, text: timeStr, color: Colors.orange),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.location_on, text: currentRide.meetingPoint, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text('About this ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(currentRide.description, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.indigo, size: 28),
                  const SizedBox(width: 12),
                  Text('${currentRide.participants.length} riders are going', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              if (user == null) return;
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