import 'package:flutter/material.dart';
import '../services/user_data_service.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
    final _userDataService = UserDataService();
    Future<void> _saveUserData() async {
      final data = {
        'firstName': _nameController.text,
        'lastName': _surnameController.text,
        'mobilePhone': _mobileController.text,
        'email': _emailController.text,
        'weight': _weightController.text,
        'height': _heightController.text,
        'steps': _stepsController.text,
        'waterIntake': _waterController.text,
        'calories': _caloriesController.text,
        'protein': _proteinController.text,
        'fats': _fatsController.text,
        'carbs': _carbsController.text,
        'notifications': notificationsEnabled,
      };
      await _userDataService.updateUserData(data);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
    }
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _stepsController = TextEditingController();
  final _waterController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();
  bool notificationsEnabled = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDataService = UserDataService();
    final data = await userDataService.getUserData();
    if (data != null) {
      setState(() {
        _nameController.text = data['firstName'] ?? '';
        _surnameController.text = data['lastName'] ?? '';
        _mobileController.text = data['mobilePhone'] ?? '';
        _emailController.text = data['email'] ?? '';
        _weightController.text = (data['weight'] ?? '').toString();
        _heightController.text = (data['height'] ?? '').toString();
        _stepsController.text = (data['steps'] ?? '').toString();
        _waterController.text = (data['waterIntake'] ?? '').toString();
        _caloriesController.text = (data['calories'] ?? '').toString();
        _proteinController.text = (data['protein'] ?? '').toString();
        _fatsController.text = (data['fats'] ?? '').toString();
        _carbsController.text = (data['carbs'] ?? '').toString();
        notificationsEnabled = data['notifications'] ?? false;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  _SettingsField(label: 'Name', controller: _nameController),
                  _SettingsField(label: 'Surname', controller: _surnameController),
                  _SettingsField(label: 'Mobile Phone', controller: _mobileController),
                  _SettingsField(label: 'Email', controller: _emailController),
                  _SettingsField(label: 'Password', controller: _passwordController, obscureText: true),
                  const SizedBox(height: 24),
                  const Text('Biometric Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  _SettingsField(label: 'Weight', controller: _weightController),
                  _SettingsField(label: 'Height', controller: _heightController),
                  const SizedBox(height: 24),
                  const Text('Fitness Goals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  _SettingsField(label: 'Steps', controller: _stepsController),
                  _SettingsField(label: 'Water Intake', controller: _waterController),
                  _SettingsField(label: 'Calories', controller: _caloriesController),
                  _SettingsField(label: 'Protein', controller: _proteinController),
                  _SettingsField(label: 'Fats', controller: _fatsController),
                  _SettingsField(label: 'Carbs', controller: _carbsController),
                  const SizedBox(height: 24),
                  const Text('App Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Notifications', style: TextStyle(fontSize: 16)),
                      Switch(value: notificationsEnabled, onChanged: (v) {
                        setState(() => notificationsEnabled = v);
                      }),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAEAEA),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _saveUserData,
                      child: const Text('Save', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAEAEA),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {},
                      child: const Text('Delete Account', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  const _SettingsField({required this.label, this.controller, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEAEAEA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
