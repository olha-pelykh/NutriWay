import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Збереження даних онбордингу користувача
  Future<void> saveUserOnboardingData({
    required String firstName,
    required String lastName,
    required String gender,
    required String goal,
    required int age,
    required int height,
    required int weight,
    required String activityLevel,
    required List<String> dietaryPreferences,
    required List<String> allergies,
    required List<String> mealTypes,
    required int snacksCount,
    required int calories,
    required int protein,
    required int fats,
    required int carbs,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('Saving user data for userId: $currentUserId');
      print('Data: firstName=$firstName, lastName=$lastName, gender=$gender');
      
      await _firestore.collection('users').doc(currentUserId).set({
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'goal': goal,
        'age': age,
        'height': height,
        'weight': weight,
        'activityLevel': activityLevel,
        'dietaryPreferences': dietaryPreferences,
        'allergies': allergies,
        'mealTypes': mealTypes,
        'snacksCount': snacksCount,
        'calories': calories,
        'protein': protein,
        'fats': fats,
        'carbs': carbs,
        'email': _auth.currentUser?.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': true,
      }, SetOptions(merge: true));
      
      print('User data saved successfully!');
    } catch (e) {
      print('Error saving user data: $e');
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Отримання даних користувача
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUserId == null) {
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Оновлення даних користувача
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  /// Видалення даних користувача
  Future<void> deleteUserData() async {
    if (currentUserId == null) {
      return;
    }

    try {
      await _firestore.collection('users').doc(currentUserId).delete();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  /// Перевірка чи завершив користувач онбординг
  Future<bool> hasCompletedOnboarding() async {
    if (currentUserId == null) {
      return false;
    }

    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      return doc.data()?['onboardingCompleted'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Зберегти лог води та страви на день
  Future<void> saveDailyLog({
    required DateTime date,
    int waterMl = 0,
    List<Map<String, dynamic>>? breakfast,
    List<Map<String, dynamic>>? lunch,
    List<Map<String, dynamic>>? dinner,
    List<Map<String, dynamic>>? snacks,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    final logId = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('dailyLogs')
        .doc(logId)
        .set({
      'date': logId,
      'waterMl': waterMl,
      'breakfast': breakfast ?? [],
      'lunch': lunch ?? [],
      'dinner': dinner ?? [],
      'snacks': snacks ?? [],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Отримати лог води та страви на день
  Future<Map<String, dynamic>?> getDailyLog(DateTime date) async {
    if (currentUserId == null) return null;
    final logId = date.toIso8601String().substring(0, 10);
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('dailyLogs')
        .doc(logId)
        .get();
    final data = doc.data();
    if (data == null) {
      // Якщо запису немає, повертаємо порожні поля
      return {
        'date': logId,
        'waterMl': 0,
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snacks': [],
      };
    }
    return data;
  }

  // Отримати всі логи за місяць
  Future<List<Map<String, dynamic>>> getMonthlyLogs(DateTime month) async {
    if (currentUserId == null) return [];
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final query = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('dailyLogs')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String().substring(0, 10))
        .where('date', isLessThan: end.toIso8601String().substring(0, 10))
        .get();
    return query.docs.map((d) => d.data()).toList();
  }
}
