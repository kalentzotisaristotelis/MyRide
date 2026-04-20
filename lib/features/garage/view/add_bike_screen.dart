import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../controller/garage_controller.dart';

class AddBikeScreen extends ConsumerStatefulWidget {
  const AddBikeScreen({super.key});

  @override
  ConsumerState<AddBikeScreen> createState() => _AddBikeScreenState();
}

class _AddBikeScreenState extends ConsumerState<AddBikeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _ccController = TextEditingController();
  final _kmController = TextEditingController();

  String? _imageUrl;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _ccController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (pickedFile != null) {
      setState(() => _isUploadingImage = true);
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final file = File(pickedFile.path);

        final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = FirebaseStorage.instance.ref().child('garage_photos/$fileName');

        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();

        setState(() {
          _imageUrl = downloadUrl;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
        }
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _saveBike() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await ref.read(garageControllerProvider.notifier).addBike(
        userId: user.uid,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        yearStr: _yearController.text.trim(),
        ccStr: _ccController.text.trim(),
        kmStr: _kmController.text.trim(),
        imageUrl: _imageUrl,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bike added successfully! 🏍️')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              GestureDetector(
                onTap: _isUploadingImage ? null : _pickAndUploadImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    image: _imageUrl != null
                        ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageUrl == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isUploadingImage)
                        const CircularProgressIndicator()
                      else
                        const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('Add Bike Photo'),
                    ],
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

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

              // --- ΧΙΛΙΟΜΕΤΡΑ ΜΕ VALIDATION > 0 ---
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Current Kilometers',
                    prefixIcon: Icon(Icons.add_road),
                    border: OutlineInputBorder()
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter mileage';
                  final km = int.tryParse(val.trim());
                  if (km == null) return 'Invalid number';
                  if (km < 0) return 'Mileage cannot be negative';
                  return null;
                },
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
                        final year = int.tryParse(val.trim());
                        if (year == null) return 'Invalid';
                        final currentYear = DateTime.now().year;
                        if (year < 1900 || year > currentYear + 1) return 'Invalid year';
                        return null;
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
                        final cc = double.tryParse(val.trim());
                        if (cc == null) return 'Invalid number';
                        if (cc < 50 || cc > 5000) return 'CC must be 50 - 5000';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: (isLoading || _isUploadingImage) ? null : _saveBike,
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