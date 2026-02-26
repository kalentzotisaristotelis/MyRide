import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../garage/domain/bike_model.dart';
import '../controller/service_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final Bike bike; // Χρειαζόμαστε τη μηχανή για να ξέρουμε πού θα μπει το service

  const AddServiceScreen({super.key, required this.bike});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();

  DateTime _selectedDate = DateTime.now(); // Προεπιλογή: Σημερινή μέρα

  @override
  void dispose() {
    _titleController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  // Συνάρτηση που ανοίγει το Ημερολόγιο
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // Από πότε επιτρέπεται
      lastDate: DateTime.now(),  // Μέχρι σήμερα
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveService() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_formKey.currentState!.validate()) {
      await ref.read(serviceControllerProvider.notifier).addService(
        bikeId: widget.bike.id,
        userId: user.uid,
        title: _titleController.text.trim(),
        date: _selectedDate,
        mileage: int.parse(_mileageController.text.trim()),
        notes: _notesController.text.trim(),
        cost: double.parse(_costController.text.trim()),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service added successfully! 🔧')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service Record'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Service Title (e.g., Oil Change)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                ),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),

              // Κουμπί για επιλογή Ημερομηνίας
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_today, color: Colors.blueGrey),
                title: Text('Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
                trailing: const Icon(Icons.edit),
                onTap: _pickDate, // Ανοίγει το ημερολόγιο
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mileage (km)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter mileage';

                  final mileage = int.tryParse(val.trim());
                  if (mileage == null) return 'Must be a valid number';

                  if (mileage < 0) return 'Mileage cannot be negative';
                  return null; // Όλα καλά!
                },
              ),
              const SizedBox(height: 16),

              // ΝΕΟ: Πεδίο για το Κόστος
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cost (€)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter cost';
                  final cost = double.tryParse(val.trim());
                  if (cost == null) return 'Must be a valid number';
                  if (cost < 0) return 'Cost cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3, // Πιο μεγάλο κουτί για σημειώσεις
                decoration: const InputDecoration(
                  labelText: 'Notes / Parts used',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: isLoading ? null : _saveService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SAVE SERVICE', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}