import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

// ΑΛΛΑΓΗ 1: Έγινε ConsumerStatefulWidget για να "ακούει" Riverpod
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// ΑΛΛΑΓΗ 2: Έγινε ConsumerState
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ΑΛΛΑΓΗ 3: Συνάρτηση που καλείται όταν πατηθεί το κουμπί
  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      // Καλούμε τον Controller να κάνει login
      ref.read(authControllerProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ΑΛΛΑΓΗ 4: "Ακούμε" την κατάσταση του Controller
    // Αν αλλάξει (π.χ. βγάλει λάθος), δείχνουμε μήνυμα
    ref.listen<AsyncValue>(authControllerProvider, (previous, next) {
      // Αν υπάρχει λάθος, δείξε κόκκινη μπάρα (SnackBar)
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Αν πέτυχε (δεν έχει λάθος και δεν φορτώνει), εδώ θα βάλουμε πλοήγηση μετά
      if (!next.isLoading && !next.hasError && next.hasValue) {
        print("LOGIN SUCCESS!"); // Προσωρινό, για να το δούμε στην κονσόλα
      }
    });

    // ΑΛΛΑΓΗ 5: Ελέγχουμε αν φορτώνει τώρα
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
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
                    const Icon(
                      Icons.two_wheeler,
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
                    const SizedBox(height: 48),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
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

                    // ΑΛΛΑΓΗ 6: Το κουμπί αλλάζει αν φορτώνει
                    ElevatedButton(
                      // Αν φορτώνει, απενεργοποιούμε το κουμπί (null)
                      onPressed: isLoading ? null : _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white) // Δείξε κυκλάκι
                          : const Text( // Αλλιώς δείξε κείμενο
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