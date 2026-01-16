import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../main_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Αυτό εδώ παρακολουθεί ΣΥΝΕΧΕΙΑ αν ο χρήστης είναι συνδεδεμένος
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Αν περιμένουμε απάντηση από τη Firebase, δείξε κυκλάκι
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Αν έχουμε δεδομένα (υπάρχει χρήστης), δείξε το Dashboard
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // 3. Αν δεν υπάρχει χρήστης, δείξε το Login
        return const LoginScreen();
      },
    );
  }
}