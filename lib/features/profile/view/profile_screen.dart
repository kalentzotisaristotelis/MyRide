import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/data/auth_repository.dart';

// ΝΕΑ IMPORTS: Φέρνουμε τον Controller και την Οθόνη Επεξεργασίας
import '../controller/user_controller.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Παίρνουμε το βασικό User (για Email και UID)
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Guest Rider';
    final uid = user?.uid ?? '';

    // 2. ΝΕΟ: Παρακολουθούμε το προφίλ από τη Βάση (για Όνομα & Bio)
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Βάζουμε εδώ το κουμπάκι της Επεξεργασίας!
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueGrey),
            tooltip: 'Edit Profile',
            onPressed: () {
              final currentProfile = profileAsync.valueOrNull;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(existingProfile: currentProfile),
                ),
              );
            },
          ),
        ],
      ),
      body: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (appUser) {
            // Αν έχει φτιάξει προφίλ, παίρνουμε το όνομά του. Αλλιώς δείχνουμε το Email.
            final displayName = appUser?.displayName ?? email;
            final bio = appUser?.bio ?? 'No bio yet. Tap Edit to add one!';

            // Το γράμμα για το κυκλάκι (παίρνει το πρώτο γράμμα του ονόματος)
            final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Το Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepOrange.shade100,
                    child: Text(
                      initialLetter,
                      style: const TextStyle(fontSize: 40, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Το Όνομα (Rider Name)
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  // Το Bio (ΝΕΟ!)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Το ID
                  Text(
                    'ID: ${uid.substring(0, 5)}...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),

                  const SizedBox(height: 40),

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

                  const Spacer(),

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
            );
          }
      ),
    );
  }
}