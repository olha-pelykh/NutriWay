import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            separatorBuilder: (context, idx) => const Divider(height: 32, thickness: 1, color: Color(0xFFEAEAEA)),
            itemBuilder: (context, index) {
              final data = recipes[index].data() as Map<String, dynamic>;
              return GestureDetector(
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
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: data['imageUrl'] != null && (data['imageUrl'] as String).startsWith('http')
                                      ? Image.network(data['imageUrl'], width: 280, height: 180, fit: BoxFit.cover)
                                      : Container(width: 280, height: 180, color: Colors.grey[300], child: const Icon(Icons.image, size: 60)),
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
                                    Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Text('from 139 ratings', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text('Nutrition per 100g', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                child: Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                            Text(ingredient['name'] ?? '', style: TextStyle(fontSize: 15)),
                                            Text(ingredient['amount'] ?? '', style: TextStyle(fontSize: 15, color: Colors.grey[700])),
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
                        child: data['imageUrl'] != null && (data['imageUrl'] as String).startsWith('http')
                            ? Image.network(data['imageUrl'], width: 100, height: 100, fit: BoxFit.cover)
                            : Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? '',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data['ingredients'] ?? '',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (data['calories'] != null)
                                  _RecipeTag('${data['calories']} kcal'),
                                if (data['time'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: _RecipeTag('${data['time']} min'),
                                  ),
                                if (data['tag'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: _RecipeTag(data['tag']),
                                  ),
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
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}

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
