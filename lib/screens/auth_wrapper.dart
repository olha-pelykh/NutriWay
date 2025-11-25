import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'onboarding/goal_screen.dart';
import '/services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool showLogin = false;

  void toggleScreen() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  Future<bool> _hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          // Check if email is verified
          if (user.emailVerified) {
            // Check if user has completed onboarding
            return FutureBuilder<bool>(
              future: _hasCompletedOnboarding(),
              builder: (context, onboardingSnapshot) {
                if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final hasCompleted = onboardingSnapshot.data ?? false;
                return hasCompleted ? const HomeScreen() : const GoalScreen();
              },
            );
          } else {
            // Show email verification screen
            return EmailVerificationScreen(user: user);
          }
        }

        // User is not signed in - show login or register
        return showLogin 
            ? LoginScreen(onToggle: toggleScreen)
            : RegisterScreen(onToggle: toggleScreen);
      },
    );
  }
}

class EmailVerificationScreen extends StatefulWidget {
  final User user;
  
  const EmailVerificationScreen({super.key, required this.user});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isResending = false;

  Future<void> _checkEmailVerified() async {
    await _authService.reloadUser();
    
    // Check again after reload
    final currentUser = _authService.currentUser;
    await currentUser?.reload();
    final isVerified = currentUser?.emailVerified ?? false;
    
    if (isVerified) {
      if (!mounted) return;
      
      // Email verified! Navigate to AuthWrapper to trigger proper navigation
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    
    try {
      await _authService.resendEmailVerification();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 100,
                color: Colors.black54,
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We sent a verification email to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Please check your inbox and click the verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFB0B0B0),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: _checkEmailVerified,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'I\'ve Verified My Email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isResending ? null : _resendVerificationEmail,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE8E8E8), width: 2),
                  ),
                  child: Center(
                    child: _isResending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Resend Verification Email',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel Registration?'),
                      content: const Text(
                        'Your account has not been verified yet. If you sign out now, your account will be deleted and you\'ll need to register again.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Stay'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true) {
                    try {
                      // Delete the unverified account
                      await _authService.deleteAccount();
                      
                      // Clear onboarding flag
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('onboarding_completed');
                      
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete account: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      // Sign out anyway
                      await _authService.signOut();
                    }
                  }
                },
                child: const Text(
                  'Cancel & Delete Account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}