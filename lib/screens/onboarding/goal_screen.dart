import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_you_screen.dart';
import '../auth_wrapper.dart';
import '/models/onboarding_data.dart';

class GoalScreen extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? gender;

  const GoalScreen({
    super.key,
    this.firstName,
    this.lastName,
    this.gender,
  });

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String? selectedGoal;

  Future<void> _handleBack() async {
    // Clear onboarding flag and return to auth
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
    
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBack,
          ),
        title: const Text(
          'Your Goal',
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
              'What\'s your main goal?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'ll tailor your experience based on your primary health objective.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: _buildGoalButton('Lose Weight'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGoalButton('Build Muscle'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGoalButton('Improve Overall Health'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                if (selectedGoal == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Будь ласка, виберіть вашу ціль'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                
                final onboardingData = OnboardingData(
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  gender: widget.gender,
                  goal: selectedGoal,
                );
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutYouScreen(
                      onboardingData: onboardingData,
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
      ),
    );
  }

  Widget _buildGoalButton(String goal) {
    final isSelected = selectedGoal == goal;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal;
        });
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE8E8E8),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            goal,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
