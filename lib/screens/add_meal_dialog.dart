import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Tag chip widget
class _RecipeTag extends StatelessWidget {
  final String text;
  const _RecipeTag(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class AddMealDialog extends StatelessWidget {
  final String mealType;
  final Function(Map<String, dynamic>) onRecipeSelected;
  final VoidCallback onCreateRecipe;

  const AddMealDialog({
    super.key,
    required this.mealType,
    required this.onRecipeSelected,
    required this.onCreateRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white, // Ensure dialog background is white
      child: SizedBox(
        width: 350,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Select recipe for $mealType', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No recipes found'));
                  }
                  final recipes = snapshot.data!.docs;
                  return ListView.separated(
                    itemCount: recipes.length,
                    separatorBuilder: (context, idx) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = recipes[index].data() as Map<String, dynamic>;
                      final imageUrl = data['imageUrl'] as String?;
                      final isNetworkImage = imageUrl != null && imageUrl.startsWith('http');
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          onRecipeSelected(data);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0,1))],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: isNetworkImage
                                    ? Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image))
                                    : Container(width: 56, height: 56, color: Colors.grey[300], child: const Icon(Icons.image, size: 32)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? '',
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['ingredients'] ?? '',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 2,
                                      children: [
                                        if (data['calories'] != null)
                                          _RecipeTag('${data['calories']} kcal'),
                                        if (data['time'] != null)
                                          _RecipeTag('${data['time']} min'),
                                        if (data['tag'] != null)
                                          _RecipeTag(data['tag']),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create new recipe'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCreateRecipe();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
