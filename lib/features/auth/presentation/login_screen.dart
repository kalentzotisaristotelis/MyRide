import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Ελέγχουμε τις φόρμες (αν είναι κενές κλπ) με αυτό το κλειδί
  final _formKey = GlobalKey<FormState>();

  // Controllers για να παίρνουμε το κείμενο που γράφει ο χρήστης
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Πάντα καθαρίζουμε τους controllers όταν κλείνει η οθόνη για μνήμη
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ΒάζουμεSafeArea για να μην πέφτει πάνω στο notch του κινητού
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. LOGO & TITLE ---
                    const Icon(
                      Icons.two_wheeler, // Εικονίδιο μηχανής
                      size: 80,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MyRide',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Welcome back, Rider!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // --- 2. EMAIL INPUT ---
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      // Έλεγχος αν το πεδίο είναι κενό
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- 3. PASSWORD INPUT ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // Κρύβει τον κωδικό με τελίτσες
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // --- 4. LOGIN BUTTON ---
                    ElevatedButton(
                      onPressed: () {
                        // Αν η φόρμα είναι έγκυρη (δεν έχει κόκκινα γράμματα)
                        if (_formKey.currentState!.validate()) {
                          // Εδώ αργότερα θα βάλουμε τη λογική σύνδεσης
                          print("Email: ${_emailController.text}");
                          print("Pass: ${_passwordController.text}");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}