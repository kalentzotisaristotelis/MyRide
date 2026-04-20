import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/data/auth_repository.dart';

// IMPORTS
import '../controller/user_controller.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Παίρνουμε το βασικό User (για Email και UID)
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Guest Rider';
    final uid = user?.uid ?? '';

    // 2. Παρακολουθούμε το προφίλ από τη Βάση (Riverpod Provider)
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueGrey),
            tooltip: 'Edit Profile',
            onPressed: () async {
              final currentProfile = profileAsync.valueOrNull;
              // Περιμένουμε να γυρίσει από την οθόνη επεξεργασίας
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(existingProfile: currentProfile),
                ),
              );
              // ΜΟΛΙΣ ΓΥΡΙΣΕΙ: Λέμε στο Riverpod να ξαναδιαβάσει τη βάση για να δούμε τη νέα φώτο/όνομα
              ref.invalidate(currentUserProfileProvider);
            },
          ),
        ],
      ),
      body: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (appUser) {
            final displayName = appUser?.displayName ?? email;
            final bio = appUser?.bio ?? 'No bio yet. Tap Edit to add one!';

            // 3. ΠΑΙΡΝΟΥΜΕ ΤΗ ΦΩΤΟΓΡΑΦΙΑ
            final photoUrl = appUser?.photoUrl;

            // Το γράμμα (fallback αν δεν υπάρχει φώτο)
            final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // --- ΤΟ AVATAR (Διορθωμένο για να δείχνει τη φώτο) ---
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepOrange.shade100,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Text(
                      initialLetter,
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold
                      ),
                    )
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // Το Όνομα
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  // Το Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic
                      ),
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
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                      );
                    },
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