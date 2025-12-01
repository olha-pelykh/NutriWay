import 'package:flutter/material.dart';
import '/models/onboarding_data.dart';
import 'meal_preferences_screen.dart';

class NutritionGoalsScreen extends StatefulWidget {
  final OnboardingData onboardingData;

  const NutritionGoalsScreen({super.key, required this.onboardingData});

  @override
  State<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends State<NutritionGoalsScreen> {
  final _caloriesController = TextEditingController(text: '2000');
  final _proteinController = TextEditingController(text: '150');
  final _fatsController = TextEditingController(text: '65');
  final _carbsController = TextEditingController(text: '250');

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nutrition Goals',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Set your daily nutrition goals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'These targets will help you track your daily intake',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Calories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter daily calorie goal',
                filled: true,
                fillColor: const Color(0xFFE8E8E8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Macronutrients',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Protein (g)', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE8E8E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fats (g)', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fatsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE8E8E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Carbs (g)', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _carbsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFE8E8E8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // Зберігаємо дані про нутрієнти
                widget.onboardingData.calories = int.tryParse(_caloriesController.text.trim()) ?? 2000;
                widget.onboardingData.protein = int.tryParse(_proteinController.text.trim()) ?? 150;
                widget.onboardingData.fats = int.tryParse(_fatsController.text.trim()) ?? 65;
                widget.onboardingData.carbs = int.tryParse(_carbsController.text.trim()) ?? 250;

                // Переходимо на наступний екран
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealPreferencesScreen(
                      onboardingData: widget.onboardingData,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
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
