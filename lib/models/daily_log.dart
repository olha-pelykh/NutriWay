class DailyLog {
  final DateTime date;
  final int waterMl;
  final List<String> meals;

  DailyLog({
    required this.date,
    required this.waterMl,
    required this.meals,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'waterMl': waterMl,
      'meals': meals,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      date: DateTime.parse(map['date'] as String),
      waterMl: map['waterMl'] as int? ?? 0,
      meals: List<String>.from(map['meals'] ?? []),
    );
  }
}
