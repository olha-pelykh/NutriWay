import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
    XFile? _pickedImage;
    String? _uploadedImageUrl;
    Future<void> _pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
        await _uploadImage(image);
      }
    }

    Future<void> _uploadImage(XFile image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('recipe_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      await storageRef.putData(await image.readAsBytes());
      final url = await storageRef.getDownloadURL();
      setState(() {
        _uploadedImageUrl = url;
        imageUrlController.text = url;
      });
    } catch (e) {
      setState(() {
        _uploadedImageUrl = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    }
    }
  final nameController = TextEditingController();
  final ingredientsController = TextEditingController();
  final caloriesController = TextEditingController();
  final timeController = TextEditingController();
  final tagController = TextEditingController();
  final imageUrlController = TextEditingController();

  bool isLoading = false;

  Future<void> _saveRecipe() async {
    setState(() => isLoading = true);
    // Wait for image upload if needed
    String? imageUrl = _uploadedImageUrl;
    if (_pickedImage != null && _uploadedImageUrl == null) {
      await _uploadImage(_pickedImage!);
      imageUrl = _uploadedImageUrl;
    }
    await FirebaseFirestore.instance.collection('recipes').add({
      'name': nameController.text,
      'ingredients': ingredientsController.text,
      'calories': caloriesController.text,
      'time': timeController.text,
      'tag': tagController.text,
      'imageUrl': imageUrl ?? imageUrlController.text,
    });
    setState(() => isLoading = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Recipe Name'),
            ),
            TextField(
              controller: ingredientsController,
              decoration: const InputDecoration(labelText: 'Ingredients'),
              maxLines: 2,
            ),
            TextField(
              controller: caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (min)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(labelText: 'Tag (e.g. vegan)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          // ignore: prefer_const_constructors
                          File(_pickedImage!.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Photo'),
                  onPressed: _pickImage,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL (optional)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading || (_pickedImage != null && _uploadedImageUrl == null) ? null : _saveRecipe,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : (_pickedImage != null && _uploadedImageUrl == null)
                      ? const Text('Uploading image...')
                      : const Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
