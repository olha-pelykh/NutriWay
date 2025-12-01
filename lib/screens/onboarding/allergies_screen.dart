import 'package:flutter/material.dart';
import '/models/onboarding_data.dart';
import 'nutrition_goals_screen.dart';

class AllergiesScreen extends StatefulWidget {
  final OnboardingData onboardingData;

  const AllergiesScreen({super.key, required this.onboardingData});

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  final List<String> allergies = [
    'Dairy',
    'Gluten',
    'Nuts',
    'Soy',
    'Shellfish',
    'Eggs',
    'Fish',
    'Other',
  ];
  
  Set<String> selectedAllergies = {};

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
          'Allergies & Intolerances',
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
            const SizedBox(height: 24),
            const Text(
              'Select any allergies or intolerances you have. You can add more later.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ...allergies.map((allergy) => _buildCheckboxItem(allergy)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                widget.onboardingData.allergies = selectedAllergies.toList();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NutritionGoalsScreen(
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

  Widget _buildCheckboxItem(String label) {
    final isSelected = selectedAllergies.contains(label);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedAllergies.remove(label);
                } else {
                  selectedAllergies.add(label);
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
                  color: const Color(0xFFE8E8E8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}