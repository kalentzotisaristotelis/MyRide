import 'package:flutter/material.dart';
// Κάνουμε import το αρχείο της οθόνης σύνδεσης
import 'features/auth/presentation/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Κρύβει την ταμπέλα "Debug"
      title: 'MyRide',
      theme: ThemeData(
        // Βάζουμε το πορτοκαλί ως βασικό χρώμα παντού
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // ΕΔΩ είναι το μυστικό: Λέμε στην εφαρμογή να ξεκινήσει με το LoginScreen
      home: const LoginScreen(),
    );
  }
}