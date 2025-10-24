class DailyStats {
  final DateTime date;
  final double distanceKm;
  final int durationMinutes;
  final int caloriesBurned;
  final double goalDistanceKm;
  final int goalMinutes;
  final int goalCalories;

  DailyStats({
    required this.date,
    this.distanceKm = 0.0,
    this.durationMinutes = 0,
    this.caloriesBurned = 0,
    this.goalDistanceKm = 5.0,
    this.goalMinutes = 30,
    this.goalCalories = 300,
  });

  double get distanceProgress => (distanceKm / goalDistanceKm).clamp(0.0, 1.0);
  double get timeProgress => (durationMinutes / goalMinutes).clamp(0.0, 1.0);
  double get caloriesProgress => (caloriesBurned / goalCalories).clamp(0.0, 1.0);

  DailyStats copyWith({
    DateTime? date,
    double? distanceKm,
    int? durationMinutes,
    int? caloriesBurned,
    double? goalDistanceKm,
    int? goalMinutes,
    int? goalCalories,
  }) {
    return DailyStats(
      date: date ?? this.date,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      goalDistanceKm: goalDistanceKm ?? this.goalDistanceKm,
      goalMinutes: goalMinutes ?? this.goalMinutes,
      goalCalories: goalCalories ?? this.goalCalories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'goalDistanceKm': goalDistanceKm,
      'goalMinutes': goalMinutes,
      'goalCalories': goalCalories,
    };
  }

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date']),
      distanceKm: json['distanceKm'] ?? 0.0,
      durationMinutes: json['durationMinutes'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      goalDistanceKm: json['goalDistanceKm'] ?? 5.0,
      goalMinutes: json['goalMinutes'] ?? 30,
      goalCalories: json['goalCalories'] ?? 300,
    );
  }
}
