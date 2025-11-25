import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dietary_preferences_screen.dart';
import '/models/onboarding_data.dart';

class AboutYouScreen extends StatefulWidget {
  final OnboardingData onboardingData;

  const AboutYouScreen({super.key, required this.onboardingData});

  @override
  State<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  
  String? ageError;
  String? heightError;
  String? weightError;

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void _validateAndContinue() {
    setState(() {
      ageError = null;
      heightError = null;
      weightError = null;
    });

    bool hasError = false;

    // Перевірка віку
    if (ageController.text.isEmpty) {
      setState(() {
        ageError = 'Age is required';
      });
      hasError = true;
    } else {
      final age = int.tryParse(ageController.text);
      if (age == null || age < 5 || age > 120) {
        setState(() {
          ageError = 'Age must be between 5 and 120 years';
        });
        hasError = true;
      }
    }

    // Перевірка зросту
    if (heightController.text.isEmpty) {
      setState(() {
        heightError = 'Height is required';
      });
      hasError = true;
    } else {
      final height = double.tryParse(heightController.text);
      if (height == null || height < 50 || height > 250) {
        setState(() {
          heightError = 'Height must be between 50 and 250 cm';
        });
        hasError = true;
      }
    }

    // Перевірка ваги
    if (weightController.text.isEmpty) {
      setState(() {
        weightError = 'Weight is required';
      });
      hasError = true;
    } else {
      final weight = double.tryParse(weightController.text);
      if (weight == null || weight < 10 || weight > 300) {
        setState(() {
          weightError = 'Weight must be between 10 and 300 kg';
        });
        hasError = true;
      }
    }

    if (!hasError) {
      widget.onboardingData.age = int.parse(ageController.text);
      widget.onboardingData.height = int.parse(heightController.text);
      widget.onboardingData.weight = int.parse(weightController.text);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DietaryPreferencesScreen(
            onboardingData: widget.onboardingData,
          ),
        ),
      );
    }
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
          'About you',
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
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            _buildInputField(
              label: 'Age',
              controller: ageController,
              keyboardType: TextInputType.number,
              errorText: ageError,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Height',
              controller: heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: heightError,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: 'Weight',
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: weightError,
            ),
            const Spacer(),
            GestureDetector(
              onTap: _validateAndContinue,
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    String? errorText,
  }) {
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: hasError ? Colors.red : const Color(0xFFE8E8E8),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: label,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
        ),
      ],
    );
  }
}