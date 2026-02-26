import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/garage_controller.dart';

class AddBikeScreen extends ConsumerStatefulWidget {
  const AddBikeScreen({super.key});

  @override
  ConsumerState<AddBikeScreen> createState() => _AddBikeScreenState();
}

class _AddBikeScreenState extends ConsumerState<AddBikeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Οι controllers για τα πεδία κειμένου
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _ccController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _ccController.dispose();
    super.dispose();
  }

  // Η συνάρτηση που τρέχει όταν πατάς SAVE
  void _saveBike() async {
    if (_formKey.currentState!.validate()) {
      // 1. Βρες το ID του χρήστη που είναι συνδεδεμένος
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // Αν για κάποιο λόγο δεν υπάρχει, σταμάτα

      // 2. Κάλεσε τον Controller να αποθηκεύσει
      await ref.read(garageControllerProvider.notifier).addBike(
        userId: user.uid,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        yearStr: _yearController.text.trim(),
        ccStr: _ccController.text.trim(),
      );

      // 3. Αν όλα πήγαν καλά (ελέγχουμε αν υπάρχει ακόμα η οθόνη)
      if (mounted) {
        Navigator.pop(context); // Κλείσε τη φόρμα και γύρνα πίσω
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bike added successfully! 🏍️')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Παρακολουθούμε αν φορτώνει για να δείξουμε κυκλάκι στο κουμπί
    final state = ref.watch(garageControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Bike')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(labelText: 'Make (e.g. Honda)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter make' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model (e.g. CBR 600)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter model' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter year';

                        // Προσπαθούμε να το κάνουμε ακέραιο αριθμό
                        final year = int.tryParse(val.trim());
                        if (year == null) return 'Must be a valid number';

                        // Έλεγχος λογικής (π.χ. όχι μηχανή του 1800 ή του 2050)
                        final currentYear = DateTime.now().year;
                        if (year < 1900 || year > currentYear + 1) {
                          return 'Enter a valid year';
                        }
                        return null; // Όλα καλά!
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ccController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CC', border: OutlineInputBorder()),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter CC';

                        // Προσπαθούμε να το κάνουμε δεκαδικό αριθμό (double)
                        final cc = double.tryParse(val.trim());
                        if (cc == null) return 'Must be a valid number';

                        if (cc <= 0) return 'CC must be greater than 0';
                        return null; // Όλα καλά!
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: isLoading ? null : _saveBike,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SAVE BIKE', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}