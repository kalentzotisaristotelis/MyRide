import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_model.dart'; // Βεβαιωθείτε ότι το path είναι σωστό

class EditProfileScreen extends StatefulWidget {
  final AppUser? existingProfile;

  const EditProfileScreen({super.key, this.existingProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingProfile?.displayName ?? '';
    _bioController.text = widget.existingProfile?.bio ?? '';
    _photoUrl = widget.existingProfile?.photoUrl;
  }

  // Συνάρτηση για επιλογή και ανέβασμα εικόνας
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Μείωση μεγέθους για ταχύτητα
    );

    if (pickedFile != null) {
      setState(() => _isUploadingImage = true);
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final file = File(pickedFile.path);

        // 1. Ανέβασμα στο Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('avatars/${user.uid}.jpg');

        await storageRef.putFile(file);

        // 2. Λήψη του Download URL
        final downloadUrl = await storageRef.getDownloadURL();

        // 3. Άμεση ενημέρωση του Firestore για να μη χαθεί το URL
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'photoUrl': downloadUrl,
        }, SetOptions(merge: true));

        setState(() {
          _photoUrl = downloadUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Η φωτογραφία ανέβηκε επιτυχώς! 📸')),
          );
        }
      } catch (e) {
        print("Storage Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Σφάλμα κατά το ανέβασμα: $e')),
          );
        }
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  // Αποθήκευση συνολικού προφίλ (Όνομα, Bio, PhotoUrl)
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          if (_photoUrl != null) 'photoUrl': _photoUrl,
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Το προφίλ αποθηκεύτηκε! ✅')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Firestore Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Αποτυχία αποθήκευσης: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : null,
                  child: _photoUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.indigo,
                    radius: 20,
                    child: IconButton(
                      icon: _isUploadingImage
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Όνομα Αναβάτη',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio / Μοτοσυκλέτα',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}