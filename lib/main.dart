import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Πακέτο Firebase
import 'firebase_options.dart'; // 2. Τα κλειδιά που μόλις φτιάξαμε
import 'features/auth/presentation/login_screen.dart';

// Κάνουμε τη main "async" για να περιμένει τη σύνδεση
void main() async {
  // Αυτή η εντολή είναι απαραίτητη όταν η main είναι async
  WidgetsFlutterBinding.ensureInitialized();

  // Εδώ γίνεται η σύνδεση με τη Firebase χρησιμοποιώντας τα κλειδιά που φτιάξαμε
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyRide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}