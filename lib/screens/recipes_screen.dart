import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/utils/image_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'create_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  Set<String> selectedTags = {};
  String sortBy = 'name'; // name, calories, time, protein, fat, carb
  bool sortAscending = true;
  bool isImporting = false;

  Future<void> _importRecipesFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        setState(() => isImporting = true);
        
        String jsonString;
        if (result.files.single.bytes != null) {
          jsonString = utf8.decode(result.files.single.bytes!);
        } else if (result.files.single.path != null) {
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        } else {
          throw Exception('Could not read file');
        }
        
        final jsonData = json.decode(jsonString);
        
        List<dynamic> recipes;
        if (jsonData is List) {
          recipes = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('recipes')) {
          recipes = jsonData['recipes'];
        } else {
          throw Exception('Invalid JSON format. Expected {"recipes": [...]} or [...]');
        }

        if (recipes.isEmpty) {
          throw Exception('No recipes found in file');
        }

        int importedCount = 0;
        for (var recipe in recipes) {
          try {
            await FirebaseFirestore.instance.collection('recipes').add({
              'name': recipe['name'] ?? '',
              'ingredientsList': recipe['ingredientsList'] ?? recipe['ingredients'] ?? [],
              'instructions': recipe['instructions'] ?? '',
              'calories': recipe['calories']?.toString() ?? '',
              'time': recipe['time']?.toString() ?? '',
              'protein': recipe['protein']?.toString() ?? '',
              'fat': recipe['fat']?.toString() ?? '',
              'carb': recipe['carb']?.toString() ?? '',
              'tags': recipe['tags'] ?? [],
              'tag': (recipe['tags'] != null && (recipe['tags'] as List).isNotEmpty) 
                  ? recipe['tags'][0] 
                  : '',
              'imageUrl': recipe['imageUrl'] ?? '',
            });
            importedCount++;
          } catch (recipeError) {
            print('Error importing recipe: ${recipe['name']}, error: $recipeError');
          }
        }

        setState(() => isImporting = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully imported $importedCount of ${recipes.length} recipes',
                style: const TextStyle(fontFamily: 'Josefin Sans'),
              ),
              backgroundColor: Colors.black,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No file selected',
                style: TextStyle(fontFamily: 'Josefin Sans'),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Import error: $e');
      print('Stack trace: $stackTrace');
      setState(() => isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error importing recipes: $e',
              style: const TextStyle(fontFamily: 'Josefin Sans'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sort & Filter',
          style: TextStyle(
            fontFamily: 'Josefin Sans',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(
                  fontFamily: 'Josefin Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortChip('Name', 'name', setDialogState),
                  _buildSortChip('Calories', 'calories', setDialogState),
                  _buildSortChip('Time', 'time', setDialogState),
                  _buildSortChip('Protein', 'protein', setDialogState),
                  _buildSortChip('Fat', 'fat', setDialogState),
                  _buildSortChip('Carbs', 'carb', setDialogState),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Order:',
                    style: TextStyle(
                      fontFamily: 'Josefin Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setDialogState(() => sortAscending = true);
                      setState(() => sortAscending = true);
                    },
                    child: Text(
                      'Ascending',
                      style: TextStyle(
                        fontFamily: 'Josefin Sans',
                        color: sortAscending ? Colors.black : Colors.grey,
                        fontWeight: sortAscending ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setDialogState(() => sortAscending = false);
                      setState(() => sortAscending = false);
                    },
                    child: Text(
                      'Descending',
                      style: TextStyle(
                        fontFamily: 'Josefin Sans',
                        color: !sortAscending ? Colors.black : Colors.grey,
                        fontWeight: !sortAscending ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Filter by tags:',
                    style: TextStyle(
                      fontFamily: 'Josefin Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedTags.isEmpty ? '(All)' : '(${selectedTags.length})',
                    style: const TextStyle(
                      fontFamily: 'Josefin Sans',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final allTags = <String>{};
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    // Get tags from new 'tags' array
                    if (data['tags'] != null && data['tags'] is List) {
                      allTags.addAll((data['tags'] as List).map((t) => t.toString()));
                    }
                    // Also include old 'tag' field for backward compatibility
                    if (data['tag'] != null && (data['tag'] as String).isNotEmpty) {
                      allTags.add(data['tag'] as String);
                    }
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTagChip('All', null, setDialogState),
                      ...allTags.map((tag) => _buildTagChip(tag, tag, setDialogState)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Josefin Sans',
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setDialogState) {
    final isSelected = sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          // Toggle order if clicking same sort option
          if (sortBy == value) {
            setDialogState(() => sortAscending = !sortAscending);
            setState(() => sortAscending = !sortAscending);
          } else {
            setDialogState(() {
              sortBy = value;
              sortAscending = true;
            });
            setState(() {
              sortBy = value;
              sortAscending = true;
            });
          }
        }
      },
      selectedColor: Colors.black,
      backgroundColor: const Color(0xFFF5F5F5),
      labelStyle: TextStyle(
        fontFamily: 'Josefin Sans',
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTagChip(String label, String? value, StateSetter setDialogState) {
    final isSelected = value == null ? selectedTags.isEmpty : selectedTags.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setDialogState(() {
          if (value == null) {
            // "All" button clears all selections
            selectedTags.clear();
          } else {
            if (selected) {
              selectedTags.add(value);
            } else {
              selectedTags.remove(value);
            }
          }
        });
        setState(() {
          if (value == null) {
            selectedTags.clear();
          } else {
            if (selected) {
              selectedTags.add(value);
            } else {
              selectedTags.remove(value);
            }
          }
        });
      },
      selectedColor: Colors.black,
      backgroundColor: const Color(0xFFF5F5F5),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily: 'Josefin Sans',
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  List<QueryDocumentSnapshot> _sortAndFilterRecipes(List<QueryDocumentSnapshot> recipes) {
    // Filter by tags
    var filtered = recipes.where((doc) {
      if (selectedTags.isEmpty) return true;
      final data = doc.data() as Map<String, dynamic>;
      final recipeTags = <String>{};
      
      // Collect all tags from recipe
      if (data['tags'] != null && data['tags'] is List) {
        recipeTags.addAll((data['tags'] as List).map((t) => t.toString()));
      }
      if (data['tag'] != null && (data['tag'] as String).isNotEmpty) {
        recipeTags.add(data['tag'] as String);
      }
      
      // Recipe must have at least one of the selected tags
      return selectedTags.any((tag) => recipeTags.contains(tag));
    }).toList();

    // Sort
    filtered.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      dynamic aValue, bValue;

      switch (sortBy) {
        case 'name':
          aValue = aData['name'] ?? '';
          bValue = bData['name'] ?? '';
          break;
        case 'calories':
        case 'time':
        case 'protein':
        case 'fat':
        case 'carb':
          aValue = int.tryParse(aData[sortBy]?.toString() ?? '0') ?? 0;
          bValue = int.tryParse(bData[sortBy]?.toString() ?? '0') ?? 0;
          break;
        default:
          return 0;
      }

      if (sortBy == 'name') {
        return sortAscending
            ? (aValue as String).compareTo(bValue as String)
            : (bValue as String).compareTo(aValue as String);
      } else {
        return sortAscending
            ? (aValue as int).compareTo(bValue as int)
            : (bValue as int).compareTo(aValue as int);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipes',
          style: TextStyle(fontFamily: 'Josefin Sans'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: isImporting ? null : _importRecipesFromFile,
            tooltip: 'Import recipes from JSON',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No recipes found',
                style: TextStyle(fontFamily: 'Josefin Sans'),
              ),
            );
          }
          final recipes = _sortAndFilterRecipes(snapshot.data!.docs);
          
          if (recipes.isEmpty) {
            return const Center(
              child: Text(
                'No recipes match your filters',
                style: TextStyle(fontFamily: 'Josefin Sans'),
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            separatorBuilder: (context, idx) => const Divider(height: 32, thickness: 1, color: Color(0xFFEAEAEA)),
            itemBuilder: (context, index) {
              final doc = recipes[index];
              final data = doc.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipeId: doc.id,
                        recipeData: data,
                      ),
                    ),
                  );
                },
                onDoubleTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  data['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Josefin Sans',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: ImageHelper.buildRecipeImage(
                                    imageUrl: data['imageUrl'] as String?,
                                    width: 280,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Row(
                                  children: [
                                    // Example: rating stars
                                    Icon(Icons.star, color: Colors.amber, size: 22),
                                    Icon(Icons.star, color: Colors.amber, size: 22),
                                    Icon(Icons.star, color: Colors.amber, size: 22),
                                    Icon(Icons.star, color: Colors.amber, size: 22),
                                    Icon(Icons.star_half, color: Colors.amber, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      '4.8',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Josefin Sans',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'from 139 ratings',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Josefin Sans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  'Nutrition per 100g',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Josefin Sans',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Color(0xFFEAEAEA)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (data['calories'] != null)
                                        _NutritionValue(label: 'Cal', value: '${data['calories']} Kcal'),
                                      if (data['protein'] != null)
                                        _NutritionValue(label: 'Protein', value: '${data['protein']} g'),
                                      if (data['fat'] != null)
                                        _NutritionValue(label: 'Fat', value: '${data['fat']} g'),
                                      if (data['carb'] != null)
                                        _NutritionValue(label: 'Carb', value: '${data['carb']} g'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  'Ingredients',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Josefin Sans',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Color(0xFFEAEAEA)),
                                  ),
                                  child: Column(
                                    children: (data['ingredientsList'] as List<dynamic>? ?? []).map((ingredient) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              ingredient['name'] ?? '',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Josefin Sans',
                                              ),
                                            ),
                                            Text(
                                              ingredient['amount'] ?? '',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[700],
                                                fontFamily: 'Josefin Sans',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ImageHelper.buildRecipeImage(
                          imageUrl: data['imageUrl'] as String?,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Josefin Sans',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (data['calories'] != null) ...[
                                  _RecipeInfoTag('${data['calories']} kcal'),
                                  const SizedBox(width: 8),
                                ],
                                if (data['time'] != null)
                                  _RecipeInfoTag('${data['time']} min'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (data['tags'] != null && (data['tags'] as List).isNotEmpty)
                                  ...(data['tags'] as List).map((tag) => _RecipeTag(tag.toString()))
                                else if (data['tag'] != null)
                                  _RecipeTag(data['tag']),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                'Delete Recipe',
                                style: TextStyle(
                                  fontFamily: 'Josefin Sans',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this recipe?',
                                style: TextStyle(
                                  fontFamily: 'Josefin Sans',
                                  color: Colors.black,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontFamily: 'Josefin Sans',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontFamily: 'Josefin Sans',
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldDelete == true) {
                            await FirebaseFirestore.instance
                                .collection('recipes')
                                .doc(recipes[index].id)
                                .delete();
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Recipe deleted successfully',
                                    style: TextStyle(fontFamily: 'Josefin Sans'),
                                  ),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateRecipeScreen(),
            ),
          );
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Recipe',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Josefin Sans',
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}

// Nutrition value widget for modal
class _NutritionValue extends StatelessWidget {
  final String label;
  final String value;
  const _NutritionValue({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontFamily: 'Josefin Sans',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'Josefin Sans',
          ),
        ),
      ],
    );
  }
}

// Info tag widget (calories and time) - highlighted
class _RecipeInfoTag extends StatelessWidget {
  final String text;
  const _RecipeInfoTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontFamily: 'Josefin Sans',
        ),
      ),
    );
  }
}

// Tag chip widget (regular tags)
class _RecipeTag extends StatelessWidget {
  final String text;
  const _RecipeTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF666666),
          fontWeight: FontWeight.w500,
          fontFamily: 'Josefin Sans',
        ),
      ),
    );
  }
}
