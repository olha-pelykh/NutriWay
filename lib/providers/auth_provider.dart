import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  bool _hasCompletedOnboarding = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    // Слухач змін стану автентифікації Firebase
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user == null) {
        _hasCompletedOnboarding = false;
        _clearUserData();
      } else {
        _loadUserData();
      }
      notifyListeners();
    });
    
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    _user = _authService.currentUser;
    if (_user != null) {
      await _loadUserData();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Завантаження даних користувача з SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
            
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  /// Очищення даних користувача з SharedPreferences
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_completed');
      _hasCompletedOnboarding = false;
      
      // Тут можна додати очищення інших даних
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  /// Збереження credentials для Remember Me
  Future<void> saveRememberMeCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }
    } catch (e) {
      debugPrint('Error saving remember me credentials: $e');
    }
  }

  /// Завантаження збережених credentials
  Future<Map<String, dynamic>> loadRememberMeCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberMe) {
        return {
          'remember_me': true,
          'email': prefs.getString('saved_email') ?? '',
          'password': prefs.getString('saved_password') ?? '',
        };
      }
    } catch (e) {
      debugPrint('Error loading remember me credentials: $e');
    }
    
    return {
      'remember_me': false,
      'email': '',
      'password': '',
    };
  }

  /// Очищення збережених credentials
  Future<void> clearRememberMeCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    } catch (e) {
      debugPrint('Error clearing remember me credentials: $e');
    }
  }

  /// Реєстрація нового користувача
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerWithEmailPassword(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Вхід користувача
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Вихід користувача
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _clearUserData();
      await clearRememberMeCredentials();
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Відправка листа для скидання паролю
  Future<bool> sendPasswordResetEmail({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Повторна відправка листа верифікації
  Future<bool> resendEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resendEmailVerification();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Перевірка статусу верифікації email
  Future<bool> checkEmailVerified() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.reloadUser();
      _user = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return _user?.emailVerified ?? false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Видалення облікового запису
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      await _clearUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Встановлення прапорця завершення онбордингу
  Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      _hasCompletedOnboarding = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting onboarding completed: $e');
    }
  }

  /// Очищення повідомлення про помилку
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
