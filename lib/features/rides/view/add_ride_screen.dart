import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/ride_controller.dart';

class AddRideScreen extends ConsumerStatefulWidget {
  const AddRideScreen({super.key});

  @override
  ConsumerState<AddRideScreen> createState() => _AddRideScreenState();
}

class _AddRideScreenState extends ConsumerState<AddRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _meetingPointController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _meetingPointController.dispose();
    super.dispose();
  }

  // Συνάρτηση που ανοίγει Ημερολόγιο ΚΑΙ μετά Ρολόι!
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // Αύριο προεπιλογή
      firstDate: DateTime.now(), // Δεν μπορούμε να κάνουμε βόλτα στο παρελθόν!
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0), // 10:00 το πρωί προεπιλογή
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  void _saveRide() async {
    // 1. Έλεγχος αν η φόρμα είναι σωστή
    if (!_formKey.currentState!.validate()) return;

    // 2. Έλεγχος αν έχει διαλέξει ημερομηνία/ώρα
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date & Time!')),
      );
      return;
    }

    // 3. Βρίσκουμε ποιος είναι ο χρήστης
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 4. Ενώνουμε την Ημερομηνία με την Ώρα σε ένα τελικό DateTime
    final finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // 5. Αποθήκευση μέσω του Controller
    await ref.read(rideControllerProvider.notifier).addRide(
      creatorId: user.uid,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      date: finalDateTime,
      meetingPoint: _meetingPointController.text.trim(),
    );

    // 6. Κλείνουμε την οθόνη και βγάζουμε μήνυμα
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride created successfully! 🏍️')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideControllerProvider);
    final isLoading = state.isLoading;

    // Φτιάχνουμε ένα ωραίο κείμενο για να δείχνουμε την επιλεγμένη ημερομηνία/ώρα
    String dateTimeText = 'Select Date & Time';
    if (_selectedDate != null && _selectedTime != null) {
      final formattedDate = DateFormat('EEE, dd MMM yyyy').format(_selectedDate!);
      final formattedTime = _selectedTime!.format(context);
      dateTimeText = '$formattedDate at $formattedTime';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organize a Ride'),
        backgroundColor: Colors.indigo, // Ένα ωραίο χρώμα για τις βόλτες
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
                  labelText: 'Ride Title (e.g. Sunday Morning Cruise)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (val) => val!.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _meetingPointController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Point',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (val) => val!.isEmpty ? 'Enter a meeting point' : null,
              ),
              const SizedBox(height: 16),

              // Το κουμπί για το Ημερολόγιο/Ρολόι
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_today, color: Colors.indigo),
                title: Text(dateTimeText, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.edit),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description (Pace, Stops, Rules)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Φέρνει το label πάνω-πάνω
                ),
                validator: (val) => val!.isEmpty ? 'Enter some details' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: isLoading ? null : _saveRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CREATE RIDE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}