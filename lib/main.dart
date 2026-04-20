import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/notification_service.dart';
import 'firebase_options.dart';
import 'features/auth/view/auth_wrapper.dart';

void main() async {
  // Απαραίτητο για async main
  WidgetsFlutterBinding.ensureInitialized();

  // Αρχικοποίηση Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Αρχικοποίηση Ειδοποιήσεων
  await NotificationService().initNotifications();

  // Εκκίνηση εφαρμογής με ProviderScope για το Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
      // Ο AuthWrapper αποφασίζει αν θα δείξει Login ή MainScreen
      home: const AuthWrapper(),
    );
  }
}