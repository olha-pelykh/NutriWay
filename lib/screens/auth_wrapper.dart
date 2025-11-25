import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool showLogin = false;

  void toggleScreen() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLogin 
        ? LoginScreen(onToggle: toggleScreen)
        : RegisterScreen(onToggle: toggleScreen);
  }
}