class OnboardingData {
  String? firstName;
  String? lastName;
  String? gender;
  String? goal;
  int? age;
  int? height;
  int? weight;
  String? activityLevel;
  List<String>? dietaryPreferences;
  List<String>? allergies;
  List<String>? mealTypes;
  int? snacksCount;

  OnboardingData({
    this.firstName,
    this.lastName,
    this.gender,
    this.goal,
    this.age,
    this.height,
    this.weight,
    this.activityLevel,
    this.dietaryPreferences,
    this.allergies,
    this.mealTypes,
    this.snacksCount,
  });

  Map<String, dynamic> toMap() {
    return {
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
    };
  }

  bool isComplete() {
    return firstName != null &&
        lastName != null &&
        gender != null &&
        goal != null &&
        age != null &&
        height != null &&
        weight != null &&
        activityLevel != null &&
        dietaryPreferences != null &&
        allergies != null &&
        mealTypes != null &&
        snacksCount != null;
  }
}
