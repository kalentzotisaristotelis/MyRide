import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../controller/garage_controller.dart';
import '../domain/bike_model.dart';

class EditBikeScreen extends ConsumerStatefulWidget {
  final Bike bike;

  const EditBikeScreen({super.key, required this.bike});

  @override
  ConsumerState<EditBikeScreen> createState() => _EditBikeScreenState();
}

class _EditBikeScreenState extends ConsumerState<EditBikeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _ccController;
  late TextEditingController _kmController;

  String? _imageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.bike.make);
    _modelController = TextEditingController(text: widget.bike.model);
    _yearController = TextEditingController(text: widget.bike.year.toString());
    _ccController = TextEditingController(text: widget.bike.cc.toString());
    _kmController = TextEditingController(text: widget.bike.mileage.toString());

    _imageUrl = widget.bike.imageUrl;
  }

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
        final file = File(pickedFile.path);
        final fileName = 'bike_${widget.bike.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = FirebaseStorage.instance.ref().child('garage_photos/$fileName');

        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();

        setState(() {
          _imageUrl = downloadUrl;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _updateBike() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(garageControllerProvider.notifier).updateBike(
        bikeId: widget.bike.id,
        userId: widget.bike.userId,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        cc: double.parse(_ccController.text.trim()),
        mileage: int.parse(_kmController.text.trim()),
        imageUrl: _imageUrl,
      );

      if (mounted) {
        Navigator.pop(context);
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
                  child: _imageUrl == null && !_isUploadingImage
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Add Bike Photo'),
                    ],
                  )
                      : _isUploadingImage
                      ? const Center(child: CircularProgressIndicator())
                      : Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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

              // ΧΙΛΙΟΜΕΤΡΑ ΜΕ ΕΛΕΓΧΟ > 0
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
                      decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder()
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter year';
                        final year = int.tryParse(val.trim());
                        if (year == null) return 'Invalid number';

                        final currentYear = DateTime.now().year;
                        if (year < 1900 || year > currentYear + 1) {
                          return 'Range: 1900 - ${currentYear + 1}';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ccController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'CC',
                          border: OutlineInputBorder()
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter CC';
                        final cc = double.tryParse(val.trim());
                        if (cc == null) return 'Invalid number';
                        if (cc < 50 || cc > 5000) {
                          return 'Range: 50 - 5000';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (isLoading || _isUploadingImage) ? null : _updateBike,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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