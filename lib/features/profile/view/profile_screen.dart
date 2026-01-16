import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Χρειαζόμαστε αυτό
import '../../auth/data/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Παίρνουμε τα στοιχεία του χρήστη που είναι συνδεδεμένος τώρα
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Guest Rider'; // Αν δεν βρει email, δείξε 'Guest'
    final uid = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Το Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepOrange.shade100,
              child: Text(
                email[0].toUpperCase(), // Το πρώτο γράμμα του email (π.χ. 'T')
                style: const TextStyle(fontSize: 40, color: Colors.deepOrange, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // Το Email
            Text(
              email,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            // Το ID (για εφέ, συνήθως το κρύβουμε αλλά είναι καλό για debugging)
            Text(
              'ID: ${uid.substring(0, 5)}...', // Δείχνουμε μόνο τα πρώτα 5 ψηφία
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 40),

            // Μια λίστα με επιλογές (για ομορφιά προς το παρόν)
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help & Support'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const Spacer(), // Σπρώχνει το Logout κάτω-κάτω

            // Το κουμπί Logout
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authRepositoryProvider).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}