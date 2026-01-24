import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/garage_controller.dart';
import '../domain/bike_model.dart';

class EditBikeScreen extends ConsumerStatefulWidget {
  final Bike bike; // Η μηχανή που θα επεξεργαστούμε

  const EditBikeScreen({super.key, required this.bike});

  @override
  ConsumerState<EditBikeScreen> createState() => _EditBikeScreenState();
}

class _EditBikeScreenState extends ConsumerState<EditBikeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers για τα πεδία κειμένου
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _ccController;

  @override
  void initState() {
    super.initState();
    // Γεμίζουμε τα κουτάκια με τα υπάρχοντα δεδομένα της μηχανής
    _makeController = TextEditingController(text: widget.bike.make);
    _modelController = TextEditingController(text: widget.bike.model);
    _yearController = TextEditingController(text: widget.bike.year.toString());
    _ccController = TextEditingController(text: widget.bike.cc.toString());
  }

  @override
  void dispose() {
    // Καθαρίζουμε τη μνήμη όταν κλείνει η οθόνη
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _ccController.dispose();
    super.dispose();
  }

  void _updateBike() async {
    if (_formKey.currentState!.validate()) {
      // Καλούμε τη νέα εντολή updateBike που έφτιαξες στον controller
      await ref.read(garageControllerProvider.notifier).updateBike(
        bikeId: widget.bike.id,
        userId: widget.bike.userId,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        cc: double.parse(_ccController.text.trim()),
      );

      if (mounted) {
        Navigator.pop(context); // Κλείνουμε τη φόρμα
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bike updated! 🛠️')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.bike.make}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(labelText: 'Make', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter make' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model', border: OutlineInputBorder()),
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
                      validator: (val) => val!.isEmpty ? 'Enter year' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ccController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CC', border: OutlineInputBorder()),
                      validator: (val) => val!.isEmpty ? 'Enter CC' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _updateBike,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Μπλε κουμπί για αλλαγή
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('UPDATE BIKE', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}