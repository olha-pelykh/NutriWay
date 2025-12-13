import 'package:flutter/material.dart';
import 'create_recipe_screen.dart';
import '/utils/image_helper.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String? recipeId;
  final Map<String, dynamic> recipeData;

  const RecipeDetailScreen({super.key, this.recipeId, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Name with Edit Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipeData['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Josefin Sans',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (recipeId != null)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRecipeScreen(
                                recipeId: recipeId,
                                recipeData: recipeData,
                              ),
                            ),
                          );
                          if (result == true && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                  ],
                ),
              ),
              
              // Recipe Image with rounded corners
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ImageHelper.buildRecipeImage(
                    imageUrl: recipeData['imageUrl'] as String?,
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Rating
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Josefin Sans',
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(4, (index) => const Icon(Icons.star, color: Colors.amber, size: 18)),
                      const Icon(Icons.star_half, color: Colors.amber, size: 18),
                      const SizedBox(width: 12),
                      const Text(
                        'from 139 ratings',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Josefin Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Nutrition per 100g
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Nutrition per 100g',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Josefin Sans',
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNutritionItem('Cal', '${recipeData['calories'] ?? '0'} Kcal'),
                      _buildNutritionItem('Protein', '${recipeData['protein'] ?? '0'} g'),
                      _buildNutritionItem('Fat', '${recipeData['fat'] ?? '0'} g'),
                      _buildNutritionItem('Carb', '${recipeData['carb'] ?? '0'} g'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Ingredients
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Josefin Sans',
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: _buildIngredientsContent(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Instructions Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Josefin Sans',
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: _buildInstructionsContent(),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Back button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    'Back to Recipes',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Josefin Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsContent() {
    final instructions = recipeData['instructions'] as String?;
    
    if (instructions != null && instructions.isNotEmpty) {
      return Text(
        instructions,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Josefin Sans',
          height: 1.5,
        ),
      );
    }
    
    return const Text(
      'No instructions provided',
      style: TextStyle(
        fontFamily: 'Josefin Sans',
        color: Colors.grey,
      ),
    );
  }

  Widget _buildIngredientsContent() {
    // Check if we have structured ingredients list
    final ingredientsList = recipeData['ingredientsList'] as List<dynamic>?;
    
    if (ingredientsList != null && ingredientsList.isNotEmpty) {
      // Show structured ingredients
      return Column(
        children: ingredientsList.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ingredient['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Josefin Sans',
                    ),
                  ),
                ),
                Text(
                  '${ingredient['amount'] ?? ''} ${ingredient['unit'] ?? ''}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontFamily: 'Josefin Sans',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
    
    // Otherwise show text-based ingredients
    final ingredientsText = recipeData['ingredients'] as String?;
    if (ingredientsText != null && ingredientsText.isNotEmpty) {
      return Text(
        ingredientsText,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Josefin Sans',
        ),
      );
    }
    
    // No ingredients at all
    return const Text(
      'No ingredients listed',
      style: TextStyle(
        fontFamily: 'Josefin Sans',
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontFamily: 'Josefin Sans',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Josefin Sans',
          ),
        ),
      ],
    );
  }
}
