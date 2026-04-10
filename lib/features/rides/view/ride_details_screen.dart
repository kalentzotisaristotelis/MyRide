import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/ride_model.dart';
import '../controller/ride_controller.dart';
import '../../../core/map_utils.dart';
import '../../profile/controller/user_controller.dart'; // ΝΕΟ IMPORT: Για τα προφίλ των συμμετεχόντων!

class RideDetailsScreen extends ConsumerWidget {
  final Ride ride;

  const RideDetailsScreen({super.key, required this.ride});

  // Η συνάρτηση που πετάει το παραθυράκι με τις επιλογές!
  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref, String rideId) async {
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

    if (selectedReason != null) {
      await ref.read(rideControllerProvider.notifier).deleteRide(rideId);
      if (context.mounted) {
        Navigator.pop(context);
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

    final currentRide = ridesList.firstWhere(
          (r) => r.id == ride.id,
      orElse: () => ride,
    );

    final user = FirebaseAuth.instance.currentUser;
    final isGoing = user != null && currentRide.participants.contains(user.uid);
    final isCreator = user != null && user.uid == currentRide.creatorId;

    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(currentRide.date);
    final timeStr = DateFormat('HH:mm').format(currentRide.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
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

            // --- ΚΟΥΜΠΙ ΤΟΥ ΧΑΡΤΗ ---
            InkWell(
              onTap: () => MapUtils.openMap(currentRide.meetingPoint),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentRide.meetingPoint,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                          const Text(
                            'Πατήστε για προβολή στο χάρτη',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.map_outlined, color: Colors.indigo),
                  ],
                ),
              ),
            ),
            // ------------------------------------------

            const SizedBox(height: 24),
            const Text('About this ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(currentRide.description, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 32),

            // --- ΝΕΑ ΕΜΦΑΝΙΣΗ ΣΥΜΜΕΤΕΧΟΝΤΩΝ ---
            Row(
              children: [
                const Icon(Icons.people, color: Colors.indigo, size: 28),
                const SizedBox(width: 12),
                Text(
                  '${currentRide.participants.length} riders are going',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),

            // Αν δεν υπάρχει κανείς, βγάζουμε μήνυμα, αλλιώς δείχνουμε τη λίστα!
            if (currentRide.participants.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Be the first to join this ride!', style: TextStyle(fontStyle: FontStyle.italic)),
              )
            else
            // Παίρνουμε τη λίστα με τα IDs και για το καθένα φτιάχνουμε ένα _ParticipantTile
              ...currentRide.participants.map((id) => _ParticipantTile(userId: id)).toList(),
            // ---------------------------------
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

// Το νέο Widget που φτιάχνει τη γραμμή του κάθε αναβάτη
class _ParticipantTile extends ConsumerWidget {
  final String userId;
  const _ParticipantTile({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Διαβάζουμε το προφίλ βάσει του ID!
    final profileAsync = ref.watch(userProfileProvider(userId));

    return profileAsync.when(
      loading: () => const ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Φόρτωση αναβάτη...'),
      ),
      error: (e, st) => const ListTile(
        leading: Icon(Icons.error),
        title: Text('Σφάλμα φόρτωσης'),
      ),
      data: (user) {
        final name = user?.displayName ?? 'Άγνωστος Αναβάτης';
        final bio = user?.bio ?? '';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.indigo.shade100,
            child: Text(
              initial,
              style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: bio.isNotEmpty ? Text(bio, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
        );
      },
    );
  }
}