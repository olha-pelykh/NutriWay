import 'package:flutter/material.dart';
import '../home_screen.dart';

class MealPreferencesScreen extends StatefulWidget {
  const MealPreferencesScreen({super.key});

  @override
  State<MealPreferencesScreen> createState() => _MealPreferencesScreenState();
}

class _MealPreferencesScreenState extends State<MealPreferencesScreen> {
  Set<String> selectedMeals = {'Breakfast', 'Lunch', 'Dinner'};
  int selectedSnacks = 0;
  
  bool get isSnacksEnabled => selectedMeals.contains('Snacks');

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
          'Meal Preferences',
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
              'What types of meals do you usually have?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            _buildMealCheckbox('Breakfast'),
            const SizedBox(height: 16),
            _buildMealCheckbox('Lunch'),
            const SizedBox(height: 16),
            _buildMealCheckbox('Dinner'),
            const SizedBox(height: 16),
            _buildMealCheckbox('Snacks'),
            const SizedBox(height: 40),
            const Text(
              'How many snacks do you have?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Opacity(
              opacity: isSnacksEnabled ? 1.0 : 0.4,
              child: Row(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: isSnacksEnabled ? () {
                        setState(() {
                          selectedSnacks = index;
                        });
                      } : null,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSnacksEnabled && selectedSnacks == index
                                ? Colors.black
                                : const Color(0xFFE8E8E8),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: isSnacksEnabled ? Colors.black : const Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
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
                    'Finish',
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

  Widget _buildMealCheckbox(String label) {
    final isSelected = selectedMeals.contains(label);
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedMeals.remove(label);
                // Якщо прибрали Snacks, скидаємо вибір кількості
                if (label == 'Snacks') {
                  selectedSnacks = 0;
                }
              } else {
                selectedMeals.add(label);
              }
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.black)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}