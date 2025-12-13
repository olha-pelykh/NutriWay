import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class CreateRecipeScreen extends StatefulWidget {
  final String? recipeId;
  final Map<String, dynamic>? recipeData;
  
  const CreateRecipeScreen({super.key, this.recipeId, this.recipeData});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final nameController = TextEditingController();
  final instructionsController = TextEditingController();
  final caloriesController = TextEditingController();
  final timeController = TextEditingController();
  final proteinController = TextEditingController();
  final fatController = TextEditingController();
  final carbController = TextEditingController();
  final tagController = TextEditingController();
  
  // Image handling
  File? _selectedImage;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();
  
  // Ingredient fields
  final ingredientNameController = TextEditingController();
  final ingredientAmountController = TextEditingController();
  String selectedUnit = 'g';
  List<Map<String, String>> ingredients = [];
  
  List<String> tags = [];
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.recipeData != null) {
      _loadRecipeData();
    }
  }
  
  void _loadRecipeData() {
    final data = widget.recipeData!;
    nameController.text = data['name'] ?? '';
    instructionsController.text = data['instructions'] ?? '';
    caloriesController.text = data['calories']?.toString() ?? '';
    timeController.text = data['time']?.toString() ?? '';
    proteinController.text = data['protein']?.toString() ?? '';
    fatController.text = data['fat']?.toString() ?? '';
    carbController.text = data['carb']?.toString() ?? '';
    
    // Validate base64 image before loading
    final imageUrl = data['imageUrl'] ?? '';
    if (imageUrl.isNotEmpty && imageUrl.startsWith('data:image')) {
      try {
        // Try to decode to validate
        final base64String = imageUrl.split(',')[1];
        base64Decode(base64String);
        _uploadedImageUrl = imageUrl; // Valid base64
      } catch (e) {
        // Invalid base64, clear it
        _uploadedImageUrl = '';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe image is corrupted. Please upload a new one.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      _uploadedImageUrl = imageUrl;
    }
    
    // Load ingredients
    if (data['ingredientsList'] != null) {
      final ingredientsList = data['ingredientsList'] as List<dynamic>;
      ingredients = ingredientsList.map((ing) => {
        'name': ing['name']?.toString() ?? '',
        'amount': ing['amount']?.toString() ?? '',
        'unit': ing['unit']?.toString() ?? 'g',
      }).toList();
    }
    
    // Load tags
    if (data['tags'] != null) {
      tags = List<String>.from(data['tags']);
    }
  }

  void _addIngredient() {
    if (ingredientNameController.text.trim().isNotEmpty && 
        ingredientAmountController.text.trim().isNotEmpty) {
      setState(() {
        ingredients.add({
          'name': ingredientNameController.text.trim(),
          'amount': ingredientAmountController.text.trim(),
          'unit': selectedUnit,
        });
        ingredientNameController.clear();
        ingredientAmountController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void _addTag() {
    if (tagController.text.trim().isNotEmpty) {
      setState(() {
        tags.add(tagController.text.trim());
        tagController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      tags.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploadedImageUrl = null; // Clear previous URL
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<String?> _convertImageToBase64() async {
    if (_selectedImage == null) {
      return _uploadedImageUrl; // Return existing base64 if no new image
    }

    try {
      // Check if file exists
      if (!await _selectedImage!.exists()) {
        throw Exception('Image file does not exist');
      }

      // Show processing message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing image...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Read file as bytes
      final bytes = await _selectedImage!.readAsBytes();
      
      // Convert to base64
      final base64String = base64Encode(bytes);
      
      // Add data URI prefix for proper image display
      final dataUri = 'data:image/jpeg;base64,$base64String';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image processed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }

      return dataUri;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _saveRecipe() async {
    setState(() => isLoading = true);
    
    // Convert image to base64 if a new one was selected
    String? imageUrl = await _convertImageToBase64();
    
    final recipeData = {
      'name': nameController.text,
      'ingredientsList': ingredients,
      'instructions': instructionsController.text,
      'calories': caloriesController.text,
      'time': timeController.text,
      'protein': proteinController.text,
      'fat': fatController.text,
      'carb': carbController.text,
      'tags': tags,
      'tag': tags.isNotEmpty ? tags.first : '', // Keep for backward compatibility
      'imageUrl': imageUrl ?? '',
    };
    
    if (widget.recipeId != null) {
      // Update existing recipe
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .update(recipeData);
    } else {
      // Create new recipe
      await FirebaseFirestore.instance.collection('recipes').add(recipeData);
    }
    
    setState(() => isLoading = false);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipeId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Recipe' : 'Create Recipe',
          style: const TextStyle(fontFamily: 'Josefin Sans'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(fontFamily: 'Josefin Sans'),
              decoration: InputDecoration(
                labelText: 'Recipe Name',
                labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Ingredients Section
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Josefin Sans',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: ingredientNameController,
                    style: const TextStyle(fontFamily: 'Josefin Sans'),
                    decoration: InputDecoration(
                      labelText: 'Ingredient',
                      labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                      filled: true,
                      fillColor: const Color(0xFFE8E8E8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: ingredientAmountController,
                    style: const TextStyle(fontFamily: 'Josefin Sans'),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                      filled: true,
                      fillColor: const Color(0xFFE8E8E8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedUnit,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontFamily: 'Josefin Sans',
                      color: Colors.black,
                    ),
                    items: ['g', 'kg', 'l', 'ml', 'pcs']
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedUnit = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addIngredient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Josefin Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (ingredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                ),
                child: Column(
                  children: ingredients.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ingredient = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ingredient['name']!,
                              style: const TextStyle(
                                fontFamily: 'Josefin Sans',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '${ingredient['amount']} ${ingredient['unit']}',
                            style: TextStyle(
                              fontFamily: 'Josefin Sans',
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _removeIngredient(index),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            TextField(
              controller: instructionsController,
              style: const TextStyle(fontFamily: 'Josefin Sans'),
              decoration: InputDecoration(
                labelText: 'Instructions',
                labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: caloriesController,
              style: const TextStyle(fontFamily: 'Josefin Sans'),
              decoration: InputDecoration(
                labelText: 'Calories',
                labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              style: const TextStyle(fontFamily: 'Josefin Sans'),
              decoration: InputDecoration(
                labelText: 'Time (min)',
                labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: proteinController,
              style: const TextStyle(fontFamily: 'Josefin Sans'),
              decoration: InputDecoration(
                labelText: 'Protein (g)',
                labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fatController,
              style: const TextStyle(fontFamily: 'Josefin Sans'),
              decoration: InputDecoration(
                labelText: 'Fat (g)',
                labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: carbController,
              style: const TextStyle(fontFamily: 'Josefin Sans'),
              decoration: InputDecoration(
                labelText: 'Carbs (g)',
                labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tagController,
                    style: const TextStyle(fontFamily: 'Josefin Sans'),
                    decoration: InputDecoration(
                      labelText: 'Tag (e.g. vegan)',
                      labelStyle: const TextStyle(fontFamily: 'Josefin Sans'),
                      filled: true,
                      fillColor: const Color(0xFFE8E8E8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Josefin Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(
                      entry.value,
                      style: const TextStyle(
                        fontFamily: 'Josefin Sans',
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.black,
                    deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onDeleted: () => _removeTag(entry.key),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            
            // Image Upload Section
            const Text(
              'Recipe Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Josefin Sans',
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCCCCC), width: 2),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : _uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _uploadedImageUrl!.startsWith('data:image')
                                ? Builder(
                                    builder: (context) {
                                      try {
                                        final base64String = _uploadedImageUrl!.split(',')[1];
                                        final bytes = base64Decode(base64String);
                                        return Image.memory(
                                          bytes,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Tap to select image',
                                                    style: TextStyle(
                                                      fontFamily: 'Josefin Sans',
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      } catch (e) {
                                        // If base64 decode fails, show placeholder
                                        return const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                              SizedBox(height: 8),
                                              Text(
                                                'Invalid image. Tap to select new one',
                                                style: TextStyle(
                                                  fontFamily: 'Josefin Sans',
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : Image.network(
                                    _uploadedImageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text(
                                              'Tap to select image',
                                              style: TextStyle(
                                                fontFamily: 'Josefin Sans',
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to select image from gallery',
                                  style: TextStyle(
                                    fontFamily: 'Josefin Sans',
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Update Recipe' : 'Save Recipe',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Josefin Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
